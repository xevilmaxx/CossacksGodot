---
id: F03
title: "F03 — ONLINE donor research: Cossacks 3 selection frame / marquee / UI and selection-quad spec"
owner: F03 (online research worker)
date: 2026-11-25
status: READ_ONLY__ONLINE_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB
scope: "Exactly one new file written — this report. No code, config, asset, test, scene, shader, menu or git edit. No Godot runner job. No donor binary read or copied here: donor-source claims are quoted from already-landed local recon reports, not re-derived."
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md §1b.2 (selection quad re-audit) and §6 (seed URLs)"
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
method: "webfetch / websearch only, 2026-11-25. Official Steam announcement text recovered in full from the Steam news archive page (the direct /news/app/.../view/... page is age/consent-gated). Almanac EN files read from raw.githubusercontent.com on branch 'main'. Exact review/discussion quotes read from the live pages."
output: docs/terrain_swarm_2026-11-25/reports/F03_selection_online.md
---

# F03 — ONLINE donor research: selection frame, UI and selection quad

## Goal

Answer, from **online primary/secondary sources only**, the questions the charter's
§1b.2 assigns: what the donor's drag-selection frame actually is, when it became
canonical, how it behaves (drag rectangle, drag-scrolling, Shift-add, double-click /
select-same-type, grouping hotkeys), what visual style the "selection quad" and its
selected-unit feedback use, and which donor *bugs* must be recorded but **not copied**.
Everything is cross-checked against the four landed local reports named in the ticket
(DSEL-01, DSEL-02, RV-SEL-01, SEL-01). No donor A/B frame was produced; donor parity
stays **UNVERIFIED** per charter guardrail 1.

---

## Source register (all fetched 2026-11-25)

| Id | Source | URL | Weight |
|---|---|---|---|
| S1 | Official GSC Steam announcement **"The Cossacks 3 Mod Manager is here + selection frame dragging ability!"**, 12 Nov 2016 | `https://store.steampowered.com/news/app/333420/view/4042499938190999083` (gated); full text via `https://store.steampowered.com/news/posts/?appids=333420&enddate=1478981556` | **primary / official** |
| S2 | Official patch notes **20.11.2016 (1.1.6.53.4130)** "The Big Maps Patch is here + 8th player!" — selection-frame bug fix | `https://store.steampowered.com/news/app/333420/` archive, same enddate query; also `https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=333420&count=100&enddate=1481000000&maxlength=0&format=json` | **primary / official** |
| S3 | gamepressure **"Cossacks 3: User interface"** guide, last updated 17 Oct 2016 | `https://www.gamepressure.com/cossacks3/user-interface/zd91b1` | secondary, contemporaneous |
| S4 | almanac **Controls and Player Feedback** (EN) | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/systems/ui_input_and_feedback.md` | secondary, source-cited recon |
| S5 | almanac **Walls and Gates** (EN) | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/combat/walls_and_gates.md` | secondary, source-cited recon |
| S6 | WGB **"Cossacks 3 Review – Less Sequel, More HD Remaster"**, 28 Sep 2016 | `https://wolfsgamingblog.com/2016/09/28/cossacks-3-review-less-sequel-more-hd-remaster/` | secondary review — **wall/box-select bug** |
| S7 | Steam **"Bug report Thread"**, opened 20 Sep 2016 (Buntkreuz, 650 comments) | `https://steamcommunity.com/app/333420/discussions/1/350543389014614918/` | community bug reports |
| S8 | Steam suggestion **"Make it easier to see when units are selected"**, 25 Aug 2017 | `https://steamcommunity.com/app/333420/discussions/2/1473095331496468674/` | community, highlight feedback |
| S9 | HeyPoorPlayer **"Cossacks 3 Review (PC)"**, 28 Sep 2016 | `https://www.heypoorplayer.com/2016/09/28/cossacks-3-review/` | secondary review — clunky UI |
| S10 | gamepressure **"Cossacks 3 review – a sad return to the past"**, 21 Sep 2016 | `https://www.gamepressure.com/editorials/reviews/cossacks-3-review-a-sad-return-to-the-past/zee9` | secondary review — micromanagement |
| S11 | r/Cossacks3 **Bugs Megathread** (Sep 2016) | `https://www.reddit.com/r/Cossacks3/comments/53pq86/bugs_megathread/` | community (search snippet only) |
| L1–L4 | Local landed reports | `docs/coord_swarm_2026-11-25/reports/DSEL_01_donor_selection_rectangle.md`, `DSEL_02_donor_pick_math.md`, `RV_SEL_01_selection_reverify.md`, `SEL_01_implementation.md` | donor-source recon + port state |

