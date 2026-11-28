---
id: ANOM-STAND
title: "ANOM stand gate — donor keep-clear law vs port protect ring and 23,146 rejects"
agent: "worker ANOM-STAND (full 1:1 port swarm, 2026-11-26)"
date: 2026-11-26
status: REPORT LANDED
labels: [O, D, U, "NO PARITY CLAIM"]
scope: "READ-ONLY decompilation. Exactly one file written: docs/terrain_swarm_2026-11-26/reports/ANOM_stand.md. No code/Godot/git/donor-execution; no other edits."
parity_guard: "PARITY UNVERIFIED. No donor GPU A/B frame. No parity claim. Chain 0/6. RESULT IS NOT GOOD."
ticket: "DEBUG run 180: pattern.gen build done rejects={ stand: 23146, water: 1292, blocked: 3072, ... }; families forests_spruce_medium 0/11, forests_pinefir_medium 0/11, hills_light 0/5, dcr1 0/5, ravine_big 0/2"
---

# ANOM-STAND — the "stand" keep-clear gate

## Executive summary

1. **[D]** Donor "stand" is occupancy-only: `_misc_CheckStandPattern` (`misc.script:3384-3521`, `Ext :3516-3521`) rejects out-of-map or already-occupied `gPatternMask` cells (4-step fast sample then full box). There is no dedicated water/rock branch inside the checker; water/shore enters the mask earlier (`height < -0.1`, `dogenerate.inc:1557-1564`).
2. **[D]** Donor keep-clear law is three ellipses centred at `(start.x, start.y+2)`: **5x7** (`dogenerate.inc:407-408`, applied `:984`), **12x15** (`:410-411`, applied `:769`), **22x18** (`:413-414`, applied `:947`). Largest donor ban is the 22x18 ellipse.
3. **[O]** Port constants match verbatim (`app/scripts/pattern_gen.gd:10-13` cites `dogenerate.inc:407-414`), but the port adds a much larger circular gate: `protect = max(CIRCLE2)*map_scale*1.5` (`app/scripts/game.gd:869-880`), plus 16-tile and 7-tile post passes. At 320-wide (`map_scale=2`) that protect radius is **45 tiles** vs donor max semi-axis **22** — flag as over-broad **[D]**, scale arithmetic conditional on map size **[U]**.
4. **[D]** 23,146 rejects is consistent in magnitude with the port's 45-tile circular gate, not with the donor 22x18 ellipse law. Zero placements in stamped families is not donor-correct.
5. **[U]** Ticket-180 counts and map size were not re-verified in-repo (no `rejects` dict exists in current `pattern_gen.gd`); all verdicts on the counts are conditional.

---

## 1. Byte-proven donor law [D] (from read-only donor text via landed reports)

| # | Donor path:line | Observation | Label |
|---|---|---|---|
| E1 | `dogenerate.inc:407-408` via X03:705-706 | `cCircle1MaskX = 5; cCircle1MaskY = 7;` | [O] quoted text |
| E2 | `dogenerate.inc:410-411` via X03:707-708 | `cCircle2MaskX = 12; cCircle2MaskY = 15;` | [O] quoted text |
| E3 | `dogenerate.inc:413-414` via X03:709-710 | `cCircle3MaskX = 22; cCircle3MaskY = 18;` | [O] quoted text |
| E4 | `dogenerate.inc:984` via X03:718 | `_misc_FillPatternMaskElipse(pointx, pointy+2, cCircle1MaskX, cCircle1MaskY);` in `CreateStartPoint` | [O] quoted text |
| E5 | `dogenerate.inc:769` + `:947` via X03:940 | C2 ellipse after stoneforest; C3 ellipse at end of `SetupStartingResources`; 7-step order stoneforest / C2 / stones / 2 forest / stones at `mindst+4` / 1 forest / C3; C3 placement `:949-977` commented out | [O] quoted text |
| E6 | `misc.script:3384-3521` via X03:1125-1138 | `_misc_CheckStandPattern(...)` reads pattern mask W/H + offsets; fast path samples every 4th cell when `angle=0` (`:3441`); rejects `out-of-map or gPatternMask set` (`:3466`, `:3504`); `doStand=True` branch writes mask (`:3497-3500`) | [O] quoted text |
| E7 | `misc.script:3516-3521` via X03:1139-1142 | `Ext` = test with `doStand=False`, then atomic stand with `doStand=True` | [O] quoted text |
| E8 | `dogenerate.inc:1557-1564` via spec `07_RESOURCES.md` §3 | water/shore cells enter mask from `height < -0.1` before stamping | [O] inherited, not re-read here |
| E9 | `pattern.lib` census via X05 §V5 | `HeightFieldStand` True 582/False 98 — a **heightfield blend flag**, not the placement gate | [O] inherited — must not be confused with ticket "stand" |

