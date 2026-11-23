# T6 WATER LANE — live state (parent T6-WATER)

Parent session: `ses_df839d7cfffesnEmyvs0mmm99d`. Protocol: `SWARM_OPS.md` §7
(recursive swarm), §5b-QUALITY (evidence before edits), `app/tools/AGENT_PROTOCOL.md`.
Owner directive: current water effects are NOT acceptable — dedicated deep
investigation + re-port, **piece by piece**. No Godot launches in this lane until
integration (W04); headless Pillow work is fully parallel.

## Owned / boundary

- Parent owns **only** `docs/t6/WATER_LANE.md` and the W04 integration request.
- Children own only the files named below. Reports: `docs/t6/reports/<ID>.md`.
- READ-ONLY for this lane: `app/tools/terrain_piece_render.py`, `app/tools/piece_specs/**`,
  `app/scripts/world.gd`, `app/scripts/game.gd`, `app/shaders/water_overlay.gdshader`,
  all other lanes' files (`docs/t6/TERRAIN*`, `UNITS*`, `RUST*`, `RESEARCH*`, `QA*`,
  `app/tools/unit_bakers/**`, `rustport/**`), `SWARM_BOARD.md`, `SWARM_OPS.md`,
  `app/tools/AGENT_PROTOCOL.md`.
- Donor `C:\Games\Cossacks 3` = private use, read-only, NEVER copy into repo.
- Reference stills `C:\Users\Maxym.Oboyshev\Downloads\c3\` (primary water:
  `articolo-787.jpg` dark river, `maxresdefault_1.jpg` pale shallow + shore).
- Exact shader path (verified 2026-11-23): `app/shaders/water_overlay.gdshader`
  — **NOT** `app/scripts/shaders/...` as written in `docs/T6_WAVE_PLAN.md`.
  Backups exist: `inbox/backup/water_overlay.gdshader.bak-T2W`, `.bak-T3S`.
- Godot rule (binding): only via
  `python app\tools\godot_runner.py run --id t6water-<purpose> --timeout 180 -- <args>`.
  This lane needs **zero** until W04.

## Ticket table

| ID | Micro-task | sessionID | State | Owned outputs | Evidence / gate |
|---|---|---|---|---|---|
| T6-W01 | Donor water shader equation re-verification + resolve UNVERIFIED sampler→texture-unit bindings; confirm 9-octave fBm, depth ramp, glint stats, foam source | `ses_t6w01_donorshader` | **DONE 2026-11-23** (report written, verification PASS) | `docs/t6/reports/T6-W01.md` (READ-ONLY otherwise) | 26.6 KB report: donor inventory F1–F20 with byte sizes/lines; all WATER_REPORT §3 constants re-verified verbatim with file:line + byte offsets; binding table; exe byte scan + Craft Anything deep xref (0 matches); remaining UNVERIFIED U1–U6; §8 implications for W02 |
| T6-W02 | Headless water piece renderer: 9-octave fBm, depth colour, donor glint statistics, shore wash band + foam | `ses_t6w02_minibaker` | **REVIEW 2026-11-23** — report written; coordinator artifacts FIXED; parent found 2 further visual artifacts → bounded fix iteration running | `app/tools/pieces/t6_water.py` (NEW), `app/shots/pieces/t6_water*.png`, `docs/t6/reports/T6-W02.md` | Report: deep 14/16 PASS (D-GA-max 32px >12 FAIL), shore 11/13 PASS (M6/M7 superseded), shallow HARD gate (194,208,201) PASS, wash 34px/85@720p PASS, black 0, rings gone, determinism 6/6. NOT yet PASS — parent visual re-check found diagonal cross-hatch + sawtooth wash + over-textured deep body |
| T6-W03 | Reflection proxy design for the 2D engine (projected texture, NOT cubemap; decals are NOT reflections) | `ses_t6w03_reflection` | **DONE 2026-11-23** (report written, PASS) | `docs/t6/reports/T6-W03.md` (READ-ONLY) | Report delivered: donor projected-texture truth re-read; Compatibility `canvas_item` feasibility matrix F1–F11; z-order caveat CONFIRMED; primary P = SubViewport/ViewportTexture bake sampled as plain sampler2D with donor fetch tail + toggle; fallbacks F1/F2/F3(rejected)/F4; gates A1–A6 |
| T6-W04 | **INTEGRATION — GATED. DO NOT START.** One coordinator-granted builder owns `app/shaders/water_overlay.gdshader` | — | BLOCKED on W01 verification + W02 PASS | shader + captures | Parent writes an INTEGRATION REQUEST here naming exact shader + parameter changes with evidence; coordinator grants the builder. Parent never edits engine shaders. |

## Supervision log (parent keeps current)

- 2026-11-23: read all mandatory docs; confirmed `subagent` tool is not exposed in
  this runtime — children spawned as background OpenCode sessions via
  `opencode run --agent general --model opencode/hy4-flash-free --session <id> ...`
  (session IDs recorded above). Notifications arrive on child idle; parent reads
  report files, pings by sessionID, and re-spawns on `opencode-go/muse-spark-1.3-contributor#high`
  after 2 failures or >20 min silence.
