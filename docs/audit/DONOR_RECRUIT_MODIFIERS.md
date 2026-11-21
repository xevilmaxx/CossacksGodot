# Donor audit — barracks recruitment click modifiers (T5-HOTKEY)

**Scope:** read-only research. Donor is private-use, read-only at `C:\Games\Cossacks 3`. No donor binaries were copied, no Godot run was performed, no code was edited. Exactly one file was written: this one.

**Owner question:** "when recruiting in barracks there were combos like ctrl + click its +5 units at a time, and shift + click is infinite or vice versa, i want that too, depending on how it were in original donor."

**Short answer:** the donor is the *vice versa* of the owner's first guess. **Shift+LMB queues exactly 5 units; Ctrl+LMB queues infinite (endless) production.** The owner's memory of "+5 on Ctrl" is off by one modifier. There are two extra donor combos: **Ctrl+Alt+LMB (and AltGr+LMB) = 100 units**, and **Ctrl+Shift+LMB = 5× infinite**. Also, the donor has a settings toggle *"Repeating unit production with left-click"* that swaps the default between plain LMB and Ctrl+LMB; shipped default is OFF, so plain LMB = 1 and Ctrl+LMB = infinite.

All of this is **VERIFIED in plaintext donor data** — not inferred from binaries.

---

## 1. Donor evidence table

Legend: **observed** = literal donor file text quoted; **derived** = straightforward evaluation of that text with a resolved constant; **inferred** = strong but indirect; **UNVERIFIED** = no plaintext evidence found.

