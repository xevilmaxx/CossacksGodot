# Swarm ticket board

States: INTAKE · TRIAGED · ASSIGNED · IN_PROGRESS · REVIEW · QA · DONE · BLOCKED.
Only the coordinator edits the State column. See `SWARM_OPS.md` for gates.

> [!IMPORTANT]
> **RED GATE RESOLVED (terrain wave):** RELIEF-1 root-caused the 28/29 `build`
> failure to steep positive-rim tiles blocking build spots; fixed with 8-tile
> walkable rims + a start-flatten ring. Jobs 712/713 selftest 29/29, 714 uitest
> 17/17; `scan_map.py` cliff 99/99/98, tileflow 100/100/100, reach 3/3;
> re-dumps byte-identical. Rock coverage 2.3–3.7% remains below the 8–18%
> reference target (deferred, walkability trade-off).

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

## TERRAIN-BEAUTY WAVE (owner directive 2026-11-21 — opened this session)

Owner asked: apply the established swarm logics to **terrain generation** — deep-dive both
the donor implementation and our own terrain recreation (trees, bushes, water, ground assets),
split the work across many micro subagents, parallelise, and improve hills / water / overall
beauty. Quality-first protocol (`SWARM_OPS.md` §5b-QUALITY) stays in force: evidence before
edits, independent re-verification, `observed`/`derived`/`inferred` labels, no "good enough".

**Lane 1 — research / audit (parallel, no runner, read-only on code + assets; each owns ONE doc):**

| ID | Ticket | Owner | Owned files (output docs) | State | Note |
|---|---|---|---|---|---|
| TB-R1 | Donor generator pipeline deep-dive (inc/scripts + generator.cfg) | TDR-1 | docs/audit/TERRAIN_DONOR_PIPELINE.md | DONE | CONFIRMED formula/thresholds; SIGN ERROR in mapgen.gd relief() smooth R=88 (+0.511 vs donor −1.023); R1–R6 UNVERIFIED (no such donor constants) |
| TB-R2 | Donor `.pattern` format decode + full family taxonomy (710 files) | TDR-2 | docs/audit/TERRAIN_DONOR_PATTERNS.md | DONE | int32 w,h + w*h footprint (all 710); no mesh/texture paths embedded; 36 prefix families; 23 donor_patterns.json entries point to missing files |
| TB-R3 | Donor terrain texture + mask asset inventory | TDR-3 | docs/audit/TERRAIN_DONOR_ASSETS.md | DONE | 4,466 donor masks vs 56 port; MAJOR: shipped masks' R/G binary (255 only at starts) → port relief() always 0; winter/desert/deco unwired; no donor foam texture |
| TB-R4 | Donor water rendering deep-dive (water.lib/.mat/textures/shaders) | TDR-4 | docs/audit/TERRAIN_DONOR_WATER.md | DONE | shader-per-frame 9-octave fBm + depth colour + reflection/glints/foam vs port's baked-on-chunk-only; W-1..W-7 proposals |
| TB-A1 | Port terrain render audit (world.gd) | TPA-1 | docs/audit/TERRAIN_PORT_RENDER.md | DONE | BLOCKER: game.gd's donor block map is discarded — world.gd blends only grass1/grass7; shore/cliff oriented art never rendered; water macro-frozen |
| TB-A2 | Port terrain asset coverage (wired / unwired / missing) | TPA-2 | docs/audit/TERRAIN_PORT_ASSETS.md | DONE | 27 winter blocks unwired (tint-only); 7/8 water sheets unused; deco_png preview-only; 20/37 pattern families unwired; all 691 PNG have .import |
| TB-A3 | Port hill / height generation audit | TPA-3 | docs/audit/TERRAIN_PORT_HILLS.md | DONE | height formula + smoothing faithful; shape is the problem — 4 round paraboloids vs donor ridges/ravines/plateaus; height shading OFF for default plains |
| TB-A4 | Port trees / bushes / decor audit | TPA-4 | docs/audit/TERRAIN_PORT_DECOR.md | DONE | trees = 3 unrotated billboards, no sway (redraw-gated); no bush/stump sprites (rock fallback); only 2/15 forest families reachable |

