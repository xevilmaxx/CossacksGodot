---
id: STAND-SCALE-LAW
title: "STAND keep-clear scale law — donor cell-ellipses vs port scaled circle"
agent: "worker STAND-SCALE (full 1:1 Cossacks 3 donor port, 2026-11-26)"
date: 2026-11-26
status: REPORT LANDED
labels: [O, D, U, "NO PARITY CLAIM"]
scope: "READ-ONLY decompilation. Exactly one file written: docs/terrain_swarm_2026-11-26/reports/STAND_scale_law.md. No code/Godot/git/donor-execution; no other edits."
parity_guard: "PARITY UNVERIFIED. No donor GPU A/B frame. No parity claim. Chain 0/6. RESULT IS NOT GOOD."
ticket: "23,146 stand rejects; forests pushed far from starts; landscape reads empty"
---

# STAND scale law — byte-proven verdict

## Executive summary

1. **[D] Donor keep-clear is three RAW cell-count ellipses centred at `(start.x, start.y+2)`, with NO multiplication by map size, `DONOR_UNITS`, or any scale factor.** Constants `5/7, 12/15, 22/18` (`dogenerate.inc:407-414`) are passed verbatim as `(rx, ry)` to `_misc_FillPatternMaskElipse` at `:984` (C1), `:769` (C2), `:947` (C3).
2. **[D] Port `* map_scale` (`MAP_W / DONOR_UNITS`) and `* 1.5` / `* 1.4` factors are PORT-INVENTIONS with zero donor basis.** Spec `07_RESOURCES.md:87-88` + V08 byte-prove donor generator distances are map cells 1:1 and `DONOR_UNITS=160` / "1 unit = 2 cells" is port-invented.
3. **[D] Minimal conforming change: `protect` must become the donor ellipse, not a scaled circle.** Exact prescription in §4 (stated only, NOT applied).
4. **[D] Shrinking the ring exposes two port-side dependents that have no donor grounding** (§5): the `near_start` relief-flatten/rock-art suppression ring and the 16-tile final clear + 7-tile forest wipe. Both are port adaptations; no donor line carries 16 / 7 / `protect`.
5. **[D] Magnitude check closes the ticket mechanism:** at 240-wide `protect = 15 * 1.5 * 1.5 = 33.75` tiles circular per start vs donor max semi-axis **22** cells elliptical — ~2.4x linear, ~5-7x area per start. That scale, not the donor law, explains 23,146 rejects and forests pushed far from starts.

---

## 1. Donor ellipse call arguments — raw cell counts, no scaling [D]

### 1.1 Constants (`dogenerate.inc:407-414`) [O]

Via `X03_dscript_corpus.md:705-710` (verbatim donor-text read):

```
D1:407     [*] = ;const cCircle1MaskX = 5;
D1:408     [*] = ;const cCircle1MaskY = 7;
D1:410     [*] = ;const cCircle2MaskX = 12;
D1:411     [*] = ;const cCircle2MaskY = 15;
D1:413     [*] = ;const cCircle3MaskX = 22;
D1:414     [*] = ;const cCircle3MaskY = 18;
D1:416     [*] = ;const cBorderObjDist = 1;
```

No divisor, no multiplier, no `mapsize`, no `DONOR_UNITS`, no `160` on these lines. The values are integer literals consumed as ellipse semi-axes in cells (see §2 for the unit proof).

### 1.2 Application sites [O]

| Donor site | Verbatim call (via landed reports) | Provenance |
|---|---|---|
| `dogenerate.inc:984` in `CreateStartPoint` | `_misc_FillPatternMaskElipse(pointx, pointy+2, cCircle1MaskX, cCircle1MaskY);` | `X03:718` verbatim; `ANOM_stand.md E4`; `DEC_U_start_positions.md:55`; `DEC_U_victory_start.md:106` |
| `dogenerate.inc:769` in `SetupStartingResources` (after stoneforest ring) | `_misc_FillPatternMaskElipse(pointx,pointy+2,cCircle2MaskX,cCircle2MaskY)` | `X03:940` 7-step order (stoneforest `:743-767` / C2 ellipse `:769` / stones / 2 forests / stones at `mindst+4` / 1 forest / C3 ellipse `:947`); verbatim arg form via `DEC_DEEP_forest_generation.md:120` |
| `dogenerate.inc:947` in `SetupStartingResources` (end of function) | `_misc_FillPatternMaskElipse(pointx,pointy+2,cCircle3MaskX,cCircle3MaskY)` | `X03:940` (C3 keep-clear `:947`; C3 *placement* `:949-977` is commented out — keep-clear only); verbatim arg form via `DEC_DEEP_forest_generation.md:120` |

