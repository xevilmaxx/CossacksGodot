# UNIT_RALLY_ARRIVAL — barracks rally outflow stall + "peasant keeps walking after arrival"

Role: **T5-UNIT-DIAG**, read-only diagnosis. **No code changed, no Godot run performed.** Everything below is from source reading plus recorded engine output already committed in the repo (`app/selftest.json`, `app/tests/results/summary.json`).

Claims are tagged **observed** (literal source/config text), **derived** (arithmetic from observed constants), or **inferred** (reasoning about runtime ordering).

> **Snapshot warning.** `app/scripts/game.gd` and `app/scripts/world.gd` were being concurrently edited (T5-GEN / T5-RENDER) while this was written; `nav.gd` was not. Line numbers below were re-verified at ~2026-11-21 18:40 local. Re-check the exact lines against the current file before patching. Function names are stable and are a better anchor than line numbers.

---

## 1. Sources read (file:line)

| File | Lines | What it establishes |
|---|---|---|
| `app/scripts/game.gd` | 1-40 | `Nav` preload, runtime `nav`, `NAV_PER_TICK := 2`, `TILE := 2.0`, `TICK_MAX := 0.25` |
| `app/scripts/game.gd` | 100-133 | `_blocked_for()` — water, `blocked[]`, **building `block_rect`s**, gates. **No units.** |
| `app/scripts/game.gd` | 355-358 | `set_rally()` — blind assignment `b["rally"] = pos`, no validation |
| `app/scripts/game.gd` | 370-373, 385-398 | `is_blocked()` (whole 2×2 m tile), `set_blocked_circle()` stamps tile if its **centre** is within r; bumps `nav_version` |
| `app/scripts/game.gd` | 401-420, 1221-1250 | `bld_rect_cells`, `bld_block_r`, `bld_block_rect` — building ink boxes are *extra* A* blockers, not terrain |
| `app/scripts/game.gd` | 1701-1779 | `spawn()` — creates the entity, stamps building footprints, **does not stamp units into `blocked`**, no `can_place` check |
| `app/scripts/game.gd` | 1781-1804 | `_on_building_finished()` — default rally `pos + (0, block_r + 2.0)` for any `trains` building |
| `app/scripts/game.gd` | 2339-2347 | `cmd_move()` — `order={"type":"move","pos":pos}`, `moving = true` |
| `app/scripts/game.gd` | 3182-3220 | `train_unit()` — queue gates (`BUILD_QUEUE_LIMIT`, farm cap, cost), **no exit-tile check** |
| `app/scripts/game.gd` | 3236-3295 | `tick()` — resets nav budget to 2, ticks units then buildings, then `_separate_units()` |
| `app/scripts/game.gd` | 3297-3373 | `_separate_units()` — pairwise separation `want = r1+r2+PERSONAL_SPACE`, building push to `r+block_r+0.15`; refuses blocked tiles |
| `app/scripts/game.gd` | 3520-3527 | `_nav_wanted()` — only fixed-destination orders use nav |
| `app/scripts/game.gd` | 3531-3548 | `_nav_gate_cells()` — A* `extra` blockers = **buildings + gates only** |
| `app/scripts/game.gd` | 3550-3561 | `_nav_line_clear()` — straight-line walkability shortcut |
| `app/scripts/game.gd` | 3563-3576 | `_nav_smooth()` — string pulling |
| `app/scripts/game.gd` | 3578-3613 | `_nav_repath()` — straight-line shortcut at 3590-3598; A* at 3599-3609; target appended only if clear at 3606-3608 |
| `app/scripts/game.gd` | 3615-3684 | `_step_move()` — arrival check 3647, repath triggers 3628-3637, waypoint advance 3638-3644, 13-probe steering 3661-3680, "boxed in" 3681-3684 |
| `app/scripts/game.gd` | 3701-3734 | `_tick_unit()` `"move"` branch — **unconditional `e.moving = true`** at 3728, order cleared only if `_step_move` left `moving=false` (3733-3734) |
| `app/scripts/game.gd` | 3735-3750 | `"attackmove"` branch — same pattern |
| `app/scripts/game.gd` | 3782-3791, 3925-3929, 4325-4339, 4364-4388 | The four callers that **do** consume `stuck_t` (attack, build, gather, deliver) |
| `app/scripts/game.gd` | 4416-4441 | `_tick_building()` production completion — **no `can_place`/free-tile check**; spawn at `pos + dir*(block_r+0.5)`; `cmd_move(u, exit + dir*1.5)` |
| `app/scripts/nav.gd` | 1-243 (full) | Custom binary-heap A* (**not** `AStarGrid2D`), nearest-open snapping, `MAX_EXPAND`, `[ ]` failure paths |
| `app/scripts/world.gd` | 394-420 | `_anim_action()` — walk clip chosen **solely** from `e.moving` (401, 416-420) |
| `app/scripts/world.gd` | 2529, 2544 | bob amplitude and `_draw_anim` call also keyed on `e.moving` |
| `app/scripts/world.gd` | 2852-2865 | rally flag drawing (read-only mirror of `e.rally`) |
| `app/scripts/input_controller.gd` | 369-397 | R-mode / right-click rally → `game.set_rally(b, pw)` with no validation |
| `app/scripts/hud.gd` | 64, 683-686 | `want_rally` button → `rally_mode` |
| `app/scripts/data.gd` | 50, 62, 65 | `BUILD_QUEUE_LIMIT := 10`, `PERSONAL_SPACE := 0.35`, `DELIVERY_RADIUS_M := 6.0` |
| `app/scripts/data.gd` | 490-524 | peasant/pikeman/serdiuk `radius := 0.35`, speeds 1.5 / 1.2 / 1.2 m/s |
| `app/scripts/data.gd` | 971 | barracks `bar` gameplay `radius := 2.5`, `build_time := 9.375 s` |
| `app/scripts/selftest.gd` | 37-47, 257-275, 462-486 | move / shell-rally / nav-detour test bodies |
| `app/selftest.json` | 14-16, 34-37, 49-51, 99-101, 153-156 | recorded coverage |
| `app/tests/building_block_test.gd` | 77-86 | single walker around a building |
| `app/tests/t_mass_army.gd` | 100-108 | mass spawn distinct ids |
| `app/tests/t_multi_ai.gd` | 197-212 | `no_ai_stuck` (AI activity, not unit arrival) |
| `app/tests/results/summary.json` | 49, 289-290, 353, 595-596 | recorded details of the above |

