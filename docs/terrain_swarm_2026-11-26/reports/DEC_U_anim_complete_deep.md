---
id: DEC-U-ANIM-COMPLETE-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-ANIM-COMPLETE-DEEP — attack-end / PlayOnce completion from NEW byte angles (packed CODE search, ACL dispatch arity, PlayOnce end-rule, firing ticks)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_anim_complete_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep/Ghidra engine active, shared Craft Anything session). Every native call pinned with document=t_87f0f3c130b0. Binary never executed."
port_scope: "variant3d/scripts/anim3d.gd cited read-only only where it owns the [U] fields; NOT edited, NOT re-specified."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_op.md (ACL tree/NumberCycle, OnAclAnimationReachedAttack body, AttackEnd re-attack gate; C1 PlayOnce end behaviour and C2 handler firing ticks [U]; no armed EndCyclesReached handler)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_deep.md (CODE-embedded RTTI/API tables, afp/aam/acm enums, 8-arg native labels, K1/K2 candidates, per-tick player NOT localized [U]-P1)
---

# DEC-U-ANIM-COMPLETE-DEEP — completion from NEW byte angles

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0`, not port test ids. "Address" = donor VA (`0x…`) for binary hits, `path:line` for donor text.
> Context carried: `DEC_U_blend_op` recovered the script-side `Attack` body and `AttackEnd` = `_unit_TryAttack` re-attack gate, but C1 (PlayOnce end behaviour) and C2 (handler firing ticks) stayed `[U]` with no armed `EndCyclesReached` handler on the unit path. This worker attacks the same unknowns from NEW byte angles and keeps them `[U]` unless bytes prove otherwise.

## 0. Method, labels, passes

### 0.1 Pass ledger (multiple NEW passes on the pinned packed exe, not script text)

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_bytes_find` text `EndCyclesReached` | ev_fa02c9cc421d00ac96cf60db6db8697870137e83faa28e9b7fe713b9f30afe88: **8 matches, all in CODE**, VAs `0x63b7ce / 0x63b82a / 0x63b894 / 0x63b8d8 / 0x63e95e / 0x63e9a6 / 0x63e9f4 / 0x63ea60` [O] §1 |
| P2 | `native_bytes_find` text `OnAclAnimationReached` + `...Attack` + `...AttackEnd` + `...Work` | ev_a76a5f2f08db94c15d1a2ad72a9bee6b34a2080f893e62b5c6a87d78e9197dd7 (21-char stem) + ev_a42f9947 / ev_e4fb4ef50 / ev_4d739fe5: **0 matches each** — no `OnAclAnimationReached*` string in exe bytes [O] §1 |
| P3 | `native_bytes_find` text `NumberCycle` | ev_38df74ad94ac4a085f107277810a92e15efaeadd38953483897cf24a26c4c80: **2 matches**, `0x86da04 / 0x86e408`, both CODE [O] §1/§2 |
| P4 | `native_bytes_find` text `PlayOnce` + `acmPlayOnce` + `aamPlayOnce` | ev_36018201 (PlayOnce ×5: `0x4f6e62 / 0x511f73 / 0x51200b / 0x7ebeaf / 0x7ece77`); ev_ed38d770 (`acmPlayOnce` ×1: `0x512008`); ev_a9953579 (`aamPlayOnce` ×2: `0x4f6e5f / 0x511f70`) [O] §1 |
| P5 | `native_bytes_find` text `FrameInterpolation` | ev_c0cf4790e989f86c32eb4f7d6487f117258c5b9bd8a29eb2d0376a4edcdf49db: **6 matches** `0x4f6dd8 / 0x550daf / 0x561a74 / 0x561fac / 0x564120 / 0x564f70` [O] §1 |
| P6 | `native_bytes_find` `acsaDefault / acsaFirst / acsaRandom / actAnimation / actTrackPoint / actExecuteState / AnimationMode / CurrentFrameBlend / TActorAnimationMode` | ev_8728a74f (`acsaDefault` ×2 `0x86d85c/0x86df58`); ev_c79fda3d (`acsaFirst` ×2); ev_e1b7fe7e (`acsaRandom` ×2); ev_42058b59 (`actAnimation` ×2 `0x86d8b6/0x86de90`); ev_8821c153 (`actTrackPoint` ×4); ev_313e6df8 (`actExecuteState` ×2); ev_160156d5 (`AnimationMode` ×19); ev_e66834e8 (`CurrentFrameBlend` ×3 `0x550ddc/0x62f747/0x62f7a3`); ev_b3527d2e (`TActorAnimationMode` ×1 `0x4f6e36`) [O] §1/§2 |
| P7 | `native_bytes_find` `ExecuteStateName / OnFrameChanged / OnEndFrameReached / OnStartFrameReached / SwitchAnimation / EndFrameReached / StartCyclesReached / FBEndCyclesReached / TXAnimationController / acoSkipActions` | `ExecuteStateName` ×4 (`0x63c528/0x660847/0x86db7e/0x86e4a4`); `OnFrameChanged` ×3 (`0x550eef/0x7ec261/0x7eca8f`); `OnEndFrameReached` ×3 (`0x550f18/0x7ec28a/0x7ecab8`); `OnStartFrameReached` ×3; `SwitchAnimation` ×1 (`0x86d83f`); `EndFrameReached` ×7; `StartCyclesReached` ×4; `FBEndCyclesReached` ×4 (`0x63e95c/0x63e9a4/0x63e9f2/0x63ea5e`); `TXAnimationController` ×2 (`0x86d82a/0x86de73`); `acoSkipActions` ×1 (`0x86def4`) [O] §1/§2 |
| P8 | `native_bytes_find` text `OnStateEndCyclesReached` | ev_53ad5bf884582fa4e7c049502f4e71f620e02739a6b756cebcea846c4e24c9bd: **4 matches** `0x63b7c7 / 0x63b823 / 0x63b88d / 0x63b8d1` [O] §1 |
| P9 | `native_bytes_show` `0x63b700+512 / 0x63b800+512 / 0x63e900+768 / 0x86d800+800 / 0x86de00+800` | ev_2086f5..., ev_c33c2bc1, ev_3fbebbf9, ev_167ec7d4, ev_d868b929: full script-API prototype strings for the End/StartCycles + FBEndCycles families + ACL enum/dispatch tables [O] §1/§2 |
| P10 | `native_bytes_show` `0x4f6d00+512 / 0x511f00+512 / 0x7ebe00+512` | ev_07e41268 (`TActorAnimationReference/FrameInterpolation/Mode` enums), ev_ec92c9d2 (`aam*/acm*/mm*/trm*` enum table), ev_0c762459 (`sam*` sprite mode table — not unit path) [O] §1/§3 |
| P11 | `native_bytes_show` `0x550c00+600 / 0x550d00+600 / 0x550900+600 / 0x86da00+600 / 0x86d880+600 / 0x63b8d0+512 / 0x63e9a0+512 / 0x63ab00+768 / 0x550e00+640 / 0x7ec100+768 / 0x63c500+512 / 0x660800+512` | ev_82bc5d18 / ev_35740440 / ev_2f81a07e (BaseActor prop table: `CurrentFrame/DirectCurrentFrame/CurrentFrameDelta/FrameInterpolation/Current-Start-EndFrameBlend/AnimationMode/Interval/OrignInterval/Options/OnFrameChanged/OnEndFrameReached/OnStartFrameReached`); ev_5ff556f8 (CycleItem tail: `ExecuteStateName/ExecuteStateIndex/OwnerCycles`); ev_90551288; frame/state API twins [O] §2/§3 |

