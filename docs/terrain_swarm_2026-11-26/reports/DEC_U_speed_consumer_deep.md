---
id: DEC-U-SPEED-CONSUMER-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SPEED-CONSUMER-DEEP — packed-CODE speed-name search, wrapper-signature inspection, global-base-speed byte proof attempt, shipped override re-check"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_speed_consumer_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/byte/VA observation; every port statement is a read-only source line or a carried cite from DEC_U_move_speed. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only; network/multiplayer/lobby/Steam/replay-sync OUT OF SCOPE."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every binary call in THIS job passed document=t_87f0f3c130b0 explicitly."
port_scope: "app/scripts/data.gd + app/scripts/game.gd (carried read-only cites from DEC_U_move_speed §7; no new port reads needed for this consumer question). variant3d/scripts/* noted only where the same table exists."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_move_speed.md (§1-§9, per-sid speed table defined-but-dead, rotatespeed*2.225 live consumer, speedperc divisor; U-speed-consumer left [U])
context_delta: "Prior worker proved the 18-row speed-constant table DEFINED-but-unconsumed (17 per-sid writes //-dead, live default 1 at unit.script:618), the live rotatespeed*2.225 consumer (unit.script:11066), and the speedperc divisor + Floor TrackPoint rewrite (player.script:1927-1944), but left U-speed-consumer open: (a) no packed-CODE search for speed property/API names, (b) no wrapper-signature read, (c) no byte-proven global base speed/interval, (d) no shipped map/script override sweep. This worker attacks exactly those four angles with NEW passes."
---

# DEC-U — speed-consumer DEEP pass (packed CODE, wrappers, global base, override sweep)

