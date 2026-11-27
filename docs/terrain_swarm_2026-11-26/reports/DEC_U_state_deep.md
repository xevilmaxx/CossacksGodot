---
id: DEC-U-STATE-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-STATE-DEEP — native static localization of the U2 state→AAF selector (CODE-embedded tables, ACL dispatcher, weapon/carry arg, loop/completion wiring)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_state_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep engine active, shared Craft Anything session). Every native call pinned with document=t_87f0f3c130b0. Binary never executed, no bytes copied."
port_scope: "variant3d/scripts/anim3d.gd + variant3d/scripts/world3d_entities.gd cited read-only only where they own the [U] fields; NOT edited, NOT re-specified."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_state_map.md (T1–T26 trigger→token rows, Nothing only readable engine state, Work/Construct/Attack as ACL completion events; U2 state→AAF trigger map for work/carry/reaction + weapon→attack1/attack2 left [U])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_deep.md (CODE-embedded-table method, RTTI/API table VAs, B1/B2/B3/P1 verdicts)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md (T1–T26, orphan verdicts, loop/once, C1/C2/B opens)
---

# DEC-U-STATE-DEEP — native static localization of the U2 state→AAF selector

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0` (not port test ids). "Address" = donor VA (`0x…`) for binary hits, `path:line` for donor text.
> Context carried: `DEC_U_state_map.md` closed T1–T26 trigger→token rows at script/ACL text level (`Nothing` the only readable engine state; `Work`/`Construct`/`Attack` as ACL completion events, not states). What stayed `[U]`-U2 is the *native* side of the same map: is there a CODE-embedded state→animation-name table, does the native selector take weapon/carry as an explicit argument, and does any native loop/completion flag drive animation *choice*? This worker attacks U2 from those NEW native angles only.

## 0. Method, passes, tool limits

### 0.1 Pass ledger (multiple NEW passes on the packed exe, not just script text)

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_bytes_find` text `SwitchTo` (utf8+utf16le, whole file) | ev_ed95bd3d: **38 matches, ALL in CODE** `0x62fd8e–0x643272` + `0x639896–0x639c83` + `0x642c4a–0x643272` + outliers `0x65915f/0x65d045/0x68d60b/0x68d678/0x69fbd4/0x6bf382/0x6c03e2` `[O]` — the script-API table region from blend-deep, not a state table |
| P2 | `native_bytes_find` `Nothing` / `OnAclAnimationReachedWork` / `...Attack` / `...Construct` | `Nothing` = **1 hit `0x4ab39d`**; `OnAclAnimationReached{Work,Attack,Construct}` = **0 hits each** `[O]` (§1.1: the 1 `Nothing` is a TRegExpr false positive; completion names live only in script/ACL text) |
| P3 | `native_bytes_find` `acmPlayOnce` / `TActorAnimationMode` / `TActorAnimationReference` | **1 hit each**: `acmPlayOnce@0x512008`, `TActorAnimationMode@0x4f6e36`, `TActorAnimationReference@0x4f6d66`, all CODE `[O]` (§1.2) |
| P4 | `native_bytes_show` `0x4ab300+512`, `0x511f00+768`, `0x4f6d00+512`, `0x62fd00+1200` | `Nothing` context = TRegExpr error table; `0x511f00` = `aam*/acm*` enum table; `0x4f6d00` = `TActorAnimationReference/FrameInterpolation/AnimationMode` RTTI; `0x62fd00` = script-API signature table `[O]` |
| P5 | `native_bytes_find` `workfood` / `construct` / `attack0` / `ExecuteState` / `AnimationName` / `CyclesList` / `actAnimation` / `actExecuteState` | `workfood`=0, `attack0`=0, `construct`=2, `ExecuteState`=37, `AnimationName`=13, `CyclesList`=4, `actAnimation`=2, `actExecuteState`=2 — all CODE `[O]` (§1.3/§2) |
| P6 | `native_bytes_find` `acmLoop` / `EndCyclesReached` / `EndFrameReached` / `StartFrameReached` / `DeferredFrameBlend` / `aamLoop` / `NumberCycle` / `acoSmooth` | `acmLoop`=1 (`0x51201c`), `EndCyclesReached`=8, `EndFrameReached`=7, `StartFrameReached`=7, `DeferredFrameBlend`=2, `aamLoop`=4, `NumberCycle`=2 (`0x86da04/0x86e408`), `acoSmooth`=1 (`0x86df3c`) `[O]` (§4) |
| P7 | `native_bytes_show` `0x86d800+1200`, `0x86dd00+1200`, `0x63b700+1200`, `0x636200+900` | ACL dispatcher tables (`acsa*`, `act*`, `aco*`, `NumberCycle`, `AnimationName`, `ExecuteStateName/Index`) + completion-handler signature block `[O]` (§2/§4) |
| P8 | `native_bytes_find` `Weapon` / `weapind` / `statetag` / `carry` / `iResource` / `OnStateEndFrameReached` / `OnStateFBEndCycles` | `Weapon`=0, `weapind`=0, `statetag`=0, `carry`=0, `iResource`=0; `OnStateEndFrameReached`=4, `OnStateFBEndCyclesReached`=4 `[O]` (§3/§4) |
| P9 | `native_bytes_find` `Work` (28) / `Attack` (9) / `Construct` (10) + `bytes_show` spot windows `0x431000/0x44e900/0x68eb00/0x744c80/0x791900` | ALL generic hits = VCL `clAppWorkSpace`, ComCtrls `TWorkArea`, formation-logic `ClassicAttack/DeepAttack`, wall-constructor — NOT animation state tables `[O]` (§1.4 negative) |
| P10 | `native_bytes_show` `0x518e00+900`, `0x520e80+900`, `0x86d980+1000` | `construct` hits = DMScript keyword table (`constructor/destructor` language keywords), NOT animation states `[O]` (§1.4) |
| P11 | `native_bytes_find` `idlefood` / `walkfood` / `attack1` / `death0` / `AnimationCycle` / `CyclesMode` | `idlefood`/`walkfood`/`attack1`/`death0` = **0 each**; `AnimationCycle`=59 (API table), `CyclesMode`=4 `[O]` (§3: AAF tokens absent from exe) |
| P12 | `native_bytes_show` `0x630100+1100` (Tree blend prototype), `0x642e00+800` (non-blend twin); `native_xrefs_list` `0x86d800`, `0x6301c2` | Full selector prototypes byte-anchored (no weapon/carry param); **0 xrefs each** under engine-stated `computed pointers` limit `[O]` (§3) |
| P13 | `native_strings_find` `SwitchTo` / `ExecuteState` / `AnimationName` (data-section index) | **0 strings each** (ev_f29c26ac, ev_9f6f81de: `data_sections_only` limit) vs P1/P5 CODE hits — proves CODE-embedded tables invisible to the strings index `[O]` (same pattern as blend-deep P2/P5) |
| P14 | `native_bytes_show` `0x63ac00+1200`, `0x63e900+1200`, `0x86de00+900`, `0x63b600+900`, `0x630600+900`, `0x550d80+600` | Completion-handler family (`OnState{End,Start}{Cycles,Frame}Reached`, `OnStateFBEndCyclesReached`, `OnState{DistanceToPoint,PointChanged,EndPoint}`) + controller flags + `AnimationMode/OnFrameChanged/OnEndFrameReached/OnStartFrameReached` property row `[O]` (§4) |