**Lane 1b — mini-map sample / visual evaluation (owner directive, same session):**
Owner wants a small deterministic terrain sample so we do not regenerate the full 320×320
map on every iteration. All needed objects (hills/rock faces, water/shore, trees, bushes,
rocks, decor) are placed there, and screenshots/videos are compared visually against the
donor reference images in `C:\Users\Maxym.Oboyshev\Downloads\c3\` (units ignored). Target:
similar visual quality. Reference analysis and harness design run in parallel with Lane 1.

| ID | Ticket | Owner | Owned files (output docs) | State | Note |
|---|---|---|---|---|---|
| TB-V1 | Donor reference-image visual target spec (all 12 c3 images, units ignored) | TS-1 | docs/audit/TERRAIN_REFERENCE_IMAGES.md | DONE | measured: ravine rock 8–18% area, olive grass ≥4 tonal patches/200², ≥3 crown colors × ≥3 size buckets; primary target cossacks-3-v1-498085.jpg |
| TB-V2 | Mini-map sample harness design (reuse real renderer, fixed seed/contents, capture + compare) | TS-2 | docs/audit/TERRAIN_SANDBOX_PLAN.md | DONE | approach (c): new app/shots/terrain_sample.json → 64×64 med/hills/fixed seed via windowed --screenshot; ZERO existing code changes, runner-safe |

**Lane 2 — build (opens after Lane 1 lands; no speculative edits). Staged by owner directive:**

1. **Stage 1 — mini-map first.** First build ticket is the harness itself (TB-B0, from the
   TB-V2 plan), then iterate visual fidelity on the *sample only* — rock-walled hills/ravines,
   water + shore, varied trees/bushes, ground texture, shading — until it meets the TB-V1
   reference acceptance criteria. No full-map generator edits in this stage.
2. **Stage 2 — keep it permanently.** The sample is a committed, fast regression / quick-test
   tool: a fixed runner command produces a PNG + side-by-side comparison sheet. Every later
   terrain change must re-capture it. It is never deleted or demoted to scratch.
3. **Stage 3 — full map generation.** Coordinator decision (this session): the narrow stamped-relief
   ticket is opened EARLY because the sample cannot pass the ravine criterion without generator
   work. All other full-map edits remain gated on the sample's visual pass. `scan_map.py` gates
   apply to the early ticket as normal.

Coordinator triages into small, independently assignable tickets with **disjoint file
ownership** (candidate owners: `world.gd` → one render builder; `game.gd` → one sim builder;
`pattern_gen.gd` / `mapgen.gd` → one generator builder; `data.gd` → options; `scan_map.py` →
QA). Builders back up before edit, run every Godot job through `godot_runner.py` with unique
ids, and pass 29/29 + 17/17 before REVIEW. Build tickets TB-B0/TB-B1… are added below on
triage — no file is assigned to two active tickets.

**Coordinator handoff / full triage:** `docs/audit/TERRAIN_BEAUTY_TRIAGE.md` — consolidates all
10 Lane-1 reports into ranked root causes, a strict disjoint-ownership map, and staged tickets
TB-B0…TB-B10. Read it before picking up any terrain ticket.

### Lane 2 — build tickets (Stage 1)

| ID | Ticket | Owner | Owned files | State | Note |
|---|---|---|---|---|---|
| TB-B0 | Mini-map sample harness: 64×64 config + capture/compare tools, capture real PNG | BUILDER-CAPTURE | app/shots/terrain_sample.json (new), app/tools/terrain_sample_shot.py (new), app/tools/terrain_compare.py (new), generated shots | DONE | runner tbb0-605..609 all ok, 0 orphans; REAL 1280×720 GPU capture (NVIDIA path); seed 9 chosen but gate 6 FAILED (rock 1.51%<3%, forest 4.71%<5%); smoke scores invalid (crops not feature-aligned, building vs ravine) |
| TB-B0b | Clean terrain-only screenshot frame (hide HUD, no town-hall preselect, map-centred camera) — screenshot-mode gated only | BUILDER-MAIN | app/scripts/main.gd (+ backup) | DONE | jobs bmain-610/611/612 ok, 29/29 + 17/17; `terrain_sample_clean.png` 1280×720 real GPU, HUD gone, right-band near-black 0.02% (was 0.09%); non-screenshot modes unchanged |
| TB-B0c | Re-capture clean sample + feature-aligned comparison | BUILDER-CAPTURE | owned harness files + generated shots | DONE (final) | permanent samples: `terrain_land.png` (start/trees), `terrain_relief.png` (ravine), `terrain_sample_128.png` (water), + 3 contact sheets. Feature-aligned smoke scores ~0.85–0.89, NOT fidelity gates |
| TB-B0d | Frame large samples on start/town-hall + `gameplay.screenshot_focus=relief` | BUILDER-MAIN | app/scripts/main.gd (+ backups) | DONE | small maps map-centre; ≥96 town-hall; relief mode scans `game.height` for deepest 7×7 window, skips water, clamps camera. Jobs 676–728; 29/29 + 17/17 |

### Stage-1 verdict (coordinator, final captures 729/730)

**PARTIAL PASS.** Achieved: mixed conifer/broadleaf canopy with size/yaw variety + understory
(trees absent → visible); donor tile-block atlas + oriented shore/cliff art; animated GPU water
with depth colour/glints/foam; stamped plateau/ravine relief (rock 2.3–3.7%, anisotropy 1.4–1.6);
perf gate green (50.06 ms max vs 250 ms); 29/29 + 17/17; byte-identical dumps.
**Still below donor reference:** rock area 2.3–3.7% vs 8–18% target; blocky stair-step tile edges;
repeating rock texture; water glints too dense/uniform; ravines not in the start-framed view (hence
the separate relief sample). Full-map work beyond TB-B5 remains gated on these visual residuals.

### Cross-agent reconciliation (quality-first rule 2 — independent verification)

- **TDR-1 vs TDR-3 on mask relief:** TDR-1 read `generatemap.inc` decoding R=255/96/48 relief codes;
  TDR-3 measured all 1,331 shipped `_gauss` masks and found R/G binary, 255 **only** at white
  start markers (R255==G255==white count), with port PNGs pixel-identical to donor TGA.
  **Reconciled:** the donor *script* supports relief classes, but shipped random masks carry no
  relief codes, so `mapgen.gd.relief()` returns 0 on real maps. Donor hills therefore come from
  **stamped hill/ravine patterns**, not mask R. TDR-1's exact relief mapping is still a correct
  script-faithfulness fix but has **no visual effect on shipped masks** — do not spend a Stage-1
  slot on it. Where the donor's relief values live is `UNVERIFIED` (TDR-3 open question 1).
- **Foam:** TDR-3 refuted the assumed shore-foam texture family (0 matches across all donor
  `data\`). Shore look = `sandsea1..6` tiles + water shader + DLC5 coastal/lakes/rivers masks.
  TDR-4's procedural foam proposal is a *port-authored* approximation, not a donor port.

## T2 PIECE-LANE WAVE (owner directive, this session — new strategy)

Owner verdict: full/small-map terrain graphics are still FAR from the donor. New bottom-up order:
1. Render **single pieces** headlessly (water, shore, shore+water, plain grass, grass with trees,
   grass with stones, ravine face, etc.) — invent all useful combos.
2. Verify each piece's textures/sprites against donor truth BEFORE composing anything.
3. Only when pieces are right → small map → then FULL map saved as a whole-map PNG for direct
   confrontation. **FINAL OWNER RULE:** map_w/map_h are CELL counts; each cell is a terrain tile
   rendered at tile texture size (owner example 64×64 px). Therefore PNG = `map_w*tile_px` ×
   `map_h*tile_px` (e.g. 320×64 = 20480×20480 at tile_px 64). `--tile-px 1` is only a compact
   diagnostic. 4k was an example; one-pixel-per-cell was my misreading, both corrected.
4. Prefer headless/Python rendering; interactive Godot is not required for piece tests.
5. Water effects are explicitly NOT acceptable yet — dedicated deep investigation + re-port lane.
6. Also investigate the reported minimap left-click jump slowness + first-seconds graphical glitches.

Lane T2-INFRA (harness/tools), T2-PIECE (one spec per piece, disjoint docs), T2-WATER (water re-port),
T2-NAV (minimap perf) all run in parallel. Also added on owner report: **mine display** (mines render
wrongly and `test*` placeholder tiles appear on terrain) → `docs/audit/PIECES/mines_display.md`.
Each agent owns exactly one output path; see triage addendum `docs/audit/TERRAIN_BEAUTY_TRIAGE.md`.

**T2-INFRA-2 DONE:** `app/tools/full_map_shot.py` produces the canonical whole-map PNG at
`map_w*tile_px × map_h*tile_px` (default tile_px 64 → 20480×20480, 152.8 MiB, streamed row-band
writer). `--tile-px 1` gives a compact 320×320 diagnostic. Runner job t2full-dump/732 ok.
CAVEAT: diagnostic compositor from real port blocks/tileblock placement, NOT the exact in-game shader/lighting.

**T2-WATER-2 result (done):** `docs/audit/WATER_PORT_FIX.md` — root cause D1 texture aliasing
(1024² wave sheets sampled at 3.8–35 texels/pixel, `filter_linear` + mipmaps off) → port ACF lag1
0.27–0.47 vs donor 0.73–0.80; D2 glint ×8/×4 with corona as multiplier; D4 α floor 0.35 exposing
flat teal ring; D5 cyan colour. 11 concrete parameter changes with measured targets.

**T2-WATER-1 result (done):** `docs/audit/WATER_REPORT.md` — full donor equation transcription,
18-row gap table, replacement shader plan. Corrected: `.dev` shader pair ships; `heightmapwaves0.tga`
has constant alpha 255 so is NOT the height source (engine supplies it); `reflectionMap` is
projected/screen, not the static cubemap. Build agent to be assigned after WATER-2 measurements land.

**T2-WATER-3 result (done):** recommends keeping/hardening approach A (canvas_item overlay) with
bind-time baked proxies; rejects screen-texture reflection, cubemap, and pure procedural fBm. Its
645 ms perf figure is the OLD baseline — current gate is **50.06 ms PASS** (job 656). It corrected a
prior assumption: `hint_depth_texture` IS supported in Compatibility, just irrelevant to a 2D scene.

**T2-NAV result (done):** minimap left-click is O(1) and the camera jumps in one frame; the slowness
and first-seconds blank quadrants come from `_build_chunk` amortization (2 chunks/frame, no fallback),
not hit-testing or stale fog. Fix proposals: centre-out bake queue, no-hole fallback, camera clamp on
jump, per-frame minimap box. NOTE: its cited 645 ms perf number is the OLD baseline; current gate is
**50.06 ms PASS** (job 656) after RENDER-1 optimisation — the mechanism still stands, at lower cost.

**T2 rock conflict RESOLVED (quality-first rule 2):** `rock_striation_arbitration.md` — all 9 port
PNGs are byte-exact RGB copies of donor DDS; the two docs measured different frequency bands.
VSI (vertical striation index): rock1 4.29 strongest; rock8 1.66 fine flutes on coarse olive fill.
Verdict: layer **rock8 face fill + rock1 flutes/shading**; rock2/3/5/6/7/9 unsuitable.

**T2-DECALS DONE:** `docs/audit/PIECES/donor_decals_and_masks.md` — 469 donor DDS (all DXT5/RGBA,
readable); DXT5 alpha = coverage/opacity, NOT a data ramp; envfieldd/w share one alpha; 226 winter
`dw` plates unwired; U1–U6 proposed uses + explicit non-uses. **Alpha conflict RESOLVED:** `decal_alpha_arbitration.md` — all 7 deco_png are colorType 2 RGB
(no alpha at all); donor envfieldd/w alpha footprint exactly (17,19,494,494); port RGB is
byte-identical to donor RGB, only alpha dropped. `field_crops.md` was wrong on file format but right
on footprint loss. Fix = regenerate 7 PNGs via `copy_assets.py:44-57/121-127` (colorType 6).

**T2 piece-spec results so far:** `grass_plain` (grass1 donor-exact; mandated grass6+grass9 stack is
20–40 L too dark — corrected recipe in doc), `grass_mottled` (terrain-driven ±25–35 L gain mandatory),
`shore_sand` (sand threshold -0.05→-0.1; whole outer water ring wrongly converted to sand; dry sand
base; wrong sector windows; stair-step edge), `ravine_face` (donor 17.3–17.9% rock vs port 3.7%; rock8
art already correct; render-only visual face-collar at height step ~0.25 proposed, no buildability
change), `mines_display` (ROOT CAUSE: game.gd:593 mine apron→terrain=1 → test2/test3 ~50% of footprint;
world.gd:1663 draws generic rock not mine sprite; test*.dds are real soil textures, not placeholders),
`desert_variant` (12 donor palettes; port flat tint; rock_landstone1 is green mossy, needs dry grade),
`shore_rock` (rock1/rock4/rock8 aspect table; striation conflict → T2-ARB-ROCK), `hill_ridge` (donor
g_hil1 aspect 1.69; port relief uses bbox only, ignores mask occupancy, and slope 0.165 < 0.5 cliff
threshold → green flanks, 0.09% rock disc). `plateau` (stamps stack to h=7.25 vs donor 2.964; 8-tile walkable ramp, no rock face),
`shore_water_transition` (donor foam DOES exist; clean shallow #A8B1AB not #696B65; port has ZERO
wash band — collar wet=0 + shader discard), `forest_broadleaf` (tree_oak is saturated chartreuse
sat 0.97 vs muted olive-lime; only 14% broadleaf). These become build tickets after the piece renderer lands.

**T2-INFRA-1 DONE (upgraded):** `app/tools/terrain_piece_render.py` — deterministic headless Pillow
renderer, now with `patches` (terrain-driven ±L olive gain), `face` (rock8 fill + rock1 flutes, hard
rim, lit/shadow ramp), `glaze` (luminance-masked cool tint), shore `bands`/foam/contour, `opacity_mask`,
`brightness`, `native_render`/grain preservation. All previous piece hashes unchanged (backward compat).
Honest limits: face is a 2D visual proxy (geometry criteria stay UNVERIFIABLE); no true specular/sun.

**T2 re-verification wave:** all four verify agents re-render pieces on the upgraded renderer.
- WATER DONE: shallow 2→3 PASS (bands now correct: sand 36 px, wash 34 px); glints unchanged (no
  headless sun vector). Remaining fixes are in-engine → T2-BUILD-WATER.
  **Coordinator palette decision:** `#C3D1CA` is the hard gate (clean crop); `#696B65` was from a
  minimap-border-contaminated crop and is retained only as a flagged legacy design anchor.

