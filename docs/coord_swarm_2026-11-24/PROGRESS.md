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

### POST-PERF FINAL GATE GREEN
- Jobs 203/204/205 all ok. selftest passed:true 29/29; uitest passed:true 17/17;
  t_render_mode PASS, seam_missing=false. (Gate run before V7-81 camera fix;
  V7-81 will re-verify its own selftest.)

### V7-83 donor map importer LANDED
- NEW `variant3d/tools/import_donor_map.py` (stdlib-only, read-only) + report.
  Decodes TerrainMapBegin/End float32[320x320] grid into the schema
  heightmap_splat.py expects; --verify compares vs g32_dump.json without
  writing donor data into the repo. Temp generated JSON consumed by splat tool
  in a temp dir then deleted. No donor bytes copied, no git.
- Measured bonmis1: 102,400 cells, bounds -2.964000/+2.964000 (mean -0.072741),
  16,274 exact matches vs g32 (15.8926%), max abs error 5.928 m. engmis4:
  bounds identical (mean +0.252345), 40,327 matches (39.3818%), max 5.302495 m.
  Bounds delta vs local dump 0.000000000 — same format/bounds, DIFFERENT maps.
- `tileblock` emitted as explicitly labelled NEUTRAL ZERO placeholder (required
  by load_dump); tile-index + named-coordinate structures parsed as opaque
  counts, SEMANTICS UNVERIFIED. Corrected DECOMP-06:119: TerrainMapEnd prefix
  is 13 bytes, not 16.
- Implication: real per-cell tile indices must come from the 37-byte records
  decoded by DEEPDEC-05 before A3 integration can use donor truth.

### DEEPDEC SWARM + donor-representation terrain tasks launched
- User asked for DEEP decompilation with multiple agents. Charter
  `DEEPDEC_CHARTER.md`; 10 audit-only agents: camera, terrain render, water,
  fog/light/sky, map serialization, models/animation, FX/audio, UI/minimap,
  AI/economy, cross-cutting function catalog.
- HARD RULES: donor read-only; shared target t_87f0f3c130b0; no target
  open/select; whole-file native_bytes_find (string search is data-only);
  evidence id per finding; NO Frida/runtime/unpacking; no source/git edits.
- TERRAIN2-06 feasibility: TRUE donor-representation port is feasible with
  shipped data — per-cell integer tile index present (g32_dump.json:1,
  game.gd:53,1610), 124-name index dictionary, smoothing rules, 320x320 detail
  bitmaps, 25-deg face metadata, 112 full-res block PNGs. NOT bit-exact:
  zero shipped vf/vs face ids, gl_EyePlane values, tile->face promotion rule
  engine-side, standalone alpha/alphavert PNGs absent (only indirect 64² dmask).
- Dispatched V7-85 (new tile atlas tool + donor alpha masks) and V7-86 (new
  tile-index spatial shader with eye-plane UVs) in NEW files only; A3
  (world3d_terrain.gd integration) queued until V7-82 frees that file.

