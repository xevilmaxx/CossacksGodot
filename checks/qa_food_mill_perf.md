# T-QA interim gate — food / mill / fields-gfx / perf / launchers (READ-ONLY, siblings in flight)

Status: **INTERIM — NOT FINAL**. Sibling workers are mid-edit (`git status` dirty, see §0).
No Godot job submitted by this desk; no tracked file edited. Helpers policy:
`opencode-go/hy4-flash-free`, fallback to `muse-spark 1.3 contributor` after 2 failures.

## §0 Sibling activity (why final verdict is HELD)

`git status --short` at gate time:

- `M app/mechanics.json`
- `M app/scripts/ai.gd`
- `M app/scripts/game.gd`
- `M app/scripts/hud.gd`
- `M app/scripts/selftest.gd`
- `M app/scripts/terrain3d_sandbox.gd`
- `M app/scripts/world.gd`
- `M app/tests/t_map_variety.gd`
- `M app/tools/scan_map.py`
- `?? inbox/draft_food_mill_notes.md` (read)
- `?? launch_3d.bat` (read)
- `?? launch_rust.bat` (read)
- `?? launch_rust_release.bat` (read)

Runner: `now_serving == next_ticket == 1081`, `pending 0`, lock free, CLEAN
(`assert_clean.py --json` CLEAN, 0 procs, history 500 total / 12 acked / 0 failures).
Queue is idle but tree is NOT settled — final gates must wait for siblings to land,
then one serialized headless selftest + ui-test + `cargo test`.

Sibling draft `inbox/draft_food_mill_notes.md` (DO NOT APPLY YET) proposes the
riskiest change in this wave: **random maps start with ZERO food nodes**
(seed-wheat strips, straggler fields, wild berries, appended-start food and
keep-clear re-plant all removed; food strictly via mill cycle; wild food refused
in `nearest_res`/`cmd_gather`/`cmd_resow`/`_tick_gather`/`_gather_deliver`).
That directly interacts with `selftest` steps `train` (100 food), `resow`
(depleted field re-sown + mill auto), `farm_cap` — fresh gates are mandatory
after it lands. Current evidence below is PRE-LANDING baseline.

## §1 QA registry (what DONE means per lane)

Per `docs/COMMANDS.md` §9 + task brief (files exist, no infinite food, mill cycle
works, bats exist):

| Lane | DONE = all true |
|---|---|
| T-FOOD-1 | food economy bounded: nodes have finite `hits/max_hits`; no path mints food without a harvest/delivery event; `farm_cap` + upkeep + famine gates hold; `selftest` train/resow/farm_cap PASS on fresh run |
| T-MILL-CORE | finished `mil` sows 7×7 ring (`SOW_ROW=7`, `MAX_FIELDS_PER_MILL=49`, `SOW_GOLD=5` per field), `stores=["food"]`, carrier delivery credits player res; `cmd_sow` restores depleted first; `t_mill_logic` 4/4 on fresh run |
| T-FIELDS-GFX | mill-owned depleted fields regrow on 60 s timer (`FIELD_REGROW_TIME=60`, `FIELD_MILL_RADIUS=18`); `field_state` ripe/growing/regrowing/depleted + `field_growth01` + `field_counts_for_mill`; world draws via `_field_decal` (`envfieldd/dw.png` donor alpha) + `_draw_field` (no sunflower heads); `t_mill_rotor` PASS |
| T-PERF-SIM/RENDER | bake bench `max_ms < 250` (T90 gate); sim `sim_ms_per_tick` reported honestly (≠ bake); 60 s CLI soak clean (0 stuck/ERROR/SCRIPT ERROR); no `perf.md` fps fabrication |
| T-LAUNCH | `launch.bat` + `clean_temp.bat` present and guarded; new `launch_3d.bat` / `launch_rust.bat` / `launch_rust_release.bat` present, route correctly, never auto-delete protected paths; Godot never launched directly by agents (runner only) |

False-PASS rule: any green claim without fresh mtime + runner `ok` + independent
re-measure is REVOKED to UNVERIFIED (stale-artifact class, cf. QA_REPORT O4).

## §2 Baseline evidence (pre-landing, read-only)

