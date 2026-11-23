# REPORT_FOOD_MILL_PERF — Food / Mill / Fields-gfx / Perf / Launch wave

Task: **T-DOCS-1** (documentation only). This is the single new artifact for the
wave. No other doc was edited; parallel writers own the other reports.

Scope: five lanes that shipped together in the working tree — **food economy**
(no infinite food), **mill cycle** (ring sowing / resow / regrow), **fields gfx**
(four visual stages), **performance** (sim + render guards) and **launchers**
(four `.bat` entry points). Supporting evidence: **QA** interim gate and the
**M01–M07** ticket mapping question.

All statements below were verified against the working tree on **2026-11-23** by
direct source reads (`app/scripts/*.gd`), the persisted result JSON
(`app/selftest.json`, `app/shots/bench.json`), the interim QA gate
(`checks/qa_food_mill_perf.md`), launcher contents, and git history
(`3ad10553` "mostly remove bloat + step" introduced the substantive wave;
`021fe169` "move shit around" re-laid-out assets with only path-fixup edits to
`game.gd`/`selftest.gd`/`world.gd`). Line numbers are from the **current
working tree**, which has since drifted from the numbers quoted in the interim
QA doc; where they differ, the numbers here are authoritative.

---

## 1. Status at a glance (honest)

| Lane | Status | One-line basis | Gate caveat |
|---|---|---|---|
| Food economy (T-FOOD-1) | **DONE-IMPLEMENTED** | Zero food nodes at mapgen; wild food refused in all four paths; sole `_add_res("food")` is a mill-tagged finite 50-hit field | Final gate not re-run; selftest `resow` currently red |
| Mill cycle (T-MILL-CORE) | **DONE-IMPLEMENTED** | 7×7 rotated ring, 5 gold/field, 49-field cap, `cmd_sow` restores depleted first, 20-food/2 s resow, near-mill 60 s regrow | No fresh `t_mill_logic` run by this desk |
| Fields gfx (T-FIELDS-GFX) | **DONE-IMPLEMENTED** | Four stages, decal + modulate/tint, timer bar, four minimap colors, mill panel counts, cached textures, `fields_anim` redraw gate | No fresh in-engine capture by this desk |
| Perf — sim (T-PERF-SIM) | **DONE-IMPLEMENTED** | 16 m resource spatial hash, block-rect cache, single-pass upkeep, nav ink cache, AI raid prefilter | 84.4 s → 43–49 s CLI claim is **reported**, not independently re-measured here |
| Perf — render (T-PERF-RENDER) | **DONE-IMPLEMENTED** | Paused/static redraw gates, ghost cache, fog revision, dirty HUD labels, minimap base cache, hover throttle, single-pass pick, camera dt clamp | No fresh frame-time measurement by this desk |
| Launchers (T-LAUNCH) | **DONE-IMPLEMENTED** | `launch.bat`, `launch_3d.bat`, `launch_rust.bat`, `launch_rust_release.bat` present, correct routes, cargo/Godot guards | None executed by this desk (would launch external programs) |
| Integrated QA final gate | **UNVERIFIED-GATE** | Interim `checks/qa_food_mill_perf.md` is **HOLD**; selftest 27/29 (`peasant_capture`, `resow` red); gate jobs timed out / never completed | No fresh serialized selftest+uitest+suite+`cargo test` |
| T6-M01…M07 mapping | **UNVERIFIED-GATE** | No `M01`–`M07` tickets found in `docs/t6/**` or elsewhere | Coordinator must map to real ids or declare superseded |

**No lane is claimed as PASS.** "DONE-IMPLEMENTED" means *the code is present
and was read and checked in the working tree*; it is not a test verdict.
"UNVERIFIED-GATE" means *the evidence required to close the lane does not
exist in a fresh, trusted run*.

---

## 2. Summary

The wave makes food a **strict mill product**. Random skirmish maps no longer
place any food nodes (`_gen_resources` and `_gen_finish` were stripped of seed
strips, stragglers, berries, appended-start food and keep-clear replant). A
*finished* mill sows a rotated 7×7 ring of 50-hit fields at 5 gold each, capped
at 49 fields per mill. Peasants resow depleted fields for 20 food every 2 s;
mill-owned depleted fields also regrow on a 60 s timer, but only while a
finished mill remains within 18 m. Wild (mill-less) food — which mapgen no
longer creates, but old saves or debug spawns might — is refused by the target
query, the explicit gather/resow commands, the gather tick and the delivery
resume path. Fields render in four stages (ripe / growing / regrowing /
depleted) using the existing donor decal with procedural tint, scale and a
timer bar, plus four minimap colors and a mill-panel count line.