---

## 2. The click → spawn → rally → move → arrival pipeline

1. **Rally set (optional).** HUD button (`hud.gd:683-686`) sets `want_rally`; `input_controller.gd:369-375` consumes the next right-click into `rally_mode` and calls `game.set_rally(e, pw)`. A production building selected alone also accepts a plain right-click (`input_controller.gd:377-398`). `game.gd:355-358` stores the raw world point — **no `is_blocked` / `can_place` validation**. If the owner never sets one, `game.gd:1800-1801` installs the default `pos + (0, block_r + 2.0)` when the building finishes.
   - `world.gd:2852-2865` draws the flag from `e.rally`; it is a pure read.
2. **Queue.** `train_unit()` (`game.gd:3182-3220`) checks nation/roster, academy gate, `queue.size() >= BUILD_QUEUE_LIMIT (10)`, farm cap and cost, then appends `{"sid": rsid, "t": build_time}`. **There is no exit/rally-tile occupancy check here.**
3. **Production tick.** `_tick_building()` (`game.gd:4416-4441`) decrements `queue[0].t`; when it reaches 0 it pops the job and:
   - `brexit = block_r`; `exit = rally`;
   - `sp = e.pos + normalize(exit - e.pos) * (brexit + 0.5)` — every unit gets the **identical** spawn point (`game.gd:4436`);
   - `spawn(job.sid, e.player, sp)` (`game.gd:4439`) — `spawn()` does **not** call `can_place` for units;
   - `cmd_move(u, exit + normalize(exit - e.pos) * 1.5)` (`game.gd:4440`) — target is **1.5 m past** the rally point, i.e. `block_r + 3.5` from the building, **3.0 m from `sp`**. Every unit is given the **identical** target.
   - `cmd_move()` (`game.gd:2339-2347`) sets `order={"type":"move","pos":target}`, `move_target`, `moving=true`.
