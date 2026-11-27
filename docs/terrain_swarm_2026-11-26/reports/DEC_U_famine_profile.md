---
id: DEC-U-FAMINE-PROFILE
worker: DEC-U-FAMINE-PROFILE (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Recover statically the exact shipped default of the famine profile flag, where read/written, and the mercenary rebellion target/count law; file/line port note for data.gd/game.gd"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts read as text only. No repo code/asset/config/Godot/git change: this report is the only file written."
network: "OUT OF SCOPE."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. No behaviour change."
upstream: "DEC_U_skirmish.md §2.1 (§9-U11-P/U11-M experiments); DEC_U_skirmish_impl_patch.md §1; DEC_U_morale_audit.md §1.1/§2; DEC_U_settings_persist.md §3.3/§4.1/§6 (profile store contract)"
---

# DEC-U famine profile — shipped default, read/write sites, mercenary rebellion target (2026-11-26)

## 0. Verdict up front

1. **Shipped default of the famine profile flag is RECOVERED: `TRUE`.**
   `[O]` `data/scripts/lib/profile.script:39`, inside `_profile_SetDefault(var profile : TProfile)`:
   `profile.bFamine := true;` (field declared `[O]` `lib/classes.script:5122`, `bFamine : Boolean;`,
   in the `TProfile` record). This closes the value half of `[U]-U11-P`. No default was invented.
2. **Read sites RECOVERED (all three):** per-unit death gate `[O]`
   `data/scripts/units/unit.inc/nothing.inc:450`
   (`if gProfile.bFamine and (gPlayer[plInd].bfamine) and (bplayable) then`);
   HUD/log warning gate `[O]` `data/gui/menu.inc/doprogress.inc:239`
   (`if gProfile.bFamine and (gPlayer[myPlInd].counter.resconsume[food]>0) and (not res[food]<=0) then`
   → `gc_logmessagesid_famine`, game/spectator only at `:241-244`, editor-mode branch at `:246-252`);
   plus four AI-sampler reads of the *player* flag (not the profile flag) `[O]`
   `units/global.inc/progresseconomicai.inc:748,975,2920,3059` (`gPlayer[plind].bfamine`).
3. **Write sites RECOVERED as far as text allows:** the *default* write is `profile.script:39`
   (called at boot `[O]` `profile.script:729` `_profile_SetDefault(gProfile)` **before**
   `[O]` `:736` `_profile_LoadStructFromUserProfileParser('gProfileUserStruct')` and `[O]` `:642`
   `StateMachineGlobalVariablesLoadFromStack(..., 'gProfile', '')`, so a stored profile
   overwrites the shipped `true` on load). All *persistence* writes go through engine natives
   with **zero script-side procedure/function definitions** (verified this ticket, §2:
   `UserSaveProfile`, `UserSaveProfileExt`, `ParserSelectUser`,
   `StateMachineGlobalVariablesSaveToStack/LoadFromStack`, `GetUserProfileStateMachineHandle`,
   `GetAppSaveDirectoryPath`, `StateMachineGlobalVariablesSaveToParser/LoadFromParser` —
   called at `profile.script:273,280,287,546-552,617-650` but defined nowhere under
   `data/scripts`). Their file encoding/flush timing is therefore NOT recoverable from text
   (same `[U]` as `DEC_U_settings_persist.md` §6 U-SP5). No `.cfg`/`.res`/`.ini` under
   `data/` contains `bFamine|bfamine|FAMINE` (negative grep this ticket, §2) — i.e. there is
   **no `config.gd`-equivalent cfg-file default**; the shipped default lives only in
   `profile.script:39` plus the native user-profile store.
4. **Menu-writer result: NO famine toggle exists in the options/menu scripts.**
   Negative greps this ticket: `eventsettings.inc` + `showsettings.inc` for
   `famine|Famine|bFamine` → **0 hits**; `_profile_ClampProfileValues`
   (`profile.script:502-561`) clamps only sounds/scroll-speeds/`igamespeed`/locale and never
   touches `bFamine`. So the only script-side write of `gProfile.bFamine` is the shipped
   default itself. (Whether a native/menu surface outside `data/scripts` can flip it is
   engine-side and stays `[U]-P-store`; §5 experiment FP-2.)
5. **Mercenary rebellion target/count law RECOVERED:** gate `[O]` `nothing.inc:487`
   (`brebellion and bmercenary and (plInd<>mercenaryind) and (bplayable)`, game/spectator
   gate `:489`); count law `[O]` `:492`
   `((difficulty>1) and (RandomInt<6000)) or ((difficulty=0) and (RandomInt<100)) or
   ((difficulty=1) and (RandomInt<200))` with `_misc_RandomInt = floor(random*32768)` `[O]`
   (`lib/misc.script:494-498`, `gc_c1rand_to_random=32768` `[O]` `dmscript.global:176`);
   target `[O]` `:494-495` `var plMercHnd := GetPlayerHandleByIndex(gc_player_mercenaryind);`
   `→ _misc_ChangePlayer(myHnd, plMercHnd, False, False, True)`, where `[O]`
   `gc_player_mercenaryind = gc_MaxPlayerCount-1` (`dmscript.global:776`) `= 12-1 =` **slot 11**
   (`gc_MaxPlayerCount = 12` `[O]` `dmscript.global:97`; non-spectator cap 8 at `:98`).
   `_misc_ChangePlayer(goHnd, newPlHnd, bCapture, bCustom, blan)` `[O]` (`miscext.script:894`)
   re-homes the object (`SetGameObjectPlayerHandleByHandle` + `TObj(pl) := newPlInd` at
   `:914-916`, counter move at `:913/:918`, inside-of-mine recursion at `:922-946`, LAN
   write-back only if `blan and (online or record)` at `:949`). So the rebellion flip hands
   the unit to **player slot 11**. `bmercenary` is a per-sid `TObjProp` flag `[O]`
   (`unit.script:612-614`: `dip`-suffix sids — `roundshierdip/lightinfantrydip/archerdip/
   grenadierdip/cossacksichdip/dragoon18dip/archerturdip/lightcavalrydip` — set
   `objprop.bmercenary := True` at `:728,:764,:1055,:1312,:1385,:1655`, plus `:2009`;
   22 `bmercenary` hits in `unit.script` this pass). Corroborating consumer `[O]`
   `unit.script:3944`: rebellion-owned mercenary dead-score modifier `3` (vs `5` captured, `2` else).
   What stays `[U]-U11-M` is **port-side only**: the port has no slot-11 mercenary player and
   no `dip`-sid mercenary flag table, so the flip *target* has no port counterpart (§5 FP-3).
   No target was invented.
6. **`progress.inc` role (ticket explicitly asks):** `units/global.inc/progress.inc` contains
   **no famine/rebellion/mercenary literal** (negative grep this ticket, §2). Its role is
   structural: `[O]` `:147` calls `_player_ProcessResourceConsume(plind, deltatime)` — the
   upkeep engine (`player.script:270-322`) that sets/clears `bfamine/brebellion` — inside the
   per-player slice (exists-check `:57-128` → consume `:147` → squad/AI tail `:177`).
   `bfamine/brebellion` storage is `[O]` `TPlayer` fields (`classes.script:3695-3696`),
   zeroed at `[O]` `player.script:122-123`.
7. **Port note (label-only unless recovered):** `variant3d/scripts/data.gd:454-470` and
   `variant3d/scripts/game.gd:5893-5901,6105-6145,6901-6935` already encode the exact
   50/12/5 + 6000/100/200 + `floor(random*32768)` laws (RESOLVED, keep verbatim).
   Only the two `[U]` comments need label updates (§6): `data.gd:461-464` `[U]-U11-P`
   (default half now RECOVERED-`true` — update the comment to cite `profile.script:39`;
   keep `FAMINE_PROFILE_ENABLED := true` as a labelled port gate, since the native
   load-overwrite path is engine-side); `game.gd:6897,6918-6921` `[U]-U11-M`
   (target half now RECOVERED-**slot 11** — update the comment to cite
   `dmscript.global:776` + `nothing.inc:494-495`; keep the no-mercenary-slot `[U]` tag).
   `FAMINE_GRACE_S/DRAIN` (`data.gd:459-460`, written `config.gd:694-695`) have **zero
   readers in `game.gd`** (verified this ticket) — keep DEPRECATED, never rewire.
   `app/scripts/data.gd:96-97` is the pre-patch copy (no `FAMINE_PROFILE_ENABLED`, no
   deprecation header); leave for the owning worker, do not touch here.

No parity claimed. No donor binary executed. Exactly one file written (this report).

## 1. Pass ledger (owner rule; every static read pinned to `t_87f0f3c130b0`)

| # | Pass | Result |
|---|---|---|
| P0 | Pin | `Get-FileHash cossacks.exe SHA256` = `87F0F3C130B0…AF4E16C`, `Length 5768048` = 5,768,048 B → `t_87f0f3c130b0` confirmed this ticket |
| P1 | Shipped default | `profile.script:7-62` full `_profile_SetDefault` read → `bFamine := true` at `:39` (EV-FP-01). Field decl `classes.script:5122` (EV-FP-02) |
| P2 | Profile-flag readers | Recursive `bFamine` grep over `data/scripts` → 5 files: `classes.script:3695,5122`, `player.script:122,295,304,320-321`, `profile.script:39`, `progresseconomicai.inc:748,975,2920,3059`, `nothing.inc:450` (EV-FP-03). Full `famine` grep over `data/` (scripts+gui+locale+cfg) → readers `doprogress.inc:239`, `showaidebug.inc:27`, `locale/*/gui.txt:45-46,254` + mission flavour (EV-FP-04) |
| P3 | Menu/config writer search (expected-negative) | `eventsettings.inc`+`showsettings.inc` × `famine|Famine|bFamine` → 0 hits; `_profile_ClampProfileValues` `:502-561` read → never touches `bFamine`; recursive `*.cfg,*.res,*.ini` × `bFamine|bfamine|FAMINE` → 0 hits (EV-FP-05) |
| P4 | Upkeep engine | `player.script:270-322` full read (EV-FP-06): `mult=100/speed=20000` accumulator, set/clear gates `:294-321`, `TPlayer` zeroing `:122-123` |
| P5 | Unit roll + rebellion | `nothing.inc:440-510` full read (EV-FP-07): gate `:450-455`, dead inside-mine branch `:456-479` (`{...}` commented out), death roll `:482`, rebellion gate `:487` + rolls `:492` + target `:494-495` + editor branch `:498-505` |
| P6 | RNG + constants | `misc.script:486-498` (`_misc_RandToRandom`, `_misc_RandomInt`) + `dmscript.global:170-176` (conversions, `gc_c1rand_to_random=32768`) + `:97-102,776,781-786` (player-count/difficulty enums) + `:2351` (EV-FP-08) |
| P7 | Rebellion target mechanics | `miscext.script:894-958` `_misc_ChangePlayer` body read (EV-FP-09); `unit.script` `bmercenary` 22-hit enumeration + `:612-614` sid list + `:3944` score branch + `:5659-5674/:5937-5952` `costmodifier>2` merc-cost path (EV-FP-10) |
| P8 | Native loader boundary | `profile.script:269-287,546-552,617-650,729-740` save/load/boot sequence read (EV-FP-11); recursive `*.script` × `procedure|function UserSaveProfile|StateMachineGlobalVariablesSaveToStack|ParserSelectUser` definitions → **0 definitions** (callers only) — engine natives (EV-FP-12) |
| P9 | `progress.inc` role | `global.inc/progress.inc` × `famine|rebellion|mercenary|bFamine` → 0 content hits; `:57-178` slice read → `:147` consume call (EV-FP-13) |
| P10 | Prior binary passes (cited, not re-run) | `DEC_U_skirmish.md` §1 P1-P5 pinned to same `t_87f0f3c130b0`: `core_session_show` + `core_feature_find "SetRandomKey"/"RandomExt"/"bfamine"/"famine"` + `native_bytes_find "victorystate"+"bfamine"` → all negative as designed (script-side law); `ev_c3804981595ae8e32f7250a675c54a63981f` (negatives), `ev_4dd1780e0bbdb16190c7009abf5f33e0d90092007f04019e45dd25ee1025bf` rejected 2-byte pattern |
| P11 | Port anchoring | `variant3d/scripts/data.gd:33,440,453-477,1742` + `game.gd:522-524,5891-5901,6105-6145,6901-6935,6959,9206,9614` + `config.gd:181-182,688-695` read; `game.gd` × `FAMINE_GRACE_S|FAMINE_DRAIN_PER_S` → 0 readers (EV-FP-14) |

Donor text was read with `Get-Content`/`Select-String` only. The donor binary was hashed
(P0), never executed, never copied.

## 2. Shipped default — full evidence

**EV-FP-01 `[O]`** — `C:\Games\Cossacks 3\data\scripts\lib\profile.script:7-62`
(`_profile_SetDefault`, selected lines):

```
9:    profile.name := '';
...
27:    profile.bautosave := True;
...
31:    profile.binfiniteonleftclick := False;
...
38:    profile.bcenterfirstrow := false;
39:    profile.bFamine := true;              <-- SHIPPED DEFAULT: TRUE
40:    profile.bRestrictCamera := true;
41:    profile.bDbgCamera := false;
```

**EV-FP-02 `[O]`** — field declaration, `lib/classes.script:5121-5123`:

```
5121:    bcenterfirstrow : Boolean;
5122:    bFamine : Boolean;
5123:    bRestrictCamera : Boolean;
```

(`TProfile` record; cf. `TPlayer` side `classes.script:3695-3696`:
`bfamine : Boolean; brebellion : Boolean;`.)

**Boot order `[O]`** (`profile.script:729-737`): `_profile_SetDefault(gProfile)` (`:729`) →
`_profile_SetDefaultProjectOptions` (`:730`) → `_profile_LoadUserProfile` (`:731`) →
`_profile_SetLocaleFromResource` (`:732`) → `_profile_GetDisplayModeFromResource` (`:733`) →
`_profile_ApplySoundOptions` (`:735`) → `_profile_LoadStructFromUserProfileParser` (`:736`).
`_profile_LoadUserProfile` itself (`:639-652`) does
`StateMachineGlobalVariablesLoadFromStack(GetUserProfileStateMachineHandle, 'gProfile', '')`
(`:642`) then `Clamp → Cheats → ServerBasedOnLocale → SaveToStack+SaveProfileExt` (`:644-650`).
`[D]`: on a machine WITH a stored profile the stored `bFamine` wins; the shipped `true`
governs fresh/first-run state. The stored bytes' encoding is engine-side (`[U]`-P-store, §5).

## 3. Where the flag is read and written

### 3.1 Reads (recovered, all script-side)

| # | Site | Text `[O]` | Role `[D]` |
|---|---|---|---|
| R1 | `units/unit.inc/nothing.inc:450` | `if gProfile.bFamine and (gPlayer[plInd].bfamine) and (bplayable) then` | Master death-roll gate (then mode/unit-type gates `:452-454`, roll `:482`) |
| R2 | `gui/menu.inc/doprogress.inc:239` | `if gProfile.bFamine and (gPlayer[myPlInd].counter.resconsume[food]>0) and (not res[food]<=0) then` | HUD/log famine warning (`gc_logmessagesid_famine` `:244`; editor-mode variant `:246-252`) |
| R3-R6 | `units/global.inc/progresseconomicai.inc:748,975,2920,3059` | `if (gPlayer[plind].bfamine) then` / `if (onFood<requiredFood) or (gPlayer[plind].bfamine) then` | AI sampler reads of the **player** flag (recall/assignment guards), not the profile flag |
| R7 (display) | `gui/menu.inc/showaidebug.inc:27` | `... + ' Famine: '+ BoolToStr(gPlayer[i].bfamine)` | AI debug overlay only |
| R8 (locale) | `locale/*/gui.txt:45-46,254` | `WARNING! A famine has befallen your state!` / `You are very low on food! Famine is possible.` | Strings for R2's log ids; no logic |

### 3.2 Writes

| # | Site | Text `[O]` | Role `[D]` |
|---|---|---|---|
| W1 | `profile.script:39` | `profile.bFamine := true;` | **Only script-side write of `gProfile.bFamine`.** Shipped default |
| W2 | native store | `StateMachineGlobalVariablesSaveToStack(..., 'gProfile', '')` (`:621,:633,:649`) + `UserSaveProfile` (`:622`) / `UserSaveProfileExt` (`:280,:635,:650`) + `LoadFromStack` (`:642`); struct key `'gProfileUserStruct'` (`:273,:287,:546-552`) | Persistence + boot-load (engine natives, zero script definitions — EV-FP-12). Byte format/flush timing `[U]` |
| W3 | menu/clamp | **none found** — `eventsettings.inc`/`showsettings.inc` famine grep 0 hits; `_profile_ClampProfileValues` (`:502-561`) never references `bFamine` | No options-menu writer in readable scripts (EV-FP-05). A native-only surface cannot be excluded — `[U]`-P-store |

### 3.3 `config.gd`-equivalent cfg files (expected-negative)

Recursive grep over `C:\Games\Cossacks 3\data\` `*.cfg,*.res,*.ini` for
`bFamine|bfamine|FAMINE` → **0 hits** (EV-FP-05). There is no shipped cfg-file famine
default to port; `config.gd`'s `economy.famine_grace_seconds/drain_per_second` keys are a
port-side surface with no donor counterpart (cf. `DEC_U_morale_audit.md` §2: wrong-shape
invention, zero sim readers).

## 4. Mercenary rebellion target/count law — full evidence

**EV-FP-07 `[O]`** — `data/scripts/units/unit.inc/nothing.inc:487-497`:

```
487:         if (gPlayer[plInd].brebellion) and (TObjProp(pobjprop).bmercenary) and (plInd<>gc_player_mercenaryind) and (bplayable) then
488:         begin
489:            if (gInterface.gamemode=gc_gamemode_game) or (gInterface.gamemode=gc_gamemode_spectator) then
490:            begin
491:               // �d�ad��� ����� _����, � ������ ���� � �ad��� �� �������� ������ ��� ����� (mojibake comment: rebellion branch)
492:               if ((gPlayer[plInd].difficulty>1) and (_misc_RandomInt<6000)) or ((gPlayer[plInd].difficulty=0) and (_misc_RandomInt<100)) or ((gPlayer[plInd].difficulty=1) and (_misc_RandomInt<200)) then
493:               begin
494:                  var plMercHnd : Integer = GetPlayerHandleByIndex(gc_player_mercenaryind);
495:                  _misc_ChangePlayer(myHnd, plMercHnd, False, False, True);
496:               end;
497:            end
```

Count law `[D]`: per-tick, per-unit, single `_misc_RandomInt` draw vs 6000 (hard/veryhard/
impossible or LAN-cached — note: unlike the death roll at `:482`, the rebellion roll does
**not** OR in `gbool_lan_isonlinecached`; difficulty-gating only), 100 (easy), 200 (normal),
i.e. P = threshold/32768. The death roll for comparison `[O]` (`:482`):

```
482:                  if (((gPlayer[plInd].difficulty>1) or (gbool_lan_isonlinecached)) and (_misc_RandomInt<50)) or ((gPlayer[plInd].difficulty=0) and (_misc_RandomInt<5)) or ((gPlayer[plInd].difficulty=1) and (_misc_RandomInt<12)) then
483:                  _unit_SetTagStates(myHnd, gc_statetag_essential_death);
```

Target law `[D]`: `gc_player_mercenaryind = gc_MaxPlayerCount-1` `[O]`
(`dmscript.global:776`), `gc_MaxPlayerCount = 12` `[O]` (`dmscript.global:97`) →
**player slot index 11**. `GetPlayerHandleByIndex(11)` → handle → `_misc_ChangePlayer`
(`miscext.script:894`, body `:894-958`, EV-FP-09) performs: resolve `newPlInd` (`:895`),
drop non-move orders if visible (`:900-910`), `RemoveObjFromPlayerCounters` (`:913`),
`SetGameObjectPlayerHandleByHandle` (`:914`), `TObj(pl) := newPlInd` (`:916`),
`AddObjToPlayerCounters` (`:918`), highlight (`:919`), mine-insider recursion (`:922-946`),
conditional LAN `WritePlayer` (`:949-956`, only `blan and (online or record)` — rebellion
passes `True`, so recorded/online games replicate it).

`bmercenary` membership `[O]` (EV-FP-10): local `var bmercenary : Boolean;`
(`unit.script:612`) set `True` (`:614`) iff sid has `dip` AND is one of
`roundshierdip|lightinfantrydip|archerdip|grenadierdip|cossacksichdip|dragoon18dip|
archerturdip|lightcavalrydip` (`:613`); `objprop.bmercenary := True` at
`:728,:764,:1055,:1312,:1385,:1655` (+`:2009`); `TObjProp` flag consumed at
`nothing.inc:487`, `unit.script:3944` (rebel-merc death score ×3), `:5659-5674` and
`:5937-5952` (`bmercenary and (costmodifier>2)` mercenary-cost path — the
`expensivemercs` dip-mode tail). Full per-sid mercenary roster audit is out of scope;
the eight `dip` sids above are the script-literal membership rule — do not extend by analogy.

Upkeep side (who raises `brebellion`) `[O]` (EV-FP-06, `player.script:270-322`):
per-resource `mult=100, speed=20000` bank accumulator (`:281-287`,
`resconsume*=gc_time_to_frames(32)` at `:284`); shortfall path (`:299-311`): food →
`bfamine := True` (`:304`); gold → `brebellion := True` **iff**
`resconsume[gold] > resincome[gold]` (`:306-307`), else `False` (`:309`). Surplus path
(`:289-298`) clears on successful deduction (`bfamine/brebellion := False`, `:295-296`).
Post-loop hysteresis (`:318-321`): `brebellion := False` iff `res[gold] < 2` or consume ≤ 0;
`bfamine := False` iff `res[food] ≤ 0` or consume ≤ 0. (DSL note per `DEC_U_skirmish.md` §0:
`not X` on a numeric lvalue is the value-read operator.) Characteristic: rebellion can only
*start* while the player still holds gold (shortfall of the *flow* with `consume>income`)
and clears when the *stock* drops below 2.

## 5. Still-`[U]` items with fixed-seed capture specs (zero-mismatch criteria; never invent)

### FP-1 `[U]-U11-P-store` — native profile store byte contract (default VALUE now resolved)

Law status: shipped default `true` (EV-FP-01) + all script-side readers/writers (§3) are
`[O]`; only the engine-native store bytes/flush-timing (which physical file, when a
first-run `true` is materialised vs held in memory) are `[U]` (same boundary as
`DEC_U_settings_persist.md` U-SP5).
Capture (owner-authorised, donor executed by owner — never by this worker):
fixed seed S, fresh profile (rename existing user-profile dir aside, owner backup first),
headless boot, no Start pressed: dump script-visible `gProfile.bFamine` via an owner
harness read + snapshot the native store file bytes. Then Accept options with no change,
snapshot again. **Zero-mismatch termination:** script-visible value reads `true` on all 3
fresh-boot repeats; no-change Accept leaves store bytes identical across 3 repeats; any
byte difference must be quoted field-by-field, never absorbed into the port.

### FP-2 `[U]-P-menu` — absence-of-writer confirmation for any native-only famine surface

Law status: no writer in any readable script/menu/clamp/cfg (EV-FP-05, 0-hit greps with
file lists in §1 P3). `[U]`: a native options surface outside `data/` text could still flip
`gProfile.bFamine` at runtime (cannot be excluded statically).
Capture: fixed seed S, `gProfile.bFamine=true`, 1 peasant/side, difficulty normal (rebellion
200 / famine 12), game mode, fixed-`dt` headless: (A) 600-tick soak with zero menu interaction;
(B) identical soak opening/closing every options submenu without Apply. Dump per-tick
famine deaths + `bfamine` flag trace. **Zero-mismatch termination:** A and B traces
identical across 3 repeats each (death ticks, victim ids, flag edges); any divergence names
the interacting surface and stays `[U]` until its script/native address is cited.

### FP-3 `[U]-U11-M-port` — port mercenary-slot mapping (donor target law RESOLVED slot 11)

Law status: donor target = slot 11 via `plMercHnd` (EV-FP-07/09 + `dmscript.global:776,97`)
is `[O]`; the port has no slot-11 mercenary player and no `dip`-sid flag table
(`game.gd:6918-6935` comment). Never invent a mercenary faction/player values.
Capture: fixed seed S, difficulty normal (rebellion threshold 200 → P=200/32768),
`gProfile.bFamine=true`, one `bmercenary` unit (any §4 sid, e.g. `lightinfantrydip`-class)
owned by slot 0 with `brebellion=true` forced via upkeep shortfall (`consume>income`,
stock ≥ 2 per `:306-307,318`), game mode, fixed-`dt`: run until first rebellion flip or
20 000 ticks. Dump flip tick + pre/post owner + `RandomInt` draw stream around the flip.
**Zero-mismatch termination:** port flip tick/owner/draws match the donor-law model
(single `floor(random*32768)<200` draw per tick per unit, target slot 11) on 3 repeats with
the same seed; stream attribution stays `[U]-G1` (D02 second-`Random()`-instance caveat)
and any ledger mismatch must be quoted, never retuned.

### FP-4 `[U]-G1-g` — RNG stream attribution of the famine/rebellion draws

Law status: draw formula `floor(random*32768)` is `[O]` (EV-FP-08); which engine stream
(`RandomExt` LCG vs Delphi second `Random()` per D02 §4.5) feeds `_misc_RandomInt` at the
`nothing.inc:482,492` call sites is `[U]` (impl-patch §1 header, `PORT1TO1` U20).
Capture: X21 20-vector fixture + per-site draw-count test (`DEC_U_skirmish.md` §3-G1):
fixed seed S, famine-only soak (rebellion flag held false), log every `_misc_random_int()`
call site + value. **Zero-mismatch termination:** port `data.gd:1742` ledger site
`famine_rebellion: floor(random*32768)` reproduces the exact draw sequence and the exact
death-tick set across 3 repeats; any extra/missing draw is a hard failure of the ledger,
not a tolerance.

## 6. Port note — `variant3d/scripts/data.gd` / `game.gd` (file/line; label-only)

Preserve the existing exact famine laws. Only the two `[U]` comments change; no constants,
no thresholds, no behaviour, no parity claim.

| # | Port site (as-read this pass) | Donor recovery this ticket | Action (comment text only) |
|---|---|---|---|
| 1 | `data.gd:454-460` DEPRECATED header + `FAMINE_GRACE_S := 120.0` / `FAMINE_DRAIN_PER_S := 0.3` (kept for `config.gd:694-695` writes) | Donor has NO grace/HP-drain (`nothing.inc:450-506` roll-only; `player.script:270-322` flag-only); **zero readers in `game.gd`** (EV-FP-14) | KEEP verbatim. Do NOT rewire any consumer to these statics |
| 2 | `data.gd:461-464` `[U]-U11-P` comment + `FAMINE_PROFILE_ENABLED := true` | Default half RECOVERED: shipped `bFamine=true` (EV-FP-01 `profile.script:39`, field `classes.script:5122`); reads R1-R2 (§3.1); no cfg/menu writer (EV-FP-05) | Update ONLY the comment: replace `donor gProfile.bFamine default not cited this ticket` with `donor shipped default TRUE (profile.script:39, _profile_SetDefault; field classes.script:5122). Native store-overwrite on boot (profile.script:642,729-736) is engine-side [U]-P-store. Port gate value TRUE matches the shipped default but remains a labelled PORT gate (not a donor-literal claim).` Keep `= true` |
| 3 | `data.gd:465-470` `PORT_MORALE_FAMINE_ENABLED` quarantine marker | Unchanged (morale-audit scope) | KEEP verbatim |
| 4 | `game.gd:5893-5901` `C1RAND_TO_RANDOM/FAMINE_ROLL_*/REBEL_ROLL_*` + `game.gd:6105-6145` upkeep set/clear + `game.gd:6901-6935` `_tick_famine_rebellion` | Exact donor transcription (`nothing.inc:450-506`, `misc.script:493-498`, `dmscript.global:176`, `player.script:294-321`); only neighbours `[U]` | KEEP all literals/behaviour verbatim |
| 5 | `game.gd:6897-6900` `gProfile.bFamine default is [U] (profile.script:39; experiment §9-U11-P)` header | Default RECOVERED true; experiment FP-1/FP-2 replace §9-U11-P | Update ONLY the comment per row 2 (cite `profile.script:39` as read literal; retain `[U]-P-store` for the native bytes). Do NOT hard-code any new branch |
| 6 | `game.gd:6918-6921,6929-6931` rebellion `[U]-U11-M` comment + slot-guard `merc >= 0 and merc < players.size() and merc != pl` | Target RECOVERED: slot 11 = `gc_MaxPlayerCount-1` (`dmscript.global:776,97`), `plMercHnd` + `_misc_ChangePlayer(go, mercHnd, False, False, True)` (`nothing.inc:494-495`, `miscext.script:894-958`); `dip`-sid membership rule (`unit.script:612-614`) | Update ONLY the comment: `donor flip target = player slot 11 (gc_player_mercenaryind, dmscript.global:776; GetPlayerHandleByIndex→_misc_ChangePlayer, nothing.inc:494-495). Port merc-indirection (mercenary flag/slot) stays [U]-U11-M-port: do NOT invent a mercenary faction/player; FP-3 capture decides.` Keep the guard behaviour |
| 7 | `game.gd:6959` morale-gated display, `game.gd:9206,9614` save framing `bfamine/brebellion`, `config.gd:181-182,688-695` deprecated keys | Out of scope / save bytes `[U]-R1` per morale-audit §1 | No touch |
| 8 | `app/scripts/data.gd:77-103` (pre-patch copy: `FAMINE_GRACE_S/DRAIN` at `:96-97`, NO `FAMINE_PROFILE_ENABLED`, no deprecation header) | Same donor law applies; file is behind `variant3d` | No touch by this worker (owning worker reconciles; label-only when touched) |

## 7. Explicit non-claims and discipline

- Default `true` is a verbatim script literal read (EV-FP-01), not an inference; the
  "matches port `= true`" observation in §6 rows 2/5 is a consistency note, not a donor
  citation for the port constant — the port constant stays a labelled gate.
- Negative results (no cfg default, no menu writer, no native definitions, no
  `progress.inc` famine literal, zero grace/drain readers) are reported with the exact
  searched file sets and patterns (§1 P3/P8/P9/P11), not as absence proofs beyond those sets.
- Binary-side evidence is cited from `DEC_U_skirmish.md` §1 P1-P5 (same pin), not re-run;
  no donor binary was executed by this worker.
- `app/scripts/*` vs `variant3d/scripts/*` divergence noted (§6 row 8) without reconciliation.
- End of `DEC_U_famine_profile.md`. Read-only; exactly one file written; no parity claim.
