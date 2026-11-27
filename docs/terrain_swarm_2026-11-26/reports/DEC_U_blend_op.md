---
id: DEC-U-BLEND-OP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-BLEND-OP — native animation blend operator decomp (ACL/TAnimation player, min/maxFrameBlend consumers, acm/aamPlayOnce handlers, showdebuganimations.inc)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_op.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk this pass; sha256 prefix 87f0f3c130b0 carried from DEC_U_aaf_art_audit, not recomputed here). Data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin cited, binary not executed; passes below are text/directory reads."
port_scope: "variant3d/scripts/anim3d.gd (read-only line citations). world3d_entities.gd cited read-only only where it owns the caller; NOT edited, NOT re-specified."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md (minFrameBlend=6/maxFrameBlend=8 literals, install/consume sites, deliberate 0,0 bypasses; [U]-B left open)
  - docs/terrain_swarm_2026-11-26/reports/IMPL_U_aaf_triggers.md (intent-only requested_blend/blend_bypass + resolver; no interpolation)
---

# DEC-U — native animation blend operator: weight curve, frame selection, `0,0` bypass

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor file line / port line. `[D]` = arithmetic over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`.
> `ev_B*` ids below are per-pass observation ids for THIS worker, not binary-decomp ids; the evidence is the cited donor `path:line` verified by a second read pass where noted. "Address" = `path:line` (scripts/ACL/AAF are text; no binary addresses are read or cited).
> Context carried: `DEC_U_aaf_triggers.md` recovered the `6/8` literals, install/consume sites and deliberate `0,0` bypasses but left [U]-B open (the engine operator interpolating between exported frames); port `anim3d.gd` carries intent-only `requested_blend`/`blend_bypass` with no interpolation; `IMPL-AAF-TRIGGERS` implemented the resolver.

## 0. Method, labels, passes

### 0.1 Pass ledger (multiple passes; strange-read log inline)

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `Get-Item D:..\cossacks.exe`; `Get-ChildItem D:animations\acl`; AAF dir count | ev_B1: exe `5,768,048` B, pin prefix carried [O]; 100+ `.acl` files; AAF dir enumerated (194-file census carried from DANIM_01, not recounted here) |
| P2 | `Select-String` `FrameBlend\|DeferredFrameBlend\|ResetFrameAnimationBlend` over `D:scripts/**` | ev_B2: 30 hits incl. third `nothing.inc` literal site (`6/8` + walk cascade), `env.inc`/`ballon`/`movearrow` `DeferredFrameBlend(false)`, building `Reset` sites — full table §1.3 [O] |
| P3 | `Select-String` `SwitchToTreeAnimation\|AnimationCyclesMode\|acmPlayOnce\|aamPlayOnce\|acmLoop\|aamLoop\|acmNone\|aamNone` over `D:scripts/**` | ev_B3: complete consumer/mode map incl. `ontagstates.inc:500` `(True,True,…,0,0)` arg polarity vs `unit.script` all-`False` a3, `movie.script:646` `(0,maxblend)`, ballon `acmPlayOnce`, movearrow `aamPlayOnce`, building `aamLoop/None/PlayOnce` [O] |
| P4 | Indexed reads `unit.script:10830-10904,10955-11104` (selector + DoDeath + death) | ev_B4: 8-arg call signature positional map (`anim, a3, bRandomFrame, a5, a6, minB, maxB`); `bSkip` early-out `(False,False,…,0,0)` vs deferred `(False,True,…,min,max)`; death `(False,False,…,min,max)` + artillery post-reset [O] |
| P5 | Indexed reads `ontagstates.inc:335-361,450-520`, `initial.inc:10-22,160-190` | ev_B5: aix mirror with literal `6,8` at `:351` vs `0,0` at `:355`; idle aix `(True,True,…,0,0)` at `:500` [O]; install `6/8 + Deferred(false)` at `:17-19`, default modes `acmLoop/aamLoop` at `:173-174`, commented min/max at `:182-184`, `SwitchToTreeAnimationCycles(idle,…)` at `:190` [O] |
| P6 | Indexed reads `movie.script:575-660,850-860`; `nothing.inc` full head | ev_B6: `_movie_UnitPlayAnimation` operator (`0,0` reset pair → `(0,maxblend)` with `maxblend=5` iff bBlend; `bRandomFrame=(not bOnce) and StrExists(anim,idle)`; `acmode` map; `ManagePeasantAttach`) [O]; exclusive `(ef-sf)/30` law at `:854-858` vs sim inclusive law (DEC-U ev_P2h) [O]; `nothing.inc` 4-level walk cascade `walk2→walk1→walk0→walk` [O] |
| P7 | Full reads `eventdebuganimations.inc` + `showdebuganimations.inc:45-156` | ev_B7: debug operator ORDER recovered: `SwitchToTreeAnimationCyclesBlend(goHnd,stag,False,bRandomFrame,False,False,0,0)` → `ResetFrameAnimationBlend` → `TrackPointClear` → `SetCyclesMode(acmPlayOnce\|acmLoop)` → `ManagePeasantAttach` → `bRandomFrame:=True` [O]; `bPlayOnce` True = `attack0/1/2,death/death0/1`, False = `walk/walk0,idle/idle0/1/2,attack0/1/2(dup),construct,work*,carry*` [O] |
| P8 | Reads `cannon.acl`, `peasant.acl` spot blocks, `fasthorse.acl:200-220`, `balloon.acl` hits, `refunit.acl`, `acl.lib` head | ev_B8: `acoSmoothAnimation=True` on every sampled block, ZERO `False` in any `*.acl` [O]; all `NumberCycle=1` except `balloon 0` + `fasthorse/hardhorse idle 10+idle_rest 1` [O]; `attack0` = `prepare0`-sandwiched track chain, `workfood` = `items[1].ExecuteStateName=OnAclAnimationReachedWork`, `cannon attack0/attack1` = `Attack…actAnimation(NumberCycle=1)…AttackEnd` brackets [O] |
| P9 | Reads `onaclanimationreachedattack.inc`, `attackend.inc`, `work.inc`, `construct.inc`; `dmscript.global:868-926` | ev_B9: `Attack` body = weapon-index decode + cost/pause + melee-damage OR immediate-PFX/projectile branch [O]; `AttackEnd` body = `_unit_TryAttack` retrigger + `SwitchTo('Nothing')` — C2 handler RECOVERED as re-attack, not an effect bind [O]; `Work/Construct` bodies = resource-hp/build-progress + sound + `SwitchTo('Nothing')` [O]; 59 `gc_anim_*` constants incl. carry/build, NO `gc_anim_reaction` [O] |
| P10 | `Select-String` `GetGameObjectFrameAnimation|GetGameObjectAnimation|SetGameObjectIntervalFactor|AnimationControlerEnabled|OnAclAnimationReached|OnStateEndCyclesReached|OnStateFBEndCyclesReached|OnStateEndFrameReached|MinFrameBlend|MaxFrameBlend` | ev_B10: frame-name vs cycle-name API split (`GetGameObjectFrameAnimationName` = current AAF token vs `GetGameObjectAnimationCycleName` = ACL cycle); `intervalfactor` consumers (walk `walkintervalfactor`, death `0.7+random*0.6`, movie reset `1`, building construct `4`); `OnStateEndCyclesReached('')` cleared at `unit.script:10812-10813`, `ontagstates:180-181`, `initial:163`; `EndFrameReached('')` at `initial:14/env:11` [O] |
| P11 | Port reads `P:scripts/anim3d.gd:326-330,685-700,732,780,848-884,1224-1230,1477` + `world3d_entities.gd` blend/action grep | ev_B11: port `requested_blend` default `DONOR_BLEND_MINMAX`, `blend_bypass=(requested_blend==DONOR_BLEND_NONE)`, `_nearest_exported_frame` ascending-tie-lower, `_frame_at` once-clamp vs `fposmod` loop, NO lerp/mix/slerp anywhere on the pose path [O] |

**Strange-read log:** `Select-String -Path <dir>` refuses directories (retry: `-Recurse -File` + `-Include`); `Get-Content | Select-Object -Index` lists are 0-based display vs 1-based editor lines (retry: always re-anchor by neighbouring unique text, never by bare number); `python3` absent in this shell (retry: `Get-Content`/`Select-String` only); wrapped `[*] = ;` prefixes are donor-script line continuations, not separate statements. No donor binary executed; no donor bytes copied. Pin prefix carried, not re-hashed.

---

## 1. The native operator as recovered (read-only)

### 1.1 Call signature (positional, from all call sites) [O] — ev_B4/B5/B6/B7

```
GameObjectSwitchToTreeAnimationCyclesBlendByHandle(hnd, anim, a3, bRandomFrame, a5, a6, minBlend, maxBlend)
GameObjectMySwitchToTreeAnimationCyclesBlend(      anim, a3, bRandomFrame, a5, a6, minBlend, maxBlend)   # aix spelling
```

| Arg | Observed values [O] | Donor cites |
|---|---|---|
| `anim` | AAF token (`gc_anim_*`), or `''` (reset pulse) | `unit.script:10891,10970,11016,11042,11055,11100`; `movie.script:636-637,646`; `ontagstates:351,355,474,500,513,596` |
| `a3` | `False` everywhere in `unit.script` + movie + debug; **`True` ONLY at `ontagstates.inc:500`** (aix idle `0,0` re-switch) | ev_B5; polarity meaning UNREADABLE — [U]-B3 §6 |
| `bRandomFrame` | `False` on early-out/attack/death (`:10891`, `:11100`, debug first unit), `True` on turn/idle-resolve/walk (`:10970,:11016,:11055`, `nothing.inc:61`); movie computes `bRandomFrame=(not bOnce) and StrExists(anim,idle)` (`:643`); debug chains `bRandomFrame:=True` AFTER first unit (`eventdebuganimations.inc`) | ev_B4/B6/B7 |
| `a5, a6` | `False, False` at every observed site (no `True` found in any pass) | ev_B2/B3 (zero-hit for `True, True` in that tail position) |
| `minBlend, maxBlend` | `(6,8)` deferred OR `(0,0)` bypass OR `(0,5)` movie-blend (see §1.3) | §1.3 table |

### 1.2 Mode handlers (`acm*`/`aam*`) [O] — ev_B3/B4/B5/B6/B7/B10

| Mode write [O] | Site | Meaning in situ |
|---|---|---|
| install `acmLoop + aamLoop` | `initial.inc:173-174` (unit birth default) | every unit starts looping |
| install `Min(6)/Max(8)/Deferred(false)` | `initial.inc:17-19`; commented twin `:182-184` | per-handle blend install; deferred explicitly OFF |
| install `MySwitchToTreeAnimationCycles(idle,…)` + random `SetCurrentFrame(Start+floor(Random*(End-Start)))` | `initial.inc:190-191` | birth pose = idle at a RANDOM frame — the only donor-randomised frame init found |
| `acmPlayOnce + aamPlayOnce` | `unit.script:10808-10809` (`DoDeath`), `movie.script:650-656` map (`bOnce→acmPlayOnce`) | death path + movie once path |
| `acmPlayOnce` (cycles only) | `unit.script:10852` (`visual_stage_0`), `ontagstates:175,345`, ballon `initial:14/ontag:77,83` | scaffold / balloon-transform stages |
| `acmLoop` | `unit.script:10854` (non-stage_0), `ontagstates:280,347`, movie `:653` | live default |
| `acmNone + aamNone` | `unit.script:11079-11080` (hide), `ontagstates:558-559`, movie `:655` else-branch | inside mine/transport: no cycles, no frame advance |
| `aamLoop` | `player.script:2969`, building `initial:241/ontag:105` (buiHnd) | building/prop loop |
| `aamNone → aamPlayOnce` | building `ontag:218-233` (construction stages) | building scaffold sequencing |
| clears `OnStateEndCyclesReached('')` + `OnStateFBEndCyclesReached('')` (+ `StartCycles/Direction/EndPoint/Collecting` in DoDeath) | `unit.script:10811-10815`, `ontagstates:180-181`, `initial:163`, `env:22-23` | NO armed end-of-cycles script handler on the unit path — completion is ACL-driven (§1.4) |
| clears `OnStateEndFrameReached('')` | `initial:14`, `env:11`, `env initialdecor:6`, `movearrow:17` sets it once (`'OnEndFrameReached'`, the only non-empty frame-handler write found) | same: no per-frame script consumer on units |

### 1.3 `min/maxFrameBlend` consumers + `0,0` bypasses [O] — ev_B2/B4/B5/B6/B7

| # | Site (address) | Call | Provenance |
|---|---|---|---|
| M1 | `unit.script:10846-10847` | `var minFrameBlend: Integer = 6; var maxFrameBlend: Integer = 8;` locals in `_unit_ForceStateTag` | literal definition (per-evaluation) |
| M2 | `unit.inc/initial.inc:17-19` | `Set…Min…(6) / Max…(8) / Deferred…(false)` | install |
| C1 | `unit.script:10970` | `Switch(…,anim, False,True,False,False, min,max)` — turn/track resolve | deferred blend |
| C2 | `unit.script:11016` | same shape — turn fail→idle | deferred blend |
| C3 | `unit.script:11055` | same shape — walk | deferred blend |
| C4 | `unit.script:11100` | `Switch(…,anim, False,False,False,False, min,max)` then `:11102 Reset` (artillery only) — death | deferred blend (bRandomFrame False: death must start at first frame) |
| C5/C6 | `ontagstates.inc:474,513` | aix `Switch(…,anim, False,True,False,False, min,max)` — turn-resolve / walk | deferred blend mirrors |
| C7 | `ontagstates.inc:596` | aix `Switch(…,anim, False,False,False,False, min,max)` + `:599` interval desync — death | death mirror |
| C8 | `progress.inc/nothing.inc:8-9,61` | own `6/8` locals + `Switch(…,anim, False,True,False,False, min,max)` + `walkintervalfactor` — path-walk | THIRD literal site (progress engine, not sim tag engine) |
| C9 | `ontagstates.inc:351` | literal `Switch(anim, False,False,False,False, 6, 8)` — early-out `bBlend=True` branch | literal (no locals) deferred |
| V1 | `unit.script:10891-10893` | `Switch(…,anim, False,False,False,False, 0,0)` + `Reset` — `bSkip` early-out, `// 0, 0 - dont use blend cause it kills animation` | **deliberate bypass, donor-proven** |
| V2 | `unit.script:11041-11042` | `Reset` + `Switch(…,anim, False,True,False,False, 0,0)` — idle re-entry, `// 0, 0 - to reset blend. needed to prevent 2 shooting animation effect` | **deliberate bypass, donor-proven** |
| V3 | `ontagstates.inc:355-357` | `Switch(anim, False,False,False,False, 0,0)` + `Reset // force playing…` — early-out mirror | bypass mirror |
| V4 | `ontagstates.inc:500` | `Switch(anim, True,True,False,False, 0,0)` — idle re-entry mirror (note `True,True` head) | bypass mirror, arg polarity [U]-B3 |
| V5 | `movie.script:636-637` + `:639` | `Switch(hnd,'',False,True,False,False,0,0)` + `Switch(hnd,idle,…,0,0)` + `Reset` — movie reset pulse | reset pulse: empty-token switch |
| V6 | `movie.script:586,1022,1076` | `Switch(…,idle, False,True,False,False, 0,0)` — revive/rebuild idle | same anti-double-shoot comment |
| V7 | `eventdebuganimations.inc` (debug button) | `Switch(goHnd,stag,False,bRandomFrame,False,False,0,0)` → `Reset` → `TrackPointClear` → `SetCyclesMode` → `ManagePeasantAttach`, then `bRandomFrame:=True` | **debug path is ALWAYS `0,0`** — the debug pose is a no-blend reference by construction |
| M3 | `movie.script:644-646` | `maxblend := 5` iff `bBlend`, else `0`; `Switch(hnd,anim,False,bRandomFrame,False,False, 0,maxblend)` | the ONLY non-`8`/non-`0` max observed: movie blend window is `0..5`, NOT `6..8` |

### 1.4 ACL/TAnimation tree player (what `SwitchToTree…` executes) [O] — ev_B8/B9

- **Registry:** `acl.lib` maps `sid → .acl file` (`Name`/`FileName` pairs, ev_B8); `refunit.acl` supplies `.default/.idle/.walk` templates every block inherits (`TrackPoint…/acoSmooth…/items[0].AnimationName`, ev_B8).
- **Block shape:** `{Name, From, CyclesList=False, Options{acoSmoothAnimation,acoRandomFrame,acoRandomCycle,acoSkipActions}, global{actTrackPoint…}, items[…]}`.
- **`acoSmoothAnimation=True` on EVERY sampled block; ZERO `False` in any `D:animations/acl/*.acl`** (ev_B8; `Select-String` zero-hit). It is therefore a constant authoring flag, NOT a per-call blend switch — the per-call switch is the `(min,max)` pair in §1.3. Its engine effect is UNREADABLE ([U]-B1).
- **`actAnimation{AnimationName, NumberCycle}` chain:** `NumberCycle=1` everywhere sampled except `balloon.acl:48,78` (`NumberCycle=0`) and `fasthorse/hardhorse.acl:210` (`idle NumberCycle=10` then `idle_rest NumberCycle=1`) (ev_B8). Infantry/cannon/peasant combat blocks are single-`actAnimation NumberCycle=1` items.
- **Sequencing is ACL-authored, not script-authored:** `attack0` (`peasant.acl:315-349`, `From=idle`) = `actTrackPoint / actAnimation{prepare0,1} / actTrackPoint`; `cannon.acl attack0/attack1` = `actExecuteState{OnAclAnimationReachedAttack} / actAnimation{attack*,NumberCycle=1} / actExecuteState{OnAclAnimationReachedAttackEnd}`; `workfood/workwood/workstone` (`peasant.acl:2142-2167`) = `items[0].AnimationName=work*` + `items[1].ExecuteStateName=OnAclAnimationReachedWork`.
- **Attack-end handler RECOVERED (refines DEC-U [U]-C2):** `onaclanimationreachedattackend.inc:2-14` = if not dead: `_unit_TryAttack(…trg…,True)` (guard order → same target, else target `0`) then `SwitchTo('Nothing')` [O] (ev_B9). The end of `NumberCycle=1` RE-ENTERS the attack decision — it is a re-attack gate, not a pose event. Damage/PFX/sound ride on the OPENING handler (`Attack`, ev_B9: weapon-index decode → cost/pause → melee `_misc_DoDamage` + sabre/pike sound, or immediate-propagation PFX/projectile, or aimed `_weapon_DoProjectile` with miss→`attackdelay` penalty).
- **`Work/Construct` handlers recovered:** `…work.inc` = resource-hp decrement + `resamount+1` + work sounds; `…construct.inc` = `buildprogress+delta` + hp + construct sound; both end `SwitchTo('Nothing')` [O] (ev_B9).

### 1.5 Frame clock + speed (what the script layer owns; the blend layer does NOT) [O] — ev_B6/B10

- **Length laws (both donor-authored, distinct):** sim `frames := 1+ef-sf; (frames/30)` (`unit.script:10774-10777`) vs movie `((ef-sf)/30)` (`movie.script:854-858`) [O]. Port `_frame_at` uses the INCLUSIVE span (sim side) — correct side chosen.
- **Speed:** `SetGameObjectIntervalFactorByHandle`: walk `walkintervalfactor` (`unit.script:11173`, `nothing.inc:66`, aix `:939` region), death `0.7+random*0.6` (`unit.script:11103`, aix `:599`), movie reset `1` (`movie.script:638`), building construct `4` (building `ontag:221,234`) [O].
- **Existence gate:** `_unit_IsAnimationExists` = `(anim='') or GetGameObjectFrameAnimationDataByHandle(…sf,ef)` (`unit.script:369-373`) [O]; `nothing.inc:27-31` adds a 4-level walk cascade `walk2→walk1→walk0→walk` (donor-stricter than the sim's single-step `walk1→walk` at `:11048-11051`) [O].
- **Name APIs are split:** `GetGameObjectFrameAnimationName(ByHandle)` = current AAF token (readback switch at `:10977,:11026`, guards `:11039,:11052`) vs `GetGameObjectAnimationCycleName` = ACL cycle (`unit.script:6103,6112,9537`, `nothing:59`) [O]. The port needs only the frame-name side.

---

## 2. Weight curve: NOT recovered [U]-B1

**Verdict: no interpolation weight formula exists in any readable donor text.** Searched: all `D:scripts/**` (`*.script`, `*.inc`) for `Blend|Smooth|Weight|Lerp|Mix|Slerp|Interpolat` — every hit is a call site, install, reset, or the constant `acoSmoothAnimation=True` flag; zero arithmetic combining two poses (ev_B2/B3/B10). The `.acl` files carry no per-frame weights (structure §1.4: only `AnimationName + NumberCycle + TrackPoint + ExecuteState` items). The `.aaf` rows carry only `(first,last,morph)` (DEC-U ev_P1). **`acoSmoothAnimation=True`-everywhere + `(min,max)`-per-call is the complete readable blend description; the curve (linear/smoothstep/hermite, per-bone vs per-vertex, easing, normalisation) is engine-side and UNVERIFIED.**

What IS excluded by reads [D]: the curve is not per-AAF data, not per-sid data (single `6/8` pair for all units), not always applied (seven `0,0` bypass sites V1-V7), and not the movie curve (`0..5`, M3). The install declares `DeferredFrameBlend(false)` (M2), so whatever the curve is, it is evaluated EAGERLY at switch time — but eager evaluation of WHAT function is still unknown.

- **[U]-B1 (weight curve).** Missing: `w(t)` over the blend window, window unit (frames? ticks? seconds?), per-channel application. **Capture R-B1 §6** bounds it (step-response length in frames); it can never name the formula, only its observable support. Port must keep performing NO interpolation until R-B1 lands with zero mismatch.

## 3. Frame selection between two nearby exported frames: NOT recovered [U]-B2

**Verdict: no readable text names a two-frame fetch, a blend-from/blend-to frame pair, or a snap-vs-interpolate rule.** The script layer passes ONE `anim` token per switch (§1.1) plus a `(min,max)` window; which exported frames the engine holds during the window, and whether it samples `floor/nearest/both-neighbours`, is never logged, asserted, or branched on in readable code (ev_B2/B3/B10 zero-hits for `GetGameObject…Frame…Blend|CurrentFrame.*Blend|Blend.*Frame` beyond install/consume/reset). Related frame machinery that IS readable (and is NOT the blend): birth random `SetCurrentFrame(Start+floor(Random*(End-Start)))` (`initial.inc:191`), `bRandomFrame` seeding (movie `:643`, debug chain), `GetGameObjectFrameAnimationDataByHandle(sf,ef)` range query, `GetGameObjectStart/EndFrame` bounds [O].

The port's `_nearest_exported_frame` (`anim3d.gd:1224-1230`: ascending scan, tie keeps LOWER frame; out-of-range returns requested unchanged) + `_frame_blend_fields` delta window (`anim3d.gd:870-884`) is therefore a **diagnostic over the deterministic 6-frame shipped subset, not a reproduction of any donor fetch** — correctly labelled `FRAME_BLEND_STATUS [U] U2`. In particular:

- tie-lower, ascending-scan order, and the 6-frame subset stride are PORT choices (converter-side), with no donor counterpart in readable text — must stay labelled as such;
- `sample_frames()` half-to-even rounding (`anim3d.gd:685-700`) reproduces the 2D bake's Python `round()`, not any blend fetch — must not be cited as blend evidence;
- the `delta <= 8` window re-uses the MAX literal as a diagnostic radius; the donor never compares a frame distance to `8` in readable text.

- **[U]-B2 (blend-window frame fetch).** Missing: which frames the engine displays during `(6,8)`/`(0,5)`. **Capture R-B2 §6** (vertex-hash step trace) bounds the observable support. Never invent a second fetched frame.

## 4. `0,0` bypass: RECOVERED [O]

The bypass is the best-understood part of the operator. `0,0` = `minBlend=0, maxBlend=0` in the §1.1 tail position, and at every site it is paired with an explicit `GameObjectResetFrameAnimationBlend` (before and/or after) and a donor comment (V1/V2/V3) [O]:

| Behaviour [O] | Sites | Order |
|---|---|---|
| early-out actions skip the sequencer entirely (`bSkip=True`): `work*/construct/attack*` play EXACTLY as authored | V1 (`unit.script:10891-10893`), V3 (`ontagstates:355-357`), C9-literal (`:351` is the non-bypass twin) | `Switch(0,0)` → `Reset` |
| idle re-entry kills the previous blend (anti-double-shoot) | V2 (`unit.script:11041-11042`), V4 (`ontagstates:500`) | `Reset` → `Switch(0,0)` |
| death (artillery) resets AFTER the blended switch | `unit.script:11100-11102`, aix `:596-598` | `Switch(6,8)` → `Reset` (reset-after, not bypass) |
| movie reset pulse uses the EMPTY token | V5 (`movie.script:636-637`) | `Switch('',0,0)` → `Switch(idle,0,0)` → `interval=1` → `Reset` → `TrackPointClear` |
| debug buttons are always no-blend | V7 (`eventdebuganimations.inc`) | `Switch(0,0)` → `Reset` → `TrackPointClear` → mode → attach (first unit `bRandomFrame` as-authored, rest forced `True`) |

[D] consequence the port already honours: under `0,0` the displayed frame MUST equal the requested clock frame with no snap and no window — `requested_blend="0,0"` + `blend_bypass=true` with `sample_frame == requested_frame` is the only donor-faithful pose. Any nearest-frame snap applied under `0,0` contradicts V1-V7.

---

## 5. Cycle/completion handlers (closes part of DEC-U [U]-C2, bounds the rest)

- **Recovered [O] (ev_B9):** `OnAclAnimationReachedAttackEnd` = re-attack gate (`_unit_TryAttack` + `SwitchTo('Nothing')`). DEC-U R-C2's "effect-to-frame offsets" framing is SUPERSEDED for the END handler: the end handler fires the NEXT attack decision; effects (damage/sound/PFX/projectile) ride on the OPENING `Attack` handler with weapon-index/propagation branches. The remaining unknowns are TIMING (which frame of `NumberCycle=1` each handler fires on) and effect-to-frame offsets — still [U]-C2 §6.
- **Still open [U]-C1:** engine action at last frame under `acmPlayOnce` between tag evaluations. No armed `EndCyclesReached/FBEndCyclesReached/EndFrameReached` handler on the unit path (ev_B10 clears); `DoDeath` blanks all four (`:10811-10815`); death completion is the delayed `DeathStage1` state (`:11085`); attack completion is the ACL `AttackEnd` retrigger above. Whether the last frame HOLDS or the pose freezes mid-blend between evaluations is engine-side — capture R-C1 §6.
- **Still open [U]-B3:** meaning of `a3` (`False` vs aix-idle `True` at `:500`) and `a5/a6` (always `False`), and of `CyclesList=False` vs `acoSkipActions=True/False` variation across blocks. No readable text defines them — capture R-B3 §6 (differential call only, never a guessed semantic).

---

## 6. True gaps [U] — fixed-camera captures with zero-mismatch termination

Every capture: singleplayer skirmish, fixed camera, paused-then-stepped sim, per-tick log of `(sim_tick, selected_anim, AAF first..last, requested_frame, displayed_frame, blend_args(min,max), vertex_hash_or_joint_track)`. **No curve, weight, frame, or semantic is invented — a capture either returns a byte-repeatable trace or the [U] stays open.** "Zero-mismatch" = all trials identical frame-for-frame AND hash-for-hash; ONE differing tick/hash fails the capture.

- **[U]-B1 (blend weight curve). Capture R-B1:** peaukr `walk 1..20 → idle 64..113` seam stepped 1 tick/frame; log screen-space ankle-joint track (or full-pose vertex hash if the runner exposes it) for ticks `[-2,+10]` around the switch under `(6,8)` vs forced `(0,0)` (debug-forced). Vary ONLY the tail pair. **Termination:** step-response length in frames + per-tick displacement table, byte-identical across 3/3 trials under EACH setting, AND `(0,0)` trace == unsmoothed hard cut (single-tick jump, zero intermediate positions); else stays [U]. Success bounds the SUPPORT only — it never names `w(t)`.
- **[U]-B2 (blend-window frame fetch). Capture R-B2:** same seam, but log `GetGameObjectFrameAnimationName` + `GetGameObjectFrameAnimationData(sf,ef)` + displayed frame index per tick (engine-read values, not port clock). **Termination:** displayed-frame sequence byte-identical 3/3 trials, showing exactly which exported frames co-occur during `(6,8)` (e.g. `20,64` hold pattern or intermediate indices with tick numbers); ONE divergent trial fails it. Until then the port fetches exactly ONE nearest frame and labels it.
- **[U]-B3 (arg polarity `a3/a5/a6`, `CyclesList`, `acoSkipActions`). Capture R-B3:** differential run only — replay the SAME attack→idle seam via sim path (`a3=False`, V2) vs aix-idle-shaped call (`a3=True`, V4) if the runner can inject it, else via unit.script-path vs ontagstates-path units; log displayed frames + hashes. **Termination:** identical-or-different verdict with tick table 3/3 trials; NO semantic name is assigned either way (labels stay `a3/a5/a6 UNVERIFIED`).
- **[U]-C1 (PlayOnce end behaviour). Capture R-C1** (carried from DEC-U, tightened): musketeer `attack1 [99,124]` single shot, 30 Hz trace `t0..t0+span+10`; record hold-at-`124` vs snap-to-`idle1 [256,305]` with tick numbers + vertex hash at last 3 ticks; repeat peasant `death [115,149]`. **Termination:** hold-vs-return verdict with tick numbers, zero mismatch 3/3 trials per sid.
- **[U]-C2 (handler timing). Capture R-C2** (reframed by §5): cannon `attack0/attack1 [301,337]` firing; log muzzle-flash PFX frame, damage tick, sound tick RELATIVE to the `Attack` (opening) vs `AttackEnd` handler firing ticks. **Termination:** effect-to-handler-tick offsets, zero mismatch 3/3 trials, or absence logged.
- **[U]-B4 (movie `0..5` window). Capture R-B4:** movie-path unit play (`_movie_UnitPlayAnimation` with `bBlend` true/false) on the same seam; log displayed frames. **Termination:** `maxblend=5` vs `maxblend=0` traces differ-or-identical verdict 3/3 trials. Decides whether the port ever needs a third `requested_blend` value (`"0,5"`); until then `"0,5"` is NOT added (only `"0,0"`/`"6,8"` exist in the port).

## 7. Exact port change list for `anim3d.gd` (file/line; NO code written here)

Each row: port site **[O]**, donor fact **[O]/[D]**, required donor-faithful replacement. **Nothing below is implemented by this worker. No parity is claimed.**

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required replacement (donor-faithful; no new assets) |
|---|---|---|---|
| F1 | `P:scripts/anim3d.gd:870-884` `_frame_blend_fields(requested_frame, sample_frame, requested_blend=DONOR_BLEND_MINMAX)` + `blend_bypass` | `0,0` bypass is donor-proven at V1-V7 (§4): under `0,0` the engine plays the clip exactly as authored | ENFORCE: when `requested_blend == DONOR_BLEND_NONE`, callers MUST pass `sample_frame == requested_frame` (assert/log `blend_bypass_violation` otherwise); document that any snap under `0,0` contradicts `unit.script:10891-10893,11042`. No interpolation added. |
| F2 | `P:scripts/anim3d.gd:1224-1230` `_nearest_exported_frame` (ascending, tie-lower) + `:780` compact-only snap | No donor two-frame fetch exists in readable text ([U]-B2 §3); tie/stride/subset are port choices | LABEL ONLY: extend the doc comment to name tie-lower + ascending scan + 6-frame subset as PORT choices with zero donor counterpart; add `fetch_policy:"nearest_single_no_blend [U]-B2"` to the returned Dictionary. No second frame fetched. |
| F3 | `P:scripts/anim3d.gd:326-330,732` `play()/pose_for()` call `_frame_blend_fields(frame, sample_frame)` with default blend | Call sites carry per-branch blend: early-out/idle-re-entry/debug `0,0`, turn/walk/death `6,8` (§1.3); movie path `0,5` (M3) exists but is NOT wired to units | THREAD the resolver's `blend` (`resolve_donor_action()["blend"]`, IMPL-AAF-TRIGGERS `anim3d.gd:1432-1440`) into the `play()/pose_for()` → `_frame_blend_fields` call as LOGGED INTENT (already supported by the optional 3rd arg + `frame_blend_for_trigger` at `:1468`); NEVER branch pose math on it. Do NOT add `"0,5"` until R-B4 lands. |
| F4 | `P:scripts/anim3d.gd:848-862` `_frame_at` once-clamp vs `fposmod` loop | Once = `attack*/death*` (bPlayOnce True, `showdebuganimations.inc:121-123,129-131`; `acmPlayOnce` `:10808-10809`; `NumberCycle=1` cannon.acl) [O]; completion between evaluations UNVERIFIED ([U]-C1) | KEEP clamp; add `completion:"clamp-at-last [U]-C1, no EndCyclesReached handler armed (unit.script:10811-10815)"` to the probe path (`aaf_completion_probe :1493`); wire NOTHING to the empty hook (`:267`) until R-C1 lands. |
| F5 | `P:scripts/anim3d.gd:175` `DONOR_CYCLE_SITES` + `:179` `AAF_COMPLETION_STATUS` | `AttackEnd` body RECOVERED (ev_B9): `_unit_TryAttack` retrigger + `SwitchTo('Nothing')`; effects ride on opening `Attack` | UPDATE the two status strings: end-handler = "re-attack gate, body recovered (`onaclanimationreachedattackend.inc:2-14`); FIRING TICK unrecovered [U]-C2"; keep clamp stand-in + R-C1/R-C2 gates. String-only change. |
| F6 | `P:scripts/anim3d.gd:160-162` `DONOR_BLEND_SITES` | Third literal site `nothing.inc:8-9,61` + movie `0,5` (M3) + debug always-`0,0` (V7) + install `Deferred(false)` (M2) recovered this pass | EXTEND the string: cite `nothing.inc:8-9,61` (progress walk cascade), `movie.script:644-646` (`0,5`), `eventdebuganimations.inc` (always `0,0` + order), `initial.inc:19` (`Deferred(false)` = eager). String-only change. |
| F7 | `P:scripts/anim3d.gd:685-700` `sample_frames` half-to-even | Half-to-even reproduces the 2D bake (`bake_sprites.sample`), NOT any blend fetch [D] | LABEL ONLY: doc-comment guard — "bake-subset stride, never blend evidence [U]-B2". No math change. |
| F8 | (new, optional) — no current site | `a3=True` only at `ontagstates.inc:500`; `a5/a6` always `False`; `acoSmoothAnimation=True` everywhere; `NumberCycle` exceptions balloon-0 / horse-idle-10 (ev_B8) | ADD a read-only const `DONOR_BLEND_ARGS_STATUS` recording exactly those four observations + `[U]-B3`; reference it from `_frame_blend_fields` doc. No behavioural branch on `a3/a5/a6`. |

Port rows outside this worker's ask (`world3d_entities.gd` caller threading, `data.gd`/`game.gd` orders, building death visuals, `anim_action` producers) are **not restated** to avoid a second source of truth.

Required donor asset manifest (all already on disk; sourced only through the approved converters, **not copied here**): `D:animations/aaf/*.aaf` + `D:animations/acl/*.acl` (`peasant/cannon/fasthorse/hardhorse/balloon` + `acl.lib` + `ref/refunit.acl`) + `D:scripts/lib/unit.script` (`:369-373,:6103-6112,:8346,:9537,:10774-10777,:10801-10826,:10830-11104,:11170-11174,:11809`) + `D:scripts/units/unit.inc/ontagstates.inc` (`:175-181,:263-264,:335-361,:450-520,:558-559,:596-599,:939`) + `D:scripts/units/unit.inc/initial.inc` (`:10-22,:160-191`) + `D:scripts/units/unit.inc/onaclanimationreached{attack,attackend,work,construct}.inc` + `D:scripts/lib/movie.script` (`:575-660,:850-860,:1021-1076`) + `D:scripts/lib/player.script:513,2969` + `D:scripts/units/building.inc/ontagstates.inc:105,215-234` + `D:scripts/progress/progress.inc/nothing.inc` + `D:scripts/dmscript.global:868-926` + `D:gui/menu.inc/showdebuganimations.inc:45-66,113-156` + `D:gui/menu.inc/eventdebuganimations.inc`.

---

## 8. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | 8-arg switch signature positional map; `(6,8)`/`(0,0)`/`(0,5)` consumers; 7 bypass sites with order + donor comments; debug always-`0,0` with full order | [O] ev_B2-B7 (§1.1/§1.3) |
| 2 | `acm/aam` install/mode/clear table; no armed unit-path end handler; birth random frame; `bRandomFrame` rules | [O] ev_B3/B4/B5/B6/B7/B10 (§1.2/§1.5) |
| 3 | ACL tree shape; `acoSmoothAnimation=True` everywhere (zero `False`); `NumberCycle` = 1 except balloon-0 / horse-idle-10; attack brackets; work/construct `ExecuteState` items | [O] ev_B8 (§1.4) |
| 4 | `Attack` body (damage/sound/PFX/projectile branches); `AttackEnd` = re-attack gate + `SwitchTo('Nothing')`; `Work/Construct` bodies | [O] ev_B9 (§1.4/§5) |
| 5 | Inclusive vs exclusive length laws; interval-factor consumers; `''→true` gate; 4-level `nothing.inc` walk cascade; frame-name vs cycle-name API split | [O] ev_B6/B10 (§1.5) |
| 6 | Weight curve `w(t)`: no formula in readable text; not per-AAF/sid; eager (`Deferred(false)`); excluded alternatives | [U]-B1 §2 (absence after P2/P3/P8/P10 zero-hit searches) |
| 7 | Blend-window frame fetch: no two-frame rule in readable text; port nearest-single + tie-lower + subset are port choices | [U]-B2 §3 |
| 8 | `a3/a5/a6`, `CyclesList`, `acoSkipActions` polarity: no readable semantic | [U]-B3 §5 |
| 9 | PlayOnce end-between-evaluations; handler firing ticks / effect offsets; movie `0..5` applicability to units | [U]-C1/C2/B4 §5/§6 |
| 10 | Every [U] has a fixed-camera frame-index/vertex-hash capture with zero-mismatch termination (R-B1/R-B2/R-B3/R-C1/R-C2/R-B4) | [D] §6 |
| 11 | Any port motion/timing/blend equal to donor, any invented curve/frame/semantic, or any runtime PASS | **Denied** — no same-camera donor/port A/B exists; visual UNVERIFIED |

## 9. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0`'s data tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-BLEND-OP.*