- 2026-11-23: W02 started from the `WATER_REPORT.md` transcription immediately and
  will reconcile against W01 when that report lands (no idle wait).
- 2026-11-23: the `subagent` tool is NOT exposed in this runtime, so spawning is done
  with `opencode run --agent general --model ... --session <id> --auto <prompt>` as
  background shell sessions (IDs recorded above). First two spawn attempts per child
  failed: attempt 1 used an invalid `--prompt` flag; attempt 2 hit "Free usage limit
  reached" for `opencode/hy4-flash-free`. Per §7.3.4 (2 failures) all three identical
  micro-tasks were escalated to `opencode-go/muse-spark-1.3-contributor#high`; all
  three are confirmed running (logs show reads of the assigned source docs).
- 2026-11-23: **W03 DONE** — `docs/t6/reports/T6-W03.md` (31,598 B) written, only
  file touched. Key results: z-order caveat CONFIRMED (overlay z=-9 draws before all
  casters, so `hint_screen_texture` contains only baked terrain + clear — NOT a
  reflection); recommended primary = offscreen `SubViewport`→`ViewportTexture`
  sampled as ordinary `sampler2D` with donor `SCREEN_UV - wavejitter_uv` fetch,
  unweighted `r+g+b` × hdrMultiplier=1 gain, additive, `reflection_enabled` toggle;
  cubemap rejected for water; A1–A6 gates defined. Flagged O6: `water.lib:32-33`
  `texScaleS=0.1` vs `water.dev.frag:187` comment 0.105 — W02 must pin this.
- 2026-11-23: W01 still active (byte-offset dumps of donor `water.lib`/`water.mat`);
  W02 still active (`app/tools/pieces/t6_water.py` created, first render in progress).
  W02 hit a harmless PowerShell `tail` alias error in one shell command.
- 2026-11-23: **W01 DONE** — `docs/t6/reports/T6-W01.md` (26,596 B), only file
  touched. No numeric error found in WATER_REPORT §3; `.dev` pair confirmed
  (`water.lib:67-68`, offsets 1859/1923) with byte offsets for every constant;
  `waveMap`=`diffusewaves0` and `hmapTex`=engine height field functionally
  resolved; foam has no texture asset; TGA alpha re-proven constant 255.
  `reflectionMap` provenance and all numeric texture-unit bindings remain
  **UNVERIFIED** after TWO independent methods (exe byte scan + Craft Anything
  deep xref returning 0 matches). New: exe embeds the legacy Fresnel pair, not
  `.dev` — supports file-loaded `.dev` but does not prove runtime preference.