**[D] consequence.** All three calls pass `(pointx, pointy+2, cCircleNMaskX, cCircleNMaskY)`:

- Centre is `(start.x, start.y+2)` — the `+2` y-offset is verbatim (`DEC_U_victory_start.md:106` explicitly: "port keep-clear must reproduce it, not centre on the point").
- Arguments are the RAW constants `5/7, 12/15, 22/18`. **No multiplication by map size, `DONOR_UNITS`, `map_scale`, `1.5`, or `1.4` appears at `:407-414`, `:769`, `:947`, or `:984` on any evidence read.** The largest donor ban is the **22x18 ellipse** (semi-axes 22 / 18, area `pi*22*18 ~= 1244` cells).
- Supporting constant: `mindst := Min(cCircle2MaskX,cCircle2MaskY)+4` (`dogenerate.inc:863` via `X03:940`) — again raw constants plus 4 cells, no scale factor.

### 1.3 Occupancy-only checker (`misc.script:3384-3521`) [O]

Via `X03:1125-1142` (supplementary targeted read of `misc.script`, labelled D9 there):

- `D9:3402-3405`: reads pattern mask W/H + offsets.
- `D9:3441`: fast path samples every 4th cell when `angle=0` (`const step = 4`).
- `D9:3466`, `:3504`: rejects out-of-map **or** `gPatternMask` already set.
- `D9:3497-3500`: `doStand=True` branch writes the mask.
- `D9:3516-3521` (`Ext`): test with `doStand=False`, then atomic stand with `doStand=True`.

**[D]** Donor "stand" reject = footprint cell outside map or already in `gPatternMask` (which includes the three start ellipses + shore + prior stamps). No water/rock branch inside the checker; water/shore enters the mask earlier from `height < -0.1` (`dogenerate.inc:1557-1564` via spec `07_RESOURCES.md` §3).

---

## 2. Scale law: donor distances are 1:1 cells; `*map_scale` and `*1.5` are port-inventions [D]

### 2.1 Spec verdict (byte-proven, inherited) [O]

`spec/07_RESOURCES.md:85-92` (§8 "Scale correction", from V08) [O]:

> Donor generator distances are **map cells (1:1)** — `DONOR_UNITS=160` / "1 unit = 2 cells" is PORT-INVENTED and doubles radii/footprints at 320². Therefore rings `14+8R / 32+10R / 70+12R / 22+16R`, ellipses 5x7/12x15/22x18, mine footprints and field step 1.6981 are in **cells**. Donor metre is defined (`dmscript.global:170-173`, 2 m/cell) so `TILE_M=2.0` is donor-grounded horizontally; stored height units stay `[U]`.

### 2.2 V08 proof (landed, not re-litigated here) [O]

`reports/V08_coordinate_scale.md` §3/C1 + §4/Q2 [O] re-read this pass:

- Donor adds `dst` directly to start positions expressed in `±GetMapWidth div 2` **cells** (`dogenerate.inc:402-405,435-438,521,559-655,704-709,1599-1602`).
- Stamps index `gPatternMask[floor(x+W/2)]` in those coordinates (`misc.script:3384-3405`; `dogenerate.inc:373`).
- Tiled patterns sit on a strict 25-**cell** grid (`dogenerate.inc:1335-1345`).
- **No donor text defines a 2-cells-per-unit generator scale.** The only donor-side 160s are `maphW=160` for a 320-cell map (`dogenerate.inc:437`) and unrelated constants — neither defines a generator unit.

**[D]** The port's `s = W / DONOR_UNITS` (see §3) doubles every donor cell distance at 320-wide and multiplies it by 1.5 at the port's 240 default. The extra `* 1.5` / `* 1.4` has no donor line at all (searched: no `1.5`/`1.4` factor adjacent to any `FillPatternMaskElipse` call in landed donor text).

### 2.3 What the port multiplies (observed, no execution) [O]