---

## Finding 1 — drag-selection frame is a *deliberate 2016 feature*, not an ancient constant (CONFIRMED)

S1, official, verbatim (EN, item 2 of the 12 Nov 2016 update):

> "An ability to drag the selection frame – community's favorite. Rejoice, as you are now
> able to select your grand armies even if they take more place than could fit on one
> screen. Select your numerous pikemen, musketeers and dragoons and send them away to
> fight in your name!"

The same announcement's RU text is **more specific about the camera** (this is the
decisive line; translated):

> "Добавлена рамка выделения. **Теперь, когда тянете рамку, карта двигается с вами.**
> Возрадуйтесь. Вы можете выбрать ваши великие армии, даже если они настолько огромны,
> что не помещаются на одном экране…"
> — "Selection frame added. **Now when you drag the frame, the map moves with you.** Rejoice,
> you can select your grand armies even if they are so huge they do not fit on one screen."

(UA text is identical in meaning: "Тепер, коли тягнете рамку, карта рухається з вами.")

**Verdict: CONFIRMED (official text).** Canonical donor drag-select is an **edge-scroll /
camera-follows-the-drag** marquee: dragging toward a screen edge pans the world so an
army larger than the viewport can be boxed. This directly confirms the charter's
"selection frame dragging ability" note and *upgrades* it — the feature shipped as
"frame + camera moves with you", not merely "a rectangle appears".
S2 (20.11.2016 patch, EN General item 4) confirms the interaction is real and was still
being fixed nine days later:

> "Fixed an error with the selection frame, when the speed of scrolling with keyboard and
> mouse were different."

RU item 7: "Исправлена ошибка при движении камеры одновременно с рамкой выделения, когда
скорости скролла мышки и клавиатуры отличалась." — "Fixed an error when moving the camera
simultaneously with the selection frame when mouse and keyboard scroll speeds differed."

This is a **camera/frame coexistence** fix, i.e. the donor marquee and camera panning run
concurrently. Label: observed (official patch text); no runtime observation — the exact
edge band width / scroll speed is **UNVERIFIED** online.