- 2026-11-23: **COORDINATOR DIRECTIVES ACKNOWLEDGED** (message to lane parent):
  1. W03 milestone ACCEPTED.
  2. New/replacement child spawns prefer `opencode-go/hy4-flash-free`
     (`opencode/hy4-flash-free` is quota-blocked); re-read SWARM_OPS §7.2 — done.
     Existing muse-spark children may finish current tasks; later micro-tasks
     use the preferred model first. (No new spawn needed since: W01 already
     settled texScaleS from `water.lib` bytes — see below.)
  3. HOST FIX sent as follow-up to all ACTIVE children (only W02): `python`
     (3.14) only, never `python3` (Microsoft-Store alias trap); also no `tail`.
  4. Conflict adjudication recorded below: shallow `#C3D1CA` HARD gate;
     `#696B65`/`#A8B1AB` report-only. Glint fraction + wash width: W01 now
     settles donor truth from shader constants; W02 reports AND scores both
     documented bands, no faked pass.
  5. texScaleS discrepancy **already settled by W01** §2.1: `water.lib:32-33`
     `TexScaleS = 0.1`, `TexScaleT = 0.01` (`observed`, byte offsets recorded);
     the `0.105` at `water.dev.frag:187` is only a comment — observed wins.
     No re-spawn required; sent to W02 in the follow-up.
  6. W04 remains GATED until W01 verification + W02 PASS are both evidenced.
- 2026-11-23: W01-vs-W03 conflict adjudicated by parent: W01 §8.4 suggests a
  `hint_screen_texture` projected sample as the reflection *form*, but W03
  (reflection design owner) proved that in the shipping 2D tree this contains
  only baked terrain (overlay z=-9 draws before all casters) and is NOT a
  reflection. **W03's verdict governs W04**; W01's statement is donor-form only.
  W02 was told not to add any reflection layer to its piece.
- 2026-11-23: **COORDINATOR VISUAL SPOT-CHECK** of staged
  `app/shots/pieces/t6_water_shore_compare.png` (~10:54) relayed verbatim to W02
  as a second follow-up (defect guidance, not a verdict override). Two objective
  artifacts MUST be fixed before any PASS:
  1. **Hard black jagged band** at the sand/water interface — donor has no black
     band. Mask/alpha compositing bug in the shore collar (zero-alpha gap rendered
     black, or band geometry gap). Required sequence: dry sand -> wet sand ->
     wash -> shallow, continuous, no black pixels, no constant run >8 px.
  2. **Concentric ring pattern** in the water body — radial synthesis, NOT the
     donor wave field. Replace with texture-sampled scrolled `diffusewaves0`
     9-octave fBm exactly per W01 §2 (noise(p)=waveMap(p/256).x; weighted sum
     0.6/0.25/0.1666 with m=(0.72,-1.60,1.60,0.72); sine swell; 9x loop
     p=m*p*0.947, amp*=0.59, s*=-1.329; shifts (0.32t,0.24t)/(0.38t,-0.26t)).
     `water_shallow.md`'s old radial-sine arc approximation is superseded for the
     water body. Check the deep-water compare sheet too — likely shares the rings.
  Hard gates unchanged: #C3D1CA HARD gate; wash widths both bands; glint both
  bands; metrics AND visual required, no PASS with either artifact. W02 must add
  a SPOT-CHECK FIX section to its report with before/after evidence and re-score.
