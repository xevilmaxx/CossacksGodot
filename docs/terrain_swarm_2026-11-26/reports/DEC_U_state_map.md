---
id: DEC-U-STATE-MAP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-STATE-MAP — donor state/order/weapon/carry to AAF token map with ACL completion events"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_state_map.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk this pass, re-observed via Get-Item; sha256 prefix carried from DEC_U_aaf_triggers, not recomputed here). Data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin cited, binary not executed, no bytes copied."
port_scope: "variant3d/scripts/anim3d.gd + variant3d/scripts/world3d_entities.gd (read-only line citations). No edits."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md (T1-T26 rows, loop/once, completion, blend)
  - docs/terrain_swarm_2026-11-26/reports/IMPL_U_aaf_triggers.md (resolve_donor_action wiring, §5 patch recommendation)
---

# DEC-U — donor state map: state/order/weapon/carry to AAF token, loop/clamp, advancing event

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor file line / port line. `[D]` = arithmetic over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`.
> `ev_` ids below are per-pass observation ids, not binary-decomp ids; the evidence is the cited donor `path:line` verified by a second read where noted.
> "Address" = `path:line` (scripts/ACL/AAF are text; no binary addresses are read or cited).

## 0. Method, passes, strange-read log

### 0.1 Pass ledger (multiple passes)

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `Get-Item` donor exe + `Get-ChildItem D:animations/aaf/*.aaf` count + full reads of `peaukr/musketeer/grenadier/cannon/yacht.aaf` | ev_P1a: exe 5,768,048 B `[O]`; ev_P1b: 194 AAF files `[O]`; ev_P1c: peaukr 18 rows `walk 1..20` … `reaction 456..481` all `morph` `[O]`; ev_P1d: musketeer 17 rows `attack1 99..124`, `death0 564..628` `[O]`; ev_P1e: grenadier 30 rows + 1 commented `attack2 630..679` (`attack2 153..154` stub, `attack2before 630..663`, `attack2after 664..679`) `[O]`; ev_P1f: cannon 4 rows (`idle 1..1`, `walk 1..99`, `attack0/attack1 301..337`) `[O]`; ev_P1g: yacht 4 rows all `1..280` `[O]` |
| P2 | Reads of `D:scripts/lib/unit.script:10796-11115` (`_unit_ForceStateTag`, `DoSetupMoveAnimation`, `DoDeath`, death branch) + `:369-373` (`_unit_IsAnimationExists`) + `:6979-7019` (peasant attach) | ev_P2a: T1-T7 early-out `0,0` no-blend branch `:10886-10895` `[O]`; ev_P2b: carry T8-T13 `:10898-10923` `[O]`; ev_P2c: weapon-state T14-T17 `:10927-10957` `[O]`; ev_P2d: turn/idle sticky readback T18-T20 `:10961-11057` `[O]`; ev_P2e: death T21 + artillery `_death` reload + `0.7+random*0.6` desync `:11072-11104` `[O]`; ev_P2f: `DoDeath` clears all four `OnState*Reached` handlers `:10811-10816` + `acmPlayOnce/aamPlayOnce` `:10808-10809` `[O]`; ev_P2g: attach map `:6991-7012` `[O]`; ev_P2h: existence gate `anim=''` → true `:369-373` `[O]` |
| P3 | Reads of `D:scripts/units/unit.inc/ontagstates.inc:295-364` (action early-out mirror) + `:166-204` (`DoDeath` mirror) + `nothing.inc:1-13` (Nothing state) | ev_P3a: aix mirror carries `bBlend` flag + `6,8` vs `0,0` split + `acmPlayOnce` on `visual_stage_0` `:334-363` `[O]`; ev_P3b: engine state `Name = Nothing` (`nothing.inc:2`) with `UsedFileName` empty and movie-block early-out `:7-11` `[O]` |
| P4 | Reads of `unit.aix:130-152` (handler registry) + `onaclanimationreached{attack,attackend,work,construct}.inc` full + `unit.script:8346` (commented attack-end log) | ev_P4a: four handlers registered `OnAclAnimationReached{Attack,Work,Construct,AttackEnd}` (`unit.aix:130,137,143,150`) `[O]`; ev_P4b: Attack handler applies weapon cost/pause/damage/projectile by `weapind 0/1/2` from `statetag and gc_statetag_weapon` (`:15-29`), ends `SwitchTo('Nothing')` (`:152`) `[O]`; ev_P4c: AttackEnd handler re-issues `_unit_TryAttack(trg,True)` unless order is guard/gainres/build (`:9-12`), ends `SwitchTo('Nothing')` (`:15`) `[O]`; ev_P4d: Work handler decrements res HP / `resamount+1` gated on `gainres` order (`:9,15-51`), ends `SwitchTo('Nothing')` (`:59`) `[O]`; ev_P4e: Construct handler adds `buildprogress`/`hp` or repair HP gated on build/repair orders (`:9,23-43`), ends `SwitchTo('Nothing')` (`:51`) `[O]` |
| P5 | Reads of `D:animations/acl/cannon.acl:1-83` + `peasant.acl:2140-2252` + `Select-String ExecuteStateName` over both + 194-file `OnAclAnimationReached*` census | ev_P5a: cannon `attack0/attack1` blocks = `CyclesList=False` + `actExecuteState Attack` + `actAnimation NumberCycle=1` + `actExecuteState AttackEnd` (`:16-46,:48-78`) vs plain single-`AnimationName` `idle/walk/death` blocks (`:1-15,:81-83`) `[O]`; ev_P5b: peasant `workfood/workwood/workstone` blocks carry `items[1].ExecuteStateName=OnAclAnimationReachedWork` (`:2146-2165`) and `construct` carries `...Construct` (`:2252`) `[O]`; ev_P5c: peasant `attack{0,1,2}` blocks carry Attack/AttackEnd brackets (`:1267,:1276,:1531,:1540,:1693,:1702`) `[O]`; ev_P5d: census finds only `...Attack` + `...AttackEnd` families outside peasant (ships/artillery/cavalry/infantry `.acl` files, e.g. `infantrygrenadier.acl:96,105`); `...Work`/`...Construct` only in `peasant.acl`; NO `...Build`/`...Death`/`...Nothing` ExecuteState anywhere `[O]` |
| P6 | Reads of `D:scripts/dmscript.global:868-926` (59 `gc_anim_*` constants) + `D:gui/menu.inc/showdebuganimations.inc` debug-button lists + `P:scripts/anim3d.gd:1424-1508` (`resolve_donor_trigger/action`) + `P:scripts/world3d_entities.gd:1945-2263` (`_unit_action`, `_donor_tag_fields`, `_resolve_donor_action`, fallback/orphan/gap helpers) | ev_P6a: no `gc_anim_reaction` constant; `turn*/turnleft*/turnright*/collide*` vocabulary-only `[O]`; ev_P6b: debug `bPlayOnce=True` for `attack0/1/2`, `death/death0/death1`, `False` for `walk/walk0/idle*/construct/work*/carry*` `[O]`; ev_P6c: port `resolve_donor_action(sid,fields)` = branch order T26→T21→T1-T7→T8-T13→T14-T17→sticky + `has_action(sid,token)` gate, orphans return `""` (`anim3d.gd:1424-1508`) `[O]`; ev_P6d: port `_unit_action` tries `_resolve_donor_action` first, then preserved chain (explicit→construct→carry→attack→walk/idle) with per-sid fallback (`world3d_entities.gd:1945-2045`) `[O]`; ev_P6e: port `_donor_tag_fields` decodes only `dead/order/res/speed/weapon-index` + explicit pass-through, never supplies `current_anim` so sticky stays dormant (`:2115-2153`) `[O]` |
| P7 | Cross-check vs DEC_U_aaf_triggers §1-§7 + IMPL §5 + `acl.lib:1-40` (sid→acl file map) | ev_P7: agreements recorded in §5; `acl.lib` confirms per-sid ACL files (`infantry.acl`, `infantryarcher.acl`, …) `[O]` |

**Strange-read log:** `Select-String -Path <dir>` refuses directories (retry: `Get-ChildItem -Recurse -File | Select-String`); `-Recurse` is not a `Select-String` parameter (retry: `Get-ChildItem -Recurse` piped in); `powershell -NoProfile -Command` must not be nested inside the `shell` tool (retry: bare PS code); `python3` absent on this host (retry: PS `Get-Content`/`Select-String` only). No donor binary executed; no donor bytes copied. `reaction`/`attack2before`/`prepare0` zero-hit searches carried from DEC_U P5 (not re-run here to avoid duplicating that worker's evidence; verdicts confirmed by the P4 handler registry which lists only Attack/Work/Construct/AttackEnd).

---

## 1. ACL/engine state machine (what the readable text actually defines) [O]

### 1.1 Engine states: exactly one unit state is readable — `Nothing`

- `D:scripts/units/unit.inc/nothing.inc:1-4`: `Name = Nothing`, `UsedFileName =` (empty), `Code: args arg_obj: TObj`.
- Its head (`:7-13`) is a dispatcher, not an animation: movie-block forces `idle+action_none` tags and clears `bexecute`; `not bbuilt` exits. The rest (`:15+`) is walk-sound bookkeeping, res-sound typing, progress ticks — no `anim :=` selection lives here.
- **No readable `Work`, `Construct`, `Attack`, or `Build` engine-state definitions exist** in `unit.inc/*.inc` or `unit.aix`. The assignment's state names resolve as follows (honest mapping, nothing invented):
  - `Work` = the ACL completion event `OnAclAnimationReachedWork` (peasant `work*` blocks, ev_P5b) + its handler `onaclanimationreachedwork.inc` (ev_P4d).
  - `Construct` = the ACL completion event `OnAclAnimationReachedConstruct` (peasant `construct` block, ev_P5b) + its handler `onaclanimationreachedconstruct.inc` (ev_P4e).
  - `Attack` = the ACL completion event pair `OnAclAnimationReachedAttack` / `...AttackEnd` (all combat `.acl` blocks, ev_P5a/c/d) + handlers `onaclanimationreachedattack{,end}.inc` (ev_P4b/c).
  - `Build` = NOT an engine/ACL state in readable text. `build` exists only as (a) order type `gc_obj_order_type_build` / `gc_obj_order_type_repair` (checked in the Construct handler `:9`) and (b) action tag `gc_statetag_action_build` → token `construct` (`unit.script:10877`). There is no `OnAclAnimationReachedBuild`, no `Name = Build` state, no `gc_anim_build` constant. Any port `build` → `construct` mapping is therefore the T4 action-tag row, not a Build-state entry — §4 F4 keeps it labelled as such.

### 1.2 Tag decode → the three `anim*` locals (the selector both engines spell) [O]

`unit.script:10832-10857` (script engine) and `ontagstates.inc:227-240` (aix mirror) decode the same seven fields: `iResource/iExecute/iMove/iWeapon/iAction/iEssential/iVisual`. `DoSetupMoveAnimation` (`:10856-11070`, mirror `:295-516`) selects three locals:

1. `anim` — single-shot action clip (T1-T7 early-out, T21 death, or the turn/idle/walk resolution below). When `bSkip=True` it plays immediately with **no blend** (`0,0` + `GameObjectResetFrameAnimationBlend`, `:10891-10893`).
2. `animidle` — sticky idle candidate (carry idles T8/T10/T12, weapon idles T14-T17, `gc_anim_idle` fallback).
3. `animwalk` — sticky walk candidate (carry walks T9/T11/T13, weapon walks T14-T17, `gc_anim_walk` fallback).

The aix mirror adds a `bBlend` flag (`ontagstates.inc:297,317`): action rows set it, then the shared switch plays `6,8` when set else `0,0` (`:350-358`) — same two numbers, same bypass comment ("dont use blend cause it kills animation").

### 1.3 Native ACL transition blocks (From → Name) and what advances them [O]

ACL files are per-sid transition tables (`acl.lib` maps sid stems → files, ev_P7). Each block names `From`, `Name`, and either a bare `items[0].AnimationName` (loop rows) or an `items` chain (once rows):

| Block kind [O] | Shape [O] | Loop/clamp [O] | Advancing event [O] |
|---|---|---|---|
| `idle/walk/death/work*/construct` plain rows (cannon `:1-15,:81-83`; peasant `:2140-2166,:2247-2252`) | single `items[0].AnimationName` + `refunit`/`refspeed` globals | loop (`acmLoop`; debug `bPlayOnce=False`; death rows clamp only via the script `DoDeath acmPlayOnce` overlay, §2) | `work*` → `OnAclAnimationReachedWork` fires at the work point (`peasant.acl:2147,2156,2165`), handler applies res HP/`resamount+1`, then `SwitchTo('Nothing')`; `construct` → `...Construct` fires, handler applies build/repair HP, then `SwitchTo('Nothing')`; `idle/walk/death` have NO `ExecuteState` — advance is the next tag evaluation (`ForceStateTag`/`OnTagStates`) reselecting `anim` |
| `attack0/attack1/(attack2)` rows (cannon `:16-78`; peasant `:1267-1702`; same shape in battleship/chaika/ferry/framegun/frigate/galley/howitzer/infantry*/fasthorse/hardhorse*, ev_P5d) | `CyclesList=False` + `acoSmoothAnimation=True` + `actTrackPoint(mmNone)` + `actExecuteState OnAclAnimationReachedAttack` + `actAnimation <attackN> NumberCycle=1` + `actExecuteState OnAclAnimationReachedAttackEnd` | clamp-once (`NumberCycle=1`; debug `bPlayOnce=True`; script early-out `0,0` + `DoDeath`-style `acmPlayOnce` on the attack path) | `...Attack` fires mid-clip → damage/cost/pause/projectile/sound applied per `weapind` (`onaclanimationreachedattack.inc:15-29,54-110`); `...AttackEnd` fires at clip end → `_unit_TryAttack(trg,True)` re-issues the attack (or `TryAttack(0,True)` for guard/gainres/build orders) (`...attackend.inc:9-12`); both handlers end `SwitchTo('Nothing')`, returning control to the tag dispatcher |
| Cross-weapon / stance-transition rows (`From=walk0 Name∈{idle,walk,idle1,attack1}`, `From=idle Name∈{walk0,idle0/1/2,attack0/1}`, `From=walk Name∈{walk0,walk,idle0,attack0}`, peasant `:3-501`) | `actAnimation ∈ {prepare*,unprepare*,trans*}` with `NumberCycle=1` + `actTrackPoint` steering | once (transitional; `NumberCycle=1` in every row read) | engine tree walk-through (`GameObjectSwitchToTreeAnimationCyclesBlendByHandle` + `SetupRotatingToDirection/Target`, `unit.script:10990-11017`); NO script `anim :=` set-site and NO `ExecuteState` inside these rows — the selector only *readbacks* their names (T18-T20) |

`Nothing` is therefore the hub: every armed ACL completion handler ends with `SwitchTo('Nothing')` (ev_P4b-e), and `Nothing` re-dispatches on tags/orders. The `Build`-as-state row does not exist; build/repair orders advance through the `...Construct` event, not a Build state (§1.1).

---

## 2. Exact state/order/weapon/carry → AAF token map (read-only) [O]

Branch order is the donor's own set-site line order (carried from DEC_U §1.2): `iVisual=hide` T26 → `iEssential=death` T21 → extract/build/attack T1-T7 → carry T8-T13 → weapon-state T14-T17 → sticky readback T18-T20. T23-T25 have no set-site (orphans). Blend and gate columns are per-site observations.

| # | Entity state / order / weapon / carry [O donor trigger] | AAF token [O] | Donor set-site [O] | Blend at emission [O] | Existence gate [O] | Loop/clamp [O] | Advancing event [O] |
|---|---|---|---|---|---|---|---|
| T1 | `iAction=extract` + target res `food` | `workfood` | `unit.script:10865-10871`; mirror `ontagstates.inc:302-304` | `0,0` early-out (`:10891-10893`) | `_unit_IsAnimationExists` `:10888` | loop | `OnAclAnimationReachedWork` → res HP/`resamount+1` → `SwitchTo('Nothing')` (`...work.inc:15-59`) |
| T2 | `extract` + `wood` | `workwood` | `:10872`; mirror `:305-308` | `0,0` early-out | same `:10888` | loop | same Work event |
| T3 | `extract` + `stone` | `workstone` | `:10873`; mirror `:309-312` | `0,0` early-out | same `:10888` | loop | same Work event |
| T4 | `iAction=build` (any res/weapon) | `construct` | `:10877`; mirror `:316-320` | `0,0` early-out (script); aix `bBlend` then same `0,0` switch `:329-358` | same `:10888` | loop | `OnAclAnimationReachedConstruct` → build/repair HP → `SwitchTo('Nothing')` (`...construct.inc:23-51`) |
| T5 | `iAction=attack` + `iWeapon∈{none,0}` | `attack0` | `:10878-10880`; mirror `:321-325` | `0,0` early-out | same `:10888` | once (`NumberCycle=1`, `bPlayOnce=True`) | `...Attack` → damage/pause/cost/projectile (`...attack.inc:15-110`) then `...AttackEnd` → `_unit_TryAttack` re-issue (`...attackend.inc:9-12`); both `SwitchTo('Nothing')` |
| T6 | `attack` + `iWeapon=1` | `attack1` | `:10881`; mirror `:324` | `0,0` early-out | same `:10888` | once | same Attack/AttackEnd pair |
| T7 | `attack` + `iWeapon=2` | `attack2` | `:10882`; mirror `:325` | `0,0` early-out | same `:10888` | once | same pair (grenadier `attack2before/after` have NO set-site — T23) |
| T8 | `iResource=food` + `iMove∈{idle,turn}` | `idlefood` → `animidle` | `:10901-10906`; mirror `:370-376` | turn `6,8` (`:11016`), idle `0,0` (`:11042`) | sticky: `animidle` else `gc_anim_idle` (`:11036-11037`) | loop | next tag evaluation; turn path via `SetupRotatingToDirection/Target` (`:10990-11008`); walk-sound typing (`nothing.inc:34-39`) is audio only |
| T9 | `food` + `walk` | `walkfood` → `animwalk` | `:10905`; same mirror | walk `6,8` (`:11055`) | walk: `animwalk` else `gc_anim_walk` (`:11048-11051`) | loop | next tag evaluation |
| T10 | `wood` + idle/turn | `idlewood` | `:10910-10912`; mirror `:377-382` | same split | same sticky | loop | same |
| T11 | `wood` + walk | `walkwood` | `:10913`; same mirror | walk `6,8` | same walk fallback | loop | same |
| T12 | `stone` + idle/turn | `idlestone` | `:10916-10918`; mirror `:384+` | same split | same sticky | loop | same |
| T13 | `stone` + walk | `walkstone` | `:10919`; same mirror | walk `6,8` | same walk fallback | loop | same |
| T14 | no action, no res; `iWeapon=none` + idle/turn/walk | `idle/idle/walk` | `:10928-10933` | turn `6,8` (code present but commented `:10963-10972` — turn currently falls to the idle sticky path); idle `0,0`; walk `6,8` | sticky/walk fallbacks as above | loop | turn: rotate calls; idle: `0,0` re-switch "to prevent 2 shooting animation effect" (`:11042` donor comment); walk: `walkintervalfactor` (`:11054`) |
| T15 | `iWeapon=0` + idle/turn/walk | `idle0/idle0/walk0` | `:10935-10940` | same split | same | loop | same |
| T16 | `iWeapon=1` + idle/turn/walk | `idle1/idle1/walk1` | `:10942-10947` | same split | **donor-dead name**: zero AAF rows define `walk1` (194-file census), so donor always degrades to `walk` at `:11048-11051` [D] | loop (idle1); walk1 never plays | same |
| T17 | `iWeapon=2` + idle/turn/walk | `idle2/idle2/walk2` | `:10949-10954` | same split | same | loop | same |
| T18 | turn/idle sticky readback: current ∈ {`trans10,trans20,walk0,prepare0,attack0,idle0`} | `idle0` | `:10977-10978` + `:11027`; mirrors `ontagstates.inc:435,485` | turn `6,8`; idle `0,0` | `animidle` re-check → `gc_anim_idle` (`:10987-10988,:11036-11037`) | loop | readback only — honoured when the caller supplies `current_anim`; port leaves dormant until R-S |
| T19 | readback ∈ {`trans01,trans21,walk1,prepare1,attack1,idle1`} | `idle1` | `:10979` + `:11028`; mirrors `:436,486` | same | same | loop | same |
| T20 | readback ∈ {`trans02,trans12,walk2,prepare2,attack2,idle2`} | `idle2` | `:10980` + `:11029`; mirrors `:437,487` | same | same | loop | same |
| T21 | `iEssential=death` + `iWeapon=none/0/1/2` | `death/death0/death1/death2` | `:11086-11093`; mirror `:583-589` | `6,8` (`:11100`); artillery resets blend after (`:11101-11102`) | weapon-specific → plain `death` if missing (`:11092-11093`) | once (`DoDeath acmPlayOnce/aamPlayOnce` `:10808-10809`; `stage_0 acmPlayOnce` `:10851-10852`) | `OnDeath` state (`:11075`) → delayed `DeathStage1` after `gc_unit_deathtime_0` (`:11085`); all four `OnState*Reached` handlers blanked (`:10811-10816`); artillery reloads `<basename>_death` props (`:11096-11099`); desync `0.7+random*0.6` (`:11103`) |
| T22 | peasant tool attach (same `anim` as T1-T13 + `attack0/construct/death`) | child actor `hoe/axe/pick/hammer/bag/lumber/cart/hide`, NOT an AAF token | `:6991-7012` (called `:11068-11069`) | n/a (child visibility swap) | peasant `usage` + child-count guard (`:11068`) | n/a | `SetGameObjectActorIndexByHandle` + `SetGameObjectVisible(child)` (`:2078-2116` region pattern; attach call `:11069`) |
| T23 | `attack2before`/`attack2after` (grenadier `630..663`/`664..679`) | — (no set-site) | zero hits in `unit.script`, `D:scripts/**`, `D:animations/acl/*.acl` (DEC_U P5) | — | debug buttons only | orphan-once | explicit `anim_action` only |
| T24 | `reaction` (`456..481` in 8 peasant AAFs) | — (no set-site) | no `gc_anim_reaction` constant; zero refs everywhere incl. debug list (DEC_U P5) | — | none | orphan (loop-shaped 26-frame row, never fired) | explicit `anim_action` only |
| T25 | `prepare*/unprepare*/trans*/walkprepare*/walkunprepare*` as *selected* clips | — (no `anim :=` set-site; readback-only) | present only as readback/sticky names (T18-T20) and ACL `actAnimation` transition rows | — | engine ACL-tree walk | once (transitional `NumberCycle=1`) | engine tree traversal; explicit `anim_action` only until R-A |
| T26 | `iVisual=hide` (inside mine/transport) | forced through `DoDeath` + `acmNone/aamNone` + invisible | `:11076-11080` (+ `11009-11015` hide tail) | n/a | — | none | `SetGameObjectVisible(False)` + playable/collision off |

### 2.1 Per-sid AAF availability (all 194 shipped files; grouped, nothing invented) [O]

The selector is identical for every sid; only the AAF row set differs. `has_action(sid,token)` (port mirror of `_unit_IsAnimationExists`, `unit.script:369-373`) resolves per sid. Families observed this pass (representatives read in full; census counts carried from DEC_U/DANIM_01):

| Family (example sids) | AAF rows read [O] | Tokens present | Tokens absent (gap, never substituted) |
|---|---|---|---|
| Peasant family, 8 files (`peaukr.aaf` read: 18 rows) | `idle/walk/death/attack0/work*/idle*/walk*/construct/reaction/prepare0/unprepare0`, `idle0=idle 64..113` alias | T1-T4, T8-T15, T21(`death` only), T22 attach | `attack1/attack2` family, `death0/1/2`, `walk0/1/2`, `idle1/2` distinct, `attack2before/after` (orphan), `reaction` (orphan) |
| Line infantry (`musketeer.aaf`: 17 rows) | `walk 1..24`, `walk0 26..49`, `attack1 99..124`, `idle/idle0/idle1 153..305`, `prepare*/unprepare*/trans*`, `death/death0/death1` | T5(`attack0`→gap→fallback), T6, T14-T16, T18-T19, T21(`death/death0/death1`) | `attack2` family, `death2`, all carry/work, `reaction` |
| Grenadier (`grenadier.aaf`: 30 rows + 1 commented) | musketeer set + `attack0 126..141`, `attack2 153..154` stub, `attack2before 630..663`, `attack2after 664..679`, `death2`, `idle2`, `prepare2/unprepare2/trans*` | T5-T7(`attack2` resolves to the 2-frame stub), T17, T20, T21 full set | `attack2before/after` (orphan T23), all carry/work, `reaction` |
| Artillery (`cannon.aaf`: 4 rows) + `cannon_death.aaf` | `idle 1..1`, `walk 1..99`, `attack0/attack1 301..337` (same window) | T5-T6 (same frames), T14-T16 degraded, T21 via `_death` props reload | `attack2`, carry/work, `prepare*/trans*`, `death0/1/2` distinct |
| Ships (`yacht.aaf`: 4 rows, all `1..280`; same shape for `chaika/ferry/galley/frigate/battleship` per ev_P5d handler census) | `idle/walk/death/attack0` one shared window | T5, T14, T21(`death`) | everything else is a gap |
| Cavalry (`fasthorse/hardhorse.acl` carry `attack2` blocks per DEC_U P4; AAF rows not re-read here) | `attack2` rows present (DEC_U ev_P4e) | T7 resolvable where their AAF declares it | carry/work, `reaction` |

No sid invents a token: a miss stays a per-sid `HAS_ACTION_MISS` gap and the caller follows the donor fallback order (`animwalk→walk`, weapon-death→`death`, `animidle→idle`, `attack2→attack1→attack0→idle`).

---

## 3. Loop vs clamp and the exact advancing event [O]

| Policy | Donor source [O] | Port mirror [O] |
|---|---|---|
| Loop: `walk/walk0/idle/idle0/1/2/construct/work*/carry*` | `showdebuganimations.inc` `bPlayOnce=False`; `unit.script:10853-10854` `acmLoop` for every non-`stage_0` live unit; `movie.script:648-656` `bLoop→acmLoop` | `anim3d.gd` `_is_once_action=false` → `fposmod` loop; `AAF_LOOP_STATUS [U] U2` label (`anim3d.gd:129`) |
| Once: `attack0/attack1/attack2`, `death/death0/death1(/death2)` | debug `bPlayOnce=True` (attacks listed twice — loop AND once buttons; sim path is once); `DoDeath acmPlayOnce/aamPlayOnce` (`:10808-10809`); `visual_stage_0 acmPlayOnce` (`:10852`); ACL `CyclesList=False` + `actAnimation NumberCycle=1` (cannon `:19,40`; peasant attack rows) | `_is_once_action=true` → clamp at `first+min(elapsed*30, span-1)`; `AAF_COMPLETION_STATUS [U]-C1/C2` stand-in |
| None: hidden | `iVisual=hide` → `acmNone/aamNone` (`:11079-11080`) + invisible (`:11009-11015`) | no hide path wired (T26 port status `no`) |
| Blend bypass (not a cycle flag) | T1-T7 + idle re-entry force `0,0` + `GameObjectResetFrameAnimationBlend` ("dont use blend cause it kills animation" `:10891`; "to prevent 2 shooting animation effect" `:11042`) | logged intent only (`DONOR_BLEND_NONE` vs `DONOR_BLEND_MINMAX`); engine operator stays `[U]-B` |

The advancing event per token is §2's last column: Work/Construct/Attack/AttackEnd handlers each end `SwitchTo('Nothing')`; death advances via delayed `DeathStage1`; everything else advances via the next tag evaluation (sticky readback or fresh `anim`).

---

## 4. True gaps [U] — fixed-camera state-transition / frame-trace captures (do NOT synthesise)

Every capture: fixed camera, singleplayer skirmish, paused-then-stepped sim, per-tick log `(sim_tick, tag_fields(iAction/iWeapon/iMove/iResource/iEssential/iVisual), selected_anim, AAF first..last, requested_frame, sample_frame, blend_delta, within_window, engine_state)`. No donor binary is executed by this worker; captures are specified for the runner owner. **Termination is zero-mismatch**: the verdict is recorded only when every listed trial matches exactly; any mismatch keeps the [U] open and is logged, never smoothed over.

- **[U]-W (weapon/order → attack1/attack2; bullet⇔iWeapon=1 unproven).** Capture R-W: fixed camera on musketeer (`attack1 99..124`) and grenadier (`attack0 126..141`, `attack1 99..114`, `attack2before/after`) each ordered to attack a ground target and an enemy unit; log `iWeapon`, `selected_anim`, frame trace `0..span+2` past the last frame; vary only ammo/weapon upgrade state. Termination: `attack1` fires iff `iWeapon=1` observed ≥3/3 trials per sid AND `attack2before→attack2after` sequence observed on grenade order or its absence logged with the exact order-scale used; else stays [U].
- **[U]-W2 (death0/1/2 by weapon at death).** Capture R-W2: kill armed (musketeer `death0 564..628`) and unarmed (peasant `death 115..149`) units on fixed camera; log `iWeapon` at death tag + `selected_anim` + interval factor (`0.7+random*0.6` desync). Termination: weapon-death token observed ≥2/2 armed trials with fallback logged when the sid lacks the row, or absence logged.
- **[U]-S (sticky readback T18-T20 dwell).** Capture R-S: musketeer attack→idle seam at 30 Hz; record `GetGameObjectFrameAnimationNameByHandle` per tick for 90 ticks post-attack; check whether any `attack1/trans*/prepare1` name persists ≥1 tick before `idle1`. Termination: sticky name observed with count, or 3 clean attack→idle seams with zero intermediate names logged. Port keeps stateless recompute until then.
- **[U]-A (`prepare*/unprepare*/trans*/walkprepare*` entry triggers).** Capture R-A: order stance changes, formation joins/leaves, cavalry mount/dismount-adjacent orders on fixed camera; log selected anim per tick. Termination: ≥1 reproducible trigger per token family with tag fields, or explicit absence log after exercising all stance/formation orders.
- **[U]-R (`reaction` trigger).** Capture R-R: expose peasants to raids, nearby deaths, combat start/end, construction complete, idle long-tail (≥120 s) on fixed camera with full tag dump; log any `reaction` selection. Termination: one reproducible trigger with tag fields, or absence logged across the full battery (token stays export-only, never auto-triggered).
- **[U]-C1 (PlayOnce end behaviour for `attack*/death*`).** Capture R-C1: musketeer `attack1 [99,124]` single shot, frame-index trace at 30 Hz from `t0` to `t0+span+10` frames; record hold-at-`124` vs snap-to-`idle1 [256,305]` tick-aligned vs mid-blend freeze; repeat for peasant `death [115,149]`. Termination: hold-vs-return verdict with tick numbers, 3/3 trials, zero mismatch.
- **[U]-C2 (ACL `...AttackEnd` effects incl. cannon).** Capture R-C2: cannon `attack0/attack1 [301,337]` firing on fixed camera; log muzzle-flash PFX attach frame, damage tick, sound tick relative to `301..337`; cross-check `_unit_TryAttack` re-issue (`...attackend.inc:9-12`). Termination: effect-to-frame offsets with 3-trial repeat, or absence logged.
- **[U]-B (blend operator `6/8` vs `0,0`).** Capture R-B: walk→idle seam (peaukr `walk 1..20` → `idle 64..113`) stepped 1 frame/tick; log rendered-pose vertex hash for ticks `[-2,+10]` around the switch under `min/max` vs forced `0,0`; fit step-response length in frames. Termination: response length in frames with 3-trial repeat under both settings, or explicit non-reproducibility log. Port keeps nearest-frame diagnostic and performs no interpolation until then.
- **[U]-T (peasant tool-attach presentation).** Capture R-T: fixed-camera work/carry/construct/attack/death per T22 row; log child handle visibility + actor index per selected anim. Termination: per-row attach table with 2/2 trials, or absence logged. Owned by the art lane; carried here because T22 is in the map.

---

## 5. Deltas vs prior reports

| # | Prior statement | This-pass verdict |
|---|---|---|
| D1 | DEC_U §1.2 T1-T26 trigger→token rows | CONFIRMED line-for-line; this report adds the per-row advancing event (`SwitchTo('Nothing')` / `DeathStage1` / tag re-evaluation) and the ACL block shapes that carry them |
| D2 | DEC_U D2 `walk1` donor-dead | CONFIRMED: selected at `unit.script:10946`, zero AAF rows in the 194-file census, always degrades at `:11048-11051`; port resolver must never request it (already guarded in `_resolve_donor_action`) |
| D3 | DEC_U D3/D4 orphan verdicts (`attack2before/after`, `reaction`) | CONFIRMED and tightened: handler registry (`unit.aix:130-152`) lists only Attack/Work/Construct/AttackEnd — no Build/Death/Nothing completion handlers exist to smuggle orphans in |
| D4 | Assignment "Nothing/Work/Construct/Attack/Build states" | SCOPED: `Nothing` is the one readable engine state; Work/Construct/Attack are ACL completion events, not states; `Build` is an order/action tag only — no `Name = Build` state, no `OnAclAnimationReachedBuild`, no `gc_anim_build`. §4 F4 keeps the port `build→construct` row labelled as a T4 tag row |
| D5 | IMPL §5 R1-R8 patch recommendation | CONFIRMED as the change list below, re-anchored to current port lines; nothing in it was applied here |

---

## 6. Exact port change list (file/line; no code written here) [O]

Each row: port site [O], donor fact [O]/[D], required donor-faithful replacement. No row implemented. No parity claimed.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required replacement (donor-faithful; assets already on disk unless noted) |
|---|---|---|---|
| F1 | `P:scripts/anim3d.gd:1424-1492` `resolve_donor_trigger` branch order | Donor set-site order T26→T21→T1-T7→T8-T13→T14-T17→sticky (ev_P2a-e, §2) | KEEP order verbatim; add nothing. If a new caller is added, it must pass the seven decoded tag fields through this function, never a hand-rolled chain. No asset needed. |
| F2 | `P:scripts/anim3d.gd:1500-1508` `resolve_donor_action` gate + `P:scripts/anim3d.gd:533-...` `has_action` | `_unit_IsAnimationExists`: `anim=''` → true, else engine probe (`unit.script:369-373`); weapon-death→`death` (`:11092-11093`); `animwalk→walk` (`:11048-11051`); `animidle→idle` (`:11036-11037`) | KEEP `available = token != "" and has_action(sid,token)`; document the `''→true` donor rule next to `_action_available`'s deliberate `false`-for-empty port guard (empty = no-op, not `idle`). No asset needed. |
| F3 | `P:scripts/world3d_entities.gd:1945-1981` resolver-first + preserved C3 fallback chain | Early-out `0,0` rows (T1-T7) skip the sequencer (`bSkip`, `:10891-10893`); deferred rows use `6,8` (`:11016,:11055,:11100`); idle seam forces `0,0` (`:11042`) | KEEP resolver-first order; extend `_record_donor_trigger_gap` chains per F7 so R-W/R-W2/R-S can audit which link fired. Log `blend` intent only — wire no interpolation until R-B. No asset needed. |
| F4 | `P:scripts/world3d_entities.gd:1999-2003` `build/repair→construct` + `:2115-2153` `_donor_tag_fields` action decode | `build` is order `gc_obj_order_type_build/repair` + action tag `gc_statetag_action_build` → `construct` (`:10877`); there is NO Build engine/ACL state (§1.1) | KEEP the T4 tag row; rename any `Build`-state comment to "T4 build/repair-order tag → construct (no donor Build state)". Add the `bBlend`-flag comment from the aix mirror (`ontagstates.inc:297,317,350-358`). No asset needed. |
| F5 | `P:scripts/world3d_entities.gd:2008-2026` carry chain + `:2077-2091` `_donor_resource_suffix` | T8-T13 res×move matrix (`:10898-10923` + mirror `:367+`); permanent ores mine as stone is a PORT mapping, not a donor row | KEEP chain order; NEVER request `walk1` in any chain (donor-dead name, D2); add the `animidle`-existence re-check before returning carry idles (mirror `:11036-11037`) once R-S proves dwell — until then keep the stateless chain and the `[U]-S` label. No asset needed. |
| F6 | `P:scripts/world3d_entities.gd:2032-2042` attack chain + `:2161-2169` `_donor_weapon_index` | Donor gates on **`iWeapon` tag slot** (`:10878-10883`), not ammo kind; Attack handler maps `none/0→0, 1→1, 2→2` (`...attack.inc:15-21`) | KEEP `_donor_weapon_index` explicit-index-first + `bullet→1` labelled fallback (`[U]-W`); NEVER produce `"2"` without an explicit index + R-W proof; add `attack2before→attack2after` sequencing ONLY after R-W observes it. No asset needed (clips exported). |
| F7 | `P:scripts/world3d_entities.gd:1982-1998` explicit `anim_action` + `attack2→attack1→attack0→idle` order + `:2241-2254` orphan labels | T23/T24/T25 + `walk1` + `turn*/collide*` have no set-site (ev_P5/P6); debug list never names `reaction` | KEEP explicit-only orphan path, availability-gated + gap-recorded; extend gap records with the donor chain as-tried (walk `animwalk→walk`, death weapon→`death`, sticky `animidle→idle`) so R-W/R-W2/R-S audits close. No asset needed. |
| F8 | `P:scripts/world3d_entities.gd:2045` stateless `walk if moving else idle` return | Donor turn/idle path is stateful readback T18-T20 (`:10977-11029` + mirrors) with `6,8` vs `0,0` split | KEEP stateless return; a one-slot `last_anim` sticky readback may be added ONLY after R-S proves dwell (IMPL §5 R6); `_donor_sticky_idle` classifier stays dormant by default. No asset needed. |
| F9 | `P:scripts/world3d_entities.gd:1982-1983` dead branch (always `death`) | Donor selects `death/death0/1/2` by `iWeapon` + fallback (`:11086-11093`) with `DoDeath` overlay + `DeathStage1` delay (`:11075,:11085`) | Branch `death0/1/2→death` by weapon index, availability-gated, logging the fallback when it fires (R-W2 proof). Artillery `<basename>_death` reload noted; no port prop-reload invented. Assets: per-sid `death*` windows already exported where declared. |

Port rows outside this worker's ask (`game.gd` order creation, `data.gd` weapon tables, `world.gd:515-516` bullet mapping, building death visuals, `anim_action` producers) are NOT restated to avoid a second source of truth.

Required donor asset manifest (all already on disk; sourced only through the approved converters, NOT copied here): `D:animations/aaf/*.aaf` (194 files incl. `reaction 456..481`, `attack2before/after`, `prepare*/trans*/walkprepare*` rows) + per-sid `.oss` bodies; `D:animations/acl/*.acl` (peasant/cannon/ship/cavalry/infantry blocks) + `acl.lib`; `D:scripts/dmscript.global:868-926`, `D:scripts/lib/unit.script` (`:369-373`, `:6991-7012`, `:10796-11115`, `:8346`), `D:scripts/units/unit.aix:130-152`, `D:scripts/units/unit.inc/{ontagstates.inc:166-516,nothing.inc:1-13,onaclanimationreachedattack.inc:1-155,onaclanimationreachedattackend.inc:1-18,onaclanimationreachedwork.inc:1-62,onaclanimationreachedconstruct.inc:1-54}`, `D:gui/menu.inc/showdebuganimations.inc`, `D:scripts/lib/movie.script:648-656`.

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | T1-T26 trigger→token rows with per-site blend, gate, loop/clamp, advancing event | [O] ev_P2a-e/P3a/P4b-e/P5a-c |
| 2 | `Nothing` is the only readable unit engine state; Work/Construct/Attack are ACL completion events each ending `SwitchTo('Nothing')`; no Build state/handler/constant exists | [O] ev_P3b/P4a-e/P5d |
| 3 | Attack `...Attack` applies damage/cost/pause/projectile per `weapind`; `...AttackEnd` re-issues `_unit_TryAttack`; Work applies res HP/`resamount+1`; Construct applies build/repair HP | [O] ev_P4b-e |
| 4 | `walk1` is a donor-dead name (selected, never resolvable) | [D] ev_P2c + 194-file census |
| 5 | Per-sid availability table: selector identical, rows differ; misses are labelled gaps, never substitutions | [O] ev_P1c-g/P6c-d |
| 6 | Loop vs once vs none policy + `0,0` bypass sites | [O] ev_P2f/P5a/P6b |
| 7 | Port sites in §6 (resolver, gate, chains, tag fields, orphan labels, gaps) | [O] ev_P6c-e |
| 8 | Every [U] has a named fixed-camera capture with zero-mismatch termination (R-W/R-W2/R-S/R-A/R-R/R-C1/R-C2/R-B/R-T) | [D] this report §4 |
| 9 | Any port motion equalling donor timing/pose/blend, or any trigger claimed without a §2 cite | **Denied** — no same-camera donor/port A/B exists; visual UNVERIFIED |

## 8. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0`'s data tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer is out of scope.

*End of DEC-U-STATE-MAP.*
