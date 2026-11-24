---
id: DEEPDEC-07
owner: DEEPDEC-07
scope: "Donor FX (PFX) and audio semantics/defaults for cossacks.exe + read-only donor text; donor-grounded recipe for variant3d"
date: 2026-11-24
status: COMPLETE — AUDIT ONLY; no target open/select/runtime/source/git edits; no donor art copied
shared_target: t_87f0f3c130b0
---

# DEEPDEC-07 — donor FX (PFX) and audio: real semantics/defaults

## 0. Method and guardrails

- Craft Anything through `execute` only; shared target `t_87f0f3c130b0`
  (`cossacks.exe`, sha256 `87f0f3c1…`). Passed `document` where accepted; never
  `core_target_open`/`core_target_select`; no Frida/GDB/Rizin/runtime, no
  unpacking, no donor code executed. `native`/`formats` toolsets already enabled.
- Whole-file `native_bytes_find` (text + byte patterns), `native_strings_find`,
  `native_library_calls_list`, `native_xrefs_list`, `native_function_callers_list`,
  `native_function_study` + `native_function_pseudocode`, `native_bytes_show`
  (read-only byte windows decoded as ASCII), `core_feature_find`-class RTTI sweeps,
  and `core_text_read` for donor text files.
- Donor text read read-only from `C:\Games\Cossacks 3\data\**`; PowerShell used only
  for read-only enumeration/parsing. **No file other than this report was written.**
- Every finding carries an evidence `id` or an exact donor `path:line` / VA.
  **PROVEN** = readable donor bytes/text. **INFERENCE** = reasoned from PROVEN facts.
  **UNVERIFIED** = absent/unreadable; no constant invented.

## 1. Top 10 findings (executive)

1. **PFX key names are data, not code.** `musketsmoke`, `musketflash`, `cannonexp`,
   `bullettrail`, `source.pfx`, `impactdust`, `musketsparks`, `cannonsmoke` have
   **0 whole-file byte hits** in `cossacks.exe`; they live only in donor text.
   Conversely the engine carries the whole PFX *API* and *type* vocabulary in CODE.
2. **The donor PFX type system is PROVEN and has 10 kinds.** `TXPFXType` at
   `0x75e861..0x75e98c`: `pfxNone, pfxPerlin, pfxFire, pfxTracer, pfxThor,
   pfxFountain, pfxTrail, pfxAtmosphere, pfxSprite, pfxAnimatedSprite`;
   `manager.lib` binds the four source managers: `aspriteshader29/30/31 →
   pfxAnimatedSprite`, `trailbullet → pfxTrail`.
3. **PFX are per-game-object, keyed `(managername, key)`, and fully tunable at
   runtime.** `GameObjectPFXCreateByHandle(gohandle, managername, key)` plus
   `InitialVelocity`, `VelocityDispersion`, `InitialPosition`,
   `PositionDispersion[Range]`, `ParticleInterval`, `EffectScale`, `Scale(x,y,z)`,
   `LifeTime`, `SleepTime`, `Min/MaxExpInitSpeed`, `ExpNumbParticles`,
   `RotationDispersion`, `ProgressMode`, `DisabledIfOwnerInvisible` (RTTI at
   `0x63cd14..0x644bbc`). **None of this is consumed by variant3d.**
4. **A "shot" is a 5-layer composition, not one sprite.** `fx.tree:4-63`
   `shotmusket = musketsmoke + musketflash + musketsparks + musketsmokeup +
   musketflashup`, with per-layer randomisation (`randpixelratio ±25%`,
   `randposition.y ±0.1`, `randframerate ±20`, `randscale.y +0.05`). `shotcannon =
   cannonsmoke + cannonflash + cannonsparks`. This is why the port's sphere+light
   is not donor-equivalent.
5. **`bullettrail` is used for ALL donor projectiles, including arrows** —
   `weapon.script:281-287` maps cannonball/howitzer/mortar/grenade/**arrow**/
   ship-cannon to `bullettrail`; only fire arrows use `firearrowtrail`.
   This resolves AUDIT3D-06 Q2: the port's arrow trail uses the *right key*, but
   only a subset of donor usage, and the 3D box is not donor `msFaceCamera`.
6. **Donor has real impact FX the port lacks.** `weapon.script:263-266` maps
   ground impact → `impactdust`, building impact → `impactsmoke`, water →
   `waterblastsmall`/`waterblast`. `source.pfx` gives exact params (e.g.
   `impactdust`: EndFrame 127, PixelRatio 100, AlphaTime/Power 2.0). The port
   plays `arrowimpact1` audio with **no visual** (AUDIT3D-06 P2-1).
7. **The donor sound engine has full 3D spatial semantics — but the shipped
   skirmish path deliberately neutralises them.** RTTI (`0x6b957c..0x6bb2d0`)
   proves emitter + listener, Min/MaxDistance, Inside/OutsideConeAngle,
   ConeOutsideVolume, KillSndOutOfRad, Height/ScaleFactor; `sound.script:424`
   calls `SetSndSoundRadius(8000)` with comment `80 - for 3D sound, 8000 for
   isometric sound`. Loudness constants at `sound.script:89-100` are
   `Full=8000, Small=20, Medium=40, Large=60, Huge=80`.
8. **Skirmish audio is a grid/aggregation system, not per-event playback.**
   `weapon.script:1148` → `_sound_RequestPlaySound(units, sndind, px,pz)` →
   sound-grid cell (`misc.script:1975-1990`) → `gui.script:3090-3209` merges
   requests across ±4 cells, drops those beyond `40 + listenerHeight + loudness`,
   creates a `soundemitter` game object at the cell centre and plays **one** clip;
   3-5/6-9/10-100 stacked muskets select `musketgroupsmall/medium/large`.
   Those group clips are **absent** from the shipped 325 oggs (UNVERIFIED runtime
   fallback).