| Gate | Result (baseline, NOT final) | Evidence |
|---|---|---|
| selftest | PASS 29/29, 0 fails | `app/selftest.json` `passed:true`; `resow`: "depleted field re-sown: yes; mill: auto=15 restored=1 gold=3369"; `farm_cap`: "farm 500 -> 525 -> 500"; `gathered`: food 2269 / wood 120 / gold 293.28 / trade 65 |
| uitest | PASS 17/17 | `app/uitest.json` `passed:true`, 0 fails |
| full suite | 19/19 | `app/tests/results/summary.json` count 19 passed 19 failed 0 (mtime fresh at last O8 wave; re-run required post-landing) |
| t_mill_logic | 4/4 | `app/tests/results/t_mill_logic.json`: no_mill_holds_load (carry=3), mill_is_drop (mill stores food), food_reaches_mill (food 36.9→149.9, gathered 45→204), resow_restores_field (hits 0→0→25) |
| t_mill_rotor | PASS | `app/tests/results/t_mill_rotor.json` `passed:true` (viewport texture + PNG saved) |
| rust cargo test | PASS, exit 0 | `cargo test --manifest-path rustport/Cargo.toml --quiet` → all suites ok (7+4+5+4+3+3 tests ok, 0 failed); warnings only (dead_code `DdsImage.format`, unused framebuffer fns). Full (non-quiet) log showed identical ok lines; earlier `| Select-Object` pipeline exit-1 was a PowerShell pipe artifact, direct run `EXIT:0` |
| bake bench | PASS (claimed) | T90 jobs 1074–1080: bench 107.18 ms (T90) / 109.33 ms (W04) < 250 ms; `scan_map` ALL GREEN; dumps byte-identical SHA `5b006c81…` (per T6-QA-LANE re-measurement, not re-run here) |
| sim bench | INFO (not a gate) | `app/shots/bench.json`: `sim_ms_per_tick 196.03`, units 618, headless_sim_only true, fps 1.19, wall 189 s — sim cost, NOT bake/render fps; must not be cited as render fps |

`app/report.json` is STALE FAIL (build/wall/shell/peasant_capture/farm_cap red,
farm 475→475→475) — superseded by `app/selftest.json` 29/29; do NOT cite it as
current. Flagged here so no lane revives it as evidence.

## §3 Independent re-measures (this desk, zero Godot jobs)

All via `read` + `python -c` (UTF-8-replace decode; game.gd has non-cp1252 bytes):

- Mill constants (`app/scripts/game.gd`): `SOW_ROW=7` (:1806), `SOW_GOLD=5` (:1807),
  `MAX_FIELDS_PER_MILL=49` (:1811), `FIELD_REGROW_TIME=60.0` (:103),
  `FIELD_MILL_RADIUS=18.0` (:104). Functions present: `_sow_field_ring` (:1812),
  `cmd_sow` (:1853, restores depleted first then sows), `_restore_field` (:1865,
  single shared path, sets `hits=max_hits`, `growth=1.0`, `regrow_time=60`),
  `_tick_fields` (per-tick fractional regrow, mill-gated), `_tick_field_growth`
  (AI re-seed + gated bulk restore), `cmd_resow` (:2403), `field_can_regrow` /
  `field_state` / `field_growth01` / `field_counts_for_mill` / `_field_mill`
  (linked-mill O(1) + 18 m adopt fallback). `pay_cost(player,{gold:5})` per field
  + `owned>=49 → 0` cap confirmed — no infinite-field path in current tree.
- No-infinite-food: `max_hits` guards throughout; `_restore_field` restores to
  `max_hits` only (never increments cap); `field_cap` upgrades scale both
  `hits` and `max_hits` together (`data.gd` mil_food/aca_field/bla_field); wild
  nodes in CURRENT tree are still harvestable (sibling zero-food proposal NOT
  yet applied — verified: current `nearest_res` has no mill-tag refusal; draft
  describes future state).
- Fields-gfx wiring (`app/scripts/world.gd`): `_field_decal` (:2070,
  `res://assets/terrain/deco_png/envfieldd.png` / `envfielddw.png` winter),
  `_draw_field` (:2096, no flower heads, decal + gold tint, `g==0` stubble,
  winter cold tint), `_face_collar` (:1268) used at :1504, `_draw_field(p,h,
  _field_growth(n))` at :2304. Assets on disk: `envfieldd.png` + `envfielddw.png`
  present; `mill_rotor.png/.json` present; no `*field*` anim sheets (stages are
  procedural by design per draft note 6 — accepted, not a missing file).
- Mill stores food (`app/scripts/data.gd:991-992`): `"mil": {... "stores":["food"],
  ... "drop":true}`; `cen`/`hou` also store food (expected). `mil_food1/2`,
  `aca_field1`, `bla_field1` effects present.
- Launchers: `launch.bat` (804 B, PATH/WinGet/ProgramFiles fallback, `--path app
  %*`, install hint) + `clean_temp.bat` (4389 B, godot.exe guard, FULL/SHOTS/AUTO
  flags, PROTECTED list covers scripts/tools/scenes/shaders/tests/assets/backups)
  both present. New untracked: `launch_3d.bat` (3D sandbox + `--stay`, forwards
  args), `launch_rust.bat` (`cargo run --bin cossacks3-rust -- %*`),
  `launch_rust_release.bat` (`--release`). All route correctly on read; none
  executed here (would launch Godot/cargo-run — deferred to post-landing gate).