| # | Claim | Source file:line (relative to `C:\Games\Cossacks 3`) | Status | Evidence / reasoning |
|---|-------|------------------------------------------------------|--------|----------------------|
| D1 | The training-button click handler computes a queue `amount` from modifier keys. | `data\gui\menu.inc\eventunitcontrol.inc:514-533` (`cTagUnit` branch) | observed | `case tag of cTagUnit : begin ... var amount : Integer; ... _unit_ProduceUnit(plHnd, gSelectedObjects, gint_gui_pickedbldcid, id, amount, bLeftButton, True, True);` |
| D2 | Ctrl+Alt → 100 units. | `eventunitcontrol.inc:518-519` | observed | `if (GetGUIShiftStateCtrl) and (GetGUIShiftStateAlt) then amount := 100` |
| D3 | Ctrl+Shift → `gc_obj_order_produce_infinite*5`. | `eventunitcontrol.inc:521-522` | observed | `if (GetGUIShiftStateCtrl) and (GetGUIShiftStateShift) then amount := gc_obj_order_produce_infinite*5` |
| D4 | Shift → 5 units. | `eventunitcontrol.inc:524-525` | observed | `if (GetGUIShiftStateShift) then amount := 5` |
| D5 | `Ctrl <> gProfile.binfiniteonleftclick` → infinite. | `eventunitcontrol.inc:527-528` | observed | `if (GetGUIShiftStateCtrl<>gProfile.binfiniteonleftclick) then amount := gc_obj_order_produce_infinite` |
| D6 | Otherwise → 1 unit. | `eventunitcontrol.inc:529-530` | observed | `else amount := 1;` |
| D7 | Production is gated by access control, then queued. | `eventunitcontrol.inc:531-532` | observed | `if (not bLeftButton) or (_player_CheckAccessControlRequirements(...) = gc_result_checkaccesscontrolreq_ok) then _unit_ProduceUnit(...)` — note `not bLeftButton` means right-click bypasses that check. |
| D8 | The "infinite" sentinel is `-1`. | `data\scripts\dmscript.global:660` | observed | `gc_obj_order_produce_infinite = -1;` |
| D9 | Negative `amount` means "set infinite": `-1` → one infinite job; `-5` → five infinite jobs. | `data\scripts\lib\unit.script:10362-10366, 10440-10443` | derived | `if (amount<=gc_obj_order_produce_infinite) then begin bsetinfinite := True; amount := round(Abs(amount)); end;` then `for i:=0 to amount-1 do ... if (bsetinfinite) then _unit_OrderProduce(bldHnd, cid, id, gc_obj_order_produce_infinite) else _unit_OrderProduce(bldHnd, cid, id, 1);` Since the sentinel is `-1`, `<= -1` catches both `-1` and `-5`; `Abs()` turns them into 1 and 5 iterations respectively. |
| D10 | Each ordered unit is charged separately; unaffordable units are skipped, partial batches are queued. | `unit.script:10435-10457`, `6005-6050` | derived | `var enoughres := ... _unit_CanApplyCostByID(cid, id, plInd);` then order 1 (or infinite); elsewhere `for j:=0 to amount-1 do _unit_ApplyCostByID(...)`. |
| D11 | Shopped default for the toggle is OFF → plain click = 1, Ctrl = infinite. | `data\scripts\lib\profile.script:31` and `:259`; `data\resources\config.res:798,989` | observed | `profile.binfiniteonleftclick := False;` and `binfiniteonleftclick = 0`. |
| D12 | The toggle is a real user-facing option: "Repeating unit production with left-click". | `data\resources\config.res:918-933`; `data\locale\en\tools.txt:221` (+ following line); `data\locale\needloc\misc.txt:143` (+ following line); `data\gui\menu.inc\eventsettings.inc:180,650`; `data\gui\menu.inc\showsettings.inc:1123-1134` | observed | `Name = binfiniteonleftclick / Caption = CFG.PROFILE.INFINITEONLEFTCLICK / value = 0 (OFF) / value = -1 (ON)`; locale line = "Repeating unit production with left-click" (short: "Repeating unit production"); `gProfileTmp.binfiniteonleftclick := bChecked;`. When ON, D5's XOR inverts: plain LMB = infinite, Ctrl+LMB = 1. |
| D13 | Donor tutorial states Shift=5, Ctrl=infinite, right-click on icon cancels. | `data\locale\en\missions\tutmis1.txt:26` (identical in `data\locale\needloc\missions\tutmis1.txt:26`) | observed | "To produce a unit, left-click on the icon of the unit you need. Clicking while holding Shift orders 5 units, holding Ctrl results in infinite production cycle. To cancel production, right-click on the unit icon." |
| D14 | Donor "what's new" lists all four combos explicitly. | `data\locale\needloc\new.txt:826-832` | observed | `:826 "Ctrl + Alt + LMC - Gives 100 units in a queue"`; `:828 "Alt Gr + LMC - Gives 100 units in a queue"`; `:830 "Ctrl + LMC - Queues an infinite production of units"`; `:832 "Ctrl + Shift + LMC - Queues an 5 infinite production of units"`. |
| D15 | `hotkeys.cfg` contains no recruitment modifier binding. | `data\game\var\hotkeys.cfg:1-243` | observed | 243 lines, all keyboard bindings for building placement, unit commands, selection and menus. No `train`/`produce`/`rally` action and no Ctrl/Shift *click* modifier. The modifiers are mouse-state checks in the GUI script (D1), **not** configurable hotkeys. |
| D16 | Rally point is set from a HUD button, then a world click; right-click also sets it directly. | `eventunitcontrol.inc:555-561`; `data\gui\menu.inc\onmousedown.inc:879-898`; `data\gui\menu.inc\doupdatecursor.inc:24-25` | observed | `cTagRally : ... gbool_gui_setrallypointmode := True;` and the right-click branch `if (gbool_gui_setrallypointmode) then ... cancel ... else ... SelectedUnitsSetRallyPoint(x, z);`. |
| D17 | A commented-out donor variant allowed Ctrl+LMB to set rally. | `onmousedown.inc:271-278` | observed (inactive) | `{var bSetRallyPoint : Boolean = GetGUIShiftStateCtrl; if (gbool_gui_setrallypointmode) or (bSetRallyPoint) then ... SelectedUnitsSetRallyPoint(x, z);}` — inside `{ }` comment, not shipped behaviour. |
| D18 | No donor evidence of Shift+click adding rally *waypoints* (multi-point rally) in searched plaintext. | searched `data\gui\*`, `data\scripts\common.inc\*`, `data\scripts\lib\*`, `data\scripts\units\global.inc\readrally.inc`/`writerally.inc`, `data\scripts\units\unit.inc\setrallypoint.inc`, `data\locale\*` | UNVERIFIED | `readrally.inc` / `writerally.inc` / `setrallypoint.inc` store one `rallyx/rallyy` pair; `showrallypoints.inc` draws one marker per building. No waypoint list was found. Do not implement multi-waypoint rally on this evidence. |
| D19 | Donor order slots per building = 12; batch sizes are carried in one order's `amount`, not N slots. | `data\scripts\dmscript.global:113` (`gc_obj_MaxOrderCount = 12`); `unit.script:6005-6050` | derived | Compare port `app\scripts\data.gd:50` (`BUILD_QUEUE_LIMIT := 10`). A 100-unit batch fits in one donor order (`TOrderInfo.amount = 100`). |