9. **Skip/attenuation distance is donor-proven and close to the port's guess.**
   Grid path uses `SetSndSoundRadiuses(0, loudness*1.25, sndHnd)` → outer radii
   25/50/75/100 world units for Small/Medium/Large/Huge; the port currently uses
   a 20-60 m cutoff that is inert in 3D (`audio.gd:317-323`).
10. **The donor engine is software-mixed winmm waveOut, not DirectSound.**
    Imports: `PlaySoundA`, `mmioStringToFOURCCA`, `waveOutOpen/PrepareHeader/
    Write/Close` only (`0x907d9c..0x907db0`); `sub_512f0c` (`0x512f0c`) calls
    waveOutOpen/PrepareHeader/Write. RTTI shows WAV/MP3/OGG decoders, volume
    groups `svgSFX/svgAmbient/svgMusic/svgInterface/svgVoice`, and EAX-style
    environment presets. So `AudioStreamPlayer3D` is a *structural analogue*, not
    a donor-copy; the donor pans/attenuates in software before waveOut.

## 2. Binary evidence table (cossacks.exe)

| id | VA / offset | Finding (OBSERVATION unless marked) |
|---|---|---|
| — (whole-file byte search) | 0 hits | PFX keys `musketsmoke`, `musketflash`, `musketsparks`, `cannonexp`, `cannonsmoke`, `impactsmoke`, `bullettrail`, `source.pfx`, `sndtag`, `sound.script` absent from all 5,768,048 bytes (UTF-8 + UTF-16LE). PFX keys are external data. |
| `ev_4778613bcb…` | `native_strings_find("Snd")` = 0 | Data-section string search finds **no** `Snd*`; all 79 `Snd` hits are CODE-resident literals (whole-file search): `0x6b9586..0x6ba731`. Important trap: data-only string search gives a false negative. |
| `ev_148e0ac7…` / `ev_2f4bded9…` | `0x6b957c..0x6bb2d0` | Full `Snd*` RTTI prototypes (101 lines decoded), e.g. `SndGetOrCreateSound(emittertag: Integer; const libraryname: String; owner: Integer): Integer` at `0x6ba040`; `SetSndSoundRadiuses(rmaxvolume: Float; radius: Float; sound: Integer)` at `0x6ba650`; `SetSndSoundMinDist/MaxDist` `0x6ba724/0x6ba7a4`; `SetSndSoundInsideConeAngle/OutsideConeAngle/ConeOutsideVolume` `0x6ba824/0x6ba8b4/0x6ba948`; `SetSndSoundKillSndOutRad` `0x6ba9e0`; `GetPosSoundManagerListenerAsObject(var x,y,z)` `0x6bac18`; `SetPosSoundManagerListenerAsObject(x,y,z)` `0x6bac7c`; `SetUseSoundManagerListenerAsCamera` `0x6bab40`; `SetSoundManagerHeightFactor/ScaleFactor` `0x6baee0/0x6baf58`; ambient thread `UseRanges/Ranges/CurrentRange` `0x6b9dc0..0x6b9f60`. |
| `ev_abc0fbbb…` | import slots `0x907d9c..0x907db0` | winmm.dll only audio imports (6): `PlaySoundA`, `mmioStringToFOURCCA`, `waveOutClose/Open/PrepareHeader/Write`. No dsound.dll in any of 18 imported libraries. |
| `ev_b3355743…`, `ev_927ed153…` | call sites `0x513055`, `0x513017` | `waveOutWrite@thunk`/`waveOutOpen@thunk` each called from exactly one function, `sub_512f0c` (`0x512f0c`). |
| `ev_b7aa3449…`, `ev_17681ef1…` | `0x512f0c`, 109 instr, 4 blocks | `native_function_study` + pseudocode: output function calls `sub_51313c`, `waveOutOpen(-1, 0x512fcc, 0, 0x30000)`, `waveOutPrepareHeader`, `waveOutWrite`. Ghidra could not lift this address; built-in lifter only — **INFERENCE** grade for the pseudo-C, but the call list is PROVEN. |
| `ev_bd96a122…` | `0x512a29..0x5145c8` | Delphi RTTI: `TOSWSoundSampling` (Frequency/NbChannels/BitsPerSample), `TOSWWAVFile`, `TOSWMP3File`, `TOSWOGGFile`; `TOSWSoundSource` fields `SoundLibrary/Name, Volume, KillSndOutOfRad, NbLoops, SoundGroup, Priority, MinDistance, MaxDistance, InsideConeAngle, OutsideConeAngle, ConeOutsideVolume, Frequency, VolumeRadius, MaxVolumeRadius, RandomOffset`; volume groups `svgSFX, svgAmbient, svgMusic, svgInterface, svgVoice`; 24 `TOSWSoundEnvironment` EAX-style presets (`sePaddedCell … sePsychotic`). |
| `ev_70688e14…` | `0x63cc04..0x644f98` | PFX/game-object script API prototypes: `GameObjectPFXCreateByHandle` (`0x63cd14`), `…InitialVelocity` (`0x63cd84`), `…VelocityDispersion` (`0x63ce48`), `…InitialPosition` (`0x63cee0`), `…PositionDispersion` (`0x63cfa4`), `…PositionDispersionRange` (`0x63d03c`), `…ParticleInterval` (`0x63d120`), `…VelocityMode/DispersionMode/Enabled` (`0x63d1b4/0x63d248/0x63d2e0`), `…EffectScale` (`0x641788`), `…RotationDispersion` (`0x641810`), `…Scale(x,y,z)` (`0x641c08`), `…SetLifeTime` (`0x641e58/0x641ec4`), `…ProgressMode/MinExpInitSpeed/MaxExpInitSpeed/ExpNumbParticles/SleepTime` (`0x6446d4..0x644934`). |
| `ev_50323f95…` | `0x75e861..0x75e98c` | `TXPFXType` enum + `XParticleFX` RTTI: 10 `pfx*` kinds listed in finding 2. |
| `ev_5df8a940…` | `0x6dcfbc..0x6dd304` | Emitter primitives: `EffectSourcePFXBurst(effect,time,nb)`, `EffectSourcePFXIsotropicExplosion(effect,time,mininitialspeed,maxinitialspeed,nbparticles)`, `EffectSourcePFXRingExplosion[XY](...)`, `EffectFireFXInit/IsotropicExplosion/RingExplosion(min/max speed,lifeboostfactor,nbparticles)`. |
| `ev_f60c0b61…` | `0x6dada4..0x6dcf5c` | PFX manager API: `GetOrCreatePFXManager`, `Get/SetPFXManagerType`, `Load/SavePFXManagerFrom/ToParser`; `GetPFXPerlinPFXManagerParticleSize/Acceleration/Friction/BlendingMode/Rotation/AspectRatio/ColorMode/Smoothness/Brightness/Gamma/Noise*`; `Get/SetPFXFireFXManagerInnerColor(r,g,b,a)` / `OuterColor(r,g,b,a)`, `MaxParticles`, `ParticleSize`, `FireDensity/Evaporation/Crown/Burst/Radius`, `ParticleLife`, `ParticleInterval`. Colour is a first-class PFX-manager field. |
| `ev_19b4e79d…` | `0x6dae40..0x6daecc` | `GetPFXManagerType`, `SetPFXManagerType(managername,pfxtype)`, `DestroyPFXManager`, `SavePFXManagerToParser`. |
| `ev_5abf500f…`, `ev_98e08519…` | `0x6ba04a`, `0x6ba5ca` | These string literals are **not inside any discovered function** and have **0 static xrefs** (runtime-computed pointers). Static string→code linking remains unresolved, as in DECOMP-03/04. |
| `ev_dfcc9b98…` etc. | byte patterns | `push/mov imm`/dword-pointer patterns for `0x6ba04a`, `0x6ba05e`, `0x6ba5ca` → 0 matches; confirms no static pointer table. |