**Strange-read log:** `OnAclAnimationReached*` zero-hit is a whole-file byte fact under the engine's stated limit ("compressed, encrypted or packed regions… are not seen, so no match is not proof of absence") — read as absence-of-string-evidence, never as proof the handler is dead (the handler bodies live in donor script text per `DEC_U_blend_op` ev_B9). `native_bytes_show` ASCII is RTTI/API table text, not disassembled code — no tick loop, no branch, no counter is observed in any window opened here. No donor binary executed; no donor bytes copied.

---

## 1. (a) — packed CODE byte search: completion/mode names with VAs [O]

All hits are CODE-section (`section: CODE`), i.e. CODE-embedded tables invisible to a data-section string index (same phenomenon as `DEC_U_blend_deep` P2/P5). File offsets are `0x…` in `cossacks.exe`; VAs are exact.

### 1.1 Completion / state-hook names

| Text searched | Result [O] | VAs / file offsets |
|---|---|---|
| `EndCyclesReached` (16 chars) | 8 matches | `0x63b7ce (@0x23abce) / 0x63b82a / 0x63b894 / 0x63b8d8 / 0x63e95e (@0x23dd5e) / 0x63e9a6 / 0x63e9f4 / 0x63ea60` |
| `OnStateEndCyclesReached` (23 chars) | 4 matches (subset of the 8) | `0x63b7c7 (@0x23abc7) / 0x63b823 / 0x63b88d / 0x63b8d1` |
| `FBEndCyclesReached` | 4 matches (the other 4) | `0x63e95c (@0x23dd5c) / 0x63e9a4 / 0x63e9f2 / 0x63ea5e` |
| `StartCyclesReached` | 4 matches | `0x63b926 / 0x63b982 / 0x63b9f0 / 0x63ba38` (P7) |
| `EndFrameReached` | 7 matches | `0x550f1a / 0x63ac5e / 0x63acba / 0x63ad24 / 0x63ad68 / 0x7ec28c / 0x7ecaba` (P7) |
| `OnAclAnimationReached` (stem, 21 chars) | **0 matches** | — (ev_a76a5f2f) |
| `OnAclAnimationReachedAttack` / `...AttackEnd` / `...Work` | **0 matches each** | — (ev_a42f9947 / ev_e4fb4ef50 / ev_4d739fe5) |