**[D] consequence.** Donor "stand" reject = footprint cell outside map or already in `gPatternMask` (which includes the three start ellipses + shore + prior stamps). It is not a semantic water/rock test and not the `HeightFieldStand` flag.

---

## 2. What the port does [O] (repo text observed, no execution)

| # | Port path:line | Observation | Label |
|---|---|---|---|
| P1 | `app/scripts/pattern_gen.gd:10-13` | `CIRCLE1=(5,7) CIRCLE2=(12,15) CIRCLE3=(22,18)` citing `dogenerate.inc:407-414` — constants match E1-E3 | [O] |
| P2 | `app/scripts/pattern_gen.gd:192-207` | `mark_ellipse` helper; `CIRCLE1` ellipse marked for every start on shared grid before tiles | [O] |
| P3 | `app/scripts/pattern_gen.gd:407-415` | `SetupStartingResources`: 2 stones + 1 pine forest per start in `CIRCLE3` ring; then `CIRCLE2` ellipse marked | [O] |
| P4 | `app/scripts/pattern_gen.gd:451-454` | forest grid separately marked with `CIRCLE1` + `CIRCLE2` ellipses | [O] |
| P5 | `app/scripts/pattern_gen.gd:489-494` | relief keep-clear uses **circular** `max(CIRCLE1)*s` radius, not the donor ellipse | [O] port adaptation |
| P6 | `app/scripts/game.gd:869-880` | `protect := maxf(CIRCLE2.x, CIRCLE2.y) * map_scale * 1.5`, circular `near_start` flatten ring before relief collision | [O] |
| P7 | `app/scripts/game.gd:688`, `:705-739` | 7-tile start keep-clear for forest paint (`dist < 7*TILE` skip) | [O] |
| P8 | `app/scripts/game.gd:331-354` | final 16-tile start clear (terrain reset + unblock + rock wipe) | [O] |
| P9 | `app/scripts/game.gd:1398-1407` | post-grove 7-tile forest wipe | [O] |
| P10 | `app/scripts/pattern_gen.gd:435-461` | rest-stage forest recipes **request** `forests_spruce_medium` and `forests_pinefir_medium` (4.9 base each) — families are not donor-zero | [O] |

**[D] radius arithmetic (conditional).** `max(CIRCLE2)=15`, `map_scale=MAP_W/160`. If the DEBUG run was 320-wide, `protect=15*2*1.5=45` tiles circular per start. Donor max keep-clear is the 22x18 ellipse (semi-axes 22/18). Linear ratio ~2-2.5x; area ratio per start ~5-6x (pi*45^2 ~= 6362 vs pi*22*18 ~= 1244). Map-size premise is **[U]** (see §5).

**[D] scale-law caveat (inherited).** Spec `07_RESOURCES.md` §8 states donor generator distances are map cells 1:1 and `DONOR_UNITS=160` / "1 unit = 2 cells" is PORT-INVENTED, doubling radii at 320. If that correction holds, the port's `*s` scaling already doubles the donor ellipses before the extra `*1.5`. Not re-verified here; carried as **[D] inherited / [U] cause**.

---

## 3. Are 23,146 rejects consistent with the donor law?

**No — not with the donor law; yes in magnitude with the port's 45-tile gate. [D] conditional.**

