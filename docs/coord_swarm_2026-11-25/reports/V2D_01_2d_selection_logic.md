---
id: V2D-01
title: "2D port's logical selection features (SECONDARY helper) — drag box, click/double-click, shift-add, aura, orders, tests; 2D→3D parity and reusable algorithm outline"
owner: V2D-01
date: 2026-11-25
scope: "READ-ONLY. app/scripts/** and app/tests/** (shipping 2D port) + read-only variant3d/scripts/** for the parity matrix + docs. One output file only; no Godot jobs, no git, no code edits."
status: SECONDARY_EVIDENCE__DONOR_IS_AUTHORITY
governing_rule: "docs/coord_swarm_2026-11-25/CHARTER.md:34-43 — donor is source of truth; 2D port is a SECONDARY helper for logical intent only; if 2D and donor disagree, donor wins and 2D is logged as divergence."
evidence_labels: "observed = literal code/doc line read this pass; derived = computed from observed lines; inferred = attribution/geometrical consequence not directly probed."
---

# V2D-01 — 2D logical selection features (SECONDARY helper)

> [!IMPORTANT]
> **SECONDARY throughout.** Everything below is read from the *shipping 2D port*
> (`app/`) to understand **logical intent** only. It is not donor truth and must
> never override donor evidence. Donor drag-rectangle evidence belongs to
> **DSEL-01**, donor projection math to **DSEL-02**, and the authoritative 3D
> selection-rectangle code audit to **V3D-01** (all three RUNNING at time of
> writing, `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:18-19,26`). Where 2D and
> donor conflict, **donor wins** (§5).

## 0. Goal

Enumerate the **logical** selection features implemented in the shipping 2D
port, cite them `path:line`, classify each as donor-derived vs invented
approximation using existing docs, map each to the current `variant3d/` 3D
equivalent, and extract a reusable algorithm outline that could guide a 3D fix
— without editing any code.

## 1. Sources

**Orientation (read in full this pass):**
- `docs/coord_swarm_2026-11-24/reports/FIXSEL_picking_orders.md` — 3D pick/order
  functional fix; authoritative on the 3D seam and its failures.
- `docs/coord_swarm_2026-11-24/reports/FIXSEL_visuals.md` — 3D selection ring /
  owner colour; authoritative on donor-vs-approximation labelling.
- `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_02_vs_2d.md` — 2D-vs-3D
  coverage table; rows 81, 84, 127, 130 name the selection gaps.
- `docs/audit/ANIM_ADJUDICATION.md` — evidence standard / "do not detune correct
  data to please a stale test" (D-22).
- `docs/audit/MICRO.md` — rows 27–32 (groups, double-click, shift-add,
  same-type selects) and §6 donor notes.
- `app/tools/AGENT_PROTOCOL.md` — boundaries and read-only discipline.

**2D port read this pass:** `app/scripts/input_controller.gd` (full),
`app/scripts/world.gd` (selection-relevant ranges), `app/scripts/hud.gd`
(`refresh_selection`), `app/scripts/main.gd` (wiring), `app/scripts/camera.gd`,
`app/scripts/game.gd` (`pick_radius`, `get_selected`), `app/scripts/selftest.gd`,
`app/scripts/uitest.gd`, `app/tests/*.gd` (grep sweep + `t_pick_res.gd`).

**3D read this pass (comparison only):** `variant3d/scripts/input_controller.gd`,
`variant3d/scripts/picking3d.gd`, `variant3d/scripts/world3d.gd`,
`variant3d/scripts/world3d_fx.gd`, and a repo-wide grep of `sel_rect/sel_active`.

**Donor-derived context cited from existing docs (not re-read this pass):**
`docs/coord_swarm_2026-11-24/PROGRESS.md:989-1002` (donor `onselection.inc:10-175`,
hotkey/divergence notes), `docs/guides/GUIDE3.md:615-663` (G4.3 donor-style
selection handlers), `docs/guides/GUIDE4.md:105-108` (L3 acceptance list),
`docs/audit/RENDER_ARCH_CRAFT_ANYTHING_REPORT.md:231` (verbatim `hotkeys.cfg`
select bindings), `docs/REPORT_NAV_MINIMAP_SHORE.md:290`, `docs/audit/MICRO.md`,
`docs/coord_swarm_2026-11-24/reports/FIXSEL_visuals.md`,
`docs/coord_swarm_2026-11-25/CHARTER.md:24-25,37-38,78`.