## 3. The EXACT PFX parameter list (four known keys)

All values below are **PROVEN** from `C:\Games\Cossacks 3\data\pfx\source.pfx`;
defaults are **PROVEN** from `data\pfx\source.ref` (read-only evidence id
`ev_434ed9b9…`). Units: `PixelRatio` is a pixel-ratio/size parameter; `AlphaTime`
and `LifeTime` are in the engine's time unit; `Interval`/`FrameRate` are animation
timing. **Mapping any of these to metres/seconds is UNVERIFIED** — no consumer
code was recovered that converts them.

### 3.1 `musketsmoke` — `source.pfx:30-65` (`ev_2735a9f8…`), manager `aspriteshader31` = `pfxAnimatedSprite`

| Parameter | Value | path:line |
|---|---|---|
| `LibSourceID` | 1 | source.pfx:34 |
| `ClassName` (ref default) | `TOSWBAnimatedSpriteFX` | source.ref:5 |
| `EndFrame` | **127** | source.pfx:41 |
| `FrameWidth / FrameHeight` | 256 / 128 | source.pfx:42-43 |
| `LibMaterialName` | `musketsmoke` | source.pfx:44 |
| `Dimensions` | `sfdAuto` | source.pfx:45 |
| `Interval` | **10** | source.pfx:46 |
| `FrameRate` | **100** | source.pfx:47 |
| `ImageWidth / ImageHeight` | 2048 / 2048 | source.pfx:48-49 |
| `PixelRatio` | **175** | source.pfx:51 |
| `MirrorU` | True | source.pfx:52 |
| `Position` | X=-0.1, Y=-1.5, Z=0.775 | source.pfx:54-57 |
| `OnEndFrameState` | `FreeToPool` | source.pfx:60 |
| `AlphaTime` | **1.5** | source.pfx:61 |
| `AlphaPower` | **1.5** | source.pfx:62 |

`musketsmoketbn` (`source.pfx:66-101`) is byte-for-byte the same values except
`LibSourceID=2` and manager `aspriteshader30`.

### 3.2 `musketflash` — `source.pfx:102-179` (`ev_a75ccd69…`), manager `aspriteshader29`

Four animation entries, each a single frame (`CurrentFrame/StartFrame/EndFrame =
0/0/0`, `1/1/1`, `2/2/2`, `3/3/3` at source.pfx:114,127,140,153).
Per animation entry: `FrameWidth=256`, `FrameHeight=128`, `Interval=100`,
`FrameRate=10`, `ImageWidth=512`, `ImageHeight=256`.
Top-level: `Interval=100` (:164), `AnimationIndex=0` (:165),
`AnimationMode=samPlayOnce` (:166), `PixelRatio=350` (:167), `MirrorU=True` (:168),
`FrameRate=10` (:169), `Position X=-0.1, Y=-1.0, Z=0.775` (:170-173),
`OnEndFrameHide=True` (:176). **No AlphaTime/AlphaPower** in this key — it hides,
it does not alpha-fade (PROVEN by absence of those fields).

### 3.3 `cannonexp` — `source.pfx:1310-1426` (`ev_187ea843…`), manager `aspriteshader30`

| Parameter | Value | path:line |
|---|---|---|
| `LibSourceID` | 15 | source.pfx:1315 |
| `EndFrame` | **255** (two animation entries :1322 and :1364) | source.pfx:1322,1364 |
| `FrameWidth / FrameHeight` | 128 / 128 | source.pfx:1323-1324 |
| `Interval` | **12** | source.pfx:1327,1404 |
| `FrameRate` | **83.3333** | source.pfx:1328,1409 |
| `ImageWidth / ImageHeight` | 2048 / 2048 | source.pfx:1329-1330 |
| `Uniforms` | `[0] randMax UIndex=3 X=0`; `[1] randStep UIndex=4 X=2`; `[2] randBias UIndex=5 X=0` (second animation: randBias X=2) | source.pfx:1332-1358,1372-1399 |
| `PixelRatio` | **30** | source.pfx:1407 |
| `MirrorV` | True | source.pfx:1408 |
| `NoZTest` | False | source.pfx:1410 |
| `OnEndFrameState` | `FreeToPool` | source.pfx:1412 |
| `AxisAligned` | False | source.pfx:1413 |
| `AlphaTime` | **1.2** | source.pfx:1414 |
| `AlphaPower` | **1.0** | source.pfx:1415 |
| `Position` | X/Y absent (default 0), **Z=1.75** | source.pfx:1416-1417 |
| `Scale` (default block) | 1,1,1 | source.pfx:1420-1422 |

