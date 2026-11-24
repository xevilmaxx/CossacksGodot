# Session progress — 2026-11-24 coordinator swarm

Living log. Only the coordinator edits this file.

## 2026-11-24 — session start

### Context read (cold-start)
`SWARM_OPS.md` (org, gates, §7 recursive tree), `SWARM_BOARD.md` (ticket states,
T6 wave closed, T5 wave), `SWARM_BACKLOG.md`, `app/tools/AGENT_PROTOCOL.md`,
`RESUME.md`, `STATUS_SKIRMISH.md`, `PERFORMANCE_SWARM.md`, `audit/MICRO.md`
(68 donor micro-features), `DONOR_OPTIONS_GAPS.md`. Donor data tree at
`C:\Games\Cossacks 3\data` confirmed (25 subdirs: scripts, gen, pattern, env, actors,
animations, objects, locale, pfx, shaders, sounds, water, gui, hud, …).

### Baseline truth check (important — docs disagree with disk)
| Signal | Docs claim | On-disk truth (read 2026-11-24) |
|---|---|---|
| `app/selftest.json` | 29/29 PASS | **`passed:false`** — 27/29; FAILs: `peasant_capture` ("peasant captured: player 1"), `resow` ("wild food nodes=0; depleted mill field re-sown: no; mill auto=24 restored=1") |
| `app/uitest.json` | 17/17 PASS | `passed:true` |
| Clean gate | CLEAN (D-23/D-30) | **DIRTY** — 4 unacknowledged historical timeouts in `app/.godot_queue/status.json`: #1132 `t-menu-roster-3`, #1135 `t-menu-roster-4`, #1184 `t-menu-input`, #1205 `t-forest-bake2` (all 100 s runner timeouts, 2026-11-23) |
| Runner | — | `now_serving=1232`, `pending=0`, `godot.lock=free`, 139 completed (98 ok / 37 failed / 4 timed-out) |

**Resolution plan:** fresh `coord-baseline-selftest` job submitted through the runner
to distinguish a stale artifact from a real regression. Each of the 4 timeouts is
superseded by later `ok` runs of the same test:
- #1132/#1135 → #1136/#1160/#1167/#1175 `t-menu-roster` ok; #1154 `-final` ok
- #1184 → #1187 `t-menu-input` ok; #1190 `-final` ok
- #1205 → #1212 `t-forest-bake-final` ok; #1217 `-clean` ok; #1222 `-render` ok
These are genuine historical/resolved timeouts; ack under `CLEAN_GATE.md` §"Resolved
historical failures" once the background job finishes (avoid spool race).

### 2026-11-24 — baseline result + first improvements
- Fresh `coord-baseline-selftest` (runner ticket **1232**, 203.83 s) => `failed`,
  **28/29**: only `resow` fails (`wild food nodes=0; depleted mill field re-sown: no;
  mill auto=18 restored=1 gold=3353`). `peasant_capture` PASSED this run → it is
  flaky, not a stable defect. `BAKE_BENCH max_ms=3753.09` was recorded under heavy
  concurrent-agent load, NOT comparable to the 50 ms gate (machine was saturated).