[D] consequence: the **state-side** completion hooks (`OnStateEndCyclesReached / OnStateStartCyclesReached / OnStateFBEndCyclesReached / OnStateEndFrameReached / OnStateStartFrameReached / OnStateFrameChanged`, each with `ByHandle(gohandle; const state: String)` + `My(const state: String)` twins at `0x63ab00–0x63ba38` / `0x63e900–0x63ea60`, ev_2086f5…/ev_c33c2bc1/ev_3fbebbf9) are byte-anchored API names. The **ACL-side** completion names (`OnAclAnimationReachedAttack / AttackEnd / Work / Construct`) have **zero byte presence** in the exe — consistent with `DEC_U_blend_op` ev_B9 (they are script-`inc` procedure names invoked via `actExecuteState{ExecuteStateName=…}` in `.acl` text, not engine exports). No firing-tick table accompanies either family in any window opened here.

Full prototype strings observed (exact, `0x63b700` ev_2086f5… / `0x63b800` ev_c33c2bc1) [O]:

```
function GetGameObjectOnStateEndCyclesReachedByHandle(gohandle: Integer): String
procedure SetGameObjectOnStateEndCyclesReachedByHandle(gohandle: Integer; const state: String)
function GetGameObjectMyOnStateEndCyclesReached(): String
procedure SetGameObjectMyOnStateEndCyclesReached(const state: String)
... (same quad for StartCyclesReached at 0x63b8d0 ev_e9202dc5, FrameChanged/EndFrameReached/StartFrameReached at 0x63ab00, FBEndCyclesReached at 0x63e900 ev_3fbebbf9)
procedure GameObjectDelayExecuteStateByHandle(gohandle: Integer; const state: String; ftime: Float)   # 0x63c500 ev @0x63c500
```

[D]: every completion hook is a **parameterless-on-read, single-String-on-write** script slot (`state: String`, empty string = disarm). No tick, frame-index, or count parameter exists in any prototype — the API itself cannot name a firing tick. `DelayExecuteState(state; ftime: Float)` is the only time-parameterised execute path found, and no call site arming it for `Attack/AttackEnd/Work/Construct` was found in these passes.

### 1.2 Mode / interpolation names

| Text | Hits [O] | VAs |
|---|---|---|
| `PlayOnce` | 5 | `0x4f6e62 / 0x511f73 / 0x51200b / 0x7ebeaf / 0x7ece77` |
| `acmPlayOnce` | 1 | `0x512008 (@0x111408)` |
| `aamPlayOnce` | 2 | `0x4f6e5f (@0xf625f) / 0x511f70 (@0x111370)` |
| `FrameInterpolation` | 6 | `0x4f6dd8 (@0xf61d8) / 0x550daf / 0x561a74 / 0x561fac / 0x564120 / 0x564f70` |
| `TActorAnimationMode` | 1 | `0x4f6e36 (@0xf6236)` |
| `AnimationMode` | 19 | `0x4f6e3c / 0x550e5a / 0x5640ac / 0x564efc / 0x6365b1 / 0x6365eb / 0x63663d / 0x636687 / … / 0x841974` (showing 19) |
| `CurrentFrameBlend` | 3 | `0x550ddc (@0x1501dc) / 0x62f747 / 0x62f7a3` |