The performance work replaces per-peasant full scans with a 16 m spatial hash
for resources, caches impassable building rects and nav ink, folds upkeep into
one shared pass, and prefilters AI raid targets. On the render side, redraws
are gated on paused/static state, build-ghost verdicts are cached while the
mouse is still, fog has a revision counter, HUD labels are dirty-flagged, the
minimap keeps a clean base image, hover scanning is throttled, picking is
single-pass, and camera delta time is clamped. Four launchers give human entry
points into the Godot game, the 3D terrain sandbox and the Rust port.

Implementation is present and internally consistent. **Verification is not
closed**: the owner QA desk left an interim HOLD, the latest selftest is
27/29 with two failures that were already in flight, and the final serialized
gate was never completed (timeouts). This report deliberately does not
convert any of that into a PASS.

---

## 3. Per-lane detail (with file:line evidence)

### 3.1 Food economy — no infinite food — **DONE-IMPLEMENTED**

- **Mapgen places zero food.** `app/scripts/game.gd:1134-1148` `_gen_resources()`
  calls only `_reseed_stage("mines")`, ore richness and ore clustering; the
  comment at `:1138-1142` states the zero-food rule explicitly.
  `_gen_finish()` at `:1326-1328` confirms "no wild-food re-plant here" in the
  keep-clear pass. A repo-wide scan of `_add_res(` calls
  (`:590,622,750,769,780,814,1174,2088,2324,2435`) shows the **only** food call
  is `:2088`.
- **Fields are finite and tagged.** `_add_res()` at `:489-501` sets
  `max_hits = hits` (no sentinel quantities) and gives food fields
  `growth = 1.0`, `regrow_t = 0.0`, `regrow_time = FIELD_REGROW_TIME`. The sole
  food creation, `_sow_field_ring()` at `:2088-2090`, passes `hits = 50`,
  `radius = 0.6` and immediately stamps `f["mill"] = mill.id`. No `-1` or
  `999999` food flag exists; the `-1` values in the file are unrelated
  (`winner`, `team`, `ignore_id`, missing-nav sentinels).
- **Wild food refused in all four paths:**
  - `nearest_res()` auto-targeting: `:2568-2572` skips `type == "food"` without
    a `"mill"` tag.
  - `cmd_gather()`: `:2791-2795` refuses with "Build a mill first".
  - `cmd_resow()`: `:2803-2807` refuses mill-less nodes (and routes live
    fields to `cmd_gather` at `:2808-2810`).
  - Gather tick / delivery resume: `_tick_gather()` at `:4935-4941` drops the
    order on a directly referenced wild node; `_gather_deliver()` at
    `:5048-5051` never resumes harvest on one.
- **Delivery credits only via harvest event.** `_gather_deliver()` at
  `:5007-5041` adds to `players.res` from `carry` at a store
  (`nearest_drop`, which includes `mil` — `data.gd:1074-1075` `stores:["food"]`,
  `drop:true`), then zeros the carry. There is no node-side minting.
- **Honest caveat (not a wave regression):** a pre-existing hard-difficulty AI
  cheat at `game.gd:3733-3741` grants `+1.5` to each AI resource (including
  food) once per second. It is a fixed-rate difficulty bonus, not an
  infinite-node or sentinel exploit, and predates this wave; it is listed here
  so "no path mints food" is not read as an absolute claim about every
  resource increment in the engine.

### 3.2 Mill cycle — **DONE-IMPLEMENTED**

- **Constants** `game.gd:2047-2052`: `SOW_ROW := 7`, `SOW_GOLD := 5`,
  `MAX_FIELDS_PER_MILL := 49`; regrow constants `FIELD_REGROW_TIME := 60.0`,
  `FIELD_MILL_RADIUS := 18.0` at `:144-145`.
- **Rotated ring** `_sow_field_ring()` `:2054-2092`: triggered from
  `_on_building_finished()` at `:2040`; requires a finished `"mil"`
  (`:2055`); counts owned fields and refuses at the 49 cap (`:2057-2062`);
  7×7 loop (`:2066-2069`) with 45° rotation
  `Vector2(cc - rr, cc + rr) * step` (`:2070`); skips out-of-bounds, blocked,
  water/terrain 3/4/5 and clashing nodes (`:2071-2084`); charges 5 gold per
  field (`:2085-2087`) then creates the finite tagged field (`:2088-2090`).