**T2-BUILD-WATER DONE:** exact donor shader re-port — deep colour within 1.6 levels/channel,
ACF lag1 0.04→0.67, glints 0% (matches donor), perf 48–71 ms PASS, 29/29 + 17/17. Fixed a 4× mask
scale bug. Remaining: shoreline band flat teal = chunk-bake substrate (→ RENDER owner).

**BUILD WAVE:**
- ASSET DONE: decal alpha restored (7 PNGs colorType 6, byte-exact donor alpha); 33 decor sprites
  blue-lifted after root cause = Blender AgX crushing blue to B≈7 → Standard/sRGB + donor-derived lift;
  all 66 colour measurements pass, 73 PNGs regenerated, no donor binaries added. py_compile clean.
  Follow-up: blue trunk artifact fixed — foliage-only lift; oak trunk B/G 1.53→0.78 (donor 0.74),
  canopy lit B 44.3 retained, all 33 sids × 2 sizes PASS. 38 tree PNGs regenerated.
- GEN IN_PROGRESS (game.gd/pattern_gen.gd): mines, sand+sector fold, density, relief clamp, winter.
- RENDER DONE (world.gd non-water, +415/−66, backup T2RENDER): shore collar RGB (104,94,65)→(155,166,151)
  flat teal gone; grass std 24→31.1 (target 30–40); forest 1,953→949 trees/MP (target 650–1000);
  field decal wired with donor alpha; ravine face-collar 0.25 threshold. Gates 29/29+17/17, bench
  219.47 ms PASS (tight headroom). Gaps: rim 8px not ≤3px, mine marker needs focused shot. Captures
  t2render_land/relief/shore2.png. Report docs/audit/T2RENDER_REPORT.md.
  Shore tone-down DONE: near-white halo gone; wash 21–39 px (3/4 transects in 30–50 band), RGB
  138–164; bench 220.6 ms PASS; t2render_shore3.png. NOTE: current selftest 28/29 `build` failure is
  attributed to concurrent GEN game.gd edits — GEN must restore 29/29 before wave closure.
  **Visual review (coordinator):** striated ravine walls + grass tonal variation are real gains, but
  shore is now an over-bright white glow (needs narrower/darker 3-band) and tree trunks look blue
  (blue-lift hit non-canopy pixels). Follow-ups assigned to RENDER and ASSET owners.