Enum contents at the VAs (exact ASCII, P10) [O]:

- `0x4f6d00` (ev_07e41268): `TActorAnimationReference: aarMorph, aarSkeleton, aarNone, aarTransform` / `TActorFrameInterpolation: afpNone, afpLinear, afpSkin, afpLSkin` / `TActorAnimationMode: aamNone, aamPlayOnce, aamLoop, aamBounceForward, aamBounceBackward, aamLoopBackward, aamExternal`
- `0x511f00` (ev_ec92c9d2): `aamNone / aamPlayOnce / aamLoop / aamBounceForward / aamBounceBackward / aamLoopBackward / aamExternal / acmNone / acmPlayOnce / acmLoop / mmNone / mmDoTrackOnce / mmDoTrackListLoop / mmDoTrackListBounceForward / mmDoTrackListBounceBackward / mmDoTrackPosition / trmNone / trmToTargetObject`
- `0x7ebe00` (ev_0c762459): `TSpriteAnimationMode: samNone, samPlayOnce, samLoop, samBounceForward, samBounceBackward, samLoopBackward` (sprite family — **not** the unit path; cited to prevent cross-family confusion)

[D]: `aamPlayOnce / acmPlayOnce` are byte-anchored enum members in two independent tables (`0x4f6d00`, `0x511f00`); `aamBounce* / acmLoop / mm* / trm* / sam*` exist natively with zero unit-script writers (carried from blend-deep). No table pairs a mode with an end-rule (clamp/return/event) — the end-rule is not in the enum bytes.

---

## 2. (b) — ACL dispatch table `acsa*` / `act*`: completion-callback slot and its arity [O]

### 2.1 The two adjacent tables (both CODE, both byte-verified)

**Table T1 — enum definitions at `0x86d82a–0x86d900`** (ev_167ec7d4, 800 B at `0x86d800`):

```
TXAnimationControllerSwitchAnimation … acsaDefault.acsaFirst.acsaRandom
TXAnimationCycleItemAction … actAnimation.actTrackPoint.actTrackPointPreset.actExecuteState
```

Exact enum cardinalities [O]: `acsa*` = **3** members; `act*` = **4** members. `SwitchAnimation` occurs ×1 (`0x86d83f`). `TXAnimationController` occurs ×2 (`0x86d82a / 0x86de73`).

**Table T2 — controller/field descriptors at `0x86de00–0x86e500`** (ev_d868b929, 800 B at `0x86de00` + ev_5ff556f8 at `0x86da00` + ev_90551288 at `0x86d880`):

```
TXAnimationController … actAnimation … actTrackPoint … actTrackPointPreset … actExecuteState …
  acoSkipActions … acoRandomCycle … acoRandomFrame … acoSmoothAnimation …
  acsaDefault … acsaFirst … acsaRandom … [code follows]
```

**Item record `TXAnimationCycleItem` field order** (exact prop-name sequence across ev_167ec7d4 / ev_90551288 / ev_5ff556f8) [O]:

```
AnimationName | NumberCycle | AnimationIndex | Action
| TrackPointMoveStep | TrackPointTurnStep | TrackPointIdleName
| TrackPointPreset | TrackPointPresetName | TrackPointMode
| ExecuteStateName | ExecuteStateIndex
| OwnerCycles
```

### 2.2 Arity verdict [D over cited bytes]

- `acsaDefault / acsaFirst / acsaRandom` is a **3-valued selector enum**, not a callback slot. It carries no parameter list in either table (bare `0a`-separated names, no parens, no type words). It selects *which cycle* of a multi-cycle item runs (default/first/random — names only; the selection function is not in the table bytes). **It is not a completion callback and has no arity.**
- `actAnimation / actTrackPoint / actTrackPointPreset / actExecuteState` is a **4-valued item-action discriminator** (`Action` field). Only one payload family is live per item, selected by `Action`.
- The **completion-callback slot** is the `actExecuteState` payload: **`ExecuteStateName: String + ExecuteStateIndex: Integer`** — arity **2** (one script-name string written in `.acl` text, e.g. `ExecuteStateName=OnAclAnimationReachedAttack`, plus one integer index resolved by the engine). Byte evidence: both names are adjacent properties in the item record (`ExecuteStateName..@.0...0` / `ExecuteStateIndex` at `0x86da00` ev_5ff556f8); the script-API twin `DelayExecuteStateByHandle(gohandle; const state: String; ftime: Float)` (arity 3: handle+name+time, `0x63c500`) is the only other `ExecuteState`-shaped entry point found.
- `NumberCycle` (×2: `0x86da04 / 0x86e408`) is the repeat-count field of the `actAnimation` payload (arity: integer count; `DEC_U_blend_op` ev_B8: `1` everywhere sampled except balloon-0 / horse-idle-10). It is **not** a callback and does not name a firing tick.
- `acoSkipActions / acoRandomCycle / acoRandomFrame / acoSmoothAnimation` (T2 tail) are per-block Boolean options, not callbacks (no parameter lists in bytes).