4. **Movement.** `tick()` (`game.gd:3236-3295`) gives `_nav_tick_budget = 2` repaths per tick, ticks all units (`_tick_unit` → `"move"` branch at 3727-3734 → `_step_move`), then ticks buildings (which spawn), then runs `_separate_units()` (`game.gd:3291`, 3301-3373).
   - `_step_move()` (`game.gd:3615-3684`) chooses `aim`: for nav orders it follows `nav_path`, else `aim = target` (3621).
   - `_nav_repath()` (`game.gd:3578-3613`) **first tries a straight line** (`_nav_line_clear` at 3592-3598) and only calls `nav.find_path` if that line is blocked. So the owner's "they go in a straight line" is *by design* for an open barracks→rally path, not evidence that A* is missing.
   - The 13-direction probe steering at 3661-3680 resolves the final approach; a successful step resets `stuck_t = 0` (3679).
   - **Arrival is declared only at `game.gd:3647-3652`** when `d_goal = e.pos.distance_to(target) <= arrive` (default **0.15 m**): `moving=false`, `stuck_t=0`, `nav_path=[]`, `nav_i=0`, `return true`.
   - A second apparent success at `game.gd:3680` returns `d_goal - step < arrive` **without clearing `moving`**.
   - "Boxed in" at 3682-3684 sets `moving=false` and increments `stuck_t`, with the comment *"let the caller give up"*.
5. **Order cleanup.** `"move"` branch (`game.gd:3727-3734`) sets `e.moving = true` at the top of **every** tick, calls `_step_move`, then clears the order only if `_step_move` left `moving=false`. `"attackmove"` does the same (3736-3750).
6. **Animation.** `world.gd:_anim_action()` (`world.gd:394-420`) checks `e.moving` at 401 and 416; `true` → `"walk"` / `"walk<res>"`. No distance or order check exists on the render side. Therefore **any sim-side failure to clear `moving` is directly visible as an endlessly marching unit.**

---

## 3. Pathfinding (`nav.gd`) — what it actually is and what it does

**Correction to the brief:** `nav.gd` does **not** use `AStarGrid2D`. It is a hand-rolled, reusable binary-heap A* over a flat `PackedByteArray`, with scratch buffers kept between queries (`nav.gd:1-14, 29-37, 111-151`). Call sites are `game.gd:3602` only (plus `configure` at 300, 3599, 4680).

Key behaviour, all **observed**:

| Aspect | Location | Behaviour |
|---|---|---|
| Neighbour set | `nav.gd:19-22, 205-218` | 8-connected; diagonals require both orthogonal cells free (no corner cutting) |
| Goal/start snapping | `nav.gd:82-102, 164-169` | `_nearest_open()` snaps a blocked start/goal to the nearest free cell within `SEARCH_RADIUS = 24` cells (48 m); if none, returns `Vector2i(-1,-1)` → `find_path` returns `[]` |
| Failure paths | `nav.gd:158-159, 168-169, 240-241, 243` | `[]` when grid not configured, when start/goal cannot be snapped, when path has ≤1 cell (start and goal in the **same 2 m cell**) |
| Search cap | `nav.gd:15, 187` | `MAX_EXPAND = 20000`; on exhaustion it returns the **closest reached cell** (`best_i`, 231-239), not `[]` |
| Other citizens | — | **Never** entered into `blocked[]` (`spawn()` at 1701-1779 stamps nothing for units) and **never** passed as `extra` (`_nav_gate_cells` at 3531-3548 adds only building rects and gates). A* is *blind* to friendly/enemy bodies. |
| Path finish | `game.gd:3604-3609` | Cells → cell centres; the raw `target` is appended **only** if `not _blocked_for(e, target)` and `_nav_line_clear(last_waypoint, target)`. If target is blocked, the path ends at the snapped cell centre and `d_goal` can never reach 0.15 m. |
| Repath budget / cooldown | `game.gd:13-14, 3634-3637, 3597/3613` | 2 repaths per tick globally, `nav_cd = 0.6 s` per unit; `nav_version` bumped on grid changes (301, 398, 1660, 4681) |
| Give-up on no path | — | **None.** `find_path() == []` → `nav_path = []`; `_step_move` then aims at raw `target` (3621) and steers with the 13 probes forever. No retry counter, no fallback for `move` / `attackmove`. `stuck_t` is written at 3683 but only *read* by attack/build/gather/deliver (3786, 3927, 4330, 4383). |