## 2. 2D feature table (SECONDARY evidence)

All rows are `observed` from current source unless labelled otherwise.

| # | Logical feature | Where implemented (2D) | Behaviour / exact rule | Provenance |
|---:|---|---|---|---|
| 1 | Selection state + atomic mutation | `app/scripts/input_controller.gd:13` (`selected_ids`), `:140-146` (`get_selected`), `:148-158` (`_set_selection`) | `_set_selection(arr)` clears every old `e["selected"]=false`, resets `selected_ids`, sets new flags, `game.bld_dirty += 1`, `hud.refresh_selection(get_selected())` (`:149-158`). `get_selected()` resolves ids via `game.by_id`, skips dead. | Donor-style selection semantics; the *exact* flag/dirty/HUD wiring is a port invention (GUIDE3 G4.3 prescribes the shape at `docs/guides/GUIDE3.md:615-663`). |
| 2 | Drag-rectangle start / end | `input_controller.gd:14-15` (`drag_start := Vector2.INF`, `dragging`); press `:474-475`; motion `:527-528`; release `:511-512` | Press stores raw screen pixel in `drag_start` and resets `dragging`. Motion sets `dragging=true` only after 6 px. Release always resets `drag_start=INF`, `dragging=false`. | Event shape donor-style (`docs/coord_swarm_2026-11-24/PROGRESS.md:1002` donor `onselection.inc:10-175` richer); pixel values port-chosen. |
| 3 | Drag-vs-click threshold | `input_controller.gd:479` and `:527` — `(mb.position - drag_start).length() > 6.0`; draw-only gate `app/scripts/world.gd:3642` — `sel_rect.size.length() > 4.0` | 6.0 screen px decides drag vs single click on release and arms `dragging` on motion. Separate 4.0 px gate only suppresses drawing a degenerate rect. | **Invented approximation.** No donor threshold found in any doc read; DSEL-01 is still resolving donor constants. `derived`: two distinct constants (6 px logic / 4 px draw). |
| 4 | Unit enumeration (box) | `input_controller.gd:485-489` | `for e in game.entities`, skip `e.dead`, `e.player != 0`, `e.kind != "unit"`; only alive player-0 units qualify. A second enumeration for HUD is `game.gd:2585-2590`. | Port simplification; donor filtering is richer (`PROGRESS.md:1002`, "Donor selection filtering richer (onselection.inc:10-175)"). |
| 5 | Inside-box test | `input_controller.gd:481-483` (rect build), `:488` (`rect.has_point(e.pos)`); screen→world `:337-343`; world→screen `world.gd:350-351` | Builds `Rect2(minf(a.x,bp.x), minf(a.y,bp.y), absf(...), absf(...))` from two `_screen_to_world()` corners in **sim metres**; tests `e.pos` (sim metres). `_screen_to_world` uses the **affine** canvas inverse divided by `world.view_scale`; `world_to_px = p * view_scale`. Linear ⇒ screen box ↔ sim box exactly. | Donor-style box selection; the affine implementation is the 2D renderer's natural mapping, not a donor constant. |
| 6 | Shift-add to selection | `input_controller.gd:502-506` | On **single click** only: `Input.is_key_pressed(KEY_SHIFT)` → `get_selected()`, append `e` if not already present, `_set_selection(cur)`. | Donor-derived semantic (`docs/guides/GUIDE3.md:654-658`, `docs/audit/MICRO.md:211` row 30 IMPLEMENTED). `derived` nuance: a drag overwrites the selection unconditionally (`:490`) — shift is ignored for box drags. |
| 7 | Double-click same-type | State `input_controller.gd:29-30` (`last_click_t`, `last_click_sid`); detection `:493-501`, timing stored `:509-510` | Same `e.sid` within `< 0.35 s`; selects every alive player-0 **unit** of that sid whose `u.pos * world.view_scale` lies in `world.view_rect`. | Donor-derived intent ("original behaviour", `GUIDE3.md:648`; `docs/audit/MICRO.md:210` row 29 PARTIAL). `inferred` divergences: 0.35 s window and on-screen-only filter are port choices — `MICRO.md:328` says "donor double-click may include off-screen same-type — UNVERIFIED". |
| 8 | Entity click pick | `input_controller.gd:345-369` (`_pick`), radius `game.gd:1555-1560`, fallback `:363-365` | One pass over `game.entities`: radius `game.pick_radius(e)` = footprint/def radius **+ 1.4 m grab margin**; `players_only` restricts only the radius test; unconditional 2 m nearest-entity fallback so enemies can be clicked; strict `<` distance keeps first entity on ties. | Port approximation; donor pick depth is engine-side / UNVERIFIED (`FIXSEL_picking_orders.md:247-250`; `picking3d.gd:259-265`). |
| 9 | Selection aura / visuals | Flags from `:148-158`; building aura `world.gd:3011-3049`; unit ring `world.gd:3252-3254`, facing+overlay `:3361-3366`; drag rect draw `:3641-3647`; squad links `:3583-3601`; rally flags `:3602-3629`; palette `:2172-2182`; overlays loaded `:319-320` | Buildings: squashed player-coloured glow, pulse `0.85+0.15*sin(anim_t*3+id*0.7)`, unfinished progress arc, dark under-ring, tinted donor `ring_sel`, four pulsing corner diamonds, garrison pips. Units: `ov_ring[int(e.player)]`, `rw = vr*2.9`, facing tick + `ov_sel`. Drag rect: white 1.5 px outline + 0.18 alpha fill. | Mixed: overlay PNGs `ring_p0/ring_p1/ring_sel` are donor artwork (`docs/ASSET_AUDIT.md:34`, `GUIDE3.md:279,305`); the glow/geometry/pulse constants and the 12-entry `PLAYER_COLORS` are **invented approximations** (`FIXSEL_visuals.md:19` = AUDIT3D-02 §2.1 "UNVERIFIED-INVENTED"; `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_02_vs_2d.md:81`; donor `gKeyColor` has 13 slots at `classes.script:7986-8015` per `FIXSEL_visuals.md:20`). Donor glow is engine-side (`SetHighlightRenderSettings`/`gGuiUpdateHighlights`), private-use: `world.gd:3012-3014`. |
| 10 | Orders after selection | `_right_order` `input_controller.gd:532-627`; minimap `minimap_order :200-213`; HUD routing `:215-240`; hotkeys `:749-997` | Right-click branches: patrol/guard/ghost/attack-ground/rally modes → repair (peasants + damaged friendly bld) → rally-only → entity pick + `_pick_res` + squad formation → `cmd_gather`/`cmd_resow`/`cmd_move`/`cmd_attack_move`/`cmd_attack`/`cmd_enter`/`cmd_build`/`cmd_gather`. Ends by clearing `attack_move_mode`. | Sim `cmd_*` are byte-identical SHARED `game.gd` (`COMPLETENESS_02:56,74`); the input routing is donor-style with port extensions (P two-click patrol, G cancel-guard). |
| 11 | Same-type / select-family hotkeys + groups | `input_controller.gd:709-715` (`_donor_combo`), `:717-747` (military/ships/same-type), `:749-794` (groups 1–9, Ctrl+Shift donor combos, backtick idle peasants), `:941-997` (`select_all`, `select_all_buildings`, `select_same_type`, `add_same_type`, `select_idle_*`) | Ctrl+digit stores selected ids; plain digit recalls; Shift+digit also recentres camera. Donor combos: Ctrl+Alt+A/Ctrl+Shift+A military, Ctrl+Q ships, Ctrl+Z / Ctrl+Shift+Z all/add same-type. | Donor-derived from `hotkeys.cfg` (`RENDER_ARCH_CRAFT_ANYTHING_REPORT.md:231`, `GUIDE3.md:769-783`). Divergence: donor Shift+N **adds to group** and group 0 exists; port Shift+digit **recentres camera** and only groups 1–9 (`PROGRESS.md:999-1000`, `docs/audit/MICRO.md:209` row 28 MISSING). |
| 12 | Tests that touch selection | `app/scripts/uitest.gd:115-123` (`select_box`), `:289-302` (`groups`); `app/scripts/selftest.gd:299-306` (`hud` → `selection_panel`); `app/tests/t_pick_res.gd:57-89` (resource pick only); `app/tests/manifest.json:163-165` | `select_box` calls `ictl._set_selection(peas)` **directly** and asserts `sel.size()==3` + panel visible; `groups` sends Ctrl+1 then 1 via `_handle_key`; `hud` calls `hud.refresh_selection([peasant])` and checks `hud_report()`. | `derived`: **no 2D test exercises an actual mouse drag, the 6 px threshold, the inside-box predicate, double-click, shift-add, or aura pixels.** `docs/audit/MICRO.md:210,212` lists `t_dblclick` / `t_sametype` as *proposed new* tests, i.e. not present. `t_pick_res.json` is retained for resource picking only. |