> READ-ONLY. No approximation endorsed. Each still-[U] ends in a named fixed-seed movement trace with zero-mismatch termination, never in a port fallback. No speed, ramp, interval default, or turn law is invented here.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / byte dump / port line (carried). **[D]** = arithmetic or verbatim-typing over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = workspace `app\scripts\`. `c3` = `t_87f0f3c130b0`.
- `ev_<hex>` = Craft Anything evidence id of a pass in **this** job (all `document=t_87f0f3c130b0` for binary calls). `ev(carried)` = id from DEC_U_move_speed, re-cited not re-run. Donor-text shell reads carry file:line instead of an evidence id (commands in §9 provenance).

### 0.1 Pass ledger (pin `t_87f0f3c130b0`, multiple NEW passes; strange-decomp log inline)

| Pass | Operation | Evidence | Result |
|---|---|---|---|
| P-DEEP0 | `core_session_show` (pin re-assert) | session record (no evidence id; host reply) | [O] active target `t_87f0f3c130b0`, `cossacks.exe` 5,768,048 B, sha256 `87f0f3…4e16c`, Deep mode; second open target `t_68474ddde43f` (`editor.exe`) untouched |
| P-DEEP1a | `native_strings_find` literal ×16: `objbase.speed`, `setspeed`, `SetSpeed`, `movementSpeed`, `MovementSpeed`, `rotatespeed`, `RotateSpeed`, `speedperc`, `SpeedPerc`, `TrackSpeed`, `MoveStepInterval`, `TurnStepInterval`, `IntervalFactor`, `walkinterval`, `motionstyle`, `TrackPoint` | `ev_be0abd…` through `ev_48586f…` (16 records; §1.1) | [O] ALL script speed/CI names ×0 **except** `TrackPoint` → 2 hits `0x958801 XTrackPoint`, `0x95908d }XTrackPointPreset`, both `.rsrc` (reconfirms prior P2-P5 verdict on a wider name list) |
| P-DEEP1b | `native_bytes_find` text (utf8+utf16le, whole file incl. CODE) ×9: `rotatespeed`, `speedperc`, `MoveStepInterval`, `TrackPointMoveStep`, `SetGameObjectTrackPoint`, `GameObjectSetupRotating`, `walkinterval`, `motionstyle`, `objbase` | `ev_109063…` (0), `ev_b670f9…` (0), `ev_c9c832…` (8), `ev_12b297…` (10), `ev_c10abf…` (33), `ev_fa4db4…` (2), `ev_9cbf21…` (0), `ev_b780cf…` (0), `ev_850bcd…` (0) (§1.2) | [O] script-side speed names ABSENT from file bytes; engine-side TrackPoint/interval/rotate API names PRESENT in CODE (§1.2 VAs) — the split is byte-proven |
| P-DEEP1c | `core_evidence_browse` rows pages for the 4 hit-sets | `ev_451267…`, `ev_9cdeaf…`, `ev_8575a1…`, `ev_ab1c5e…` | [O] full VA lists (§1.2): `MoveStepInterval` ×8, `TrackPointMoveStep` ×10, `SetGameObjectTrackPoint` ×33, `GameObjectSetupRotating` ×2, all `section: CODE` |
| P-DEEP2a | `native_bytes_show` 512 B ×5: `0x638900`, `0x63a580`, `0x5fd100`, `0x840020`, `0x86da00` | `ev_e0e92c…`, `ev_168214…`, `ev_88cc76…`, `ev_41761c…`, `ev_85f7ad…` (§2-§3) | [O] verbatim wrapper signatures (§2.1) + CODE property-name runs (§3.1) + RTTI property table (§3.2) |
| P-DEEP2b | `native_bytes_show` 1024 B ×6: `0x840000`, `0x840100`, `0x86d900`, `0x86db00`, `0x63a400`, `0x638a00` + `native_bytes_find` `MoveStep`/`TurnStep`/`EpsilonDistance`/`VirtualDirection`/`Rotat`/`2.225` | §2.1/§3.1 (ascii cites) + FIND totals: MoveStep 24, TurnStep 20, EpsilonDistance 9, VirtualDirection 10, Rotat 231, `2.225` 0 | [O] two-channel step/interval signature family complete (§2.1); `2.225` literal absent from image (script-side factor) |
| P-DEEP2c | `native_bytes_show` 1024 B ×5: `0x638b80`, `0x638d00`, `0x639d00`, `0x63c300`, `0x63b500` + `native_bytes_find` pattern `66 66 0E 40` (float32 2.225 LE) | §2.1 (follow/min/max + epsilon/interval sigs) + 2.225f-bytes total 0 | [O] no float-encoded 2.225 in image; follow-clamp + epsilon + `GetGameObjectMyInterval` signatures recovered |
| P-DEEP2d | `native_xrefs_list` + `native_function_find` ×5: `0x638975`, `0x63897f`, `0x63a5e6`, `0x8400a4`, `0x86da74` + `native_function_show sub_6362a4` | `ev_6912f0…/ev_b44c1b…`, `ev_f0f424…/ev_7a6f38…`, `ev_97273c…/ev_6296ac…`, `ev_137883…/ev_b48168…`, `ev_75c81f…/ev_8e3592…`, `ev_c29ac6…` (§2.2) | [O] registration strings live inside giant registrar `sub_6362a4` (13120 basic blocks), 0 static xrefs (computed registration); property tables are data, not functions |
| P-DEEP3 | global-base-speed byte hunt (§3): 2.225 text+float sweeps + property-table default inspection + `float 1.0` control (`00 00 80 3F` → 1821 hits, unusable as proof) | §3.3 | [O-negative] NO byte-proven global base speed or tick default found — stays [U] (§3.3) |
| P-DEEP4 | donor-text override sweep (read-only shell): `objbase.speed` full-tree, `\.speed :=` full-tree, `user.inc/resetdefaults.inc` speed grep, maps inventory | shell reads, file:line cites (§4) | [O] exactly 3 LIVE `.speed :=` writers, zero shipped override re-enabling per-sid rows (§4.1-§4.3) |

**Strange-decomp log (required):** no per-instruction locomotion disassembly is offered. The CODE hits in P-DEEP1b/2a are *registration-string runs inside the script-binding registrar* (`sub_6362a4`, 13120 blocks, §2.2), not locomotion integrators; attributing any neighbouring `sub_*` to movement would be a guess. The `Rotat` 231-hit set (§2.1) is a name prefix, not a function identification — no function is named as the turn integrator. The `float 1.0` pattern (1821 hits) is cited only to show why a float-constant hunt cannot prove a base speed. Nothing is pseudo-C quoted.

---

## 1. Packed CODE byte search — script names ABSENT, engine API names PRESENT (task a)

### 1.1 Data-section string search (wider name list than prior) [O]

All `document=t_87f0f3c130b0`, `mode=literal`, case-insensitive:

| Query | Evidence | Hits |
|---|---|---|
| `objbase.speed` | `ev_be0abd…` | 0 |
| `setspeed` / `SetSpeed` | `ev_6555a8…` / `ev_c108e6…` | 0 / 0 |
| `movementSpeed` / `MovementSpeed` | `ev_ff5cdc…` / `ev_69ccf8…` | 0 / 0 |
| `rotatespeed` / `RotateSpeed` | `ev_faf36c…` / `ev_f76d33…` | 0 / 0 |
| `speedperc` / `SpeedPerc` | `ev_54df12…` / `ev_bcca9e…` | 0 / 0 |
| `TrackSpeed` | `ev_a9fb23…` | 0 |
| `MoveStepInterval` | `ev_5b4e17…` | 0 (data sections only) |
| `TurnStepInterval` | `ev_e0c9fa…` | 0 (data sections only) |
| `IntervalFactor` | `ev_401692…` | 0 |
| `walkinterval` | `ev_90f082…` | 0 |
| `motionstyle` | `ev_484ece…` | 0 |
| `TrackPoint` | `ev_48586f…` | 2: `0x958801 XTrackPoint`, `0x95908d }XTrackPointPreset`, both `.rsrc` |

[D] consequence: no script locomotion identifier (`objbase.speed`, `rotatespeed`, `speedperc`, `walkinterval`, `motionstyle`, any `*Speed*` setter) is embedded as a binary string. This extends the prior P2-P5 verdict (entry names + `rotatespeed`/`IntervalFactor`/`walkinterval`/`fishingspeed`/`motionstyle`/`MovementMode`/`MaxSpeed`/`Deceleration`) to the full task-(a) name list. Absence is limited by the tool's `data_sections_only` caveat — §1.2 closes the CODE gap.

### 1.2 Whole-file byte search (CODE included) — the split [O]

`native_bytes_find`, `encoding: both (utf8+utf16le)`, whole `cossacks.exe` as stored:

| Query | Evidence | Total | First VAs [O] |
|---|---|---|---|
| `rotatespeed` | `ev_109063…` | 0 | — |
| `speedperc` | `ev_b670f9…` | 0 | — |
| `walkinterval` | `ev_9cbf21…` | 0 | — |
| `motionstyle` | `ev_b780cf…` | 0 | — |
| `objbase` | `ev_850bcd…` | 0 | — |
| `MoveStepInterval` | `ev_c9c832…` / page `ev_451267…` | **8** | `0x5fd17a`, `0x5fd2ef`, `0x63897f`, `0x6389c5`, `0x638a25`, `0x638ae3`, `0x8400a4`, `0x840164` — all `section: CODE` |
| `TrackPointMoveStep` | `ev_12b297…` / page `ev_9cdeaf…` | **10** | `0x638975`, `0x6389bb`, `0x638a1b`, `0x638ad9`, `0x638b31`, `0x638b6f`, `0x638bc5`, `0x638c0b`, `0x86da74`, `0x86e41c` — all `CODE` |
| `SetGameObjectTrackPoint` | `ev_c10abf…` / page `ev_8575a1…` | **33** | `0x62f57a`, `0x6329fe`, `0x632b4a`, `0x632c96`, `0x632de2`, `0x632f3a`, `0x633002`, `0x636e2e`, `0x63713e`, `0x637386`, `0x637542`, `0x638a0e`, `0x638bfe`, `0x638d5e`, `0x638eaa` + 18 further (paged record) — all `CODE` |
| `GameObjectSetupRotating` | `ev_fa4db4…` / page `ev_ab1c5e…` | **2** | `0x63a5e6`, `0x63a6d6` — both `CODE` |
| `MoveStep` (control) | §P-DEEP2b | 24 | `0x5fd17a:CODE`, `0x5fd1e6:CODE`, `0x5fd2ef:CODE`, `0x5fd367:CODE`, `0x63897f:CODE`, … |
| `TurnStep` (control) | §P-DEEP2b | 20 | `0x638c77:CODE`, `0x638cbd:CODE`, `0x638d1f:CODE`, `0x638d75:CODE`, … |
| `EpsilonDistance` | §P-DEEP2b | 9 | `0x639e61`, `0x639e9b`, `0x639ef1`, `0x639f3b`, `0x63c34c`, … all `CODE` |
| `VirtualDirection` | §P-DEEP2b | 10 | `0x639da5`, `0x639df3`, `0x63b520`, `0x63b568`, … all `CODE` |
| `Rotat` (prefix control) | §P-DEEP2b | 231 | `0x50ce08`, `0x50ce44`, `0x50d454`, … (prefix only, NOT attributed to locomotion) |
| `2.225` (text) | §P-DEEP2b | 0 | — (script-side factor, cf. §2.3) |

[D] byte-proven split (task-a answer): **script speed vocabulary is not CODE-embedded; engine TrackPoint/interval/rotate/epsilon vocabulary is CODE-embedded.** There is no packed `CODE` table keyed by `objbase.speed` / `setspeed` / `movementSpeed` / `rotatespeed` / `speedperc` / `TrackSpeed` to find — the search was run and returned zero with VAs listed, not assumed. The CODE-embedded tables that DO exist are the TrackPoint binding/property runs of §2-§3 (blend/tick-shaped only in the sense that they pair a Float step with an Integer interval; no blend factor or tick rate is claimed).

---

## 2. Wrapper signatures — the native setter does NOT consume the dead script speeds (task b)

### 2.1 Verbatim signatures [O] (CODE registration runs)

`0x638900` run (`ev_e0e92c…`), 512 B ascii (truncated to the speed-relevant items, order donor-verbatim):

- `function GetGameObjectMyTrackPointMoveStepInterval(): Integer`
- `function GetGameObjectTrackPointMoveStepIntervalByHandle(gohandle: Integer): Integer`
- `procedure SetGameObjectTrackPointMoveStepIntervalByHandle(gohandle: Integer; movestepinterval: Integer)`
- `function GetGameObjectPositionXByHandle(gohandle: Integer): Float`
- `procedure SetGameObjectMyTrackPointMoveStepInterval(movestepinterval: Integer)`

`0x638a00` run (1024 B ascii, §P-DEEP2b):

- `function GetGameObjectMyTrackPointMoveStep(): Float`
- `function GetGameObjectTrackPointMoveStepByHandle(gohandle: Integer): Float`
- `procedure SetGameObjectMyTrackPointMoveStep(movestep: Float)`
- `procedure SetGameObjectTrackPointMoveStepByHandle(gohandle: Integer; movestep: Float)`

`0x638b80`/`0x638d00` runs (1024 B ascii each, §P-DEEP2c) complete the symmetric turn pair plus follow clamps:

- `function GetGameObjectMyTrackPointTurnStepInterval(): Integer`
- `function GetGameObjectTrackPointTurnStepIntervalByHandle(gohandle: Integer): Integer`
- `procedure SetGameObjectMyTrackPointTurnStepInterval(turnstepinterval: Integer)`
- `procedure SetGameObjectTrackPointTurnStepIntervalByHandle(gohandle: Integer; turnstepinterval: Integer)`
- `function GetGameObjectMyTrackPointTurnStep(): Float`
- `function GetGameObjectTrackPointTurnStepByHandle(gohandle: Integer): Float`
- `procedure SetGameObjectMyTrackPointTurnStep(turnstep: Float)`
- `procedure SetGameObjectTrackPointTurnStepByHandle(gohandle: Integer; turnstep: Float)`
- `procedure SetGameObjectTrackPointFollowAutoMovement(gohandle: Integer; bauto: Boolean)`
- `procedure SetGameObjectTrackPointFollowMinMoveStep(gohandle: Integer; min: Float)`
- `procedure SetGameObjectTrackPointFollowMaxMoveStep(gohandle: Integer; max: Float)`
- `procedure SetGameObjectTrackPointFollowMinTurnStep(gohandle: Integer; min: Float)`
- `procedure SetGameObjectTrackPointFollowMaxTurnStep(gohandle: Integer; max: Float)`
- `procedure SetGameObjectTrackPointFollowMoveMaxRa…` (run continues past the 1024 B window; name completed only to the window edge — NOT quoted further)

`0x63a400`/`0x63a580` runs (`ev_168214…` + §P-DEEP2b) — the live rotate consumer's native entry:

- `function GameObjectMySetupRotatingToTarget(posx, posy, posz: Float; const sturnleft: String; const sturnright: String; const sidle: String; fanimangle: Float; animtimeinterval: Integer; fminturnangle: Float; busecycles: Boolean): Boolean`
- `function GameObjectSetupRotatingToDirectionByHandle(gohnd: Integer; dirx, diry, dirz: Float; const turnleft, turnright, idle: String; animangle: Float; animtimeinterval: Integer; minturnangle: Float; usecycles: Boolean): Boolean` (`0x63a5e6`)
- `function GameObjectSetupRotatingToTargetByHandle(gohnd: Integer; posx, posy, posz: Float; const turnleft, turnright, idle: String; animangle: Float; animtimeinterval: Integer; minturnangle: Float; usecycles: Boolean): Boolean` (`0x63a6d6`)
- neighbouring: `procedure SetGameObjectMyRotatingTargetVector(x: Float; y: Float; z: Float)` + `…ByHandle` twin (window edge)

`0x639d00`/`0x63b500`/`0x63c300` runs (task-b neighbours, §P-DEEP2c):

- `procedure SetGameObjectMyEpsilonDistance(epsilondistance: Float)` / `…ByHandle(gohandle: Integer; epsilondistance: Float)`; same pair for `EpsilonAngle`; `GetGameObjectEpsilonAngleByHandle` (the `unit.script:11066` reader); `SetGameObjectMyVirtualDirection(x,y,z: Float)` / `…ByHandle`; `function GetGameObjectMyInterval(): Integer` / `procedure SetGameObjectMyInterval(interval: Integer)` (generic object interval, NOT attributed to locomotion here)

Camera-track lookalikes that must NOT be confused with unit locomotion [O] (`0x5fd100`, `ev_88cc76…`): `SetCameraTrackSmoothMoveStepInterval(const name: String; smoothmovestepinterval: Integer)`, `SetCameraTrackSmoothMoveStep(…; smoothmovestep: Float)`, `SetCameraTrackAccelerationFactor(…; accelerationfactor: Float)` — camera system, excluded from the unit verdict [D].

### 2.2 Registration mechanism [O/D]

- `native_xrefs_list` on `0x638975`, `0x63897f`, `0x63a5e6`, `0x8400a4`, `0x86da74`: **0 static references either way** (`ev_6912f0…`, `ev_f0f424…`, `ev_97273c…`, `ev_137883…`, `ev_75c81f…`) — same computed-registration shape as the prior `XTrackPoint` 0-xref verdict [D].
- `native_function_find`: `0x638975`/`0x63897f`/`0x63a5e6` all lie inside **`sub_6362a4`** (`ev_b44c1b…` +9937/+9947/+17218); `0x8400a4`/`0x86da74` are in no discovered function (`ev_b48168…`/`ev_8e3592…`: data tables) [O].
- `native_function_show sub_6362a4` (`ev_c29ac6…`): **13120 basic blocks** [O] — the image's giant script-binding registrar. The §2.1 strings are its registration payload [D: registrar attribution from size + string density + 0-xref computed binding; NOT a locomotion-integrator claim].

### 2.3 Task-(b) answer [D, load-bearing]

The native setter family consumes **two channels per axis**:

1. a Float **step size** (`movestep: Float`, `turnstep: Float` — distance/angle covered per step), and
2. an Integer **step interval** (`movestepinterval: Integer`, `turnstepinterval: Integer` — ticks per step).

Neither channel takes `objbase.speed`, a `gc_obj_speed_*` constant, `rotatespeed`, `walkintervalfactor`, or `speedperc`. The ONLY script bridge into this family found in sampled text is the `speedperc` upgrade path (`player.script:1940-1943`, carried): script reads the Float divisor `objbase.speed`, computes `Floor(movestepinterval*speed)` / `Floor(turnstepinterval*speed)` in script, and passes the quantised **Integer** to the interval setter. The dead per-sid `objbase.speed := gc_obj_speed_*` rows (§4.1) therefore have **no native consumer even if re-enabled textually**: the native side has no `speed` parameter to receive them — a re-enabled write would only change the divisor the `speedperc` path reads, and only for water units behind the `{and _unit_IsWaterUnit}` gate (carried [U] U-upg-gate). `rotatespeed` likewise never reaches native: script multiplies it by `2.225` and passes the product as `animangle: Float` to `GameObjectSetupRotatingToDirectionByHandle` (`unit.script:11066`, carried), while native timing comes from `animtimeinterval: Integer` + `minturnangle` + `usecycles`. **No native setter consumes the dead script speeds directly — byte-proven at the signature level.**

---

## 3. Global base speed / interval — hunt run, nothing byte-proven (task c)

### 3.1 CODE property-name runs [O] (the tables that exist)

`0x840020` (`ev_41761c…`, 512 B) and `0x840000`/`0x840100` (1024 B each) ascii:

- Repeating record shape: length-prefixed names `MoveStep` (`0x08`), `MoveStepInterval` (`0x10`), `EpsilonDistance` (`0x0F`), `VirtualDirection` (`0x10`), then later `MoveProperty`, `TurnStep` (`0x08`), `TurnStepInterval` (`0x10`), `EpsilonAngle` (`0x0C`), `VirtualUp` (`0x09`), each followed by `ffffffff` separators and short id/type bytes in hex (`08000000…ffffffff 10000000…` etc.) [O].
- These are **property-name tables** (serializer/RTTI shape, same family as the `0x86da00` table below), NOT a speed-constant table: no per-class row, no px/s value, no tick default is legible in the dumped windows [D].

### 3.2 RTTI property-descriptor table [O]

`0x86da00` (`ev_85f7ad…`, 512 B) + `0x86d900`/`0x86db00` (1024 B each) ascii/hex:

- Ordered descriptors: `NumberCycle`, `AnimationIndex`, `Action`, **`TrackPointMoveStep`**, **`TrackPointTurnStep`**, `TrackPointIdleName`, `TrackPointPreset`, `TrackPointPresetName`, `TrackPointMode`, `ExecuteStateName`, `ExecuteStateIndex`, `OwnerCycles`, then `TXAnimationCycleItem…`, `TXAnimationController…`, `actAnimation/actTrackPoint/actTrackPointPreset/actExecuteState…` [O].
- Each descriptor carries small hex tag bytes (e.g. `TrackPointMoveStep f8 10 40 00 1c …`, `TrackPointTurnStep 18 11 40 00 20 …` in the hex dump) whose field semantics (type id vs. default vs. offset) are **not decoded in this job** — quoting them as defaults would be invention [I explicitly withheld].
- `0x86da74`/`0x86e41c` (`TrackPointMoveStep` text hits) sit inside this table [O] (§1.2).

### 3.3 The negative result (task-c answer) [O-negative → U]

- Text `2.225`: **0 matches** whole-file (§P-DEEP2b) [O] — the live `rotatespeed*2.225` factor exists ONLY in script (`unit.script:11066`, carried), never as a native constant.
- Float32 bytes `66 66 0E 40` (≈2.225f LE): **0 matches** (§P-DEEP2c) [O] — same verdict at the encoding level (float64 form not swept: searching every near-encoding would be unbounded; the text sweep already proves the literal is not embedded as written).
- Float32 `00 00 80 3F` (1.0f): **1821 matches** (§P-DEEP2d) [O] — cited ONLY to show a constant hunt cannot identify a base speed: with 1821 candidates, picking one as "the" tile-per-interval without an anchoring string or xref would be a guess, so none is picked.
- No `1 tile per interval`, no `ticks-per-step default`, no `MoveStep default distance`, no per-class native speed row was found anchored to any TrackPoint name, VA, or xref in this job's windows [O-negative].

[D] task-(c) answer: **whether live movement uses a global base speed (e.g. 1 tile per interval) and with what interval is NOT byte-proven and stays [U] U-base-speed.** The native two-channel model (Float step + Integer interval, §2.3) constrains the SHAPE of any future answer (a base would have to appear as a default step and/or default interval), but supplies no VALUES. See T-BASE (§8).

---

## 4. Shipped map/script override sweep — nothing re-enables per-sid writes (task d)

Read-only PowerShell against `C:\Games\Cossacks 3\data\` (commands §9).

### 4.1 Full-tree `objbase.speed` [O] (file:line)

| File:line | Text [O] | Live? |
|---|---|---|
| `unit.script:618` | `objbase.speed := 1;` (inside `_unit_InitBase`) | LIVE — the universal overwrite |
| `unit.script:1192/1322/1420/1546/1699/1735/1767/1796/1826/1857/1875/1906/1924/1961/1991/2001/2015/2035` | all `//objbase.speed := gc_obj_speed_*` (17 sites; `:1906` deeper-indented but still `//`) | DEAD — reconfirmed byte-for-byte including the `:1906/:1991/:2001/:2015` indented variants this pass |
| elsewhere in `data/scripts/**` (`*.script`, `*.inc`) | zero further `objbase.speed` hits | — |