**Verdict on “we need A* for spawned units too”:** **No.** Spawned units already go through the nav decision path (`_nav_wanted` 3523-3527 → `_step_move` 3619-3644 → `_nav_repath`). A* is deliberately skipped when the line is clear (3590-3598), which is the normal open-terrain barracks→rally case. Adding A* to the spawn line would not change either reported bug, because neither blocker is in the nav grid: **other citizens** are excluded from both `blocked[]` and `extra`, and a **blocked rally tile** is snapped around rather than appended as a reachable target.

---

## 4. Evidence table

| # | Claim | file:line | Tag | Verdict |
|---|---|---|---|---|
| E1 | Training completion has no exit-tile / `can_place` gate; the queue always pops and a unit is always spawned | `game.gd:4427-4440`, `3182-3220` | observed | **Confirmed.** A literal spawn *stall* cannot originate in `_tick_building`. |
| E2 | Every spawned unit uses the identical `sp` and the identical move target, 3.0 m apart | `game.gd:4436, 4439-4440`; derived from 1800-1801 | observed + derived | **Confirmed.** Computed: `(block_r+3.5) − (block_r+0.5) = 3.0 m`. |
| E3 | Units repel each other with `want = 0.35+0.35+0.35 = 1.05 m`, far above `arrive = 0.15 m` | `game.gd:3338-3351`, `3615`; `data.gd:62, 496, 505, 524` | derived | **Confirmed.** At most one unit can satisfy `d_goal ≤ 0.15 m` at a shared point; the rest are pushed to ≥1.05 m. |
| E4 | `sp = block_r + 0.5` can lie inside a **blocked tile**, because `set_blocked_circle` blocks a whole 2×2 m tile when its centre is within `block_r` (band reaches `block_r + 1.41 m`) | `game.gd:385-398, 4436`; `TILE=2.0` at 16 | derived | **Confirmed** (worst case). Spawn can begin on `is_blocked()==true` ground. |
| E5 | `_separate_units` will not relocate a unit into a blocked tile; building push also refuses blocked targets | `game.gd:3348-3351, 3362-3373` | observed | **Confirmed.** A unit spawned inside the blocked band can stay there. |
| E6 | Rally can be set to an arbitrary/blocked world point; no validation | `game.gd:355-358`; `input_controller.gd:369-397` | observed | **Confirmed.** Player can right-click a tree/building as rally. |
| E7 | A blocked target is never appended to the A* path; path ends at snapped cell centre while `d_goal` still measures the raw target | `game.gd:3606-3608`, `3646`; `nav.gd:82-102, 166-169` | observed + derived | **Confirmed.** `d_goal` can never fall below 0.15 m → permanent walk. |
| E8 | Other citizens are not obstacles for A* or for the straight-line check | `game.gd:1701-1779` (no unit stamp), `3531-3548`, `100-133`, `3550-3561` | observed | **Confirmed.** “A* not reaching because of other citizens” is causally right (crowd blocks arrival) but not because of the nav grid. |
| E9 | `"move"`/`"attackmove"` re-assert `moving=true` every tick; `stuck_t` is never read by them | `game.gd:3727-3750` vs `3786, 3927, 4330, 4383` | observed | **Confirmed.** The `3681` comment “let the caller give up” is false for the two most common order types. |
| E10 | Any successful probe resets `stuck_t`, so a unit sliding sideways around a crowd never accumulates a stuck count | `game.gd:3661-3679` | observed + inferred | **Confirmed.** Probe fan spans ±105°, so at least one lateral direction is almost always free. |
| E11 | `_step_move` can report success at 3680 without clearing `moving` | `game.gd:3680` vs `3647-3652` | observed | **Confirmed.** Normally self-heals next tick; adds a one-tick window at threshold boundaries. |
| E12 | Walk animation is selected purely from `e.moving` | `world.gd:401, 416-420, 2529` | observed | **Confirmed.** No render-side arrival logic exists, so the fix belongs in `game.gd`. |
| E13 | `BUILD_QUEUE_LIMIT = 10` | `data.gd:50`, `game.gd:3210` | observed | **Confirmed.** Repro must use ≤10 queued per barracks (or refill in batches). |
| E14 | `nav_detour` selftest considers `dist < 1.2 m` a pass and never checks `moving` or `order` | `selftest.gd:474-486` | observed | **Confirmed.** A permanently walking unit passes this test. |
| E15 | `train` selftest spawns exactly one peasant; `shell` selftest only checks `rally != INF` | `selftest.json:34-37, 99-101`; `selftest.gd:269-270` | observed | **Confirmed.** No outflow coverage. |