`cannonexpsmoke` (`source.pfx:1427-1543`) is the same timing/PixelRatio but
`AlphaTime=2.0`; `cannonexpbuilding` (`:1544-1586`) EndFrame 127 / FrameRate
71.4286 / PixelRatio 30 / AlphaTime & AlphaPower 2.0.

### 3.4 `bullettrail` — `source.pfx:1731-1767` (`ev_cea65ecc…`), manager `trailbullet` = `pfxTrail`

| Parameter | Value | path:line |
|---|---|---|
| `LibSourceID` | 26 | source.pfx:1733 |
| `ClassName` (`trail`) | `TOSWBTrailFX` (type by manager) | manager.lib / source.pfx:1735 |
| `VertLimit` | **150** | source.pfx:1739 |
| `TimeLimit` | **0.2** | source.pfx:1740 |
| `MinDistance` | **0.05** | source.pfx:1741 |
| `Alpha` | **0.2** | source.pfx:1742 |
| `AlphaFade` | True | source.pfx:1743 |
| `UVScale` | 1 | source.pfx:1744 |
| `MarkStyle` | **msFaceCamera** | source.pfx:1745 |
| `MarkWidth` | **0.1** | source.pfx:1746 |
| `Enabled` | True | source.pfx:1747 |
| `ZWrite / ZTest` | False / False | source.pfx:1748-1749 |
| `LibMaterialName` | `bullettrail` | source.pfx:1750 |
| `Position` | 0,0,0 | source.pfx:1751-1754 |
| `UVRepeat / Finish` | False / False | source.pfx:1755-1756 |
| `UseDiff` | True | source.pfx:1758 |
| `Diffuse` (RGBA) | **1,1,1,1** | source.pfx:1759-1763 |

There is **no `count` and no `velocity` field in any of the four keys** — count and
velocity live in the *manager/effect* layer (`ExpNumbParticles`,
`Min/MaxExpInitSpeed`, `InitialVelocity`, `VelocityDispersion`, `ParticleInterval`,
`EffectSourcePFX*`), not in the sprite/trail descriptor. This is an important
correction to the task's assumed schema: **size = PixelRatio / MarkWidth,
lifetime = EndFrame+Interval+FrameRate or TimeLimit/AlphaTime, colour =
`Diffuse`/`StartColor`/`LifeColor`/`EndColor` (animatedsprite defaults in
source.ref) or Fire manager Inner/OuterColor, count = ExpNumbParticles /
MaxParticles, velocity = InitialVelocity/Min/MaxExpInitSpeed.**

### 3.5 Reference defaults (`source.ref`, `ev_434ed9b9…`)

`animatedsprite` defaults: `ClassName=TOSWBAnimatedSpriteFX`, `Interval=100`,
`AnimationIndex=0`, `AnimationMode=samLoop`, `PixelRatio=800`, `Rotation=0`,
`MirrorU/MirrorV=False`, `FrameRate=10`, `Position=0,0,0`, `Scale=1,1,1`,
`Direction=0,0,1`, `Up=0,1,0`, `Visible=True`, `Unscale=True`,
`Unrotate/Unposition=False`, `UseTLF/UseAnim=False`, `AnimFadeTime=0.5`,
`NoZWrite=True`, `NoZTest=False`, `UseLifeColor=False`,
`StartColor/LifeColor/EndColor = (1,1,1,1)`, `LifeTime=0`, `StartTime/EndTime/
BirthTime/CurrTime=0`, `OnEndTime*/OnEndFrame*` all False, `StartPower/EndPower=1`,
`Turn=0`, `LerpScale/LerpRotation=False`, `StartScale/EndScale=1`,
`StartRotation/EndRotation=0`, `SleepTime=0`, `StartPosition/EndPosition=0,0,0`,
`LerpPosition/LerpAround=False`, `TurnTime/TurnDelta=0`,
`AlphaStartFactor=1`, `AlphaEndFactor=0`, `AlphaTime=0`, `AlphaDelta=0`,
`AlphaPower=1`, `AlphaReset/AlphaDisabled/AlphaInvisible=False`, `Enabled=True`,
`AxisAligned=True`, `AxisAlignedX=0`, `AxisAlignedY=1`,
`AxisAlignedToCamera=True`, `AxisAlignedToCamDir=2`,
`AxisAlignedToCamAng[0]=(0,90,0,-90)`, `[1]=(-89,0,89,0)`, `AxisAlignedToCamEul=0`.

## 4. Donor FX semantic map (readable text only)

### 4.1 Effect compositions — `data\pfx\fx.tree` (PROVEN, `ev_3beb482e…`)