**Key point for the owner:** D13 and D14 are the donor's *own user-facing text*. They agree exactly with the script arithmetic in D2–D6 after resolving D8/D9. There is no binary-only guess involved.

---

## 2. Verdict — exact donor truth table

Shipped default (`binfiniteonleftclick = False`, D11/D12):

| Input on a training icon | `amount` passed to `_unit_ProduceUnit` | Effective donor behaviour |
|--------------------------|---------------------------------------|----------------------------|
| Plain LMB | `1` (D6) | 1 unit queued, charged once |
| **Shift + LMB** | `5` (D4) | **5 units queued**, charged 5× (partial if cannot afford all) |
| **Ctrl + LMB** | `-1` (D5 + D8) | **infinite / endless production cycle** of that unit type |
| **Ctrl + Shift + LMB** | `-5` (D3 + D8) | 5 infinite production jobs (donor help text: "Queues an 5 infinite production of units") |
| **Ctrl + Alt + LMB** | `100` (D2) | 100 units queued in one order |
| **AltGr + LMB** | `100` (D14:828; AltGr presents as Ctrl+Alt) | 100 units queued |
| RMB on the icon | not a quantity — `bLeftButton = False` (D7) and donor tutorial D13 | cancels production / refunds |

If the player enables **"Repeating unit production with left-click"** (`binfiniteonleftclick = True`, D12), the last two rows of the XOR swap:

| Input | `amount` | Behaviour |
|-------|----------|-----------|
| Plain LMB | `-1` | infinite production |
| Ctrl + LMB | `1` | 1 unit |

Shift, Ctrl+Shift and Ctrl+Alt rows are unaffected by the toggle (they are evaluated before the XOR).

**Verdict sentence:** owner remembered +5 and infinite but attributed them to the wrong keys. Donor = **Shift adds 5, Ctrl makes it endless** (with Ctrl+Alt = 100 and Ctrl+Shift = 5× endless). A settings option can swap which of plain/Ctrl is endless.

---

## 3. Donor rally-point modifier (only what the same search produced)

- Rally is armed by the HUD Rally button (`cTagRally`, `eventunitcontrol.inc:555-561`) and then set by a **right-click** on the map (`onmousedown.inc:879-898`); a right-click on a selected production building also sets it without arming.
- `onmousedown.inc:271-278` shows an *inactive* older variant where Ctrl+LMB set rally — do not treat it as shipped behaviour.
- **No evidence of Shift+click rally waypoints** was found (D18). The port's current single-point rally is therefore already faithful; nothing to port here.

---

## 4. Port gap — current behaviour with file:line