### 4.2 Full-tree `\.speed :=` [O] (file:line — the complete LIVE writer set)

Only THREE live writers exist in the shipped tree:

1. `unit.script:618` — `objbase.speed := 1;` (init default) [O].
2. `player.script:1930` — `gPlayer[plInd].objbase[cid][iarr2[i]].speed := 1/(…speed*(1+value/100));` (speedperc divisor) [O, carried law].
3. `serial.script:516` — `gPlayer[i].objbase[cid][id].speed := 1;` (`gSerialVersion<91` compat pin) [O, carried].
4. `weapon.script:59` — `weapon.speed := physvalue;` (projectile propagation setter, NOT unit locomotion) [O] — surfaced by the unanchored `\.speed` sweep; correctly excluded [D].

### 4.3 Shipped overrides / maps / user scripts [O-negative]

- `data/scripts/user/user.inc/resetdefaults.inc`: `Select-String … 'speed|MoveStep|rotatespeed'` → **zero hits** [O] — the shipped user-defaults overlay touches no speed.
- `data/scripts/user/` tree otherwise: only `user.aix` + `resetdefaults.inc` present; no per-sid speed file [O] (directory listing).
- `data/maps/missions/*.map` inventory (e.g. `ausmis1-5`, `battle1-8`, `bonmis1-3`, `engmis1-4`, …): binary map blobs — a text re-enable probe is out of scope for a script sweep, and NO script in the shipped tree reads a per-map speed row back into `objbase.speed` (the §4.2 writer set is closed) [D]. Map-driven re-enable therefore has no script consumer even if a map blob carried a number.
- Cross-tree `objbase.speed|MoveStepInterval|speedperc` outside `data/scripts/lib/*` (DLC/patch sweep attempted): no additional live writer surfaced in the sampled output [O-negative within the sweep's page limits; the CLOSED writer set of §4.2 is the load-bearing claim, not the absence of DLC hits].

[D] task-(d) answer: **no shipped map, user script, patch, or serial path re-enables any of the 17 per-sid `gc_obj_speed_*` writes. The live value after `InitBase` is `1` for every sid, modifiable only by the `speedperc` divisor (water-gated branch) and reset by the serial pin.** The defined-but-dead verdict stands and is now sweep-closed at the script level; the remaining opening is purely native (T-SPEED/T-BASE).

---

## 5. What each still-[U] needs (no port wiring until green)

Carried opens U-speed-consumer (split below), U-turn, U-motionstyle, U-accel, U-terrain, U-formation, U-carry, U-upg-gate, U-upg-stack, U-walkinterval (DEC_U_move_speed §1.4/§2-§6) **plus** the new U-base-speed (§3.3). Port change list itself is carried (DEC_U_move_speed §7 S1-S6, specify-only) and is NOT repeated here — this report adds only the consumer-shape correction: any future consumer must target the **Integer-interval setters** with `Floor()` quantisation, never a Float speed.

---

## 6. Fixed-seed movement traces (zero-mismatch termination; never invent a speed)

General harness (all T-*): singleplayer skirmish, fixed map seed (record `randkey0/1`), flat open ground (T-TERRAIN excepted), fixed camera (position/yaw/pitch/fov logged + capture id), headless fixed-`dt` (= 1/32 s, `gc_time_to_frames`), seeded RNG re-seeded per series, canonical JSON state hash (players, entities, positions, orders, RNG counters). Assertions read positions/handles, never pixels. **Termination rule (all): run the FULL stated series; ANY single positional/temporal mismatch vs the stated donor expectation keeps the item [U] and forbids wiring; zero mismatches across the FULL series closes it.** Never fit or invent a rate, ramp, scalar, gate, or default.

- **T-SPEED (U-speed-consumer steady-state velocity per class):** one unit per class (peasant, foot, hardhorse, fasthorse, cannon, mortar, howitzer, multicannon, all 7 ship sids), surveyed origin, straight 20 m march (ships: 40 m sail), no orders/formation/aura/upgrades. Log per-tick `(pos, tick)`. Pass = per-class mean velocity over middle 50% of transit matches its §1.1 [D] m/s cell within quantisation (±1 tick / ±0.05 m) with 0 mismatches across 5 trials × 15 classes; first mismatch stops the run with its capture id. Decides whether ANY defined constant is the live speed. (Carried, re-affirmed: the §2.3 two-channel model predicts this trace FAILS — i.e. stays [U] — because live `objbase.speed` is 1 for all classes; the prediction is recorded, never fitted.)
- **T-BASE (U-base-speed: native step/interval defaults — NEW trace for §3.3):** fresh skirmish per trial, one foot unit, no upgrades/orders. Expose `GetGameObjectTrackPointMoveStepByHandle` (Float) + `GetGameObjectTrackPointMoveStepIntervalByHandle` (Integer) + turn twins at spawn (pre-order), then order 20 m march and log per-tick `(pos, MoveStep, MoveStepInterval, TurnStep, TurnStepInterval)`. Pass = spawned defaults identical across 10 trials × 3 classes (foot/horse/ship) within exact Integer equality + Float ±1 ulp, AND per-tick displacement equals `MoveStep` every `MoveStepInterval` ticks within ±1 tick with 0 mismatches; any trial-to-trial default drift or unexplained displacement keeps [U]. This is the ONLY trace allowed to close U-base-speed, and it closes it with MEASURED defaults, never with `1 tile` assumed.
- **T-TURN (U-turn/U-motionstyle):** foot, cannon (`slowrotate`, rate 1), ship (`ship`, rate 2); 90° then 180° facing changes, no translation. Log per-tick facing + translation start. Pass = duration ordering matches rate ordering (5 < 4 < 2 < 1) with 0 mismatches across 10 trials × 3 classes; asserts (never fits) whether `*2.225` predicts absolute durations. Now also logs `animtimeinterval`/`minturnangle` exposition if the harness exposes them.
- **T-ACCEL (U-accel):** foot + fasthorse + cannon; from `mmNone` order 10 m march. Log first 32 ticks `(pos, per-tick displacement)`. Pass = 0 mismatches vs step hypothesis (first-tick displacement already steady-state) across 10 trials × 3 classes; any ramp keeps [U].
- **T-TERRAIN (U-terrain):** foot marches 20 m across (a) flat, (b) max-slope climbable, (c) shallow-water edge lane, (d) bridge deck where present. Log transit ticks per lane. Pass = all four lanes within ±1 tick (null-cost) with 0 mismatches across 10 trials; any systematic delta is filed as a measured table, never a fitted scalar.
- **T-FORM (U-formation):** 12-foot squad `LINE8` vs 12 solo feet, same 20 m order; then `LINE3` vs `COLUMN`. Log per-unit arrival ticks + slot offsets. Pass = squad mean arrival matches solo mean within ±2 ticks AND offsets match `unitRadius*0.8/*0.5` pitch with 0 mismatches; any formation speed delta keeps [U].
- **T-CARRY (U-carry):** peasant shuttles 10 m storehouse↔tree lane empty then full (`resamount>0` both directions logged). 20 round trips. Pass = loaded-leg and empty-leg transit ticks identical within ±1 tick with 0 mismatches; any delta keeps [U].
- **T-UPG (U-upg-gate/U-upg-stack):** pre-upgrade 40 m sail baseline (each ship sid × 5), apply `speedperc 40`, sail again; stacking probe if the engine permits a second apply. Log TrackPoint move/turn intervals where exposed + transit ticks. Pass = post-upgrade intervals equal `Floor(pre·(1/1.4))` with 0 mismatches AND land-unit intervals unchanged (decides the `{and _unit_IsWaterUnit}` gate); stacking run decides oscillation vs compounding with 0 mismatches. Until green, NOTHING from §2.3's divisor path is wired. Now asserts against the Integer-interval setters (not a Float speed).
- **T-WALK (U-walkinterval):** infantry (`walkintervalfactor` 1.25) vs fasthorse (1.0) vs donkey (1.4) 20 m marches; log anim-rate handle where exposed alongside `(pos, tick)`. Pass = any velocity correlation recorded as MEASURED with 0 mismatches across 10 trials, never assumed from the anim cadence.

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Script speed names (`objbase.speed`, `setspeed`, `rotatespeed`, `speedperc`, `walkinterval`, `motionstyle`, `*Speed*` setters) have zero data-section strings AND zero whole-file byte matches; engine TrackPoint/interval/rotate/epsilon names have 8/10/33/2/9/10 CODE hits with VAs | [O] §1.1-§1.2 + ev ids |
| 2 | Native setter family = Float step + Integer interval per axis (`MoveStep`/`MoveStepInterval`, `TurnStep`/`TurnStepInterval`), ByHandle+My pairs, plus follow min/max clamps; rotate entries take `animangle: Float; animtimeinterval: Integer; minturnangle: Float; usecycles: Boolean` | [O] §2.1 verbatim sigs + ev ids |
| 3 | Registration strings live in giant registrar `sub_6362a4` (13120 blocks), 0 static xrefs; property tables at `0x840020`/`0x86da00` are data, not functions | [O] §2.2 + ev ids |
| 4 | No native setter takes a speed: dead per-sid rows have no consumer even if re-enabled; only bridge is script-side `Floor(interval*speed)` Integer rewrite (water-gated) and `rotatespeed*2.225 → animangle` | [D] §2.3 |
| 5 | `2.225` text + float32 bytes both 0 in image; no global base speed / tick default byte-proven; `1.0f` has 1821 hits (unusable) | [O] §3.3 |
| 6 | Exactly 3 live `.speed :=` writers (`unit.script:618`, `player.script:1930`, `serial.script:516`); 17 per-sid writes `//`-dead; `weapon.script:59` is projectile-only; user overlay has zero speed hits; no shipped override re-enables rows | [O] §4.1-§4.3 |
| 7 | Every still-[U] (incl. new U-base-speed) has a zero-mismatch fixed-seed trace; none closed by port fallback; no numeric invented | [D] §6 |
| 8 | Any port visual equals donor march/turn/formation motion | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 8. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned, global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-SPEED-CONSUMER-DEEP.*
