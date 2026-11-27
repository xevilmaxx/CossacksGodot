---
id: PORT1TO1-BLEND-OWNER-PROTOCOL
worker: BLEND-OWNER-PROTOCOL (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "The single owner-only fixed-seed capture packet that settles animation blend B1/B2/B3/B4 and completion C1/C2 in one authorized donor session: fixed seed/sid/action selection, per-tick frame-index + vertex-hash capture across the (6,8) window and the (0,0) bypass, weight-curve derivation from donor frames, arg-polarity check, PlayOnce/EndCyclesReached handler firing ticks, movie 0..5 applicability, the seven 0,0 bypass sites, zero-mismatch termination, and per-outcome port change (which interpolation/frame fetch may be enabled)."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_DONOR_EXECUTION__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, opened for write, debugger-attached or GPU frame captured by this worker. The owner-only sessions below are SPECIFIED, not performed. All donor facts are carried [O]/[D] from the cited landed reports; no curve, weight, frame index, handler tick or polarity is invented here."
scope_guard: "Repo/doc file reads and read-only filesystem/hash reads only. No source, shader, asset, config, test, fixture, result JSON, git state, Godot process, runner job, gate, capture or donor binary was created, modified or executed. Exactly one repository file written: this report. No Craft Anything native calls; no investigation memory written."
upstream: "PORT1TO1_u_register_update.md §1 P0-5; PORT1TO1_owner_decisions.md §4 (E-B1, E-B2/B3/B4, E-C1/C2) + §0 reviewer line; PORT1TO1_acceptance_plan.md §6 P0-5; DEC_U_blend_op.md §§1-7 (R-B1/R-B2/R-B3/R-B4/R-C1/R-C2, seven bypass sites, port change list F1-F8); DEC_U_aaf_triggers.md §§1-6 (T1-T26, completion, blend); DEC_U_state_map.md §§1-4 (token/ACL census, advancing events); DEC_U_aaf_art_audit.md §§1-3 (per-sid AAF ranges); IMPL_U_aaf_triggers.md (intent-only resolver); variant3d/scripts/anim3d.gd (VERIFIED current line anchors, read-only)"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
---

# PORT1TO1 BLEND / COMPLETION — single owner-only capture packet (read-only, no parity)

> **Mandatory reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **P0-5 stays OPEN.** Blend B1/B2/B3/B4 and completion C1/C2 are among the P0 blockers restated in `PORT1TO1_u_register_update.md:64` (P0-5), whose verdict is `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. A "close", a metric, a still, a deterministic replay pair or a port fallback never counts. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false` before, during and after this packet.

## 0. Authority and discipline (read first)

Every statement here is `[O]` (verbatim donor read carried from a cited report, or verbatim port file line re-read for this packet), `[D]` (deterministic control-flow/arithmetic over cited `[O]`), `[I]` (reading without runtime proof), or `[U]` (UNVERIFIED — retired **only** by an owner executing §§2-9 under the §10 rule).

- **This worker executed nothing.** No donor binary was run, no GPU frame captured, no debugger/tracer invoked, no Godot/git/code/shader/asset/config change. Donor VAs, frame indices, AAF row numbers and cites are re-carried from `DEC_U_blend_op.md`, `DEC_U_aaf_triggers.md`, `DEC_U_state_map.md` and `DEC_U_aaf_art_audit.md`; they were not re-lifted from the donor tree. Port line anchors marked `VERIFIED` were re-read (read-only) for this packet; anchors marked `DEC-U` are carried and **must be re-read at apply time** because concurrent local modification is observed (line drift: e.g. `_frame_blend_fields` is now `anim3d.gd:1020-1041` vs `DEC_U_blend_op.md`'s `:870-884`; `_nearest_exported_frame` now `:1522-1527` vs `:1224-1230`; `_frame_at` now `:986-1000` vs `:746-760`; completion string now `:200` vs `:175`).
- **Owner-only.** Every session in §§2-9 may be run **only by the owner**, on a retail donor install, singleplayer skirmish, fixed camera, paused-then-stepped sim. Workers are forbidden to run donor binaries, attach debuggers or capture frames.
- **No approximation, no parity claim, no invention.** This packet supplies no `w(t)`, no blend weight, no second fetched frame, no handler firing tick, no `a3/a5/a6` semantic, no `0,5` applicability verdict and no invented completion signal. Each is a `[U]` with a named experiment. A retired `[U]` becomes `[D]+capture-id`, not a parity proof (§13).
- **Load-bearing port fact `[D]` (VERIFIED, unchanged here):** `variant3d/scripts/anim3d.gd` carries `requested_blend`/`blend_bypass` as **logged intent only**, with no interpolation on the pose path — a read-only grep finds **zero** `lerp`/`mix`/`slerp` occurrences in the module. `play()` (`:428`) and `pose_for()` (`:847`) compute `sample_frame` from `_morph_fields()`/`:903-935` **before** calling `_frame_blend_fields()` (`:454`, `:870`, `:1020-1041`), which returns telemetry only; `_nearest_local()` (`:1498-1509`) scans ascending and keeps the lower frame on a tie, and `_nearest_exported_frame()` (`:1522-1527`) fetches exactly ONE frame from the deterministic 6-frame shipped subset. Both are labelled PORT choices with zero donor counterpart (`FRAME_BLEND_STATUS :137`, `DONOR_BLEND_FETCH_SITES :183`, `fetch_policy:"nearest_single_no_blend [U]-B2" :1038`). Once-actions clamp at the last frame (`_is_once_action :966-970`, `_frame_at :986-1000`); the completion hook registry (`:1780-1785`) is empty and `aaf_completion_probe()` (`:1794-1804`) reports `"clamp-at-last [U]-C1, no EndCyclesReached handler armed"` — a labelled stand-in, not a recovered signal (`AAF_COMPLETION_STATUS :200`). This report changes none of that.

## 1. Controlled inputs — fixed seed / sid / action selection

### 1.1 Seed and admissibility (harness constants, NOT donor-stream claims)

One owner-pinned integer seed `20261113` (literal used by the fixed-seed harness; `PORT1TO1_determinism_audit.md:36/47`, acceptance plan §2.3). It is a **harness constant**, not an asserted donor `randkey0/1` and not a donor RNG equivalence. For every trial:

| Control | Requirement | Cite / failure effect |
|---|---|---|
| Seed | `--seed 20261113`; manifest must assert `deterministic == true` and `seed == "20261113"` | `determinism_audit.md:36,47` — never `--seed random` (N1), never menu Random (N2) |
| Config | One temp config copy; `config_sha256_file` recorded and byte-identical across all 3 trials | `determinism_audit.md:36,108-132` |
| Class-N paths | Exclude N3 fishing delivery (unseeded `randf()` in live sim), N4 audio (disable or ignore for pose hashes), N5 wall-clock watchdog (no `watchdog:`/`wall-clock limit reached` line), N6 frame-paced stepping (tick-driven `--seq` fixed step / CLI exact ticks only), N7 async-load yields, N8 800×600 fallback (require 1280×720 windowed), N9 `load_save` seed rewrite (no save/load in capture) | `determinism_audit.md:42-102`; any active Class-N path voids the trial |
| Trials | **3/3** identical runs per setting per sid; one differing tick/hash fails | `owner_decisions.md:218,226,234` |
| Camera / stepping | One fixed camera per battery; paused-then-stepped sim at donor 30 Hz; record `sim_tick` and wall clock separately | `DEC_U_blend_op.md §6`; do not substitute port frame count for donor tick |

### 1.2 sid / action selection matrix (all frame windows are donor AAF reads, `[O]`)

| Battery | sid(s) | Action seam / window (donor AAF) | What it settles | Cite |
|---|---|---|---|---|
| R-B1 / R-B2 | peaukr | `walk [1,20]` → `idle [64,113]` stepped 1 tick/frame; log ticks `[-2,+10]` around switch | B1 support/`w(t)`; B2 co-occurring frames | `DEC_U_blend_op.md §6 R-B1/R-B2`; `DEC_U_aaf_art_audit.md §1.2` (`peaukr.aaf:5` walk, `:3` idle) |
| R-B3 | peaukr or musketeer, sim-path vs aix-path unit | Same seam, sim path `a3=False` (V2 `unit.script:11041-11042`) vs aix-idle-shaped `a3=True` (V4 `ontagstates.inc:500`) | B3 arg polarity | `DEC_U_blend_op.md §1.1/§6 R-B3` |
| R-B4 | movie-path unit | `_movie_UnitPlayAnimation`, `bBlend` true vs false; `maxblend=5` iff `bBlend` | B4 movie `0..5` applicability | `DEC_U_blend_op.md §1.3 M3/§6 R-B4`; `movie.script:644-646` |
| R-C1 | musketeer; peasant | `attack1 [99,124]` single shot → `idle1 [256,305]`; `death [115,149]`; trace `t0..t0+span+10` | C1 hold-at-last vs snap-to-idle vs mid-blend freeze | `DEC_U_blend_op.md §6 R-C1`; `DEC_U_aaf_art_audit.md §1.2` (`musketeer.aaf:7`, `peaukr.aaf:6`) |
| R-C2 | cannon | `attack0/attack1 [301,337]` firing | C2 handler firing ticks / effect offsets | `DEC_U_blend_op.md §5/§6 R-C2`; `DEC_U_aaf_art_audit.md §1.2` (`cannon.aaf`) |
| R-W / W2 (supporting) | musketeer; grenadier | `attack1 [99,124]`; `attack2before [630,663]` → `attack2after [664,679]`; `death0 [564,628]` / `death [115,149]` | weapon→`attack1/2`, death family | `DEC_U_aaf_triggers.md §6 R-W/R-W2`; `DEC_U_state_map.md §2.1` |
| R-S / R-A / R-R (supporting) | musketeer; peasant | 90-tick `GetGameObjectFrameAnimationName` log; stance/formation orders; raid/death/combat/construct/idle-long-tail battery | sticky readback, prepare-family triggers, `reaction` orphan | `DEC_U_aaf_triggers.md §6 R-S/R-A/R-R`; `DEC_U_state_map.md §4` |

No sid is substituted across families: `walk1` is a donor-dead name (selected `unit.script:10946`, zero AAF rows, degrades at `:11048-11051` `[D]`) and must never be requested (`DEC_U_state_map.md §2.1`, `anim3d.gd:218/252`). Orphans `reaction`/`attack2before`/`attack2after`/`prepare*`/`trans*` have no donor set-site and are exercised only as cited above (`DEC_U_state_map.md §2`, `DEC_U_blend_op.md §1.3`).

## 2. Per-tick capture schema — frame index + vertex hash (every battery)

Each tick of every trial writes one row. Columns are filled from **engine reads**, never from the port clock alone; the port-clock columns are recorded beside them so divergence is visible:

```
sim_tick, t_seconds, donor_frame_clock, selected_anim_token,
AAF_first, AAF_last, requested_frame_clock, displayed_frame_index,
GetGameObjectFrameAnimationName_value, frame_data_sf_ef,
sample_frame(port), blend_args(min,max), requested_blend(port),
blend_bypass(port), blend_bypass_violation(port),
pose_vertex_hash, joint_track_hash_or_ankle_joint_xy, engine_state,
handler_events[], tag_fields(iAction/iWeapon/iMove/iResource/iEssential/iVisual)
```

- `displayed_frame_index` is an engine-read value (`GetGameObjectFrameAnimationName` / `GetGameObjectFrameAnimationData(sf,ef)`); `requested_frame_clock` is the sim clock. Their per-tick relation is the whole B1/B2 evidence.
- `pose_vertex_hash` = hash of engine-displayed posed vertices (or screen-space ankle-joint track where a full pose hash is not exposed). Hash the **rendered** pose, not the port-baked 6-frame subset.
- `blend_args(min,max)` = the donor tail pair actually passed at the switch; `(6,8)` deferred vs `(0,0)` bypass vs `(0,5)` movie. vary **only** the tail pair between the two R-B1/B2 settings; everything else pinned.
- `blend_bypass_violation` is the port's labelled status flag (`anim3d.gd:1026/1036`); a `true` under `(0,0)` is itself a finding — it contradicts `unit.script:10891-10893,11042`.

No row is smoothed, averaged or dropped. A `null` engine read is a missing dump, not a zero.

## 3. The seven 0,0 bypass sites `[O]` (R-B1/B2 control arm)

`(0,0)` = `minBlend=0, maxBlend=0` in the 8-arg switch tail, always paired with `GameObjectResetFrameAnimationBlend`; the donor comments make the intent explicit (`DEC_U_blend_op.md §1.3/§4`, carried into `anim3d.gd:166 DONOR_BLEND_BYPASS_SITES`):

| # | Site `[O]` | Order / purpose |
|---|---|---|
| V1 | `unit.script:10891-10893` | `Switch(0,0)` → `Reset`; `bSkip` early-out, "dont use blend cause it kills animation" |
| V2 | `unit.script:11041-11042` | `Reset` → `Switch(0,0)`; idle re-entry, "to reset blend ... prevent 2 shooting animation effect" |
| V3 | `ontagstates.inc:355-357` | `Switch(0,0)` → `Reset`; early-out mirror |
| V4 | `ontagstates.inc:500` | `Switch(anim, True,True,False,False,0,0)`; idle re-entry mirror; `a3=True` polarity `[U]-B3` |
| V5 | `movie.script:636-637,639` | `Switch('',0,0)` → `Switch(idle,0,0)` → `interval=1` → `Reset` → `TrackPointClear`; empty-token reset pulse |
| V6 | `movie.script:586,1022,1076` | `Switch(idle,…,0,0)`; revive/rebuild idle, same anti-double-shoot intent |
| V7 | `eventdebuganimations.inc` | `Switch(0,0)` → `Reset` → `TrackPointClear` → mode → attach; debug path **always** no-blend (first unit `bRandomFrame` as-authored, rest forced `True`) |

**Not a bypass:** death `unit.script:11100-11102` / `ontagstates.inc:596-598` do `Switch(6,8)` → `Reset` (reset-after) — it is a deferred switch, not a `0,0` site.

**Invariant `[D]` under every V1-V7:** `displayed_frame_index == requested_frame_clock` with no snap and no window; the `(0,0)` trace must be the unsmoothed single-tick hard cut. Any intermediate pose or displacement under a true `(0,0)` setting fails the capture. The port already records `blend_bypass_violation` for this (`anim3d.gd:1026/1036`); it is status only and must not be read as behaviour proof.

## 4. R-B1 — weight curve / support derived from donor frames `[U]-B1`

**What is readable `[O]`:** one `6/8` pair for all units (`unit.script:10846-10847`, installed `initial.inc:17-19` with `DeferredFrameBlend(false)` = eager), seven `0,0` bypasses (§3), and `acoSmoothAnimation=True` on every sampled ACL block with zero `False` in any `*.acl` (`DEC_U_blend_op.md §1.4`). **No** readable text combines two poses: searches for `Blend|Smooth|Weight|Lerp|Mix|Slerp|Interpolat` over all donor scripts returned only call sites/installs/resets/the constant flag (`DEC_U_blend_op.md §2`); AAF rows carry only `(first,last,morph)`; `.acl` items carry only `AnimationName + NumberCycle + TrackPoint + ExecuteState`. The curve is engine-side.

Procedure (owner-only):

1. Run the §1.2 peaukr seam at 1 tick/frame, once with `(6,8)` and once debug-forced `(0,0)` (V7); log §2 rows for ticks `[-2,+10]`, 3/3 trials per setting, changing only the tail pair.
2. **Support bound:** compute the step-response length in frames from the `pose_vertex_hash` change sequence. If the pose changes on exactly one tick under both settings, support = 1 tick (hard cut) — this bounds `w(t)` to no observable window and does **not** name a curve.
3. **Weight derivation from donor frames (only if intermediate poses exist):** take the co-occurring donor frame indices from R-B2 (§5) as frames `A`/`B`. For each tracked vertex/joint, project the engine-displayed pose onto the segment `p_B → p_A`: `w_t = ((p(t)-p_B)·(p_A-p_B))/‖p_A-p_B‖²`. Require all tracked vertices/joints to yield the **same** `w_t` at that tick (0 mismatch). Fit the resulting `w(t)` sequence only against candidate curve families; accept a named family only on 0 residual across **all** ticks and 3/3 trials. Otherwise report `w(t)` UNNAMED.
4. **Window unit:** record both `sim_tick` and the engine frame clock, and check which donor length law counts — sim inclusive `frames=1+ef-sf, duration=frames/30` (`unit.script:10774-10777`) vs movie exclusive `(ef-sf)/30` (`movie.script:854-858`). Both are donor-authored `[O]`; choosing between them is engine-side `[U]-B1` and must be captured, never assumed.

**Guard:** derive only from engine-read poses at donor AAF frame indices. The port's 6-frame decimated shipped subset (`index.json frames_per_action=6`) is a converter choice and is **never** donor evidence for a weight or a second frame. No linear/smoothstep/hermite form, per-bone vs per-vertex rule, easing or normalisation is supplied by this packet.

## 5. R-B2 — blend-window frame fetch `[U]-B2`

Same seam as §4. Per tick log engine `GetGameObjectFrameAnimationName` + `GetGameObjectFrameAnimationData(sf,ef)` + `displayed_frame_index` under `(6,8)` (and under `(0,0)` as control). **Termination:** displayed-frame sequence byte-identical 3/3 trials, showing exactly which exported frames co-occur (e.g. a `20,64` hold pattern, or intermediate donor indices with tick numbers); one divergent trial fails. No readable donor text names a two-frame fetch, a blend-from/blend-to pair or a snap-vs-interpolate rule (`DEC_U_blend_op.md §3` zero-hit) — the port's nearest-single fetch, ascending tie-lower and 6-frame stride remain PORT choices (`anim3d.gd:1496-1527/:1038/:183`) until this lands. No second donor frame is invented.

## 6. R-B3 — argument polarity `[U]-B3`

Differential run only: replay the same attack→idle seam via the sim path (`a3=False`, V2) and the aix-idle-shaped call (`a3=True`, V4, `ontagstates.inc:500`) if the runner can inject it, else via `unit.script`-path vs `ontagstates.inc`-path units; log displayed frames and hashes. Also record `a5/a6` (observed `False` everywhere) and `CyclesList=False` / `acoSkipActions` variation across ACL blocks. **Termination:** identical-or-different verdict with tick table 3/3 trials; **no semantic name is assigned** to `a3/a5/a6` either way (`anim3d.gd:176 DONOR_BLEND_ARGS_STATUS` stays status-only, no behavioural branch).

## 7. R-B4 — movie `0..5` applicability `[U]-B4`

`_movie_UnitPlayAnimation` computes `maxblend := 5` iff `bBlend`, else `0`, and switches with `(0,maxblend)` (`movie.script:644-646`, `DEC_U_blend_op.md §1.3 M3`). This is the only non-`8`/non-`0` max in readable donor text; it is a **movie** window, not shown to apply to units. Run the movie path with `bBlend` true/false on the same seam; log displayed frames. **Termination:** differ-or-identical verdict 3/3. Until a zero-mismatch result says units use it, the port keeps only `"0,0"` and `"6,8"` (`anim3d.gd:160-161`) and does **not** add `"0,5"`.

## 8. R-C1 — PlayOnce end / EndCyclesReached firing ticks `[U]-C1`

No armed completion handler exists on the unit path: `DoDeath` clears all four `OnStateEndCyclesReached`/`OnStateFBEndCyclesReached`/`OnStateEndFrameReached` handlers to `''` (`unit.script:10811-10815`; mirrors `ontagstates.inc:180-181`, `initial.inc:163`); death advances via delayed `DeathStage1` (`unit.script:11085`); attack advances via the ACL `AttackEnd` re-attack gate (`DEC_U_blend_op.md §5`, `DEC_U_state_map.md §1.3`). A genuine non-empty `EndCyclesReached` firing in the capture would itself be a discovery — record it, never pre-wire one.

Run musketeer `attack1 [99,124]` single shot and peasant `death [115,149]` at 30 Hz, `t0..t0+span+10`; record frame index per tick, and vertex hash at the last 3 ticks. **Termination:** hold-at-`124` vs snap-to-`idle1 [256,305]` vs mid-blend freeze verdict **with tick numbers**, 0 mismatch 3/3 trials per sid. The port's clamp-at-last (`_frame_at :990-996`, `aaf_completion_probe :1794-1804`) stays the labelled stand-in until then.

## 9. R-C2 — handler firing ticks / effect offsets `[U]-C2`

`OnAclAnimationReachedAttackEnd` **body is recovered** `[O]` (`onaclanimationreachedattackend.inc:2-14`: `_unit_TryAttack(…,True)` re-issue, then `SwitchTo('Nothing')`); it is a re-attack gate, not an effect bind. Damage/PFX/sound ride the OPENING `Attack` handler (`...attack.inc:15-110`, weapon-index branches). **Firing ticks are unrecovered** (`DEC_U_blend_op.md §5`, `DEC_U_state_map.md §1.3`).

Run cannon `attack0/attack1 [301,337]` firing on fixed camera; log muzzle-flash PFX attach frame, damage tick and sound tick **relative to the `Attack` and `AttackEnd` handler firing ticks**, cross-checking the `_unit_TryAttack` re-issue. **Termination:** effect-to-handler-tick offsets 0 mismatch 3/3 trials, or absence logged with the exact window used. The empty completion hook (`anim3d.gd:1780-1785`) is not invoked by this packet.

## 10. Zero-mismatch termination criteria (every item; no partial credit)

A `[U]` retires **iff** its verdict/tuple is identical frame-for-frame and hash-for-hash across **3/3 trials**, at the exact §1 controls, with all §2 columns populated. Any mismatching tick/hash, missing engine dump, inactive `0,0` invariant, Class-N path or path/camera mixing ⇒ item stays `[U]` and the port change in §11 is **not** authorised. "Close", a threshold or a visual read never counts.

| Item | Tuple / verdict that must repeat with zero mismatch | 3/3 requirement |
|---|---|---|
| B1 support | step-response length in frames + per-tick displacement table under `(6,8)` **and** `(0,0)`; `(0,0)` == single-tick hard cut | byte-identical per setting; support only, not `w(t)` |
| B1 weight (only if intermediate poses) | per-tick `w_t` from donor frames `A/B`, same for all vertices/joints; named curve only on 0 residual | 0 residual all ticks, 3/3; else `w(t)` unnamed |
| B2 fetch | `displayed_frame_index` sequence + `GetGameObjectFrameAnimationName/Data(sf,ef)` per tick under `(6,8)` | byte-identical 3/3; one divergent trial fails |
| B3 polarity | identical-or-different verdict + tick table for `a3=False` vs `a3=True` paths | 3/3; no semantic name assigned |
| B4 movie | differ-or-identical verdict for `maxblend=5` vs `maxblend=0` | 3/3; otherwise `"0,5"` not added |
| C1 completion | hold-at-last / snap-to-idle / freeze verdict **with tick numbers** + last-3-tick hash, per sid | 0 mismatch 3/3 per sid |
| C2 handlers | PFX/damage/sound ticks relative to `Attack` / `AttackEnd` firing ticks, or logged absence | 0 mismatch 3/3 |
| 0,0 invariant | `displayed_frame_index == requested_frame_clock` at every tick of all V1-V7 arms exercised; no intermediate pose | 0 mismatch 3/3 |
| Window unit | sim-inclusive vs movie-exclusive law actually counted by the blend window | 0 mismatch 3/3; never assumed |

## 11. Outcome → exact port change (owner applies; NO edits made here)

Each row fires **only** on its own §10 zero-mismatch capture. Port anchors are `VERIFIED` at the time of this packet; re-read before applying (line drift is observed, §0).

| Zero-mismatch outcome | Exact port change — which interpolation / frame fetch to enable | What stays as-is / hard-failed |
|---|---|---|
| **B1 = support-only (single-tick hard cut, no intermediate poses)** | **Enable NO interpolation.** Record the support bound in `FRAME_BLEND_STATUS` (`:137`) / `DONOR_FRAME_LAW_STATUS` (`:207`); keep `_nearest_exported_frame` single fetch (`:1522-1527`). Support alone never licenses a weight. | No lerp/mix/slerp anywhere on the pose path; `fposmod`/clamp clocks unchanged |
| **B1 = derived `w(t)` + B2 = co-occurring donor frames** | Only now may interpolation be introduced: replace the single `sample_frame` in `play()` (`:452-454`) / `pose_for()` (`:868-870`) with the **captured** two donor frame indices and the **captured** `w(t)` over the captured window; keep the curve bounded to that window and cited by capture id; retire `fetch_policy:"nearest_single_no_blend [U]-B2"` (`:1038`). | Never apply under `(0,0)`; never interpolate from the port's 6-frame decimated subset; never extend `w(t)` beyond captured support |
| **B2 = hold pattern `A,B` or intermediate indices** | Enable exactly the captured fetch order/tick schedule in `_nearest_local`/`_nearest_exported_frame` (`:1498-1527`); the second frame is the captured donor AAF frame, not a neighbour guessed from the subset. | Tie-lower/ascending-scan/6-frame-subset stay labelled PORT choices if not superseded |
| **B3 = identical / different** | Update `DONOR_BLEND_ARGS_STATUS` (`:176`) string with the verdict + capture id only. | **No behavioural branch** on `a3/a5/a6`, `CyclesList` or `acoSkipActions` either way |
| **B4 = movie window applies to units** | Add a third `requested_blend` value `"0,5"` beside `"0,0"`/`"6,8"` (`:160-161`) and thread it through `frame_blend_for_trigger` (`:1766-1775`) as logged intent; extend `DONOR_BLEND_SITES` (`:162`) with the captured window. | If not applicable, `"0,5"` is never added; movie sites remain donor data only |
| **C1 = hold / snap-to-idle / freeze at captured tick** | Wire the **empty** completion hook (`set_aaf_completion_hook` `:1780-1785`) to fire at the captured tick and replace clamp-at-last in `_frame_at` once branch (`:990-996`) and `aaf_completion_probe` (`:1794-1804`); update `AAF_COMPLETION_STATUS` (`:200`) and `DONOR_CYCLE_SITES` (`:196`). | No EndCyclesReached handler invented; absence of a script handler stays recorded |
| **C2 = handler offsets** | Schedule muzzle-flash PFX / damage / sound at the captured offsets relative to the captured `Attack`/`AttackEnd` firing ticks; keep the re-attack body (`_unit_TryAttack` + `SwitchTo('Nothing')`) as recovered. | No effect-to-frame offset invented; hook stays empty for other actions |
| **0,0 invariant confirmed** | Keep `blend_bypass` enforcement (`blend_bypass_violation` `:1026/1036`); document the seven sites (`:166`) as the reason no interpolation may ever be applied to an early-out/idle-re-entry/debug switch. | Any snap under `(0,0)` remains a defect; no weight added to V1-V7 |

## 12. Hard-fail matrix — gaps that may NEVER be substituted

| Gap → / Forbidden substitute ↓ | B1 weight unknown | B2 frames unknown | B3 polarity unknown | B4 movie unknown | C1 completion unknown | C2 handler ticks unknown |
|---|---|---|---|---|---|---|
| Invented `w(t)` / linear/smoothstep/hermite / per-bone guess | ✗ | — | — | — | — | — |
| Use port 6-frame decimated subset as donor frames or weights | ✗ | ✗ | — | — | — | — |
| Second fetched frame guessed from neighbour / stride / tie | — | ✗ | — | — | — | — |
| Snap nearest frame under a true `(0,0)` bypass | ✗ | ✗ | — | — | — | — |
| Semantic name for `a3/a5/a6`/`CyclesList`/`acoSkipActions` | — | — | ✗ | — | — | — |
| `"0,5"` added to unit blend values without capture | — | — | — | ✗ | — | — |
| Invented `EndCyclesReached`/`EndFrameReached` handler or tick | — | — | — | — | ✗ | — |
| Effect-to-frame offset / damage-sound tick guessed | — | — | — | — | — | ✗ |
| `camera`/tick law assumed (sim-inclusive vs movie-exclusive) | ✗ | ✗ | — | ✗ | — | — |

Telemetry rule: keep `visual_parity_claim=false`; each retired sub-item flips to `[D]+capture-id` with its tuple; everything else stays `[U]` with the § battery that would settle it.

## 13. Status until the owner executes §§2-9 (explicit, non-negotiable)

- **P0-5 stays OPEN.** `blocking_unverified` remains non-empty (P0-1 … P0-8 plus tails), six-condition chain stays 0/6 CLOSED, verdict `RESULT IS NOT GOOD` (`PORT1TO1_u_register_update.md:14/69/206`).
- **Port keeps NO interpolation and ONE nearest frame.** `play()`/`pose_for()` compute pose before blend telemetry; `_nearest_local` ascending tie-lower and the 6-frame subset remain labelled PORT choices; `requested_blend`/`blend_bypass` remain intent-only. No lerp/mix/slerp is introduced by this packet.
- **Completion stays a labelled stand-in.** Clamp-at-last with an empty hook; no `EndCyclesReached` handler armed or invented; `AttackEnd` body is cited as recovered but its firing tick is `[U]-C2`.
- **Parity UNVERIFIED.** Nothing here is a capture, a gate PASS or an A/B frame. Even after the owner captures and the port is updated, a matched-seed donor-vs-port GPU A/B frame is still required before any parity statement. `parity.status="UNVERIFIED"`, `parity.claim=NONE`, `visual_parity_claim=false` throughout.

## 14. Claim register and scope statement

| # | Claim | Label |
|---|---|---|
| 1 | This packet restates P0-5 as still open; no upstream P0 row is removed or promoted | [D] `PORT1TO1_u_register_update.md:64/206` |
| 2 | Seven `0,0` bypass sites V1-V7 with cites/order and the death reset-after carve-out; invariant `displayed==requested` under `0,0` | [O]/[D] `DEC_U_blend_op.md §1.3/§4`, `anim3d.gd:166` VERIFIED |
| 3 | Port has zero `lerp`/`mix`/`slerp` on the pose path; one nearest frame, ascending tie-lower, 6-frame subset; clamp stand-in + empty hook | [D] `anim3d.gd:428/847/903-935/966-1000/1020-1041/1498-1527/1780-1804` VERIFIED (read-only grep) |
| 4 | Every B1-B4/C1-C2 item has an owner-only § battery with per-tick frame/hash capture and §10 zero-mismatch termination | [D] this packet §§1-10 |
| 5 | No `w(t)`, weight, donor frame, handler tick, polarity or movie-window applicability is invented; each stays `[U]` until captured | [O] scope guard |
| 6 | No donor binary executed, no GPU frame captured, no runner/gate launched, no port capture compared by this worker | [O] subagent context (repo/doc reads only) |
| 7 | No approximation adopted, no parity claim made, no test/gate weakened; exactly one repository file written | [O] scope guard |

*End of PORT1TO1-BLEND-OWNER-PROTOCOL. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