## 3. 2D → 3D parity matrix (SECONDARY comparison; 3D authority = V3D-01)

| 2D logical feature (2D evidence) | 3D equivalent in `variant3d/` | Verdict |
|---|---|---|
| Selection flags / HUD refresh `input_controller.gd:148-158` | `variant3d/scripts/input_controller.gd:207-217` — byte-intent identical | **PARITY** (observed). |
| Drag start / end / 6 px threshold `input_controller.gd:14-15,474-475,479,511-512,527-528` | `variant3d/scripts/input_controller.gd:29-30,608-609,613,646-647,662-663` — same constants and state machine | **LOGIC PRESENT**, but see next two rows and §4. |
| Inside-box test `input_controller.gd:481-488` | `variant3d/scripts/input_controller.gd:615-624` — same `Rect2`/`has_point` loop | **STRUCTURALLY PRESENT, GEOMETRY SUSPECT.** 2D corners come from an affine inverse (`:342-343`); 3D corners come from `picking3d.ground_point()` ray/heightfield (`:460-462` → `picking3d.gd:235-243`). `inferred`: under a tilted perspective camera, two ground-projected corners do **not** bound the same screen box, so the sim-space AABB is not the drawn box. Not probed here — V3D-01 owns this. |
| Rectangle overlay drawn `world.gd:3641-3647` | `world3d.gd:126-127` declares `sel_rect`/`sel_active`; `input_controller.gd:1166-1172` writes them; repo-wide grep finds **no 3D mesh/draw consumer** | **MISSING (visual).** Matches `COMPLETENESS_02:84,130` "data-only mirrors". Note `variant3d/scripts/world.gd:3642` still draws the rect, but that is the byte-identical 2D dev sandbox, not the 3D render path. |
| Unit enumeration `input_controller.gd:485-489` | `variant3d/scripts/input_controller.gd:619-623` — identical filters | **PARITY** (observed). |
| Shift-add `input_controller.gd:502-506` | `variant3d/scripts/input_controller.gd:637-641` — identical | **PARITY** (observed); same drag-overwrites nuance. |
| Double-click same-type `input_controller.gd:493-501,509-510` | `variant3d/scripts/input_controller.gd:628-636,644-645` — identical + explicit `Rect2` type guard at `:631-632` | **PARITY of code**; depends on 3D `view_rect` actually being the rendered screen rect (`world3d.gd:280-293`) — `inferred`, V3D-01 to confirm. |
| Entity click pick `input_controller.gd:345-369` (metre radius, nearest) | `variant3d/scripts/picking3d.gd:266-301` (screen-space pixel reach via `unproject_position`, depth-ordered ties); seam `input_controller.gd:470-480` | **EQUIVALENT INTENT, DIFFERENT ALGORITHM.** `players_only` forwarded verbatim (V7-68); 2 m fallback preserved. Residual `BODY_LIFT_M = 0.8 m` parallax estimate and yaw-0-only `_pixel_reach` are declared open risks (`FIXSEL_picking_orders.md:247-253`). |
| Selection aura / owner colour `world.gd:3011-3049,3252-3254,3361-3366` | `world3d.gd:535-559` derives entries from the read-only mirror → `world3d_fx.gd:387-431` builds `SelRing_<id>` torus + under-ring + owner pip, pulse at `:726-834` | **EQUIVALENT STAND-IN, NOT PARITY.** Procedural geometry, 13 donor colour slots; labelled `PORT APPROXIMATION — NOT DONOR PARITY` (`FIXSEL_visuals.md:6,24`). Missing 2D extras: building progress arc / four corner diamonds / garrison pips, unit facing tick, squad links, selected-building rally pennant (`FIXSEL_visuals.md:83`; `COMPLETENESS_02:82,85,127`). |
| Orders after selection `input_controller.gd:532-627` | `variant3d/scripts/input_controller.gd:694-...` with 3D `_pick`/`_pick_res` seams | **PARITY** (functional): FIXSEL probe 10/10 including exact sim destination `(155,155)` (`FIXSEL_picking_orders.md:183-214`). |
| Same-type / group hotkeys `input_controller.gd:709-747,749-794,941-997` | `variant3d/scripts/input_controller.gd:877-887,891-959,1093-1149` | **PARITY** (observed); inherits the same donor divergences (§5). |
| Selection tests | `variant3d/selftest.json` 29/29, `t_pick3d` 6/6, FIXSEL probe 10/10 (`FIXSEL_picking_orders.md:165-166,279`) | **PARTIAL.** No test asserts a real 3D drag-box selecting units — exactly the owner-reported fault (`CHARTER.md:25`, fix gate `CHARTER.md:78`). The 2D `select_box` test bypasses dragging too. |

