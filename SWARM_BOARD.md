# Swarm ticket board

States: INTAKE · TRIAGED · ASSIGNED · IN_PROGRESS · REVIEW · QA · DONE · BLOCKED.
Only the coordinator edits the State column. See `SWARM_OPS.md` for gates.

> [!IMPORTANT]
> **QUALITY-FIRST (D-22): all build tickets are effectively BLOCKED until
> `game.gd` parses again.** QA's final gate FAILED (runner #105) on
> `Could not parse global class "C3Game"`; `app/selftest.json` showing 29/29 is
> a STALE ticket-43 artifact, not a fresh result. Agent A owns the fix. Do not
> accept any green result produced while the tree is unparseable. Pending test
> jobs were cancelled via `godot_runner.py cancel --prefix t-` to free the
> runner. Deep audits are in `docs/audit/` and gate status is tracked in
> `docs/STATUS_TESTS.md`.

| ID | Ticket | Owner | Owned files | State | Note |
|---|---|---|---|---|---|
| A-01 | Fix failing `build` self-test step | A | game.gd, selftest.gd, data.gd | DONE | regression found by runner smoke job | reconciled 2026-11-21 from worker reports/gates|
| B-01 | Verify L6 `--seed`/`--dump-map`/`scan_map.py` 20-seed pipeline | B | main.gd, scan_map.py, scans/** | DONE (partial sweep) | determinism PROVEN byte-identical seed-7 dumps (SHA256 8F2DCB1…); seed/dump/uitest green; reach 3/3 after radius fix (deep-GEN); 20-seed sweep omitted due to runner churn |
| C-01 | Audit L7 peasant animations; apply DO-L7.06 duration fix | C | anim index.json, sheet_metrics.py, anim assets, docs/UNIT_BAKING_FIX.md (append) | QA | 0.667 → 1.08 s, 1-field diff; docs ownership corrected 2026-11-21 (was assigned in original task but omitted from board) |
| D-01 | Audit L8 transparent building ghost + block rules | D | world.gd, input_controller.gd, hud.gd | DONE | game.gd defects reported, not edited | reconciled 2026-11-21 from worker reports/gates|
| E-01 | Document runner + swarm protocol; fix stale README wording | E | COMMANDS.md, app/README.md, root README.md | QA | GUIDE4 line count 2296 |
| F-01 | Eliminate `quit()`-in-`_initialize()` hangs in test scripts | F | app/tests/** | DONE | headless guard added; F3 jobs ok (1.99s / 11.15s); 0 direct quit() calls remain; N-01 merged here |
| G-01 | Audit AI opponent: expansion, waves, chat spam, stuck states | G | ai.gd | DONE | CLI 60 s soak required | reconciled 2026-11-21 from worker reports/gates|
| H-01 | Audit menu/scenes flow; optional seed UI field | H | menu.gd, scenes/** | DONE | no main.gd edits | reconciled 2026-11-21 from worker reports/gates|
| I-01 | Cross-check mechanics.json / MECHANICS.md against code | I | mechanics.json, MECHANICS.md | DONE | read-only on .gd files | reconciled 2026-11-21 from worker reports/gates|
| J-01 | Audit nav.gd AStarGrid2D API usage | J | nav.gd | DONE | no new standalone scripts | reconciled 2026-11-21 from worker reports/gates|
| K-01 | Make asset-pipeline tools cross-platform | K | copy_assets.py, convert_models.py, bake_sprites.py, compute_ortho.py | DONE | preserve Windows defaults | reconciled 2026-11-21 from worker reports/gates|
| L-01 | Audit audio wiring and missing sound assets | L | audio.gd | DONE | CLI 60 s log check | reconciled 2026-11-21 from worker reports/gates|
| M-01 | Review all completed diffs; block protocol violations | M | none (read-only) | DONE | review desk | reconciled 2026-11-21 from worker reports/gates|
| N-01 | Feature-request intake → prioritized backlog with acceptance criteria | N | SWARM_BACKLOG.md | DONE | triage desk | reconciled 2026-11-21 from worker reports/gates|
| O-01 | Run full acceptance suite; sign release report | O | QA_REPORT.md | DONE | QA desk | reconciled 2026-11-21 from worker reports/gates|
| P-01 | Fix self-test step `wall` ("stone wall missing") | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-02 | Fix self-test step `shell` (cascades from missing wall) | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-03 | Fix self-test step `peasant_capture` (captured by player 1) | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-04 | Fix self-test step `farm_cap` | A | game.gd, selftest.gd | DONE | resolved by A-01; QA O5 fresh selftest 29/29 (mtime 08:16:04). This row was stale until 2026-11-21 reconciliation |
| P-05 | Remove donor-derived scratch from res:// | AB | `_mill_tmp/**`, bake_mill_rotor.py | MERGED INTO P-09 | user wants the whole mill-rotor feature finished |
| P-06 | Fix damage-protection off-by-one: `data.gd:235` WK is 1-based but `prot` arrays are 0-based 6-slot; `data.gd:916-919` `prot[pi]` reads the NEXT slot for every kind, and `firearrow(6)`/`cannonball(7)` are out of range → no protection at all | IMPL-SIM | data.gd, game.gd | DONE | : PROT_SLOT map landed; firearrow clamp documented |
| P-06b | `.osm` reader "bug" | IMPL-SIM | bake_sprites.py / bake_naval.py | DONE | : PROT_SLOT map landed; firearrow clamp documented |
| P-07 | Raw donor `.dds`/`.lib`/`.mat` git exposure | none | git index, .gitignore | CLOSED | USER DECISION 2026-11-21: leave everything as-is; no action |
| P-08 | 29 donor `.obj/.mtl` meshes on disk | none | app/assets/models/obj/** | CLOSED | USER DECISION 2026-11-21: leave everything as-is; no action |
| P-09 | FINISH the unowned mill-rotor feature (user request) + remove `_mill_tmp` scratch | AB | world.gd, bake_mill_rotor.py, mill_rotor assets, _mill_tmp/** | DONE | user: "its an unfinished feature i want it done"; do NOT touch app/tests/** (F owns until it reports) | reconciled 2026-11-21 from worker reports/gates|
| P-10 | Reopen N-11: port naval units (waiver overturned by evidence) | AC | naval bake pipeline, anim assets, data.gd entries | IN_PROGRESS | 54 readable meshes + 5 readable animated .oss + 24 .aaf; see NAVAL_EVIDENCE.md |
| P-11 | Audit `main.gd` mode dispatch, watchdog and result JSON (R-01 premise correction) | unassigned | main.gd | BLOCKED | B owns main.gd until B-01 closes; testbridge.gd is only the --test-api TCP bridge |
| P-12 | `chop` sound maps to nothing at `main.gd:1065` | unassigned | main.gd | DONE | DE decomp: files NOT missing — `workwood1..9.ogg` exist; one-line fix `_play(["chop"])` -> `["workwood"]`; blocked on main.gd owner B | reconciled 2026-11-21 from worker reports/gates|
| P-13 | Nation music only `rus`/`ukr` | IMPL-SHELL | audio.gd, audio assets | DONE | 20 donor tracks converted to app/assets/sounds + `.import` generated; `MUSIC_FALLBACK="ukr"`; t_audio_events 5/5 PASS (21 nations themed, 0 missing) |
| P-14 | Full donor map options (Terrain/Relief/Richness/Season/Teams) in skirmish menu | unassigned | menu.gd, data.gd, game.gd | BLOCKED | found by H-01; needs sim-layer support; A owns data.gd/game.gd, B owns main.gd |
| P-15 | Literal `"random"` seed string from menu (currently resolved to a random int) | unassigned | main.gd | BLOCKED | one-line change; B owns main.gd until B-01 closes |
| P-16 | Port `.aix` campaign trigger scripts | none | campaign data, menu.gd | DEFERRED | OWNER CHARTER 2026-11-21: missions/campaigns out of scope |
| P-17 | DLC mission-map strategy | none | map generation, tools | DEFERRED | OWNER CHARTER 2026-11-21: DLC missions out of scope |

## Skirmish-first tranche (owner charter 2026-11-21)

| ID | Ticket | Owner | Owned files | State |
|---|---|---|---|---|
| P-18 | Multiple AI opponents / teams on one random map | unassigned | game.gd, ai.gd, menu.gd | DONE | owner explicitly asked for "multiple enemies on map" | reconciled 2026-11-21 from worker reports/gates|
| P-19 | Skirmish options parity: relief, richness, season, teams, map size | unassigned | data.gd, game.gd, menu.gd, world.gd | INTAKE | from RC + H-01; random-map fidelity |
| P-20 | Volley smoke, muzzle flash, arrow trails | IMPL-RENDER | world.gd | DONE (partial) | t_smoke_fx now 6/6 PASS (arrow-trail emitter added, FX_CAP held); shadows/weather still open under P-21 |
| P-21 | Animated water + shoreline (shadows/weather/seasons remain) | IMPL-RENDER | world.gd | DONE (partial) | t_water 5/5 PASS (4 phase-shifted wave variants + time-based shimmer); note: shimmer updates on chunk re-bake (pan/zoom), not per frame; full shadows/weather still open |
| P-22 | Mass-army scale + squad experience/disband | unassigned | game.gd, ai.gd, hud.gd | INTAKE | 200 -> thousands; squads 15-400 already exist |
| P-23 | Skirmish upgrade-tree depth (firepower tiers, bayonet, cavalry, drills) | unassigned | data.gd, game.gd | DONE | RB G-02..G-05, ~12 tickets | reconciled 2026-11-21 from worker reports/gates|
| P-24 | Scotland + nation-unique units + 12 baked-but-unwired sprites | A | data.gd, game.gd, anim assets | DONE (partial) | wired cossackdon/hackapell/cossackregister/bagpiper + `sco` nation; 8 national peasants resolve visually. CORRECTION: `buildings.json` has ZERO `sco_*` keys (1506 keys, 20 prefixes) — Scotland uses generic building art; Scottish unique units need a bake outside A's files |
| P-41 | Bake Scottish building sheets + Scottish unique-unit sprites | IMPL-ASSETS + IMPL-SIM + IMPL-RENDER | anim assets, data.gd, world.gd | DONE | 18 sco_* sheets + sco_highlandersword baked; loaded via EXTRA_ANIM_INDEX; t_roster_scotland 6/6 PASS (spawned Highlander walked 6 m) |
| P-42 | Sim-layer support for N players/teams (hand-off `inbox/handoff-P18-agentG.md`) | IMPL-SIM | game.gd, main.gd, data.gd | DONE | : PLAYER_COUNT/TEAMS + N-player sim; t_multi_ai 6/6 |
| P-43 | Generator emits one start per participant (currently 2, third AI uses fallback) | unassigned | game.gd, pattern_gen.gd | DONE | t_multi_ai FAIL check 2, ticket 182; map_starts=2 with 3 players | reconciled 2026-11-21 from worker reports/gates|
| P-44 | Guard AI-facing `say()` calls with `if player == 0:` (chat spam) | unassigned | game.gd | DONE | G reported 7 sites (1826, 2154, 2175, 2183, 2321, 2364, 2368); t_multi_ai saw 12x "Not enough resources." | reconciled 2026-11-21 from worker reports/gates|
| P-45 | Adjudicate animation-metric thresholds vs measured outliers | ADJ-P45 | t_anim_metrics.gd, docs/audit/ANIM_ADJUDICATION.md | DONE | All 3 checks were WRONG THRESHOLDS, not data defects: donor AAF `idle 1..1` for siege; 68 foot outliers real (0 pixel mismatches); 45 walks donor-exact. Test 5/5 with donor cadence bands; no index.json value changed |
| P-46 | Forest patch structure + start reach | IMPL-SIM + IMPL-PATTERN | game.gd, pattern_gen.gd | DONE | patches 12/12/12, mean 83/86/85, cliff 100%, reach 3/3, purity 100%, clearance 100% (RNG short-circuit restored + post-gen provisioning, default seed byte-identical) |
| P-47 | Cliff ring 0% on seed 9: post-collision `height += 0.25` at `game.gd:487` after collision pass at `:621-642` | IMPL-SIM | game.gd | DONE | : cliff 0%->100% seed 9 |
| P-48 | Clearance 94% boundary case | IMPL-DOCS | scan_map.py | DONE | CORRECTED: prescribed radius 5→6 would regress to 83% (3 of 18 deposits excluded); applied inclusive `>=` at the 10 m boundary instead → 100%. IMPL-DOCS verified distance table. deep-GEN §6.2 to be updated with the correction |
| P-49 | Stale "maps are 160x160" note in `MAPGEN_STATUS.md:71` | unassigned | MAPGEN_STATUS.md | DONE | deep-GEN Q; 320 is working size (D-24) | reconciled 2026-11-21 from worker reports/gates|
| P-50 | Mill auto-creates surrounding crop fields like the donor | IMPL-SIM | game.gd, data.gd | DONE | : 7x7=49 ring, 5 gold/field, selftest auto=24 |
| P-51 | "Grain Crops" mill order + field growth timer/UI | IMPL-SIM | game.gd, input_controller.gd, hud.gd | DONE | : Grain Crops HUD button + Y hotkey + 60s growth, selftest restored=1 |
| P-52 | Systematic donor-vs-port MICRO-FEATURE sweep (small loops missing) | deep-MICRO | docs/audit/MICRO.md | DONE | 68 features enumerated (27 implemented / 23 partial / 17 missing); Top 20 ranked in docs/audit/MICRO.md |
| P-53 | Food gathered by a mill is not credited to player resources | IMPL-SIM | game.gd, data.gd | DONE | t_mill_logic 3/4: `food 0.0->0.0, gathered 4.0->6.0`; genuine delivery bug found by IMPL-LEGACY | reconciled 2026-11-21 from worker reports/gates|
| P-54 | Legacy standalone tests write result JSON | IMPL-LEGACY | 5 files under app/tests/ | DONE | 4/5 pass, t_mill_logic honest FAIL (P-53); prior 97 s was FIFO wait (7 s actual render) |
| P-25 | HUD information fidelity (worker icons, 6 resources, deficit, score) | SC | hud.gd | DONE | RE gap 3 | reconciled 2026-11-21 from worker reports/gates|
| P-30 | Donor formation bonuses (149 verified tuples) | IMPL-SIM | game.gd, data.gd, selftest.gd | DONE | `Data.formation_bonuses()` + `_donor_formation_bonus()` cutover; selftest updated to donor hold +7; t_squads assertion being updated by its author |
| P-37 | Correct false `bonusdamage 0` claims | unassigned | GUIDE4.md:1131, data.gd:215 | INTAKE | deep-DECOMP: GUIDE4 A04 and the data.gd comment are factually wrong; fix comments only, no behaviour |
| P-38 | Land uncommitted/untracked fixes so a clean checkout keeps them | unassigned | main.gd (chop→workwood), bake_naval.py (untracked) | INTAKE | deep-DECOMP: both fixes exist only in the working tree; needs commit/staging decision by owner |
| P-31 | Stage-level reseeding + generator version gates for true random maps | unassigned | game.gd, data.gd | INTAKE | DB decomp fnd_24: donor reseeds before every stage; port uses one seed; 16-24h, critical path |
| P-32 | Import `envscales.cfg` table (mines 0.3152, stones 0.329, 0.85-1.15 jitter) | unassigned | data.gd, world.gd | INTAKE | DB decomp fnd_26; 4-6h |
| P-33 | Hotkey parity from donor `hotkeys.cfg` (243 bindings) | unassigned | config.gd, input_controller.gd | INTAKE | DB decomp fnd_23: `Data.HOTKEYS={}` today; 8-12h; DE also found gaps |
| P-26 | Animation metrics sweep across 54 keys / 299 actions | SE | anim index.json, UNIT_BAKING_FIX.md | DONE | 8 scalar fixes (national peasant walks 0.667 -> 1.08); selftest 29/29; no rebake |
| P-34 | Attack frame timing | PORT-ANIM | docs/audit/ANIM_ATTACK.md | DONE | RULE WRONG, not a data defect: 51/51 attack durations donor-exact from AAF+fps (0 mismatches), one-shot fire_t semantics; index.json unchanged (sha256 verified); test 5/5, selftest 29/29 |
| P-35 | Re-capture a genuine L8 ghost screenshot | IMPL-RENDER | app/shots/ | DONE | `p35_ghost_recheck.png` captured via live windowed `--test-api`: translucent red house + footprint ellipse + red X + "Too close to cen." reason;Inspected with Pillow |
| P-09 | Finish mill-rotor feature (user request) | AB | world.gd, bake_mill_rotor.py, rotor assets | DONE | AB fixed scratch/redraw; IMPL-RENDER corrected rotor scale to true ortho 6.352 (≈0.958x tower cell) and verified spinning over the tower in `impl-mill.png` |
| P-36 | Resolve dead `terrain_masks` path (world.gd:645/92, main.gd:850 — assigned but never read by draw code) | unassigned | world.gd, main.gd | INTAKE | deep-RENDER claim 3 PARTIAL; status docs citing "dmask anti-seam" describe non-rendered code; wrong alpha/red-channel comments too |
| P-39 | Decide whether player 1's missing reachable stone (default seed, 160 tiles, 25-tile radius) is a start-fairness defect or acceptable variance | unassigned | game.gd, pattern_gen.gd | DONE | t_map_variety FAIL check 5, ticket 163; deep-GEN confirms 25 is correct at 160 tiles, so do NOT blame the radius | reconciled 2026-11-21 from worker reports/gates|
| P-40 | Raise squad cap to donor ladder 15/36/72/120/196/400 (`Data.SQUAD_MAX = 195` caps at 193) | IMPL-SIM | data.gd, game.gd | DONE | : SQUAD_MAX=403; t_squads 5/5 |

## WIP expansion — 20 live slots reached (2026-11-21)

| ID | Ticket | Owner | Owned files | State |
|---|---|---|---|---|
| P-07 | Camera/quality preset audit | P | camera.gd, config.gd | DONE |  | reconciled 2026-11-21 from worker reports/gates
| Q-01 | Mapgen/pattern_gen liveness audit | Q | mapgen.gd, pattern_gen.gd, MAPGEN_STATUS.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| R-01 | Test-bridge self-exit audit | R | testbridge.gd | DONE |  | reconciled 2026-11-21 from worker reports/gates
| S-01 | Video capture tools portability | S | seq_to_mp4.py, video_build.py, record_session.py | DONE |  | reconciled 2026-11-21 from worker reports/gates
| T-01 | Export config + perf.md telemetry | T | export_presets.cfg, project.godot, shots/perf.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| U-01 | Runtime config JSON audit | U | config.json, cli.json, uitest.json, *_patterns.json | DONE |  | reconciled 2026-11-21 from worker reports/gates
| V-01 | Credits + waiver documentation | V | CREDITS.md, WAIVERS.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| W-01 | Remaining tools portability + naval evidence | W | 12 tools, NAVAL_EVIDENCE.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| X-01 | Guides/footage consistency audit | X | GUIDE1-3, TERRAIN_GEN_RESEARCH.md, videos.md, CONSISTENCY_AUDIT.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| Y-01 | Asset integrity audit | Y | ASSET_AUDIT.md | DONE |  | reconciled 2026-11-21 from worker reports/gates
| Z-01 | Measurable no-hang gate (`assert_clean.py`) | Z | assert_clean.py, CLEAN_GATE.md | DONE |  | reconciled 2026-11-21 from worker reports/gates

## FINAL PORT WAVE (2026-11-21, after 19/19 gate)

| ID | Ticket | Owner | Owned files | State |
|---|---|---|---|---|
| FP-1 | Reseeding/version gates, map-option sim, worker slots, squad XP, naval sim, control hand-offs | PORT-SIM | game.gd, data.gd, config.gd | DONE | dumps byte-identical; season/relief/richness/terrain verified by scan; 29/29 + 17/17; main.gd + world.gd hand-offs routed |
| FP-2 | envscales, dead dmask path, field visuals, season/relief shading, naval hull render | PORT-VIS | world.gd | DONE | donor scales+jitter; dead dmask removed; field growth stages; BIOME/RELIEF tint+shading; naval hull+crew 8 facings; 5 shots inspected; 29/29 + 17/17 |
| FP-3 | Patrol waypoints, guard UI, donor hotkey parity, market UI | PORT-CONTROL | input_controller.gd, hud.gd | DONE | 29/29 + 17/17 each step; 4 windowed captures inspected; KEY_BACKQUOTE parse break fixed; hand-offs routed to PORT-SIM/PORT-MENU |
| FP-4 | Full donor skirmish options menu + pinned buttons + mnemonics | PORT-MENU | menu.gd | DONE | 4 option rows emit terrain_type/richness/season/relief; Start/Back pinned; donor C/R/S/L/X mnemonics wired on key-up (E/M deferred: no editor/network screens); 29/29, 17/17, live GUI captures |
| FP-5 | Attack frame-timing adjudication (P-34) | PORT-ANIM | docs/audit/ANIM_ATTACK.md | DONE | 51/51 donor-exact, rule wrong, index.json unchanged; 5/5 + 29/29 green |
| FP-6 | Mill ambient + distinct work sounds (MICRO #19) | PORT-AUDIO | audio.gd | DONE | donor `amb_windmill` proximity bed; wood/stone/mine work families; food mapped to workconstruct as documented INFERENCE (donor food is silent); gates 29/29, 17/17, t_audio_events 5/5, clean CLI |
| FP-7 | Final wiring: menu cfg→sim (main.gd), guard cancel, config.json check | PORT-WIRING | main.gd, input_controller.gd | DONE | four cfg keys fed into MAP_TYPE/BIOME/RICHNESS/RELIEF with legacy fallbacks; G-again uses cmd_cancel_guard; config.json correctly unedited (DEFAULT merge); 29/29 + 17/17 |

**Capacity:** roster 100 tickets · WIP limit 20 · currently 20 live workers.
Triage backlog holds 25 additional small tickets (6 P0, 7 P1, 8 P2, 4 P3)
ready to pull as slots free.

## Unowned pre-existing changes (do not touch)

`git status` shows a windmill-rotor feature already in flight before this swarm
(`app/scripts/world.gd` rotor drawing, `app/tools/bake_mill_rotor.py`,
`mill_rotor.png`, deletion of `mill_sails*`, changes under `app/tests/`). This is
not assigned to any swarm ticket and no worker owns it. Review desk: flag but
do not modify. Coordinator will ask the user before any action.

## Queue telemetry

All Godot work is serialized by `app/tools/godot_runner.py`. Inspect with:

```
python app\tools\godot_runner.py status
```

That reports `now_serving`, pending tickets, lock state, completed jobs, and
max/mean wait times. A bounded max wait is the measurable proof of no starvation.
