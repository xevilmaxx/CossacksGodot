---
owner: R5
ticket: D-22
date: 2026-11-24
scope: donor hotkeys/player controls vs Godot port; read-only recon
---

# R5 — Donor hotkeys / player controls vs port

**Method note.** Donor read with `python open(...,'rb').read().decode('latin-1')`. The task's `data\scripts\hotkeys.cfg` path is wrong for this donor build: the live file is `C:\Games\Cossacks 3\data\game\var\hotkeys.cfg` (243 lines, **55** `Action` bindings — "243 bindings" is a line-count misread). `config.cdx`/`cossacks.cdx` are compiled Delphi binaries; no literal key maps were extracted from them (they only contain RTTI strings such as `TShortCut`, `SHIFT+CTRL+ALT+…`). Runtime key registration and action dispatch are in `data\gui\menu.inc\registershortcuts.inc` (static keys + loads `hotkeys.cfg` at :187-221) and `onshortcut.inc` / `onshortcut1.inc`. Port evidence is static read of `app/scripts/*.gd`. All verdicts below are **observed** unless marked derived/inferred.

## Claim verification table

| # | Claim | Evidence (donor path:line + literal key / port path:line + literal key) | Method | Verdict | Action |
|---|---|---|---|---|---|
| 1 | `hotkeys.cfg` has ~243 bindings | donor `data/game/var/hotkeys.cfg` 243 lines, 55 `Action` rows | count `struct.begin`/`Action` | observed — **PARTIAL** (count wrong, file right) | keep 55-binding count in docs; path → `data/game/var/` |
| 2 | MICRO row 5: "keyboard parity NOT missing wholesale"; `Data.HOTKEYS` populated at `config.gd:463` | donor n/a; port `data.gd:223` declares `{}`, `config.gd:526-536` assigns `Data.HOTKEYS = hk_def` from `DEFAULT_CONFIG.controls.hotkeys` (`config.gd:109-148`), read at `input_controller.gd:73-90` | grep + read loader | observed — **CONFIRMED** (stale line ref: 536, not 463) | do not re-ticket G2 wholesale; fix line ref in MICRO |
| 3 | MICRO 14: G→stand_ground broken | donor `hotkeys.cfg:105-110` `G=unit\|guard` + `G=unit\|cancelguard`; `onshortcut.inc:348-365`; port `config.gd:113` `guard=G`, `input_controller.gd:244-266 begin_guard()` + `game.cmd_cancel_guard` fallback, `:866` | read handlers | observed — **MISSING** (gap closed; claim stale) | close row 14 |
| 4 | MICRO 15: cancel-guard (G again) absent | same donor; port `input_controller.gd:244-260` toggles via `e.order.type=="guard"` | read handler | observed — **MISSING** (gap closed) | close row 15 |
| 5 | MICRO 16 / RB G-12: "donor patrol P", port only Q + fixed ±6 m | donor `hotkeys.cfg` has **no** `unit\|patrol` row; `P=build\|%com%por` (`:68-69`); `registershortcuts.inc:70` patrol registration doubly commented; `onshortcut.inc:400-403` has `patrol` mode case. Port `config.gd:114` `patrol=Q`, `:141` `patrol_waypoints=P`, `input_controller.gd:211-240,713-715` two-click P route, `:855-859` Q instant ±6 m | diff literal keys + handler | observed + derived — **PARTIAL** | donor "patrol P" is **false for this build** (P is Shipyard build). Waypoints now exist; see gap G2 below for the P conflict |
| 6 | MICRO 17: D/E/V hold-fire/feuer-frei/engage | donor `hotkeys.cfg:117-118 D=disableattack`, `:113-114 E=enableattack`; **V absent** from `hotkeys.cfg` (only legacy commented `registershortcuts.inc:67` `//TOHOTKEYS// V // free order`; no `engage` case in `onshortcut.inc`). Port `config.gd:116-118`, `input_controller.gd:746-760` | key diff + case-list scan | observed — **PARTIAL** (D/E CONFIRMED; V semantics donor-unverified) | keep V as port convenience; do not claim donor parity |
| 7 | MICRO 18: stand ground S / no-stand C | donor `hotkeys.cfg:89-94`; port `config.gd:111-112`, `input_controller.gd:860-865` | key diff | observed — **CONFIRMED** | none |
| 8 | MICRO 19: attack-move A | donor `:85-86`; port `config.gd:110`, `input_controller.gd:771-772` | key diff | observed — **CONFIRMED** | none |
| 9 | MICRO 20: attack-ground R (dual with build art) | donor `:121-122 R=unit\|attackpoint` and `:28-29 R=build\|%nat%art`; port `config.gd:129 attack_ground=R`, `:144 art=R`; `input_controller.gd:763-769` build menu wins, `:808-815` otherwise bombard | handler order | observed — **CONFIRMED** | none |
| 10 | MICRO 26: donor cursors (11) | donor `data/cursors/*`; port `input_controller.gd:51` loads 11 names | file list | UNVERIFIED (out of hotkey scope) | leave to render worker |
| 11 | MICRO 28: control-group append absent; donor `Ctrl+Shift+n` | donor `registershortcuts.inc:86-91` registers `n`,`Ctrl+n`,`Shift+n` (0-9) + NUM/Alt/Shift+Alt (`:156-172`); `onshortcut.inc:1409` Ctrl+n=store, `:1513` **Shift+n=append** (`ctrlgroupmask or mask`, `:1561-1563`), `:1399-1401` **double-tap digit = camera jump**. Port `input_controller.gd:656-674`: Ctrl+1..9 store, digit recall, **Shift+digit = camera jump**, no append, no 0, no double-tap | read both group blocks | observed — **CONFIRMED** (still open; donor key is Shift not Ctrl+Shift) | top gap 1 |
| 12 | MICRO 31: same-type select only 2 of 4 Z variants | donor `hotkeys.cfg:189-205` Z / Shift+Z / Ctrl+Shift+Z / Ctrl+Z. Port `config.gd:122,134,139-140` + `input_controller.gd:678-689,843-851,887+` | key diff + handlers | observed — **CONFIRMED fixed** (all 4 present; claim stale) | close row 31 |
| 13 | Select all / idle / buildings / mines / all peasants | donor `:154-186` Ctrl+Alt+A(+alt), Ctrl+A, Ctrl+Q, Ctrl+B, Ctrl+P(+` alt), Ctrl+`, Ctrl+M; port `config.gd:119-121,132-133,137-140`, `input_controller.gd:678-700,831-842,871-886` + `:692` plain backtick | key diff | observed — **CONFIRMED** | none |
| 14 | Alt+M minimap toggle | donor `:146-147 interface\|minimap`; port `config.gd:142`, `input_controller.gd:852-854` | key diff | observed — **CONFIRMED** | none |
| 15 | MICRO 68: build mnemonics `J=tem`, `P=por` absent, core set present | donor `:4-73` C,H,L,B,E,S,R,D,K,J,I,O,M(×3),P,T; empty Key for wwa/swa. Port `config.gd:143-147`: core C/H/L/B/E/S/R/D/K/I/O/M/T/W/N present; **no `tem`, no `por`/`dock`**; `data.gd:1104` has `dock` (Shipyard) but no mnemonic; port P consumed by `patrol_waypoints` | key diff + `hud.gd:928-931` label source | observed — **CONFIRMED** | top gap 2 |
| 16 | SWARM_BOARD FP-3 "donor hotkey parity + mnemonics DONE" | `docs/SWARM_BOARD.md:122` vs rows 5,6,11,15,17-19 here | cross-check | observed — **PARTIAL / overstated** | narrow FP-3 to "core order keys + 4 Z variants"; keep residual tickets |
| 17 | Speed keys | donor `registershortcuts.inc:51-54` Sub/Add/-/=, `:178-181` `[`/`]` + Ctrl+Sub/Add; `onshortcut.inc:2079-2130` steps speed. Port `main.gd:604-607 set_speed()` exists but **no key handler** in `input_controller.gd` (`KEY_ADD/KEY_SUBTRACT/KEY_BRACKET*` absent) | handler scan | observed — **MISSING** | top gap 3 |
| 18 | Camera scroll / zoom / height | donor `registershortcuts.inc:9-12` arrow repeat, `:55-58` PGUP/PGDN height + Ctrl+PGUP/PGDN FOV, `:60-61` Home/Ctrl+Home; `onshortcut.inc:1981,2175-2209`. Port `camera.gd:137-151` arrows, `:169-174` wheel zoom; no PGUP/PGDN/Home handlers | handler scan | observed — **PARTIAL** | top gap 4 |
| 19 | Quicksave F5 / F9 | donor `registershortcuts.inc:185` F5 (Engine), `:105` F9 (editor dev only); `onshortcut.inc:1695-1703` F5 = `DoAutoSave` quicksave, `:1673` F9 shares `Space/SpaceD` case (editor place / camera-to-selected). Port `config.gd` no F-key actions; `input_controller.gd:701-710` F5=`game_save()`, F9=`game_load()` | read dispatch | observed — F5 **CONFIRMED**, F9 **MISSING/mismatch** | top gap 5 |
| 20 | Delete kills selected | donor `registershortcuts.inc:59 Del`, `onshortcut.inc:2211+`; port `input_controller.gd:734-742 KEY_DELETE → game.cmd_delete` | key diff | observed — **CONFIRMED** | none |
| 21 | Garrison enter / unload | donor `:141-142 U=unit\|unloadall`; enter is mouse/right-click driven (no hotkey in `hotkeys.cfg`); port `config.gd:130 unload=U`, `input_controller.gd:819-822` | key diff + scope | observed — **CONFIRMED** for U; enter garrison UNVERIFIED (no donor hotkey) | none |
| 22 | Pause key | donor `registershortcuts.inc:47-48` `Pause` + `Ctrl+Shift+P`; donor `Space/SpaceD` = camera-to-selected (`onshortcut.inc:1673-1691`). Port `config.gd:123 pause=Space`, `input_controller.gd:743-745` | key diff | observed — **MISSING/mismatch** | folded into top gap 5 |
| 23 | Q view collision | donor `hotkeys.cfg:150-151 Q=interface\|viewcollision`; port Q=patrol, no viewcollision action | key diff | observed — **MISSING** (dev/debug only) | low priority / open question |

## Compact donor-vs-port key mapping

Legend: ✔ parity, ✎ partial/semantics differ, ✘ missing/conflict, `—` no donor binding.
Donor source: `hotkeys.cfg` unless `RS`=`registershortcuts.inc`, `OS`=`onshortcut.inc`.

| Literal key | Donor action (evidence) | Port action (evidence) | Status |
|---|---|---|---|
| `A` | `unit\|attack` (`:85`) | `attack_move` (`config.gd:110`) | ✔ |
| `S` / `C` | `standground` / `nostandground` (`:89,93`) | `stand_ground` / `no_stand_ground` (`:111-112`) | ✔ |
| `G` | `guard` **and** `cancelguard` (`:105,109`) | `guard` toggle via `begin_guard()` (`input_controller.gd:244`) | ✔ |
| `Q` | `interface\|viewcollision` (`:150`) | `patrol` (`config.gd:114`) | ✘ Q repurposed |
| `P` | `build\|%com%por` Shipyard (`:68`); patrol **unbound** | `patrol_waypoints` (`config.gd:141`, `input_controller.gd:713`); no `dock` mnemonic | ✘ conflict |
| `D` / `E` | `disableattack` / `enableattack` (`:117,113`) | `hold_fire` / `feuer_frei` (`:116-117`) | ✔ |
| `V` | — (legacy commented `free order`, `RS:67`) | `engage` (`config.gd:118`) | ✎ donor-unverified |
| `R` | `unit\|attackpoint` + `build\|%nat%art` (`:121,28`) | `attack_ground` + `art` build, menu priority (`:129,144`, `input_controller.gd:763`) | ✔ |
| `Ctrl+S` | `unit\|stop` (`:137`) | `stop` (`:115`) | ✔ |
| `U` | `unit\|unloadall` (`:141`) | `unload` (`:130`) | ✔ |
| `Z` / `Shift+Z` / `Ctrl+Z` / `Ctrl+Shift+Z` | same-type ×4 (`:189-204`) | `select_same_type` / `add_same_type` / `select_all_same_type` / `add_all_same_type` (`:122,134,139-140`) | ✔ |
| `Ctrl+A` / `Ctrl+Alt+A`(+`Ctrl+Shift+A` alt) / `Ctrl+Q` / `Ctrl+B` / `Ctrl+P`(+`` ` ``) / `Ctrl+\`` / `Ctrl+M` | select family (`:154-186`) | same actions (`config.gd:119-121,132-133,137-140`; `input_controller.gd:678-700`) | ✔ |
| `Alt+M` | `interface\|minimap` (`:146`) | `minimap_toggle` (`:142`) | ✔ |
| `F` / `J` / `K` / `L` | `squad\|fill` / `rank` / `column` / `square` (`:97,125-134`) | `squad_form` / `squad_line` / `squad_column` / `squad_square` (`:124-128`) | ✔ (J/K/L) |
| `Del` | kill selected (`RS:59`) | `cmd_delete` (`input_controller.gd:734`) | ✔ |
| `F5` | quicksave (`OS:1695`) | `game_save()` (`:701`) | ✔ |
| `F9` | camera/editor helper (`OS:1673`) | `game_load()` (`:706`) | ✘ semantics |
| `0-9` / `Ctrl+n` / `Shift+n` / double-tap `n` | recall / store / **append** / **jump** (`OS:1335,1409,1513,1399`) | recall / store / **jump**; no append, no 0, no double-tap (`input_controller.gd:656-674`) | ✎ |
| `Sub`/`Add`, `-`/`=`, `[`/`]`, `Ctrl+Sub/Add` | speed steps (`RS:51-54,178-181`) | none (`main.gd:604` API only) | ✘ |
| Arrows / `PGUP`/`PGDN` / `Ctrl+PGUP,PGDN` / `Home` | scroll / height / FOV / home (`RS:9-12,55-61`) | arrows + wheel (`camera.gd:137-151,169-174`); no PGUP/Home | ✎ |
| `Pause` / `Ctrl+Shift+P` / `SpaceD` | pause / pause / camera-to-selected (`RS:27,47-48`; `OS:1673`) | `pause=Space` (`config.gd:123`) | ✘ |
| Build C,H,B,E,S,L,R,D,K,I,O,M,T,N | donor `:4-65` | `config.gd:143-147` | ✔ |
| Build `J=tem`, `P=por` | donor `:40,68` | absent (`data.gd:1104 dock` exists, unmapped) | ✘ |

## Top-5 ranked actionable gaps

1. **Control groups: append + double-tap jump** — target `app/scripts/input_controller.gd:656-674`. Minimal: `Shift+digit` → append selected IDs to `groups[gi]` (donor `OS:1513`); add a fixed-threshold double-tap detector (e.g. `OS.get_ticks_msec() - last[gi] < 300`) for camera jump (donor `OS:1399-1401`); add `KEY_0` group 10. **AC:** Ctrl+1 stores, 1 recalls, Shift+1 adds without removing, double-tap 1 centres camera, 0 works. **Risk:** medium — moving Shift+digit breaks the currently shipped jump shortcut; timing heuristic must use a named constant to stay deterministic.
2. **`P` build mnemonic (Shipyard/dock) vs patrol** — target `app/scripts/config.gd:143-147` + `app/scripts/input_controller.gd:711-715`. Minimal: add `"dock": "P"` to build map; in the `KEY_P` branch, when `hud.build_menu_open` set `hud.build_ghost_sid = "dock"` before starting patrol (or move waypoints to a free key). **AC:** selecting a peasant, opening build menu and pressing P spawns the dock ghost; P outside build menu still starts the two-click route. **Risk:** low — branch on existing deterministic UI state; stale comment at `:712` must be updated.
3. **Speed keys** — target `app/scripts/input_controller.gd` (near `:734`) calling `main.gd:604 set_speed()`. Minimal: map `-`/`KEY_SUBTRACT`/`[` → one step down, `=`/`KEY_ADD`/`]` → one step up, `Ctrl+Add/Sub` as donor variants; reuse `Data.DONOR_GAME_SPEED` step list. **AC:** pressing `=` increases displayed speed by exactly one donor step and is clamped at 8; `-` symmetric. **Risk:** low (pure state step), but use the donor step table rather than float increments for determinism.
4. **Camera height/FOV/home keys** — target `app/scripts/input_controller.gd` + `app/scripts/camera.gd`. Minimal: `PGUP/PGDN` adjust `camera.zoom` with a named step mirroring donor 5 m elastic-distance steps; `Ctrl+PGUP/PGDN` adjust FOV/zoom equivalent; `Home` centres on town hall, `Ctrl+Home` resets height/angle instantly. **AC:** four keys produce the documented camera changes and respect `camera.clamp_pos()`. **Risk:** medium — donor uses a 3-D elastic distance with 0.34–2.9 clamp (`camera.gd:14-17`); map to explicit constants, never mouse position.
5. **F9 and Space/Pause semantics split** — target `app/scripts/config.gd:123`, `input_controller.gd:701-710,743-745`. Minimal: add a `pause` binding on donor `Pause` (and keep `Ctrl+Shift+P`), treat donor `Space`/`SpaceD` as camera-to-selected (wire to existing camera centre helper) rather than pause; keep F5 quicksave; either drop F9 `game_load` or document it as a port-only convenience since donor F9 is not load. **AC:** Pause/`Ctrl+Shift+P` pause; Space centres camera on selection; F5 saves; F9 behaviour matches the documented choice. **Risk:** low–medium — changes deeply ingrained muscle memory; gate behind config so existing saved profiles can keep Space=pause.

## Open questions

- Donor `V` is not in `hotkeys.cfg` (only a commented-out legacy `free order` line). Is port `cmd_engage` intentionally a port-only action, or should it be bound to a different donor command?
- Is the "donor patrol P" line in MICRO/G-12 derived from an older game version? This donor build's `P` is unambiguously Shipyard; `unit|patrol` is commented out in both registration and dispatch.
- `J=tem` (Cathedral) has no port building (`data.gd` BUILDINGS has no `tem`). Is this tracked by RA G03/G05, and should the mnemonic still be reserved?
- `Q=interface|viewcollision` is a donor debug view; the port uses Q for patrol. Keep repurposed or add a debug-only binding?
- Runtime user overrides (`user://` config / saved hotkeys) were not inspected; `registershortcuts.inc:188-192` loads `hotkeys.cfg` from the save directory when present, so an end user's donor profile could differ from the shipped file.
- Donor group `Alt+n` / `Shift+Alt+n` / `NUMn` player-oriented shortcuts (`RS:156-172`, `OS:2279+`) are not covered by the port's numeric handler; priority unclear for a skirmish port.
