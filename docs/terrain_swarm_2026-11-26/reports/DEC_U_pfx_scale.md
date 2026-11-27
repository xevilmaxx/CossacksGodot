---
id: DEC-U-PFX-SCALE
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-PFX-SCALE — donor 1:1 PFX world-size / frame-time / seed / FreeToPool decomp (U3 follow-up)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_pfx_scale.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line or binary-grep observation; every port statement is a read-only source line. No scale, seed, or TTL is invented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c. Every binary observation below is a read-only grep/byte observation against this pin; the binary was never executed."
port_scope: "variant3d/scripts/world3d_fx.gd (read-only line citations)"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (§2 U3, §3 U7, §6 P3-P4)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md (§2.4, §4 [U]-F/[U]-S, §5 P7)
---

# DEC-U — PFX `PixelRatio` / `Interval` / `FrameRate` → world size + seconds, RNG seed, `FreeToPool` timing

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> Each `[U]` ends in a concrete fixed-camera runtime capture with a zero-mismatch termination criterion. Nothing is closed by a port fallback.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary grep hit / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`. `c3` = `t_87f0f3c130b0`.
- `ev_` ids below are this session's pass-evidence ids (all against the pin; binary never executed; donor text is the cited `path:line` itself).

### 0.1 Pass ledger (multiple passes on the pin; strange-decomp log inline)

| Pass | Operation (read-only) | Evidence | Result |
|---|---|---|---|
| P1 | Pin verify: `certutil -hashfile cossacks.exe SHA256` + length | `ev_pin_sha256` | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, `5,768,048 B` [O] — pin confirmed |
| P2 | Full read `D:pfx/source.pfx:1-2894` (all 44 sections) | `ev_pfx_src_full` | 43 `animatedsprite` sources + `bullettrail/fragtrail/firearrowtrail` trails [O]; every `Interval×FrameRate≈1000` [D] (§1); `musketsmokeup` outer `10/100` overrides animation `20/50` [O] |
| P3 | Full read `D:pfx/fx.tree:1-538` (24 effects) | `ev_pfx_tree_full` | `shotmusket` 5 children + deltas, `buildingsmoke` 4 children `parentrandom=true`, `shottower` 3 children, trail singletons [O] (§3) |
| P4 | Full read `D:scripts/lib/pfx.script:1-415` | `ev_pfx_script_full` | Exact 8-float rule + `FillRand` + `prand` sharing [O]; `Random` ×2 (`:45`,`:203`); 0 `Randomize/RandSeed` in file [O] (§4) |
| P5 | Full read `D:pfx/manager.lib:1-37` + `D:pfx/material.mat:1-542` | `ev_pfx_mgr_mat` | 5 managers (`aspriteblank/aspriteshader29/30/31/trailbullet`, `pfxAnimatedSprite/pfxTrail`, `VisibilityCulling=True`) [O]; sprite→texture bindings incl. `musketsmoke/musketflash/musketsparks/musketsmokeup/musketflashup/grenadeexp/grenadesmoke/cannonexp/cannonexpsmoke/impactsmoke/distexpflare/distexpring/bullettrail→bullettrail.bmp/buildingfire+buildingsmoke→firesmoke.dds/waterblast` [O] (§5) |
| P6 | Read-only binary grep `c3` for `PixelRatio` (5 hits) + `FreeToPool\|OnEndFrameState\|AnimationsCount\|MirrorU` (16 hits) | `ev_bin_pfx_props` | Engine-native behaviour-property tables exist: `PixelRatio/Rotation/MirrorU/MirrorV/Position/Scale/…/FrameRate/…`, `OnFrameState/OnEndFrameState/OnStartFrameState`, `AnimationsCount/CurrentFrame/StartFrame/EndFrame/FrameWidth/FrameHeight/Interval/…/ImageWidth/ImageHeight/…`, `OnEndFrameFree/Hide/Disable/FreeOwner`, `TimeLoop/TimeLoopBackward`, `Alpha*/Lerp*/StartScale/EndScale/BirthTime…` [O] (§1.3). No script-side formula; native consumer confirmed, mapping unrecovered |
| P7 | Read-only binary grep `c3` for `pfx/Random/RandSeed/Randomize/AlphaTime/MarkWidth/TimeLimit` + script grep `Randomize\|RandSeed\|GetOrCreate.*Effect\|FreeToPool` over `D:scripts/lib` | `ev_bin_rng_pool` | 0 `Randomize/RandSeed` string hits in binary-adjacent pass scope here; `Random` import-style only (consistent with DEC_U P1e/P3e: Delphi RTL, not a game string); script side: `FreeToPool` only via `GameObjectDelayExecuteStateByHandle(Result,'FreeToPool',10)` (`gui.script:3038`, commented `3048`) and projectile `GameObjectExecuteStateByHandle(projHnd,'FreeToPool')` (`weapon.script:1004,1015,1025,1030`) + `gEffectLibrary.GetOrCreate('buildingsmoke',…)` call sites (`nothing.inc:78,383`) + `cFXMusket='shotmusket'` selectors (`weapon.script:254,258,859`, `unit.script:778,905,950,1233,1552-1644,2547`) [O] (§4-§6) |
| P8 | Second read of port `P:scripts/world3d_fx.gd` (`:99-430` constants, `:750-860` pool, `:1119-1162` RNG, `:1396-1470` composition, `:1707-1826` visuals, `:2018-2082` update, `:2223-2236` free) | `ev_port_fx_reread` | Port change list anchors in §7 [O] |

**Strange-decomp log (required):** binary grep lines (e.g. `c3:9008/9021`) interleave property-name tables with long native code byte runs (`C…`/`U…` sequences); no function boundary, branch polarity, or `PixelRatio→metres` arithmetic was guessed from those bytes. The tables are cited only as proof the engine natively consumes `PixelRatio/Interval/FrameRate/OnEndFrameState`, not as proof of any conversion formula. No donor executable was run; no bytes copied.

---

## 1. What the donor statically proves about time: `Interval × FrameRate = 1000` [O/D]

### 1.1 The product law (all 44 sections, not two rows)

Every `Animations[*]` block **and** every outer behaviour block in `source.pfx` satisfies `Interval × FrameRate ≈ 1000` (halves/quarters/doubles of the same clock):

| Source key [O] (`source.pfx` lines) | Animation `Interval / FrameRate` | Product [D] | Outer behaviour `Interval / FrameRate` | Product [D] |
|---|---|---|---|---|
| `musketsmoke` `:38-49` + `:51/:53` | `10 / 100` | `1000` | `— / 100` (`PixelRatio=175`) | `10×100=1000` |
| `musketflash` `:111-161` ×4 + `:164/:169` | `100 / 10` | `1000` | `100 / 10` (`PixelRatio=350`) | `1000` |
| `musketsparks` `:197-239` ×4 + `:242/:247` | `20 / 50` | `1000` | `20 / 50` (`PixelRatio=180`) | `1000` |
| `musketsmokeup` `:266-277` + `:279-281` | `20 / 50` | `1000` | **`10 / 100`** (`PixelRatio=600`) | `1000` — outer **overrides** animation rate [O] |
| `musketflashup` `:313-356` ×4 + `:358/:362` | `250 / 4` | `1000` | `250 / 4` (`PixelRatio=800`) | `1000` |
| `cannonsmoke` `:384-393` + `:395/:397` | `10 / 100` | `1000` | `— / 100` (`PixelRatio=120`) | `1000` |
| `cannonflash` `:426-434` + `:436/:441` | `20 / 50` | `1000` | `25 / 40` (`PixelRatio=450`) | `1000` |
| `howitzersmoke` `:546-554` + `:556/:559` | `5 / 200` | `1000` | `5 / 200` (`PixelRatio=160`) | `1000` |
| `mortarsmoke` `:749-760` + `:762/:765` | `5 / 200` | `1000` | `5 / 200` (`PixelRatio=200`) | `1000` |
| `grenadeexp` `:1017-1018` + `:1094/:1099` | `14 / 71.4286` | `≈1000.0004` | `14 / 71.4286` (`PixelRatio=50`) | `≈1000.0004` |
| `cannonexp` `:1327-1328` + `:1404/:1409` | `12 / 83.3333` | `≈999.9996` | `12 / 83.3333` (`PixelRatio=30`) | `≈999.9996` |
| `buildingfirestart` `:1822-1823` + `:1857/:1862` | `14 / 71.4286` | `≈1000.0004` | `14 / 71.4286` (`PixelRatio=110`) | `≈1000.0004` |
| `buildingfire` `:2013-2014` + `:2048/:2053` | `14 / 71.4286` | `≈1000.0004` | `14 / 71.4286` (`PixelRatio=110`, `samLoop`) | `≈1000.0004` |
| `buildingsmoke` `:2110-2111` + `:2145/:2150` | `14 / 71.4286` | `≈1000.0004` | `14 / 71.4286` (`PixelRatio=110`, `samLoop`) | `≈1000.0004` |
| `firearrow` `:2213-2214` + `:2258/:2262` | `250 / 4` | `1000` | `250 / 4` (`PixelRatio=1250`) | `1000` |
| `waterblast` `:2826-2827` + `:2831-2832/:2835` | `16 / 62.5` | `1000` | `16 / 62.5` (`PixelRatio=60`) | `1000` |
| `waterblastsmall` `:2869-2870` + `:2874-2875/:2878` | `8 / 125` | `1000` | `8 / 125` (`PixelRatio=30`, `Scale 0.5³`) | `1000` |

**[D] verdict:** `Interval` is milliseconds per frame and `FrameRate` is frames per second of the **same** clock: `secPerFrame = Interval/1000 = 1/FrameRate`. The DEC_U note "`100/10=10≠100` so no single law holds" is superseded for the **time** axis: the law is not `1000/Interval=FrameRate` failing on `100/10` — it is `Interval×FrameRate=1000` holding on **all** rows including `100×10=1000` (re-read P2; the earlier "counter-example" mis-divided).

### 1.2 Total lifetime is then exactly computable from cited frame counts [D]

`totalSeconds = (EndFrame − StartFrame + 1) × Interval / 1000`, with the end-of-life policy in §6 deciding recycle vs hide vs loop:

- `musketsmoke` `0..127` × `10 ms` = `128 × 0.010` = **1.28 s** to `FreeToPool` (`:41/:46/:60`) [D].
- `musketflash` 4 single-frame animations (`0..0`…`3..3`) × `100 ms` = **0.4 s** to `OnEndFrameHide=True` (`:114/:119/:164/:176`) [D]. Port `IMPACT_FLASH_FRAME_SECONDS=0.1` (`world3d_fx.gd:253`) = `1/FrameRate` [O] is therefore the donor-grounded per-frame step; port `IMPACT_FLASH_PORT_LIFE=0.35` (`:254`) and `LIFE["muzzle_flash"]=0.35` (`:139`) are **not** donor values (0.4 s is) [D].
- `buildingfirestart` `0..127` × `14 ms` = `128 × 0.014` = **1.792 s** to `OnEndFrameFree=True` (`:1817/:1822/:1864`) [D].
- `buildingfire` / `buildingsmoke` same `1.792 s` per loop, but `AnimationMode=samLoop` + `OnEndFrameFree=False` (`:2050/:2055`, `:2147/:2152`) so they **never self-terminate** — and `BirthTime=1.792` (`:2062`, `:2159`) equals exactly one loop [D]. This is the donor's fire→smoke handoff constant, not a guess.
- `distexpring` adds `StartTime=0.1` (`:1714`) + `LerpScale StartScale=0.1→EndScale=10.0` (`:1717-1719`) [O] — a 100× growing ring, not a fixed quad [O].
- `AlphaTime/AlphaPower` are per-key fade-curve parameters, not lifetimes: `musketsmoke 1.5/1.5` (`:61-62`), `cannonexp 1.2/1.0` (`:1414-1415`), `impactsmoke 2.0/2.0` (`:1257-1258`), `buildingfire 0.0/1.0` (`:2057-2058`, no fade), `buildingsmokestart AlphaTime=0` (`:1961`) [O]. The curve function itself (pow shape, time base) is **not** in script/data → [U] U3-c.

### 1.3 What `Interval/FrameRate` do NOT decide [U]

Whether the native `AnimatedSpriteFX` engine steps frames off the script `Interval` clock, the sim 32-fps clock (`gc_frames_to_time=0.03125`, carried from DEC_U P11), or the render clock is **not** in any `.pfx/.tree/.script/.lib` text — the consumer is the native property table (`ev_bin_pfx_props`: `AnimationsInterval/AnimationsFrameRate/AnimationsCurrentFrame/…/OnEndFrameState/…` in `c3`) whose stepping code was not decompiled here. So:

- **[U] U3-time-open:** the native frame-advance rule (does the outer behaviour `FrameRate` override the `Animations[*]` rate as `musketsmokeup` implies? what happens when they disagree? is `Interval` re-read per frame under `randframerate` deltas?).
- Port `LIFE` table (`world3d_fx.gd:126-141`) and `TRAIL_TIME_LIMIT=0.2` (`:160`, literal `TimeLimit=0.2` at `source.pfx:1740` [O]) stay labelled stand-ins until E-U3 lands. `TimeLimit/MinDistance/VertLimit` are **trail** keys (`:1739-1741`) with seconds/metres-looking magnitudes but unverified units — never copied onto sprites.

---

## 2. What the donor statically proves about size: `PixelRatio` is an integer behaviour property, divisor unrecovered [U]

### 2.1 Observed [O]

- `PixelRatio` is declared and randomised exactly like `FrameRate`: `pfx.script:18-24` field decls; `:63-67` `Round(Lerp(start,stop,rand))` added to the behaviour's current `PixelRatio`; `fx.tree` codes `randpixelratio=2/3/4/5` with `randpixelratiostart/stop` deltas (e.g. `shotmusket/musketsmoke 3:-25..+25` `:16-18`; `grenadeexp 4:-10..+10` `:227-229`; `howitzerexpground 0..-10` `:348-349`) [O].
- Concrete bases cover a 42× range: `standingsmoke 15`, `cannonexp/building 30`, `waterblastsmall 30`, `grenadeexp/impactsmoke 50`, `waterblast 60`, `distexpflare/ring 80/50`, `buildingfirestart/buildingfire/buildingsmoke 110`, `buildingsmokestart 138`, `cannonsmoke/howitzersmoke/towersmoke 120/160/120`, `musketsmoke/musketsmokepoint 175`, `musketsparks 180`, `mortarsmoke 200`, `cannonflash/towerflash 450`, `musketsmokeup 600`, `musketflashup 800`, `firearrow 1250` [O] (§1.1 + P2).
- The binary consumes it natively (`ev_bin_pfx_props`: `PixelRatio` adjacent to `Rotation/MirrorU/MirrorV/Position/Scale/Direction/Up/Visible` in the behaviour table; `AnimationsFrameWidth/FrameHeight/ImageWidth/ImageHeight` in the animation table) [O]. No script line converts it to metres.
- Frame geometry is fully cited and needs no capture: `musketsmoke 256×128 @2048² → 8×16=128 frames` (`:42-43/:47-48`); `musketflash 256×128 @512×256 → 2×2=4` (`:115-122`); `musketsparks 170×128 @2048×512 → 12×4=48` (`:193-200`); `firesmoke 128×256 @2048² → 16×8=128` (`:1818-1825`); `bullettrail` is **not** a sprite (no frames; decoded BMP `512×256`, `material.mat:443-444`) [O].

### 2.2 What remains [U] U3-size

- **[U] U3-size-open:** the divisor/multiplier turning integer `PixelRatio` into world units, and whether it involves live camera distance / projection / viewport height (`worldSize = f(PixelRatio, camera)` unknown). Candidate readings (NOT endorsed): pixels-per-metre at a reference distance; screen-pixel height mapped through the projection matrix; shader uniform scale. None appears in text; the `.rsrc` string `0OSWPerlinPFX` (DEC_U P2b) is a noise-shader name, not a scale proof.
- Port sizes `IMPACT_SMOKE_QUAD_M=1.4` (`world3d_fx.gd:236`), `IMPACT_SMOKE_UP_QUAD_M=2.0` (`:237`), `IMPACT_FLASH_QUAD_M=0.7` (`:252`), `TRAIL_WIDTH_M=0.1/STREAK=1.2` (`:162-163`) stay labelled `PORT approximation` until E-U3 — correctly labelled today (`:106`, `:235`, `:253`, `:272`, `:1397-1398`) and not to be "tuned" by eye.

---

## 3. Effect composition [O] (the five `shotmusket` layers the port must spawn together)

`fx.tree:4-62` (`ev_pfx_tree_full`): `shotmusket` = `musketsmoke + musketflash + musketsparks + musketsmokeup + musketflashup` with per-child codes:

- `musketsmoke`: `randmirrorv=1, randframerate=2 (-20..+20), randpixelratio=3 (-25..+25), randposition=3 (y −0.1..+0.1), randscale=4 (stop.y=0.05)` (`:11-23`) [O].
- `musketflash/musketsparks`: `randanimation=1, randmirrorv=2` (`:28-29`, `:34-35`) [O].
- `musketsmokeup`: `randmirroru=1, randframerate=2 (0..50), randpixelratio=3 (0..50)` (`:40-46`) [O].
- `musketflashup`: `randanimation=1, randmirroru=2, randmirrorv=3, randframerate=4 (0..50), randpixelratio=5 (0..50)` (`:51-59`) [O].
- Cavalry/king/drag variants add only `effectoffset` (`shotmusketcav −0.025,−0.175,0.33` `:65-69`; `king −0.01,−0.1,0.375` `:79-83`; `drag` same + `randposition` y −0.05 `:85-98`) [O]; `shotmcannon` adds `0.1,0.25,0.03` (`:199-203`) [O].

Port `DONOR_MUSKET_CHILDREN` (`world3d_fx.gd:304-314`) transcribes these codes faithfully [O]; the missing piece is spawning all five (plus `musketsmokeup/musketflashup` sheets, already derived in `DONOR_FX_SHEETS` `:380-389` [O]) with one shared-or-split `rand[0..7]` per §4 — see E-U3/E-U7.

`buildingsmoke` = 4 children (`buildingfirestart/buildingsmokestart/buildingfire/buildingsmoke`, each `randmirroru=2`, `parentrandom=true`, `:417-442`) [O]; `shottower` = 3 (`towersmoke/towerflash/towersparks`, no `parentrandom`, `:443-473`) [O]; `grenadeexp` = 4 (`grenadeexp/grenadesmoke/distexpflare/distexpring`, `parentrandom=true`, `:215-252`) [O]; trails are singletons (`bullettrail/firearrowtrail/fragtrail`, `:360-396`) [O].

---

## 4. RNG rule [O] + seed source [U] U7

### 4.1 Exact rule [O] (`pfx.script:39-86,200-252`, `ev_pfx_script_full`)

Covered fully by DEC_U §3 and re-verified on the full 415-line read: 8 floats; `ptr=nil → rand[i]:=Random` else `Float(ptr+i*4)`; `ClampInt(code-1,0,7)`; `MirrorU/V = (Round(rand)=1)`; `AnimationIndex = Round(rand×(n-1))` iff `AnimationsCount>1`; `FrameRate/PixelRatio/Position/Scale = Lerp(start,stop,rand)` deltas added to base; `TLibEffects.FillRand: for i:=0 to 7 do fRand[i]:=Random` (`:200-204`); `fParentRandom → {FillRand; prand:=fRand}` in **both** `GetOrCreate` (`:206-229`) and `GetOrCreateOffset` (`:231-252`) [O]. Effect offset added after (`:223-227`, `:248-251`) [O].

### 4.2 Seed [U] U7-seed (no static address)

- `pfx.script` contains 0 `Randomize`/`RandSeed` tokens (P7 grep [O]); the only generator calls are the two parameterless `Random` lines [O]. Delphi parameterless `Random` = float in `[0,1)` — that reading is language semantics [I], not a donor line.
- Whether the sim calls `Randomize`/`RandSeed` elsewhere, and whether PFX shares the sim/m²isc stream (`_misc_RandomizePickedUnitStateMachineInterval`, `_misc_GameObjectRandomize*` at `misc.script:369-642` [O] use a differently-named helper, not `Random` directly), is **not** recovered here. Prior-decomp `Random(256)@0x403a0c / RandomExt-LCG@0x60f64c` (PORT1TO1 §6 U7 plan) was **not** re-observed and is **not** reaffirmed.
- Port keeps `pfx_random_stream=null` → `_pfx_rand8()=[]` → `UNVERIFIED_U7_no_stream` (`world3d_fx.gd:1129-1135,776-785`) [O] — the correct posture until E-U7.

---

## 5. Materials [O] (tints the port already uses correctly)

`material.mat` (`ev_pfx_mgr_mat`): smoke greys `0.3137255 (=80/255)` for `musketsmoke/musketsmokeup/standingsmoke/grenadesmoke/cannonexpsmoke/waterblast` (`:17-19`, `:458-464` etc); flash whites `(1,1,1,1)` for `musketflash/musketsparks/cannonflash/grenadeexp/distexpring` (`:63-81` etc); `impactsmoke 0.157` (`:362-364`); `distexpflare alpha 0.1` (`:403/:411`); `buildingfire 0.7843137/alpha 0.5 + firepalette LUT` (`:450-475`); `buildingsmoke 0.1568627/0.0784313/alpha 0.75 + firesmoke.dds` (`:480-509`); `bullettrail→bullettrail.bmp` (`:443-444`); `waterblast→waterblast.dds bmTransparency` (`:515-516`) [O]. Port `_kind_color` grey `0.3137255` (`world3d_fx.gd:230,1697`) and flash white (`:1700`) match the cited literals [O]; port smoke alpha `0.55` (`:238`) is a port choice (donor diffuse alpha unverified) [O, self-labelled].

---

## 6. `FreeToPool` / hide / loop timing [O rule, U trigger wiring]

### 6.1 Donor policy table [O]

| Policy key in `source.pfx` | Keys carrying it [O] | Meaning in script/native surface [O] |
|---|---|---|
| `OnEndFrameState = FreeToPool` | `musketsmoke/musketsmoketbn (:60/:96)`, `cannonsmoke (:409)`, `howitzersmoke (:571)`, `mortarsmoke (:772)`, `grenadeexp (:1102)`, `impactsmoke (:1255)`, `impactdust (:1296)`, `cannonexp (:1412)`, `cannonexpbuilding (:1575)`, `towersmoke (:2376)`, `musketsmokepoint (:2532)`, `waterblast/waterblastsmall (:2839/:2882)` | Engine end-of-frames state (native table `ev_bin_pfx_props`); script requests pool-delayed free via `GameObjectDelayExecuteStateByHandle(Result,'FreeToPool',10)` (`gui.script:3038` [O]) |
| `OnEndFrameFree = True` (no pool) | `buildingfirestart (:1864)`, `buildingsmokestart (:1959)` | Frees at `1.792 s` [D §1.2]; **not** pooled |
| `OnEndFrameHide = True` | `musketflash (:176)`, `musketsparks (:253)`, `cannonflash (:631)`, `mortarflash (:831)`, `towersparks (:2498)` etc | Holds last frame hidden; port muzzle-flash HOLD (`world3d_fx.gd:2065-2068`) matches this policy [O] |
| `OnEndFrameFree = False` + `samLoop` | `buildingfire (:2048-2055)`, `buildingsmoke (:2145-2152)` | Loops forever until the state machine removes the burning state; `BirthTime=1.792` = one loop [D] |
| `//OnEndFrameFreeOwner` (commented) | `musketsmoke (:59)`, `cannonsmoke (:408)` etc | Disabled owner-free; port must not invent owner-free [O] |