| Port site | Observed text | Donor basis |
|---|---|---|
| `app/scripts/pattern_gen.gd:9` | `const DONOR_UNITS := 160.0  # donor map = 320 cells = 160 generator units` | **None** — V08 verdict PORT-INVENTED |
| `app/scripts/pattern_gen.gd:71` | `var s := float(map_w) / DONOR_UNITS` | **None** |
| `app/scripts/pattern_gen.gd:100-101` | `dx := int(round(float(ca[0]) * s))` (footprint scaling) | **None** — donor footprints are 1:1 cells (V08 §5 table) |
| `app/scripts/pattern_gen.gd:173` | `r3 = maxf(CIRCLE3.x, CIRCLE3.y) * s * 1.4` | **None** — no donor `*1.4` |
| `app/scripts/pattern_gen.gd:197-198, 242-243` | `rx = r.x * s`, `ry = r.y * s` (ellipse marks) | **None** — donor passes raw constants |
| `app/scripts/pattern_gen.gd:267` | `dst = (... + RandomExt * ...) * s` (mine rings) | **None** — donor rings are raw cells |
| `app/scripts/pattern_gen.gd:490` | `rx0 = maxf(CIRCLE1.x, CIRCLE1.y) * s` (relief keep-clear, circularised) | **None** — donor relief keep-clear is not a scaled circle |
| `app/scripts/game.gd:869-870` (= `variant3d/scripts/game.gd:1584-1585`, same statement) | `var map_scale := float(MAP_W) / C3PatternGen.DONOR_UNITS` / `var protect := maxf(C3PatternGen.CIRCLE2.x, C3PatternGen.CIRCLE2.y) * map_scale * 1.5` | **None** — no donor `map_scale`, no `*1.5`, wrong circle (`CIRCLE2`), wrong shape (circle vs ellipse), missing `+2` centre offset |

**[D] arithmetic at the ticket sizes:**

- 320-wide: `map_scale = 2.0`, `protect = 15 * 2.0 * 1.5 = 45` tiles circular per start (matches `ANOM_stand.md` P6). Donor max semi-axis = 22. Linear ratio ~2.05-2.5x; area `pi*45^2 ~= 6362` vs `pi*22*18 ~= 1244` = **~5.1x**.
- 240-wide (port default per task): `map_scale = 1.5`, `protect = 15 * 1.5 * 1.5 = 33.75` tiles circular per start. Area `pi*33.75^2 ~= 3579` vs donor `~= 1244` = **~2.9x** per start; with 3-4 starts the banned union is the same order as the 23,146 reject count. Donor ellipses alone (~1.2k cells each) cannot produce that magnitude — consistent with `ANOM_stand.md` §2-§3.

---

## 3. Minimal conforming change (STATED ONLY — NO EDIT MADE)

**Answer to the task question: yes.** `protect` must become the donor's largest ellipse (C3 = 22x18) in CELLS with no scale factor, and the circular shape must become the donor ellipse at `(start.x, start.y+2)`.

Exact prescription (do NOT apply — this worker made no edit):

1. **File:line:** `app/scripts/game.gd:869-880` (live copy; identical statement at `variant3d/scripts/game.gd:1584-1595`).
2. **Delete** the two scale lines:
   - `var map_scale := float(MAP_W) / C3PatternGen.DONOR_UNITS` (`app:869` / `variant3d:1584`)
   - `var protect := maxf(C3PatternGen.CIRCLE2.x, C3PatternGen.CIRCLE2.y) * map_scale * 1.5` (`app:870` / `variant3d:1585`)
3. **Replace** with raw donor semi-axes (cells, no scale):
   ```gdscript
   var prx := C3PatternGen.CIRCLE3.x  # 22.0 cells, dogenerate.inc:413
   var pry := C3PatternGen.CIRCLE3.y  # 18.0 cells, dogenerate.inc:414
   ```
4. **Replace** the circular test with the donor ellipse centred at `(sx0, sy0+2)`:
   - Loop bounds: `x` in `[sx0-prx, sx0+prx]`, `y` in `[sy0+2-pry, sy0+2+pry]` (clamped to map).
   - Inside test: `((x-sx0)/prx)^2 + ((y-(sy0+2))/pry)^2 <= 1.0` instead of `Vector2(...).length() <= protect`.
   - Centre note: `sx0/sy0` are already tile coords (`v0.x / TILE`, `:875-876`); donor `+2` is **2 cells**, so `sy0 + 2.0` — not `+2.0*TILE` metres, not `+2*s`.
5. **Do NOT** substitute `maxf(CIRCLE3.x, CIRCLE3.y)` circularised (= 22-circle, area `pi*484 ~= 1521`) for the ellipse (`pi*22*18 ~= 1244`): the conforming shape is the **22x18 ellipse**, ~18% smaller than the 22-circle. `max(...)=22` is only the correct *bounding* scalar, not the mask.
6. **Same-contract cleanups required for 1:1 conformance** (same ticket, listed so no one re-litigates; NOT applied here): `pattern_gen.gd:197-198` (`rx=r.x*s` → raw `r.x/r.y`), `:242-243`, `:490` (circularised `maxf*s` → raw C1 ellipse), `:100-101` (`*s` footprint scale → 1:1), `:173` (`*s*1.4` → donor ring/placement rule), `:267` (`*s` on mine `dst` → raw cells). The `game.gd protect` fix alone narrows the flatten ring; the `pattern_gen.gd` `*s` marks are the occupancy-grid half of the same over-broad ban.