- Donor ban per start is at most the 22x18 ellipse ~= ~1.2k cells. Even with several starts plus shore/prior-stamp occupancy, ~23k placement rejections across ~30k candidate cells cannot be produced by the donor ellipses alone.
- Port `protect=45` circular ban is ~6.4k cells per start; 3-4 starts ~= ~19-25k banned cells — the same order as 23,146. This is an order-of-magnitude consistency check only, not a replay: attempt counts, family loop bounds, and map size are **[U]**.
- The ticket's `water: 1292, blocked: 3072` companions show other gates firing normally, which isolates the excess to the occupancy/"stand" path — i.e. the keep-clear + prior-stamp mask, exactly where P5/P6 widen the donor rule. **[D] inference from ticket numbers, conditional on ticket accuracy.**

---

## 4. Are zero-placement families donor-correct?

**No. [D].**

- `forests_spruce_medium` and `forests_pinefir_medium` are donor Stage-9 families at `frs_mid/6` (`dogenerate.inc:1855-1856` via X03:925-926). The donor stamps them whenever `needed=floor(W*H*freq)` (with the `freq>0 -> at least round()` rule, `misc.script:3695-3700`) and attempts (`trycount=floor(256*mapsizeoptimise)`, `:3704`) find a free mask cell. A zero result across 11 requests each means every attempt hit occupied/water/out-of-map — an occupancy-rejection outcome, not a donor zero-frequency.
- Same for `hills_light` (`hil/2`, `:1764-1765`), `dcr1`, `ravine_big` (`plt/1.5`, `:1761`): all are live donor calls with nonzero frequency. `ravine_medium` is the one commented-out family (`:1760`) — `ravine_big` is not it.
- Port P10 requests these families with small counts and 200 tries each on the shared/forest grids that already carry CIRCLE1+CIRCLE2 ellipses plus all prior stamps; on a small map (`map_w<=160` collapses counts to 1 each, `:458-460`) a widened keep-clear can plausibly zero them. Mechanism is **[D]** from port text; that it happened on ticket-180's map is **[U]**.

---

## 5. UNVERIFIED register

| ID | Claim | Status | Why not verified |
|---|---|---|---|
| U-1 | Ticket-180 `rejects` values and ~30k candidate denominator | [U] | No `rejects` dict found in current `pattern_gen.gd` (grep: only `can_stand`/`stand` lambdas); DEBUG-run code differs from landed tree or is unlanded |
| U-2 | DEBUG map size / start count / biome / relief preset | [U] | Not in ticket excerpt; radius arithmetic in §2 assumes 320-wide illustratively |
| U-3 | Which exact gate the ticket labels `stand` (shared `occupied` vs `forest_occ` vs `relief_occ` vs game.gd flatten) | [U] | Current tree has three occupancy grids + two game.gd post rings; ticket string `stand` does not name one |
| U-4 | Donor cell-vs-unit scale (spec §8 1:1 claim) | [U] here | Inherited from spec/V08; donor coordinates not re-measured by this worker |
| U-5 | Whether any zero family is explained by water/edge instead of keep-clear | [U] | No per-family attempt log in evidence; would need the DEBUG run's seed + map |
| U-6 | `HeightFieldStand=False` (98 records) as a placement veto | [U] | X05 proves the flag exists; no plaintext consumer recovered; must not be conflated with occupancy stand |

---

## 6. Open questions (for COORD / owner)

1. Which grid does ticket-180's `stand` counter increment — shared `occupied`, `forest_occ`, or `relief_occ`? Name it and cite the DEBUG-run line.
2. What were ticket-180's MAP_W/start count/seed? Without them no reject total can be judged.
3. Is `game.gd:870 protect = max(CIRCLE2)*map_scale*1.5` intended as the donor C1/C2/C3 contract, and where is the `*1.5` from? No donor line carries it.
4. Should relief keep-clear return to the donor 22x18-style ellipse (or C1-only per `pattern_gen.gd:485` comment) instead of the 45-tile circle?
5. Do zero-placement families recover if the DEBUG seed is re-run with donor-size ellipses only? That experiment decides defect vs map-shape.

---

*No donor binary executed, copied, or committed. No repo source, asset, config, test, git, or Godot job touched. No donor visual parity claimed.*