- **`cmd_sow()` restores depleted first** (`:2097-2105`): loops this mill's
  fields with `hits <= 0`, calls `_restore_field()` on each and returns early;
  only sows a fresh ring when nothing needed restoring.
- **Single restore path** `_restore_field()` `:2109-2116`: sets
  `hits = max_hits`, `growth = 1.0`, resets `regrow_t`, bumps `res_dirty`,
  posts a `construct` event.
- **Peasant resow cost** `:4490-4508`: at the field slot, `hit_t` accumulates;
  every 2.0 s it pays `{"food": 20}`, restores the field and switches the
  peasant to gathering it — the "20 food / 2 s" rule.
- **Mill lookup** `_field_mill_id()` `:2122-2136`: returns the linked `mill`
  id in O(1) when that mill is alive/finished/near; otherwise adopts any
  finished mill within 18 m and writes the tag back (`:2134`). `field_can_regrow()`
  `:2146-2150` requires a food node with `max_hits > 0`, `hits == 0` and a
  resolvable mill.
- **Tick paths** `_tick_fields(dt)` `:2199-2219` advances `regrow_t/growth`
  for gated fields only, restores at `>= 60 s`, and sets `fields_anim` for the
  renderer; `_tick_field_growth()` `:2226-2236` re-seeds AI mills and runs the
  gated bulk restore. Both are driven from the main tick (`:3745-3749`).
- **Food-cap upgrades** `data.gd:1123-1132` (`mil_food1/2`, `aca_field1`
  `field_cap 3.0`, `bla_field1` `field_cap 2.0`) scale `hits` and `max_hits`
  together in `_restore_field`/cap code, so no cap inflation path exists.

### 3.3 Fields gfx — **DONE-IMPLEMENTED**

- **Four states** defined in `game.gd:2155-2163` `field_state()`:
  `ripe` (ratio ≥ 0.75), `growing` (live, partially eaten), `regrowing`
  (depleted with timer running), `depleted` (bare stubble). Progress for
  visuals is `field_growth01()` `:2167-2173`.
- **Render stages** `world.gd:2221-2294` `_draw_field()`: `depleted` draws a
  brown stubble plate + short dry strokes (`:2254-2265`); live stages draw the
  cached decal with stage-dependent size and **modulate** tint (`:2266-2285`),
  with `growing` green shoots, `regrowing` a pulsing green-gold tint
  (`:2276-2281`) and a **two-rect timer bar** (`:2286-2293`); a procedural
  vertical-stalk fallback exists when no decal is present (`:2295-2309`).
- **Decal + cached textures** `world.gd:2207-2219` `_field_decal()` reads
  `res://assets/terrain/deco_png/envfieldd.png` (winter `envfielddw.png`) and
  memoizes per season in `field_decal_tex`; called at `:2253` and drawn at
  `:2284`. No new crop-stage sprite asset — stages are procedural by design
  (consistent with draft note 6 in `inbox/draft_food_mill_notes.md`).
- **Minimap colors** `hud.gd:1496-1521`: regrowing olive `Color(0.55,0.58,0.25)`
  (`:1507-1508`), depleted brown `Color(0.32,0.26,0.17)` (`:1509-1510`),
  growing green `Color(0.35,0.62,0.22)` (`:1518-1519`), ripe gold
  `Color(0.85,0.75,0.3)` (`:1520-1521`) — four distinct colors.
- **Mill panel counts** `hud.gd:575-582`: sow button tooltip plus a line
  "Fields ripe/growing/regrowing/bare" fed by
  `game.field_counts_for_mill()` (`game.gd:2176-2195`).
- **Redraw gate** `world.gd:1806-1814`: the resource layer redraws on camera
  movement, `res_dirty` change **or `fields_anim`** (so regrow bars/pulses
  animate without leaking into idle frames); `game.gd:2219` supplies the flag.

### 3.4 Performance — sim — **DONE-IMPLEMENTED**

- **Resource spatial hash** `game.gd:105-111` (`RES_GRID_M := 16.0`),
  `nearest_res()` `:2552-2579` scans only buckets overlapped by `max_r`, and
  `_res_grid_ensure()` `:2585-2600` rebuilds on `res_dirty` **and** array-size
  change. The strict `< best_d` nearest rule and filters are preserved.
