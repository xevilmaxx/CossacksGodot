---
id: PORT1TO1-SESSION-RISKS-2026-11-26
title: "Session risk register — concrete failure modes, exact diagnosis and required action for the seven dedicated owner donor sessions (full 1:1 Cossacks 3 donor port)"
worker: SESSION-RISKS (read-only subagent)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_session_risks.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_session_risks.md]
files_edited: []
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, manifest, result JSON, backup, git state, Godot process, runner job, gate, capture, ROI metric or donor binary was created, modified or executed; no donor GPU frame was produced or compared. Exactly one repository file written: this report."
labels: [SESSION_RISK_REGISTER, FAILURE_MODES, EXACT_DIAGNOSIS, REPEAT_CORRECTED_SETUP, KEEP_U_OPEN, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
verdict: "RESULT IS NOT GOOD — zero P0 settled; all nine P0 rows open; seven owner sessions SPECIFIED, not performed; six-condition chain 0/6 CLOSED; any failure mode below keeps its item [U] and its P0 row open; no threshold relaxed, no value invented, no port result substituted for donor evidence; no approximation; no parity claim."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md (§0-§7)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_decision_sim.md (§0/§1.3/§2/§3)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md (§3-§8)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md (§3-§8)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md (§1-§13)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md (§1-§10)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md (§1-§7)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md (§1-§9)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md (§1-§10)
  - docs/terrain_swarm_2026-11-26/CHARTER.md (§4 :66-72)
---

# PORT1TO1 — owner session risk register (2026-11-27)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **What this document is.** A read-only risk register for the seven dedicated owner sessions defined in `PORT1TO1_p0_session_plan.md §1`. For each session it names concrete failure modes, the **exact** dump/log to re-check for diagnosis, and the **required action**. It is a handling rulebook for the owner/COORD. **This worker performed none of it.** No session is run, no threshold is relaxed, no value is invented, no port result is substituted for donor evidence, and no parity is claimed.

> **Action vocabulary is closed.** Every row's required action is one of exactly two forms: **REPEAT UNDER CORRECTED SETUP** (re-run the same packet at its exact pinned scene/seed/camera/config/dumps/repeats — never retry-until-green, never a fallback, never a substitute) or **KEEP `[U]` OPEN** (the named item and its P0 row stay open with the divergent dump quoted verbatim). Where a row needs both, it is written as "KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP". No third form exists: no "close", no metric, no still, no replay pair, no port fallback, no averaged result.

## 0. Non-negotiable baseline (do not quote selectively)

1. **Seven sessions; zero results.** S1 water, S2 FOW, S3 blend, S4 selection, S5 save, S6 tick, S7 RNG are **SPECIFIED, not performed** (`p0_session_plan.md §1/§7`). Zero P0 are settled by the existing terrain Route A capture (`decision_sim.md:81`; `X39:34/178`).
2. **Donor execution is owner-only; workers are forbidden.** `CHARTER.md:66-69`: "Read-only donor. No donor executable is run, no donor binary is copied or committed. Craft Anything read tools only. Donor material = private use only." No worker launches `cossacks.exe`, attaches a debugger/tracer, captures a GPU frame, produces a donor save, runs a Godot/gate/harness job, or promotes a `[U]` to `[D]`.
3. **Thresholds are fixed, never retuned.** Every packet's zero-mismatch criterion stands as written: water 0 differing bits/elements over ≥2 water-visible frames + 1 camera move; FOW 0 off-step cells / 0 mismatching cells / 0 out-of-domain values / 0 misclassified pixels; blend byte-identical frame-for-frame and hash-for-hash across 3/3 trials with `(0,0)` a single-tick hard cut; selection 0 px reprojection / 0 membership mismatches / ×8 frustum audit; save E-T0 byte-identical except the six jitter fields with 3 identical-seed repeats and a single predicted divergent field; tick byte-identical `H_0…H_3599` across 6 sequences with a single survivor; RNG 0 mismatches across the full series with S/G counts exact and G values count-only. None of these is lowered, averaged, quantised or traded for a "close" value.
4. **A port result is never donor evidence.** A port-internal replay pair, `sha256_pixels` repeatability, metric, still, `PORT APPROXIMATION` label or labelled substitute cannot settle any `[U]` row. L2 RNG breakpoints are a **native state dump, not a donor GPU A/B frame** (`rng_owner_protocol §0`).
5. **Parity stays UNVERIFIED.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, six-condition chain **0/6 CLOSED** before, during and after all seven sessions. Even an all-green packet battery yields only `[D]+capture-id/harness-id` internal results; condition 6 needs a COORD-signed geometry-byte equality + pixel-identical matched frame, and none exists.

---

## 1. S1 — Water (P0-1 / P0-1b / P0-2), `water_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| W1 | **No water-visible frame / no field break** at `FUN_00603d30 @0x603d30` entry: `[ebp+0x1c]` carries no plane-Y field record. | Re-check the Phase-0 GATE breakpoint log for the `0x603d30` hit and the `[ebp+0x1c]` dump; re-check the tracer frame file + frame counter for **≥2 water-visible frames + one level→pitched camera move**, the logged map name (shore/water-visible) and the shipped unmodified `water.lib` (`CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Session void, nothing settled; move camera to a shore or load a shore map. No neutral/grey/generated texture and no screen-space approximation promoted. |
| W2 | **U1 PATH mixing / wrong path tag** — a dump tagged DEV when the BUILTIN arm fired, or CUSTOM live (`C+0x184 != 0` with `[0x8fc6b8] != 0`) mislabelled as unreachable. | Re-check the `FUN_00851bdc @0x851bdc` `param_2` dump, the `FUN_00856530 @0x856530` two-flag single-step log (`0x8fcdb0/0x8fbd28/0x8fc748`, `C+0xf0`, `C+0x190`), the `glShaderSource` verbatim texts, the `glGetUniformLocation` key list (mask `0x3FFFFFFF`) and the U1 verdict `(PATH, C+0x184, [0x8fc6b8], P, VP/FP source hash)`. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Discard every dump on the wrong path; re-tag all dumps with the single observed PATH. No PATH mixing counts as agreement. |
| W3 | **U4* tuple mismatch / ULP > 0**, or pre-bind literals `0.01/0.02` mistaken for live uniforms. | Re-check the `C+0x88..+0xc4` block dump at the taken ctor (`0x856080`) or FILE copy (`0x852f5c`) arm, `C+0xb4/+0xbc` dirs and `C+0xc4` Speed, plus the `glUniform1f`/`glUniform2f` hook floats for S1–S11/W0/W1/S10/S11 across the first water draw; compare bit-exact to the two donor-enumerated tuples. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Scalar source stays UNSET; no default FILE/ENGINE; `water3d.gd:745-747` refusal stays. |
| W4 | **Closed height gate voids U3 frame** (`C+0xe0 == 0` or `[C+0xe0+8] == 0`), or a substitute `heightmapwaves0.tga` / 1×1 neutral texel is used. | Re-check the binder-rows `7e.10–7f.1` dump (`0x854250–0x8542f0`), gate values, `(W,H,Min,Max)` at `C+0xd0/+0xd4/+0xe4/+0xe8`, chain pointers (`0x739bf8`, `0x82f86c`, `0x82f060/0x82f114`), texel block, `glBindTexture`/`glGetTexLevelParameteriv` provenance. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Use a frame with the gate open and a real texture; `±2.96` stays classification-only, never a recovered uniform; other maps need their own U3 row. |
| W5 | **U12 texture-id disagreement or ambiguous provenance** (`C+0x4c` ↔ `[C+0x4c+8]` vs bound `name`), matrix conflated level/pitched, or `cameraModel` reused as reflection matrix. | Re-check the `0x854054` bit `7c.01` dump (`u=C+0xf8`, `(target,name)`, `C+0x4c`/`[C+0x4c+8]`), the whole-frame API trace (FBO attach / `glCopyTexImage2D` dst / `glTexImage2D` upload, FBO binding), the `0x854054`/`0x8f206c`-adjacent matrix dump at caller `+0x60` with `glViewport/glScissor` recorded level vs pitched, the U12-S waves-name correlation and the verdict `(class, target, name, w, h, u, M, viewport)`. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Record the disagreement as the finding; port keeps refusing water (hard-fail) until a real reflection bind lands; never `cameraModel`, never a viewport-sized heuristic FBO. |
| W6 | **U6 UV/winding not bit-exact** or **U5 time writer unknown**. | Re-check the virtual `+0x98` dump (4×f32 `MultiTexCoord0`, 6 indices / draw first-count, `GL_CULL_FACE`/`GL_FRONT_FACE`, same-frame `hmapW/H`) against `max‖attr/(W,H)−0.5 − VS_TexCoord1.xy‖ == 0.0`; re-check `glUniform1f(time)` samples over ≥3 frames / ≥2 s, the `C+0xc8` write-watchpoint EIP (or 10 s silent-watchpoint constant-0 verdict) and `C+0xc4 == 1.0`. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** U6/U5 stay labelled; no invented dividend/index/diagonal/cull and no `_time += delta` presented as donor time. |

**Can settle on green:** P0-1, P0-1b, P0-2, item-by-item, on each item's own zero-mismatch tuple. **Does not settle:** parity or any other P0.

---

## 2. S2 — FOW (P0-3), `fow_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| F1 | **Void session at P0** — pin mismatch, Class-N path active, missing knob log, `GetFOWEnable` not True, or `DynFogDepth` not False. | Re-check the per-run dump record `{run_id, seed=20261113, config_sha256, fixture_id, tick, camera_pose, viewer_set_count, per_viewer_res[], FOWBuildFull_flag, knob_getter_values, readout_kind, raw_values[]}`, the knob `Get*` log (**no `Set*` in P1–P5**), the pinned rig `58/−32°/400` / FOW-on gate path and the "no Class-N active" assertion. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Session void for that run; restart at the same seed. Never `--seed random` (N1) or menu Random (N2). |
| F2 | **FOW transect void / linear scale fit fails** (E-GRID-a): off-step cells, no single stable fine step width, or six radii not fitting one `k`. | Re-check the two perpendicular 1.0-unit `GetFOWLOSData(x,z)` transects spanning `±(res+8)` for vision `0/3/8` and reveal `R=10/20/30`, the 0.25-unit fine transect raw integers, `FOWBuildFull` + settled-tick flags; fit `dist <= k*res` with **0 off-step cells**. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No `1.0`, `2.0`, `53.333`, `0.5` or one-tile value enters the port without the fit; `1 res = 1 m` driver stays labelled. |
| F3 | **Combine / removal mismatch** (E-GRID-b), or the fill-cap arm missing its log. | Re-check the pair transect + bisector dumps, the 3-viewer removal sequence with `FOWBuildFull` + settled tick between removals, ally/enemy split, and the `GetFOWFillMaxNum`/`GetFOWDefDov` log; verify 0 mismatching cells across sub-runs. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** The raised `SetFOWFillMaxNum` is the only permitted knob write and only inside that arm; no threshold/per-team structure added on a guess. |
| F4 | **Occlusion rule unconfirmed on the rotated transect** (E-GRID-c). | Re-check control (no interposition) + hill/forest/wall interposition transects at coordinates actually present in the logged fixture, the `GetFOWElevation` default (unchanged), and the **second rotated transect** predictions with 0 mismatches. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No slope, blocker list or `FOWElevation` effect from a single transect. |
| F5 | **Persistence flapping or lane mixing** (P4): any flapping cell, or save+reload fed into a lane-B deterministic hash (N9 seed rewrite). | Re-check the full matrix — walk-away, player-switch round-trip (both legs), balloon/victory gate, viewer kill, save+reload, ally/enemy probe — ×2 repeats with 0 flapping cells; for a port-internal repeat check seed before and after; check that a cell changing at the capture tick with no recompute is quoted, not smoothed. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Save+reload arm is lane A only (N9 caveat); no explored restore without the save arm; no per-tick FOW rebuild asserted as donor. |
| F6 | **Sampler domain out-of-range or tint arm fails** (P5/P6): raw values out of domain, pixel sets not pairwise disjoint, or per-cell script read disagreeing with `>0`. | Re-check the 0.25-unit fine transect raw `Integer` returns ×3 repeats (0 out-of-domain), the 240² panel RGBA for never-seen / seen-now / explored-not-visible cells paired with `GetFOWLOSData` at each cell centre, both DPI arms (`scale = 2 iff ViewerHeight > 1535`) and the mandated 3-seed repeats (never pooled). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** `>0` stays the only port predicate; no RGBA/threshold/blend enters the port; `FOWColor` stays engine-default-only. |

**Can settle on green:** P0-3 (F-GRID a–e, persistence, tint, knob defaults), item-by-item. **Does not settle:** parity or lane-B admissibility (needs D0 preflight + a real donor frame).

---

## 3. S3 — Blend / completion (P0-5), `blend_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| B1 | **Missing engine dump / incomplete §2 per-tick row** — a `null` engine read treated as zero, or a row smoothed/averaged/dropped. | Re-check every trial's per-tick row for all §2 columns: `sim_tick`, `donor_frame_clock`, `displayed_frame_index` (engine read), `requested_frame_clock` (sim clock), `GetGameObjectFrameAnimationName_value`, `frame_data_sf_ef`, `pose_vertex_hash`, `handler_events[]`, `tag_fields`; a `null` is a missing dump, not zero. Confirm 3/3 trials per setting/sid and byte-identical `config_sha256_file` across trials. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No port change authorised; port keeps zero `lerp`/`mix`/`slerp` and one nearest frame. |
| B2 | **Animation handler absent / completion stand-in** (R-C1): no genuine non-empty `EndCyclesReached` firing; port remains clamp-at-last with empty hook. | Re-check the musketeer `attack1 [99,124]` → `idle1 [256,305]` and peasant `death [115,149]` captures at 30 Hz over `t0..t0+span+10`, frame index per tick, last-3-tick vertex hash, and the hold-at-last vs snap-to-idle vs mid-blend-freeze verdict **with tick numbers**, 0 mismatch 3/3 per sid; re-check `anim3d.gd:1780-1785` (empty hook), `:1794-1804` completion probe and `AAF_COMPLETION_STATUS`. A genuine firing would be a discovery to record, never to pre-wire. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No handler invented; clamp-at-last stays labelled. |
| B3 | **C2 handler firing ticks absent** — PFX/damage/sound offsets relative to `Attack`/`AttackEnd` not recovered. | Re-check the cannon `attack0/attack1 [301,337]` log: muzzle-flash PFX attach frame, damage tick, sound tick relative to `Attack` and `AttackEnd` firing ticks, cross-checked against the recovered `_unit_TryAttack(…,True)` → `SwitchTo('Nothing')` re-issue body; logged absence must name the exact window. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No effect-to-frame offset guessed; hook stays empty for other actions. |
| B4 | **`(0,0)` bypass invariant violated** — intermediate pose/snap under a true `(0,0)`, or `blend_bypass_violation` true. | Re-check the V1–V7 traces (`unit.script:10891-10893/11041-11042`, `ontagstates.inc:355-357/500`, `movie.script:636-637/639/586/1022/1076`, `eventdebuganimations.inc`) for `displayed_frame_index == requested_frame_clock` at every tick with no snap/window; confirm the death `Switch(6,8)→Reset` carve-out is not counted as a bypass. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Never apply a weight to an early-out/idle-re-entry/debug switch; any snap under `(0,0)` remains a defect. |
| B5 | **B1/B2/B3/B4 verdict not 3/3** — non-zero `w(t)` residual, divergent displayed-index sequence, unresolved polarity, or movie-window applicability unproven. | Re-check the step-response length under `(6,8)` vs forced `(0,0)` and the per-tick `w_t` projection onto donor frames A/B (0 residual all ticks for a named curve); B2 byte-identical index sequence; B3 sim `a3=False` vs aix `a3=True` tick table; B4 `bBlend` true/false with `maxblend=5` vs `0`; sim-inclusive vs movie-exclusive window law; Class-N exclusions and that `walk1` (donor-dead) was not requested. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** `w(t)` stays UNNAMED; no `"0,5"` added; no semantic name for `a3/a5/a6`; the port's 6-frame decimated subset is never donor evidence. |

**Can settle on green:** P0-5 B1–B4 / C1 / C2 and W/S/A/R tails, item-by-item. **Does not settle:** parity; `[U]-P1` native player tail or `FB` semantic on partial green.

---

## 4. S4 — Selection / projection (P0-8), `selection_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| S1 | **Camera marker mismatch or camera move within a battery** (T10 session integrity): rig not held, viewport changed, FOW on outside a veto probe, or a marker/log gap. | Re-check the fixed rig `58 / −32° / focal 400` with `Min/MaxFocalLength=400`, `FocalLengthPower=1.0`, fixed viewport and `GetViewerWidth/Height` per capture; re-check per-probe log `GetCameraAbsolutePosition` (cPos), `GetCurrentMouseWorldCoord` (mPos), `GetGameObjectRayCastCount` + post-`SortRayCastList` order, prio branch, `(1+dist)/prio`, returned handle, `GetCountGameManagerPickedObjects` membership; confirm ≥5 owner-surveyed markers and **no camera/map/viewport change within the battery**. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Any gap, missing dump or camera move voids the frame set; port approximations stay tagged. |
| S2 | **Reprojection ≠ 0 px / clip prediction wrong** (T1/T2/T3). | Re-check the `sub_4cd334` entry/exit dump (mode byte `*(p1+200)`, `(w,h)`, `focalArg`, struct floats `+0xac/+0xa0/+0xcc/+0xd0`, which of 5 GL paths fires), `GetCameraFieldOfView @0x5fece6` / `ByFocalLength @0x5fecfa` input→return, the whole-frame `sub_5d1c60` GL sequence, ≥5 surveyed points to captured integer pixels at 0 px, the `DepthOfView=1200` bracketed either-side and near-to-eye clip tests, and ≥3 aspect ratios. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No FOV/near/far/sensor/aspect value written as donor fact; `17.27°`/`0.1/4096`/`216/36/121.4` stay PORT APPROXIMATION. |
| S3 | **Pick winner / tie-break / 1-px nudge mismatch** (T6/T7). | Re-check the overlap rig (own peasant prio 1, wood 2, unbuilt building 6, enemy 7 within 1–2 px), per-handle `pos`, ray order, prio branch, `(1+dist)/prio` in XZ metres, returned `nearestHnd`, the constructed exact tie (1e-6, first-in-ray wins), the seed-`0.5` probe (or documented unconstructible), the 1-px nudge, the FOW-on veto returning 0, and the `GetGameObjectRayCastAABBByHandle`/`OctreeRayCast` sweeps at two depths with zero residual sort inversions. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Port screen-px `sd` + depth tie-break stay labelled; no AABB inside-test or prio threading on a guess. |
| S4 | **Drag anchor / marquee membership mismatch** (T4/T5). | Re-check the LMB press, 1–3 px epsilon-crossing steps in four directions, `GameManagerIsSelectionMode` onset frame, frozen rect corner matching press-point or first-move-point at **0 px / 0.0 m**; re-check `GetCountGameManagerPickedObjects` membership for all inset/outset rects including 1-px edges and both drag directions (zero mismatches). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Port keeps the dual-anchor model and centroid-in rule until their rows terminate. |
| S5 | **Minimap affine/quad ≠ 0 px** (T8/T9) or DPI arm missing. | Re-check ≥6 surveyed markers across both axes, the fitted `u=sx·x+ox`, `v=sz·z+oz`, panel captures + `GetGUIMiniMapPosition/Width/Height` on both DPI arms and a non-square map, ≥5 corners to 0 px (byte-identical repeat), 4 widely separated camera poses incl. map-edge clip, and all 4 stroked frustum edges at 0 px (×8 audit). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** `stroke_minimap_quad` stays unwired; fog tint ladder is outside P0-8; no save/tick/ai/fow/water edit from this packet (C-7). |

**Can settle on green:** P0-8 T1–T10, item-by-item. **Does not settle:** parity.

---

## 5. S5 — Save (P0-6), `save_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| V1 | **E-T0 control fails — harness broken**: identical-state re-save not byte-identical except the six jitter fields. | Re-check the third identical-state re-save `.map` byte-diff against save A: bytes 0–3, `OSWMap13…`/snapshot/record tags, trailers, file size + SHA-256; verify the only divergences are `lasttimecheckcapture`, `lasttimeidlegrid`, `lasttimescangrid`, `lasttimetopology`, `lasttimebestposition`, `lastsearchenemy` (and `uniqrnd=0→random` on load), 3 identical-seed repeats. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No case is admissible until E-T0 passes; fix the harness, claim nothing. |
| V2 | **Profile bytes unreadable / native store snapshot missing** at `UserSaveProfile`/`UserSaveProfileExt`, `StateMachineGlobalVariables*`, `GetAppSaveDirectoryPath` suffix or `custommap` Start-only snapshot. | Re-check the §4 native store bytes before/after Start and before/after Accept on a **fresh user profile** (existing dir backed up/renamed aside, headless boot with no Start pressed), struct keys `gProfile`/`gProfileUserStruct`, and the produced `.map` files; byte format and flush timing are `[U]` and must be learned from snapshots, never assumed. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No store encoding or flush timing invented; no `.sav` magic invented (`.sav` is a non-question). |
| V3 | **Divergence at unpredicted offset / more than one field diverges.** | Re-check the full divergent dump verbatim with offsets and neighbouring field names, first-256-B hexdump, and the predicted `[D]` offsets (e.g. TObj `hp`@20, `trghnd`@120, `uniqrnd`@148, 866 B span) against the single changed field; confirm all other bytes identical (jitter excepted). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Record FAIL; never trim/force-fit the dump to make it match. |
| V4 | **Predicted encoding contradicted** — 8 B doubles instead of 4 B LE `00 00 80 3F`/`00 00 00 40`, `C3 A9` codepage instead of single-byte `E9`, handle instead of `uid`, unexpected fresh-save version word. | Re-check the §2 case dump against the cited `[O]/[D]` expectation (fresh-save word `5C 00 00 00` build 92; ship map's `35 00 00 00` build 53 is only a wrapper oracle; Boolean 1 B `00→01`; `orders[].trg = uid`, not handle; `victorystate` `0/1/2`). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Report the well-formed alternative as a finding, never force-fit; no byte/transform/trailer invented; additive telemetry only, v5 wire unchanged, no version bump. |
| V5 | **Repeat divergence / missing dump or trailer** across the 3 identical-seed repeats. | Re-check all three repeats agree for the case, trailer/`GameMapRecordEnd`/`GameMapEnd` presence, the six-field jitter exception, and that a masked or averaged diff was not used. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** A passing case confirms only its single byte question; it never promotes P0-6 or establishes save parity. |

**Can settle on green:** P0-6 byte questions, case-by-case. **Does not settle:** parity; no donor `.sav` exists.

---

## 6. S6 — Tick (P0-4), `tick_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| T1 | **Tick hash divergence** — any single-tick difference in `H_0…H_3599` across the 6 sequences. | Re-check canonical `H_f = sha256(canonical_json)` keyed `(seed, run_kind, global_frame f, event_seq)`, sorted keys + full Float precision (R2 veto compares `==`, never quantised), over 3 literal seed key pairs × process restart = 6 runs, `N=3600` ticks = 112.5 s, 12 roster slots incl. slot 11 mercenary, and the immutable manifest (config SHA, 3 seed key pairs, startid set, speed factor, Class-N "none active"). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No order adopted; `TICK_ORDER v1 PORT APPROXIMATION` stays frozen; no fallback, threshold retune or retry-until-green. |
| T2 | **No single survivor / multiple survivors.** | Re-check the winner-with-loser list against the §4 candidates (rotation (i)/(ii)/(iii), block-boundary permutations, rate law); verify losers are deleted/listed, never averaged or merged. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Never ship two orders; index-order slice stays a PORT SUBSTITUTE. |
| T3 | **Wrong-stream or wrong-count RNG draw at a site.** | Re-check the §3.5 draw-count record (`draws_before/after`, `stream`, `site_id`, `n_literal`, `reseed_bool`) for S (`RandomExt` `0x60f64c`) vs G (Delphi `0x403a0c`) attribution, the X21 oracle assert for S and count-only for G; one wrong stream/count fails the candidate. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Never merge S and G; never invent a draw or count to fit a hash. |
| T4 | **Gate not absolute-deadline / R2 veto quantised / closed gate.** | Re-check the §3.3 gate record (`deadline_before`, `gametime`, `addtime`, `fire_bool`, `veto_bool` + colliding player/itype, `deadline_after`) for R1 (absolute deadline, no catch-up), R2 (exact-float cross-player veto), R3 (caller-only write); verify Float `==` was not quantised and no `+=` accumulator used. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Candidate FAIL; no countdown accumulator, no deadline quantisation. |
| T5 | **Inadmissible run** — init phases unasserted, Class-N active, wall-clock/frame-paced stepping, missing stage-order record. | Re-check §2.1 admissibility and step 2 assertions (`progresstick:=id*2`, four absolute deadlines, entity `floor(RandomExt*32)`), §3.1 `time_s == f/32`, §3.6 `stage_order_observed` with `[O]` stages logged `absent` (never invented), N3 fisher neutralised, no watchdog/800×600/`load_save` rewrite. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** Inadmissible run settles nothing; instrument additively without changing sim order, RNG consumption or save keys. |
| T6 | **U-O7 unobservable / no driver VA recovered.** | Re-check the §3.7 section-visitation log with section-max budgets frozen (stride vs contiguous, rotation offset, interval class, capture-protector scan order); confirm no native scheduler/driver VA was invented. | **KEEP `[U]` OPEN — record `[U]-O1 PERMANENTLY NATIVE`.** No port change; keep the labelled port order. |

**Can settle on green:** P0-4 rotation/rate/interleave/cadence items, only on single-survivor zero mismatch. **Does not settle:** parity — internal self-consistency against donor-text-pinned algebra; no donor binary involved.

---

## 7. S7 — RNG (P0-7), `rng_owner_protocol.md`

| # | Concrete failure mode | Exact diagnosis — dump/log to re-check | Required action |
|---|---|---|---|
| R1 | **RNG oracle mismatch — an S draw diverges from X21.** | Re-check the canonical `test_vectors.json` oracle (authoritative) with f32 round-trip bits, **not** the disclosed Markdown row-7 `bits LE` discrepancy (`99d0093d` vs `99009d3d` — re-derive, never hand-transcribe or invent a resolving value); re-check the §3.2 S record (`s_hex`, `f32_hex_le`, `n_literal`, `floor_result`) against `3C6FEF6C…A2C21855`, and that the oracle-context first S state is `0x3C6FEF6C` from `(key0=0x44A108F9, key1=0x00000001)` injected only into the model, never `Data.RANDOM_SEED`. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No wiring; no value invented to resolve the table discrepancy. |
| R2 | **Wrong stream / wrong count / extra or missing draw.** | Re-check §3.2 `stream` ∈ {S, G, stored, 0}, `draw_ordinal`, `n_before/n_after` and the stage-keyed ledger `(stage_id, generator_version, stream_name)` at S0–S5; verify `uniqrnd` is a stored value (not a draw) and `frnd` follows scatter (S3-b); verify no `m+n` or `minesdensity`/version-gated count was invented. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** FAIL, not a value to fit; never merge streams into one or route a G site through `sim_rng`. |
| R3 | **G value misread as a mismatch** (violating the count-only rule). | Re-check §3.4: G values free-run from process-start QPC/TickCount (`0x4033b8`, slot `0x8f2008`) and can never be snapshotted; only the draw count and G attribution are admissible; re-check the L2 `0x8f2008` process-start dump and §3.2 G `byte_or_float`/`scale` (`0x8f206c = 2^-32`, not the S divisor). | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** A G value difference is not a failure; do not wire anything until counts/attribution are 0-mismatch across the full series. |
| R4 | **Restart / seed-change check divergence.** | Re-check §5 same-seed restart (per-tick canonical state hash + per-frame `sha256_pixels`), process restart (G seed **must** change), same-process regeneration (no per-map G reseed), `key0`-only (bit-identical S streams), `key1` ±1 (S changes), reseed identity (same-key only, no G write), and restart-after-save/load seed `20261113`. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** FAIL; no partial green wires a stream. |
| R5 | **L2 breakpoint dump mismatch** (owner debugger only; no GPU frame). | Re-check §3.5 dumps at `0x60f64c` (S state before/after + f32 return at `0x60f68e`), `0x403a0c` (G state + returned byte), `0x8f2008` (process-start seed + stage boundaries), `0x8f206c` (2^-32 divisor); require every S value equal to the model with 0 mismatches and every G advance equal to one draw with no missed hits. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** L2 is a native state dump, not a donor A/B frame; no parity from L2. |
| R6 | **Seed-context conflation / Class-N active / partial series.** | Re-check the harness literal `20261113` vs synthetic oracle `(0x44A108F9, 0x00000001)` kept separate, config SHA-256, "no Class-N active", no `watchdog:`/`wall-clock limit reached` line, and that **all** series R20/L20/C300/U50/F1M/K0/A600 ran in full before any flip. | **KEEP `[U]` OPEN; REPEAT UNDER CORRECTED SETUP.** No partial series closes a G1 sub-item; no threshold retune; no port-internal replay pair accepted as donor evidence. |

**Can settle on green:** P0-7 G1 sub-items, only on full-series zero mismatch. **Does not settle:** parity; G values stay count-only forever; native `@Round` address, signed-`key0` donor behaviour, generation-owned key bytes and live-replay equivalence stay `[U]` (`rng_owner_protocol §7.3`).

---

## 8. Common rule — all seven sessions (non-negotiable)

1. **Partial or ambiguous result ⇒ parity UNVERIFIED and the P0 row open.** Any mismatch, missing dump, void session, Class-N path, wrong PATH/seed/fixture/camera, closed gate, wrong stream/count, non-0 px, non-0 ULP, single-tick divergence, or absence of a single survivor leaves that item `[U]` and its named P0 row open. No item is promoted by a partial green, an average, a "close" value, a metric, a still, a replay pair, a labelled substitute or a port fallback.
2. **`RESULT IS NOT GOOD` remains.** `blocking_unverified` stays non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus tails). The stable handoff wording is carried verbatim from `p0_session_plan.md §7`:

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — blocking_unverified is non-empty (no donor A/B frame; water U12/U4*;
FOW grid; tick interleave; animation blend; save container; RNG G1; selection/projection).
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = [PT-V1, PT-V2, PT-V3, PT-V4, PT-V5, PT-V6, PT-V7,
                        P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8,
                        W-R1, T-SEED, T-CALLBACK, atlas-layout, X17, U-INJ-1..11,
                        plus the domain residuals]
```

3. **`RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all tier-2 conditions hold** — not after these sessions, not on a capture, and not on a COORD-independent reading. Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", or "gate PASS" derived from a capture (`decision_sim.md:142`).
4. **Divergent dump is quoted, never smoothed.** A failed ★ gate records the divergent dump verbatim with offsets/registers/event ids and leaves the item `[U]`; it is never trimmed, averaged, retried-until-green or threshold-retuned.
5. **Failure ⇒ later repeat of the same session, not a fix-by-substitute** (`p0_session_plan.md §6.5`): the same packet must be re-run at its exact setup. No merge of sessions is legal (`decision_sim.md:93`); one session executes at most one packet protocol at a time.
6. **Even all-green leaves parity UNVERIFIED.** Each session retires only its named `[U]` to `[D]+capture-id/harness-id`. No session produces a matched donor GPU A/B frame or a COORD ruling; six-condition chain stays 0/6 until condition 6 is signed on demonstrated geometry-byte equality + a pixel-identical matched frame.
7. **Workers remain forbidden** to run donor binaries, Godot/gate/harness jobs, captures, or to promote a `[U]`; all seven sessions are owner/COORD-only.

---

## 9. Claim register and file discipline

| # | Claim | Label |
|---|---|---|
| 1 | Seven failure-mode tables map one-to-one to the seven dedicated owner sessions and their named failure modes: no water-visible frame (S1), FOW transect void (S2), animation handler absent (S3), camera marker mismatch (S4), profile bytes unreadable (S5), tick hash divergence (S6), RNG oracle mismatch (S7). | [D] `p0_session_plan.md §1`; the seven owner protocols |
| 2 | Every row supplies an exact dump/log diagnosis and a required action drawn only from {REPEAT UNDER CORRECTED SETUP, KEEP `[U]` OPEN}; no third action form exists. | [O] this report §1-§7 |
| 3 | Thresholds are restated, never relaxed: 0 differing bits/elements over ≥2 frames + move; 0 off-step/mismatching/out-of-domain cells; 3/3 trials; 0 px; single survivor over 6 sequences; E-T0 control; full-series 0 mismatch; G values count-only. | [D] the seven owner protocols' zero-mismatch sections |
| 4 | No threshold retune, no invented value, no port result substituted for donor evidence; port-internal replay/metrics/stills/labelled substitutes settle nothing. | [D] `decision_sim.md §4`; `p0_session_plan.md §0/§6.5`; each protocol hard-fail matrix |
| 5 | Any partial/ambiguous result leaves parity UNVERIFIED and the P0 row open; `RESULT IS NOT GOOD` remains while `blocking_unverified` is non-empty; six-condition chain 0/6. | [D] `p0_session_plan.md §7`; `decision_sim.md §0/§2.3` |
| 6 | Donor execution is owner-only; this worker executed no code, Godot, git, donor binary, gate, capture or ROI metric; no donor GPU A/B frame exists. | [O] scope guard; `CHARTER.md:66-72` |
| 7 | No approximation adopted, no parity claimed; exactly one repository file written — this report. | [O] scope guard |

*End of PORT1TO1-SESSION-RISKS. Read-only; exactly one repository file written; no code/Godot/git/donor execution; no threshold relaxed; no value invented; no port result substituted for donor evidence; no approximations; no parity claim. Seven owner sessions specified, zero performed; any failure keeps its `[U]` open and its P0 row open; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