---

## 5. Root-cause ranking — Bug 1: “full line stops units coming out of the barracks”

| Rank | Cause | Tag | Why it explains the report |
|---|---|---|---|
| **1** | **All spawns share one point and one target; separation (1.05 m) > arrival radius (0.15 m).** Units pile into a static clump at the rally point, nobody ever clears `moving`, the clump stops extending, and new units spawn into it and are pushed sideways/back. | derived + inferred | Directly matches “go in a straight line … once line is full they stop coming out”. The *visible* outflow stalls even though the queue keeps popping (E1-E3). |
| **2** | **Spawn point inside the blocked-tile band** (`block_r+0.5` vs band up to `block_r+1.41`), and separation refuses to relocate into blocked tiles → some new units are born inside `is_blocked()==true` ground, get boxed in by `_step_move` (3682), have their order cleared at 3733, and sit at the door. A growing ring of such units looks like a “full line”. | derived + inferred | Explains cases where units appear at the barracks and never move at all, rather than marching in place. |
| **3** | **Rally point set on a blocked cell** (tree/building/rock) via unvalidated `set_rally`; target never appended to path → permanent walk near the exit. | observed + derived | Less common, but produces the same visual with a specific player action. |
| **4** | **Per-tick nav budget `NAV_PER_TICK = 2`** with `_nav_gate_cells` O(all buildings) per repath can delay route updates for large groups. | observed + inferred | Secondary latency only; does not stop the queue. Explicitly *not* a root cause. |

**A* is not the missing piece** (E1, E8). The defect is spawn/target geometry plus the absence of a “close enough / give up” rule.

---

## 6. Root-cause ranking — Bug 2: “peasant near destination keeps walk animation”

| Rank | Cause | Tag | Why it explains the report |
|---|---|---|---|
| **1** | **No give-up path for `move`/`attackmove`.** `_step_move` only clears `moving` on `d_goal ≤ 0.15 m` (3647) or when all 13 probes are blocked (3682). A crowd (1.05 m spacing) or a blocked target keeps `d_goal` above 0.15 m while lateral probes keep succeeding, so `stuck_t` is reset every tick (3679) and is never read by the caller (3727-3750). | observed + derived | Exactly “after some tries, stop where it is supposing it arrived” — that rule does not exist today. |
| **2** | **Blocked target never appended to path** (3606-3608) while `d_goal` still measures the blocked raw point. | observed + derived | Produces a deterministic infinite walk whenever rally/destination lands on a building, tree or water tile — matching “A* not reaching totally destination”. |
| **3** | **Return-at-3680 without clearing `moving`**, plus unconditional `e.moving = true` at 3728 on every subsequent tick. | observed | Adds a one-tick (and, at threshold boundaries, repeated) window where the unit is effectively arrived but still flagged moving. |
| **4** | **Gather work-slot oscillation** — `on_node >= max_workers` redirects to `nearest_res(..., 45.0, true)` with no `avoid` argument (`game.gd:4311-4324`), and `_work_slot` can return the blocked node centre (`3689-3699`); repeated retargeting can keep `moving=true` despite “~arrived”. | observed + inferred | Matches the *peasant-specific* wording; secondary to rank 1 but worth covering in the fix. |