**Cross-check.**
- L1 DSEL-01 §"Pseudocode" mirrors the script half of this: start on first LMB-held move
  from `GetCurrentMouseWorldCoord`, `GameManagerBeginSelection` +
  `GameManagerStartSelection('spmAdd'|'spmRunTime')`, finalize on LMB-up. It does **not**
  mention camera-follow — expected, because that part is native/engine and invisible to
  the `.inc` scripts (L1 open question 3: "pickfrustum=true semantics … screen rect vs
  projected quad").
- L2 DSEL-02 claim 11 / §D: drag rect is world-space ground coordinates.
- L3 RV-SEL-01 §"Final authoritative donor selection spec": Shift semantics and the
  disabled Ctrl branch re-confirmed at byte level; native inside-box predicate **UNVERIFIED**.
- L4 SEL-01: our port **kept the two-ground-point world rect with no camera scroll**
  (`input_controller.gd` unchanged entity loop, `world.sel_rect` mirror kept). Therefore
  **edge-scroll / camera-follows-drag is a confirmed gap** (see Gap list, G1).

---

## Finding 2 — exact drag-rectangle behaviour (script side, corroborated online)

These online sources agree with the landed donor recon and add no contradictory script fact:

| Behaviour | Online evidence | Local corroboration | Verdict |
|---|---|---|---|
| Box "gathers all eligible objects inside it"; selection set updates **while button held** | S4 Key points + §"Selection and Camera": "a selection box updates the selected set while the mouse button is held", "a selection box gathers all eligible objects inside it" | L1 claims 3–6, L2 claim 11, L3 pseudocode | CONFIRMED (online + local) |
| A box mode is updated **per frame** | S4 §1.1: `spmFrame` — "for a box updated every frame while the button is held"; `spmRunTime` — "for a one-frame click" | L1/L3 say the live drag modes are `spmRunTime`/`spmAdd` | **DISCREPANCY — see Open question O1**; do not pick a side without the native source |
| Range extends beyond one screen (camera follows drag) | S1 RU/UA text; S2 selection-frame/camera fix | absent from L1–L4 (native) | CONFIRMED online; GAP in port |
| Owner/playable filtering | S4 §1.2: `SetGameManagerSelectionSettings(pickgroups, pickgamemanagerplayer, pickplayableObject, ...)`; "Human players normally use `pickplayableObject = True` and an owner filter" | L1 claim 8, L3 constant table `(false,true,true,true)` | CONFIRMED |
| Cursor can be clipped to the window for the frame | S4 §3: `SetClipCursor(val)` — "Lock the cursor inside the window (for the selection frame)" | not in L1–L4 | NEW online detail; native use at runtime **UNVERIFIED** |
| Ground point = cursor→ground raycast; click target = first object hit by mouse ray | S4 §2.2: `GetCurrentMouseWorldCoord(...)`, `GameObjectRayCastMouseRay()`, `GetRayCastIntersectGameObjectFromMouseRay()` | L1 claim 13, L2 claim 7/8 | CONFIRMED |

Note on S4's authority: it is a source-cited recon (cites `data/gui/menu.inc/*`,
`data/scripts/lib/control.script`, `derived/dws_native_signatures.json`), consistent with
L1–L3 on every overlapping item except the `spmFrame`/`spmRunTime` naming of O1. It is
**secondary**, so where it disagrees with the byte-level local recon the local recon wins.

---

## Finding 3 — Shift-add, double-click / select-same-type, grouping hotkeys

### 3a. Shift-add (S3, S4; CONFIRMED)

S3 (gamepressure UI guide), verbatim:

> "If you have some troops selected, hold **SHIFT** and left mouse to add more units to
> the selection."

and, for the same-type shortcut: "Combine this with holding **SHIFT** to instantly add more
units to selection."

S4 §7.3 hotkey table lists the explicit action names
`select|addunitsofsametype` (`Shift+Z`) and `select|addallunitsofsametype`.
Local: L1 claim 4/16 and L3 Conflict 1 — Shift drag → `spmAdd`; L4 implemented Shift union
(`[10,11,12]` in probe 329). **All agree; no contradiction.**

### 3b. Double-click / Ctrl / Z — select all of the same kind (S3, S4; CONFIRMED)

S3, verbatim:

> "Double clicking a unit, clicking a unit while holding **CTRL**, or selecting a unit and
> pressing **Z** selects all units of the same kind. Combine this with holding **SHIFT** to
> instantly add more units to selection."

S4 §7.3: `Z` = `select|unitsofsametype` ("repeat to select the next one"), `Shift+Z` =
`select|addunitsofsametype`; §7.2 also lists `select|allunitsofsametype` and
`select|addallunitsofsametype`. S4 §7.1 notes `Repeat = True` cycles through options, which
explains the "repeat presses step to the next unit" nuance absent from S3.