Scope guard: prescription is a text statement. No file was edited, no Godot/runner job run, no donor binary executed.

---

## 4. Port-side dependents that break (or change behaviour) if the radius shrinks

| # | Dependent (observed port text) | Behaviour change when `protect` shrinks 33.75/45-circle → 22x18 ellipse | Donor-grounded? |
|---|---|---|---|
| D1 | `near_start` relief-flatten ring: `app/game.gd:869-880` builds the mask; `:936` skips relief stamping where `terrain==3/4 or near_start != 0` | A smaller, elliptical mask **un-protects** a ring of cells the port currently flattens. Relief stamps whose 48-100-tile footprints overlap starts will now stamp height near towns; the pre-collision flatten guarantee ("no start ever steepened", `:865-868`) weakens exactly where the donor never gave it | **No.** Comment claims "the donor's C1/C2/C3 keep-clear contract" (`:868`) but no donor line flattens terrain height in a 33-45-tile circle; donor keep-clear is occupancy-mask only (`misc.script:3384-3521`), applied at stamp time, not a height-flatten pass |
| D2 | Rock-art suppression on the ring boundary: `variant3d/game.gd:1596-1598` sets `_relief_stamp_mask=1` everywhere `near_start=1` ("suppress rock ART on the step at that boundary") | Shrinking the mask moves the suppression boundary inward; a visible rock-art step can appear where the old wide ring hid it. Cosmetic knock-on of D1 | **No.** No donor rock-art suppression line cited at the use site; port adaptation to hide its own flatten terrace |
| D3 | Final 16-tile start clear: `app/game.gd:336-353` — 16.05-tile forest-terrain reset + 16.0-tile unblock/rock wipe (`blocked→false`, `terrain 5→0`) | Independent of `protect` (hard-coded 16.0, no `map_scale`/`protect` reference) so it does **not** break mechanically. But it becomes the *widest* remaining ring — wider than the conforming 22x18 ellipse on the short axis — and will keep clearing forest/rock the donor would have stamped | **No.** No donor line carries 16; donor start clear is the C1/C2/C3 ellipses only. Retain-or-narrow is a port-design decision, not a donor requirement |
| D4 | 7-tile forest paint/wipe rings: `app/game.gd:733-739` (`p2.distance_to(sp) < 7.0*TILE` skip in `_gen_patterns`), `:331-332` + `game.gd:1398-1407` post-grove 7-tile wipe (per `ANOM_stand.md` P7/P9) | Independent of `protect`; unchanged by the fix. 7.0 happens to equal `cCircle1MaskY=7` numerically but is applied as a **circle** (radius 7) at the paint stage, not the donor 5x7 ellipse at the occupancy stage | **Partial.** Magnitude coincides with C1's y semi-axis; shape (circle), stage (paint/wipe vs `gPatternMask` stand test), and duplication (two extra passes) are port adaptations with no donor line |
| D5 | 9-tile bush exclusion (`:619-625`, `< 9.0*TILE`), 12-tile home-grove guard (`:653-656`, `< 12.0*TILE`), 4/5/6-tile mine-clearing radii (`:604`, `:629-636`, `:771-773`, `:807`, `:842`) | Untouched by the `protect` change (separate literals). They further thin the near-start landscape the user calls "empty", compounding the visual complaint | **No.** No donor cite at any of these use sites; port scatter/clear tuning |

