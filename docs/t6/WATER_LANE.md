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
| T6-W02 | Headless water piece renderer: 9-octave fBm, depth colour, donor glint statistics, shore wash band + foam | `ses_t6w02_minibaker` | **ACCEPTED-WITH-DEVIATION 2026-11-23** (parent visual re-check PASS; 1 open metric deviation) | `app/tools/pieces/t6_water.py` (NEW), `app/shots/pieces/t6_water*.png`, `docs/t6/reports/T6-W02.md` | Final: all 4 visual artifacts fixed and parent-verified (no black band, no rings, no diagonal moiré, no sawtooth wash); deep mean (44.22,53.22,55.15), ACF lag1 0.929, glint bands A/B stats, shallow HARD gate (194,208,201), wash 34px/85@720p, determinism 6/6. D-ACFP N/A (adjudicated below). **D-GA-max 32px >12px = OPEN GENUINE FAIL** — coordinator/owner visual waiver requested before W04 builder grant |
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
- 2026-11-23: **PARENT FINAL VISUAL RE-CHECK PASS** — I visually inspected the
  regenerated `t6_water_shore_compare.png` and `t6_water_deep_compare_clean.png`:
  all four artifacts are gone (no black band, no concentric rings, no diagonal
  moiré/cross-hatch, no sawtooth wash). Shore edge is now a soft organic wave;
  deep body is smooth cellular slate with sparse neutral glints; palette matches
  the donor reference panels closely. All hard gates measured PASS: deep mean
  (44.22,53.22,55.15), std 7.54, |dL| 1.48, ACF lag1 0.929, glint band A
  0.3220%/median 4/86% coherent/65 comps ≥5px, band B 0.0153%; shore HARD gate
  (194.0,208.0,201.0), sat 0.067, wash 34px/85@720p, sand 26px/65@720p,
  3 bands, max run 1px, 57 foam px (+12.7 L), 0 black px, 0 foam beyond 1.07 m;
  determinism 6/6 byte-identical hashes.
- 2026-11-23: **D-ACFP ADJUDICATED N/A (superseded as written)** — parent ruling
  with evidence: (a) both donor reference ACFs decay MONOTONICALLY and have no
  interior local peak at lag 6–14 (`WATER_PORT_FIX.md` §1d: dark river
  0.801→0.552→0.421→0.349→0.328; pale 0.730→0.549→0.462→0.249→0.066), so the
  "6–14px peak" was a diagnostic proxy for non-aliased coherence, never an
  observed donor property; (b) W02 proved by 9 grid probes + body-only A/B that
  producing the peak requires injecting a 5.6px directional swell which creates
  the diagonal striping the parent visual gate forbids; (c) SWARM_OPS §7.6.1 —
  metrics never override visual review; (d) the anti-aliasing intent is met by
  ACF lag1 0.929 + monotonic slow decay. Replacement check recorded: high lag1
  with non-flat decay (not white noise). W02 correctly reported FAIL rather than
  self-adjudicating.
- 2026-11-23: **OPEN DEVIATION — D-GA-max**: largest band-A glint component
  32px vs ≤12px cap remains a genuine metric FAIL. W02's evidence: the 32px
  zones are swell-tilt alignment plateaus whose cores hold bright-neutral
  pixels (bmax 7), i.e. sun-glitter patches, not white foam; the ≤12px cap was
  a foam-confusion guard, and both donor stills show ZERO isolated glints.
  I did NOT waive it. W02 state = ACCEPTED-WITH-DEVIATION (visual + all hard
  gates PASS); **coordinator/owner visual sign-off required before a W04
  builder is granted**. W04 integration request prepared below.

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

---

## W04 INTEGRATION REQUEST — PREPARED, NOT YET GRANTED (parent never edits shaders)

**Status:** ready for coordinator decision. W01 verification is evidenced
(`docs/t6/reports/T6-W01.md`); W02 visual + hard gates PASS
(`docs/t6/reports/T6-W02.md`). **One open deviation (D-GA-max 32px >12px)
requires coordinator/owner visual sign-off before a builder is granted.**