Local: L1 claim 7 (`KeyDoubleDelay = 0.5` s in `menu.cfg:33`), L1 claim 16 (Ctrl-equivalent
select-same-type), L3 constant table. L4 changed the port window `0.35 → 0.5` but has
**no timing assertion** (L4 §"UNVERIFIED / honest limits"). S4 does not state the numeric
double-click window, so the `0.5` literal remains sourced from **local donor recon**, not
from the online sweep.

### 3c. Grouping hotkeys (S3 + S4; CONFIRMED, with a binding nuance)

S3, verbatim: "Unit and building groupping: **CTRL + a number from 0 to 9**."

S4 is more complete:
- §"Selection and Camera": "**Ten control groups are numbered 0 through 9.** A selection
  can be stored, extended, and recalled later."
- §8.1: `0`–`9` and `NUM0`–`NUM9` are **reserved** for "Control groups — select a group";
  `LButton`/`RButton`/`MButton` reserved for selection/orders/camera dragging.
- §8.2: `Ctrl+0..9` = **assign**, `Shift+0..9` = **add**, `Alt+0..9` = **select**,
  `Shift+Alt+0..9` = reserved extra group mode.
- §8.3: the native RTTI contains `TXGroup4` and `TXGroupSelectionViewer`, the latter
  drawing **green highlights around units in the active control group**; the script layer
  has no group-key interface (native handles it).

Nuance: S3's "Ctrl+N" and S4's "Alt+N selects / Ctrl+N assigns" are not a contradiction —
S3 describes the common assign action; S4 documents the full native map. Label: observed
(both). L1 claim 26 records the donor `hotkeys.cfg` select family; control groups are
native-only there too.

### 3d. Other global selection shortcuts (S3 + S4; CONFIRMED)

- S3: "**CTRL + A** will select every unit on the map." S4: `Ctrl+A` = `select|allunits`,
  plus `Ctrl+B` buildings, `Ctrl+Q` ships, `Ctrl+P`/backtick idle peasants,
  `Ctrl`+backtick all peasants, `Ctrl+M` idle mines, `Ctrl+Alt+A`/`Ctrl+Shift+A` military.
- S3 recruitment-queue convention (not selection, but same modifier vocabulary):
  "left click adds a unit to queue, and right click subtracts a unit from cueue. **If you
  hold SHIFT**, you will add/subtract fife units at a time. **Holding CTRL** will set the
  recruitment to unlimited mode". This corroborates the charter's "Shift ×5, Ctrl
  unlimited" seed.
- S3: "By holding SHIFT you can set a path for your troops to follow." (Shift = queue,
  consistent with additive/queue semantics.)

---

## Finding 4 — what the "selection quad" should look like

This must be assembled from **two evidence tiers**, kept separate:

**Tier A — exact donor pixel constants (from local donor source recon, not online):**
L1 claim 18 / L3 §"Visual" / L4 donation table: the drag-frame outline is bound via
`data\resources\resource.lib:47` `SelectionBrushFileName=.\data\brushes\selection.cfg`,
whose `LineSetup` is `RGBA(1,1,0,1)` — **pure yellow**, `LinePattern=65535` (solid),
`LineWidth=1`, `AntiAliased=False`, `LineStep=1`, `Visible=True`. There is **no fill**.
This is the authoritative target style for our overlay. Label: observed (donor config);
that the engine actually rasterises it live is **UNVERIFIED** (L3 "Intent-only", item 4).

**Tier B — online corroboration of the surrounding visual language:**
- S8 (Steam suggestion, 25 Aug 2017), verbatim: "when units are above farms, you cannot
  see the highlight circles anymore. The layers at which these circles are drawn should be
  fixed… The same with when these units are behind structures. Some games fix this by
  giving them a white outline." Confirms donor selected-unit feedback is **circles under
  units** whose draw layer/occlusion is imperfect; the white-outline idea is a *fan
  suggestion*, not donor behaviour.
- S7 (bug thread), verbatim: "there is no visual indication of selected units, if they are
  standing next to a building (**their blue/yellow circle is 'under' the building**)".
  Confirms the circles' colour family (blue/yellow) and the occlusion defect.