`world.gd` is **not** at fault: it faithfully mirrors `e.moving` (E12).

---

## 7. Concrete fix proposals (routed by owner)

### F1 — Stagger the rally exit slot  → **`app/scripts/game.gd`, owner T5-GEN** (`_tick_building`, around 4429-4441)
Replace the single shared target with a per-unit slot derived from the units already heading to that rally (golden-angle fan like `_work_slot`, `game.gd:3689-3699`, or a queue-index offset along the rally line), radius growing with occupancy. Keep `sp` on a ring search around `block_r + 0.5` that passes `not is_blocked(sp)`. If no free slot exists, hold the job (small `wait_t`) but cap the hold (e.g. 2 s) and spawn anyway, so the queue can never hard-stall.
**Acceptance:** with `BUILD_QUEUE_LIMIT = 10` filled at one barracks, all 10 spawn within `10 × build_time + 2 s` sim time; pairwise gap ≥ 1.0 m; 0 units still have `moving=true` within 1 s of being assigned their slot.

### F2 — Robust “give up and declare arrived”  → **`app/scripts/game.gd`, owner T5-GEN** (`_step_move`, around 3646-3684)
Add an effective arrival band and a no-progress timer:
- `arrive_eff = max(arrive, e.def.radius * 2 + Data.PERSONAL_SPACE + 0.15)` for crowd-sensitive orders, **or**
- track `last_d_goal` / `no_progress_t`; if `d_goal` fails to decrease by ≥0.1 m over **2.0 s** while `d_goal ≤ 2.0 m`, declare arrival: `e.moving = false; nav_path = []; nav_i = 0; return true`.
Also clear `moving` on the success return at 3680 (move that branch to share the 3647-3652 cleanup). This is the explicit “stop where it is, suppose it arrived” path the owner asked for, and it automatically fixes crowded rally points, blocked targets and the one-tick lag.
**Acceptance:** no unit has `moving=true` while within 0.5 m of its assigned target for >1 s; 0 stuck units (`moving=true`, `d_goal` unchanged >2 s) in a 60 s CLI run; existing `selftest` `move` and `nav_detour` still pass.

### F3 — Make the caller respect the give-up  → **`app/scripts/game.gd`, owner T5-GEN** (`_tick_unit`, 3727-3750)
Stop re-asserting `e.moving = true` before `_step_move`; let `_step_move` own the flag. Consume `e.stuck_t > 2.0` in the `"move"` and `"attackmove"` branches: declare arrival, reset the counter, clear the order. This makes the existing comment at 3681 true.
**Acceptance:** same as F2, plus `e.order.type == "none"` for every declared-arrival unit.

### F4 — Validate/snap rally points  → **`app/scripts/game.gd`, owner T5-GEN** (`set_rally`, 355-358)
If `is_blocked(pos)` or `_blocked_for` on a representative unit, snap `pos` to the nearest free tile centre before storing (reuse `nav._nearest_open` via a public wrapper, or a small local ring scan). Then the append condition at 3606-3608 succeeds and F2 is rarely needed.
**Acceptance:** setting rally on a tree/building tile results in a reachable rally flag; a unit ordered there declares arrival within 3 s of reaching the snapped cell.

### F5 — Reachability-aware path result  → **`app/scripts/nav.gd`, owner: free** (`find_path`, 156-243)
Optionally expose the **effective goal point** (centre of `g` after `_nearest_open`) alongside the cell array, so callers can use it as the arrival target instead of the raw unreachable point. Do **not** add citizens to the nav grid: they move constantly and would thrash repaths; F1/F2 handle them correctly at the movement layer.
**Acceptance:** `find_path` to a blocked goal returns a path whose final point is walkable and within `SEARCH_RADIUS × tile` of the requested goal; no behaviour change for clear goals.