| effectname (fx.tree line) | component keys | semantic kind |
|---|---|---|
| `shotmusket` (:4) | musketsmoke, musketflash, musketsparks, musketsmokeup, musketflashup | musket muzzle shot (5 layers) |
| `shotmusketcav` (:64) | inherits `[0]` via `{refkey}` + offset/overrides | mounted musket shot — INFERENCE from refkey |
| `shotmusketking` (:78), `shotmusketdrag` (:86) | inherit `[0]` | unit variants — INFERENCE |
| `shotcannon` (:100) | cannonsmoke, cannonflash, cannonsparks | cannon muzzle shot |
| `shothowitzer` (:132) | howitzersmoke, howitzerflash, howitzersparks | howitzer muzzle shot |
| `shotmortar` (:165) | mortarsmoke, mortarflash, mortarsparks | mortar muzzle shot |
| `shotmcannon` (:198) | inherits | multicannon — INFERENCE |
| `grenadeexp` (:216) | grenadeexp, grenadesmoke, distexpflare, distexpring | grenade / generic explosion |
| `impactsmoke` (:254) | impactsmoke, distexpring | building/unit hit |
| `impactdust` (:274) | impactdust | ground hit |
| `cannonexpground` (:290) | cannonexp, cannonexpsmoke, distexpflare, distexpring | cannon ground explosion |
| `cannonexpbuilding` (:327) | cannonexpbuilding, distexpring | cannon building explosion |
| `howitzerexpground` (:347), `howitzerexpbuilding` (:354) | inherit | howitzer explosions — INFERENCE |
| `bullettrail` (:361) | bullettrail | projectile ribbon |
| `firearrowtrail` (:370) | firearrowtrail, firearrow | burning arrow + ribbon |
| `fragtrail` (:389) | fragtrail | fragment/debris ribbon |
| `expflash` (:398) | distexpflare, distexpring | distant explosion flash/ring |
| `buildingsmoke` (:418) | buildingfirestart, buildingsmokestart, buildingfire, buildingsmoke | building fire + smoke |
| `shottower` (:444) | towersmoke, towerflash, towersparks | tower gun shot |
| `shotmusketpoint` (:476) | musketsmokepoint, musketsparkspoint | point-defence musket shot |
| `waterblast` (:506), `waterblastsmall` (:522) | same-named key | ship/water splash |

### 4.2 Source entries — `data\pfx\source.pfx` (44 entries; semantic kind from its
name + its `fx.tree` membership). Parameters tabulated in §5 of the working notes
(short form below); all **PROVEN** values, no colour/count invented.

| # | key (source.pfx line) | kind | EndFrame / PixelRatio / AlphaTime,AlphaPower |
|---|---|---|---|
| 1 | aspriteblank (1) | blank placeholder | 0 / (default 800) / – |
| 2 | musketsmoke (30) | smoke | 127 / 175 / 1.5,1.5 |
| 3 | musketsmoketbn (66) | smoke variant | 127 / 175 / 1.5,1.5 |
| 4 | musketflash (102) | flash | 4×1 frame / 350 / none (OnEndFrameHide) |
| 5 | musketsparks (180) | sparks/hit | 11 / 180 / – |
| 6 | musketsmokeup (258) | upward smoke | 63 / 600 / 1.5,1.5 |
| 7 | musketflashup (296) | upward flash | 4×1 / 800 / – |
| 8 | cannonsmoke (374) | smoke | 127 / 120 / 1.5,1.5 |
| 9 | cannonflash (415) | flash | 15 / 450 / – |
| 10 | cannonsparks (457) | sparks | 11 / 170 / – |
| 11 | howitzersmoke (535) | smoke | 127 / 160 / 1.0,1.0 |
| 12 | howitzerflash (593) | flash | 15 / 500 / – |
| 13 | howitzersparks (649) | sparks | 11 / 200 / – |
| 14 | mortarsmoke (741) | smoke | 127 / 200 / 1.0,1.0 |
| 15 | mortarflash (794) | flash | 15 / 700 / – |
| 16 | mortarsparks (850) | sparks | 11 / 250 / – |
| 17 | standingsmoke (942) | ambient/standing smoke | 63 / 15 / – |
| 18 | grenadeexp (1000) | explosion | 127 / 50 / 1.0,1.0 |
| 19 | grenadesmoke (1112) | explosion smoke | 127 / 50 / 1.5,1.5 |
| 20 | impactsmoke (1224) | building hit / dust | 127 / 50 / 2.0,2.0 |
| 21 | impactdust (1265) | ground hit / dust | 127 / 100 / 2.0,2.0 |
| 22 | cannonexp (1310) | explosion | 255 / 30 / 1.2,1.0 |
| 23 | cannonexpsmoke (1427) | explosion smoke | 255 / 30 / 2.0,1.0 |
| 24 | cannonexpbuilding (1544) | building explosion | 127 / 30 / 2.0,2.0 |
| 25 | distexpflare (1587) | distant flash | 0 (single) / 80 / 1.0,1.0 |
| 26 | distexpring (1656) | distant shockwave ring | 0 (single) / 50 / 1.0,1.0 |
| 27 | bullettrail (1731) | projectile ribbon | TimeLimit 0.2 / MarkWidth 0.1 / Alpha 0.2 |
| 28 | fragtrail (1768) | fragment ribbon | TimeLimit 0.2 / MarkWidth 0.05 / Alpha 0.2 |
| 29 | buildingfirestart (1805) | fire ignite | 127 / 110 / 0.0,1.0 |
| 30 | buildingsmokestart (1900) | smoke ignite | 127 / 138 / 0,1.5 |
| 31 | buildingfire (1996) | sustained fire | 127 / 110 / 0.0,1.0 |
| 32 | buildingsmoke (2093) | sustained smoke | 127 / 110 / 0,1.5 |
| 33 | firearrow (2196) | burning projectile | 0 (single) / 1250 / – |
| 34 | firearrowtrail (2304) | burning ribbon | TimeLimit 0.2 / MarkWidth 0.1 / Alpha 0.3 |
| 35 | towersmoke (2341) | tower smoke | 127 / 120 / 1.5,1.5 |
| 36 | towerflash (2382) | tower flash | 15 / 450 / – |
| 37 | towersparks (2424) | tower sparks | 11 / 170 / – |
| 38 | musketsmokepoint (2502) | point smoke | 127 / 175 / 1.5,1.5 |
| 39 | musketflashpoint (2538) | point flash | 0 / 350 / – |
| 40 | musketsparkspoint (2616) | point sparks | 11 / 180 / – |
| 41 | musketsmokeuppoint (2694) | point upward smoke | 63 / 600 / 1.5,1.5 |
| 42 | musketflashuppoint (2732) | point upward flash | 0 / 800 / – |
| 43 | waterblast (2810) | water splash large | 127 / 60 / – |
| 44 | waterblastsmall (2853) | water splash small | 127 / 30 / – |