- S7, verbatim: "when SHIFT selecting some types of units in your current selection, there
  is no highlight (visual indication) which units you selected" — donor bug, do not copy.
- S4 §8.3: control-group-selected units get **green highlights** via `TXGroupSelectionViewer`
  (native). Do not confuse these with the marquee yellow or the blue/yellow unit circles.
- (Context, lower weight) Editor docs mirror the yellow-frame convention: S-search result
  from cossacksworld.ucoz.co.uk "Selected mode highlighted by yellow frame" — that is the
  **map editor**, not the in-game marquee; use only as corroborating house style.

**Synthesis — "selection quad" spec for our port (DONOR_CITED style, native raster UNVERIFIED):**

1. **Screen-space overlay**, axis-aligned rectangle in viewport pixels, drawn by the
   input layer from the authoritative drag start/current mouse pixels — not by projecting
   a world-space `Rect2` back through the camera (L4's `camera3d.world_to_px()` SIM-vs-
   centred-metres trap).
2. **1 px solid yellow** outline `Color(1,1,0,1)`, no fill, no anti-aliasing (Tier A).
3. Present **only while dragging**; hidden and rect emptied on LMB-up / minimap release
   (L4 acceptance criteria).
4. It must coexist with camera panning — the rectangle is anchored to screen drag pixels
   while the world scrolls underneath (Finding 1), which is precisely what the donor
   2016-11 patch added.
5. Selected-unit feedback is separate from the quad: unit highlight circles/aura
   (`selection.friend`, `selection.building.<0..3>`, friend/ally/enemy materials, render
   size 0.7 — L1 claims 19–21), plus green group highlights for an active control group.
6. **Legibility is a known donor weak point** (S7/S8): circles hide under buildings/farms.
   Our port may improve on this, but must not *remove* the donor-style feedback to do so.
   Note: no donor GPU screenshot of the quad was obtained — the exact on-screen thickness
   at non-1× DPI is **UNVERIFIED**.

---

## Finding 5 — donor bugs recorded but explicitly NOT to be copied

Per charter §1b.2. Each is **observed** as a third-party report, none reproduced here.

| Bug | Source + verbatim | Why we do not copy it |
|---|---|---|
| **Box-select stops working after selecting a wall** | S6 WGB: "Cossacks 3 has quite a number of bugs living within its code, from the developer's console still being accessible through a tap of P to **the box selection not working after you select a wall** and units sometimes failing to obey commands." | Explicit charter named defect. Our port must keep box-select working after any prior selection, including a wall/building. L1 claim 21 records that donor walls get *no highlight* — a plausible related cause; our port must not inherit the failure. |
| Drag-box + camera interaction broken at launch | S7 (OP, 20 Sep 2016): "interface (CRITICAL): **drag-box selecting units in half-broken: it frezzes window scrolling with mouse, but if I scroll with keys, the box shifts along with the view instead of getting resized from the point I started it**"; also "Cannot scroll and select at the same time"; S11: "Selecting units is only possible on the currently visible area, the camera doesn't move with the selection." | S1/S2 show GSC *fixed* the frame+scroll behaviour in Nov 2016. Target the **fixed** donor behaviour (Finding 1), not the Sep-2016 broken state. |
| Box select intermittently dies | S7 comment #1 (noah): "My box to select units has stopped working and I can't select the troops I just recruited…"; comment #10: "just got this one and it carried into my next game"; S11/stale reports of selection limited to visible area. | Robust state reset on LMB-up / mode change is required in our port. |
| No visual delta on Shift-add | S7: "when SHIFT selecting some types of units in your current selection, there is no highlight (visual indication) which units you selected." | Our Shift-add should give at least the normal feedback. |
| Selected markers hidden by terrain/buildings | S7: "their blue/yellow circle is 'under' the building"; S8: "when units are above farms, you cannot see the highlight circles anymore." | Do not reproduce the occlusion; keep the ring layer above ground decorations. |
| Missing selection audio on some units | S7: "some units do not have sound effects while walking or when you select them"; L1 claim 22 records donor `selectpeasant1..6`/`selectship` cues. | If port audio assets exist, wire cues; otherwise document as missing (L4 already does). |
| General UI clunkiness / micromanagement (context only) | S9: "This can be clunky however, because of the way the UI is set up and the overall messy nature of setting up ranks"; "a clunky UI, grindy late game and unit imbalances"; S10 CONS: "Tons of redundant micromanagement", "Low legibility and chaotic combat". | Context for why the quad/feedback matters; not a feature request to copy. |

