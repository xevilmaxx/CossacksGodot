---
id: DEC-U-BLEND-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-BLEND-DEEP — native static localization of animation blend operator (FrameBlend RTTI, script-API table, TAnimation/ACL player candidates, Round/float helpers)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep/Ghidra engine active, shared Craft Anything session). Every native call pinned with document=t_87f0f3c130b0. Binary never executed."
port_scope: "variant3d/scripts/anim3d.gd cited read-only only where it owns the [U] fields; NOT edited, NOT re-specified."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_op.md (8-arg switch positional map, (6,8)/(0,0)/(0,5) sites, ACL tree/NumberCycle, inclusive/exclusive frame laws; B1 weight curve, B2 frame fetch, B3 arg polarity left [U]; native player not localized)
---

# DEC-U-BLEND-DEEP — native static localization: FrameBlend RTTI, script-API table, player candidates

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0` (not port test ids). "Address" = donor VA (`0x…`) for binary hits, `path:line` for donor text.
> Context carried: `DEC_U_blend_op.md` recovered the script-side 8-arg switch map and ACL tree from text, but B1 (interpolation operator/weight curve), B2 (frame fetch) and B3 (arg polarity) stayed `[U]` with no native anchor. This worker attempts the native anchor.

## 0. Method, passes, tool limits

### 0.1 Pass ledger (multiple NEW passes on the packed exe, not just script text)

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_document_show` + `native_sections_list` | ev_d5b1af50: 10 sections; CODE `0x401000-0x8f1da8` entropy 6.61, DATA 44 kB, `.bind` `0x96c000-0x98fd70` entropy **7.96 exec** (packed/encrypted region); `.rsrc` 128 kB |
| P2 | `native_strings_find` literal `minFrameBlend/maxFrameBlend/FrameBlend/TAnimation/SwitchToTreeAnimation/AnimationCycle/NumberCycle/acoSmooth/AclAnimation/CyclesMode/acmPlayOnce` | ev_8a06d66a (0 hits minFrameBlend), ev_83e469cb (0 maxFrameBlend), ev_128c0ace (0 FrameBlend), ev_aafd85f7 (0 TAnimation) — **data-section string search finds NONE of the script symbols**; limitation: "only strings stored in the file are searched" i.e. data sections only |
| P3 | `native_strings_find` `TObject/Animation/Blend/System/Delphi/VCL/GetGameObject/MaxFrame` | ev set §1: only `glBlendFunc@0x90ae98` (OpenGL import), `\XAnimation@0x959080` + `XTrackPoint@0x958801` (XGUI skin strings in `.rsrc`), `XTileSmooth`, `XWallConstructor`, `AlphaBlendValue`, `FrameRect/DrawFrameControl` (Win32 imports) — **no animation RTTI in data-section strings, no Delphi/VCL markers** |
| P4 | `native_functions_search` `Blend/Anim/Round/glBlend/Frame` + `native_xrefs_list 0x907d90` | ev_13bb08b6/ev_414855a4/ev_81eeb59c/ev_8f3eb17e/ev_16867739: sole `Blend` hit = `glBlendFunc@thunk 0x4afb14` (render-state, unrelated); 0 `Anim` functions; `Round` = 2 `ForegroundWindow` substring false positives only; `Frame` = 3 Win32 `*Frame*` imports only. `glBlendFunc` xrefs only its thunk (ev_50be950d) |
| P5 | `native_bytes_find` raw `FrameBlend` (`46 72 61 6d 65 42 6c 65 6e 64`) over whole file bytes | ev_9ce63dc9: **19 matches in CODE section** at file offsets `0x1501e3… / 0x22eb4e…` (VAs `0x550de3…`, `0x62f74e…`) — the symbols exist as **CODE-embedded tables**, invisible to the data-section string index (explains P2 zero-hits) |
| P6 | `native_bytes_show` `0x550dd0+320`, `0x550c00+480`, `0x550ee0+480`, `0x550900+800` | ev_059f4d5f/ev_0756a4bc/ev_c2340c84/ev_649d139d: **RTTI/property tables** — `TXAnimation`, `TXAnimations`, `TXBaseActor`/`XBaseActor`, full prop lists (§1.1) |
| P7 | `native_bytes_show` `0x62f600+900`, `0x62f850+900`, `0x62fb00+900`, `0x62fd00+1200`, `0x630100+1200`, `0x630600+1200`, `0x62f300+800`, `0x62ef00+800`, `0x642e00+400` | ev_be6b305a/ev_a083ad4c/ev_d5ecdc3f/ev_2f629430/ev_1572daa6/ev_c01040cd/ev_b7b6acde/ev_084e8f0a: **script-API signature table** with complete native prototypes (§1.2) — resolves B3 arg names |
| P8 | `native_bytes_find` `TAnimation` / `SwitchToTreeAnimation` / `FrameInterpolation` raw | ev_aaf9b82a (14× `TXAnimation`, VAs `0x550923…` + `0x86d82a…`), ev_1b76a8ed (8× `SwitchToTreeAnimation`, `0x6301c2…` + `0x642e66…`), ev_d7d6e508 (6× `FrameInterpolation`, `0x4f6dd8` + `0x550daf` + `0x561a74…` + `0x564120/0x564f70`) |
| P9 | `native_bytes_show` `0x4f6d00+400` (TActor enums), `0x561a00+400` (mesh props), `0x86d800+500` (controller dispatch), `native_function_find 0x561b80` | ev_8780471c (afp*/aam* enums), ev_a954ba18 (mesh `FrameInterpolation` prop + `LoadFromFile`), ev_b1604be2 (`TXAnimationControllerSwitchAnimation`, `acsa*`, `act*` dispatch), ev_0e06229d (`0x561b80` inside `sub_561b80`) |
| P10 | `native_function_disassemble` + `native_function_study sub_561b80` | ev_c4d19985 (garbage decode of `sub_401000` = data-as-code, discarded), ev_0ca87fe3/ev_4b000467 (`sub_561b80`: real mesh-load path consuming `FrameInterpolation@0x561fac`, `esi+0x50/0x58/0x68/0x85/0x6c/0x6d` field traffic — candidate consumer §3, NOT proven per-tick player) |
| P11 | `native_functions_search` `floor/round/sin/cos`, `native_bytes_find System.Round` (`53 79 73 74 65 6d 2e 52 6f 75 6e 64`), `native_xrefs_list` on table VAs | ev_e0aede70 (0 floor imports), ev_df54c131 (round = ForegroundWindow FPs only), ev_be5fc2b6 (sin = WaitForSingleObject/GetClassInfo FPs only), ev_c7c5dbb3 (0 `System.Round` bytes); ev_62b1cc5b/ev_af0e5826 (0 xrefs to `0x550de3`/`0x62f74e`: "references made through computed pointers at run time are not seen") |
| P12 | Donor-text cross-check `Select-String SwitchToTreeAnimationCyclesBlend / DeferredFrameBlend|ResetFrameAnimationBlend` over `C:\Games\Cossacks 3\data\scripts/**` | Script call sites (`unit.script:10891,10970,11016,11042`; `movie.script:586,636-637,646,1022,1076`) use byte-identical procedure names to the native table (§1.2) [O] |