### 6.2 What remains [U] U3-pool

- **[U] U3-pool-open:** (a) native pool identity (per-`LibManagerName` shader pools `aspriteshader29/30/31` in `manager.lib` [O] vs one global pool — `Sorting=assMaterial`, `VisibilityCulling=True` [O] — unknown); (b) pool size/high-water mark; (c) whether `FreeToPool` fires on `CurrentFrame==EndFrame` or `>EndFrame`, and under `randframerate`-shifted rates; (d) who calls the `buildingsmoke` removal when the building leaves the burning state (`nothing.inc:78,383` attaches it [O]; no detach line recovered here).
- Port `use_donor_fx_pool=false` default + `DONOR_FREETOPOOL_KEYS` 14-key gate + `queue_free` elsewhere (`world3d_fx.gd:418-429,2180-2236`) [O] is the correct conservative posture until E-U3-pool.

---

## 7. Exact port change list for `world3d_fx.gd` (file/line; no code written here)

Each row: port site **[O]**, donor fact **[O]/[D]**, required replacement. **No row claims implementation.**

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no invented scale/seed/TTL) |
|---|---|---|---|
| F1 | `world3d_fx.gd:126-141 LIFE` + `:142 DEFAULT_LIFE` + `:143 FALLBACK_FX_CAP` + `:2187-2195 _enforce_cap` | Frame totals + `Interval` ms/frame give exact donor TTLs [D §1.2]: smoke `1.28 s`, flash `0.4 s`, `buildingfirestart 1.792 s`, `waterblastsmall 1.024 s` (`128×8 ms`), `musketflashuppoint 1.0 s` (`4×250 ms`) | After E-U3-time: replace `LIFE` lookups with `ttl=(End-Start+1)×Interval/1000` from `DONOR_FX_LITERAL_KEYS`-grade per-key tables; keep `FALLBACK_FX_CAP` until pool sizes recovered ([U] U3-pool) |
| F2 | `:236-237 IMPACT_SMOKE_QUAD_M 1.4 / UP 2.0`, `:252 FLASH_QUAD_M 0.7`, `:272 IMPACT_TRAIL_STREAK_M`, `:162-163 TRAIL_*_M`, `:1774-1780/:1800-1805/:1820-1822` size use | `PixelRatio` integer bases 15..1250 [O §2.1]; divisor unrecovered [U] | After E-U3-size: `quadSize=f(PixelRatio, camera)`; until then keep labelled PAs, never retune by eye |
| F3 | `:253 IMPACT_FLASH_FRAME_SECONDS 0.1` + `:139 LIFE["muzzle_flash"] 0.35` + `:254 PORT_LIFE 0.35` + `:2065-2068` flash HOLD | Flash = 4×`100 ms` = `0.4 s` [D §1.2]; `OnEndFrameHide=True` (`source.pfx:176`) [O] | Set flash TTL to `0.4 s` after E-U3-time; `0.1 s` step is already donor-grounded (`1/FrameRate`) — keep. HOLD stays (matches `OnEndFrameHide`) |
| F4 | `:2048-2053 volley_smoke drift/fade`, `:2060-2064 AlphaPower`, `:2058 pow(1-k,…)` | `AlphaTime/AlphaPower` per-key [O §1.2]; curve base unrecovered [U] | After E-U3-curve: apply cited per-key `AlphaTime/Power` over the donor TTL; until then keep labelled curve |
| F5 | `:1119-1162` RNG (`_pfx_rand8/_pfx_code/_pfx_mirror/_pfx_animation_index/_pfx_lerp`) + `:441-444 pfx_random_stream=null` | Exact 8-float rule [O §4.1]; seed unrecovered [U] | Inject stream only after E-U7 identifies `Randomize/RandSeed` + isolation; keep `UNVERIFIED_U7_no_stream` default |
| F6 | `:834-858 add_impact_fx` + `:1446-1469 _add_donor_composition` + `:304-314 DONOR_MUSKET_CHILDREN` | 5-child `shotmusket` codes + offsets [O §3]; `parentrandom` only on `grenadeexp/expflash/buildingsmoke` [O] | After E-U3/E-U7: spawn all 5 `shotmusket` layers per shot with split `rand8` (one `FillRand` each, `prand=nil`), all 4 `buildingsmoke` layers with one shared `FillRand`; wire `shotmusketcav/king/drag/mcannon/point` offsets (`fx.tree:63-98,197-214,475-504`) |
| F7 | `:2223-2236 _free_item` + `:2200-2212 _pool_acquire` + `:418-429 DONOR_FREETOPOOL_KEYS` + `:445 use_donor_fx_pool=false` | 14-key `FreeToPool` set vs `Free/Hide/Loop` set [O §6.1] | After E-U3-pool: pool per `LibManagerName` if proven, else keep opt-in holder pool; wire `buildingfire/smoke` removal to the burning-state exit (E-U14), never to a port timer |
| F8 | `:260-272` trail constants + `:1813-1825 arrow_trail` + `:2107-2137 _orient_impact_trail` | Trail keys `VertLimit 150 / TimeLimit 0.2 / MinDistance 0.05 / Alpha 0.2/0.3 / MarkWidth 0.1/0.05 / msFaceCamera / ZWrite False / Diffuse` [O] (`source.pfx:1739-1764,1783,2315`) | After E-U3-trail: spawn ribbon vertices at `MinDistance` intervals up to `VertLimit`, expire at `TimeLimit`; keep `0.2/0.1` literals, `ZWrite=False→DEPTH_DRAW_DISABLED` already correct |