- GEN DONE (game.gd/pattern_gen.gd, backups T2GEN): mine test2/test3 in footprints 190/48→**0/0/0**;
  sand threshold -0.1 + donor 8×45° sector fold + 3 sandsea tiles (rim 2803→1277); forest coverage
  0.94→5.7% (capped by scan_map 8–16 patch gate → T2QA recalibration assigned); relief clamp max h
  8.07→2.964, stacking 13068→0, flat 24.9→62%, PCA aspect 1.49→2.45–3.18, ravine 0.65→2–4.8%,
  start keep-clear 0. Gates 29/29+17/17, scan all green, bench 202.08 ms, dumps byte-identical.
  `--check-only` jobs HUNG in this environment (even on untouched data.gd); parse validity proven by
  selftest loading all scripts. Winter alias data exposed for world.gd owner.

**T2QA scan recalibration DONE:** `scan_map.py` patch gate 40–90 / mean 170–1228 at 320², derived
from donor stamp counts (115–236) and area scaling (`SCAN_CALIBRATION.md`). Degenerate maps rejected.
GEN dumps now correctly RED (patches 9–16, coverage 5.1–5.7% vs 15–48%) — a real generator gap, not
calibration. GEN sent back to raise coverage to ≥15% with 40–90 patches.

**T2-VERIFY-GEO DONE:** `app/tools/terrain_geometry_verify.py` — dump-based CLI with --baseline
before/after and per-metric PASS/FAIL/UNVERIFIED. Measured 320² dump: plateau max h **8.07** vs donor
ceiling 2.964, 13,068 stacking cells, flat fraction 24.91% vs 55–65%, ridge aspect 1.08 vs 1.5,
forest 0.94% vs 17–48%, start keep-clear 0 (PASS). Numbers fed to T2-BUILD-GEN as targets.

**T2 verification wave:** T2-VERIFY-SHORE / -RELIEF / -DECOR / -WATER convert accepted specs into
JSON, render real piece PNGs, measure criteria and write `verdict_<group>.md`.
- SHORE v2 DONE: 1/20 → **20 PASS / 1 FAIL** after renderer upgrade (bands 47/73/268 px @720p,
  foam 1,266 specks, rock anisotropy 3.75, rim 2 px, lit/shadow 1.82). Sole remaining named fail =
  donor 8-sector fold / 3 distinct sandsea1/5/6 tiles → appended to T2-BUILD-GEN (game.gd:1210-1226).
- WATER DONE: glints 0% in tool (tool limit) + shallow 8 FAIL/2 PASS; exact shader fixes in verdict doc.
- DECOR v2 DONE: 18/30 → **29 PASS / 19 FAIL** after renderer upgrade (desert 7/1, field 4/2,
  bushes 6/1, conifer 3/5, broadleaf 2/6, mines 3/4, stones 4/0). Genuine remaining: sprite blue-lift
  REBAKE (proxy tints leave halos), field alpha restore at conversion + wire, 4 mine fixes, density.
- RELIEF v2 DONE: 12/24/10 → **22 PASS / 15 FAIL / 9 UNVERIFIABLE** after renderer upgrade
  (grass_plain 10/0, grass_mottled 4/4, plateau 1/1/6, hill 2/5, ravine 2/3/3, winter 3/2).
  Genuine remaining: mottled gain overshoot, ravine flute anisotropy, hill cap/flank inversion,
  winter wiring, and a HEIGHT/DUMP VERIFIER for geometry criteria (still UNVERIFIABLE from PNG).

**T2-DENSITY DONE:** `docs/audit/PIECES/map_density.md` — port forest covers only **0.94%** of the
map (10 components) vs donor 17–48% — an 18–50× COVERAGE gap. But per-cell detail is 1,953 trees/MP
(2–3× donor) — so fixes must ADD forest cells/clumps and THIN per-cell density, not add trees to
existing cells. Root cause: pattern_gen.gd:279 collapsed 7 families to base=1; game.gd:523 caps each
stamp to a ≤4.5-tile disc, discarding donor footprints. Also ≥14× per-start resource asymmetry.
F1–F6 proposals with gates (≥100 stamps, ≥15% coverage, ≥40 patches, 650–1000 trees/MP).

**Wave size:** 25 research/infra micro-agents in the T2 batch, 4 verification agents, 1 density audit,
1 decal-alpha arbitration, 1 rock arbitration, plus the water build and renderer upgrade now.
They report asynchronously; later waves will convert accepted specs into rendered pieces, then combos,
then small map, then the 4k full-map confrontation PNG.

## T2 WAVE CLOSE — final validation (coordinator)

- Fresh 320² dump (`final_fullmap_dump.json`, runner 876) → canonical PNG
  `app/shots/final_fullmap_20480x20480_tile64.png` (20480² RGB, 185.1 MB, streamed, sidecar with
  assertions). Diagnostic compositor caveat applies (no Godot shader/lighting/sprites).
- `scan_map.py` on final dump: **ALL GREEN** — dark 45.6%, rock 6.8%, patches 75, mean 622,
  coast 100, cliff 96, tileflow 100, reach true.
- Geometry verifier: PASS 12 / FAIL 5 / UNVERIFIED 6 — the 5 FAILs are stale/misaligned rows
  (patch target still 8–16 vs authoritative 40–90; `blocked[]` byte-identity no longer applies because
  GEN legitimately changed relief; trees/MP counts dump nodes, not rendered per-cell detail).
- Gates across build wave: selftest 29/29, uitest 17/17, bake bench 196–221 ms (<250), determinism
  byte-identical, 0 orphan Godot processes. `--check-only` jobs hung environment-wide; parse validity
  proven by selftest loading all scripts.
- Final sample captures: `terrain_land.png` (trees/brown trunks/fields/ravine), `t2render_relief.png`,
  `t2render_shore3.png`, `water_t2.png`, plus 17 piece PNGs under `app/shots/pieces/`.
- HONEST STATUS: measurable fidelity improved substantially, but still NOT donor-equal — grass gain
  is coarse blotchy, shore water still has cellular veins, ravine rim 8 px not ≤3 px, water lacks
  reflection/9-octave FBM, and the full-map compositor omits real shader/lighting. Further work needs
  a new wave, starting with the remaining piece-proxy failures and full in-engine comparison.

## R-ARCH WAVE — SYNTHESIZED (owner decision pending)