What is **not** in the tables (honest negative) [O-absence with packed-region reserve]: no `OnCompletion / OnEnd / Callback / FireAt / FireTick / EndFrame` property name occurs in either 800 B window; `native_bytes_find` for `EndCyclesReached` hits the *script-API* region (`0x63b7xx/0x63e9xx`), never the ACL dispatch region (`0x86d8xx–0x86e4xx`). The dispatch bytes therefore prove the slot *shape* (which string goes where) but contain **no firing-tick rule and no per-tick sequence** — ticks stay [U] §4.

---

## 3. (c) — does `PlayOnce` clamp at last frame, return to first, or fire an event? — from bytes only

### 3.1 What the bytes prove [O]

1. `aamPlayOnce / acmPlayOnce` exist as enum members (two tables, §1.2). `aamBounceForward / aamBounceBackward / aamLoopBackward / aamExternal / sam*` also exist with no unit writers — mode existence ≠ mode semantics.
2. The `TXBaseActor` property table (`0x550c00–0x550f44`, ev_82bc5d18 / ev_35740440 / `0x550e00` 640 B) gives the **complete frame-event register file** in fixed order [O]:
   ```
   StartFrame | EndFrame | DirectStartFrame | DirectEndFrame | Reference
   | CurrentFrame | DirectCurrentFrame | CurrentFrameDelta (Float)
   | FrameInterpolation | CurrentFrameBlend | StartFrameBlend | EndFrameBlend
   | AnimationMode | Interval | OrignInterval ("Orign", sic) | Options
   | OnFrameChanged | OnEndFrameReached | OnStartFrameReached
   | Animations | AutoCentering | MaterialLibrary | LightmapLibrary | …
   ```
   The sprite twin (`0x7ec100`, 768 B) repeats `AnimationMode … OnFrameChanged / OnEndFrameReached / OnStartFrameReached …` — same triple, different family.
3. The script-API region gives the **writable** side of the same triple for states (`0x63ab00` 768 B: `Get/SetGameObjectOnStateFrameChanged… / OnStateEndFrameReached… / OnStateStartFrameReached…`, each `ByHandle(gohandle): String` + `My(): String`); and the cycles side (`0x63b700–0x63ba38`: `…MyAnimationCyclesMode… / OnStateEndCyclesReached… / OnStateStartCyclesReached…`; `0x63e900`: `…MyOnStateFBEndCyclesReached…`).
4. No window opened in P1–P11 contains a clamp opcode, a wrap opcode, a last-frame-hold flag, a return-to-first flag, or a `FireAtFrame = N` integer beside any `PlayOnce` occurrence. `native_bytes_find` for `PlayOnce` lands in enum tables only (`0x4f6d00 / 0x511f00 / 0x7ebe00` context) — never beside a rule.

### 3.2 Verdict: UNRESOLVED from bytes [U]-C1 (no invented rule)

[D] over §3.1: the bytes prove *that* a `PlayOnce` mode and *three* frame-event slots (`OnFrameChanged / OnEndFrameReached / OnStartFrameReached`) and *three* state-cycle slots (`…EndCyclesReached / …StartCyclesReached / …FBEndCyclesReached`) exist and are writable with a single `String` each — but they do **not** state what the engine does at the last frame of a `NumberCycle=1 PlayOnce` item between tag evaluations (hold last vs return to first vs auto-fire). Specifically excluded by structure: the end-rule is not an enum member (no `aamClamp / aamHold / aamReturn` string exists in either enum table), not a property (no such flag in the `0x550c00` register list), and not a second API parameter (all setters take exactly `(gohandle; const state: String)`).