- **Clean gate CLEAN** achieved: acked the 4 verified historical timeouts
  (#1132/#1135 superseded by #1136/#1160/#1167/#1175 + #1154; #1184 by #1187/#1190;
  #1205 by #1212/#1217/#1222/#1229). `assert_clean.py --json`: `clean:true`,
  140 jobs, 4 acknowledged, 0 live processes, lock free.
- Recon landed: **R1** (farming — features are implemented, MICRO.md stale; one real
  gap = missing aca.3 agronomist +50% upgrade), **P1** (sim: `_grid_rebuild`
  per-tick allocations rank 1; `_kind_class` hoist rank 4 — zero-risk), **P2**
  (render: HUD per-frame O(n) counter scan top pick; no safe water fetch reduction),
  **T1** (29 steps partitioned into 8 coherent subsets, 3 hard deps), **T2**
  (`--self-test` output-only; add `--self-only`/`run_only`; subsets must not overwrite
  canonical selftest.json).
- Wave 2 builders launched: **I1** (data.gd: aca_agronom1 row) and **I2**
  (hud.gd: 0.5 s counter throttle), each exclusive owner, backup + one targeted test.
- **D1** launched: diagnose the sole `resow` failure (truth fix, no weakening).
- Gap matrix consolidated in `GAPS.md`.

### 2026-11-24 — periodic supervision (owner request)
- R8 and R11 had reported but their sessions stayed `running` on trailing background
  donor scans. Pinged both; scans stopped/ignored, reports confirmed final, sessions
  closed. No new work started by either.
- Automation `aut_20c9e4cc0001a6MHYIQ9OSk0sQ` created: every 5 min checks report
  files vs expected ids, pings silent/running agents, reads runner status + clean
  gate, appends a one-line check here (`SWARM_OPS.md` §7.3 supervision loop).
- All 16 wave-1 recon agents + T1–T3 + D1 have now closed with reports. Wave-2
  builders remaining: I4 (resow latch + subsets, re-running full gate), I6
  (300 s AI metal soak). I1/I2/I3/I5 landed with targeted tests green.
- **Coordinator diff review (read-only)** of landed I1/I2/I3/I5: `git diff --stat`
  = data.gd +4, hud.gd +5/-1, world.gd +70/-18, audio.gd -2. All edits are
  minimal, evidence-commented, backup present, no called symbol renamed;
  world.gd preserves draw call order/args (pool count reset in `_draw_units`,
  cached `_bld_key` keyed by SPRITE_CELL+player+sid, negative death-sheet cache
  keyed by resolved path). No protocol block. I4/I6 reviewed after they close.
- **Owner speed question answered** (`TEST_SPEED_NOTES.md`): tests are NOT at x1.
  CLI soaks run up to 1500 fixed ticks/40 ms frame (9,600 ticks for 300 sim-s)
  and bypass `--speed` entirely (`main.gd:1121-1122,1575-1593`); selftest uses
  `game.tick(0.25)` = 4 ticks/sim-s with `dt` hard-capped at 0.25
  (`game.gd:3820`). `--speed 10` is a no-op for CLI and impossible for selftest;
  shortening windows would weaken assertions. I6 informed; real speedups are
  the headless CLI frame-budget flag and T3 Scenario B snapshot restore, both
  recorded as follow-ups.

### 2026-11-24 — 29/29 RESTORED
- I4 ticket **1248 `i4-resow-latch2`** succeeded: diag showed
  `I4RESOW LATCH t=8 sow_t=2.0 hits=50` — the peasant's own `cmd_resow`
  restored the field at tick 8, long before the 60 s auto-sow timer (sow_t=2).
  Canonical `app/selftest.json` is now `passed:true`, **29 steps**, 0 failures
  (sim_seconds 366.5625). This supersedes all earlier red/28-29 snapshots.
  I4 asked to finish the two subset runs + final report; no new code changes.
- I6 report landed with honest partial scorecard (see `IMPROVEMENTS.md`):
  metal mines fixed, but force max 40 / wave 0 are MEASURED failures from a
  separate `_train`-gate cause → follow-up ticket G-AI4.

### 2026-11-24 — FINAL VERDICT (all work closed)
- All 26/26 reports landed. I4 report: subset mechanism `--self-only`/`run_only`
  + 8 groups, resow truth fix, 29/29 gate; documented the `capture` group-order
  FAIL as an open question. I6 report: metal-mine fix real but force/wave targets
  are measured failures from a separate `_train` cause (G-AI4 follow-up).
- Coordinator fixed the last subset interaction (COORD-1): `peasant_capture`
  fixture now avoids buildings; `capture` subset 2/2 PASS (job 1254).
- **Settled gate: selftest 29/29 (job 1255), uitest 17/17 (job 1256), clean gate
  CLEAN.** Supersedes every earlier red snapshot in this doc.
- Runner defects fixed + verified (P4-fix): 2 s `pid_alive` throttle and
  post-job Godot child reaping; job 1257 ok, 0 orphans, gate CLEAN.
- Remaining documented follow-ups (NOT done this session): G-AI4 train gates /
  wave cadence, DDS 613 MiB dead decals, 259 MiB duplicate PNGs (hardlinks),
  `scan_map.py` 28.5 s, T3 Scenario B snapshot restore for <30 s subsets,
  grapeshot range 175 vs donor 450, Scotland depth, HUD fidelity, staged naval
  families, gold-shortage desertion/ship-stop, capture-mode inversion.

### Wave 2 progress
- Landed reports: W2-1 (game rules — capture modes, artillery gate, gold-shortage
  ship-stop, chat, queue/research clear; `t_capture` 6/6), W2-9 (`.gdignore`
  excludes 613.63 MiB dead DDS non-destructively), W2-10 (naval index 5→7 keys,
  0 orphans; six donor-backed `data.gd` UNITS_BASE entries + dock.trains hand-off
  ready for W2-2). Recorded in `IMPROVEMENTS.md`.
- Outstanding integration: **DONE** — W2-2 integrated W2-10's 6 ship sids +
  7-sid `dock.trains` into `data.gd` (job 1265 ok, `t_upgrades` 6/6), plus all
  donor data-truth fixes (grapeshot 450 px, firepower tiers, wheellock, bayonet,
  Mathematics→art_acc, 7 naval upgrades, 8 Scotland rows). W2-1's `hud.gd:889`
  capture-% denominator hand-off still open with W2-3.
- W2-12 landed: 5-tier config/menu support (30/30 `t_menu_roster`, default output
  byte-identical) but per-slot tiers still cannot reach the sim — exact
  main.gd→ai.gd→game.gd hand-off recorded; main.gd (W2-6) and ai.gd (W2-4) are
  still owned, so integrate after those agents close.
- W2-4 report complete: 8 s wave cooldown + famine floor fixed, **root cause of
  force stall found** (ai.gd passed nation sid `strelet` to `train_unit`, which
  validates generic `serdiuk` — now fixed). Soak job 1262 failed silently
  (exit 1, no CLI JSON, cause UNVERIFIED), but trace shows force 40→46 and
  military 4→7 post-fix; `wave=0` and force<260 remain MEASURED NOT MET. No PASS
  claimed; a clean re-soak is a follow-up. Recorded in `IMPROVEMENTS.md`.

### Wave 2 late results
- W2-5 CLOSED BLOCKED-BY-ENVIRONMENT: 3 `t_forest_bake` timeouts incl. untouched
  baseline; world.gd reverted byte-for-byte; acked #1261/#1268/#1270 with that
  evidence (7 acks total, history CLEAN).
- W2-6 LANDED with honest caveat: snapshot restore + `wall_ms` + CLI frame flags
  implemented, full 29/29 (99.31 s), subset still 123.05 s startup-bound —
  **<30 s target NOT met**; multi-group benefit UNVERIFIED. Canonical JSON hash
  unchanged. 10/11 reports landed; only W2-3 (HUD) still open after ping.

### WAVE 2 CLOSED — final verdict (2026-11-24)
- All 11/11 reports landed. Settled gate: selftest **29/29** (job 1273, 77.67 s),
  uitest **17/17** (job 1274, 86.71 s), clean gate **CLEAN** (182 jobs, 7 acked).
- Shipped: game-rules (W2-1), data truth + naval sids (W2-2/+10), HUD (W2-3),
  AI wave/famine/train-root-cause (W2-4 partial), test-speed mechanisms (W2-6,
  <30 s NOT met), difficulty tiers (W2-12), ambient beds (W2-7), scan_map ~5×
  (W2-8), 613 MiB DDS excluded (W2-9). W2-5 closed BLOCKED-BY-ENVIRONMENT with
  no change shipped; its 3 timeouts acked with baseline proof.
- Known honest residuals: force>=260/wave>=1 not yet met; per-slot AI tiers
  cannot reach sim (hand-off); minimap position + standalone t_hud_fidelity
  expectations need test-owner updates; 259 MiB duplicate PNGs and Scotland art
  bake deferred; wave-3 building UX now opens.

### Wave 3 progress
- W3-1 landed: `build_cost()/can_afford()` now gate placement on escalated cost;
  human sites with no selected peasant refused; default rally re-armed after
  capture; cancel/refund (1.0/0.5-inferred) added. Test job 1275 ok 6/6 but it
  is the collision regression script — a direct build-rule test is a follow-up.
  API hand-off forwarded to W3-2.

### Wave 4 supervision
- Sweep W4-2: W4-1 report landed; W4-2 verification job 1288 `w42-zoom-input3`
  ended ok (125.8 s), runner empty, clean CLEAN, no orphans. Only its report
  file missing — pinged to finalise with no new jobs. No full gate until it lands.

### Wave 4 overlap check — failure evidence resolved
- Jobs 1282 (W4-2) and 1283/1284 (W4-1) all failed with PROTOTYPE CONTRACT
  errors from mid-edit snapshots: W4-2 called `zoom_step` as a function while a
  W4-1 draft declared it as a float; W4-1's camera.gd had a same-name collision.
  CURRENT source is reconciled: camera.gd defines `zoom_step(notches, anchor)`
  + `set_zoom_target()` + `_smooth_zoom()`; input_controller.gd calls it via
  `camera.call("zoom_step", ...)` with a `has_method` guard. Both agents asked
  to verify the CURRENT tree and write reports; no reversion needed.

### Wave 4 overlap check (owner question)
- Verified `git diff` currently shows main.gd changes from W2-6 and
  input_controller.gd changes from W3-2 — NO W4 edits or backups yet, so the two
  agents have not duplicated work in the tree. Their wording WAS ambiguous, so
  I issued a sharp layer boundary (W4-1 = camera state/smoothing/default + API;
  W4-2 = input events → that API only), messaged both, and recorded it in
  `WAVE4_CHARTER.md`. Reports must name the exact API contract.

### Supervision (waves 5/6) — environmental startup failures
- W5 jobs 1302 `w54-uitest2`, 1304 `w57-edge`, 1305 `w52-dump-base2` all failed
  in 6–9 s with 0-byte stderr and only the Godot banner — same ENVIRONMENTAL
  startup-failure signature as earlier hangs, NOT parse/assertion errors.
  W5-4 told to finalise VERIFICATION-BLOCKED (its `w54-hud` 1291 ok, and the
  pre-wave-5 gate 1290 was uitest 17/17); W5-7 told to do one retry then finalise
  honestly. No reverts of correct work, no repeated re-submits.
- G3-3 LANDED harness `heightmap3d_shot.py` + `hm3d_probe.json` with HONEST
  verdict UNVERIFIED: G3-2's `heightmap3d_sandbox.gd` is still a 169-byte stub,
  no world/scene/dump/PNG exists, runner 7 pending — deliberately submitted NO
  g33 job to avoid wasting a contended slot. Donor JPG MEASURED (1280×720,
  luma 75.35, stddev 29.09, greenish 0.2752); M0.6 baseline documented, not
  re-measured. Handoff command ready for when G3-2 lands.

### Supervision (waves 5/6)
- W5-5 visual capture re-launched after a ~6 min FIFO wait; runner now 7 pending
  (max wait 423.64 s, bounded), one live Godot matching the serving ticket —
  expected queue wait, NOT a hang; no re-submit. No G3 reports yet (agents still
  writing new files/tooling). No full gate; no orphan.

### Wave 5 progress
- W5-3 LANDED: measured early-out fix — pre 2/9 (101 chunk-key derivations,
  4 tile_of) → post 9/9 (1 derivation, 0 tile_of), plus `t_wave_smoke` 9/9;
  new light probe `t_chunk_schedule_light.gd` (not in manifest, documented).
  Whole-map render explicitly NOT shipped (BLOCKED-BY-BAKE-TIME, W5-6 numbers).

### Wave 5 supervision (mid-wave issues)
- W5-3 chose small early-out (shipped) + whole-map BLOCKED-BY-BAKE-TIME (not
  shipped, W5-6 numbers); its new light test pre-patch correctly FAILS 7/9
  assertions (proves the probe detects the unoptimised path); post jobs queued.
- W5-4 `w54-uitest` job 1292 KILLED at 240 s (environmental, same class as prior
  hangs; `w54-hud` 15.8 s ok) — asked for one longer re-run, no test weakening.
- W5-2 `w52-dump-base` 1297 shows SELF-SNAPSHOT parity MISMATCH + `raw_to_base64
  ret.is_empty()` at main.gd:778 — asked to fix or mark fast subsets NOT-ACHIEVED
  (no broken snapshot path enabled by default).
- W5-1 soak 1295 `skipped` by FIFO turn logic during the job burst — asked to
  re-submit once with a unique id and report measured trace rows.
- Runner queue ~7 pending (burst), lock fresh — no orphan. No full gate until all
  W5 reports land.

### Wave 5 progress
- W5-7 LANDED: edge-scroll depth ramp + log dwell in camera.gd, 6 config keys
  with defaults. Donor has FLAT speed only (oncamera.inc:10-11,23-29) → explicit
  port improvement; job 1313 parse/load 6/6, FEEL unverified (owner review).
- W5-5 mid-flight: strong MEASURED zoom evidence (canvas scale 0.75 → 2.90 →
  0.395, 245,740 changed pixels); final aura A/B capture queued. No code edits.

### Wave 5 final status
- W5-2 LANDED: per-slot AI tiers FIXED (main.gd prefers roster ai_difficulty;
  W5-1's ai.gd consumer reads it). Pre-baked self-snapshot fast subset FIXED
  parity bug (JSON float/Rect2 loss → var_to_str + quantised compare): 41.83 s
  vs 61.72 s no-snapshot (32% faster), full 1337 29/29 PASS. **<30 s NOT met**
  — residual ~36 s world/hud forest-bake; no assertions weakened.
- ALL Wave-5 reports now landed (W5-1..W5-7 + W5-6 recon). Wave-6 reports all
  landed (G3-1..G3-4). Wave-7 phase 1 landed (V7-0/V7-1/V7-2 + H1).
  Need one FINAL settled gate in app/ before opening phase 2.

### Wave 5 AI result (measured fail, honest)
- W5-1 report landed: per-slot AI tier consumer FIXED in ai.gd (normal path
  byte-identical). Force/wave root causes fixed (real-cost gate + donor min-count
  quotas), clean soak job 1316 ok 300 sim-s → force 84 (was 46) but wave 0;
  effective threshold is 120 (config.json overrides data.gd's 260), so
  acceptance is MEASURED FAIL. Binding cause: gold mine never built (gold floor 2)
  + single barracks throughput — left as explicit next ticket, NOT re-patched.

### Wave 7 integration progress
- V7-53 LANDED: hud.gd 3D adapter seam (bind_3d + minimap box branch), parse
  PASS + 6/6 2D regression; handoff to V7-50 (call hud.bind_3d(cam3d) in 3D
  branch). V7-50/51/52 still running; variant queue empty, no orphans.

### Wave 7 phase 2 — integration batch launched
- All 8 modules landed (camera3d parse PASS, picking3d parse PASS, terrain
  probe 25,600 verts/75.6 ms, fog 9/9 test PASS, FX 13/13 test PASS, entities,
  anim3d, hud3d_adapter). All 7 atomic tests landed; terrain 6/6 PASS, fog 9/9
  PASS, FX 13/13 PASS; others honest BLOCKED/MODULE_MISSING or SEAM_MISSING.
  Manifest registered all 7 (31 total, 2D prefix intact).
- Integration batch launched: V7-50 main/config/data (render_mode seam),
  V7-51 world3d composition, V7-52 input 3D picking, V7-53 hud 3D adapter —
  one existing file per owner, no collisions. Variant final gate after these.

### FINAL 2D GATE GREEN (after all wave-5 merges)
- Jobs 1338 selftest ok (72.39 s), 1339 uitest ok (170.92 s), both 29/29 and
  17/17 PASS. Clean gate DIRTY only from historical 1292 (env timeout) + 1295
  (FIFO skip) — BOTH acked with evidence (env churn / re-run 1316 clean).
  Final: **CLEAN** (246 jobs, 9 acked, 0 processes, lock free).

### Wave 7 phase 2 — ATOMIC SPLIT LAUNCHED (owner directive)
- Owner: "subdivide migration in as smallerst/atomic tasks as possible, same for
  docs/tests, multiply subagent quantities to parallelize."
- Created `V73_ATOMIC_CONTRACT.md` (exact one-API-per-file contracts), then
  launched 18 agents in 4 batches: 8 new 3D modules (camera3d, picking3d,
  world3d_terrain/entities/fx/fog, hud3d_adapter, anim3d), 7 atomic tests,
  manifest registration, 2 docs atoms + read-only supervision. Each owns ONE
  new file + ONE report; no two agents share a file. Integration seams on
  EXISTING variant3d files (main/input/hud/world3d) deliberately deferred to a
  follow-up batch so no agent overwrites another's work.

### Wave 6 heightmap result
- G3-2 LANDED: ONE full-grid ArrayMesh (102,400 verts / 203,522 tris / 1
  surface, build 129.168 ms), donor-block splat albedo, water plane + donor
  light; 1280×720 non-blank capture. VERDICT = GEOMETRY_FIX_VERIFIED,
  DONOR_FIDELITY_NOT_CLAIMED: still flat/dark, no relief/face art/units, FOV
  unverified (600 m overview). Donor text cited, no binaries copied. Feeds V7-4
  full world3d in variant3d; never replaces shipping 2D renderer.

### Wave 5 visual A/B result
- W5-5 report landed: startup zoomed-out PASS (canvas_scale 0.75 at frame 475),
  wheel zoom PASS (0.75→2.90→0.395 via real OS wheel), clamp PASS (2.9 donor
  max), 245,740 px changed (26.66%), real GPU capture 1280×720. Aura/rally/
  deselect and donor equality UNVERIFIED — building was off-screen in the
  selected capture and a minimap click moved the box the wrong way; flagged for
  owner review with a required re-capture (blocker, not a claimed pass).

### 3D variant: NO 2D bake pipeline (owner directive 2026-11-24)
- Owner: "in 3d variant you need models anim pngs? if its 3d why even need
  making baking." CORRECT — recorded §NO 2D BAKE PIPELINE in WAVE7 charter.
  3D variant renders MESHES: keep donor geometry (.obj→.glb), material albedo
  textures, and ANIMATION DATA (.oss skin + .aaf actions); DEAD WEIGHT = baked
  8-azimuth sprite sheets (anim/** PNGs, sprites/, sprites_hi/), anim/index.json
  metrics, buildings.json sprite keys, bake tools. V7-0 instructed to `.gdignore`
  only the sprite dirs inside variant3d (not obj/tex/blocks); H1 hygiene told to
  document and ignore 3D-conversion garbage. V7-2 independently confirmed
  donor-faithful skinned rigs are BLOCKED (unreadable bone hierarchy) and the
  sampled-pose fallback must be labelled PORT APPROXIMATION, not donor parity.

### Hygiene + 3D governance (owner directives 2026-11-24)
- H1 launched (owns ONLY clean_temp.bat, .gitignore, launch_3d.bat, new
  launch_variant3d.bat + report) to add variant3d/ cleanup rules, 3D experiment
  ignore patterns, and fix stale launch scripts. Owner added "point launch3d.bat
  to correct godot project" — H1 instructed to target active `variant3d/`, with
  legacy M0 sandbox documented separately.
- Governing rule for all 3D work: LEVERAGE DONOR CODE, don't invent; singleplayer
  skirmish scope only. V7-1 inventory landed with donor-source table §2.4 and
  D-12 scope; it corrected R-ARCH's ortho premise (donor main view is PERSPECTIVE)
  and flagged study line-number drift — seam numbers must be re-verified.

### Owner governing rule for 3D (added 2026-11-24)
- "Leverage existent donor code to transform into feasible Godot project — no
  need to invent who knows what; we are attempting the singleplayer part port."
  Added §GOVERNING RULE to WAVE6/WAVE7 charters: every 3D decision cites donor
  path:line (`data\scripts`, `data\cameras\camera.cfg`, `data\shaders`, `.osm/
  .oss/.aaf`, `light.cfg/env.cfg`), UNVERIFIED where unreadable, no invented
  constants, singleplayer skirmish scope only (D-12). Reinforced to G3-2 and
  V7-0/V7-1/V7-2.
- W5-4 LANDED: `t_hud_fidelity` 2 literals `[N]`→`(N)` (test 6/6 PASS, job 1291),
  `uitest` minimap assertion NO-CHANGE (matches shipped bottom-left 200 px);
  fresh uitest attempts all blocked by environmental/concurrent parse issues,
  pre-wave-5 gate 1290 was 17/17. Donor bottom-right 240 px remains an OPEN
  hud fidelity gap.

### Wave 7 — FULL 3D variant with all mechanics (owner directive 2026-11-24)
- Owner: "for 3d variant duplicate all game mechanics you invented for 2d world,
  just make a 3d variant; may be separate project or same with 3d branch and own
  tests." Architecture decision: **separate project `variant3d/` inside repo** —
  full script/test/tool/scene/shader copies, assets HARDLINKED (2.31 GiB saved),
  `.import` files real copies, own project.godot, OWN runner queue (no contention
  with waves 5/6), own selftest/uitest. 2D app/ remains untouched.
- Phase 1 launched: V7-0 scaffold + baseline 29/29 proof, V7-1 read-only mechanics
  inventory (SHARE/ADAPT/NEW + world contract + ownership plan), V7-2 read-only
  mesh/animation conversion feasibility. Charter + ids in `WAVE7_3D_VARIANT_CHARTER.md`.
- Phase 2 (after scaffold): V7-3 main/config/data seams, V7-4 full world3d,
  V7-5 camera3d+input, V7-6 hud, V7-7 tests, V7-8 meshes/anim, V7-9 scenes/env.

### Wave 6 — parallel Godot 3D heightmap variant (owner directive 2026-11-24)
- Owner: "in parallel try to develop godot 3d variant; for terrain generation
  leverage heightmap concept instead of per-chunk reasoning; maybe donor were
  full 3d game with just optimized 2d perspective?"
- Prior R-ARCH evidence CONFIRMS donor is full 3D OpenGL (perspective camera,
  lit heightfield, GLSL, skinned meshes). M0 3D sandbox used block-by-block
  heightfield and visually FAILED (M0.6). Its dump `final_fullmap_dump.json` no
  longer exists → G3-2 regenerates one.
- New approach: ONE ArrayMesh from the full 320×320 height grid (~102k verts /
  204k tris), donor block albedo, perspective Camera3D — no chunk dictionaries
  or 2/frame cap. Shipping 2D world.gd UNTOUCHED; all G3 files are NEW.
- 4 agents launched in parallel (G3-1 donor truth recon, G3-2 heightmap world,
  G3-3 capture harness, G3-4 splatmap generator). Charter + session ids in
  `WAVE6_3D_CHARTER.md`. Runner shared FIFO with wave 5 — unique g3* ids.

### Owner directive — edge-scroll acceleration (2026-11-24)
- Owner: "the more you move on the edges of the screen the faster the camera
  moves, and maybe logarithmic acceleration if the mouse sits on one edge for a
  prolonged time." Verified camera.gd:116-172 uses BINARY edge bools + fixed
  `mouse_speed`. W5-7 launched (owns camera.gd, free after W4-1) to add a depth
  ramp + capped logarithmic dwell acceleration, config-driven with defaults,
  light verification only (t_nav_smoke), FEEL = owner visual review.

### Owner architecture directive — whole-map render (2026-11-24)
- Owner: "once map is created you don't render it in chunks; keep whole built
  map in memory, it's relatively small; chunking is for open worlds."
- Verified: 320² tiles, CHUNK_T=32 → 100 chunks; quality presets 8/12/16 px →
  whole-map RGBA = 25/56/100 MiB (all feasible). Current code keeps 100 terrain
  chunks with no eviction but bakes 2/frame with per-frame scanning; forest LRU
  20 ≈ 62 MB. 20480²/1.6 GB is diagnostic-only, not a runtime preset.
- W5-3 (world.gd) priority switched to evaluate/implement one-shot whole-map
  bake + single Sprite2D, verified with its light test (no t_forest_bake).
  W5-6 launched as read-only feasibility recon (memory/bake-time/GPU limits +
  main.gd loading-stage handoff). Both in WAVE5_CHARTER.

### SESSION FINAL VERDICT (2026-11-24) — ALL WAVES GREEN
- Waves 2 (11), 3 (3), 4 (2) = **16/16 reports landed**. Final settled gate:
  selftest **29/29** (job 1289, 99.60 s), uitest **17/17** (job 1290, 118.59 s),
  clean gate **CLEAN** (198 jobs, 7 acked, 0 live processes, lock free).
- Shipped highlights: capture/gold rules, donor data truth + naval sids, HUD
  fidelity, AI train-root-cause + wave cooldown, 5-tier difficulty config/UI,
  ambient beds, scan_map ~5×, 613 MiB DDS excluded, building affordability/
  completion/rally rules, building UX gating + aura + rally styling, and zoom
  fluidity + more-zoomed-out startup.
- Honest open follow-ups (documented, not silently claimed): AI force>=260/wave>=1
  not yet reached (clean re-soak needed); per-slot AI tiers cannot reach sim;
  <30 s subsets not met; W2-5 world perf BLOCKED-BY-ENVIRONMENT; minimap move +
  t_hud_fidelity `[N]` expectations need test-owner updates; W3-3 aura and W4
  zoom FEEL need owner/coordinator visual A/B; 259 MiB duplicate PNGs, Scotland
  art bake, adviser auto-control deferred.

### Wave 4 opened (owner directive 2026-11-24)
- "optimize zoom in zoom out speed and fluidity, start the game more zoomed out."
  W4-1 launched with exclusive `camera.gd` + `main.gd`; session
  ses_df319549fffeU6xZbEhzvKGgXA. W4-2 (input_controller.gd wheel handling)
  held until W3-2 closes that file. Charter: `WAVE4_CHARTER.md`.

### Wave 3 progress
- W3-3 landed: render-only aura (glow + tinted ring + pulsing diamonds +
  progress halo + garrison pips) and selected-gated rally flag. Verified the
  two `t_smoke_fx` FAILs (`artillery_explosion_fx`) are PRE-EXISTING by running
  the untouched backup (byte-identical stdout); green job 1279 WAVE_SMOKE 9/9.
  Visual A/B still required via coordinator screenshot (headless has no draw).

### Wave 3 supervision
- Sweep W3-2: W3-1/W3-3 reports landed, W3-2 still open. Its `uitest` job 1281
  just started (lock 3 s, one matching Godot process) — expected, not orphan;
  history CLEAN (7 acks). Report ping already sent earlier; no re-ping, no
  reassignment, no full gate until W3-2 report lands.
- Sweep W3-1: runner empty, clean CLEAN, no orphans. W3-3 had 2 failed light
  verification jobs (#1276/#1278) + 1 ok (#1277) and no report; W3-2 had no
  report or job yet. Status pings sent to both; no reassignment, no full gate.
- Wave 2 fully closed (11/11 reports, final gate green). Wave 3 launched:
  W3-1 game.gd (affordability/builder/completion/rally re-arm), W3-2
  input_controller.gd+hud.gd (gate ghost, aura handoff, rally UX, buildables),
  W3-3 world.gd (selection aura + rally flag art). Session ids in WAVE3_CHARTER.
  First sweep: runner empty, clean CLEAN, no reports expected yet — no ping.

### Wave 2 supervision
- Sweep W2-5 (final pending item): W2-3's retry job 1272 `w23-hud-retry` ended
  ok (150.7 s) and `app/uitest.json` is 17/17 PASS; runner empty, clean CLEAN
  (7 acks). Only its report file is missing — pinged to finalize with no new
  jobs. No full gate until that report lands.
- Sweep W2-4: 9/11 reports (W2-3, W2-5 missing). W2-5 ESCALATED per §7.3:
  two timeouts on the same `t_forest_bake` test (#1261 245 s, #1268 131 s);
  `git diff -- app/scripts/world.gd` is empty (fix reverted or never applied).
  Its A/B baseline job #1270 then ALSO timed out (94.2 s, only Godot header),
  proving the hang is environmental/pre-existing, not W2-5's change (world.gd
  diff empty). W2-5 told to close as BLOCKED-BY-ENVIRONMENT (no perf win, no
  world.gd change). Mirrors historical timeout 1205 in PERFORMANCE_SWARM; ack
  with that evidence after the report lands.
  W2-6 subset job #1269 ok (123 s), full retry #1271 queued. W2-3 still no
  report after ping. Clean gate DIRTY only from the two unresolved timeouts —
  correct until W2-5's verdict decides ack vs revert. No full gate.
- Sweep W2-3: 8/11 reports landed (W2-2/-3/-4/-5 still open). Runner has 2 queued
  jobs (W2-6 verification), one live Godot matching W2-5's `t_forest_bake`
  re-run (expected). History shows W2-5 job 1261 timed-out (unacked — correct:
  not resolved yet, so clean gate stays DIRTY by design), plus failed jobs for
  W2-3 (1266), W2-4 (1262), W2-6 (1267) — likely concurrent cross-file parse
  churn, not orphans. Pings sent to W2-3 (no report + failed test) and W2-4
  (placeholder report + failed soak with usable trace rows). No full gate.
- Sweep W2-2: 5/11 reports landed; 5 queued jobs, healthy FIFO, no orphan after
  the runner reaped job 1261's child. **Job 1261 `w25-world` TIMED OUT at 245 s**
  with only the Godot header (t_forest_bake normally 1–38 s) — likely a hang in
  W2-5's chunk early-out. Urgent diagnosis message sent to W2-5; no finish/PASS
  accepted until resolved. W2-4's soak is queued behind it, not stalled.
- Sweep W2-1: no W2 reports yet (agents still working). Runner job 1259
  `w21-capture-rules` actively serving, one live Godot matching it (lock 13 s,
  history CLEAN) — expected, not an orphan. No ping needed.

### Owner directives received during wave 2 (reserved W3)
- Building placement must REFUSE when resources are insufficient, and all
  building construction must be completable.
- Building selection visual: replace white circle with a donor-styled aura.
- Rally points must be visible and used when a building is selected, plus
  related polish ("and much more").
- W3 will own the exact sites after a read-only recon (agent X1) identifies them;
  no .gd file conflicts with wave 2 owners.

### Periodic supervision checks
- Sweep 5: ALL 26/26 expected reports present; runner empty (`pending=0`), no
  Godot processes, lock free, history CLEAN (4 acked) — **CLEAN**. All builders
  closed; coordinator reviewing remaining subset-order issue and preparing the
  final settled gate (selftest already 29/29 from job 1249).
- Sweep 6 (final): all agents closed, no reports pending, no live jobs, gate
  CLEAN; runner leak + poll throttle fixed and verified afterwards. No ping
  needed.
- Sweep 4: reports 25/26 (only `I04_test_split.md` pending); runner ticket 1249
  `i4-final-full` actively serving, one live Godot matching it (expected, lock 47 s,
  history CLEAN) — no orphan, no ping needed (agent is mid-gate, not stalled).
- Sweep 3 — **action taken**: found 2 live Godot processes while the runner had
  already released/moved past their tickets: PID 18188 (soak job 1245, only the
  Godot header written) and PID 7212 (diag job 1246). Killed both with targeted
  `taskkill /PID … /T /F` (NOT `doctor`, which would have killed the active job).
  Root cause: `godot_runner.py` launches the WinGet `godot.EXE` shim; on normal
  completion the shim exits but its real Godot child survives — the runner's
  `kill_tree` only runs on hard timeout (`godot_runner.py:366`). This is a real
  runner defect; add to P4-fix (post-job process-tree cleanup). I6 was also told
  to STOP re-running soaks — jobs 1239 and 1242 already ended `ok`, and a third
  was in flight. No reassignment of I4/I6.
- Sweep 2: I4/I6 reports still absent; runner `pending=1` (#1245 I6 soak re-run),
  one live Godot matching that job (expected, not orphan), lock fresh 14 s,
  history CLEAN. I4 diag2 revealed a FALSE-POSITIVE trap: `hits=50` at t=139
  coincided with `sow_t` reset 55.3→0.0 = the 60 s auto-sow timer, not the
  peasant's `cmd_resow`. Sent urgent test-only correction to I4 (zero sow_t,
  spawn at walkable work slot via `_snap_free_point`+`_work_slot`, latch within
  a <60 s window) and told it to stop guessing if this fails.
- 2026-11-24 automation sweep: 24/26 expected reports present (missing only
  `I04_test_split.md`, `I06_ai_metal_mines.md` — both builders still running).
  Runner `pending=2` (#1242 I6 soak, #1243 I4 diag2), lock HELD 170 s with one
  live Godot whose command matches the queued soak → expected in-flight job,
  **not** an orphan; clean gate DIRTY only for that live process. History CLEAN
  (4 acked). No reassignments.
- I4's diag stdout showed the peasant stuck in `resow` order ~3.4 m from the field
  (`I4RESOW t=20..80 hits=0`), never reaching `_work_slot` (game.gd:4358) — so
  the fix is test-side spawn placement, not just the latch. Hint sent to I4.

### Swarm launched (wave 1 recon — all read-only, no runner cost)
19 micro-agents, each owning exactly one report file under `reports/`:
- R1 farming/production, R2 capture/siege, R3 formations/squads, R4 combat/weapons,
  R5 hotkeys/controls, R6 AI, R7 economy/market, R8 roster/upgrades, R9 naval,
  R10 environment/seasons, R11 HUD/GUI, R12 new-micro sweep.
- P1 sim hot paths, P2 render hot paths, P3 assets/memory, P4 tooling/startup perf.
- T1 selftest subset taxonomy, T2 subset mechanism + existing small-test overlap,
  T3 per-step cost/dependency analysis (owner directive: split big tests into small
  logically meaningful fast sets).

Session ids are recorded in `CHARTER.md`. Wave 2 (implementation) is gated on these
reports + the fresh baseline result.