**Strange-read log:** `native_strings_find` searches data sections only — zero-hit does NOT mean absent (P5 proves the symbols live in CODE-embedded tables). `native_functions_list` covers 18918 functions but stopped after 6M instructions + 1238 unresolved indirect jumps: "stripped binary… absence is not proof". `native_xrefs_list` on table addresses returns 0, with the engine's own limitation "references made through computed pointers at run time are not seen" — so a 0-xref is a tool limit, never evidence of dead code. `sub_401000` disassembles as garbage (entry bytes are data/packed); discarded, not cited as code. `.bind` entropy 7.96 + exec = packed region: `native_bytes_find` "compressed, encrypted or packed regions… are not seen, so no match is not proof of absence". No donor binary executed; no donor bytes copied.

---

## 1. What the packed exe DOES contain (new static localization) [O]

### 1.1 RTTI / property tables: native animation field names (CODE-embedded, VAs exact)

**Block A — class descriptors at `0x550900` (ev_649d139d):**

```
TXAnimation … TXBaseActor … Name / StartFrame / EndFrame / AAGroup / AsString …
TXAnimations … FileName … (float tables 0x4740…)
```

**Block B — `TXBaseActor` property table at `0x550c00` (ev_0756a4bc), exact prop sequence [O]:**

```
StartFrame | EndFrame | DirectStartFrame | DirectEndFrame | Reference
CurrentFrame | DirectCurrentFrame | CurrentFrameDelta | FrameInterpolation
CurrentFrameBlend(?) …(continues Block C)
```