### F6 — Defensive render fallback (optional, low priority)  → **`app/scripts/world.gd`, owner T5-RENDER** (`_anim_action`, 394-420)
Not required — the sim fix is authoritative. If desired, force `"idle"` when `e.order.type == "none"` regardless of `moving`, as belt-and-braces against any future stale flag. Do not attempt distance checks in the renderer.
**Acceptance:** visual smoke test after F2/F3 shows walk → idle transition at arrival.

---

## 8. Existing coverage and gaps

| Area | Existing | Coverage gap |
|---|---|---|
| Basic move | `selftest.json:14-16` — “walked 6.0 m forward”; `selftest.gd:37-47` | Checks **displacement only** (`moved >= 3.0` after 8 s); never checks `moving`, `order`, or arrival |
| Nav detour | `selftest.json:153-156`; `selftest.gd:462-486` — wall avoidance | Success is `dist < 1.2 m` (E14) — **a permanently marching unit passes**. No `moving`/`order` assertion; no no-path/blocked-target case |
| Training | `selftest.json:34-37` — one peasant in 12.5 s | Single unit; no queue-of-N outflow, no rally flag, no exit-tile geometry |
| Rally | `selftest.json:99-101`; `selftest.gd:257-275`; `uitest.gd:222-230` | Only asserts `rally != INF` (E15); never spawns a unit to it, never sets rally on a blocked tile |
| Separation | `selftest.json:49-51` — min gap 1.33 m | Gap is asserted, but **not coupled to arrival**: nobody checks that a separated unit declares arrival |
| Mass army | `t_mass_army.gd:100-108` — 552 distinct ids | No movement or arrival assertions |
| AI stuck | `t_multi_ai.gd:197-212` | Tracks AI activity, not `moving`/`order` staleness |
| Building block | `building_block_test.gd:77-86` | One walker, open path; no crowd, no blocked target |
| Stuck counters | — | **No test references `_step_move`, `stuck_t`, `nav_path`, `nav_cd`, or `find_path` failure** anywhere under `app/tests/` or `selftest.gd` |
| Animation state | `t_anim_metrics.gd` (clip cadence), `t_audio_events.gd` (walk prefixes) | Validates clip *assets*, not the `moving → walk/idle` **state transition** |

**Recommended new tests** (new files under `app/tests/`, route to whoever owns test harness; register in `app/tests/manifest.json`):
1. `t_rally_outflow.gd` — fill a barracks queue to 10, run 60 s CLI, assert all 10 spawned, all `order=="none"`, all `moving==false`, min gap ≥1.0 m.
2. `t_arrival_giveup.gd` — park 20 units on one point, assert `moving` clears within 2 s for every unit and no stuck units after 60 s.
3. `t_blocked_rally.gd` — set rally onto a blocked tile, assert arrival at snapped cell with `moving==false` and `order=="none"`.

---

## 9. Open questions / unknowns

- **Unknown:** exact visual wording “line is full” — no screenshot or save attached. Rank 1 and rank 2 of §5 both fit; a repro from `app/shots/` or a short CLI trace (spawn count vs `moving` count) would separate them. No Godot run was performed here per the brief.
- **Unknown:** `bld_block_r()` for `bar` under each nation sprite may be considerably larger than the 2.5 m gameplay radius (`game.gd:1221-1226`, `data.gd:971`), which changes how often E4 fires. Needs the recorded ink-box data, not read here.
- **Unknown:** whether `world.gd` is mid-edit by T5-RENDER; the rally-flag lines moved from ~2800 to ~2852 during this audit. Re-verify before touching that file.
- **Note:** the task brief described `nav.gd` as using `AStarGrid2D`; the actual implementation is a custom binary-heap A*. Coordinator should not ask for an `AStarGrid2D` migration as part of this fix.