Carried unit-path fact (donor script, from `DEC_U_blend_op` ev_B10, not re-read here): the unit path **disarms** all four state-cycle slots (`OnStateEndCyclesReached('')` cleared at `unit.script:10812-10813`, `ontagstates:180-181`, `initial:163`; `OnStateFBEndCyclesReached('')` likewise; `OnStateEndFrameReached('')` at `initial:14/env:11`). So even though the slots exist natively, **no armed `EndCyclesReached` handler is present on the unit path** — completion signalling, if any, must come through the ACL `actExecuteState` slot (§2), whose firing tick is itself unrecovered (§4). Whether the pose holds or snaps between evaluations is therefore still engine-internal.

- **[U]-C1 stays open.** Capture R-C1 §5 decides hold-vs-return with tick numbers; no clamp/return/event is asserted here.

---

## 4. (d) — exact firing ticks for Attack / AttackEnd / Work / Construct: NOT in bytes [U]-C2

### 4.1 What was searched and what came back [O]

- Whole-file `OnAclAnimationReached*` (stem + three full handler names): **0/0/0/0** hits (P2). The four `ExecuteStateName` hits that DO exist are the *slot definition* (`0x86db7e / 0x86e4a4` in the ACL tables) and the *delay API* (`0x63c528 GetGameObjectDelayExecuteStateNameByHandle / 0x660847 GetGroupDelayExecuteStateNameByHandle`) — none is a per-handler firing record.
- No `FireTick / FireAtFrame / AttackTick / DamageTick / HitFrame / MuzzleTick` string was found in any window; no integer run beside an `ExecuteStateName` occurrence names a tick (adjacent bytes are the next property name, per ev_5ff556f8 ASCII).
- Handler bodies are carried from `DEC_U_blend_op` ev_B9 (read-only donor script, not re-read here): `Attack` = weapon-index decode → cost/pause → melee-damage OR immediate-PFX/projectile OR aimed-projectile; `AttackEnd` = `_unit_TryAttack` retrigger + `SwitchTo('Nothing')`; `Work/Construct` = resource-hp/build-progress + sound + `SwitchTo('Nothing')`. Bodies give *order* (effects ride on opening `Attack`; end is a re-attack gate) but **no tick**.
- The AAF side gives clip bounds only (e.g. cannon `attack0/attack1 [301,337]` per blend-op; musketeer `attack1 [99,124]`; peasant `work*/death [115,149]`-family) — bounds are not firing ticks.

### 4.2 Verdict: firing ticks UNRESOLVED [U]-C2a/b/c/d (no invented tick)

No byte-proven mapping exists from any `.acl` item (`actAnimation{…,NumberCycle=1}` bracketed by `actExecuteState{…Attack…}` / `{…AttackEnd…}`) to a sim tick, frame index, or 30 Hz step. In particular: whether `Attack` fires at item-entry (tick 0 of the cycle), at a mid-cycle key, or at the first displayed frame; and whether `AttackEnd` fires at the last frame, the frame after, or the next tag evaluation — **none is stated in any table, prototype, or enum recovered in P1–P11.** The script API cannot express it either (all completion setters take a bare `String`, §1.1).

- **[U]-C2a (Attack), [U]-C2b (AttackEnd), [U]-C2c (Work), [U]-C2d (Construct) stay open.** Captures R-C2a–d §5 decide them per-tick; no handler, tick, or offset is asserted here. The prior "no armed `EndCyclesReached` handler" observation is *strengthened* (now byte-anchored: the slots exist at `0x63b7xx/0x63e9xx` but are cleared on the unit path), not overturned.

---

## 5. Still-[U] fields — per-tick handler / frame-index captures, zero-mismatch termination (3/3)

All captures: singleplayer skirmish, fixed camera, paused-then-stepped sim, per-tick log `(sim_tick, selected_anim, AAF first..last, requested_frame, displayed_frame, blend_args(min,max), vertex_hash_or_joint_track, engine_read_frame_name)`. **No handler, tick, clamp rule, or offset is invented — a capture either returns a byte-repeatable trace or the [U] stays open.** "Zero-mismatch" = all trials identical frame-for-frame AND hash-for-hash; ONE differing tick/hash fails the capture. Native field names from §1–§3 may be logged as labels only (they add no pose math).