**Block C — blend property run at `0x550dd0` (ev_059f4d5f), exact bytes-ascii [O]:**

```
CurrentFrameBlend | StartFrameBlend | EndFrameBlend | AnimationMode
Interval | OrignInterval | Options | OnFrameChanged | OnEndFrameReached
OnStartFrameReached | Animations | AutoCentering | MaterialLibrary | LightmapLibrary …
```

**Block D — mesh-level interpolation enums at `0x4f6d00` (ev_8780471c) [O]:**

```
TActorAnimationReference: aarMorph, aarSkeleton, aarNone, aarTransform
TActorFrameInterpolation: afpNone, afpLinear, afpSkin, afpLSkin
TActorAnimationMode:      aamNone, aamPlayOnce, aamLoop, aamBounceForward, aamBounceBac…
```

**Block E — ACL/Tree player dispatch at `0x86d800` (ev_b1604be2) [O]:**

```
TXAnimationControllerSwitchAnimation: acsaDefault, acsaFirst, acsaRandom
TXAnimationCycleItemAction: actAnimation, actTrackPoint, actTrackPointPreset, actExecuteState
TXAnimationCycleItem: … AnimationName …
```

[D] consequences: (i) the script `acm*/aam*` mode writes (`DEC_U_blend_op` §1.2) target the native `TActorAnimationMode` enum — `aamNone/aamPlayOnce/aamLoop` are now byte-anchored, not just script tokens; `aamBounceForward/aamBounceBack…` exist natively but have **zero** script-side writers found (do not wire them). (ii) `afpLinear` proves a LINEAR interpolation mode exists at mesh level — it does **not** give the blend-window weight curve (still [U]-B1 §2). (iii) `actAnimation/actTrackPoint/actTrackPointPreset/actExecuteState` byte-anchor the ACL item dispatch `DEC_U_blend_op` §1.4 described from `.acl` text.

### 1.2 Script-API (function-pointer/export) table: complete native prototypes `0x62f300–0x630700` [O]

Exact signature strings from ev_c01040cd / ev_be6b305a / ev_a083ad4c / ev_d5ecdc3f / ev_2f629430 / ev_b7b6acde / ev_1572daa6 / ev_084e8f0a:

```
function GetGameObjectStartFrameByHandle(const gohandle: Integer): Integer
procedure SetGameObjectStartFrameByHandle(const gohandle, startframe: Integer)
function GetGameObjectEndFrameByHandle … / Set … (endframe)
function GetGameObjectCurrentFrameBlendByHandle … / Set … (currentframeblend)
function GetGameObjectMaxFrameBlendByHandle …   / Set … (maxframeblend)
function GetGameObjectMinFrameBlendByHandle …   / Set … (minframeblend)
function GetGameObjectStartFrameBlendByHandle … / Set … (startframeblend)
function GetGameObjectEndFrameBlendByHandle …   / Set … (endframeblend)
function GetGameObjectOrignIntervalByHandle …   / Set … (origninterval)     # sic: "Orign", not "Origin"
procedure SetGameObjectCurrentFrameDeltaByHandle(const gohandle: Integer; const delta: Float)
function GetGameObjectFrameAnimationDataByHandle(gohandle; name: String; var startframe, endframe): Boolean
function GetGameObjectAnimationCycleCountFrameByHandle(gohandle; name: String): Integer
function GetGameObjectAnimationCycleLeftFrameByHandle(gohandle): Integer
procedure GameObjectMySwitchToFrameAnimationBlend(name: String; randomframe, smooth: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectSwitchToFrameAnimationBlendByHandle(gohnd; name: String; randomframe, smooth: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectMySwitchToAnimationCyclesBlend(name: String; randomcycles, randomframe: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectSwitchToAnimationCyclesBlendByHandle(gohnd; name: String; randomcycles, randomframe: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectMySwitchToFBAnimationCyclesBlend(name: String; randomcycles, randomframe: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectSwitchToFBAnimationCyclesBlendByHandle(…same…)
procedure GameObjectMySwitchToTreeAnimationCyclesBlend(name: String; randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectSwitchToTreeAnimationCyclesBlendByHandle(gohnd: Integer; name: String; randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean; minframeblend, maxframeblend: Integer)
procedure GameObjectMySwitchToAnimationCyclesBlendDefault(name: String; minframeblend, maxframeblend: Integer)
procedure GameObjectSwitchToAnimationCyclesBlendDefaultByHandle(…)
procedure GameObjectMySwitchToFBAnimationCyclesBlendDefault / …ByHandle …
procedure GameObjectMySwitchToTreeAnimationCyclesBlendDefault / …ByHandle(gohnd; name; minframeblend, maxframeblend)
function GetGameObjectDeferredFrameBlendByHandle(gohandle): Boolean
procedure SetGameObjectDeferredFrameBlendByHandle(gohandle; def: Boolean)
procedure GetGameObjectDeferredFramesByHandle(gohandle; var defcurrentframe, defstartframe, defendframe)
procedure SetGameObjectDeferredFramesByHandle(gohandle; defcurrentframe, defstartframe, defendframe)
procedure GameObjectMySwitchToTreeAnimationCycles(name: String; randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean)   # 0x642e00, non-blend twin, ev_084e8f0a
procedure GameObjectSwitchToTreeAnimationCyclesByHandle(gohandle; name: String; randomcycles, randomframe, randomfbcycles, randomfbframe: Boolean)
```

