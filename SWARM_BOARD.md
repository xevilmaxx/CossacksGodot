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
| A-01 | Fix failing `build` self-test step | A | game.gd, selftest.gd, data.gd | IN_PROGRESS | regression found by runner smoke job |
| B-01 | Verify L6 `--seed`/`--dump-map`/`scan_map.py` 20-seed pipeline | B | main.gd, scan_map.py, scans/** | DONE (partial sweep) | determinism PROVEN byte-identical seed-7 dumps (SHA256 8F2DCB1…); seed/dump/uitest green; reach 3/3 after radius fix (deep-GEN); 20-seed sweep omitted due to runner churn |
| C-01 | Audit L7 peasant animations; apply DO-L7.06 duration fix | C | anim index.json, sheet_metrics.py, anim assets, docs/UNIT_BAKING_FIX.md (append) | QA | 0.667 → 1.08 s, 1-field diff; docs ownership corrected 2026-11-21 (was assigned in original task but omitted from board) |
| D-01 | Audit L8 transparent building ghost + block rules | D | world.gd, input_controller.gd, hud.gd | IN_PROGRESS | game.gd defects reported, not edited |
| E-01 | Document runner + swarm protocol; fix stale README wording | E | COMMANDS.md, app/README.md, root README.md | QA | GUIDE4 line count 2296 |
| F-01 | Eliminate `quit()`-in-`_initialize()` hangs in test scripts | F | app/tests/** | DONE | headless guard added; F3 jobs ok (1.99s / 11.15s); 0 direct quit() calls remain; N-01 merged here |
| G-01 | Audit AI opponent: expansion, waves, chat spam, stuck states | G | ai.gd | IN_PROGRESS | CLI 60 s soak required |
| H-01 | Audit menu/scenes flow; optional seed UI field | H | menu.gd, scenes/** | IN_PROGRESS | no main.gd edits |
| I-01 | Cross-check mechanics.json / MECHANICS.md against code | I | mechanics.json, MECHANICS.md | IN_PROGRESS | read-only on .gd files |
| J-01 | Audit nav.gd AStarGrid2D API usage | J | nav.gd | IN_PROGRESS | no new standalone scripts |
| K-01 | Make asset-pipeline tools cross-platform | K | copy_assets.py, convert_models.py, bake_sprites.py, compute_ortho.py | IN_PROGRESS | preserve Windows defaults |
| L-01 | Audit audio wiring and missing sound assets | L | audio.gd | IN_PROGRESS | CLI 60 s log check |
| M-01 | Review all completed diffs; block protocol violations | M | none (read-only) | ASSIGNED | review desk |
| N-01 | Feature-request intake → prioritized backlog with acceptance criteria | N | SWARM_BACKLOG.md | ASSIGNED | triage desk |
| O-01 | Run full acceptance suite; sign release report | O | QA_REPORT.md | ASSIGNED | QA desk |
| P-01 | Fix self-test step `wall` ("stone wall missing") | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-02 | Fix self-test step `shell` (cascades from missing wall) | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-03 | Fix self-test step `peasant_capture` (captured by player 1) | A | game.gd | DONE | resolved by A-01 work; R-01 selftest confirms pass |
| P-04 | Fix self-test step `farm_cap` (farm 475 → 475 → 475) | unassigned | game.gd | BLOCKED | separate root cause |
| P-05 | Remove donor-derived scratch from res:// | AB | `_mill_tmp/**`, bake_mill_rotor.py | MERGED INTO P-09 | user wants the whole mill-rotor feature finished |
| P-06 | Fix damage-protection off-by-one: `data.gd:235` WK is 1-based but `prot` arrays are 0-based 6-slot; `data.gd:916-919` `prot[pi]` reads the NEXT slot for every kind, and `firearrow(6)`/`cannonball(7)` are out of range → no protection at all | unassigned | data.gd, game.gd | BLOCKED | deep-SIM CONFIRMED + broadened; e.g. pikeman arrow hit uses prot[5]=40 instead of prot[4]=6; line numbers in old ticket stale; needs donor `_misc_DoDamage` reference + one selftest per weapon kind |
| P-06b | `.osm` reader "bug" | none | bake_sprites.py / bake_naval.py | CLOSED | REFUTED by DC (fnd_7): readers already use correct longs 12/13/14, byte-identical output; only stale comment in bake_naval.py fixed by AC |
| P-07 | Raw donor `.dds`/`.lib`/`.mat` git exposure | none | git index, .gitignore | CLOSED | USER DECISION 2026-11-21: leave everything as-is; no action |
| P-08 | 29 donor `.obj/.mtl` meshes on disk | none | app/assets/models/obj/** | CLOSED | USER DECISION 2026-11-21: leave everything as-is; no action |
| P-09 | FINISH the unowned mill-rotor feature (user request) + remove `_mill_tmp` scratch | AB | world.gd, bake_mill_rotor.py, mill_rotor assets, _mill_tmp/** | IN_PROGRESS | user: "its an unfinished feature i want it done"; do NOT touch app/tests/** (F owns until it reports) |
| P-10 | Reopen N-11: port naval units (waiver overturned by evidence) | AC | naval bake pipeline, anim assets, data.gd entries | IN_PROGRESS | 54 readable meshes + 5 readable animated .oss + 24 .aaf; see NAVAL_EVIDENCE.md |
| P-11 | Audit `main.gd` mode dispatch, watchdog and result JSON (R-01 premise correction) | unassigned | main.gd | BLOCKED | B owns main.gd until B-01 closes; testbridge.gd is only the --test-api TCP bridge |
| P-12 | `chop` sound maps to nothing at `main.gd:1065` | unassigned | main.gd | INTAKE | DE decomp: files NOT missing — `workwood1..9.ogg` exist; one-line fix `_play(["chop"])` -> `["workwood"]`; blocked on main.gd owner B |
| P-13 | Nation music only `rus`/`ukr` (`audio.gd:43` via `main.gd:415/564`) | unassigned | audio.gd, audio assets | INTAKE | DE decomp: exactly 20 donor nation tracks absent (`alg,aus,bat1,bav,den,eng,fra,hun,net,pie,pol,por,pru,sax,sco,spa,swe,swi,tur,ven`); add files + fallback theme |
| P-14 | Full donor map options (Terrain/Relief/Richness/Season/Teams) in skirmish menu | unassigned | menu.gd, data.gd, game.gd | BLOCKED | found by H-01; needs sim-layer support; A owns data.gd/game.gd, B owns main.gd |
| P-15 | Literal `"random"` seed string from menu (currently resolved to a random int) | unassigned | main.gd | BLOCKED | one-line change; B owns main.gd until B-01 closes |
| P-16 | Port `.aix` campaign trigger scripts | none | campaign data, menu.gd | DEFERRED | OWNER CHARTER 2026-11-21: missions/campaigns out of scope |
| P-17 | DLC mission-map strategy | none | map generation, tools | DEFERRED | OWNER CHARTER 2026-11-21: DLC missions out of scope |

## Skirmish-first tranche (owner charter 2026-11-21)

| ID | Ticket | Owner | Owned files | State |
|---|---|---|---|---|
| P-18 | Multiple AI opponents / teams on one random map | unassigned | game.gd, ai.gd, menu.gd | INTAKE | owner explicitly asked for "multiple enemies on map" |
| P-19 | Skirmish options parity: relief, richness, season, teams, map size | unassigned | data.gd, game.gd, menu.gd, world.gd | INTAKE | from RC + H-01; random-map fidelity |
| P-20 | Fidelity tranche 1: volley smoke, muzzle flash, arrow trails | unassigned | world.gd, audio.gd, fx assets | INTAKE | RE top visual gap, 4 tickets |
| P-21 | Fidelity tranche 2: shadows, animated water, weather/seasons | unassigned | world.gd, terrain assets | INTAKE | RE gaps 4/6/8 |
| P-22 | Mass-army scale + squad experience/disband | unassigned | game.gd, ai.gd, hud.gd | INTAKE | 200 -> thousands; squads 15-400 already exist |
| P-23 | Skirmish upgrade-tree depth (firepower tiers, bayonet, cavalry, drills) | unassigned | data.gd, game.gd | INTAKE | RB G-02..G-05, ~12 tickets |
| P-24 | Scotland + nation-unique units + 12 baked-but-unwired sprites | A | data.gd, game.gd, anim assets | DONE (partial) | wired cossackdon/hackapell/cossackregister/bagpiper + `sco` nation; 8 national peasants resolve visually. CORRECTION: `buildings.json` has ZERO `sco_*` keys (1506 keys, 20 prefixes) — Scotland uses generic building art; Scottish unique units need a bake outside A's files |
| P-41 | Bake Scottish building sheets + Scottish unique-unit sprites (archersco/lancersco/etc.) | unassigned | anim assets, bake tools | INTAKE | A-01/P-24 correction: earlier RA/RD claim of "14 sco building sheets already baked" was WRONG; real work remains |
| P-42 | Sim-layer support for N players/teams (hand-off `inbox/handoff-P18-agentG.md`) | A / coordinator | game.gd, main.gd, data.gd | BLOCKED | G implemented ai.gd team targeting + menu controls; sim hard-locked to 2 players at game.gd:229 etc. |
| P-43 | Generator emits one start per participant (currently 2, third AI uses fallback) | unassigned | game.gd, pattern_gen.gd | INTAKE | t_multi_ai FAIL check 2, ticket 182; map_starts=2 with 3 players |
| P-44 | Guard AI-facing `say()` calls with `if player == 0:` (chat spam) | unassigned | game.gd | INTAKE | G reported 7 sites (1826, 2154, 2175, 2183, 2321, 2364, 2368); t_multi_ai saw 12x "Not enough resources." |
| P-45 | Adjudicate animation-metric thresholds vs measured outliers | unassigned | anim index.json, test | INTAKE | t_anim_metrics FAIL: 4 single-frame siege idles, 68 foot >0.90 (real measurements, mostly death/walk), 45 walks off n*0.09 nominal, naval index lacks bbox/metrics. Decide which are intentional poses vs defects; do NOT bulk-edit to satisfy the test |
| P-46 | Forest flecks: paint contiguous footprint cores instead of ≤10 scattered tiles (`game.gd:468-475`, amplified ×4 by area_scale) | unassigned | game.gd | INTAKE | deep-GEN A-1: 299-310 one-tile flecks per seed; predicted patches → 8-16; needs one dump+scan iteration |
| P-47 | Cliff ring 0% on seed 9: post-collision `height += 0.25` at `game.gd:487` after collision pass at `:621-642` | unassigned | game.gd | INTAKE | deep-GEN A-2 (attribution inferred): remove write or re-run collision pass after `_gen_patterns()`; predicted 0%→100% |
| P-48 | Clearance 94% boundary case: radius 5→6 at `scan_map.py:74` | unassigned | scan_map.py | INTAKE | deep-GEN B-2; knob already documented in GUIDE4:1168; predicted 94%→100% |
| P-49 | Stale "maps are 160x160" note in `MAPGEN_STATUS.md:71` | unassigned | MAPGEN_STATUS.md | INTAKE | deep-GEN Q; 320 is working size (D-24) |
| P-25 | HUD information fidelity (worker icons, 6 resources, deficit, score) | SC | hud.gd | IN_PROGRESS | RE gap 3 |
| P-30 | Import donor formation bonuses from `formations.cfg` — VERIFIED counts: 149 formations, 137 symmetric, 46 with nonzero bonuses, only **15** with (2,2,7,7), 22 with (1,1,1,1), 3 with (3,3,7,7) | unassigned | game.gd, data.gd | INTAKE | deep-DECOMP refuted DB's "43 / all 2-2-7-7": import the PER-ID 4-field table, not a flat default; 6-8h |
| P-37 | Correct false `bonusdamage 0` claims | unassigned | GUIDE4.md:1131, data.gd:215 | INTAKE | deep-DECOMP: GUIDE4 A04 and the data.gd comment are factually wrong; fix comments only, no behaviour |
| P-38 | Land uncommitted/untracked fixes so a clean checkout keeps them | unassigned | main.gd (chop→workwood), bake_naval.py (untracked) | INTAKE | deep-DECOMP: both fixes exist only in the working tree; needs commit/staging decision by owner |
| P-31 | Stage-level reseeding + generator version gates for true random maps | unassigned | game.gd, data.gd | INTAKE | DB decomp fnd_24: donor reseeds before every stage; port uses one seed; 16-24h, critical path |
| P-32 | Import `envscales.cfg` table (mines 0.3152, stones 0.329, 0.85-1.15 jitter) | unassigned | data.gd, world.gd | INTAKE | DB decomp fnd_26; 4-6h |
| P-33 | Hotkey parity from donor `hotkeys.cfg` (243 bindings) | unassigned | config.gd, input_controller.gd | INTAKE | DB decomp fnd_23: `Data.HOTKEYS={}` today; 8-12h; DE also found gaps |
| P-26 | Animation metrics sweep across 54 keys / 299 actions | SE | anim index.json, UNIT_BAKING_FIX.md | DONE | 8 scalar fixes (national peasant walks 0.667 -> 1.08); selftest 29/29; no rebake |
| P-34 | Attack frame timing (50 actions below `n*0.12`, one-shot fire_t semantics) | unassigned | anim index.json, game.gd | INTAKE | SE finding: systemic; needs dedicated frame-level ticket, not bundled |
| P-35 | Re-capture a genuine L8 ghost screenshot (current `g4_l8_ghost_audit.png` shows only ring + "Not enough resources", no sprite/X) | unassigned | app/shots/, world.gd | INTAKE | deep-RENDER claim 7 CONTRADICTED; code is correct at world.gd:1614-1637; shot predates fix |
| P-36 | Resolve dead `terrain_masks` path (world.gd:645/92, main.gd:850 — assigned but never read by draw code) | unassigned | world.gd, main.gd | INTAKE | deep-RENDER claim 3 PARTIAL; status docs citing "dmask anti-seam" describe non-rendered code; wrong alpha/red-channel comments too |
| P-39 | Decide whether player 1's missing reachable stone (default seed, 160 tiles, 25-tile radius) is a start-fairness defect or acceptable variance | unassigned | game.gd, pattern_gen.gd | INTAKE | t_map_variety FAIL check 5, ticket 163; deep-GEN confirms 25 is correct at 160 tiles, so do NOT blame the radius |
| P-40 | Raise squad cap to donor ladder 15/36/72/120/196/400 (`Data.SQUAD_MAX = 195` caps at 193) | unassigned | data.gd, game.gd | INTAKE | t_squads FAIL check 1, ticket 177; other 4 squad checks PASS (formations, replenish, bonuses, disband) |

## WIP expansion — 20 live slots reached (2026-11-21)

| ID | Ticket | Owner | Owned files | State |
|---|---|---|---|---|
| P-07 | Camera/quality preset audit | P | camera.gd, config.gd | IN_PROGRESS |
| Q-01 | Mapgen/pattern_gen liveness audit | Q | mapgen.gd, pattern_gen.gd, MAPGEN_STATUS.md | IN_PROGRESS |
| R-01 | Test-bridge self-exit audit | R | testbridge.gd | IN_PROGRESS |
| S-01 | Video capture tools portability | S | seq_to_mp4.py, video_build.py, record_session.py | IN_PROGRESS |
| T-01 | Export config + perf.md telemetry | T | export_presets.cfg, project.godot, shots/perf.md | IN_PROGRESS |
| U-01 | Runtime config JSON audit | U | config.json, cli.json, uitest.json, *_patterns.json | IN_PROGRESS |
| V-01 | Credits + waiver documentation | V | CREDITS.md, WAIVERS.md | IN_PROGRESS |
| W-01 | Remaining tools portability + naval evidence | W | 12 tools, NAVAL_EVIDENCE.md | IN_PROGRESS |
| X-01 | Guides/footage consistency audit | X | GUIDE1-3, TERRAIN_GEN_RESEARCH.md, videos.md, CONSISTENCY_AUDIT.md | IN_PROGRESS |
| Y-01 | Asset integrity audit | Y | ASSET_AUDIT.md | IN_PROGRESS |
| Z-01 | Measurable no-hang gate (`assert_clean.py`) | Z | assert_clean.py, CLEAN_GATE.md | IN_PROGRESS |

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