---

## Finding 6 — cross-check summary against DSEL_01 / DSEL_02 / RV_SEL_01 / SEL_01

| Topic | Online (F03) | Local reports | Agreement |
|---|---|---|---|
| Drag-select is canonical | S1 official, 12 Nov 2016 | L1/L2/L3 donor source | CONFIRMED, online adds date + camera-follow detail |
| Box updates live while button held | S4 §Key points/§1.1 | L1 claims 3–6 | CONFIRMED |
| Own-only / playable filtering | S4 §1.2 | L1 claim 8, L3 `(false,true,true,true)` | CONFIRMED |
| Shift = add | S3, S4 `addunitsofsametype` | L1 claim 4, L3 Conflict 1, L4 probe 329 | CONFIRMED; port implemented |
| Double-click / Ctrl / Z same-type | S3, S4 §7.3 | L1 claim 7/16, L4 `0.5 s` | CONFIRMED; port literal 0.5 but unasserted |
| Grouping 0–9 | S3, S4 §8.1–8.3 | L1 claim 26 (select family only; groups native) | CONFIRMED, online more complete |
| Outline yellow 1 px solid/no fill | S7/S8 only colour-family context (blue/yellow circles, editor yellow frame) | L1 claim 18 + L3 §Visual exact `selection.cfg` values | Local is authoritative; online does not contradict |
| Native inside-box predicate | no online source found | L1 claim 24 / L3 open question 1 — **UNVERIFIED** | Still UNVERIFIED |
| Ctrl-remove in drag is disabled | no online source found | L1 claim 5 (`//spmRemove`), L3 Conflict 1 | Local-only; keep as is |
| Port state | n/a | L4: overlay + world epsilon + Shift + 0.5 s; **no camera-follow** | See G1 |

---

## Gap list for our port (actionable, no edits made)

| # | Gap | Evidence | Suggested owner / note |
|---|---|---|---|
| **G1** | **No edge-scroll / camera-follows-drag.** Port keeps a two-ground-point world rect with no camera pan while dragging; donor's headline 2016-11 feature is "frame + map moves with you". | S1 RU/UA text; S2 frame/camera fix; L4 diff rows 1–4 | D-wave (selection quad). Highest priority; redesign the overlay around screen drag pixels + camera motion. Watch the S7 "box shifts instead of resizing" failure mode. |
| **G2** | Native inside-box predicate still unknown (centre / AABB / selection size / frustum). Port uses `rect.has_point(e.pos)`. | online: none; L1 claim 24, L3 open q.1 | Keep PORT APPROXIMATION label; do not invent a donor literal. |
| **G3** | Exact quad colour/thickness not visually A/B-checked against a donor frame. Values are donor-config-exact but live rasterisation UNVERIFIED. | L1 claim 18, L3 "Intent-only" item 4 | A windowed donor capture (out of charter scope) would be needed; until then DONOR_CITED + UNVERIFIED raster. |
| **G4** | Composition filters (own player; land > water > buildings; drop guards when non-guards present; squad collapse) not implemented; port filter is `kind=="unit"` + `player==0`. | S4 §1.2 partially; L1 claim 11, L2 §D, L4 open q.5 | Out of SEL-01 scope; needs its own ticket. |
| **G5** | `pickfrustum` / off-frustum exclusion not implemented; donor cannot pick outside camera frustum. | L1 claim 8/25, L3 open q.9 | Depends on G1 (edge-scroll changes the frustum during drag). |
| **G6** | Selection sounds / highlight-material semantics only approximated (rings, no `selection.friend`-style mapping). | S7 (missing select SFX), L1 claims 19/22, L4 §UNVERIFIED | Wire if assets exist; else document. |
| **G7** | No control-group green-highlight feedback (`TXGroupSelectionViewer`) and no group shortcuts in port. | S4 §8.1–8.3 | Separate UI ticket. |
| **G8** | Double-click `0.5 s` literal has no elapsed-time assertion; `spmFrame` vs `spmRunTime` naming unresolved (O1). | S4 §1.1 vs L1/L3; L4 §UNVERIFIED | TEST-S1 / donor-source follow-up. |
| **G9** | No fix yet for step (h) edge-scroll "box shifts with view" donor bug when combining keyboard + mouse scroll. | S2 official fix note, S7 OP | Regression test candidate for G1 implementation. |