[D] consequences: (i) the `DEC_U_blend_op` §1.1 "8-arg switch positional map" is now **natively labelled**: `a3=randomcycles, bRandomFrame=randomframe, a5=randomfbcycles, a6=randomfbframe` for the Tree/Cycles family — arg polarity [U]-B3 is resolved **as names** (see §4 for the remaining semantic reserve on `FB`). (ii) The `FrameAnimationBlend` family (unused by units, no script call sites found) carries a second bool named **`smooth`** — the only native blend-adjacent flag beyond `randomframe`; units never call it, so it cannot be the unit weight curve, but it is the correct search seed for any future B1 code hunt. (iii) `Start/EndFrameBlend` + `CurrentFrameDelta: Float` + `DeferredFrames(defcurrent,defstart,defend)` triples exist natively alongside `Min/MaxFrameBlend` — the script layer only ever touches Min/Max + Deferred flag; the rest is engine-internal state (see §5 on the fetch question).

### 1.3 `minFrameBlend`/`maxFrameBlend` as binary field names: FOUND [O]

P2's zero-hit is superseded: `MinFrameBlend/MaxFrameBlend/StartFrameBlend/EndFrameBlend/CurrentFrameBlend` exist byte-identically at `0x550dd0` (property table) and `0x62f74e–0x62fd00` (API table). The script locals `minFrameBlend=6/maxFrameBlend=8` (`unit.script:10846-10847`) therefore write through to `SetGameObjectMin/MaxFrameBlendByHandle` state consumed by the `…Blend(gohnd, name, randomcycles, randomframe, randomfbcycles, randomfbframe, minframeblend, maxframeblend)` engine entry. The literal pair `(6,8)` itself is script-authored (no `06 00 00 00 08 00 00 00` byte run found in the exe, ev_5895c9ca — expected: literals live in script text, and `.bind` is packed so absence proves nothing).

---

## 2. B1 — interpolation OPERATOR / weight curve: still [U]

**Verdict: NO weight formula recovered from code structure.** What P1–P11 add, and what they exclude:

- [O] A mesh-level interpolation MODE enum exists: `afpNone/afpLinear/afpSkin/afpLSkin` (`0x4f6d00`, ev_8780471c), consumed on the mesh load path (`FrameInterpolation` property occurrences `0x561a74/0x561fac/0x564120/0x564f70`, ev_d7d6e508; consumer `sub_561b80` §3).
- [O] `afpLinear` names a linear mode — it does NOT name the blend-window weight `w(t)` over `(min,max)`, its unit (frames/ticks/seconds), its per-channel application, or its normalisation.
- [D] Excluded by structure: the curve is not a second script argument (the Tree/Cycles blend signature carries only `random*` flags + `min/max` ints), not per-AAF data, and not the `smooth` flag (different procedure family, never called by units). The `CurrentFrameDelta: Float` setter (`SetGameObjectCurrentFrameDeltaByHandle(gohandle; delta: Float)`) is the only float-typed frame input found — a candidate accumulator the curve could write through, but no writer was isolated (0-xref tool limit, §3).
- **[U]-B1 stays open.** Capture R-B1 §6 (unchanged from `DEC_U_blend_op` §6, tightened with native field names).