- **[U]-C1 (PlayOnce end-between-evaluations). Capture R-C1:** musketeer `attack1 [99,124]` single shot, 30 Hz trace `t0..t0+span+10`; record hold-at-`124` vs snap-to-first/idle with tick numbers + vertex hash at last 3 ticks; repeat peasant `death [115,149]` and cannon `attack0 [301,337]`. **Termination:** hold-vs-return-vs-event verdict with tick numbers, zero mismatch 3/3 trials per sid. Until then the port keeps clamp-at-last as a labelled stand-in (`completion:"clamp-at-last [U]-C1"`) with the empty hook unwired.
- **[U]-C2a (Attack firing tick). Capture R-C2a:** cannon `attack0/attack1 [301,337]` firing; log muzzle-flash PFX frame, damage tick, sound tick RELATIVE to the opening `Attack` handler tick (engine-read `ExecuteStateName` dispatch if the runner exposes it, else first observable effect). **Termination:** handler-tick + effect offsets, zero mismatch 3/3 trials, or absence logged.
- **[U]-C2b (AttackEnd firing tick). Capture R-C2b:** same run; log the `_unit_TryAttack` re-entry tick (next `Attack` decision) relative to the last displayed frame of the `NumberCycle=1` item. **Termination:** end-handler tick + retrigger offset, zero mismatch 3/3 trials.
- **[U]-C2c (Work firing tick). Capture R-C2c:** peasant `workfood/workwood/workstone` loop; log resource-hp decrement tick + `resamount+1` tick + work-sound tick relative to the `Work` handler tick. **Termination:** offsets 3/3 or absence logged.
- **[U]-C2d (Construct firing tick). Capture R-C2d:** building scaffold sequence (`aamNone → aamPlayOnce` stages per blend-op); log `buildprogress+delta` tick + hp tick + construct-sound tick relative to the `Construct` handler tick. **Termination:** offsets 3/3 or absence logged.
- **[U]-B1/B2/B3/B4/P1 (carried, unchanged):** R-B1 (weight-curve support), R-B2 (blend-window fetch), R-B3 (`random*`/FB differential), R-B4 (movie `0..5`), R-P1 (deferred-triple effect) per `DEC_U_blend_deep` §7 — restated by reference, not re-specified, to avoid a second source of truth.

## 6. Exact port change list for `anim3d.gd` (file/line; NO code written here)

| # | Port site (current [O], per blend-op/deep) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement |
|---|---|---|---|
| G1 | `DONOR_CYCLE_SITES` / `AAF_COMPLETION_STATUS` strings | `EndCyclesReached/StartCyclesReached/FBEndCyclesReached` + `FrameChanged/EndFrameReached/StartFrameReached` API quads byte-anchored (`0x63ab00/0x63b700/0x63e900`); all unit-path slots disarmed (carried); `OnAclAnimationReached*` zero byte-hits (script-side only) | EXTEND the status strings: cite `cossacks.exe 0x63b7c7/0x63b823/0x63b88d/0x63b8d1` + `0x63e95c/0x63e9a4/0x63e9f2/0x63ea5e` + `0x63ab00` quads; record "slots exist natively, disarmed on unit path; ACL handler names have zero exe hits — firing ticks [U]-C2a–d". String-only change. |
| G2 | `DONOR_BLEND_ARGS_STATUS` (new const, blend-deep F2) | `acsa*` = 3-member selector (no arity) at `0x86d82a/0x86de73`; `act*` = 4-member discriminator; callback slot = `ExecuteStateName:String + ExecuteStateIndex:Integer` (arity 2) at `0x86da00`; `NumberCycle` ×2 at `0x86da04/0x86e408` | EXTEND the const: record exactly the §2 arity verdict + VAs; cite `TXAnimationControllerSwitchAnimation` (`0x86d83f`) occurring ×1. No behavioural branch. |
| G3 | `_frame_at` once-clamp + `aaf_completion_probe` (`:848-862/:1493` per blend-op F4) | §3: no clamp/return/event rule in enum/property/API bytes; `aamBounce*/sam*` exist-but-unused; `OnFrameChanged/OnEndFrameReached/OnStartFrameReached` register triple at `0x550c00–0x550f44` | EXTEND the probe comment: cite the `0x550c00` register order + `0x550eef/0x550f18/0x550f44` event VAs; keep clamp stand-in labelled `[U]-C1`; wire NOTHING to the empty hook until R-C1 lands. String-only. |
| G4 | `fetch_policy` label (`nearest_single_no_blend [U]-B2`) | §4: no firing-tick table; `ExecuteStateName` slot VAs `0x86db7e/0x86e4a4` + delay API `0x63c528/0x660847` (arity 3 with `ftime: Float`) | LABEL ONLY: extend `fetch_policy`/completion strings to cite the slot VAs as the shape (not the timing) of completion; no second frame fetched, no tick asserted. |