- Perf honesty: bake 107–109 ms vs `bench.json` sim 196 ms/tick are DIFFERENT
  metrics; any claim equating them is REJECTED. No `fps` fabrication found in
  current tree (`bench.json` correctly marks `headless_sim_only:true`).
- Mechanics sheet: `app/mechanics.json` 189 values (`name/group/value/unit/source`);
  food/mill/field rows located by `name`, not `key` (earlier `key` grep returned
  empty — schema note, not a gap).

## §4 Interim verdicts (HOLD — siblings must land first)

| Lane | Interim | Reason |
|---|---|---|
| T-FOOD-1 | PARTIAL (HOLD) | Current tree bounded + 29/29 green, but sibling zero-food proposal (draft notes 1–2) is unlanded; fresh selftest required after it lands (train/resow/farm_cap at risk) |
| T-MILL-CORE | PARTIAL (HOLD) | Ring/cap/cost/delivery verified in code + t_mill_logic 4/4 + selftest auto=15, but tree dirty (game.gd/world.gd/ai.gd/hud.gd/selftest.gd all M); re-run required |
| T-FIELDS-GFX | PARTIAL (HOLD) | Gate fns + decal paths + assets verified; procedural-stages accepted; needs in-engine capture post-landing (sibling world.gd edits in flight) |
| T-PERF-SIM/RENDER | PARTIAL (HOLD) | Bake PASS evidence fresh via T90/W04 jobs (107/109 ms); sim 196 ms reported honestly; needs fresh bench + CLI soak after landing; `fog_revision`/`sync`/`_fx_needs_redraw` claims in draft UNVERIFIED until diff lands |
| T-LAUNCH | PARTIAL (HOLD) | All 5 bats present, content correct on read, guards intact; new bats untracked (need `git add` decision by owner); no live launch test yet (would collide) |
| T6-M01..M07 sim gaps | UNVERIFIED (OPEN) | No `T6-M0*` / `M01` tickets found in `docs/t6/**` (grep 0 hits); closest are T6-T01..T15 piece lanes + T90/W04/U90 sign-offs (see T6-QA-LANE). Cannot confirm closure — coordinator to map M01..M07 → actual ticket ids or declare superseded |

No lane is marked DONE. No false-PASS revoked (all greens have fresh mtimes +
runner `ok` in cited jobs); `app/report.json` FAIL explicitly excluded as stale.

## §5 Open gaps / risks for coordinator

1. Zero-food maps vs selftest: if draft notes 1–2 land, `train` (needs 100 food),
   `resow` (needs a depletable field), `farm_cap` baselines may shift — selftest.gd
   is itself `M` (sibling editing). Gate must re-run selftest+uitest+suite fresh.
2. `launch_*.bat` untracked (`launch_3d`, `launch_rust`, `launch_rust_release`) —
   needs owner commit/staging decision (cf. P-38 precedent: uncommitted fixes).
3. Draft perf items 7–8 (`sync` pause-skip, `_fx_needs_redraw`, `fog_revision`,
   static rally flags) are code claims in an unapplied draft — zero measurement
   here; verify post-landing via bench + screenshot + CLI.
4. T6-M01..M07 unmapped — please confirm whether these are the T6-T*/W*/U*/R*
   lanes (then this gate can close them by reference) or a separate sim-gap list
   still open.
5. `app/report.json` stale FAIL still on disk — consider deleting or marking
   superseded so future QA does not re-litigate it.

## §6 Next (post-landing, serialized, one batch)

1. `python app/tools/godot_runner.py status` (expect idle) → single batch via runner
   with unique `tqa-*` ids: `--self-test app/selftest.json`, `--ui-test app/uitest.json`,
   `--cli app/cli.json --cli-seconds 60`, `--screenshot`, plus `cargo test
   --manifest-path rustport/Cargo.toml` (no runner needed) and `scan_map.py` on fresh dump.
2. Re-measure: food node count from fresh dump, mill auto/restored/gold deltas,
   field counts per mill, bench max_ms, CLI stuck/ERROR grep, PNG non-blank.
3. Promote each lane to PASS/FAIL/PARTIAL only on fresh evidence; revoke any
   stale green. Write final verdict as addendum below (same file, no new paths).

---

## DASHBOARD SNIPPET (copy-paste)

`T-QA interim (siblings in flight): FOOD PARTIAL-HOLD | MILL PARTIAL-HOLD | FIELDS-GFX PARTIAL-HOLD | PERF PARTIAL-HOLD | LAUNCH PARTIAL-HOLD | T6-M01..M07 UNVERIFIED | selftest 29/29 (pre-landing) | uitest 17/17 | suite 19/19 | t_mill_logic 4/4 | bench bake 107-109ms<250 | sim 196ms/tick INFO | cargo test PASS exit0 | queue idle CLEAN | FINAL HELD for sibling landing. Evidence: checks/qa_food_mill_perf.md`