- 2026-11-23: **W02 report delivered** (`docs/t6/reports/T6-W02.md`). Both
  coordinator artifacts verified FIXED: black band root cause = unpainted sand
  band (now a continuous dry→wet gradient; black_px=0, profile continuous,
  max run 7px); rings root cause = radial-sine approximation (term deleted,
  body now uses the same donor 9-octave texture-sampled `water_map` as deep,
  grep-clean). Deep 14/16 PASS: mean (44.18,53.18,55.18), G−R 9.0/B−R 11.0,
  std 7.37, |dL| 1.87, ACF lag1 0.920 with coherent peak lag 11, band-A
  fraction 0.3048%/median 5/88.9% coherent/69 comps ≥5px, band-B 0.0137%,
  sun-linkage Δ5.3px, determinism 6/6 byte-identical. Shore 11/13 PASS:
  HARD gate (194.2,208.2,201.2), saturation 0.067, wash 34px / 85@720p,
  sand 26px / 65@720p, 3 bands, black 0, rings gone, zero foam >1.07 m.
  W01 reconciliation: zero constant changes; `.dev` pinned; texScaleS/T
  observed 0.1/0.01; 260/180 piece glint exponents documented as a DEVIATION
  from donor 170/120 (CPU cusp-field evidence; needs W04 in-engine check).
- 2026-11-23: **PARENT VISUAL RE-CHECK** of the regenerated compare sheets found
  two further artifacts not covered by the coordinator spot-check, relayed to W02
  as a bounded fix iteration: (A) dense diagonal cross-hatch/moiré in BOTH water
  bodies versus the donor's smooth banding — likely the donor crossing-swell
  evaluated at too-high frequency in the P_SPAN=230 mapping; lower its spatial
  frequency / amplitude without restoring rings; (B) sawtooth wash boundary in
  the shore piece (~8px triangular teeth) versus the donor's soft blurred wash —
  soften the contour while keeping widths/3-band/zero-black; plus (C) deep body
  over-textured versus the donor's near-flat slate — reduce visible body contrast
  while keeping the numeric bands.
- 2026-11-23: metric adjudications recorded: **S-M6/M7 SUPERSEDED** (the
  coordinator ruled radial arcs are not donor behaviour, so the old
  `water_shallow.md` 6px-arc/33-level depiction metrics no longer apply to the
  body; re-label N/A, not FAIL). **D-GA-max 32px >12px remains a genuine FAIL**
  — W02 must attempt a fix without regressing other glint stats, else keep FAIL
  and report why (no manufactured pass). W02 state set to REVIEW; W04 still gated.

## Conflict adjudications (coordinator / parent — binding)

1. **Shallow gate — RESOLVED**: `#C3D1CA` (195,209,202) is the **HARD gate**
   (T2 coordinator palette decision, `SWARM_BOARD.md`). `#696B65` (contaminated
   minimap crop) and `shore_water_transition.md` plateau `#A8B1AB` are
   **report-only context**, not alternative gates.
2. **Glint fraction — donor truth SETTLED by W01 from shader constants**
   (exponents 170/120, grey (0.4,0.4,0.4), per-pixel `rd`, corona divisor, max
   analytic add ≈0.65 linear). W02 must still **report and score BOTH** documented
   acceptance bands (`WATER_PORT_FIX §4a` 0.30–0.80 % and `water_glints §5 A1`
   ≤0.30 % and >0) and never manufacture a pass. Both refs measured 0 isolated
   glints in clean river; the donor's analytic budget is sparse.
3. **Wash width — both bands still reported**: `water_shallow.md M5` 30–50 px
   (source 512×288 px) vs `shore_water_transition.md C2` 80 px @720p (accept
   60–90). Donor shader truth from W01: coastfade 0.57 m / deepfade 1.07 m;
   shore height band 0.15 m (`texturemap.inc:30-31`). Report both bands.
4. **Shader variant**: `water.lib:67-68` names `.dev` (W01 byte-offset verified);
   retail binary preference is **UNVERIFIED** (exe embeds legacy pair, no `.dev`
   strings). Pin `.dev` constants; never mix in the debug `water.frag`.
5. **texScaleS — RESOLVED**: `0.1` from `water.lib:32-33` (`observed`) wins over
   the `0.105` comment at `water.dev.frag:187`; W01 already verified the bytes.
6. **Reflection form vs portability**: W01's donor-form statement does NOT
   override W03's 2D z-order finding. W03 governs W04; no reflection in W02's piece.