All paths relative to `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\app\scripts\`.

| Port behaviour | Source | Compared to donor |
|----------------|--------|-------------------|
| Train button connects `pressed → _on_train` and `gui_input → _on_train_gui` | `hud.gd:477-478` | Donor has a single click handler that reads modifier state (`eventunitcontrol.inc:514-533`). |
| `_on_train` calls `game.train_unit(0, bld, sid)` with **no amount argument** → exactly **1** unit | `hud.gd:597-600` | Matches donor plain LMB (1) only. |
| `_on_train_gui`: **Shift+LMB removes one queued job of that sid and refunds** | `hud.gd:602-610` (`Input.is_key_pressed(KEY_SHIFT)`, `bld.queue.remove_at(i)`, `Data.refund(...)`) | **Direct conflict**: donor Shift+LMB *adds 5*. Donor cancels via **right-click** on the icon (D13). |
| No Ctrl handling on train buttons anywhere | `hud.gd:597-610`; grep of `hud.gd` / `input_controller.gd` for `ctrl` shows only selection/camera uses (`input_controller.gd:81,528,542,562`, etc.) | Ctrl=infinite, Ctrl+Alt=100, Ctrl+Shift=5× infinite all missing. |
| `train_unit` appends **one** queue entry, charges **one** cost, hard cap `BUILD_QUEUE_LIMIT = 10` | `game.gd:3189-3227`; `data.gd:50` | Batch/infinite needs a count or infinite flag on the job (donor carries `amount` in one order, D19). |
| Job completion always `pop_front()` — no endless re-arm | `game.gd:4514-4526` | Infinite production cannot be represented at all. |
| HUD queue readout: button text = `str(queue.size())` or `+N`; status line `training %s (%d)` | `hud.gd:474, 761-762, 845-847` | No ∞ / endless indicator. |
| Rally: right-click on selected production building sets rally; R button arms rally mode | `input_controller.gd:369-375, 377-397, 767-772, 818-820`; `hud.gd:551-555, 683-685`; `game.gd:355-361` | Already matches donor D16. **No change required.** |

**Net gap:** 4 donor behaviours missing (Shift=5, Ctrl=infinite, Ctrl+Alt=100, Ctrl+Shift=5× infinite), 1 behaviour wrong (Shift currently cancels), 1 HUD indicator missing, 1 optional settings toggle missing. Rally is already correct.

**Risk note (verify, don't assume):** because `_on_train` is on `pressed` and `_on_train_gui` is on `gui_input`, a Shift+LMB may fire both handlers (cancel then train) depending on Godot's `set_input_as_handled()` timing at `hud.gd:608`. The fix below removes that ambiguity by handling all modifiers in one place.

---

## 5. Minimal fix plan (implementation owner: HUD/input agent — NOT T5-HOTKEY, which is read-only)

Owner assignment is for the orchestrator; T5-HOTKEY only reports. Smallest faithful change set:

### 5.1 `app/scripts/game.gd` — extend the queue primitive

1. Change signature to `func train_unit(player: int, building: Dictionary, sid: String, amount: int = 1, infinite: bool = false) -> bool:` (keep old 3-arg callers valid — `t_capture.gd:124` calls it directly).
2. Keep the existing one-time validation (`game.gd:3190-3225`: finished, roster/captured SID, academy gate, cap, cost lookup).
3. Replace the single `building.queue.append(...)` at `game.gd:3226` with **one** job carrying a counter, mirroring donor's single order with `amount` (D19):
   - `{"sid": rsid, "t": Data.UNITS[rsid].build_time, "count": amount, "infinite": infinite}`.
   - Charge `min(amount, affordable)` units up front (donor charges per unit and skips unaffordable ones, D10) or charge on completion — pick one and keep it consistent with `Data.refund` in the cancel path.
   - For `infinite = true`, store the flag on the job and do **not** fill to `BUILD_QUEUE_LIMIT`; this is donor's `-1` sentinel (D8/D9).
4. In `_tick_building` (`game.gd:4514-4526`): when `job.t <= 0`, decrement `count`; if `infinite` or `count > 0`, re-arm `job.t` and keep the job at index 0 instead of `pop_front()`. Spawn the unit each cycle exactly once (the existing spawn code after `:4526` should run once per completed cycle).
5. Add `func cancel_train(building: Dictionary, sid: String) -> bool` that removes/decrements one queued unit of `sid` and refunds via `Data.refund` — move the logic currently in `hud.gd:604-608` into `game.gd` so input code stays thin.
6. Optionally add `set_repeat_on_left_click(enabled: bool)` stored in player/profile config to implement D12; the XOR in 5.2 reads it.

### 5.2 `app/scripts/hud.gd` — modifier resolution + HUD indicator

1. Add constants near the top: `const TRAIN_BATCH := 5`, `const TRAIN_BIG_BATCH := 100`.
2. Replace `_on_train` / `_on_train_gui` (`hud.gd:597-610`) with a **single** LMB handler that computes amount from `Input.is_key_pressed`:
   ```
   ctrl = Input.is_key_pressed(KEY_CONTROL)
   shift = Input.is_key_pressed(KEY_SHIFT)
   alt = Input.is_key_pressed(KEY_ALT)
   if ctrl and alt:  game.train_unit(0, bld, sid, 100)
   elif ctrl and shift: game.train_unit(0, bld, sid, 1, true)   # see Open Q1 for 5× infinite
   elif shift:       game.train_unit(0, bld, sid, 5)
   elif ctrl != repeat_on_left_click: game.train_unit(0, bld, sid, 1, true)
   else:             game.train_unit(0, bld, sid, 1)
   ```
   This is a direct port of `eventunitcontrol.inc:518-530`.
3. Move cancel to **right-click** on the train button: in `_on_train_gui`, handle `ev.button_index == MOUSE_BUTTON_RIGHT` → `game.cancel_train(bld, sid)` (donor D13). Remove the Shift-cancel branch entirely so Shift means +5.
4. Update the three queue readouts (`hud.gd:474`, `:761-762`, `:845-847`) to show `∞` (or `"inf"`) when the front job has `infinite == true`, and show `+N` for `count > 1` batches. Tooltip on the train button can quote donor D13: "Click: 1 · Shift: 5 · Ctrl: endless · Right-click: cancel".
5. Wire the new "Repeating unit production with left-click" toggle into whichever settings UI owns checkboxes (outside this file's scope; locate via existing settings code) and persist it.

### 5.3 `app/scripts/input_controller.gd` — no change required

Rally already matches donor (§3). Only touch it if the owner later wants a multi-waypoint rally, for which **no donor evidence exists** (D18).

### 5.4 Tests

Add a focused UI test alongside `app/tests/t_capture.gd` (which already calls `game.train_unit` directly at `t_capture.gd:124`). Prefer driving the real button handlers with synthetic `InputEventMouseButton` + modifier state so the modifier wiring itself is covered, not just `train_unit`.

---

## 6. Acceptance criteria (measurable from a UI test)

Assume a finished Barracks for player 0, enough resources/cap, and a deterministic selectable unit (e.g. `serdiuk`/`strelet` as in `t_capture.gd:121-129`). For each case, inspect `bld.queue` and `game.players[0].res` through the test bridge.

1. **Plain LMB** on the train button → `bld.queue.size()` increases by exactly **1**; the front job has `count == 1` and `infinite == false`; resources drop by exactly one unit price.
2. **Shift+LMB** → `bld.queue.size()` increases by exactly **1 job** carrying `count == 5` (or 5 separate jobs if the implementer chooses the one-entry-per-unit route, but then exactly 5 and resources drop 5×); with limited resources it queues the affordable subset, never more. HUD button text shows `+5`.
3. **Ctrl+LMB** → front job has `infinite == true`; after waiting for **two** build times, the front job's `sid` is unchanged, the unit count has increased by 2, and the queue was never emptied. HUD shows the ∞ indicator.
4. **Ctrl+Shift+LMB** → still infinite production (donor "5 infinite"). If implemented as 5 infinite jobs, assert 5 such jobs; the minimal single-job interpretation is acceptable only if recorded as a deviation (Open Q1).
5. **Ctrl+Alt+LMB** → job carries `count == 100` (or 100 units total); total charged = 100× price; cap/resource limits respected. AltGr may be treated as Ctrl+Alt at the app level if the OS exposes it that way.
6. **Right-click on the train button** → one queued unit of that sid is removed and refunded; **Shift+LMB no longer cancels** (this is the key regression check).
7. **Toggle ON** "Repeating unit production with left-click" → plain LMB now yields `infinite == true`; Ctrl+LMB now yields `count == 1`; Shift still yields 5.
8. **Rally regression** → select the Barracks, right-click a ground point, assert `bld.rally` is set to that (snapped) point; unchanged from current behaviour.
9. **No modifier leakage** → Ctrl+LMB on the train button does not select all units or trigger any global Ctrl shortcut from `input_controller.gd:528-562`; `set_input_as_handled()` must be called in the button handler.

---

## 7. Open questions / risks

1. **Q1 — Ctrl+Shift semantics.** D9 derives `-5` → five infinite `_unit_OrderProduce` calls, matching D14's odd wording "Queues an 5 infinite production of units". Whether that means five *distinct* endless orders (faster combined output) or one endless order with a 5× count is not observable from plaintext. Recommendation: implement as a single infinite job for the minimal port, and record the deviation explicitly.
2. **Q2 — saved-profile override.** D11/D12 show shipped defaults OFF, but a player's saved profile could enable the toggle. Port should expose it rather than hard-code "Ctrl = infinite"; otherwise owner's muscle memory may differ from the default.
3. **Q3 — Shift double-fire.** Verify whether current `hud.gd:477-478` Shift+LMB triggers both `_on_train_gui` cancel and `_on_train` add. The refactor in §5.2 removes the ambiguity, but the pre-fix behaviour should be noted when comparing screenshots/tests.
4. **Q4 — 100-unit batch vs `BUILD_QUEUE_LIMIT = 10`** (`data.gd:50`). Do **not** append 100 entries; the donor stores the count inside one order (`gc_obj_MaxOrderCount = 12`, D19). Use a `count` field.
5. **Q5 — AltGr.** `new.txt:828` lists AltGr+LMB separately from Ctrl+Alt+LMB; on Windows AltGr usually generates Ctrl+Alt, so one binding should cover both, but verify on the target keyboard layout.
6. **Q6 — rally waypoints.** D18 is UNVERIFIED; no multi-waypoint rally should be added on this evidence. If the owner specifically remembers "shift+click to add waypoints", that memory is **not** supported by donor plaintext and needs a separate investigation (possibly a different game or a mod).
7. **Q7 — cancel on right-click vs existing UX.** Port currently has no right-click-on-icon cancel; switching from Shift-cancel to RMB-cancel (D13) is a deliberate fidelity change and should be called out in the owner-facing changelog.

---

**End of report.**