---

## Open questions

1. **O1 — `spmFrame` vs `spmRunTime`.** S4 §1.1 says box selection uses mode `spmFrame`
   ("updated every frame while held") while L1/L3 report only `spmRunTime`/`spmAdd` in
   active donor scripts and a 7-value enum without `spmFrame`. Possibilities: almanac
   paraphrases a native sub-mode, or derives from a different game build. **UNVERIFIED**;
   do not change our mode strings on the strength of S4 alone.
2. O2 — exact edge band / pan speed during marquee drag (S1/S2 confirm behaviour, no numbers).
3. O3 — whether `SetClipCursor` (S4 §3) is actually engaged during a live drag in the
   shipped game, and its interaction with multi-monitor windowed mode (S7 mentions mouse
   capture failing there).
4. O4 — whether the post-2016-11 fixed donor behaviour fully resolves the Sep-2016
   "box selection after selecting a wall" bug (S6); no post-patch retest found online.
5. O5 — no donor screenshot of the live yellow quad was found; thickness at non-1× DPI and
   whether a faint fill exists remain **UNVERIFIED** (local `selection.cfg` says no fill).

---

## Summary

Online research establishes that the **selection frame is a named, official Cossacks 3
feature of 12 Nov 2016**, and — critically — that its headline behaviour is **"when you
drag the frame, the map moves with you"**, enabling box-select of armies larger than the
screen (S1, RU/UA text); the 20.11.2016 patch then fixed a camera/frame simultaneous-scroll
error (S2). Contemporary UI guides and the source-cited almanac corroborate the rest of
the donor contract: live-updating box, Shift-add/queue, double-click **or Ctrl** **or Z**
for select-all-same-type, ten 0–9 control groups, owner/playable filters and a screen-space
rectangle with per-frame object marking (S3, S4). The exact quad style — **1 px solid
yellow, no fill, no AA** — remains donor-config-exact from landed local recon (L1/L3);
online sources only corroborate the surrounding yellow/blue highlight-circle language and
its known occlusion weakness (S7, S8). Reviews and forum threads confirm the donor bugs
the charter names: **box selection failing after selecting a wall** (S6), broken early
drag-box/camera interaction (S7, S11), no Shift-add highlight (S7) and hidden selected
markers (S7, S8) — all recorded, none to be copied. Nine port gaps are listed, led by the
missing camera-follows-drag behaviour (G1). The `spmFrame`/`spmRunTime` naming conflict
(O1) and the still-unknown native inside-box predicate (G2) are left **UNVERIFIED**.

No code, config, asset, test, scene, shader, menu or git state was changed; no Godot job
was submitted; exactly one report file was written. No donor binary was run or A/B frame
produced, so donor visual parity remains **UNVERIFIED** per the charter.