Required donor assets (not copied here): `D:pfx/source.pfx` sheets (`musketsmoke/musketflash/musketsparks/musketsmokeup/musketflashup/firesmoke/cannonflash/bullettrail.bmp`), `D:pfx/textures/*`, `D:pfx/material.mat` tints, `D:pfx/fx.tree` 24-effect table, `D:pfx/manager.lib` 5-manager table, `D:animations/aaf/pfx/*.aaf` (52).

---

## 8. Still-[U] values with concrete fixed-camera runtime captures (zero-mismatch criteria; no invented numbers)

- **E-U3-time (frame clock + TTL):** singleplayer skirmish, fixed camera, spawn `shotmusket` once (musketeer `attack0`) with no other FX. Log behaviour `CurrentFrame` + `FrameRate/Interval` reads per frame + effect-visible frames `0..127` + `OnEndFrameState` fire frame. Vary only `Interval` `10→14` (covers `buildingfirestart`) in a second capture. **Terminates [U] U3-time iff** `observedFrames×Interval/1000 == listed TTL` with **0 dropped/repeated frames** across 3 consecutive captures per key AND the `FreeToPool/Hide` fire frame equals `EndFrame` exactly in all 3.
- **E-U3-size (world size):** same scene, fixed camera distance `d0` (record `camera.position/projection/size` + target world pos). Capture `musketsmoke` quad world width at frame 0 for `PixelRatio 175`, then override only `PixelRatio→350` (covers `musketflash`) at the same `d0`, then repeat both at `d1=2×d0`. **Terminates [U] U3-size iff** fitted `worldSize = k×PixelRatio×d` (or whatever form emerges) predicts all 4 captures with **0 px mismatch** at the captured resolution (measure in donor pixels against a surveyed ground ruler, e.g. a 5.25 cm rally mesh or a 1 m tile edge in the same frame).
- **E-U3-curve (alpha):** capture `musketsmoke` pixel alpha over its `1.28 s` at fixed exposure; fit `AlphaTime/Power`. **Terminates iff** the fitted curve reproduces all sampled frames with **0 quantisation-step mismatch** (>1 LSB fails) across 2 captures.
- **E-U3-trail (ribbon):** fire one arrow over flat ground, fixed camera side-on; log ribbon vertex count vs travelled distance + `TimeLimit` expiry. **Terminates iff** `vertexSpacing==MinDistance 0.05` with **0 extra/missing vertices** and expiry frame `== TimeLimit` within **±0 frames** across 3 shots.
- **E-U7-seed:** fixed map seed, trigger `shotmusket` N=50 with no other FX; log the 8 `rand` values per spawn (script hook on `TLibEffect.GetOrCreate`); reload same map/seed, repeat. **Terminates [U] U7 iff** the two 50-spawn sequences are **bit-identical (0 differing floats)** → seeded (then find the `Randomize/RandSeed` caller), or differ in **≥1 float** → time-seeded. No stream is fabricated either way.
- **E-U3-pool (FreeToPool timing + pool size):** spawn 300 `shotmusket` in one frame (fixed camera, skirmish cheat/harness); log live-holder count + reuse vs alloc + `FreeToPool` fire frames. **Terminates iff** peak holders and the free-frame rule are **exactly** reproduced (0-holder, 0-frame mismatch) across 3 runs, including the `buildingfire/smoke` never-free-while-burning case.