- **Block-rect cache** `game.gd:112-127` `_block_rects_ensure()` rebuilds
  cached `[Rect2, id]` pairs only when `bld_dirty` changes; margin constant
  `:128-130`.
- **Single-pass upkeep** `game.gd:3884-3940` `_tick_upkeep()`: one shared
  accumulator pass over entities/buildings for food/gold/stone per player
  (`:3892-3924`) instead of three separate scans.
- **Nav ink cache** `game.gd:4062-4071`, `:4087-4088`: building ink cells are
  cached per `nav_version`, with a duplicated output array so callers cannot
  mutate the cache.
- **AI prefilters** `ai.gd:293-309` per-tick deposit cache (invalidated at
  `:40-41`); `ai.gd:442` fetches the building list once; `ai.gd:615-663`
  `_raids()` collects eligible cavalry first, then enemy peasants once
  (`:638-644`) before scanning food nodes — removing an O(nodes × entities)
  rescan while preserving first-match target choice.
- **Reported wall-time improvement:** a 60 s CLI soak went from **84.4 s to
  43–49 s (≈45 % faster)** per the wave-owner's report. **This desk did not
  re-run or independently time it**; see §4 and §5. The only persisted bench in
  the tree, `app/shots/bench.json`, records `sim_ms_per_tick 196.03`,
  `headless_sim_only: true`, `wall_seconds 189.118` for a 30 s sim — that is a
  **simulation-cost** metric, not render fps or the CLI soak, and must not be
  cited as such (same caution as `checks/qa_food_mill_perf.md` §2/§3).

### 3.5 Performance — render — **DONE-IMPLEMENTED**

- **Sync redraw gates** `world.gd:1801-1834`: camera-move detection, `res_dirty`/
  `bld_dirty` comparison, `fields_anim` and rotor presence decide layer
  redraws; unit/anim layers are skipped while `paused` with a still camera and
  clean sim (`:1826-1829`); fx layer goes through `_fx_needs_redraw()`
  (`:1843-1856`) which only redraws on move/dirty/rally/fx-items/selection/
  projectiles/ghost/armed patrol.
- **Ghost cache** `world.gd:3079-3125`: placement verdict is cached while the
  mouse moves < 2 px, the ghost id is unchanged and the result is < 120 ms old
  (`:3096-3098`); expensive `_bld_tex`/verdict work is skipped on cached frames.
- **Fog revision** `world.gd:106-109,1949` `fog_revision` bumps on fog updates;
  HUD tracks `minimap_fog_rev` (`hud.gd:42-43`) to skip its full-map dim pass
  when no fog pixel changed.
- **HUD dirty labels** `hud.gd:1065-1088`: resource/eco/status text is assigned
  only when the formatted string actually changes (the comment at `:71` notes
  that same-string assignment still relayouts).
- **Minimap base cache** `hud.gd:33-43,1133-1152`: `minimap_base` is built once
  and duplicated into the working/display images; mine and building blip lists
  are rebuilt only on `res_dirty`/`bld_dirty` (`:1261-1278,1323-1338,1491-1495`).
- **Hover throttle & single-pass pick** `input_controller.gd:23` hover-scan
  throttle state; `:290-305` `_pick()` is documented as a single pass replacing
  a two-scan walk; `:912+` hover scan and `:491-494` target/res pick reuse it;
  `:173` stops scanning once one enemy is enough for attack-move.
- **Camera dt clamp + memoized clamp** `camera.gd:96-101` clamps `dt` to
  `minf(dt, 0.05)`; `:19-22,80-94` memoizes `clamp_pos()` so mouse-motion events
  do not re-clamp per event.

### 3.6 Launchers — **DONE-IMPLEMENTED**

All four are present at the repository root (sizes: `launch.bat` 804 B,
`launch_3d.bat` 1169 B, `launch_rust.bat` 639 B, `launch_rust_release.bat` 520 B):

| File | Route | Guard |
|---|---|---|
| `launch.bat` | Godot game, `--path app %*` | PATH → WinGet → Program Files fallback; install hint |
| `launch_3d.bat` | `--path app res://scenes/terrain3d_sandbox.tscn -- --stay %*` | same Godot discovery + hint; `--stay` default, forwards args |
| `launch_rust.bat` | `cd rustport` → `cargo run --bin cossacks3-rust -- %*` | `where cargo` guard + rustup hint |
| `launch_rust_release.bat` | `cd rustport` → `cargo run --release --bin cossacks3-rust -- %*` | same cargo guard |