**Strange-read log:** `native_strings_find` searches data sections only — zero-hit does NOT mean absent (P13 vs P1/P5 proves the symbols live in CODE-embedded tables). `native_bytes_find` "compressed, encrypted or packed regions … are not seen, so no match is not proof of absence" (`.bind` entropy 7.96 exec per blend-deep) — every zero-hit below is therefore reported as `[O]-absence with packed-region reserve`, never as proof of non-existence. `native_xrefs_list` on table VAs returns 0 under "references made through computed pointers at run time are not seen" — a tool limit, never evidence of dead code. No donor binary executed; no donor bytes copied. `reaction`/`attack2before`/`prepare0` zero-hit text searches carried from `DEC_U_state_map` P5/P7 (not re-run to avoid duplicating that worker's evidence; verdicts confirmed by the P2 handler-absence here — no `OnAclAnimationReached` family in the exe at all).

---

## 1. (a) Packed CODE byte search for state/selector names with VAs [O]

### 1.1 `SwitchTo` / `Nothing` / `Work` / `Construct` / `Attack` — what the exe DOES and DOES NOT contain

- **`SwitchTo`: 38 CODE hits (ev_ed95bd3d).** Address list `[O]`: `0x62fd8e, 0x62fe2c, 0x62feea, 0x62ff90, 0x630056, 0x6300fc, 0x6301c2, 0x63028c, 0x630376, 0x6303f8, 0x63049a, 0x630520, 0x6305c6, 0x63064c` (Tree/Cycles/Frame blend family, same `0x62f300–0x630700` API table as blend-deep §1.2) + `0x639896, 0x6398dc, 0x639c83` (ExecuteState region §4) + `0x642c4a–0x643272` (non-blend `SwitchToTreeAnimationCycles` twins, 10 hits) + 7 outliers (`0x65915f, 0x65d045, 0x68d60b, 0x68d678, 0x69fbd4, 0x6bf382, 0x6c03e2`). Every inspected window spells a **`GameObject…SwitchTo…(gohnd/handle, name: String, …)` script-API prototype**, never a `state → animation` row. There is NO `SwitchTo('Nothing')`-shaped native table: `SwitchTo('Nothing')` exists only as **script text** (`onaclanimationreached*.inc` handlers + `unit.script`, per state-map ev_P4b-e), with zero native-side `SwitchToNothing` literal in the exe.
- **`Nothing`: 1 hit `0x4ab39d`, PROVEN FALSE POSITIVE `[O]`.** `bytes_show 0x4ab300+512` reads `TRegExpr(comp): ?+*{ Follows Nothing` — a regex-diagnostic string, not the `unit.inc/nothing.inc` engine state (`Name = Nothing`, state-map §1.1). No other `Nothing` run exists in the file. The readable engine state `Nothing` therefore has **zero native table presence**; it is script-defined only.
- **`OnAclAnimationReachedWork / ...Attack / ...Construct`: 0 hits each `[O]`** (P2). The ACL completion events that advance `Work`/`Construct`/`Attack` (state-map §1.3: peasant `work*`/`construct` rows, cannon/infantry attack brackets, handlers ending `SwitchTo('Nothing')`) are **absent from the packed bytes** — they live in `D:animations/acl/*.acl` text + `D:scripts/units/unit.inc/onaclanimationreached*.inc` text only. This is a clean negative: no native completion-name table to mine for a state→animation map.
- **`Work` (28) / `Attack` (9) / `Construct` (10): ALL EXCLUDED as non-animation tables `[O]`** (P9/P10). Spot windows: `0x431000` = `clAppWorkSpace/clBackground/clBtnFace…` (VCL color constants); `0x44e900` = `TWorkArea/TWorkAreas` (ComCtrls list-view); `0x68eb00/0x791900` = `ProcessPlayerSLogicFrmClassicAttack/DeepAttack…`, `TXFormationLogicClassicDefence/ClassicAttack/DeepDefence…` (formation AI); `0x744c80` = `TXWallConstructor/TXConstructorMode` (wall builder). The 2 lowercase `construct` hits (`0x518ec0/0x520f28`) sit in the DMScript keyword table (`array/args/break/begin/case/const/…constructor…destructor…`, `0x518e00` window) — language keywords, not animation states. `D`-consequence: generic substring search cannot smuggle a state table into existence; every candidate window resolves to an unrelated subsystem.

### 1.2 `acmPlayOnce` / `TActorAnimationMode` / `TActorAnimationReference` — byte-anchored, one hit each [O]

- `acmPlayOnce@0x512008` sits inside the mode-enum run at `0x511f00+768` `[O]`: `…cmNone/cmPC/cmPlayer…aamNone/aamPlayOnce/aamLoop/aamBounceForward/aamBounceBackward/aamLoopBackward/aamExternal…acmNone/acmPlayOnce/acmLoop…mmNone/mmDoTrackOnce/mmDoTrackListLoop/…/mmDoTrackPosition…trmNone/trmToTargetObject/…/gfNone/gfWedge/…/rpNone/rpLeft/…/rqBack/rqLeft/…`. Same region blend-deep §1.1-D cited for `afp*/aam*`; this pass adds the adjacent `acm*` + `mm*` (track-list) + `trm*` + `gf*` + `rp*/rq*` families as observed neighbours — named only, no semantics assigned.
- `TActorAnimationReference@0x4f6d66` + `TActorAnimationMode@0x4f6e36` both inside the mesh RTTI block at `0x4f6d00+512` `[O]`: `TOSWBaseMesh…TActorAnimationReference: aarMorph/aarSkeleton/aarNone/aarTransform…TActorFrameInterpolation: afpNone/afpLinear/afpSkin/afpLSkin…TActorAnimationMode: aamNone/aamPlayOnce/aamLoop/aamBounceForward/aamBounceBackward/aamLoopBackward/aamExternal…`. Byte-confirms blend-deep Block D; `aarMorph` (the only AAF row flag observed in 194 files, state-map ev_P1c-g) is natively listed but that lists a *mode*, never a state→name row.
- `[D]` for U2: the native side owns the *vocabulary* (`aam*/acm*/aar*/afp*`), the script/ACL side owns the *selection* (T1–T26 set-sites). No CODE row binds a state name (`Nothing/Work/Construct/Attack`) to an animation name — the (a) search returns vocabulary tables, not a lookup table.

---

## 2. (b) ACL dispatcher windows — NO state→animation-name lookup table [O]

**Windows read `[O]`:** `0x86d800+1200` (controller/switch + cycle-item-action enums), `0x86d980+1000` (cycle-item fields), `0x86dd00+1200` + `0x86de00+900` (controller flags + code), `0x86da04/0x86e408` (`NumberCycle`), `0x86df3c` (`acoSmooth`), `0x86def4` (`acoSkipActions`).

Exact native structure (ascii runs, order preserved):

```
TXAnimationControllerSwitchAnimation: acsaDefault, acsaFirst, acsaRandom
TXAnimationCycleItemAction: actAnimation, actTrackPoint, actTrackPointPreset, actExecuteState
TXAnimationCycleItem: AnimationName, NumberCycle, AnimationIndex, Action,
  TrackPointMoveStep, TrackPointTurnStep, TrackPointIdleName,
  TrackPointPreset, TrackPointPresetName, TrackPointMode,
  ExecuteStateName, ExecuteStateIndex, OwnerCycles
TXAnimationCycles / TXAnimationCyclesList / TXAnimationsLibrary (containers)
TXAnimationController: actAnimation, actTrackPoint, actTrackPointPreset, actExecuteState,
  acoSkipActions, acoRandomCycle, acoRandomFrame, acoSmoothAnimation,
  acsaDefault, acsaFirst, acsaRandom
```

**Key-structure verdict `[D]`:** this is a **per-item instruction chain**, not a state-keyed map:

1. There is NO `From`-state key field anywhere in the `0x86d800–0x86e800` span. The `From → Name` transition written in `.acl` text (e.g. peasant `From=walk0 Name=idle`, state-map §1.3) has no native counterpart field — the native item carries only the *payload* (`AnimationName` + `NumberCycle` + `AnimationIndex`) and the *continuation* (`ExecuteStateName` + `ExecuteStateIndex` + `TrackPoint*` steering + `Action`).
2. `ExecuteStateName` is a **string slot per item** (paired with a resolved `ExecuteStateIndex`), i.e. the `actExecuteState OnAclAnimationReachedAttack[…]` bracket from cannon/peasant `.acl` blocks (state-map ev_P5a/c). It names the *next script state to execute when this item finishes*, not the animation to pick for a given unit state. Direction is item→state, never state→animation.
3. Selection-mode enums (`acsaDefault/acsaFirst/acsaRandom`, `acoRandomCycle/acoRandomFrame/acoSkipActions/acoSmoothAnimation`) choose *which cycle/item fires within the already-selected animation*, per the `GameObjectSwitchTo…(…, randomcycles, randomframe, …)` arguments (§3) — they do not take a unit state (`iAction/iWeapon/iResource/iMove`) as a key.
4. `NumberCycle` (`0x86da04/0x86e408`, 2 hits) + `CyclesList=False` (ACL text) is the once-vs-loop counter for the item (`NumberCycle=1` on attack rows, state-map §1.3), consumed at dispatch time — see §4. It is not a selector key either.
5. `xrefs(0x86d800)=0` under the stated `computed pointers` limit (P12) — localizes nothing further; recorded only to prevent misreading the 0 as "unreferenced".

`[D]` consequence for U2: the native dispatcher cannot answer "given weapon/carry/order X, which animation name?" — that question is answered **only** by the script selector (`unit.script:10856-11070` + `ontagstates.inc:295-516`, state-map §1.2/§2). The often-imagined "hidden native state table" does not appear in any window of the dispatcher span; the `.acl` `From` key stays a file-level construct with no native field.

---

## 3. (c) Is weapon/carry state an explicit argument to the selector? NO — byte-proven [O]

**Full native prototypes in the `SwitchTo` span (P12, `0x630100+1100` + `0x62fd00+1200` + `0x642e00+800`) `[O]`:**

```
GameObjectSwitchToTreeAnimationCyclesBlendByHandle(gohnd: Integer; name: String;
  randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean;
  minframeblend, maxframeblend: Integer)
GameObjectMySwitchToTreeAnimationCyclesBlend(name: String;
  randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean;
  minframeblend, maxframeblend: Integer)
GameObjectSwitchToAnimationCyclesBlendByHandle(gohnd; name: String;
  randomcycles, randomframe: Boolean; minframeblend, maxframeblend: Integer)
GameObjectSwitchToFrameAnimationBlendByHandle(gohnd; name: String;
  randomframe, smooth: Boolean; minframeblend, maxframeblend: Integer)
GameObjectSwitchToTreeAnimationCyclesByHandle(gohandle; name: String;
  randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean)   # non-blend twin, 0x642e00
```

**Verdict `[D]`:** no parameter slot carries weapon, carry, resource, order, move, or statetag state. The selector takes an opaque **object handle** (`gohnd/gohandle`), a resolved **`name: String`** (the already-chosen AAF token), four/two **random flags**, and the **blend window** (`min/maxframeblend`) — nothing else. Weapon/carry discrimination happens *before* the call, in script locals (`iWeapon/iResource/iAction/iMove` decoded at `unit.script:10837-10843`, branched at `:10865-11070`), and arrives at the native boundary only *baked into* `name`. The byte signatures leave no room for a second interpretation: there is no hidden `weapon: Integer` or `carry: Integer` formal to discover.

Corroborating absences `[O]` (each with packed-region reserve, P8/P11):

- `Weapon`=0, `weapind`=0, `statetag`=0, `carry`=0, `iResource`=0 hits in the whole file — the script tag vocabulary (`iWeapon`, `weapind` in `onaclanimationreachedattack.inc:15-29`, `statetag and gc_statetag_weapon`) has zero native string presence.
- AAF token literals `workfood`/`walkfood`/`idlefood`/`attack0`/`attack1`/`death0` = **0 hits each** — animation *names* are file data (`.aaf` rows), never baked into the exe. Only the structural nouns (`AnimationCycle` 59 hits, `CyclesMode` 4, `ExecuteState` 37, `AnimationName` 13) live in CODE — the framework, not the content.
- `strings_find` 0 for `SwitchTo/ExecuteState/AnimationName` (P13) vs `bytes_find` 38/37/13 confirms the framework itself is CODE-embedded, so the absences above are *table* absences, not index artefacts.

`[D]` consequence for U2: the port must keep resolving weapon→`attack1/attack2` and carry→`idle*/walk*/work*` on the script side (port `_donor_weapon_index` / `_donor_resource_suffix`, state-map §6 F5/F6). Any "pass weapon index to the engine and let it pick" design would be invention — the native entry point has no such parameter.

---

## 4. (d) Loop flag / completion-event wiring to animation *choice* in native structures [O]

What IS wired natively (all CODE `[O]`, P6/P7/P14):

- **Loop vocabulary:** `acmNone/acmPlayOnce/acmLoop@0x512008` + `aamNone/aamPlayOnce/aamLoop/aamBounceForward/aamBounceBackward/aamLoopBackward/aamExternal@0x4f6d00/0x511f00` + property row `AnimationMode@0x550d80` + `Get/SetGameObjectAnimationCyclesModeByHandle(gohandle): String` / `Get/SetGameObjectMyAnimationCyclesMode(animationcyclesmode: String)@0x63b600`. The script `acmPlayOnce/aamPlayOnce` writes (state-map ev_P2f: `DoDeath`, `stage_0`) target this enum — now byte-anchored, not just script tokens.
- **Per-item once counter:** `NumberCycle@0x86da04/0x86e408` + controller flags `acoSkipActions@0x86def4, acoRandomCycle, acoRandomFrame, acoSmoothAnimation@0x86df3c` + `CyclesMode` get/set (`0x63b66c/0x63b6c4/0x63b73a/0x63b77a`). The ACL `NumberCycle=1` / `CyclesList=False` attack shape (state-map §1.3) is the file-level authoring of this counter.
- **Completion-event wiring — by state-name STRING, not by loop flag `[O]`:** the `0x63b700–0x63ea00` signature block exposes the full family, each as `ByHandle(gohandle): String` getter + `ByHandle(gohandle; state: String)` setter (+ `My` twins):
  `OnStateEndCyclesReached`, `OnStateStartCyclesReached`, `OnStateEndFrameReached`, `OnStateStartFrameReached`, `OnStateFBEndCyclesReached` (4 hits `0x63e955–0x63ea57`), `OnStateFrameChanged`, `OnStatePointChanged`, `OnStateEndPointReached`, `OnStateDistanceToPoint(gohandle; state: String; distance: Float)`, plus property row `OnFrameChanged/OnEndFrameReached/OnStartFrameReached@0x550d80`. The unit path arms NONE of them (state-map §3.1: `DoDeath` blanks all four `OnState*Reached` handlers; no non-empty `SetGameObjectOnStateEndCyclesReached` write found on the unit path) — death advances via delayed `DeathStage1`, attacks via ACL `...Attack/AttackEnd` item brackets, everything else via tag re-evaluation.

What is NOT wired to *choice* `[D]`:

- No native structure maps `AnimationMode`/`NumberCycle`/`aco*` back to a *name* selection. The loop flag governs **how the current item plays** (once/clamp vs loop) and the completion wiring governs **which script state runs next** (`ExecuteStateName→ExecuteStateIndex`, `OnState*Reached(state: String)`), but the **which-animation-for-which-unit-state** decision stays exclusively in the script selector (`DoSetupMoveAnimation` T1–T26). Put bluntly: the exe knows how to *finish* an animation, never which one to *start* for a given weapon/carry/order — that table does not exist in CODE.
- `DeferredFrameBlend/Boolean + DeferredFrames(defcurrent,defstart,defend)@0x630600` triple exists natively but the script installs `Deferred(false)` (`initial.inc:17-19`, state-map ev_P6b), so it is unarmed on the unit path — recorded, not wired.

---

## 5. Still-[U] fields — state-transition / frame-trace captures with zero-mismatch termination

U2 as inherited from `DEC_U_state_map` §4: the **script-side** rows T1–T26 are closed, but the **live-engine proof** (does the running sim actually present the tags that fire each row, and does the displayed clip follow?) stays open for work/carry/reaction and for weapon→`attack1`/`attack2`. Nothing in §§1–4 above closes them — the native passes prove *where the answer is NOT* (no CODE table, no extra arg, no flag-driven choice), so each field below gets a runner-side capture. **No capture is executed by this worker** (donor binary never run); captures are specified for the runner owner. **Zero-mismatch termination**: every listed trial must match exactly tick-for-tick and frame-for-frame; ONE divergent tick/hash/selected-name fails the capture and the `[U]` stays open, logged, never smoothed over.

- **[U]-W (weapon/order → `attack1`/`attack2`; bullet⇔`iWeapon=1` unproven). Capture R-W:** fixed camera on musketeer (`attack1 99..124`) and grenadier (`attack0 126..141`, `attack1 99..114`, `attack2before 630..663` / `attack2after 664..679`) each ordered to attack a ground target and an enemy unit; per-tick log `(sim_tick, tag_fields(iAction/iWeapon/iMove/iResource/iEssential/iVisual), selected_anim, AAF first..last, requested_frame, sample_frame, blend_delta, within_window, engine_state)`. Vary only ammo/weapon-upgrade state. **Termination:** `attack1` fires iff `iWeapon=1` observed ≥3/3 trials per sid AND `attack2before→attack2after` sequence observed on grenade order or its absence logged with the exact order-scale used; else stays `[U]`. Native §§1–3 contribute the negative guardrail: no exe `attack1` literal and no weapon formal exist, so a positive must come from the tag dump, never from bytes.
- **[U]-W2 (death`0/1/2` by weapon at death). Capture R-W2:** kill armed (musketeer `death0 564..628`) and unarmed (peasant `death 115..149`) units on fixed camera; log `iWeapon` at death tag + `selected_anim` + desync factor (`0.7+random*0.6`). **Termination:** weapon-death token observed ≥2/2 armed trials with fallback logged when the sid lacks the row, or absence logged.
- **[U]-WC (carry → `idle*/walk*/work*` liveness). Capture R-WC:** peasant gather→carry→drop cycle per resource (food/wood/stone) on fixed camera; log `(iResource, iMove, selected_anim)` per tick across pickup, walk-loaded, drop, walk-empty seams. **Termination:** full `work*` (early-out `0,0`) → `idlefood/idlewood/idlestone` → `walkfood/walkwood/walkstone` sequence observed ≥2/2 trials per resource with `SwitchTo('Nothing')` re-dispatch visible between rows (handler tick), or the exact missing link logged; else stays `[U]`.
- **[U]-S (sticky readback T18–T20 dwell). Capture R-S:** musketeer attack→idle seam at 30 Hz; record `GetGameObjectFrameAnimationNameByHandle` per tick for 90 ticks post-attack; check whether any `attack1/trans*/prepare1` name persists ≥1 tick before `idle1`. **Termination:** sticky name observed with count, or 3 clean attack→idle seams with zero intermediate names logged. Port keeps stateless recompute until then.
- **[U]-A (`prepare*/unprepare*/trans*/walkprepare*` entry triggers). Capture R-A:** order stance changes, formation joins/leaves, cavalry mount/dismount-adjacent orders on fixed camera; log selected anim per tick. **Termination:** ≥1 reproducible trigger per token family with tag fields, or explicit absence log after exercising all stance/formation orders.
- **[U]-R (`reaction` trigger). Capture R-R:** expose peasants to raids, nearby deaths, combat start/end, construction complete, idle long-tail (≥120 s) on fixed camera with full tag dump; log any `reaction` selection. **Termination:** one reproducible trigger with tag fields, or absence logged across the full battery (token stays export-only, never auto-triggered). Native §1.1 hardens the orphan verdict: zero `reaction` constant/handler/ACL-row/EXE-literal across all four stores.
- **[U]-C1 (PlayOnce end behaviour for `attack*/death*`). Capture R-C1:** musketeer `attack1 [99,124]` single shot, frame-index trace at 30 Hz from `t0` to `t0+span+10` frames; record hold-at-`124` vs snap-to-`idle1 [256,305]` tick-aligned vs mid-blend freeze; repeat for peasant `death [115,149]`. **Termination:** hold-vs-return verdict with tick numbers, 3/3 trials, zero mismatch. Native §4 names the mechanism under test (`AnimationMode=aamPlayOnce/acmPlayOnce` + `NumberCycle=1` + unarmed `OnStateEndCyclesReached`) without predicting its visible outcome.
- **[U]-C2 (ACL `...AttackEnd` effects incl. cannon). Capture R-C2:** cannon `attack0/attack1 [301,337]` firing on fixed camera; log muzzle-flash PFX attach frame, damage tick, sound tick relative to `...Attack` (opening) vs `...AttackEnd` handler firing ticks; cross-check `_unit_TryAttack` re-issue. **Termination:** effect-to-frame offsets with 3-trial repeat, or absence logged.

---

## 6. Deltas vs prior reports

| # | Prior statement | This-pass verdict |
|---|---|---|
| D1 | State-map §1–§2: T1–T26 rows, `Nothing` hub, Work/Construct/Attack as completion events | CONFIRMED and bounded natively: `Nothing`/`OnAclAnimationReached*` have zero CODE presence (§1.1) — they are script/ACL-text-only by byte-proof, not just by text-search absence |
| D2 | State-map §4 [U]-W/W2/S/A/R/C1/C2/B/T | NARROWED: native passes eliminate three hoped-for shortcuts — no CODE state table (§2), no weapon/carry formal (§3), no flag-driven choice (§4). Remaining closes are runner captures R-W/R-W2/R-WC/R-S/R-A/R-R/R-C1/R-C2 in §5 |
| D3 | Blend-deep CODE-embedded-table method (strings-index vs bytes-find, table VAs) | REUSED and extended: same pattern reproduces for the selector vocabulary (`SwitchTo` 38 CODE vs 0 strings; `ExecuteState` 37 vs 0; `AnimationName` 13 vs 0); new VAs `0x4ab39d/0x511f00/0x630100/0x636200/0x63b600–0x63ea00/0x86d800–0x86e800` |
| D4 | AAF art audit 194-file census (tokens live in `.aaf`, `aarMorph` only flag) | CONFIRMED natively: AAF token literals (`workfood/attack0/attack1/death0/idlefood/walkfood`) 0 hits in exe (§3); `aarMorph` byte-listed at `0x4f6d66` without any state binding (§1.2) |
| D5 | Orphan verdicts (`attack2before/after`, `reaction`, `prepare*/trans*` readback-only) | HARDENED: fourth store (packed exe) also clean — no `reaction`/token literals, no `...AttackEnd`-handler bodies, `From`-key with no native field (§§1–2) |

---

## 7. Exact port change list (file/line; no code written here) [O]

Each row: port site `[O]`, donor fact (this job `[O]`/`[D]`), required donor-faithful replacement. No row implemented. No parity claimed. Rows outside this worker's ask (blend operator, orders, building visuals, `anim_action` producers) are NOT restated.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement |
|---|---|---|---|
| F1 | `P:scripts/world3d_entities.gd` `_donor_weapon_index` + attack chain; `P:scripts/anim3d.gd` `resolve_donor_trigger/action` | Native selector takes `(gohnd, name, random*, min/max)` ONLY — no weapon/carry formal (§3, `0x630100/0x642e00` prototypes) | KEEP weapon→`attack0/1/2` resolution on the script side; NEVER add an engine-side weapon argument; keep `bullet→attack1` labelled fallback `[U]-W` until R-W proves the index equivalence |
| F2 | Same carry chain (`_donor_resource_suffix`, res×move matrix) | AAF carry/work token literals absent from exe (0 hits, §3); selection is script `iResource×iMove` branches | KEEP carry resolution script-side; add the R-WC link log (which of `work*→idle*→walk*` fired per tick) once the runner lands it; until then keep the chain + gap records |
| F3 | Sticky `last_anim` / readback branches (dormant) | No native `From`-keyed table exists (§2: item chain is `AnimationName+NumberCycle / ExecuteStateName+Index`, never state→name) | Do NOT invent a native-side sticky/dispatch table; wire the one-slot `last_anim` readback ONLY after R-S proves dwell (state-map F8), reading script `current_anim`, never a native field |
| F4 | `anim_action` explicit hook + orphan allow-list | `Nothing`/`OnAclAnimationReached*`/`reaction`/token literals all zero in CODE (§1.1/§3); `From` has no native field (§2) | KEEP orphans (`reaction`, `attack2before/after`, `prepare*/trans*`) explicit-`anim_action`-only + availability-gated + gap-recorded; cite this report's VAs in the orphan comment as the fourth-store proof |
| F5 | Completion/once handling (`_is_once_action`, clamp, gap chains) | Native loop vocabulary (`aam*/acm*@0x511f00/0x4f6d00`, `AnimationMode@0x550d80`, `NumberCycle/aco*@0x86da04/0x86def4/0x86df3c`) + string-keyed completion setters (`OnState*Reached(gohandle; state: String)@0x63b700–0x63ea00`) govern *how-long / what-next*, never *which-animation* (§4) | KEEP clamp-at-last with `[U]-C1/C2` labels; add the completion-string hook point ONLY when R-C1/R-C2 land; never branch animation *choice* on `AnimationMode`/`NumberCycle`/`aco*` |

Required donor asset manifest (all already on disk; sourced only through the approved converters, **not copied here**): `cossacks.exe` VAs `0x4ab39d/0x4f6d00/0x4f6e36/0x511f00/0x512008/0x550d80/0x62fd00–0x630700/0x636200/0x63ac00/0x63b600–0x63ea00/0x642e00/0x86d800–0x86e800` (ev ids §0.1) + `D:scripts/lib/unit.script:10837-11104` + `D:scripts/units/unit.aix:130-152` + `D:scripts/units/unit.inc/{nothing.inc:1-13,ontagstates.inc:166-516,onaclanimationreachedattack.inc:1-155,onaclanimationreachedattackend.inc:1-18,onaclanimationreachedwork.inc:1-62,onaclanimationreachedconstruct.inc:1-54}` + `D:animations/acl/*.acl` (peasant/cannon/ship/cavalry/infantry blocks) + `D:animations/aaf/*.aaf` (194 files) + `D:scripts/dmscript.global:868-926` + `D:gui/menu.inc/showdebuganimations.inc`.

---

## 8. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `SwitchTo` 38 CODE hits (`0x62fd8e–0x643272` + regions) are script-API prototypes, never a state→name table | [O] ev_ed95bd3d + P12 windows |
| 2 | `Nothing` 1 hit `0x4ab39d` is `TRegExpr … Follows Nothing`, not the engine state; `OnAclAnimationReached{Work,Attack,Construct}` 0 hits | [O] P2/P4 (absence with packed-region reserve) |
| 3 | `acmPlayOnce@0x512008`, `TActorAnimationMode@0x4f6e36`, `TActorAnimationReference@0x4f6d66` byte-anchored in enum/RTTI tables | [O] P3/P4 |
| 4 | ACL dispatcher native shape: `acsa*` + `act*` + `TXAnimationCycleItem{AnimationName,NumberCycle,…,ExecuteStateName,ExecuteStateIndex,…}` + `aco*` + controller; NO `From`-key field, direction item→state | [O] P5–P7/P14 (`0x86d800–0x86e800`) |
| 5 | Selector prototypes take `(handle, name, random*, min/max)` only; `Weapon/weapind/statetag/carry/iResource` 0 hits; AAF tokens (`workfood/attack0/attack1/death0/idlefood/walkfood`) 0 hits | [O] P8/P11/P12 (byte-proven, packed reserve noted) |
| 6 | `Work/Attack/Construct` generic hits resolve to VCL/ComCtrls/formation/wall subsystems; `construct` pair to DMScript keywords — none animation-related | [O] P9/P10 (exclusion by window) |
| 7 | Loop/completion natives: `aam*/acm*`, `AnimationMode`, `NumberCycle`, `aco*`, `CyclesMode`, `OnState{End,Start}{Cycles,Frame}Reached` + `FB/Distance/Point` family keyed by `state: String`; unit path arms none; they drive duration/continuation, never choice | [O] P6/P7/P14 |
| 8 | Data-section strings index 0 for `SwitchTo/ExecuteState/AnimationName` vs CODE dozens — CODE-embedded-table pattern reproduced | [O] P13 ev_f29c26ac/ev_9f6f81de |
| 9 | Every remaining `[U]` (W/W2/WC/S/A/R/C1/C2) has a named fixed-camera state-transition/frame-trace capture with zero-mismatch termination | [D] §5 |
| 10 | Any port motion equalling donor timing/pose/blend, any trigger claimed without a §1–§4 cite, or any runtime PASS | **Denied** — no same-camera donor/port A/B exists; visual UNVERIFIED |

## 9. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) and the read-only `C:\Games\Cossacks 3\data` script tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-STATE-DEEP.*