## 4. Reusable algorithm outline (no code edits)

`derived` from the 2D code path; geometry warning `inferred`. Intended to guide
the 3D fixer **only after** DSEL-01/DSEL-02/V3D-01 report.

1. **Left-button state machine.** On press store the raw screen pixel and clear
   the drag flag; on motion arm dragging once displacement exceeds one pixel
   threshold; on release compare displacement to the *same* threshold and
   either run the box branch or the click branch, then reset both state vars.
   Keep the threshold in one place so logic and drawing cannot drift (2D uses
   6 px for logic but 4 px for the draw gate — `input_controller.gd:479` vs
   `world.gd:3642`).
2. **Authoritative screen→frame conversion.** Convert both box corners with the
   *same* function the click/ground-order path uses (2D: affine canvas inverse ÷
   `view_scale`; 3D: `picking3d.ground_point` ray-heightfield). Build a canonical
   `Rect2` with `minf`/`absf` so drag direction is irrelevant.
3. **Enumerate then filter.** Iterate `game.entities`; skip `dead`, wrong owner,
   wrong `kind`. This is the only selection predicate in 2D; donor may be richer
   (`onselection.inc:10-175`) — do not narrow it further without donor evidence.
4. **Inside test + atomic commit.** `rect.has_point(e.pos)`; collect an array;
   commit through one `set_selection()` that clears old flags, sets new flags,
   bumps the dirty counter and refreshes HUD **in one call**. Never mutate the
   sim outside that seam.