**UNVERIFIED marks:** keys whose semantic kind rests only on the name and not on
an `fx.tree` membership or script const are: `standingsmoke`, `musketsmoketbn`,
`musketsparks` (sparks is a reasonable but unproven reading), `*point` variants
(the suffix suggests attachment to a point; the engine API proves point attach is
possible but the exact consumer is not resolved), `distexpflare`/`distexpring`
(their *membership* in explosions is proven; individual visual semantics are a
name-derived INFERENCE).

### 4.3 Effect-key dispatch and FX meshes (post-report read-only addendum)

A follow-up whole-folder scan resolved where the `fx.tree` `effectname` keys are
selected: `data\scripts\lib\unit.script` assigns
`objprop.weapon[N].fxshot := 'shotmusket'` / `'shotmusketcav'` / `'shotmusketking'`
/ `'shotmusketdrag'` / `'shotmusketpoint'` per unit-weapon definition
(unit.script:778,905,950,1233,1552,1583,1608,2547). So the effect key is a
**per-weapon object property**, not a global constant.

The shot FX also has real mesh/animation assets (private-use, not copied):
`data\actors\pfx\shot\shotmusket1.actor` (`ev_acbfb30f…`) and `shotmusket2.actor`
(`ev_f20c4886…`) bind `.\data\animations\aaf\pfx\pfxshotmusket1.aaf` /
`pfxshotmusket2.aaf` and `.\data\actors\pfx\shot\shotmusket1.oss` /
`shotmusket2.oss`, all under `refurl=.\data\actors\ref\refpfxbones.actor`.
**INFERENCE:** a donor shot is a 3D animated mesh plus the 5 sprite layers, which
further widens the gap to the port's single sphere+light. `unit.script:6737`
also uses `EffectCreateWithKey(goHnd, 'TXLifeColorEffect', 'blink', false)`,
showing additional effect classes beyond the PFX managers.

## 5. Audio: which files are actually referenced by skirmish events

### 5.1 Library wiring (PROVEN)