**[D] net effect.** Fixing only `game.gd:869-870` to the donor 22x18 ellipse is behaviour-safe for D3-D5 (they don't read `protect`) but **re-exposes D1/D2 by design**: cells the port used to flatten will follow donor stamping rules (occupancy test only). If relief footprints then land on towns, the conforming follow-up is the donor rule (occupancy rejection via `can_stand`, i.e. the `pattern_gen.gd` §3 item-6 cleanups) — not re-widening the flatten circle, which would re-instate the reported defect.

---

## 5. UNVERIFIED register

| ID | Claim | Status | Why not verified here |
|---|---|---|---|
| U-1 | Ticket-180 `rejects={stand:23146,...}` counts and map size/starts/seed | [U] | No `rejects` dict in current `pattern_gen.gd` (per `ANOM_stand.md` U-1); DEBUG-run code differs from landed tree or is unlanded |
| U-2 | Which grid the ticket labels `stand` (shared `occupied` vs `forest_occ` vs `relief_occ` vs game.gd flatten) | [U] | Three occupancy grids + two game.gd rings in current tree; ticket string names none (per `ANOM_stand.md` U-3) |
| U-3 | Exact `:769`/`:947` full-line donor text beyond the landed quotes | [U] here | `X03:940` gives the 7-step order + line numbers; full verbatim lines for `:769`/`:947` are carried via `DEC_DEEP_forest_generation.md:120` arg form, not re-read from donor text by this worker |
| U-4 | Whether zero-placement families recover on re-run with donor-size ellipses | [U] | Needs the DEBUG seed + map; mechanism is [D] from port text, outcome is conditional (per `ANOM_stand.md` U-5) |
| U-5 | `HeightFieldStand` (pattern.lib 582 True / 98 False) as a placement veto | [U] | Proven to exist (X05), no plaintext consumer recovered; must not be conflated with occupancy stand (per `ANOM_stand.md` U-6) |

---

## 6. Open questions (for COORD / owner)

1. Confirm the conforming centre: `(start.x, start.y+2)` in **cells** (donor `pointy+2`, `V08` 1 unit = 1 cell) — i.e. `sy0 + 2.0` tiles in `game.gd`, not `+2.0*TILE`.
2. Is the intended conforming keep-clear C3-only (22x18 at the relief stage) with C1 (5x7) at `CreateStartPoint` and C2 (12x15) mid-`SetupStartingResources`, preserving the donor 3-ellipse staging — or a single C3 ellipse everywhere? Donor stages them (X03:940); the port currently marks C1+C2 in several grids.
3. Where is port `*1.5` (`game.gd:870`) / `*1.4` (`pattern_gen.gd:173`) / `16.0` / `7.0` from? No donor line carries them — delete, cite, or owner-approve as PORT APPROXIMATION?
4. Should `DONOR_UNITS` / `s` be removed from all keep-clear/footprint paths (§2.3 table) in the same change, or is `game.gd:869-870` fixed first with `pattern_gen.gd` `*s` marks tracked as a follow-up?
5. Do zero-placement families (`forests_spruce_medium`, `forests_pinefir_medium`, `hills_light`, `dcr1`, `ravine_big`) recover on the ticket seed with donor-size ellipses? That experiment decides defect vs map-shape.

---

## Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `cCircle1/2/3MaskX/Y = 5/7, 12/15, 22/18`, `cBorderObjDist=1` (`dogenerate.inc:407-416` via X03:705-712) | [O] inherited, re-cited |
| 2 | `_misc_FillPatternMaskElipse(pointx, pointy+2, cCircle1MaskX, cCircle1MaskY)` at `:984` (X03:718 verbatim) | [O] inherited, re-cited |
| 3 | C2 ellipse at `:769`, C3 ellipse at `:947`, 7-step order; C3 placement `:949-977` commented out (X03:940; arg form DEC_DEEP_forest_generation.md:120) | [O] inherited |
| 4 | No `*map_scale / *DONOR_UNITS / *1.5 / *1.4` at any cited donor ellipse line | [D] over 1-3 (absence on evidence read) |
| 5 | Donor distances are 1:1 cells; `DONOR_UNITS=160` / 2-cells-per-unit is PORT-INVENTED (spec 07 §8; V08 §3/C1) | [O]+[D] inherited, re-read |
| 6 | Port `map_scale` + `protect` + `*1.5` formulas (`app/game.gd:869-870`, `variant3d:1584-1585`); `*s` ellipse/footprint/mine scaling (`pattern_gen.gd:71,100-101,173,197-198,242-243,267,490`) | [O] fresh read this pass |
| 7 | 240-wide `protect=33.75` circular vs donor 22x18; 320-wide `45` vs `22` (§2.3 arithmetic) | [D] arithmetic over 5+6 |
| 8 | Minimal fix = raw C3 22x18 ellipse at `(sx0, sy0+2)`, no scale (§3 items 1-6) — STATED ONLY | [D] prescription, unexecuted |
| 9 | Dependents D1-D5 + donor-grounding verdicts (§4) | [O] port reads + [D] verdicts |
| 10 | No code/Godot/git/donor-execution; exactly one file written; parity UNVERIFIED; chain 0/6; RESULT IS NOT GOOD | [O] scope guard |

*End of STAND_scale_law. READ-ONLY; exactly one repository file written; no source/asset/config/test/git/Godot/donor-execution; PARITY UNVERIFIED, no parity claim.*
