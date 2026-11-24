---
title: "R1 — Farming / production feature family: donor truth vs verified port code state"
owner: R1
decision: "D-22 quality-first"
updated: 2026-11-24
scope: "READ-ONLY. Donor C:\\Games\\Cossacks 3\\data\\scripts + locale read as bytes with Python open(...,'rb').decode('latin-1'); no donor executable run, no donor file copied. Port app/scripts/{game,data,config,hud,input_controller,world,audio,main,ai,selftest}.gd read-only. No Godot / godot_runner run. Verifies board P-50 / P-51 / FP-1 / FP-2 / FP-6 and corrects stale docs/audit/MICRO.md rows."
---

# R1 — Farming / production verification

**Method (observed).** Every donor citation is a literal line read this pass; every port
citation is a literal line in the current working tree (2026-11-24), **not** board prose.
Labels: `observed` = literal line read; `derived` = arithmetic/control-flow consequence;
`inferred` = attribution or mapping choice. Verdict = CONFIRMED / PARTIAL / MISSING /
UNVERIFIED for the family claim, not for the ticket title.

**Headline (derived).** The owner's 2026-11-21 complaint is **no longer true of the code**:
P-50/P-51 are implemented and FP-6 is implemented. `docs/audit/MICRO.md` (2026-11-21)
rows 1–4, 6–8, 10, 13, 65 are **stale**, as are its specific numbers `aca_rye1 +40%` and
`mil_food2 +250%`. Residual gaps are fidelity-level, not absence.

## 1. Claim table