`data\sounds\sounds.slc` (`ev_520b3d4e…`): `units → units.snd`,
`interface → interface.snd`, `ambient → ambient.snd`.
`data\sounds\units\units.snd` has **248** `Path` entries → `.ogg` under
`.\data\sounds\units\`; `interface.snd` **52**; `ambient.snd` **27**;
total 327 declared paths vs **325** `.ogg` files on disk (2 duplicates/missing —
**UNVERIFIED** which). This matches the port's 325-clip bed.

### 5.2 Skirmish-event-referenced (units library)

`weapon.script:400-425` (`_weapon_SetWeaponSound`) is the definitive event→library
index map; `sound.script:87-230` (`ev_292f854c…`) expands each index to clip names:

| Weapon/event | `gc_snd_ind_*` | Clips (PROVEN) |
|---|---|---|
| `SHOTMUSKET` | musket | `musket1..15` |
| `PPOINTT`, `PPOINTTTOW`, `PPOINTTFRAME` | shotcannon | `shotcannon1..4` |
| `PPOINTTKOR`, `PPOINTTFRAME5` | shotship | `shotship1..4` |
| `PSMPOINTTPUS` | shotcannoncannister | `shotcannoncannister1..4` |
| `DIMMORT1` | shothowitzer | `shothowitzer1..4` |
| `DIMMORT2NEW`, `DIMMORT2KOR` | shotmortar | `shotmortar1..4` |
| `PSMPOINTT` | shotmulticannon | `shotmulticannon1..4` |
| `PUEXP`, `PUEXPHOWITZER` | explcannon / explhowitzer | `cannonexpl1..3` |
| `PUEXPBLD`, `PUEXPHOWITZERBLD`, `POINTSTONE4` | cannonballhitbuilding | `cannonballhitbuilding1..2` |
| `PUEXPONSHIP`, `PUEXPKORVSKOR` | cannonballhitship | `cannonballhitship`, `cannonballhitbuilding2`, `cannonexpl1..3` |
| `VODABUL`, `VODABUL2` | watersplash | `watersplash1..6` |
| `STRELDEZPRO` | arrowimpact | `arrowimpact1..8` |
| `STRELA` | arrow | `arrow1..7` |
| `OSTRELA` | firearrow | `firearrow1..8` |

Other skirmish event families registered in `sound.script`: sabre/pike/cavsword
(`sabre1..11`, `bayonetbloodhit1..7`), deaths (`deathart1..2`,
`deathbuilding1..2`, `deathinf1..6`, `deathcav1..6`, `deathship`), burn (`burn1..7`),
walk (`walkpea1..5`, `walkpeastone1..9`, `walkinfcloth1..8`, `walkinfmetal1..8`,
`walkcavfast1..12`, `walkcavslow1..11`, `walkartmortar1..10`, `walkartwheels1..9`,
`walkboat1..12`, `walkship1..14`), work (`workstone1..7`, `workwood1..9`,
`workconstruct1..12`), select (`selectpeasant1..6`, `selectship`), band
(`drummer`, `bagpiper`, `officer1..2`), alarm.

### 5.3 Menu/music/ambience only (NOT skirmish events)

`ambient.snd` (`ev_a6ff66cc…`, 27 entries): national music `alg, aus, eng, fra,
pol, pru, rus, spa, swe, tur, ukr, ven, den, net, bav, sax, bat1 (battle), sco,
hun, por, swi, pie`; beds `amb_atmosphere, amb_towneur, amb_wind, amb_windmill,
amb_sea`. `doambientsound.inc` (`ev_3447b1f8…`) creates an ambient thread named
`music`, adds one sound per playable nation, selects the player's nation via
`SetSndAmbientThreadActiveSoundByName`, and crossfades `music`↔`battle` with
`SetSndAmbientThreadSetPlayingFade(...,3/5)` on combat state
(`_sound_MusicSwitchToBattle/National`, `sound.script:547-580`).
Ambient ranges: `amb_wind` low=-5 high=100 vol=0.2; `amb_towneur` low=-1000
high=1000 vol=1 (PROVEN in `doambientsound.inc`).

`interface.snd` (`ev_d10e1abd…`, 52 entries): `btnhover`, `btnclick`, `cancel`,
`bldmil/bldsto/bldmar/bldpor/bldswa/bldsga/bldwwa/bldwga`, etc.;
`VolumeGroup=svgInterface`, `DefPriority=10000`. `sound.script` also registers
`construct`, `cancel`, `btnclick`, `upgcen/upgaca/upgbar/upgba2/upgsta/upgbla/
upgtow/upgart/upgmil/upgpor/upgmine`, `alarm` with `cLoudFull=8000` (global,
non-positional). Note `alarm` is used by the port for `rout`/`capture`
(`main.gd:1632-1634,1657-1658`) — donor also treats it as a global UI-style sound.

### 5.4 Emitter rules (exact, PROVEN)

- `soundemitter.prop` (`ev_75a6e233…`): object `soundemitter`, `StringTag=108`,
  `LODActorName=point`, `DefaultScale=0.0001³` (invisible), state machine
  `soundemitter.aix`, `StateMachineInterval=100`.
- `soundemitter.aix` (`ev_1bb90a57…`): on init stores
  `gSoundManager.emitterhnd := GetGameObjectMyHandle`; `OnDestroy` clears it;
  `FreeToPool` recycles the object.
- `gui.script:3044-3051` `GetOrCreateSoundEmitterInListenerPos` reuses
  `gSoundManager.emitterhnd` and repositions it with `SetGameObjectPositionByHandle`;
  `GetOrCreateSoundEmitterInPos` (`gui.script:3030-3042`) finds/creates a
  `soundemitter` at a grid-cell centre with `CreatePoolGameObjectHandle`.
- `gui.script:2947-2960` `GetScreenListenerPos`: ray-cast through screen centre,
  then `lx = rx - dst*dirx*0.3`, `ly = ry - dst*diry*0.15`, `lz = rz - dst*dirz*0`;
  listener is moved there via `SetPosSoundManagerListenerAsObject` when farther
  than 1 unit. `init.script:148-153` (`ev_a4099c29…`) sets
  `SetUseSoundManagerListenerAsObject(False)`,
  `SetUseSoundManagerListenerAsCamera(False)`,
  `SetAbsSoundManagerListenerAsObject(True)`.
- `sound.script:386-430` `_sound_EmitterPlaySound(emitterHnd, libind, sndlibind,
  bplayuniq)`: random-start linear probe over the library to find a free handle;
  tags `_sound_GetTagByIndexes(sndlibind,index)` (unique = `1,000,000+sndlibind`);
  `SetSndSoundSourceName(clip, sndHnd)`;
  `SetSndSoundRadius({40}8000, sndHnd)` — comment `80 - for 3D sound, 8000 for
  isometric sound`; commented alternative `SetSndSoundRadiuses(10, 60, sndHnd)`;
  `SetSndSoundPlaying(True)`.
- `sound.script:432-500` `_sound_EmitterFadeSound(...)`: adds `SetSndSoundRandomOffset
  (0)`, `SetSndSoundMaxRadius(0)`, `SetSndSoundLoop(bloop)` and
  `SetSndSoundFadePlaying(fadein, fadetime)`.
- `sound.script:502-528` `_sound_PlaySound(libind,sndlibind)` (non-positional):
  owner is `GetSoundManagerListenerHandle`, radius 8000, maxRadius 0.
- `.snd` schema (all three files): `DefSoundGroup, DefPriority, DefVolume,
  DefMinDistance=1, DefMaxDistance=100, DefInsideConeAngle=360,
  DefOutsideConeAngle=360, DefConeOutsideVolume, DefNbLoops=1, DefFrequency,
  DefRandomOffset=0, DefKillSndOutOfRad=False, VolumeGroup`.
  `units.snd` defaults `DefPriority=100`, `VolumeGroup=svgSFX`;
  musket overrides `DefPriority=1000`, arrows `DefVolume=0.15`;
  `interface.snd` `DefPriority=10000`, `VolumeGroup=svgInterface`;
  `ambient.snd` `DefPriority=100000` (music) / `90000` (amb_atmosphere),
  `VolumeGroup=svgMusic`/`svgAmbient`.
- `TOSWSoundSource` RTTI field names (`0x514164..0x5143aa`) match every one of
  those script setters — this is why the schema is PROVEN, not guessed.

## 6. Reconstructed logic — donor skirmish audio pipeline

```
weapon fires (weapon.script:1147-1148)
  -> _sound_RequestPlaySound(units, gWeapons[weaponid].sndind, px, pz)
  -> _misc_PosToSoundGridIndices: cell = Floor((pos + MapSize/2)/gc_soundgrid_size)
  -> gSoundGrid[cell].sndrequests[sndlibind]++  (one counter per sound index)
  -> per progress tick, _gui_DoProgressSoundControl (gui.script:2930-3210):
       listener placed at screen-centre-derived world point
       combine: for each cell with requests, for each sound index:
         if dst > 40 + listenerHeight + loudness*1.25 -> discard
         else merge into strongest neighbouring cell within +/-4 cells
       play: cell centre -> GetOrCreateSoundEmitterInPos -> soundemitter game object
         group substitution: musket count 3-5 -> groupsmall, 6-9 -> groupmedium,
                             10-100 -> grouplarge (clips absent from ship)
         _sound_EmitterPlaySound(emitterHnd, units, sndlibind, false)
           -> random free clip -> SndGetOrCreateSound(tag,'units',emitterHnd)
           -> SetSndSoundRadiuses(0, loudness*1.25, hnd)   [gui.script:2992-2993]
           -> SetSndSoundPlaying(True)
       reset all cells' bsndrequestexist