Rows outside this worker's ask (`world3d_entities.gd` callers, orders, building visuals, `anim_action` producers, B1/B2/B3/P1 captures) are **not restated**.

Required donor asset manifest (all already on disk; sourced only through the approved converters, **not copied here**): `cossacks.exe` VAs `0x4f6d00 / 0x4f6e36 / 0x511f00 / 0x550900 / 0x550c00 / 0x550d00 / 0x550e00 / 0x63ab00 / 0x63b700 / 0x63b800 / 0x63c500 / 0x63e900 / 0x660800 / 0x7ebe00 / 0x7ec100 / 0x86d800 / 0x86da00 / 0x86de00` (ev ids §0.1) + `D:scripts/lib/unit.script` + `D:scripts/units/unit.inc/ontagstates.inc` + `D:scripts/units/unit.inc/initial.inc` + `D:scripts/units/unit.inc/onaclanimationreached{attack,attackend,work,construct}.inc` + `D:animations/acl/*.acl` (peasant/cannon + `acl.lib` + `ref/refunit.acl`).

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `EndCyclesReached` ×8 CODE VAs; `OnStateEndCyclesReached` ×4 + `FBEndCyclesReached` ×4 + `StartCyclesReached` ×4 + `EndFrameReached` ×7 with exact VAs; full Get/Set ByHandle+My prototype strings | [O] ev_fa02c9…/ev_53ad5b…/P7/P9 (§1.1) |
| 2 | `OnAclAnimationReached` stem + `Attack/AttackEnd/Work` full names: 0 byte-hits each (script-side only) | [O-absence with packed-region reserve] ev_a76a5f…/ev_a42f99…/ev_e4fb4e…/ev_4d739f… (§1.1) |
| 3 | `PlayOnce` ×5, `acmPlayOnce` ×1 (`0x512008`), `aamPlayOnce` ×2, `FrameInterpolation` ×6, `TActorAnimationMode` ×1, `AnimationMode` ×19, `CurrentFrameBlend` ×3 with VAs; `aam/acm/mm/trm/sam` enum contents | [O] ev_360182…/ev_ed38d7…/ev_a99535…/ev_c0cf47…/ev_b3527d…/ev_160156…/ev_e66834…/ev_07e412…/ev_ec92c9…/ev_0c7624… (§1.2) |
| 4 | `acsa*` 3-member selector (no arity) + `act*` 4-member discriminator; callback slot `ExecuteStateName:String + ExecuteStateIndex:Integer` (arity 2); `NumberCycle` ×2; no `OnCompletion/FireTick` property in dispatch windows | [O]/[D] ev_167ec7…/ev_d868b9…/ev_5ff556…/ev_905512… (§2) |
| 5 | BaseActor frame register order + event triple VAs; sprite twin; state hook quads; all completion setters take exactly `(gohandle; const state: String)` | [O] ev_82bc5d…/ev_357404…/P11 (§3.1) |
| 6 | No clamp/return/event rule in enum/property/API bytes; no armed unit-path `EndCyclesReached` handler (carried + byte-strengthened) | [D] §3.2 — [U]-C1 stays open |
| 7 | No firing-tick table for Attack/AttackEnd/Work/Construct in any recovered bytes; handler bodies give order only (carried) | [D] §4 — [U]-C2a/b/c/d stay open |
| 8 | Every [U] has a per-tick handler/frame-index capture with zero-mismatch termination (R-C1/R-C2a–d + carried R-B1/B2/B3/B4/P1) | [D] §5 |
| 9 | Any port motion/timing/blend equal to donor, any invented handler/tick/clamp rule, or any runtime PASS | **Denied** — no same-camera donor/port A/B exists; visual UNVERIFIED |

## 8. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) and the read-only `C:\Games\Cossacks 3\data` script tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-ANIM-COMPLETE-DEEP.*