## 3. Native `TAnimation`/ACL player candidates around the hits [I→U]

- **Candidate K1 — `sub_561b80`** (ev_0ca87fe3/ev_4b000467): immediately follows the mesh `FrameInterpolation` property block; prologue `55 8B EC`, makes property-setter calls with `edx=0x561f48/58/70/84/98` and consumes the `FrameInterpolation@0x561fac` table entry (`mov edx,0x561fac; call 0x8971c4`), reads instance fields `[esi+0x50/0x58/0x68/0x85/0x6c/0x6d]`. [I] Shape = mesh/animation object loader resolving interpolation + distance/scale props. **NOT proven to be the per-tick frame player** — no tick loop, no `(min,max)` window arithmetic, no two-frame fetch observed in the disassembled prefix. Candidate only.
- **Candidate K2 — `TXAnimationControllerSwitchAnimation` dispatch (`0x86d800`, ev_b1604be2):** `acsaDefault/acsaFirst/acsaRandom` + `actAnimation/actTrackPoint/actTrackPointPreset/actExecuteState` tables with float rows. [I] Shape = the ACL cycle-item dispatcher `DEC_U_blend_op` §1.4 described from text. No code entry point isolated (table only; xrefs unavailable — computed-pointer tool limit).
- **Honest negative:** `native_xrefs_list` on `0x550de3` and `0x62f74e` returns 0 references (ev_62b1cc5b/ev_af0e5826) under the engine-stated limitation "references made through computed pointers at run time are not seen" — this localizes NOTHING and must not be read as "unreferenced". Function discovery is partial (6M-instruction cap, 1238 unresolved indirect jumps, stripped `sub_…` names). **The per-tick native animation player is therefore NOT localized — [U]-P1 (new).**

## 4. B3 — arg polarity: natively labelled, one semantic reserve left

[O] The ByHandle Tree/Cycles blend prototype (`0x630100`, ev_2f629430) is:

```
GameObjectSwitchToTreeAnimationCyclesBlendByHandle(
  gohnd, name, randomcycles, randomframe, randomfbcycles, randomfbframe,
  minframeblend, maxframeblend)
```

[D] This fixes the `DEC_U_blend_op` §1.1 positional map to native names:

| Script position | Native name [O] | Script values observed |
|---|---|---|
| `a3` | `randomcycles` | `False` everywhere except `ontagstates.inc:500` (`True`) |
| `bRandomFrame` | `randomframe` | `False` on early-out/attack/death, `True` on turn/idle-resolve/walk |
| `a5` | `randomfbcycles` | `False` at every observed site |
| `a6` | `randomfbframe` | `False` at every observed site |

[D] The non-blend twin at `0x642e00` (ev_084e8f0a) repeats the same four `random*` names without blend args — spelling is consistent across two table regions, so this is not a one-off string accident.

- **[U]-B3 narrowed to one reserve:** the `FB` in `randomfbcycles/randomfbframe` + `SwitchToFBAnimationCyclesBlend*` + `DeferredFrameBlend/DeferredFrames` is UNRESOLVED from static bytes (FrameBone? FaceBone? FrameBlend-deferred path?). No semantic is assigned. Capture R-B3 §6 decides it differentially, never by guessing.

## 5. B2 / (d) — is a second exported frame ever fetched? From code structure: NO fetch demonstrated [U]

[D] The native state layout around the player shows **one current-frame register plus a float delta**, not two frame registers:

- Property table (Block B/C): `CurrentFrame | DirectCurrentFrame | CurrentFrameDelta | FrameInterpolation` + `Current/Start/EndFrameBlend`. One `Current*` family, one `Delta: Float` (`SetGameObjectCurrentFrameDeltaByHandle(gohandle; delta: Float)`).
- Deferred path: `DeferredFrameBlend: Boolean` + `DeferredFrames(defcurrentframe, defstartframe, defendframe)` — a **pending triple**, staged while `DeferredFrameBlend` is set; the script layer installs `Deferred(false)` (`initial.inc:17-19`), so the deferred triple is never armed on the unit path [O donor script].
- Mode enum `afpLinear/afpSkin/afpLSkin` selects HOW one frame's vertices are posed/skinned, not WHICH two exported AAF frames are held.

[D] Therefore: nothing in the recovered CODE structure fetches, names, or holds two exported AAF frames simultaneously during a `(min,max)` window. A single `CurrentFrame + Delta + Interpolation-mode` register file is consistent with per-vertex interpolation between adjacent samples of ONE stream — but that last clause is already inference beyond the bytes, so it is marked [I] and NOT used. **(d) answer: from code structure alone, a second exported frame fetch is NOT demonstrated; B2 stays [U].** Capture R-B2 §6 bounds the observable support without inventing a fetch. The port keeps fetching exactly ONE nearest exported frame and labelling it (`fetch_policy:"nearest_single_no_blend [U]-B2"`).

## 6. (b) — `System.Round` / float helpers near AAF frame evaluation: NOT localized [U]

[O] Zero `System.Round` byte runs (ev_c7c5dbb3); zero `floor` imports (ev_e0aede70); `round` = 2 `*ForegroundWindow` substring false positives (ev_df54c131); `sin/cos` = `WaitForSingleObject/GetClassInfo/SystemParametersInfoA` substring false positives (ev_be5fc2b6/ev_e8fe50229). The exe imports no CRT math by name; float work is inline x87/SSE or inside the packed exec `.bind` region (entropy 7.96, "packed regions… are not seen"). **No native rounding helper is localized; AAF frame-index arithmetic stays script-sourced** (inclusive `(ef-sf)` vs exclusive laws, `floor(Random*(End-Start))` birth init — `DEC_U_blend_op` §1.5). No new float-xref exists to cite. [U]-RND stays open; no capture is prescribed against packed bytes (a runtime trace would be needed, out of scope for this read-only worker).

---

## 7. Still-[U] fields — exact frame-index / vertex-hash captures, zero-mismatch termination

All captures: singleplayer skirmish, fixed camera, paused-then-stepped sim, per-tick log `(sim_tick, selected_anim, AAF first..last, requested_frame, displayed_frame, blend_args(min,max), vertex_hash_or_joint_track)`. **No curve, weight, frame, or semantic is invented — a capture either returns a byte-repeatable trace or the [U] stays open.** "Zero-mismatch" = all trials identical frame-for-frame AND hash-for-hash; ONE differing tick/hash fails the capture. Native field names from §1 may be logged as labels only (they add no pose math).