`clean_temp.bat` (4389 B) remains present with its Godot guard and protected
path list. None of these was executed by this desk — launching Godot or a
cargo build is outside a documentation task and would collide with the shared
runner.

### 3.7 QA gate and ticket mapping — **UNVERIFIED-GATE**

- `checks/qa_food_mill_perf.md` is explicitly **INTERIM — NOT FINAL / HOLD**.
  It records pre-landing baselines (selftest 29/29, uitest 17/17, suite 19/19,
  `t_mill_logic` 4/4, bake 107–109 ms < 250 ms, `cargo test` exit 0) and states
  that no final gate was run because sibling writers were in flight. Those
  green numbers are **baselines, not current verdicts**.
- The freshest persisted selftest, `app/selftest.json`, is **27/29**, with
  failures `peasant_capture` ("peasant captured: player 1") and `resow`
  ("wild food nodes=0; depleted mill field re-sown: no; mill: auto=24
  restored=1 gold=3321"). The `resow` failure detail actually **confirms zero
  wild food nodes** while failing the resow sub-step — this is the in-flight
  failure the owner flagged, not evidence of an infinite-food path.
- `git status` at verification time still shows modified engine files
  (`game.gd`, `data.gd`, `config.gd`, `main.gd`, `mapgen.gd`, `menu.gd`,
  `pattern_gen.gd`, `world.gd`, queue counters) plus untracked test files — the
  tree is not settled, which is why the final gate cannot be honestly closed.
- **M01–M07:** no tickets with those ids exist under `docs/t6/**` or elsewhere
  in the repo (the interim QA doc, §4/§5 item 4, reports the same 0-hit grep).
  Closest known items are `T6-T01…T15` piece lanes and the `T90/W04/U90`
  sign-offs. They cannot be marked closed by reference without coordinator
  action.

---

## 4. Verification evidence — what ran and what did NOT

### Ran / directly verified by this desk (read-only)

| Check | Method | Result |
|---|---|---|
| Source reads of all five lanes | `game.gd`, `world.gd`, `hud.gd`, `camera.gd`, `input_controller.gd`, `ai.gd`, `data.gd`, launcher `.bat` files | Every code claim in §3 located at the cited line |
| Sole food-node creation | Repo-wide grep of `_add_res(` in `game.gd` | Only `:2088` creates food; finite `hits = 50`, mill-tagged |
| Zero wild food at runtime | `app/selftest.json` `resow` detail | `wild food nodes=0` |
| Selftest count | Parse of `app/selftest.json` | **27/29**; `passed: false`; failures `peasant_capture`, `resow` |
| Sim bench metric | Parse of `app/shots/bench.json` | `sim_ms_per_tick 196.03`, `headless_sim_only true` — INFO, not fps |
| QA interim state | Read `checks/qa_food_mill_perf.md` | INTERIM / HOLD; no final gate |
| Git history | `git log --oneline -S …`, `git show 3ad10553`, `git show 021fe169` | Wave introduced in `3ad10553`; `021fe169` is asset moves + path fixups |
| Launcher contents | Read all four `.bat` files | Routes and cargo/Godot guards correct |

### Did NOT run / NOT verified by this desk

- **No Godot job was submitted.** No fresh selftest, uitest, full suite,
  screenshot, CLI soak, or bake bench was executed.
- **No `cargo test`** was executed; the "PASS, exit 0" line in the interim QA
  doc is a pre-landing baseline only.
- **The 84.4 s → 43–49 s CLI improvement** is taken from the wave-owner's
  report; no persisted timing artifact was found for that comparison, and this
  desk did not re-measure it. Treat the number as **reported / unverified**.
- **No in-engine field-gfx capture** was taken; the four-stage rendering is
  verified by source, not by a fresh PNG.
- **No launcher was executed.**
- **Final integrated gate never completed** — the owner's gate jobs timed out;
  no fresh serialized selftest+uitest+suite+`cargo test` evidence exists.
- **M01–M07** were not mapped to real ticket ids; no closure evidence exists.

### Stale artifacts explicitly excluded

- `app/report.json` is a stale FAIL (older `farm_cap`/`peasant_capture` red)
  superseded by `app/selftest.json`; do not cite it as current.
- The green table in `checks/qa_food_mill_perf.md` §2 is pre-landing baseline;
  it is not current evidence.
- Any claim equating `bench.json` `sim_ms_per_tick 196` with render fps is
  rejected.

---

## 5. Known gaps / unverified

1. **Final gate not run.** The tree is still dirty (parallel writers), and
   selftest is 27/29 with `peasant_capture` and `resow` red. Until a fresh,
   serialized gate passes, all five implementation lanes stay
   DONE-IMPLEMENTED rather than PASS.
2. **`resow` selftest step fails** with zero wild food nodes and no successful
   in-suite field re-sow (`auto=24 restored=1`). The code path exists and was
   read (§3.2), but the behavioural assertion does not currently pass; the
   owner flagged this as pre-existing/in-flight. It must be triaged before
   closing T-FOOD-1/T-MILL-CORE.
3. **CLI perf number is second-hand.** 84.4 s → 43–49 s (≈45 %) was reported by
   the wave owner but was not independently timed here; re-run the 60 s CLI
   soak under the shared runner to confirm.
4. **Render perf claims are source-level only.** Redraw gates, caches and
   clamps were read but not measured; no fresh frame-time or stall data.
5. **Launchers untracked/uncommitted?** At verification time `git status` did
   not list the three new `launch_*.bat` files as modified, but the wave
   landed them in the working tree via `3ad10553`; the owner should confirm
   they are staged/committed as intended (same class as the P-38 uncommitted
   fix precedent in the interim QA doc).
6. **T6-M01…M07 unmapped.** Need coordinator mapping to real `T6-T*`/`W*`/`U*`
   ids or an explicit "superseded" declaration.
7. **AI hard-difficulty cheat** (`game.gd:3733-3741`) grants a fixed +1.5/s of
   every resource to AI players. Documented in §3.1 as a nuance; not a wave
   regression, but any absolute "no food is created without harvest" claim
   must carve it out.

---

## 6. How to verify manually

Perform these **after** sibling writers land, using the shared runner only
(agents must not invoke `godot` directly):

1. **Confirm the tree is settled:** `git status --short` should show no
   engine-file churn; run `python app/tools/godot_runner.py status` and wait for
   `pending: 0`, `godot.lock: free`.
2. **Fresh gates, one serialized batch** (unique ids, e.g. `tqa-*`):
   - `--self-test app/selftest.json` — expect `passed: true`, 29/29, specifically
     `train`, `resow`, `farm_cap`, `peasant_capture` green.
   - `--ui-test app/uitest.json` — expect 17/17.
   - Full suite: check `app/tests/results/summary.json` (expect 19/19, fresh
     mtime), `t_mill_logic` 4/4 and `t_mill_rotor` PASS.
   - `--cli app/cli.json --cli-seconds 60` — grep stdout for `stuck`, `ERROR`,
     `SCRIPT ERROR` (case-insensitive) and confirm **0 hits**; time the wall
     seconds to confirm the 43–49 s improvement.
   - `cargo test --manifest-path rustport/Cargo.toml` directly (no runner) —
     exit 0.
   - `--screenshot` on a fresh mill field and view the PNG: four stages
     (gold / green / pulsing green-gold + bar / brown stubble) and four minimap
     colors should be visible.
3. **Re-measure the food invariant:** from a fresh dump, count `type == "food"`
   nodes on a random skirmish map (expect **0** before any mill is built); build
   a mill and confirm ≤ 49 tagged fields, each with finite `hits/max_hits`, and
   that `pay_cost` debits gold on sow and food on peasant resow.
4. **Re-measure perf honestly:** record bake `max_ms < 250` separately from
   `sim_ms_per_tick`; never quote the sim figure as render fps.
5. **Launchers (human only):** double-click `launch.bat` (game),
   `launch_3d.bat` (3D sandbox, window stays open via `--stay`),
   `launch_rust.bat` / `launch_rust_release.bat` (Rust port). Confirm a clear
   install hint appears if Godot/cargo is missing and that no protected path
   is deleted.
6. **Close or supersede M01–M07** with the coordinator, then add a final
   addendum to `checks/qa_food_mill_perf.md` promoting each lane on fresh
   evidence only. Until then, keep the statuses in §1 unchanged.

---

*Status legend used throughout: **DONE-IMPLEMENTED** = code present and read in
the working tree; **UNVERIFIED-GATE** = no fresh trusted test evidence. No
false PASS is asserted.*