| # | claim | evidence (donor path:line + port path:line + literal) | verification method | verdict | correction / action |
|---:|---|---|---|---|---|
| 1 | Donor mill auto-creates a 7×7 = 49-tile rotated field diamond, 5 gold/tile | donor `scripts/lib/unit.script:6470` `_unit_DoSeedWheat`, `:6475` `const cRow = 7`, `:6476` `cCount = cRow*cRow`, `:6477` `const size = 1.6981`, `:6494` `VectorRotateY(...,45)`, `:1691-1694` `'field' ... price[gc_resource_type_gold] := 5`; port `game.gd:2093-2142` `SOW_ROW := 7`, `SOW_GOLD := 5`, `MAX_FIELDS_PER_MILL := 49`, `step := 1.6981 * TILE * 0.5` | literal read both sides; 7×7=49 derived | **observed — CONFIRMED** (mechanism) / **derived — PARTIAL** (fidelity) | P-50 "DONE" is accurate at loop level. Reword as "ring exists; donor collision/snap fidelity partial" rather than full parity. Port tile pool is `hits=50` (`game.gd:2138`) vs donor 25 000 HP (`dmscript.global:128`) — model mapping is `inferred`. |
| 2 | Ring spawns when a mill finishes; donor also seeds pre-built mills at map generation | donor `common.inc/generatemap.inc:46` `const cSeedWheat = True`, `:1009-1022` `usage=gc_obj_usage_mill ... _unit_DoSeedWheat(goHnd, False)`; port `game.gd:2062` + `:2089-2090` `_on_building_finished(e)` → `_sow_field_ring(e)` when `e.sid == "mil"`; port `_spawn_starts:2499-2533` spawns only `"cen"` (no pre-built mill) | read call sites and start-spawn loop | **observed — CONFIRMED** (live build); **observed — N/A** (mapgen path) | No ticket: the donor map-gen branch is unreachable in a port that starts with no mill. Do not re-open P-50 for it. |
| 3 | Donor skips tiles by 5×5 rotated collision scan + near-resource radii; port uses a simpler clash test | donor `unit.script:6504-6521` `for j:=0 to 25-1 ... GetMapCollisionTag`, `:6527` `rad := size*0.9*3`, `:6536-6539` food/wood/stone `allowdst := rad/3`, ore `allowdst := rad`; port `game.gd:2121-2134` `in_bounds`/`is_blocked`, terrain `3 or 4 or 5` skip, `n.pos.distance_to(p) < 1.5*TILE` for food/wood/stone only | literal read; radius ratio derived | **derived — PARTIAL** | Port has no 5×5 scan, no discrete `size2` snap (`:6497-6499`), and no ore-distance rule. Ore nodes have radius 0 and are not blocked (`_add_res:508-520`), so fields can be sown on a mine apron. Low-cost fidelity follow-up; keep out of P-50 as DONE. |
| 4 | Donor "Grain Crops" is a one-shot mill production order; port has button + Y hotkey | donor `units/building.inc/doprogressorders.inc:123-136` `gc_obj_order_type_produce ... usage=gc_obj_usage_field → _unit_DoSeedWheat(myHnd, False); amount := 0; _unit_RemoveOrder`; `locale/en/units.txt:1016-1017` `@field` / `Grain Crops`; port `hud.gd:576-581` `_mkbtn("Grain Crops",...)`, `:755-761` `_on_grain_crops → game.cmd_sow(mill)`, `input_controller.gd:823-830` `sow_fields`, `config.gd:131` `"sow_fields": "Y"`, `game.gd:2147-2155` `cmd_sow` | literal read of order branch, locale, button, hotkey, command | **observed — CONFIRMED** | P-51 "DONE" stands. Caveat (derived): port is instantaneous, not a queued order; `cmd_sow:2153-2155` **restores depleted fields first** and only sows a new ring if none were restored — donor order always seeds. Document as intended adaptation, not a bug. |
| 5 | Fields grow toward full capacity over time | donor `env/env.inc/nothing.inc:78-86`: `cFieldRestartTime = 31.25`, `hp := Min(hp+Floor(gc_FieldMaxHP*random*0.1), gc_FieldMaxHP)` gated on stage-0 visual tag; `dmscript.global:128` `gc_FieldMaxHP = 25000`; port `game.gd:156` `FIELD_REGROW_TIME := 60.0`, `:2249-2269` `_tick_fields` linear `regrow_t` → `_restore_field` (full `hits = max_hits`) | literal read; absence of partial-HP write verified by full function read | **observed — PARTIAL** | Regrowth exists, but it is a **binary 60 s timer**, not donor's 31.25 s gated +10% HP increments. FP-2's "field growth stages" is the visual half only (`world.gd:2494-2543`). If fidelity required, add partial `hits` increments; else document. |
| 6 | Port exposes ripe/growing/regrowing/depleted field states visually | port `game.gd:2205-2213` `field_state` (ratio ≥ 0.75 → ripe), `:2217-2223` `field_growth01`, `:2226-2245` `field_counts_for_mill`; `hud.gd:582-590` state line + tooltip, `hud.gd:1537-1551` minimap; `world.gd:2494-2543` `_draw_field` (envfieldd decal, stubble, green-gold scaling). Donor stage gates `nothing.inc:72-76` `hp<5000` / `hp<13000` | literal read | **observed — CONFIRMED** (states) / **derived — PARTIAL** (threshold mapping 0.75 vs 13000/25000=0.52) | No MISSING ticket. Minor: donor stage-1 threshold is 0.52 of full HP, port switches at 0.75; adjust only if a visual A/B gate demands it. |
| 7 | Auto re-sow timer ~60 s | donor `dmscript.global:1487` `gc_global_TimeSeedWheat = 0.03*2000`, `progresseconomicai.inc:3896` `_player_CheckProgressLastTimeAndIncrease(gPlayer[plInd].lastseedwheattime, 3, gc_global_TimeSeedWheat+plInd*3)`; port `game.gd:3837-3840` `sow_t += dt ... if sow_t >= 60.0: _tick_field_growth()`, `:2276-2286` AI mill ring re-seed + depleted restore | literal read; 0.03×2000=60 derived | **observed — CONFIRMED** (period); **derived — PARTIAL** (donor adds `+plInd*3` per-player stagger and a `3`-unit check step) | No ticket; per-player stagger is immaterial for 2-player skirmish and would add state. Keep MICRO open question 1 open on unit conversion. |
| 8 | Human auto-sow is gated by the economy adviser | donor `progresseconomicai.inc:3899` `if (bai) or (not bai and gPlayer[plind].playeradviser.adviser.benable and ...adviser.beconomy) then _ai_DoSeedWheat(plind)`; port `game.gd:2277-2279` `if not bool(players[pi].get("is_ai", false)): continue` — human timer branch never runs; no `adviser` symbol in `app/scripts/**` (grep) | literal read + whole-tree grep | **observed — MISSING** (port), deliberately deferred by D-12 skirmish charter (MICRO row 46) | Do **not** let board P-51 "DONE" imply adviser parity. Either record as an explicit charter waiver or add a small `economy_adviser` config toggle; do not silently claim complete. |
| 9 | "Field capacity +200%" / agricultural equipment +100% are the donor **field-life decay** upgrades | donor `locale/en/upgrades.txt:8` `(field capacity +200%)`, `:130` `(field capacity +100%)`; `lib/country.script:3490` `gc_upg_type_fieldlifeperc, 200`, `:3714` `gc_upg_type_fieldlifeperc, 100`; `dmscript.global:760` `gc_upg_type_fieldlifeperc = 23`; `lib/player.script:1830-1831` `fieldlife := Round(fieldlife + value)`; `units/unit.inc/onaclanimationreachedwork.inc:24` `resdec := Max(1, floor(100/(1+(fieldlife/100))))`; port `data.gd:1134-1137` `aca_field1 {field_cap:3.0}`, `bla_field1 {field_cap:2.0}`, applied `game.gd:3404-3410` scales `max_hits` AND `hits` of every food node | chain traced from locale label → upgrade type → player field → harvest formula vs port apply_upgrade | **derived — PARTIAL** | Important correction to MICRO rows 6/8: locale "field capacity" **is** `fieldlifeperc`, i.e. slows per-hit decay; it is not a separate upgrade. Port's 3×/2× yield is numerically close (3× as many harvests) but changes the regrow target and does not change `resdec`. If strict parity wanted, add `player.fieldlife` + divisor in harvest tick; otherwise document "equivalent harvest count, different mechanism". |
| 10 | Wheat harvesting +40% (aca.1) | donor `locale/en/upgrades.txt:2` `(harvesting +40%)`; port `data.gd:1138-1139` `aca_wheat1 effect gather_mult.food = 1.4`, name `New wheat +40%` | literal read | **observed — CONFIRMED** | none |
| 11 | Rye harvesting +50% (aca.2) | donor `upgrades.txt:4` `(harvesting +50%)`; port `data.gd:1140-1143` `aca_rye1 ... 1.5`, with explicit comment "not the previous estimated +40% (deep-MICRO §2.2)" | literal read | **observed — CONFIRMED** | MICRO row 7 is stale; do not re-ticket the +40% error. |
| 12 | Agronomist / agriculturists' salary +50% (aca.3) | donor `upgrades.txt:5-6` `@%nat%aca.3` / `Raise agriculturists' salary ... (harvesting +50%)`; port `UPGRADES_BASE` `data.gd:1111-1200` has aca.1/aca.2/aca.4=field/aca.5=boat but **no aca.3 row**; grep `agronom`/`agri` in `app/scripts/**` = 0 hits | literal donor line + full upgrade-block read + grep | **observed — MISSING** | Add `aca_agronom1` (`building:"aca"`, `gather_mult.food = 1.5`, name "Agriculturists' salary +50%"). See Top-5 #1. Verify stacking rule with donor (open question Q3). |
| 13 | Grain treatment +140% (mil.1) | donor `upgrades.txt:141-142` `(harvesting +140%)`; port `data.gd:1128-1129` `mil_food1 ... 2.4`, `Grain treatment +140%` | literal read | **observed — CONFIRMED** | none |
| 14 | Grain storage +180% (mil.2) | donor `upgrades.txt:143-144` `(harvesting +180%)`; port `data.gd:1130-1133` `mil_food2 ... 2.8` with comment "not the previous estimated +250% (deep-MICRO §2.2)" | literal read | **observed — CONFIRMED** | MICRO row 8 is stale. |
| 15 | Worker slots per resource node food 3 / wood 2 / stone 3 | donor `dmscript.global:222-225` `gc_gameplay_resource_maxattackers_food = 3`, `_wood = 2`, `_stone = 3`, `_none = 4`; port `data.gd:558-560` `RESOURCE_WORKERS := {"food":3,"wood":2,"stone":3}`, enforced `game.gd:5044-5059` `on_node >= max_workers` → retarget | literal read both, enforcement call site read | **observed — CONFIRMED** | FP-1 "worker slots" DONE stands; MICRO row 10 stale. Donor `_none = 4` has no port equivalent — `inferred` low impact, no ticket. |
| 16 | Mill windmill ambient sound near a finished mill | donor `lib/gui.script:3234` `const cMill = 'amb_windmill'`, `:3266-3271` `cBaseVolumeMill = 0.3`, `mindstmill = 20`, `maxdstmill = 60`, `:3285-3290` usage=gc_obj_usage_mill volume ramp, `:3301-3302` set volume/playing; port `audio.gd:17-22` `AMBIENT_MAX_DIST := 60.0`, `AMBIENT_TICK := 0.4`, `:73-126` dedicated looping `amb_windmill` player + distance attenuation | literal read; ramp constants compared | **observed — CONFIRMED** (family) / **derived — PARTIAL** (port ramp starts 8 m, donor 20 m; clamp 8 dB vs linear 0.3 base) | FP-6 stands. Cosmetic only; do not open a ticket without an A/B audio gate. |
| 17 | Distinct wood / stone / mine work sounds; food silent in donor | donor `onaclanimationreachedwork.inc:44` `_unit_RequestPlaySound(myHnd, gc_snd_ind_workstone)`, `lib/sound.script:373` `workstone'+IntToStr(i)`, `:371` `workfood'+IntToStr(i)` defined but **calls commented out**: `onaclanimationreachedwork.inc:28` and `units/unit.inc/ontagstates.inc:303` `//sndind := gc_snd_ind_workfood`; port `audio.gd:222-230` `work_sound`: wood→`workwood`, stone/gold/iron/coal→`workstone`, food→`workconstruct`; `main.gd:1280-1282` `"chop": ... _play(["workwood"], -8.0, ev.pos)`; audio.gd:184-189 + `:235-251` recovers resource type at event position | donor call-site search + comment check + port dispatch read | **observed — CONFIRMED** (wood/stone/mine); **inferred — PARTIAL** (food stand-in, explicitly documented in audio.gd:216-221) | FP-6 honest as written. MICRO row 65 stale for stone/mine. Do not "fix" food to workfood: no donor call exists. |
| 18 | Manual peasant re-sow of a depleted mill field still works | port `game.gd:2875-2886` `cmd_resow` (requires `node.has("mill")`), `:4586-4605` 2 s work + `pay_cost({"food":20})` → `_restore_field`; right-click path in `input_controller.gd`; selftest `selftest.gd:360-405` step `resow` | literal read command/tick/test | **observed — CONFIRMED** | MICRO row 5 accurate; no ticket. Note port refuses wild food (`game.gd:2624-2629`, `:2866-2869`, `:5035-5038`) — donor has wild food; this is the T-FOOD-1 design decision, not a regression. |

## 2. Stale / overclaimed tickets (explicit)

* **P-50 (board line 80, DONE)** — **NOT overclaimed at loop level**; code exists at
  `game.gd:2089-2142`. It **is** overclaimed if read as donor-exact fidelity: no 5×5
  collision scan, no `size2` snap, no ore-distance rule (claim 3).
* **P-51 (board line 81, DONE)** — button/Y-hotkey/growth timer all present. Overclaimed
  only for **adviser gating**, which is absent by charter (claim 8).
* **FP-6 (board line 125, DONE)** — verified present; honest caveat that food work sound is
  an inferred stand-in is already in code comments (claim 17).
* **FP-1 / FP-2 (board lines 120-121, DONE)** — worker slots and field state visuals verified
  (claims 15, 6). FP-2's "field growth stages" is visual; sim regrowth is still a 60 s binary
  timer (claim 5).
* **`docs/audit/MICRO.md` (2026-11-21)** — rows 1, 2, 3, 4, 6, 7, 8, 10, 13, 65 and its
  Top-20 items 1–3, 7–8, 18–19 are **stale**. Specifically refuted by current code:
  "no field creation hook", "no button", "no growth/regeneration", "no per-tick recovery",
  "`aca_rye1` +40%", "`mil_food2` +250%", "only food capped at 2", "no food/stone/mine work
  sounds". Do not assign work from that document without re-verifying against this report.
* **MICRO §2.3 correction** — MICRO treated "field-life upgrade" and "field capacity +200%"
  as separate donor features; donor `country.script:3490` shows they are the **same**
  `gc_upg_type_fieldlifeperc` upgrade (claim 9).

## 3. Ranked Top-5 actionable list

Rank = rough impact × frequency ÷ cost (`observed` evidence, `derived` ranking, `inferred`
cost/impact weighting).

| # | item | impact×freq÷cost (derived) | exact port file | minimal change | acceptance criterion | seed-determinism risk |
|---:|---|---|---|---|---|---|
| 1 | Add agronomist/agriculturists +50% upgrade (aca.3) | **HIGH** — 1 tiny data row, permanent economy effect | `app/scripts/data.gd` (after `aca_rye1`, ~`:1143`) | one `UPGRADES_BASE` row `aca_agronom1`: `{"building":"aca","effect":{"gather_mult":{"food":1.5}}, ...}`; no code change | Researching it at the academy yields a HUD upgrade entry whose name contains "+50%" and food gather multiplier becomes 1.5× | **NONE** — data-only. `research()` iterates a fixed dict; no RNG. Adding a key changes AI research order only if `ai.gd:483` is edited; leave that list unchanged for byte-identical seeds. |
| 2 | Donor-faithful field regrowth increments (31.25 s / +10% HP) | **MED-HIGH** — every mill field, small sim change | `app/scripts/game.gd` (`_tick_fields:2249-2269`, const near `:156`) | replace full `_restore_field` at 60 s with staged `hits` increases: `hits = min(max_hits, hits + floor(max_hits * k))` on a per-node 31.25 s gate while `field_state(n) == "growing"`; keep `_restore_field` at full | A depleted mill field first shows partial green shoots then becomes harvestable in donor-like steps; `field_growth01()` still returns 0..1 | **LOW** — deterministic arithmetic only, no `randf()`. Donor uses `random`; use a hash of `node.id`, never the global `rng`, or dumps shift. Changing regrow timing changes food availability → AI decisions → save/dump divergence on replay; gate behind a version flag if determinism is a release gate. |
| 3 | Donor ring skip fidelity (5×5 collision, discrete snap, ore radius) | **MED** — only on mill placement, medium cost | `app/scripts/game.gd` (`_sow_field_ring:2104-2142`) | add a 25-point rotated collision probe around each candidate, snap to `sqrt(2)*step` lattice, and skip nodes within `rad` of gold/iron/coal deposits; keep 5 gold and cap 49 | On a fixed seed, no field overlaps a mine apron or blocked tile; field count stays ≤49; gold spend unchanged per surviving tile | **MED** — extra probes are pure geometry (no RNG), but changing which tiles are sown changes `res_nodes` order and `next_id`, hence gather target selection and dumps. Require a fresh byte-identical-dump check before merge. |
| 4 | Human economy-adviser gate (or explicit waiver) | **MED** — every human mill, tiny code, but charter-scoped | `app/scripts/game.gd` (`_tick_field_growth:2276-2286`) + `app/scripts/config.gd` (economy block ~`:85-90`) | optional `economy.adviser_auto_sow` (default matching current behaviour); change human `continue` to consult it | With the flag enabled, a human player's mill re-sows on the 60 s tick; with it disabled, behaviour is unchanged. If owner declines, add a one-line waiver note in the board only — **no code** | **LOW** — branch on config, no RNG. If enabled by default, human resource/field state diverges from old dumps; keep default OFF for determinism. |
| 5 | Work-sound ramp fidelity (mill 20→60 m, not 8→60 m) | **LOW** — audible near every mill, trivial cost | `app/scripts/audio.gd` (`AMBIENT_MAX_DIST:21`, ramp `:122-123`) | change ramp start from 8.0 to 20.0 and base to donor `0.3` equivalent; leave `AMBIENT_TICK` | Near a mill the volume is flat up to ~20 m then falls to 0 at 60 m, matching `gui.script:3266-3271` | **NONE** — audio only; no game state read/written beyond existing scan. |

## 4. Open questions

1. **Q1 — HP↔hits mapping (`inferred`).** Donor field `gc_FieldMaxHP = 25000` with 100 HP
   per harvest = 250 harvests; port `_add_res("food", ..., 50, 0.6)` gives 50 hits with
   `GATHER_BASE.food.hits = 22` per carry (`data.gd:553`). The port field is ~2.3 carries,
   not 250 harvests. P-50 is functionally correct but the yield/pool ratio is a port
   adaptation; no donor-faithful number was found.
2. **Q2 — auto-sow period conversion (`derived`, MICRO open question 1 unresolved).**
   `gc_global_TimeSeedWheat = 0.03*2000` and port `60.0 s` are numerically equal only under
   the assumed 0.03125 s/frame × 32 frames/unit convention. Not timed against a donor replay.
3. **Q3 — upgrade stacking (`inferred`).** Donor has three separate "harvesting +40/+50/+50"
   upgrades (aca.1/2/3) plus mil.1/2. Whether donor adds the percentages (1+0.4+0.5+0.5)
   or multiplies them is UNVERIFIED here; port `gather_mult.food` multiplies. Adding
   agronomist (Top-5 #1) inherits that uncertainty.
4. **Q4 — donor field-life vs port field_cap equivalence (`inferred`).** With fieldlife=200,
   donor `resdec=33` → ~757 harvests from 25 000 HP. Port `field_cap=3.0` → 150 hits. Both
   are "≈3×" but only the donor formula keeps regen cap constant. Needs an owner decision
   whether numerical parity suffices.
5. **Q5 — `bAuto` is dead in this donor build (`observed`).** `unit.script:6472-6473`
   comments out the auto/manual distinction; both paths use `cRow=7`. Treat 49 as an upper
   bound; the collision skips explain community "~40 fields/mill" (MICRO open question 3).
6. **Q6 — visual threshold (`derived`).** `field_state` ripe cut-off 0.75 (`game.gd:2210`)
   vs donor stage gates 5000/13000 of 25 000 (`nothing.inc:72-76`). Whether an A/B visual
   gate exists is UNVERIFIED; no Godot run was performed by this worker.