- **[U]-B1 (weight curve `w(t)` over the `(min,max)` window). Capture R-B1:** peaukr `walk 1..20 → idle 64..113` seam stepped 1 tick/frame; log screen-space ankle-joint track (or full-pose vertex hash) for ticks `[-2,+10]` around the switch under `(6,8)` vs forced `(0,0)`. Vary ONLY the tail pair. **Termination:** step-response length in frames + per-tick displacement table, byte-identical 3/3 trials under EACH setting, AND `(0,0)` trace == unsmoothed hard cut (single-tick jump, zero intermediate positions); else stays [U]. Success bounds the SUPPORT only — it never names `w(t)`, never cites `afpLinear` as the blend curve.
- **[U]-B2 (blend-window frame fetch). Capture R-B2:** same seam, but log `GetGameObjectFrameAnimationName` + `GetGameObjectFrameAnimationData(sf,ef)` + displayed frame index per tick (engine-read values, not port clock). **Termination:** displayed-frame sequence byte-identical 3/3 trials, showing exactly which exported frames co-occur during `(6,8)` (e.g. `20,64` hold pattern or intermediate indices with tick numbers); ONE divergent trial fails it. Until then the port fetches exactly ONE nearest frame and labels it.
- **[U]-B3 (FB semantic `randomfbcycles/randomfbframe`, `CyclesList`, `acoSkipActions`). Capture R-B3:** differential run only — replay the SAME attack→idle seam via sim path (`randomcycles=False`, V2 `unit.script:11042`) vs aix-idle-shaped call (`randomcycles=True`, V4 `ontagstates.inc:500`) if the runner can inject it, else unit.script-path vs ontagstates-path units; log displayed frames + hashes. **Termination:** identical-or-different verdict with tick table 3/3 trials; NO semantic name is assigned either way (labels stay `random*` + `[U]-B3-FB`).
- **[U]-C1 (PlayOnce end-between-evaluations). Capture R-C1** (carried, tightened): musketeer `attack1 [99,124]` single shot, 30 Hz trace `t0..t0+span+10`; record hold-at-`124` vs snap-to-`idle1 [256,305]` with tick numbers + vertex hash at last 3 ticks; repeat peasant `death [115,149]`. **Termination:** hold-vs-return verdict with tick numbers, zero mismatch 3/3 per sid.
- **[U]-C2 (handler timing). Capture R-C2** (reframed by `DEC_U_blend_op` §5): cannon `attack0/attack1 [301,337]` firing; log muzzle-flash PFX frame, damage tick, sound tick RELATIVE to `Attack` (opening) vs `AttackEnd` handler firing ticks. **Termination:** effect-to-handler-tick offsets, zero mismatch 3/3, or absence logged.
- **[U]-B4 (movie `0..5` window). Capture R-B4:** movie-path unit play (`_movie_UnitPlayAnimation`, `movie.script:644-646`) with `bBlend` true/false on the same seam; log displayed frames. **Termination:** `maxblend=5` vs `maxblend=0` traces differ-or-identical verdict 3/3. Until then `"0,5"` is NOT added to the port (only `"0,0"`/`"6,8"` exist).
- **[U]-P1 (native per-tick player; new). Capture R-P1:** same as R-B2 but with `DeferredFrameBlend` toggled true once (non-unit harness only — never on the skirmish unit path) to observe whether `DeferredFrames(defcurrent,defstart,defend)` triple changes the displayed sequence. **Termination:** triple-effect verdict 3/3 or no-effect verdict 3/3. Static disassembly of the packed `.bind` region is NOT prescribed (read-only bytes, no tooling that defeats packing).

## 8. Exact port change list for `anim3d.gd` (file/line; NO code written here)

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement |
|---|---|---|---|
| F1 | `DONOR_BLEND_SITES` string (`anim3d.gd:175` per DEC_U_blend_op F6) | Native prototypes now byte-anchored: Tree/Cycles blend = `(randomcycles, randomframe, randomfbcycles, randomfbframe, min, max)`; Frame blend = `(randomframe, smooth, min, max)` (§1.2) | EXTEND the string: cite `cossacks.exe 0x630100/0x642e00` signature table + `0x550c00/0x550dd0` property table; record `a3/a5/a6 = randomcycles/randomfbcycles/randomfbframe [O-names]`, `FB semantic [U]-B3-FB`. String-only change. |
| F2 | `DONOR_BLEND_ARGS_STATUS` (new const proposed in DEC_U_blend_op F8) | `smooth` exists but ONLY in the never-called-by-units `FrameAnimationBlend` family; `FB*`/`Deferred*` families exist natively but are never armed on the unit path | ADD the const recording exactly: four `random*` names, `smooth` (Frame-family only, not unit path), `Deferred(false)` install + unarmed deferred triple, `aamBounce*`/`afp*` exist-but-unused. No behavioural branch. |
| F3 | `_frame_at` once-clamp vs `fposmod` loop + `aaf_completion_probe` | `TActorAnimationMode` enum natively anchored incl. `aamBounceForward/aamBounceBack…` with zero script writers (§1.1 D) | KEEP clamp; extend probe comment: `aamBounce*` observed natively, unwritten by scripts — do NOT implement. String-only. |
| F4 | `_nearest_exported_frame` + `fetch_policy` label | §5: single `CurrentFrame + Delta + mode` register file; NO two-frame fetch demonstrated | LABEL ONLY: extend `fetch_policy` string to cite `0x550c00` (`CurrentFrame/DirectCurrentFrame/CurrentFrameDelta/FrameInterpolation`) as the native register file consistent-with (not proof-of) single-stream interpolation. No second frame fetched. |