Final decision doc: `docs/audit/RENDER_ARCH_SYNTHESIS.md`; full CA report with 159 evidence records:
`docs/audit/RENDER_ARCH_CRAFT_ANYTHING_REPORT.md`. Verdict = donor is 3D OpenGL, perspective camera,
lit heightfield, live skinned meshes, GLSL shaders; 2D port structurally cannot match. Recommendation:
keep 2D, add optional `render_mode=2d|3d` with terrain-only M0 sandbox as the FIRST visual gate
(16×16 tiles, ArrayMesh from height, donor blocks as albedo, Camera3D, DirectionalLight3D, spatial water).
M1 objects / M2 input-HUD / M3 animated units / M4 mode switch only after M0 is visually accepted.
**R-ARCH-REFLECT DONE** (`docs/audit/RENDER_ARCH_REFLECTION.md`): decals are NOT reflections;
`materials/ref` = reference/template. Donor water = live PROJECTED texture (texture2DProj + wave jitter,
WaterReflection option); objects = static cubemap_c00..05 (128² BMP). Sampler→texture-unit binding still
in cossacks.exe (UNVERIFIED). Recommendation: M0 water should use hint_screen_texture projected proxy,
not cubemap; cubemap deferred to licence-reviewed ticket. Follow-up sent to M0-3D.
**3D BRANCH CLOSED (M0.6 VISUAL FAIL — agent and coordinator agree).** M0.6 restored the −32° tilt,
padded the mesh to 32 tiles so no border shows, fixed wall normals (cliff-band metric 2921→0, though
strips remain visibly lighter), ground luminance 80.65, seam gaps 0, 78 draw calls / 16 ms. Yet the
capture STILL reads as a flat top-down tile mosaic, not the donor's oblique eroded landscape. Root gap
is fundamental: donor depth comes from organic eroded relief + scene content (trees, shadows, units),
which a donor-block heightfield cannot supply at this stage. Decision: KEEP THE 2D PATH as shipping
renderer; 3D sandbox files remain as documented experiment only. No M1–M4.