5. **Mirror visuals read-only.** Derive rings/auras from the selection flags in
   a sync step; give the FX layer set semantics so ids removed from the
   selection lose their marker in the **same** call (2D clears the frame
   `selected` flips; `world3d_fx.gd:402-406` does the same with immediate free).
6. **Click branch stays separate.** Radius pick with nearest-wins + fixed
   fallback; double-click = same sid inside one time window + on-screen filter;
   shift = append to current selection via `get_selected()`. Do not let the box
   branch consume these modifiers unless donor says so.
7. **Perspective-safe box test (the key 3D lesson).** `inferred`: with a tilted
   perspective camera, projecting only two corners to the ground and forming a
   sim-space AABB is **not** equivalent to the screen rectangle the user drew.
   Two donor-neutral options to evaluate: (a) project each candidate entity's
   **rendered** point to screen and test against the **screen** rect (mirrors
   `picking3d.pick`, which already works: `picking3d.gd:281-290`), or (b) unproject
   all four screen corners to the ground and point-in-quad test. Decide from
   DSEL-01/DSEL-02 donor evidence, not from 2D.
8. **Smallest-map verification.** Isolated probe only: place 3–4 known player
   units inside/outside a known box, drag, assert exact `selected_ids`; then
   assert clear-on-empty-drag, click-pick, double-click, shift-add, and that a
   right-click order after box selection lands at the intended sim point
   (FIXSEL's `(155,155)` assertion is the template). Only then run combos/final
   gates (`CHARTER.md:39-40,74-81`).

## 5. Divergences from donor noted (donor wins)

| 2D behaviour | Donor evidence in docs | Standing |
|---|---|---|
| 6 px drag threshold; 4 px draw gate | No donor value found in docs read; DSEL-01 pending | **UNVERIFIED / port-chosen** |
| 0.35 s double-click window; on-screen-only same-type filter | `docs/audit/MICRO.md:328` — donor may include off-screen same-type, UNVERIFIED | **Port approximation** |
| 12 hardcoded `PLAYER_COLORS` with `wrapi` | Donor 13-slot `gKeyColor`, slot 12 mercenary (`FIXSEL_visuals.md:19-23`; `classes.script:7986-8015`) | **Invented; donor wins** |
| Procedural pulse/ellipse/diamond aura + `+1.4 m` pick margin | Donor glow engine-side and private-use (`world.gd:3012-3014`; `picking3d.gd:259-265`) | **Approximation; no parity claim** |
| Three entity filters (dead/owner/kind) | Donor `onselection.inc:10-175` "richer" (`PROGRESS.md:1002`) | **Partial** — DSEL-01 must define the real filter set |
| Shift+digit = camera jump; groups 1–9 only | Donor Shift+N **adds** to group; group 0 supported (`PROGRESS.md:999-1000`) | **Divergence** — logged, not fixed here |
| P = two-click patrol, Q = instant patrol | Donor patrol is button-only (`P` commented `//TOHOTKEYS//`), donor Q = viewcollision (`PROGRESS.md:1001-1002`; `RENDER_ARCH_CRAFT_ANYTHING_REPORT.md:231`) | **Port extension** |
| `select_box` uitest bypasses the drag | No donor analogue; test-design issue only | **Test gap** |

## 6. Open questions

1. **Q1 (DSEL-01):** donor drag enter/move/leave events, exact threshold (if any),
   and the authoritative filter set — 2D's `>6.0` px and three filters are not
   donor-cited.
2. **Q2 (DSEL-02 / V3D-01):** does the donor box test in screen space or ground
   space? This decides between the two options in §4 step 7. The 2D affine
   mapping gives no answer for a perspective camera.
3. **Q3 (V3D-01):** is the 3D drag-box failure caused by the ground-corner AABB
   (§3 geometry row), by `sel_rect` never being drawn, by `view_rect` mismatch,
   or by a combination? This report did not run a Godot probe (READ-ONLY task).
4. **Q4:** donor double-click window and whether off-screen same-type units are
   included (`MICRO.md:328`).
5. **Q5:** should the drag box honour Shift (add) at all? 2D does not
   (`input_controller.gd:490`); donor `onselection.inc` is unread here.
6. **Q6:** whether to expose donor slot 12 (mercenaries) and whether donor key
   colour alpha is 1.0 (`FIXSEL_visuals.md:81-82`).
7. **Q7:** no 2D or 3D test asserts aura pixels or a real drag; who adds the
   smallest-map drag test named in `CHARTER.md:78`.

## 7. Summary

`observed`: the shipping 2D port has a complete, compact logical selection
pipeline — one atomic `_set_selection` seam, a 6 px drag threshold, a sim-space
AABB over filtered `game.entities`, 0.35 s same-type double-click, click
shift-add, click pick with radius + 2 m fallback, player-tinted procedural
aura plus donor overlay art, a full right-click/hotkey order router, and HUD
selection panel refresh. `derived`: the 3D controller copies nearly all of this
byte-for-byte; the functional click-pick/order path is verified (FIXSEL 10/10)
and rings exist as procedural stand-ins. `inferred`: the most likely 3D
drag-box fault is the frame mismatch — 2D's affine screen→sim map makes a
two-corner ground AABB exactly the drawn box, while 3D's perspective ground
ray does not — compounded by `sel_rect`/`sel_active` having no 3D draw
consumer. All of that is **SECONDARY**: donor evidence from DSEL-01/DSEL-02 and
the V3D-01 audit is authoritative, and any conflict with 2D must be resolved in
the donor's favour. No code was edited; no Godot job was submitted; no git
operation was run.