```
`gc_soundgrid_size`, `gc_soundgrid_countx/county` are engine constants with **no
definition in donor text** — **UNVERIFIED** numeric cell size. `loudness*1.25`
for `cLoudSmall=20/Medium=40/Large=60/Huge=80` yields 25/50/75/100 outer radii
(PROVEN arithmetic, INFERENCE that they are metres).

## 7. Port implications — donor-grounded `variant3d` recipe

### 7.1 PROVEN values the port can consume today (numbers only, no donor art)

1. **FX lifetime/alpha from exact key fields.** Replace hardcoded
   `LIFE.shot/smoke/explode` with values derived from donor fields:
   smoke `AlphaTime=1.5, AlphaPower=1.5`; flash hide-on-end (no fade);
   cannonexp `AlphaTime=1.2, AlphaPower=1.0`; explosion smoke `AlphaTime=2.0`;
   trails `TimeLimit=0.2, Alpha=0.2, AlphaFade=True`. Keep the 2D lifetimes
   unchanged until an A/B decision (AUDIT3D-06 §7.5).
2. **Trail width/colour.** `MarkWidth=0.1` and `Diffuse=(1,1,1,1)` are PROVEN;
   `TRAIL_STREAK_M=1.2` remains a port value. Better: replace the single
   `BoxMesh` with a camera-facing quad strip (`msFaceCamera` equivalent) — donor
   manager is `pfxTrail` with `ZWrite/ZTest=False`, not a solid box.
3. **Add the missing impact FX kinds** `impactdust`/`impactsmoke` using PROVEN
   PixelRatio 100/50 and AlphaTime 2.0/2.0; they map to existing `hit` events
   (`main.gd:1643-1645`) that currently play audio only.
4. **Composition, not singleton.** For `shot`, compose smoke + flash + sparks
   layers (donor has 5) with per-layer randomisation proportional to donor
   `randpixelratio ±25%`, `randposition.y ±0.1` (`fx.tree:13-23`); scale/count
   factors are PROVEN there, absolute visual sizes are still UNVERIFIED.
5. **Positional audio radius.** If implementing `AudioStreamPlayer3D`, use donor's
   per-event outer radius `loudness*1.25` → 25/50/75/100 m for
   small/medium/large/huge, with `max_volume_radius=0` equivalent (full volume
   near source) and `DefMinDistance=1`. This *replaces* the port's inert 20-60 m
   `get_camera_2d()` cutoff with donor-grounded numbers.
6. **Ambient bed ranges.** `amb_wind` (-5..100, vol 0.2) and `amb_towneur`
   (-1000..1000, vol 1) are PROVEN from `doambientsound.inc`; the port's
   windmill/town/sea proximity logic can be parameterised from these instead of
   the Camera2D/16 fudge.
7. **Grouping rule.** Implement per-cell request counting and 3-5/6-9/10-100
   substitution thresholds *as data*, but note the group clips are absent — so
   the faithful behaviour is "one clip per cell per sound index", which is what
   the port already approximates.

### 7.2 APPROXIMATIONS (must be labelled as such in code/docs)

- `AudioStreamPlayer3D`/`AudioListener3D` are a Godot analogue of the donor's
  software emitter/listener model, not a donor copy; donor mixes in software and
  outputs PCM via waveOut. Panning curve and cone/reverb behaviour are
  **UNVERIFIED** (no donor DSP code recovered).
- Sprite sheet → cross-planes / sphere primitives remains an approximation:
  donor art is private-use and was not copied.
- `PixelRatio` → world size conversion is **UNVERIFIED**; do not divide by a
  guessed constant without evidence.

## 8. UNVERIFIED / BLOCKED

- No consumer function recovered for any `Snd*` or PFX script-name literal
  (0 static refs, 0 found functions at `0x6ba04a`, `0x6ba5ca`). PFX key→engine
  binding is proven only at the *data* level (`fx.tree`, `manager.lib`, scripts).
- `PixelRatio`, `Interval`, `FrameRate`, `AlphaTime`, `AlphaPower`, `TimeLimit`
  units (pixels? seconds? engine ticks?) and their conversion to metres/seconds.
- `gc_soundgrid_size`, `gc_soundgrid_countx/county`, `gc_soundlibrary_*_maxcount`
  numeric values (engine built-ins, not in donor text).
- Whether donor actually pans stereo in isometric mode: `SetSndSoundRadius(8000)`
  suggests attenuation is effectively disabled; `80` is documented as the 3D
  alternative but is not used in the shipped skirmish calls (PROVEN call sites).
- Behaviour when a `musketgroup*` substitution has no matching clip (assets
  absent); likely silent fallback, not proven.
- `howitzerexpground/howitzerexpbuilding/framexp` and several `fx.tree` children
  rely on `{refkey}` inheritance; their explicit key lists were not expanded.
- Visual semantics of `distexpflare`, `distexpring`, `standingsmoke`, `*point`
  variants beyond name + composition membership.

## 9. Next atomic tasks

1. Expand all `{refkey=.effectlibrary[N]}` inheritances in `fx.tree` to a full
   effect→keys table with exact line numbers (mechanical, read-only).
2. Search `.prop`/`.aix` files for PFX manager definitions that override
   `LifeTime`/`InnerColor`/`OuterColor` for fire and explosion kinds.
3. Page `native_function_callees_list` for the function containing
   `0x512fcc` (WAVEFORMATEX constant) to confirm sample rate/channels from bytes.
4. Cross-check the 327 `.snd` paths against the 325 on-disk oggs to identify the
   exact 2 missing/duplicate names.
5. Decide (owner) whether `variant3d` should adopt donor outer radii 25/50/75/100
   and per-cell aggregation, or only the radius values, before any code change.

## 10. Verdict

The donor FX/audio semantics are far more recoverable than the earlier audit
assumed: the engine ships full RTTI-prototyped PFX and sound APIs, the exact
per-key PFX schemas/defaults are in readable text, and the skirmish audio path is
a documented grid-and-emitter aggregation system with concrete radius constants.
What remains genuinely unverified is the *unit conversion* and the *DSP curve*,
not the existence or shape of the semantics. No donor parity is claimed; the
recipe above separates PROVEN numbers from approximations.