Until every applicable capture terminates, the port keeps: `LIFE` table, PA quad sizes, `UNVERIFIED_U7_no_stream`, opt-in pool + cap, and `PORT APPROXIMATION — NOT DONOR PARITY` labels — listed gaps, never behaviour.

---

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `Interval×FrameRate≈1000` on all 44 `source.pfx` sections; `secPerFrame=Interval/1000=1/FrameRate`; TTLs `128×10 ms=1.28 s` (smoke), `4×100 ms=0.4 s` (flash), `128×14 ms=1.792 s` (`buildingfirestart`, == `BirthTime` of the looping fire/smoke) | [O] `source.pfx` lines in §1.1; [D] products/quotients |
| 2 | `musketsmokeup` outer `10/100` overrides animation `20/50` (both product 1000) | [O] `source.pfx:266-281` |
| 3 | `PixelRatio` bases 15..1250 with per-child `randpixelratio` deltas; divisor→metres unrecovered | [O] §2.1; [U] U3-size |
| 4 | 8-float `ClampInt/Round/Lerp` rule + `FillRand` + `prand` sharing in both `GetOrCreate` paths; `Random` ×2, 0 `Randomize/RandSeed` in `pfx.script` | [O] `pfx.script:39-86,200-252`; [U] U7-seed |
| 5 | Engine natively consumes `PixelRatio/FrameRate/Interval/OnEndFrameState/AnimationsCount/…` (property tables in `c3`); stepping code not decompiled | [O] `ev_bin_pfx_props`; [U] U3-time/U3-size |
| 6 | 14-key `FreeToPool` set vs `Free/Hide/Loop` sets; `buildingfire/smoke samLoop + Free=False` loop on `BirthTime=1.792` | [O] §6.1; [U] U3-pool |
| 7 | Port differs at §7 F1–F8; each has a donor-faithful replacement + capture; no row implemented here | [O] port lines + donor facts |
| 8 | Every [U] has a fixed-camera capture with a zero-mismatch criterion; none closed by a port fallback; no scale/seed/TTL invented | [D] §8 |
| 9 | Any port FX visual equals donor motion/size/timing | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 10. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC_U-PFX-SCALE.*