### DECOMP-04 §8 — hmapTex consumer + water descriptor PROVEN
- hmapTex at 0x853e0c is a standalone Delphi AnsiString (refcount -1, length 7,
  NUL-terminated; ev_20196da6..., ev_f49f1d24..., ev_a2994635...), referenced by
  `mov edx,0x853e0c` at 0x853bde -> call 0x405454 (ev_19089834...,
  ev_cf7b42dd...); sole in-file pointer 0x853bdf (ev_c9350527...). Callee
  sub_405454 is a ref-counted Delphi string-assignment helper. NO containing
  function discovered (native_function_find "not inside any discovered
  function" around 0x853b00-0x854000) -> no texture lookup/binding proven.
- SAME initializer assigns a coherent water descriptor: waterAmount,
  fresnelPower/Bias, hdrMultiplier, waveFreq/Amp, distFactor, bumpFactor,
  texScaleS/T, waveDir0/1, fogEnabled, hmapTex, hmapW/H/Min/Max,
  shadowed/shadowMap/shadowSize/shadowColor, cameraModel, reflectionMap
  (ev_9824755f..., ev_335ea2e2...). hmapTex is a water heightmap PARAMETER name;
  binding still UNVERIFIED.
- CONTRAST: SphereHeight/SphereHeightMin/DynFogDepth DO have a real consumer:
  sub_7ab704 (9 blocks/335 instructions, ev_e57a21ab..., pseudo-C
  ev_acad42c1...) reads them as config keys with default DynFogDepth=0 and
  DynFogStart/End/Density/Power/Offset. Other two DynFogDepth copies have 0 xrefs.
- V7-84 dispatched: new `water3d.gd` + `water3d.gdshader` only (no terrain file
  edits), donor water literals/uniforms, probe, no visual parity claim.

### DECOMP-06 donor .map relief IS READABLE (prior UNREADABLE was wrong)
- Craft Anything triage called .map "unknown"; core_packed_files_list refused it;
  byte-search + read-only Python decoded the structure:
  - `TerrainMapBegin … TerrainMapEnd` section with PLAIN UNCOMPRESSED
    float32[320x320] height grid (409,600 B), bounds EXACTLY ±2.964 m =
    donor cMaxHeight=2.96 (texturemap.inc:29-31), already the schema
    heightmap_splat.py expects (base64 LE f32).
  - Anchor: TerrainMapBegin, then the SECOND `40 01 00 00 40 01 00 00` header;
    grid starts 8 bytes later (0xa68acd bonmis1.map, 0xa3353c engmis4.map).
  - Also decoded 102,400 x 37-byte tile/attribute grid (4 tile-index bytes,
    four constant 1.0f weights) and 8,777 sparse 31-byte named coordinate
    records — semantics PARTLY UNVERIFIED.
  - NOT the source of g32_dump.json (17,354 / 41,496 exact matches, mostly
    shared zeros/clamps): format recoverable ≠ visual parity.
- V7-83 dispatched: standalone read-only `variant3d/tools/import_donor_map.py`
  with --verify vs g32_dump.json; no donor data written into repo.

### TERRAIN2-01 DONOR PIPELINE — MAJOR CORRECTION
- Donor has NO SPLAT WEIGHTS. ONE INTEGER TILE INDEX per cell, chosen by slope
  aspect: texturemap.inc:426-445,474-511 computes dirX=lh-rh, dirY=th-bh, 8
  x 45-deg sectors, writes sandsea*/rock* via MapGetTileIndexByTileBlock ->
  SetTileIndex; base tiles from tile_lowground/highground.bmp by h<0.1 and
  r div 2 (loadtextureterrainfrombitmap.inc:4-42), weighted neighbour
  transitions from tilesmooth_scripts.cfg:1-35.
- Cliff striations = 25-deg TILLED FACE TILES with alpha masks (tiles.lib:119-136
  rockNvf AngleX=0/AngleZ=25, rockNvs AngleX=25/AngleZ=0; reftile.mat:120-169
  alphavert.bmp UV scale 0.125 tmmEyeLinear), NOT per-vertex normals. Ground
  shader has tangentSpace=false (shaders.lib:19); only Blinn-Phong normal use
  (hf.pvl.sm.vert:15). No ground normal maps.
- Terrain albedo UVs are EYE-PLANE PROJECTED (shaders.lib:30 texGen=true;
  hf.pvl.sm.vert:26-33 dot(realpos, gl_EyePlaneS/T[0])), not 0..1 map UVs.
- Water: 2x2-cell WaterFieldAdd(...,-0.5) patches (generatemap.inc:646-708);
  shader discards height>level, blends depth/waves/reflection/3-tap shadow/
  nautic foam/particles (water.dev.frag:167-232). -0.25 IS donor literal
  (texturemap.inc:30); our "donor literal UNVERIFIED" comment is stale.
- terrainmesh1..4 = FOUR DISTINCT RELIEF PROPS with one LOD slot each
  (actors.lib:1200-1225), not 4 LODs of one mesh. Default FogMode=0
  (colors.lib:36) + DynFogDepth=False (camera.cfg:59); override only for
  screenshot camera (docreate.inc:296-320) — do not unconditionally add fog.
- TERRAIN2-06 architecture agent dispatched for a donor-representation port;
  V7-82 splat fix explicitly downgraded to PORT APPROXIMATION interim polish.

### DECOMP-02 RTTI class names decoded + DECOMP-03 vertex layout
- DECOMP-02: RTTI strings carry a leading Delphi metadata flag byte; corrected
  names XTerrain 0x95864a, XTerrainDataLite 0x9587c3, XTerrainData 0x958b76,
  XTerrainBorders 0x9593b4, XHeightField 0x958aa3, XMap 0x958ab2,
  XTile 0x9589e9, XWorld 0x9589e0, XColorTable 0x958ab9, XBrush 0x9587d6,
  each with VA->file offset in its report. ALL xref searches 0 code refs.
- DECOMP-03 §6 exact layout: sub_4ff680 glVertexPointer(3,FLOAT,0),
  glNormalPointer(FLOAT,0), glTexCoordPointer(2,FLOAT,stride 12), NO color array
  (glColorPointer 0 refs). sub_501420 adds two extra glTexCoordPointer(4,FLOAT)
  on texture units GL_TEXTURE0+ offsets — genuine MULTI-TEXTURE/multi-UV path.
  Draws are mode 4 GL_TRIANGLES only, arrays (first=0,count=[obj+0x90]+8) or
  indexed shared-vertex triangle lists with 32-bit indices (count=[obj+0x1c]+8).
  Display lists are generic object caches (gated byte [obj+0xbc]); terrain/UI
  identity UNVERIFIED. Implication: ShaderMaterial can mirror triangle-list
  indexed geometry + multi-UV sampling; vertex colours NOT donor-proven;
  tile factors/UV transforms/fog/water constants unrecoverable from EXE.

### TERRAIN2-02 donor textures — fix dispatched
- Top reusable donor blocks (all 1024x1024 DXT1, 11 mips, ALREADY converted to
  `variant3d/assets/terrain/blocks/*.png`): grass1 (15,993 splat cells;
  tiles.mat:2-4, terrain.presets:6), grass2 (2,863; presets:7), rock8
  (high-face fill; world.gd:1394-1396,1476-1479), sandsea6 (shoreline tile
  texturemap.inc:505-511; world.gd:1060-1063), ground1 (bare earth; tiles.lib:32,
  presets:16 — no donor road tile exists). Masks: alpha.bmp 512x256 8bpp blend
  atlas, alphavert.bmp 1024x512 cliff mask.
- UNVERIFIED: detail.dds 2048x 2 (name suggests detail, construction link, not
  proven terrain detail/normal); alphanull.bmp; hmapTex binding; sand1/2 256x vs
  sand3/4 1024x despite same metadata; no donor terrain normal map bound; road
  art; inert dmask/d_*.png; most terrain scripts commented in shipped build.
- V7-82 dispatched: variant3d-only splat regeneration with --texels-per-cell 4
  + LINEAR filter (owns variant3d/tools/heightmap_splat.py, splat PNG, one
  filter line in world3d_terrain.gd), before/after GPU captures if feasible,
  29/29 gate. app/ untouched.

### DECOMP-04 strings/config keys — CORRECTED DECOMP-01
- IMPORTANT correction: native_strings_find is DATA-SECTIONS-ONLY, so DECOMP-01's
  zero matches were false negatives. Whole-file native_bytes_find found real
  donor keys in CODE: SphereHeight 0x7abc44, SphereHeightMin 0x7abc5c,
  MinHeightMinAngle 0x7abe5c, DynFogDepth 0x5fe437/0x5fe46b/0x7ac0ac,
  FocalLength (16), Weather (32), DateTimeEnable 0x7e6630/0x7e9aac,
  hmapTex 0x853e0c (file offset 4534796), XTerrainBorders 0x7783b6/0x7783cf/
  0x7783e9, HXHeightField/XColorTable .rsrc + 47/29 CODE hits.
- Truly ABSENT whole-file: grass1, sand, rock, diffusewaves, terrainmesh,
  .hmap, .dds, .tga -> external data/** confirmed, not disuse.
- DECOMP_01 report corrected with a WARNING block; follow-up dispatched to find
  code consumers of hmapTex / DynFogDepth / SphereHeight (could unlock donor
  water/fog semantics). Report DECOMP_04_strings_config.md.

### DECOMP-03 donor render path PROVEN
- Fixed-function OpenGL 1.x, CPU-side vertex arrays + index remaps, cached state
  setters, NO VBOs/shaders in the analysed binary path. Packing confined to
  .bind; CODE segment yielded full Ghidra dossiers/pseudo-C.
- Proven call sites: glDrawArrays 0x4ffaeb in sub_4ff680 (ev_53e679e4...,
  ev_e8b90d94...); glDrawElements 0x4ffb7a (ev_510b131a..., ev_6861feca...);
  second draw path sub_501420 at 0x501e80/0x501fcd incl. glNewList/glCallList
  (ev_5b533b72...); glVertexPointer/NormalPointer/TexCoordPointer +
  glEnableClientState around 0x4ffa7e/0x4ffb41 (ev_1426cbde..., ev_4eb0f457...);
  cached glBindTexture at 0x88f8c0 (ev_7283a6b2..., ev_b07dd093...).
- UNVERIFIED: shader setup (no shader imports, wglGetProcAddress 0 refs,
  $XWaterShader etc. are .rsrc metadata with 0 code refs); D3D9 path
  (Direct3DCreate9 imported but 0 refs, DrawPrimitive 0 matches).
- Follow-up dispatched to extract exact gl*Pointer size/type/stride args and
  draw modes from sub_4ff680 / sub_501420, with terrain implications.

### DECOMP-05 static-vs-runtime feasibility
- Ghidra static decompilation IS feasible PER FUNCTION: entry 0x8f1a08 -> real
  113-line pseudo-C (DEP check, mutex, "Cossacks III", WinExec) evidence
  ev_8fb27745...; arbitrary sub_60faa0 -> 39 lines virtual call ev_2cbea617...
- NOT terrain-targeted: 4 terrain strings have 0 code refs (ev_01c9b39d...,
  ev_b218360c...); 18,918 functions, 6M-instruction cutoff, 1,238 unresolved
  indirect jumps, stripped names, no recovered types (ev_60b49743...).
- High entropy is LOCALISED to .bind (7.96, 146,800 B); 5.18 MB CODE segment
  entropy 6.61 analysed fine (ev_2a27e4cd...). Packed-file listing refused the
  EXEs (no recognised container, 0 evidence records); .bind is NOT an
  enumerable static archive.
- Verdict: do NOT ask for consented runtime unpacking for terrain work — small
  uncertain payoff vs anti-cheat/DEP/network/instability risk. Focus on static
  external `data/**` scripts/shaders (TERRAIN2 lane). Frida/runtime tools were
  only enumerated, NEVER executed. Report DECOMP_05, finding fnd_1.

### V7-81 minimap black-view FIXED — USER RETEST PENDING
- camera3d.gd coordinate frame fixed. Measured minimap-centre click on 320x320
  stub: BEFORE global_position (320.0, 34.06, 374.51), centred view centre
  (320.0, 315.24) -> off-terrain/black; AFTER global_position (0.0, 34.06,
  54.51), centred view centre (0.0, -4.76), sim round-trip (320.0,315.24) ~=
  (320,320). Corner click clamps to centred (-297.08,-300.43).
- Extra: main.gd's read-only V7-70 seam ALSO converts _target to centred after
  jumps/setup; naive fix would double-subtract and black out startup. Added a
  camera-local memo guard `_own_clamp_target` so conversion happens exactly once;
  verified by simulated seam checks. Open question flagged for main.gd owner.
- Jobs: before-probe 206 (2/8, bug reproduced), parse 207/210, after-probe 208
  8/8, final probe 211 11/11, selftest 212 29/29. Probe deleted. No visual claim.

### CRAFT ANYTHING donor decompilation — initial pass documented
- User asked if we use Craft Anything for donor scanning; answer was NO until
  now (direct read-only text extraction). Enabled native toolset, triaged donor
  EXEs with Craft Anything 0.6.1 (Deep mode, no runtime unpacking, no copies).
- Documentation: `reports/DECOMP_01_craft_anything_donor.md` with exact paths,
  sha256, evidence ids, addresses and limits.
- Proven: cossacks.exe PE x86, 5,768,048 B, entry 0x8f1a08, 18,918 functions /
  12,073 strings / 746 imports before analysis cap; Delphi/C++Builder hint;
  `.bind` entropy 7.96; stripped; 6M-instruction cap + 1,238 unresolved jumps.
  Four terrain strings in .rsrc: EXTerrain 0x958649, XTerrainDataLite 0x9587c3,
  sXTerrainData 0x958b75, <XTerrainBorders 0x9593b3.
  0x9587c3 -> file offset 0x5499c3; byte window reveals a Delphi unit/class
  table with HXHeightField, XMap, XTile, XColorTable, XWorld, XBrush,
  OSWTexture, LXShaderLOD, XShadowMap etc. `core_feature_find` found 0 code
  refs for XTerrainData — no pseudo-C produced, packing likely.
- Delegated long dives to 5 subagents: DECOMP-02 RTTI terrain classes,
  DECOMP-03 render API functions, DECOMP-04 config/data strings, DECOMP-05
  static-vs-runtime feasibility (no donor execution without consent),
  DECOMP-06 donor .map binary format. All audit-only, shared target id
  t_87f0f3c130b0, no target open/select collisions.

### TERRAIN2 results and leftovers (user request)
- TERRAIN2-03 water/weather: donor water geometry IS a flat plane
  (water.dev.vert:14-18,29); all detail is fragment-stage (water.dev.frag:85-104,
  186-227). Only diffusewaves0.bmp is bound (water.mat:7,11, 256² tfLuminance);
  diffusewaves1 commented, waves2 library-only, heightmapwaves0 fully commented.
  Shoreline is height-contour driven with real literals cMaxHeight=2.96 /
  cWaterHeight=-0.25 / cWaterShoreHeight=-0.1 (texturemap.inc:29-31); frags fade
  over 0.57/1.07 m. DynFogDepth=False in camera.cfg:59 + cameradebug.cfg:57 but
  TRUE in camerascreenshot.cfg:61. Sky = unlit two-band dome (skydome.cfg:7-46)
  + 12 cloud billboards, Weather=40, wind (-0.7421,0,-0.8673); no day/night.
- TERRAIN2-04 ranked recipe: (P0-1) regenerate splat with
  `--texels-per-cell 4` + LINEAR filter — current tool crushes 1024² donor
  grass1.dds blocks to ONE mean texel per 2 m cell (heightmap_splat.py:191-208,
  383-384), the direct cause of uniform dark olive. (P0-2) water coverage must
  follow dump/height mask, not a full-map wash — g32_dump.json has 0 water
  cells but 2,359 below -0.25. (P1-2) seed/size consistency guard using the
  manifest's input_seed/map_w/map_h/input_dump_sha256. AUDIT3D-03's light-rig
  P0 already fixed; forest/stone painting UNVERIFIED.
- TERRAIN2-05 leftovers: 82 evidence-cited items in 5 groups. Top: RB-01
  V7-81 minimap black-view fix unverified; RB-07 AI force>=260/wave>=1 fails
  (gold mine never built, gold bottoms at 2); DF-01 no donor GPU visual A/B;
  PF-01 windowed sync_ms never re-measured after perf fixes; DF-02 terrain
  fidelity open. Recommended next three: RB-01, DF-01, RB-07.
- User explicitly unsatisfied with 3D terrain quality: "need to understand better
  how donor did it properly". Charter `TERRAIN2_CHARTER.md`.
- Five AUDIT-ONLY agents launched, one report each, no source/git edits:
  TERRAIN2-01 donor terrain pipeline (elevation -> mesh -> textures -> shading);
  TERRAIN2-02 donor terrain texture inventory/reuse;
  TERRAIN2-03 water/weather/fog/sky vs our flat quad;
  TERRAIN2-04 ranked gap recipe for current world3d_terrain.gd;
  TERRAIN2-05 exhaustive leftovers/open-questions to-do sweep.
- Hard rule reiterated: donor read-only, cite path:line, mark UNVERIFIED,
  never invent terrain values, no visual-parity claims without GPU A/B.

### USER BUG: minimap LMB -> black main view (V7-81 dispatched)
- User: clicking the middle of the minimap in windowed variant3d turns the main
  render area black. Diagnosed from source: camera3d.gd `_target` is TOP-LEFT sim
  metres (0..640) but `_apply_transform():161` uses it directly as CENTRED world
  X/Z while terrain spans -320..+320. Minimap centre sim (320,320) therefore
  places the camera at world (320,320) = terrain corner -> black.
- clamp_pos():323-344 also mixes frames (centred screen corners clamped against
  0..640 limit, delta written into sim target); bind():141 sets _target=ZERO (map
  corner, not centre).
- V7-81 owns camera3d.gd only: keep public API, subtract map half in transform,
  convert centred corner centre back to sim in clamp, initialise at map centre.
  Probe must assert minimap-centre jump lands near world centre, not (320,320).

### V7-79 pose memoization LANDED (main perf fix)
- world3d_entities.gd Pass 1 only: local pose_memo at :953-962, reuse at
  :982-999, telemetry :1064-1066. anim3d.gd read-only, untouched. All donor
  skins/tints/signatures and PORT APPROXIMATION labels preserved.
- Measured 200 units: 133.122 ms -> 11.175-16.270 ms/frame = 8.18x-11.91x;
  100 units 141.350 -> 7.514-15.931 ms. pose_for() calls/frame N -> 6.
  Morph delta donor frames 1->16 BYTE-IDENTICAL (118.295389942825); batches /
  cached meshes unchanged 36/36. Jobs BEFORE 196, AFTER 199/200, selftest 202
  29/29. Probe deleted. No visual parity claim.
- Combined with V7-80: expected windowed sync_ms drop from 12-20 ms to a few ms
  (final windowed measurement still UNVERIFIED).
- Post-perf final gate re-run launched (selftest + uitest + t_render_mode).

### V7-80 resource reconcile gate LANDED
- world3d.gd now gates the resource half of _reconcile_entities() on a direct
  translation of app game.gd:2642-2661 (res_dirty AND res_nodes.size() parity;
  app world.gd:2095-2104 cited for the 2D pattern). No invented 30-frame forced
  rescan or moved/fields_live clauses.
- Measured 12.54x on the gated reconcile at 200 units + 1200 res_nodes:
  4.18 ms -> 0.33 ms per frame (~3.85 ms removed). Parse PASS (195/201);
  probe 11/11 (197) confirms entity half still runs gate-closed, resources
  add/remove on res_dirty, size-only guard works, no-signal doubles keep old
  behaviour. Selftest 29/29 (198). Probe deleted. All dbg_*/ghost/rally intact.

### PERF-3D measured the sync hot path (audit only)
- Report `PERF3D_sync_hotpath.md`; temp probe deleted; no edits/git.
- #1 per-unit donor skin sampling `world3d_entities.gd:955-1000` ->
  anim3d.gd:489-530/410-459: **115.4-160.1 ms @ 200 units (0.58-0.80
  ms/unit), 90-98% of world.sync**. Every unit re-skins 531-1014 verts into a
  fresh PackedVector3Array even when sharing sid/action/donor frame. At 15-34
  skinned units this matches the user's 12-20 ms.
- #2 `_reconcile_entities()` full scan world3d.gd:305-355: 0.42 ms @ 200 units,
  3.92 ms @ 200 units + 1200 res_nodes.
- #3 transform writes 2.07-3.03 ms @ 200 units; the morph mesh rebuild is
  CACHED (entities.gd:571-573) and only 1.1-1.7 ms steady state.
- FX 0.02 ms, fog 0.003 ms, view_rect 0.01 ms — not bottlenecks.
- Dispatched V7-79 (memoize pose by sid/action/frame in entities+anim3d) and
  V7-80 (gate resource reconcile on game.res_dirty in world3d) — disjoint files.

### FINAL GATES RUN (functional green, honesty caveats intact)
- Variant: selftest 29/29 (last full 186 + 185), uitest 17/17 (191),
  t_render_mode PASS 10/10 seam_missing=false (193). Variant runner empty/lock
  free at end. 60 historical unacked probe-iteration failures remain; no
  variant assert_clean.py -> no formal variant CLEAN claimed.
- 2D app: uitest 17/17 (1341), clean CLEAN (0 processes, free lock, 9 acks).
  selftest job 1340 FAILED transiently (concurrent Godot contention with
  PERF-3D probe; exit 1, empty stderr, selftest.json still passed 29/29);
  rerun on quiet queue 1342 ok, 29/29. app/ files untouched all wave.
- `STATUS_WAVE7_PHASE2.md` got an authoritative FINAL VERDICT section at top;
  older sections are explicitly labelled historical snapshots.

### V7-78 donor skins SHIPPED — V7-74 caveat closed
- New `variant3d/tools/convert_skins.py` reads donor .oss + each unit's .aaf
  via read-only manifest paths; exports deterministic 6-frames/action subset
  using verbatim bake_sprites decimation. 55 per-sid c3_skin_v1 JSON + index
  in `variant3d/assets/models/skin/`, 3,746,538 bytes total, byte-deterministic
  (SHA-256 verified). 7 ship hulls skipped (.osm, no skin tracks).
- anim3d.gd lazy `_ensure_shipped_skins()` on first bind/has_skin/pose_for;
  per-unit AAF ranges + nearest-exported-frame snapping; no edits to other files.
- Parse PASS (176/184). Probe 24/24 PASS (181) with ZERO manual registrations:
  auto-loaded 55 skins; idle 64->74 changed 733/733 verts (max 0.02205 m);
  walk 1->9 changed 733/733 (max 0.391075552 m, Python donor recheck
  0.391075624 m; V7-74 frames 1->10 value reproduces exactly). Selftest 29/29 (186).
- Honest: still flat-root PORT APPROXIMATION — NOT DONOR PARITY, visual
  UNVERIFIED; N=6 no interpolation; ships static; tools unskinned; perf unchanged.

### USER WINDOWED RUN — clean, new perf target
- User pasted live windowed output: NO SCRIPT ERROR. The expected deliberate
  flat-root morph WARNING appears (world3d_entities.gd:206), and PERF lines now
  print correctly (e.g. r/b/u/f=299/6/16/0 then FX counts), confirming the
  dbg_* fix. Measured `sync_ms=12.65..20.06` vs tick_ms ~1-2 ms — the main
  remaining perf target, likely per-frame donor morph mesh rebuild.
- PERF-3D audit-only agent dispatched to measure per-stage sync costs via
  variant runner and propose minimal fixes; no edits yet.

### USER-REPORTED RUNTIME ERROR FIXED (dbg_res)
- User saw repeated `Invalid access to property or key 'dbg_res' on ... Node3D
  (world3d.gd)` at `main.gd:1592` in the windowed game after ~120 frames.
- Root cause: unbranched PERF debug print in main.gd reads/resets four 2D world
  counters (`dbg_res`, `dbg_bld`, `dbg_unit`, `dbg_fx`; app world.gd:59-62)
  that world3d.gd never declared.
- Fix applied directly in `variant3d/scripts/world3d.gd`: declare all four ints
  with citations, increment unit/building in _reconcile_entities (2D analogues
  world.gd:3227/2836), resource at add_resource (:2696), FX in add_fx (:3582).
- Verified via variant runner: parse PASS (182), direct property-access probe
  PASS (183, stdout `DBG_PROBE PASS`, stderr empty), full selftest PASS (185,
  passed:true 29/29), no dbg/Invalid access lines in stderr. Probe deleted.

### V7-70 3D VIEWPORT CAPTURE + SNAPSHOT + E19 LANDED
- P0 G1 CLOSED: windowed 3D capture now saves genuine GPU pixels from a
  dedicated Screenshot3DViewport (jobs 138/179). Root cause: blank backbuffer +
  camera target in sim metres vs +-320 m centred terrain. Blank 3D captures now
  fail loudly; CPU map remains headless/2D-only. Donor visual parity UNVERIFIED.
- Snapshot: canonical w52-self-base-2 / var_to_str / Rect2 / float32 compare
  restored from app; dump round-trip + check + self-snapshot OK (147/148/153).
- E19: journey 3D routes sim metres through jump_to_world(); 2D byte-identical
  (probes 173/175). Selftest 29/29 (143/177); parse clean (171). No git ops.

### V7-77 E6 zoom anchor — HONEST NON-RESULT
- camera3d.gd zoom anchor now resolves terrain height via guarded dynamic
  sampler (height_at_world centred metres; game.height_at with map-centre
  offset; no sampler -> explicit 0.0 flat fallback). Public APIs/defaults and
  V7-66 jump_to_world unchanged. Parse PASS (172); probe 12/12 (174).
- BUT measured drift on sloped stub: before 0.0001 px / 0.00000 m -> after
  0.0024 px / 0.00008 m. Anchored point stayed under cursor in BOTH cases:
  the old flat correction preserved the whole view ray, so E6's drift premise
  is an OPEN QUESTION, not a fixed bug. No improvement claimed.

### V7-74 donor poses CONSUMED — with one shipping caveat
- entities sync() calls anim3d.pose_for(e, action, t) per unit at donor 30 fps,
  rebuilds the unit mesh from real donor flat-root verts via V764 §4 transform,
  migrates to a frame-keyed MultiMesh batch; V7-65 tints + 6 signatures intact.
- Probe 20/20 PASS (161): real peaukr.oss walk frames 1->10 changed
  733/733 rendered verts, max 0.295301526784897 m (matches V764 exactly),
  mean 0.1065164 m. Parse PASS (162); selftest 29/29 (163).
- CAVEAT §7: shipped runtime has NO REGISTERED SKIN, so morph only appeared
  because the probe registered one manually. V7-78 dispatched to export donor
  skin data as runtime assets and auto-register it (anim3d + new converter +
  new assets only).

### V7-76 ghost/rally visuals LANDED
- world3d.gd 527 -> 682 lines; sync() now translates the exact 2D triggers
  (app world.gd:3464-3509, :3602-3613) and calls fx.draw_ghost / draw_rally;
  ghost ground point from Camera3D.screen_to_world(mouse) (camera3d.gd:167-176),
  optional set_build_ghost_pos() handoff documented.
- Probe PASS (152/155): ghost false->true, rally markers 0->1,
  FX MeshInstance3D 1->5, ghost_shown 0->1, rally_active 0->1. Parse PASS (145);
  selftest 29/29 (157). Probe deleted. No visual parity claim; 2D can_place
  throttle deliberately not copied.

### V7-75 pick caller + E18 LANDED
- input_controller.gd 3D `_pick()` forwards players_only to picking3d; 2D
  untouched, no cmd_* changes. E18 shift+group now calls jump_to_world(metres)
  instead of writing Vector2 into Camera3D.global_position.
- Parse PASS (140); probe 5/5 (141): true->true, false->false, omitted->true,
  screen pixel forwarded; selftest 29/29 (144); E18 probe 2/2 (149/151) with
  2D still (480,640). Probes deleted.
- Open: E6 camera3d.gd:361-394 flat Y=0 zoom anchor -> V7-77; E19 main.gd:1626-
  1627 journey-mode Vector2->Vector3 lerp + wrong view_scale -> V7-70.

### V7-73 FX world offset FIXED
- `world3d_fx.gd.bind()` now derives world_offset from game.MAP_W/MAP_H
  (320x320 -> (320,320) m), matching world3d_entities.gd:541 / terrain:307-314;
  optional explicit bind offset + set_world_offset() shifts live nodes.
  V7-65 donor tints preserved.
- Measured error before (320,320) m / 452.548 m magnitude -> after (0,0) m /
  0.000 m; FX at sim (100,240) renders at expected (-220,0,-80).
- Parse PASS (133); probe 7/7 (134); existing t_fx3d 13/13 (135). Probe deleted.
  No world3d.gd edit needed; no visual parity claim.

### V7-62 entity feed + world contract LANDED (biggest P0 closed)
- `world3d.gd` 331 -> 527 lines. Probe: 0 -> 5 REAL entity mesh nodes
  (2 units + 1 building + 2 resources), dropping to 4 after removal; selection
  mirror [7001,7002] -> [7001]; view_rect with Vector2 corners now
  (160,160,320,320) instead of full map; all 8 added contract methods present.
- `int()` root cause fixed by extracting "id" from entity Dictionaries (no
  blanket cast); error gone from stderr. Parse PASS (109); selftest 29/29 PASS
  (130), no missing-contract errors. Probe/result deleted; no visual claim.
- V7-76 dispatched to wire the remaining dead draw_ghost/draw_rally APIs using
  world3d.gd (current file preserved).

### V7-68 picking players_only FIXED
- `picking3d.gd.pick(screen, players_only := true)` now honors the 2D flag
  (`if not players_only or player == 0`, app input_controller.gd:358); fallback
  reach converted per candidate instead of fixed 30 m.
- Parse PASS (129); probe 127: pick(true)->friendly id 10, pick(false)->enemy
  id 20, default->friendly, pick_res()->resource 77, no cmd_* calls. Probe deleted.
- OPEN handoff: input_controller.gd:396 still calls pick without forwarding the
  flag -> V7-75 dispatched. E6/E18/E19 (zoom-at-cursor, shift+group, journey
  mode) traced to camera3d.gd/main.gd, documented as handoffs.

### V7-65 donor player tints LANDED
- Donor JSON loaded at runtime; player mapping is identity `entity.player ->
  gKeyColor[slot]`, evidenced from app game.gd:1988-1992,378-389, world.gd:2172-
  2182, data.gd:225-239 — no nation mapping exists.
- All six public signatures unchanged; batch key extended internally to
  `unit|sid|p<player>`; resources untinted; load failure = push_error + no tint
  (no invented fallback palette). FX invented palette removed, rally pennant
  uses donor values; non-player FX untouched.
- Fixed relayed entity errors at :590/:624 (explicit Variant, not suppressed)
  and a MultiMeshInstance3D material_override runtime error found by probe.
- Parse PASS (100/101/115); probe 21/21 PASS (116, deleted); selftest 29/29
  PASS (122) with ticket-86 errors gone. Alpha, >1.0 clamping, uniform-0
  semantics UNVERIFIED.
- Follow-ups dispatched now that files are free: V7-73 FX world_offset (P0),
  V7-74 consume donor poses (P0) — both strictly one file each.

### V7-71 audio 3D fix LANDED
- audio.gd: Vector3->Vector2 horizontal (x,z) for ambient centre (old :153)
  and a 3D-aware get_camera_3d() culling branch (old :318); 2D statements
  byte-identical, no new constants/RNG.
- Parse PASS (97); stub Camera3D probe 6/6 PASS (117, deleted); full selftest
  29/29 PASS (121). Open: true 3D positional audio / AudioStreamPlayer3D
  and donor emitter semantics (sound.script:418,515) NOT implemented.

### Minimap P0 END-TO-END CONTRACT VERIFIED
- V7-67 trace: hud.gd:1403-1404 normalized mouse -> tile*TILE_M (2.0,
  data.gd:23) = sim metres top-left, byte-identical to app hud.gd:1369-1370;
  :1453 passes the unchanged value as ONE Vector2 to jump_to_world, no
  view_scale. camera3d.gd:215-223 assigns _target directly, no view_scale.
  get_minimap_box() only affects the post-jump redraw box, not the jump value.
  V7-67's open question resolved; no edits needed.

### V7-66 camera jump API LANDED
- `camera3d.gd:208-223` public `jump_to_world(world_pos: Vector2)` sets target,
  applies transform, resets clamp memo, clears zoom anchor. API contract: ONE
  arg in sim metres, top-left origin — do NOT pass view_scale.
- `input_controller.gd:226-233` 3D branch calls it dynamically; 2D block
  byte-identical. Parse PASS (85/87), runtime probe 11/11 PASS (114): two jumps
  moved 316.2 m, memo stable, out-of-map clamped inside 640x640 m. Probe deleted.
- `t_camera3d.gd` has a PRE-EXISTING `_initialize()` tree-timing failure unrelated
  to this diff — needs separate triage at final gate.
- V7-67 compatibility check dispatched (exact one-arg sim-metre call).

### V7-72 new OBJ imports VERIFIED
- Headless import via variant runner only: job `v772-editor-import` (104) exit 0
  using `--headless --path variant3d --import` (CLI syntax pre-checked, 98).
- `.obj.import` 116 -> 172 (+56); `.png.import` 116 -> 172 (+56); 0 missing;
  stderr empty. Probe (113): module reports `obj_available = 172`, all 56/56
  new sids true, 5 sampled assets load() as Mesh; temp probe deleted.
- Open: GLB lane empty; bar18/dock still have no donor actor; entity feed (G2)
  unchanged until V7-62 lands.

### V7-69 snapshot regression FIXED — VERIFIED DONE
- Root cause in variant3d/scripts/main.gd:760-769 (regressed w52-self-base-1 +
  JSON.stringify, no _json_rect, plain float compare, raw-path checks); fixed
  concurrently by V7-70 (ticket 102 parse). V7-69 restored the owned artefact
  `variant3d/tests/results/w52_self_base.json` byte-identically to canonical
  sha256 d807526f... (w52-self-base-2, native Rect2). app/selftest.json hash
  unchanged.
- Verification (variant runner): job 91 selftest 29/29 (all step names/details/
  flags identical to app, only timing differs). BEFORE: job 92 no SELF-SNAPSHOT
  line, full mapgen 53.07 s; job 93 MISMATCH/bad format. AFTER: job 111
  `SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)` +
  `check: OK`, stderr empty; job 110 same subset fast path 25.92 s (-51%).
- Open: no direct `first difference at ...block_rect` log captured; sim_seconds
  variance UNVERIFIED.

### V7-69 snapshot verification — interim PASS
- Job 91 (`v769-selftest-snapshot`) ok, 29/29; all step names/details/passed
  flags byte-identical to canonical app/selftest.json (only timing differs);
  app hash unchanged. No SELF-SNAPSHOT/fallback lines in a full run (expected:
  snapshot path is subset-only). Two subset diagnostic jobs still queued;
  lossy Rect2 source in main.gd:752-769 already relayed to V7-70.

### V7-60 donor light rig LANDED
- `_make_environment()` ported verbatim from heightmap_world3d.gd:114-147 into
  wired `world3d_terrain.gd` and called from build() at :347; donor citations
  light.cfg:3-16,26-29 and water.dev.vert:22 preserved, no invented values.
- Backup `inbox/backup/world3d_terrain.gd.bak-V760`; parse PASS (79); node-tree
  probe 19/19 PASS (90) with measured HeightmapTerrain, WaterPlane,
  WorldEnvironment, DonorSun and donor-valued sky/sun properties.
- Honest open questions: donor Z-up→Y-up comment conflicts with verbatim Z-up
  expression (not corrected); ambient/diffuse constants recorded but unused;
  emission floor unchanged; visual parity UNVERIFIED.

### V7-67 minimap 3D jump LANDED
- hud.gd 3D-only guard at :1405-1410 + `_minimap_jump_3d()` / `_cam3d_jump()`
  helpers; calls `cam.call("jump_to_world", world_pos)` guarded by has_method,
  so it degrades safely until V7-66 lands. 2D handler byte-identical to app
  (1002/1002 chars). Parse PASS (83); selftest 29/29 PASS (86).
- Selftest stderr still shows world3d_entities.gd:573,606 errors -> relayed to
  V7-65; world3d.gd:207 -> V7-62.

### V7-63 missing models LANDED
- Roster unit/building OBJ coverage 23/81 -> 79/81 (missing 58 -> 2).
- Manifest 116 -> 172 (unit 9->62, building 14->17, env 93 unchanged).
- 56 new donors converted: 46 .oss units + 7 .osm naval hulls + 3 .osm
  buildings; 168 new asset files. Original 116 outputs 348/348 byte-identical;
  app/ manifest untouched (116 entries); 0 2D bake/sprite outputs.
- Still absent (not unreadable): `bar18` (no ukrba2/eurba2/turba2 actor) and
  `dock` (no shipyard actor; Shipyard in units.txt:975 is only a label).
- Caveat: 56 new OBJs lack .import caches -> V7-72 dispatched to run the
  project's own headless editor import via variant runner + probe obj_available.

### V7-64 donor morph animation LANDED
- `anim3d.gd` rewritten: GDScript translation of donor `bake_sprites.read_oss` /
  `qmat` / `skin` / `sample`; `pose_for(e, action, t)` returns the real skinned
  vertex array for the resolved AAF frame.
- Measured: parse exit 0 (80); behaviour probe 17/17 PASS (82); real donor
  `peaukr.oss` (k=483,fps=30,b=20,v=577, exact 312,376-byte closure); donor
  walk frames 1->10 changed 577/577 verts, max 0.2953 m, mean 0.1037 m,
  cross-checked with independent Python re-implementation.
- Honest label kept: flat-root `PORT APPROXIMATION — NOT DONOR PARITY`, bone
  parents unreadable, visual UNVERIFIED. Consumer integration into
  world3d_entities.gd queued after V7-65 frees that file (handoff in V764 §4).

### ALL 9 AUDITS IN — consolidated triage written
- `AUDIT3D_TRIAGE.md` created with verified-good list, 10 P0s, 11 P1s, 4 P2s
  and per-gap assignment/state. No git operations.
- AUDIT3D-06 (FX/anim/audio): 2D audio bed fully preserved (identical audio.gd
  hash, 325 ogg clips, event dispatch). But P0: FX ~320 m off target because
  `world_offset` never set (world3d_fx.gd:90,227-236) -> queued as follow-up to
  V7-65 (same file). P0: draw_ghost/draw_rally/play_anim have no runtime callers
  -> queued after V7-62/65/66. P1: no 3D positional audio; audio.gd:318 looks
  for Camera2D -> relayed to V7-71 along with the Vector3 fix. Donor PFX size/
  lifetime/colour/count unconsumed; only 3 unverified bullettrail literals used.

### AUDIT3D-09 runtime proof — 3D nodes real, PIXELS UNVERIFIED
- Measured (variant runner): clean headless boot (72); 3D-default selftest PASS
  (76); real node tree with Node3D + MeshInstance3D x4 + Camera3D +
  DirectionalLight3D + WorldEnvironment (75); real OpenGL 3.3 context in
  windowed mode (73).
- P0 G1: BOTH screenshot paths end in CPU 2D map fallback — headless by design
  (main.gd:1716-1725), windowed because viewport capture was blank
  (main.gd:1749-1752). No genuine 3D image proof -> V7-70 dispatched (main.gd).
- P1 G2: per-frame `int()` constructor error at world3d.gd:207, exact cause
  `int(id)` on entity Dictionaries from game.gd:2585-2590 -> relayed to V7-62.
- P1 G3: windowed-only Vector3->Vector2 error at audio.gd:153 (cam is Camera3D)
  -> V7-71 dispatched.

### AUDIT3D-04 / 05 / 07 results
- AUDIT3D-04: core sim BYTE-IDENTICAL (14/21 common scripts incl. game.gd,
  ai.gd, world.gd; all 29 selftest step details match; config differs only by
  render_mode). Gaps: P0 incomplete 3D world contract (missing _update_fog,
  mark_rally_dirty, fog_revision, fog_sprite, terrain_chunks, _anim_dir etc.
  called unbranched from main.gd:1331/1418-1442, input_controller.gd:609/634,
  hud.gd:1741) -> added to V7-62; P1 picking loses players_only=false
  (picking3d.gd:208-236) -> V7-68; P1 self-snapshot regression to
  w52-self-base-1 + lossy block_rect string -> V7-69.
- AUDIT3D-05: donor zoom bounds/tilt/edge-scroll match 2D; all cmd_* paths
  inherited; no double-binding (bind_3d idempotent). P0 minimap camera jump
  no-op in 3D (hud.gd:1397-1415 + input_controller.gd:222-232) -> V7-66/V7-67.
  P1s: view_rect full-map (to V7-62), fog quad height/centre mismatch and
  missing fog_revision, fixed-depth pick fallback, assumed FOV, missing
  selection-rect/patrol overlays.
- AUDIT3D-07: RESOURCE INTEGRITY SOUND, NO P0. project.godot files differ only
  in name/description. 306 res:// refs scanned: 278 resolve; 28 non-resolving
  are 9 dynamic UNVERIFIED + 19 benign (comments, guarded legacy, shots writes,
  guarded GLB_DIR, one test output). Full .import coverage for importables;
  DDS correctly .gdignore'd. P1 conditional: .gitignore excludes 4236 legacy
  sprite files referenced by 2D world.gd — tracking UNVERIFIED (no git used).
  P2s: shots/ dir never created; 17 .gd lack .uid sidecars; 2099 .ctex absent.

### V7-61 donor key colours EXTRACTED
- `variant3d/data/donor_key_colors.json`: 13 exact player slots, normalised
  RGB floats (channel*koef/255) from classes.script:7986-8015; donor literals
  verified verbatim. Slot 3 inherits default koef 1.1 at :7988; slot 12 is
  mercenary. Case table has 14 entries but index 13 is unreachable per
  gc_MaxColorCount=13 / misc.script:5070 guard. Alpha UNVERIFIED.
- V7-65 dispatched: apply donor tints in world3d_entities.gd (batching keyed
  internally by player slot; public add_* signatures unchanged for V7-62) and
  replace invented FX palette in world3d_fx.gd; probe asserts two players differ.

### AUDIT3D-01 models — user-reported concern CONFIRMED
- V7-14 asset claim HOLDS: 116 manifest bboxes, 116 real donor-derived OBJ
  meshes (binary .oss/.osm geometry, NOT boxes/billboards), 0 GLB. "6 loaded"
  was only a 5-entity stub smoke, not coverage.
- BUT no production code calls add_unit/add_building, so a real 3D skirmish
  renders ZERO entity meshes. P0 -> V7-62 dispatched (entity feed in
  world3d.gd + fix `world3d.gd:207 Invalid call. Nonexistent 'int' constructor.`
  seen in the 3D selftest).
- 58/81 unit/building IDs have no OBJ -> invented 1 m cube. P0 ->
  V7-63 dispatched (extend variant3d/tools/convert_models.py from existing
  donor .oss/.osm). P1 animation discarded by converter -> V7-64 dispatched
  (donor-sampled morph poses via bake_sprites.skin, approximation labelled).

### AUDIT3D-08 donor coverage
- variant3d inherits the SAME donor-derived asset base as app/ (hardlinked
  assets + byte-identical sim scripts; only render_mode differs). 3D modules
  consume a subset. Readable but unused: light.cfg, colors.lib, weather,
  terrainmesh1..4.osm, shader text, donor team palette. Unreadable: .map
  relief, .oss bone parents, ACL/PFX semantics, absolute FOV. No .ani files
  exist in installed donor. Its light-rig P0 is already covered by V7-60;
  team-colour P1 by V7-61 + follow-up implementation.

### HUD 3D bind regression FIXED
- V7-53: hud.gd `bind(g, w: C3World)` and `var world: C3World` -> untyped;
  2D logic unchanged. Variant selftest with render_mode="3d": ticket 71 PASS,
  passed:true 29/29, no watchdog. Remaining stderr: pre-existing
  world3d.gd:207 'int' constructor error -> assigned to V7-62.

### AUDIT3D-02 colours — user-reported concern CONFIRMED
- 3D FX/rally colours DO reuse exact 2D RGB from app/scripts/world.gd, and unit
  albedo is donor-DDS-grounded via manifest.json. BUT no player/nation colour
  is donor-derived in EITHER port: real donor `gKeyColor` table
  (classes.script:7986-8015, 13 slots) is never read. Three mutually
  inconsistent invented palettes exist in app/ world.gd/menu.gd/hud.gd;
  variant3d copies one (world3d_fx.gd:67-74).
- P0: `world3d_entities.gd:170-188,321-336` batches by `sid` only, so donor
  recursive uniform-0 team tint (misc.script:5067-5081) cannot exist.
  P0: invented palette. P1: `draw_rally()` has no caller; no 3D selection
  ring/flag/stripe equivalents.
- V7-61 dispatched: extract the exact donor 13-slot key-colour table read-only
  into `variant3d/data/donor_key_colors.json` with citations; implementation
  into the 3D renderer follows after the data lands.

### AUDIT3D results arriving
- AUDIT3D-03 terrain: runtime is a real 102,400-vertex live-height grid;
  splat provenance SHA-256 matches g32_dump.json (same in app/ and variant3d/).
  Gaps: P0 no runtime WorldEnvironment/sun (donor rig stranded in unreferenced
  `heightmap_world3d.gd:114-147`) -> V7-60 dispatched to wire it; P1 static
  albedo baked from one seed with no consistency check; P1 flat water quad
  vs 2D port's animated diffusewaves shader. Visual parity UNVERIFIED.

### Launcher fix + 3D parity audit swarm (user-reported blocker)
- ROOT CAUSE of "launch3d variant bat launches nothing" FOUND and FIXED:
  1. `launch_variant3d.bat` routed an INTERACTIVE windowed game through the
     serialized test runner. That runner redirects stdout/stderr to spool files
     and resolves Godot as bare `shutil.which("godot")` -> godot is NOT on PATH
     here (only a WinGet symlink), so Popen fails and no window appears.
     It also calls `reap_spawned_godot()` which would taskkill a real game window.
     Replaced with the working direct-launch pattern from `launch.bat` (explicit
     WinGet/PATH/ProgramFiles resolution, foreground launch, args forwarded).
  2. Batch parse error: `(V7-0)` inside an `if not exist (...)` block closed the
     block early -> "is was unexpected at this time." Removed the parentheses.
  3. `variant3d/config.json` still defaulted to `render_mode: "2d"`, so even a
     working launcher showed the 2D renderer. Flipped to `"3d"` in variant3d
     ONLY; app/ untouched; main.gd source default stays "2d" for t_render_mode.
- VERIFIED: `launch_variant3d.bat --headless --quit` and the `launch_3d.bat` shim
  both exit 0 with Godot 4.7.2; `--dump-config` reports render_mode "3d";
  `--quit-after 10` clean. Full selftest with 3d config FAILED (ticket 69):
  `hud.bind()` typed world param rejects world3d.gd at main.gd:1043, watchdog
  forced exit -> fix routed to V7-53 (hud owner).
- Launched 9 parallel AUDIT3D agents (models, nation colours, terrain, sim
  parity, camera/HUD/picking, FX/anim/audio, resources, donor coverage, runtime
  proof). Charter: `AUDIT3D_CHARTER.md`; one report per agent under reports/.
  User's specific concern (unit/building models are placeholders, nation colour
  basis) is AUDIT3D-01/02.

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