Rows outside this worker's ask (`world3d_entities.gd`, orders, building visuals) are **not restated**.

Required donor asset manifest (all already on disk; sourced only through approved converters, **not copied here**): `cossacks.exe` VAs `0x4f6d00/0x550900/0x550c00/0x550dd0/0x550ee0/0x561a00/0x62f300–0x630700/0x642e00/0x86d800` (ev ids §0.1) + `D:scripts/lib/unit.script` (`:10846-10847,:10891,:10970,:11016,:11042`) + `D:scripts/lib/movie.script` (`:586,:636-637,:644-646,:1022,:1076`) + `D:scripts/units/unit.inc/ontagstates.inc` (`:500`) + `D:scripts/units/unit.inc/initial.inc` (`:17-19`).

---

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `Min/Max/Start/End/CurrentFrameBlend`, `CurrentFrame/DirectCurrentFrame/CurrentFrameDelta/FrameInterpolation`, `DeferredFrameBlend/DeferredFrames` exist as native CODE-embedded tables (`0x550c00/0x550dd0/0x62fxxx`) with exact signature strings | [O] ev_059f4d5f/ev_0756a4bc/ev_be6b305a/ev_a083ad4c/ev_d5ecdc3f/ev_2f629430/ev_1572daa6/ev_c01040cd (§1) |
| 2 | `TXAnimation/TXAnimations/TXBaseActor`, `TActorAnimationReference/Mode/FrameInterpolation` (`aar*/afpNone/afpLinear/afpSkin/afpLSkin/aam*`), `TXAnimationControllerSwitchAnimation` (`acsa*`), `TXAnimationCycleItemAction` (`act*`) enums byte-anchored | [O] ev_649d139d/ev_8780471c/ev_b1604be2 (§1.1) |
| 3 | 8-arg switch tail maps to `randomcycles, randomframe, randomfbcycles, randomfbframe, minframeblend, maxframeblend`; Frame-family second bool is `smooth`; non-blend twin confirms spelling | [O] ev_2f629430/ev_084e8f0a (§1.2/§4) |
| 4 | Script call-site names byte-identical to native table names (`unit.script`, `movie.script` cites §0.1 P12) | [O] donor text reads |
| 5 | Script symbols absent from data-section string index; live in CODE-embedded tables; `.bind` packed (entropy 7.96); function discovery partial; xrefs on tables return 0 under stated computed-pointer limit | [O] ev_8a06d66a/ev_83e469cb/ev_128c0ace/ev_aafd85f7/ev_d5b1af50/ev_76fe7a0b/ev_62b1cc5b/ev_af0e5826 |
| 6 | No `System.Round` bytes, no `floor/round/sin/cos` imports (only `*ForegroundWindow*`/`WaitForSingleObject/GetClassInfo` substring FPs) — native float helper NOT localized | [O-absence with packed-region reserve] ev_c7c5dbb3/ev_e0aede70/ev_df54c131/ev_be5fc2b6 (§6) |
| 7 | `sub_561b80` mesh-load consumer of `FrameInterpolation@0x561fac` — candidate, NOT the per-tick player; per-tick player NOT localized | [I→U] ev_0ca87fe3/ev_4b000467 (§3) |
| 8 | Weight curve `w(t)`: `afpLinear` names a mode, never the window curve; no formula in readable bytes | [U]-B1 §2 |
| 9 | Blend-window fetch: single `CurrentFrame+Delta+mode` register file + unarmed deferred triple; NO second exported frame fetch demonstrated from structure | [U]-B2 §5 |
| 10 | `FB` in `randomfbcycles/randomfbframe` + FB/Deferred families: names observed, semantic unresolved | [U]-B3-FB §4 |
| 11 | Every [U] has a fixed-camera frame-index/vertex-hash capture with zero-mismatch termination (R-B1/R-B2/R-B3/R-C1/R-C2/R-B4/R-P1) | [D] §7 |
| 12 | Any port motion/timing/blend equal to donor, any invented curve/frame/semantic/player, or any runtime PASS | **Denied** — no same-camera donor/port A/B exists; visual UNVERIFIED |

## 10. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) and the read-only `C:\Games\Cossacks 3\data` script tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-BLEND-DEEP.*