**M0.5 RESULT (coordinator rejected agent's "visual pass"):** `terrain3d_m05.png` matched donor luminance
(78.3 vs 76.9) and closed seams 2284→0, but visually it is a FLAT TOP-DOWN tile mosaic with a hard
rectangular border and horizontal dark cliff bands — not the donor's oblique landscape. The 6× height /
2.9° FOV flattened the perspective (wrong trade-off). M0.6 assigned: restore −32° oblique tilt, choose
FOV/distance that keeps it, pad/feather the patch border, fix cliff-band lighting; if it still fails,
STOP the 3D branch. No further iteration after M0.6.

**M0-3D DONE (mechanism PASS, visual FAIL — honest):** new files only; 16×16 heightfield ArrayMesh
(1,684 verts / 842 tris / 31 draw calls / 0.0 m height error), perspective Camera3D tilt −32°,
DirectionalLight3D + shadows, spatial water material; real runner capture `terrain3d_sandbox.png`
1280×720. Visually DARK, low-contrast, blocky terraced patch with seam gaps, no sky/trees/units —
NOT closer to the donor still than 2D. FOV assumption UNVERIFIED (216mm sensor → 17.27° vs 36mm → 2.9°).
Reflection proxy skipped (deferred M1). Next: M0.5 art pass (FOV calibration, exposure/tonemap, close
seams, sky/background, water) BEFORE any M1 object work; if M0.5 still loses to 2D, stop 3D.
Process rule: donor-paradigm-first, visual A/B before code, metrics never override visual review.

## R-ARCH WAVE (owner: understand donor rendering paradigm, use Craft Anything, more investigation)

Craft Anything session re-briefed to the 2D-vs-3D-ortho question; hypothesis `hyp_1` recorded
(donor = low-poly 3D ortho with textured ground/water shaders; 2D port cannot reproduce it);
6-step plan set; handoff written. Sole CA user R-ARCH-CA; others read donor files directly.
Eight parallel agents: CA subsystem analysis, camera projection, terrain representation, unit meshes,
shaders/lighting, pattern placements, port 3D-mode feasibility, and a candid retrospective
(RENDER_ARCH_WHY_WE_FAILED.md) answering whether the blocker was decompilation, understanding, or scope.
Outcome feeds an owner decision on adding a selectable 2D/3D render mode before skirmish.
- R-ARCH-CA RESULT: donor is a low-poly 3D OpenGL renderer (hyp_1 SUPPORTED, fnd_27–33, CA evidence
  ids). Live renderer = OpenGL 1.x (D3D9 imported but 0 xrefs); decompiled projection switch has
  glFrustum/glOrtho/gluOrtho2D(HUD); RTTI XCamera/XWorld/XTile/XLightShader/XShadowMap/XWaterShader;
  109 GLSL shaders (heightfield, Blinn-Phong, TBN normal maps, 9-tap PCF shadows, HDR, SSAO/FXAA/DOF).
  Unknowns: which projection branch drives the main view (camera cfg points to perspective), D3D9 dead
  or live, heightfield resolution. Doc docs/audit/RENDER_ARCH_CRAFT_ANYTHING.md.
- R-ARCH-CAM RESULT: donor camera is TRUE PERSPECTIVE (focal 400, tilt −32°, height 20–58, ccmRTS);
  no ortho parameters exist. Port is Camera2D; stored −32° pitch is dead config. Switching is a
  cross-cutting rewrite (picking/minimap/HUD/sprites), not a node swap.
- R-ARCH-SHADERS RESULT (`docs/audit/RENDER_ARCH_SHADERS.md`): 109 GLSL files (47 vert/58 frag), vertex
  stages use gl_Vertex/gl_NormalMatrix/gl_LightSource[0]/boneMatrices[16]; fragments Blinn-Phong,
  shadow2DProj PCF 3/9-tap, TBN normal mapping, textureCube, eye-plane texgen, depth fog; post chain
  uses depth texture for SSAO/DOF/FXAA. Port = 1 canvas_item shader + CPU Image chunks → shadows,
  normal maps, reflections, skinning, depth post are structurally impossible. P0–P3 Godot Spatial
  mapping plan provided.
- R-ARCH-UNITS RESULT (`docs/audit/RENDER_ARCH_UNITS.md`): donor meshes decoded with exact size closure
  (yacht.osm 9364v/7731f, enghou.osm 7587v/5339f, trees 2 geometry states), skinned .oss 20 bones /
  483 frames @30fps, NO pre-rendered entity sprite sheets, yaw = renderer transform. Port bakes 8
  azimuths (units) and ONE fixed view (buildings) via CPU Cycles ortho 32°; 116 .obj are bind-pose,
  Z-up, no skinning — animated 3D mode needs a new rig/animation export pass.
- R-ARCH-PORT3D RESULT (`docs/audit/RENDER_ARCH_PORT_FEASIBILITY.md`): sim/generator/AI/orders/HUD/
  minimap/save-load reusable verbatim; seams = main.gd bind, input_controller.gd picking, hud.gd camera
  box, static C3World/C3Camera typing. Proposed `render_mode=2d|3d` menu flag, world3d.gd/camera3d.gd,
  staged M0–M4 with terrain-only 3D A/B sandbox first. Asset debt: .obj conversions lack normals/anim,
  Z-up, forced-opaque textures — re-conversion needed for 3D units.
- R-ARCH-META RESULT (`docs/audit/RENDER_ARCH_WHY_WE_FAILED.md`): owner's H1 "cannot decompile" REFUTED
  (donor algorithms were plaintext; CA decoded .osm/.oss/.pattern/.map/.aix + RTTI + readable CODE);
  H3 "asked wrong" MOSTLY REFUTED (D-12/D-22 demanded maximum fidelity). H2 "you cannot understand"
  dominant but narrow — we understood then substituted approximations and self-certified with metrics.
  New process rule: donor-paradigm-first, visual A/B gates BEFORE code, metrics never override visual review.
- R-ARCH-TERRAIN RESULT: donor terrain is 3D heightfield — lit `normal` materials with specular,
  explicit verticalfront/verticalside faces, ShadersSM20.HeightField with shadows/fog, elevation
  tile zones, real terrainmesh*.osm. Port composites block PNGs into Image→Sprite2D. Exact match is
  impossible in 2D. Recommendation: Godot 4 Camera3D (perspective or ortho TBD) + ArrayMesh from
  game.height_at() + donor blocks as albedo + DirectionalLight3D; stage as 16×16 A/B sandbox first.

## T5 WAVE (owner's next defect list)

- T5-RENDER (`world.gd`, `camera.gd`): remove sunflower-like field heads (use donor envfieldd alpha +
  vertical stalks), fix mine sprite scale/centring, ~2× larger view, keep ALL chunks in RAM (no lazy
  load) while preserving no-hole fallback. Must keep grid_peak <0.20 and bench <250 ms.
- T5-AI-DIAG DONE (`docs/audit/AI_SURVIVAL_DIAG.md`): military training has NO food-reserve gate;
  mill is 6th in build order with wrong 100 vs 150 stone check; only 35% peasants on food; configured
  AI_FOOD/WOOD/STONE_THRESHOLD constants are dead; famine/wave wipe triggers unearned human victory
  (game.gd:4590). No reproduced failure in old logs — code-path diagnosis.
- T5-AI-FIX DONE (ai.gd, +221/−38, backup T5AI): food-reserve gate before military, mill FIRST with real
  150-stone cost, food share 35→50/62% with ceil, miner recall + field resow, configured thresholds
  consumed, explicit food>wood>stone priority. 3× 300 s CLI soaks: **0 famine ticks**, food min 176–243,
  population 8→17..27, winner -1. uitest 17/17. selftest 23/29 = 5 PRE-EXISTING + 1 fragile resow test
  (AI mill auto-sows a field; test matches by any mill flag instead of mill.id). Army still 0–11 units,
  no waves — pre-existing metal economy limiter. Unearned victory NOT fully fixed: game.gd:4590 still
  uses OR elimination → queued for game.gd owner.
- T5-TESTFIX DONE (selftest.gd +8/−4, backup T5TEST): resow step now attributes fields by mill.id;
  `resow` PASS (auto=21 restored=1, was auto=41 restored=0). Selftest 24/29 — remaining 5 pre-existing
  failures (wall, shell, flee, peasant_capture, farm_cap) reproduced in control with original ai.gd;
  uitest 17/17. No assertion weakened.
- T5-GEN DONE (game.gd/pattern_gen.gd/data.gd/hud.gd, backups T5G/T5MOD): donor SetupMines — every start
  has all 3 ores within 24 tiles, 3–4 quadrants per start, distances 4–116 tiles; richness A/B poor 21
  vs rich 37 ore nodes. Spawn stagger 19 unique tiles for 20 units, spread 14.9×7.0, 20 arrived/0 stuck
  after 60 s. Recruit modifiers plain1/Shift5/Ctrl endless/Ctrl+Shift 5∞/Ctrl+Alt 100(capped 10)/RMB
  cancel. **selftest 29/29 (1016), uitest 17/17 (1022)**, all scan gates green, no new geometry FAILs.
  Note Ctrl+Alt capped at BUILD_QUEUE_LIMIT=10 vs donor 100 — documented deviation.
- T5-SIMREQ IN_PROGRESS (game.gd only, backup T5SIM): change elimination at game.gd:4590 from
  "no buildings OR no units" to AND / grace timer so a famine-wiped army cannot hand an unearned win.
- T5-SELFTEST-FIX RECHECK DONE: NO test edit needed — T5-GEN's gameplay fixes made all 5 legacy steps
  green. selftest 29/29 twice (byte-identical, tickets 1023/1025), uitest 17/17 (1024). Backup retained.
- T5-SELFTEST-FIX rechecking first: T5-GEN's gameplay fixes may have made all 5 legacy steps pass — if
  selftest/uitest are green, NO test edit will be made.
- T5-HOTKEY DONE (`docs/audit/DONOR_RECRUIT_MODIFIERS.md`): owner's guess was REVERSED. Donor = plain
  LMB 1, **Shift+LMB +5**, **Ctrl+LMB endless (-1)**, Ctrl+Shift 5×endless, Ctrl+Alt 100, RMB cancel;
  shipped toggle swaps plain↔Ctrl (default off). Port: Shift currently cancels+refunds, no Ctrl, queue
  always pops. Fix appended to T5-GEN, which now also owns hud.gd for the modifier resolver.
- T5-UNIT-DIAG DONE (`docs/audit/UNIT_RALLY_ARRIVAL.md`): NOT an A* problem — units already use A*.
  Spawns all share one `sp` + one rally target 3 m away; 1.05 m separation vs 0.15 m arrival radius
  jams the column; `sp` can land in the blocked door band. `move`/`attackmove` re-assert moving=true
  every tick and NEVER read stuck_t — no give-up path; blocked rally target not appended to A* path
  while d_goal still measures it. F1–F4 appended to T5-GEN (game.gd); F5 nav.gd optional, F6 world.gd
  optional — both skipped unless needed.
- T5-GEN (`game.gd`, `pattern_gen.gd`, `data.gd`): donor-style SetupMines — guaranteed near-start clusters
  first, then varied map-wide clusters with random directions/distances/counts, scaled by RICHNESS,
  deterministic, preserving mine_mask (no test*) + start fairness. Richness A/B + geometry gates.

## T4 QUALITY REGRESSION WAVE (owner rejection, highest priority — now CLOSED, checkerboard fixed)

Owner: current terrain is a "total checkerboard mess", worse than before; either use donor logic or
revert to last decent version. **All further feature work is on hold.** Full `world.gd.bak-*` chain is
available in `inbox/backup/` (agentAB → T3W, 11 backups).
- T4-REGRESSION (read-only): identify exact change that introduced checkerboard + minimal revert target
  preserving water/mine/field/winter fixes → `docs/audit/TERRAIN_CHECKERBOARD_TRIAGE.md`.
- T4-DONOR-BLEND DONE (`docs/audit/TERRAIN_BLEND_DONOR_PLAN.md`): donor fact = discrete 124-slot TileBlock
  per cell + 3-pass probability-weighted SmoothTileMap (22 chains in tilesmooth_scripts.cfg; port
  smooth_summer.json faithfully copies the 10 Summer chains). Generator is faithful (game.gd:1323-1589);
  renderer is NOT: caps distinct names 3/2, fractional coverage washes rare names to ~25% alpha,
  global grass1 base, fixed role textures, synthetic gain path. Fix = world.gd-only, exact per-cell
  coverage, chunk-dominant base, ≤3 composites, delete gain path. Also 39 preset names have no PNG.
- T4-TEST DONE (`app/tools/terrain_blend_test.py`): terrain-only (no objects) A/B harness with FFT 2D
  autocorrelation grid-peak metric. Measured: uniform **0.113**, donor_tiles **0.064**, current_gain
  **0.651** — checkerboard is now objectively measurable. PNGs blend_uniform/donor_tiles/current_gain.
- T4-FIX-GROUND DONE (world.gd, backup T4G, 113 deletions/0 additions): removed entire synthetic gain
  path (595–701, 1036–1037, 1601–1604), kept mine/field/winter/no-hole/water/face-collar. REAL capture
  grid_peak **0.0964 → 0.0228** (target <0.20); visual = smooth olive meadow, lattice gone. Gates
  29/29 + 17/17, bench 143.46 ms PASS. Captures t4ground_land/relief.png. Clean state saved as
  `world.gd.bak-T4CLEAN`.
- T4-BLEND KEPT (world.gd, +31/−44, rollback target bak-T4CLEAN untouched): BLOCKS_PER_CHUNK 3→6,
  PER_ROLE 2→3, exact per-cell coverage (no 2×2 alpha wash), chunk-dominant donor block as base.
  NO gain/patch/hard-rim symbols remain. Real capture grid_peak 0.0246→**0.0628** (≈ donor-style
  0.064), all crops <0.20, no lattice; visual = organic donor tile patches. Gates 29/29 + 17/17,
  bench **109.16 ms** PASS. Capture t4blend_land.png. This is the current accepted ground state.

## T3 FIX WAVE — CLOSED (but visually rejected by owner — metrics alone were not sufficient)

Four parallel owners on disjoint files, backups + gates required:
- T3-FIX-WORLD DONE (`world.gd`, +265/−69, backup T3W): grass std 30.9→32.6, hi-freq 6.9→8.8 (both
  in donor bands); ravine rim ~8→≈3 px via cached boundary subdivision; 21 winter*.png loaded (0→21);
  no-hole coverage 0→100% with centre-out bake, 2-chunks/frame + LRU 24 kept. Bench 125.05 ms PASS.
  Gates 29/29 + 17/17. Captures t3world_land/relief/winter.png.

**FINAL independent verification (coordinator):** fresh dump (ticket 925) →
`app/shots/FINAL_fullmap_20480x20480_tile64.png` (20480² RGB, 185 MB, sidecar assertions); scan_map
ALL GREEN (forest 45.6%, rock 6.8%, patches 75, mean 622, coast 100, cliff 96, tileflow 100, reach true);
geometry verifier PASS 13 / FAIL 0 / UNVERIFIED 10; selftest 29/29 (ticket 926) + uitest 17/17 (927)
re-run independently. 0 orphan Godot processes.
- T3-FIX-SHADER DONE (`water_overlay.gdshader`, backup T3S): root cause = diffusewaves0 1–3px cell walls
  sampled nearly unblurred (BLUR 0.0015 ≈0.4 texel) → 8-tap ring BLUR 0.0060, octave weights
  0.92/0.06/0.02, gentle swell. Vein proxy 2.96→1.44 (−51%), L σ 11.73→8.12 (donor 8.9), RGB
  (45,55,57) vs (44,53,54), glints 0%, gates 29/29+17/17. Capture t3shader_water.png.
- T3-FIX-NAV DONE (`hud.gd` only — camera.gd needed no edit, clamp already public): camera.clamp_pos()
  + box draw in click AND drag branches; box redraw each frame change-gated; old timer box removed.
  Gates 29/29 + 17/17. REAL windowed minimap click driven via testbridge RPC (t3nav-shot-battle/897):
  camera clamped to Y=3736px, no blank border, viewport box relocated → F2/F3 VERIFIED. F4 deferred
  (would rewrite minimap; fog already guarded).
- T3-FIX-GEO DONE (`terrain_geometry_verify.py`, backup T3G): imports authoritative `patch_gates()`
  (40–90 at 320²); criterion G scoped to render-only changes; trees/MP relabeled as dump-node diagnostic;
  per-seed variance metrics advisory. Before PASS 12/FAIL 5 → **PASS 13 / FAIL 0 / UNVERIFIED 10**.
  Strict-gate regression test still FAILs a flipped blocked[] byte. py_compile clean.

- T5-RENDER DONE (world.gd +192/−69, camera.gd +5, backups T5R): field sunflowers removed (decal-only
  vertical stalks, hue 42.9° in 39–45 band); mine marker exactly 2.0 tiles wide, foot-anchored, olive
  disc stripped; default zoom 1→2 (arch pitch 30→65 px); ALL 100 chunks kept resident via distant
  low-res LOD (<10 MB) with 2/frame full-res upgrade and no-hole fallback preserved. Gates green in
  isolation (29/29, 17/17, bench 172.56 ms, grid_peak 0.088/0.137 <0.20). Captures t5render_land/mine.
  Main-tree selftest transiently red from other workers' concurrent edits — settle in final validation.

**T5-SELFTEST-DIAG IN_PROGRESS** (read-only): diagnose the 5 pre-existing selftest failures
(wall, shell, flee, peasant_capture, farm_cap) — game bug vs fragile test, minimal fix, risk ranking →
`docs/audit/SELFTEST_FIVE_FAILURES.md`.

## FINAL VALIDATION — DONE (settled tree, all green)

- Fresh 320² dump ticket 1034 → `app/shots/FINAL_fullmap_v5_20480x20480_tile64.png` (20480², 185.5 MB,
  tile_px 64, assertions in sidecar).
- scan_map: forest 45.6%, rock 6.8%, patches 75, mean 622, coast 100, cliff 96, tileflow 100, reach true.
- geometry verifier: **PASS 13 / FAIL 0 / UNVERIFIED 10**.
- bake bench (job FINAL-bench/1035): **max_ms 139.64 < 250 PASS**.
- final capture `app/shots/FINAL_land_v5.png` (job 1036): 2× zoom, no sunflower fields, no checkerboard.
- selftest 29/29 (twice byte-identical), uitest 17/17 on settled tree (T5-GEN/T5-TESTFIX/T5-SIMREQ).

## FINAL VALIDATION (queued — run after all T5 owners release files)

Once T5-GEN / T5-TESTFIX finish, re-run on the settled tree: selftest 29/29 + uitest 17/17, scan_map,
geometry verifier, bake_bench, grid_peak on a fresh capture, and regenerate the full-map dump/PNG.
Main-tree selftests were transiently red only because multiple workers edited game.gd/ai.gd/hud.gd
concurrently; isolated worktrees were green.

## Parallel doc lane (owner request, this session)

| ID | Ticket | Owner | Owned files | State | Note |
|---|---|---|---|---|---|
| DOC-R1 | Modernise root README layout + hero image (existing repo screenshot only, no donor assets) | DOC-README | README.md (+ backup) | DONE | hero `app/shots/portvis-final.png`; layout modernised, all claims/links preserved, backup README.md.bak-DOC-README |
| QA-P1 | Measure 120-frame low-preset chunk-bake hitch and record PASS/FAIL vs 250 ms | QA-1 | app/shots/perf.md, app/tools/bake_bench.py (new), app/shots/perf_low.json (new) | **PASS (after remediation)** | final `max_ms=50.06 mean_ms=43.59` (job render1-bench-opt/656) vs 250 ms target; baseline 645 ms |
| QA-P2 | Regenerate Godot `.ctex` import cache for 87 new env sprites | QA-1 | app/.godot/imported/** (generated) | DONE | job qa1-import/638 ok; 385/385 .import entries now have matching .ctex (was 87 missing); exported builds no longer need dev-only fallback |
| QA-P3 | Optimise `_build_chunk` to bring max bake < 250 ms while keeping ≥3 block families | RENDER-1 | app/scripts/world.gd (+ backup) | DONE | JOB render1-bench-opt/656 PASS 50.06 ms; levers: 6→3 / 4→2 composites, bind-time atlas pre-warm, single-pass coverage grids, composite at final res on LOW; 29/29 + 17/17 |

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

## T6 RECURSIVE WAVE (owner directive 2026-11-23 — OPEN)

Owner: analyze done-vs-not-done vs donor; restructure swarm as an infinite
recursive micro-agent tree (parents supervise children, helpers test their own
piece before whole tests); graphics piece-by-piece with many mini-bakers
(terrain first, some units second); water explicitly not acceptable yet;
optional pure-Rust zero-dependency-GUI multiplatform branch in `rustport/`.

- Protocol: `SWARM_OPS.md` §7 (recursive tree, models, supervision, ownership).
- Plan + gap analysis + full micro-ticket list: `docs/T6_WAVE_PLAN.md`.
- Models (D-29, owner): workers PREFER `opencode-go/hy4-flash-free` (opencode
  pool quota-blocked); escalation `opencode-go/muse-spark-1.3-contributor#high`.
  Broadcast to all 6 lanes 2026-11-23. Child runtimes spawn via `opencode run`
  CLI or subagent-session API (no `subagent` tool below coordinator).
- Clean gate: 12 historical timeouts acked by coordinator (D-30); CLEAN re-verified.
- Lane docs: `docs/t6/<LANE>_LANE.md`; worker reports `docs/t6/reports/<ID>.md`.
- Progress: WATER W01 DONE (byte-offset-pinned equation verification,
  `docs/t6/reports/T6-W01.md`) + W03 DONE (reflection = projected sampler2D;
  SubViewport proxy recommended). W02 in progress. TERRAIN 8/15 mini-bakers
  running, piece modules + compare PNGs landing. QA Q02/Q03 verified, Q01
  registry + dashboard building; clean-gate blocker CLOSED (D-30, sweep 2 CLEAN).
  UNITS/RUST/RESEARCH standing up.
- Coordinator visual spot-check (2026-11-23 ~11:00): first staged pieces still
  FAR from donor — ravine reads as wooden fence (uniform striations, black
  outline, zigzag), water has concentric-ring artifact + black shore band.
  Defect guidance relayed to TERRAIN + WATER parents; no piece PASS accepted
  with these artifacts. 0/15 terrain pieces PASS so far.

| ID | Lane / ticket | Owner | Owned files | State | Note |
|---|---|---|---|---|---|
| T6-TERRAIN | Lane parent: 15 terrain piece mini-bakers (T01-T15) | T6-TERRAIN parent ses_df83a3717ffedjlk7Nu0JnxU16 | docs/t6/TERRAIN_LANE.md, lane children per plan | DONE (lane complete) | 12/15 FULL PASS (D-44 confirms T09). INTEGRATION REQUEST filed; lane stopped, world.gd untouched by lane. T90 granted. || T6-T01…T15 | Terrain piece micro-tickets | children of T6-TERRAIN | app/tools/pieces/t6_*.py + own piece docs/shots | INTAKE | see plan §2 table for acceptance criteria |
| T6-T90 | Terrain integration: 12 verified pieces into world.gd/pools (6 scoped groups) | T6-T90 builder ses_df7ba96c7ffe7mSjngwhUibllu | app/scripts/world.gd (exclusive), app/tools/copy_assets.py, regen asset PNGs | DONE | QA Q02 signed PASS: 1074-1080 ok (29/29, 17/17, bench 107.18, scan green, byte-identical, grid_peak 0.1815 indep. re-measured <0.20, W04 water re-measured). Diff: 2 pool constants + stump keying; groups 2-5 verified-already-live. Third completed integration. || T6-U90 | Unit integration (staging to live anim + index.json, assets-only) | T6-U90 builder ses_df7dbc303ffeznoJvbaIPz7L4F | app/assets/models/anim/**, anim/index.json, anim/naval/index.json | DONE | QA Q02 signed PASS: 1062/1063/1064/1066 ok (5/5, 29/29, 17/17, 6/6), scope 88+38 anim-only, 54/1 keys, 0/1849 lossy, zero QA Godot jobs. First completed integration of the wave. || T6-RESEARCH | Lane parent: S01–S05 UNVERIFIED gaps + web | T6-RESEARCH parent `ses_df8396897ffeU2qScHMiE9LLAv` | docs/research/T6_S0*.md, docs/t6/RESEARCH_LANE.md | DONE | all 5 landed: S01 perspective glFrustum confirmed + heightfield 256–640²; S02 bindings statically unrecoverable (honest UNVERIFIED, functional identities); S03 Summer=exact 141-entry copy, Winter=_winter mirrors; S04 7 mechanics gaps (triaged below); S05 fps30 truth, 1.08 stride guard, unbaked actions/mounts. Cross-lane routing sent to UNITS+TERRAIN |
| T6-QA | Lane parent: registry, gate desk, liveness | T6-QA parent `ses_df8393adbffeE3AT4n1abIh5W1` | app/tools/t6_registry.py, docs/t6/QA_LANE.md, DASHBOARD.md | DONE (reactivatable) | Q01/Q02/Q03 delivered, 3 sweeps CLEAN, dashboard live (43 tickets/49 rows); escalations routed: T15 FAIL→TERRAIN, R05-AAF id mismatch→RUST; Q03 periodic sweeps resumed; gate desk idle-watch |

### T6-S04 mechanics gaps — INTAKE (sim tranche, opens after graphics pieces; source `docs/research/T6_S04_web.md`, cited URLs)

| ID | Gap | Priority | Note |
|---|---|---|---|
| T6-M01 | Gold-shortage desertion + ship-stop rule | P1 | donor economy behavior absent from mechanics.json |
| T6-M02 | Iron+coal shortage stops firing | P1 | resource-dependent combat gate |
| T6-M03 | Omitted military research rows | P1 | diff vs donor research table |
| T6-M04 | National unit stat deltas | P2 | per-nation modifiers beyond roster wiring |
| T6-M05 | Naval classes + upkeep | P1 | pairs with P-10/T6-U07 naval port |
| T6-M06 | Production-building siege rule | P2 | capture/siege interaction |
| T6-M07 | Mass-army scale (200 → thousands) | P1 | overlaps P-22; perf-gated |