**Single shader file to change:** `app/shaders/water_overlay.gdshader`
(exact path verified; the plan's `app/scripts/shaders/...` is wrong).
Backups already present: `inbox/backup/water_overlay.gdshader.bak-T2W`,
`.bak-T3S`; the builder must create `inbox/backup/water_overlay.gdshader.bak-T6W04`
before editing. **World.gd and all other shared files stay READ-ONLY for this
builder** (see dependency D1 below — separate coordinator grant required).

**Evidence base:** W01 §2 (byte-offset-pinned donor equations) + §8; W02 §4–§7
(verified equations, measured piece gates); WATER_REPORT §5 gap rows 1–18;
WATER_PORT_FIX §3 P1–P11 / §4; W03 §4 (reflection proxy, gated separately).

### Exact parameter / shader changes (in shader order)

1. **Noise source (gap rows 1, 13).** Bind ONE sampler `wave_noise` to
   `app/assets/terrain/water_png/diffusewaves0.png` (donor `DiffuseWaves0`, 256²,
   `tfLuminance`, `miLinearMipmapLinear`). Replace the 3-sheet weighted mix at
   `water_overlay.gdshader:39-42` with
   `noise(p) = texture(wave_noise, fract(p/256)).r`. Remove `wave1`, `wave2`
   and `foam_tex` (`world.gd:781-783,825-826` bindings become stale — builder
   must not edit world.gd; report them to coordinator for a companion grant).
2. **Wave synthesis (rows 2, 4).** Implement donor `water_map` verbatim from
   W01 §2.4: `f = 0.6*noise(p) + 0.25*noise(p*m) + 0.1666*noise(p*m*m)` with
   `m = mat2(0.72,-1.60,1.60,0.72)`; crossing swell
   `sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)*0.50*f*waveheight²`;
   9-iteration loop `p=m*p*0.947`,
   `f -= amp*abs(sin((noise(p+shift1*s)-0.5)*2))`, `amp*=0.59`, `s*=-1.329`;
   return `wave + f*0.5`. **Caveat from W02:** at piece scale the donor swell
   produced diagonal moiré, so the builder must A/B the swell frequency
   in-engine and may attenuate the BODY swell while keeping the donor tilt
   spectrum in the normals (W02 `swell_amp=0.0` body-only finding). Never
   substitute radial sines.
3. **Time scroll / scales (row 3).** Replace the three arbitrary scroll vectors
   (`:36-38`) with donor `shift1=(0.32t,0.24t)`, `shift2=(0.38t,-0.26t)`;
   `pos += t*0.01`; level sample `uv*15 + t*0.1`. `texScaleS=0.1`,
   `texScaleT=0.01` are OBSERVED (`water.lib:32-33`; the `0.105` comment is not).
4. **Normals + refraction jitter (rows 5, 6).** Four central differences of
   `water_map` at `dif=(0,0.01)`, `normwater=normalize(vec3(h3-h4,h1-h2,0.15))`,
   `wavejitter=normwater.xy*0.01*(level-height)`; offset BOTH bed and reflection
   sample coords by it. Delete the `1.2` slope gain and the forward 0.7 m
   differences at `:56-60`.
5. **Depth colour (rows 8, 15, 16).** `coastfade=clamp(depth/0.57)`,
   `coastfade2=clamp(depth/1.07)`; shallow tint must be calibrated so the
   composited water reads `#C3D1CA` HARD gate (W02 measured (194,208,201) —
   ±18/channel); deep tint `(0,0.025,0.05)` pre-gain, NOT a final colour.
   Apply a calibrated equivalent of `watercolor *= 2.2+watershade` for shallow
   brightness. `waveheight=clamp(water_level*3-1.5,0,1)` from a real
   `water_level` uniform with donor semantics (port `-0.25` is only a
   classification threshold). Alpha `coverage*coastfade2`; delete the 0.35 floor.
6. **Glints (rows 9, 10, 11).** Per-pixel ray `rd=normalize(light-r0)`,
   `r0=vec3(uv,water_level)`, light `(-0.08618,0,0.9387)` (keep `world.gd:820`);
   `grad=dot(n,rd)` (no clamp); exponents 170/120 with grey `(0.4,0.4,0.4)`;
   corona `gradpos=dot((0,0,1),rd)`, `smoothstep(0,1,pow(gradpos,5))` as a
   DIVISOR `/(1+1.25*corona)`; soft term `0.25*((grad-1)*0.5+spec)`; DELETE
   `×8/×4` and the `pow(grad,24)*0.35` sheen (`:71-75`). **Open calibration:**
   W02 needed 260/180 on a CPU cusp field to avoid 2–3% 1px speckle; the
   builder must A/B 170/120 (donor) against the retune in-engine and report
   which reproduces W02's glint size/coherence stats. D-GA-max 32px must be
   re-measured in-engine, not waived by the builder.
7. **Foam (rows 12, 13).** Rewrite `nautic()`/`particles()` verbatim from W01
   §2.7 using `wave_noise`: 3 octaves ×18 `pow(1-f,5)` and ×200
   `pow(f*0.35,7)*30`, `m`, `p*=1.2`, `amp*=0.5`, `s*=-1.227`; gate by
   `coastfade*(1-coastfade2)`; zero foam beyond 1.07 m. No foam texture asset.
   W02's weak gain 0.15 is a port-art decision, record as such.
8. **Shore wash interface (rows 14, 16).** The wash must read as a soft 3-band
   sand→wash→water transition, 30–50 px source / 60–90 px @720p, with NO black
   gap and NO sawtooth (W02 final: max run 1 px, black 0). Alpha fades from 0 at
   the waterline over 1.07 m.

### Dependencies needing SEPARATE coordinator grants (not in this shader file)

- **D1 — depth mask resolution** (`app/scripts/world.gd:829-845`): coverage/depth
  is baked one texel per 2 m tile; a 30–50 px wash cannot exist in-engine
  without a higher-res depth texture or sub-tile coverage ramp. This is a
  shared-file change; the W04 builder may NOT touch world.gd without an explicit
  coordinator grant naming that file and its own builder. Request it now.
- **D2 — stale uniform bindings** (`world.gd:781-783,825-826`): if `wave1`,
  `wave2`, `foam_tex` uniforms are removed from the shader, the world.gd
  `set_shader_parameter` calls must be removed in the same grant as D1.
- **D3 — reflection proxy (W03)**: NOT in the base W04 shader grant. If the
  owner wants reflection, grant a separate builder for the `SubViewport`→
  `ViewportTexture` bake + plain `sampler2D` uniform + donor fetch tail +
  `reflection_enabled` toggle; explicitly NOT `hint_screen_texture`
  (z-order proof in W03 §3). Gates W03 A1–A6.

### Gates for the granted builder

Backup before edit; Godot only via
`python app\tools\godot_runner.py run --id t6water-<purpose> --timeout 180 -- <args>`;
selftest 29/29 + uitest 17/17; bake bench ≤250 ms and not worse than baseline;
`scan_map` green; determinism byte-identical; in-engine A/B captures against
`articolo-787.jpg` / `maxresdefault_1.jpg` water crops; W02's measured bands
re-checked in-engine; owner visual review is final (SWARM_OPS §7.6.4). No donor
asset copied. Zero reflection in the base grant.
