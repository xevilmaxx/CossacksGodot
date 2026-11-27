---
id: PORT1TO1-P0-SESSION-PLAN-2026-11-26
title: "Updated owner session plan — seven owner packets grouped into the minimum number of dedicated owner sessions (full 1:1 Cossacks 3 donor port)"
worker: P0-SESSION-PLAN (read-only subagent)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md]
files_edited: []
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, manifest, result JSON, backup, git state, Godot process, runner job, gate, capture, ROI metric or donor binary was created, modified or executed; no donor GPU frame was produced or compared. Exactly one repository file written: this report."
labels: [OWNER_SESSION_PLAN, MINIMUM_SESSION_COUNT, OWNER_ONLY_DONOR, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
verdict: "RESULT IS NOT GOOD — zero P0 settled by the existing terrain Route A capture; all nine P0 rows open; four GPU donor sessions + one paired-save donor session + one native-state-dump/harness session + one harness-only session are SPECIFIED, not performed; six-condition chain 0/6 CLOSED; no accepted approximation, no parity claim."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_decision_sim.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions_update.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief_addendum.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/CHARTER.md (§4 :66-72)
---

# PORT1TO1 — updated owner P0 session plan (2026-11-27)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This plan specifies sessions; it performs none.** Every step below is an owner/COORD run-book carried from the seven delivered packets. No worker executes any of it. A packet can settle its named P0 row(s) **only** when that packet's exact zero-mismatch criterion terminates; no packet, and no session, settles parity.

## 0. Three explicit baselines (non-negotiable)

1. **Zero P0 are settled by the existing terrain Route A capture.** `PORT1TO1_decision_sim.md:81` verbatim: "a Route A donor session, as defined in `X39 §3`, settles ZERO P0 packets. It is a terrain capture + manifest, not any packet's terminating experiment." Route A (`X39_ab_feasibility.md §3`) produces one 320² Land/summer terrain PNG + `.map` + manifest for chain condition 1; it supplies none of the water tracer dumps, FOW `GetFOWLOSData` transects, blend per-tick traces, tick hash matrix, paired single-field saves, selection reprojection probes or RNG draw series. A donor frame is **necessary but not sufficient** (`X39:34/178`).
2. **Donor execution is owner-only; workers are forbidden.** `CHARTER.md:66-69` verbatim: "Read-only donor. No donor executable is run, no donor binary is copied or committed. Craft Anything read tools only. Donor material = private use only." Each packet restates this: no worker launches `cossacks.exe`, attaches a debugger/tracer, captures a GPU frame, produces a donor save, runs a Godot/gate/harness job, or promotes a `[U]` to `[D]`. This worker executed nothing.
3. **Parity stays UNVERIFIED until a matched A/B frame plus an explicit COORD ruling.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, six-condition chain **0/6 CLOSED** before, during and after all seven sessions. Even a fully green packet battery yields only `[D]+capture-id/harness-id` internal results. Chain condition 6 requires a COORD-signed ruling of demonstrated geometry-byte equality + pixel-identical matched frame; no such ruling exists. No tier above 2; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.

## 1. Coverage: seven packets → nine P0 rows

The seven packets cover the nine canonical rows of `PORT1TO1_u_register_update.md §1` (water is three rows). This supersedes the advice-only ordering in `PORT1TO1_p0_packet_index.md §2` and the stale "six packets / P0-7 has no packet" wording in the index and `PORT1TO1_handoff_checklist.md:136` (repair recorded at `PORT1TO1_owner_decisions_update.md §0/§3`).

| Session | Packet file (`docs/terrain_swarm_2026-11-26/reports/`) | P0 row(s) it can settle | Execution lane (owner/COORD only) |
|---|---|---|---|
| **S1** | `PORT1TO1_water_owner_protocol.md` | P0-1, P0-1b, P0-2 (W-U12 / U4* / U1-U3-U5-U6) | `RUNTIME-GPU` donor tracer + debugger |
| **S2** | `PORT1TO1_fow_owner_protocol.md` | P0-3 (F-GRID a–e, persistence, tint, knob defaults) | `RUNTIME-GPU` donor session; script dumps; one pixel arm |
| **S3** | `PORT1TO1_blend_owner_protocol.md` | P0-5 (B1–B4, C1/C2 + W/S/A/R tails) | `RUNTIME-GPU` donor session, 30 Hz paused-stepped |
| **S4** | `PORT1TO1_selection_owner_protocol.md` | P0-8 (E-U13, V1-SENSOR, V2-PROJ/-NF/-ASPECT/-DRAG/-BOX/-MINI) | `RUNTIME-GPU` donor session, fixed survey rig |
| **S5** | `PORT1TO1_save_owner_protocol.md` | P0-6 (S-SAVE-R1a…g) | Paired-save donor session + native profile-store snapshots (no GPU frame) |
| **S6** | `PORT1TO1_tick_owner_protocol.md` | P0-4 (S-TICK-O1 + D1–D3 companions) | Headless fixed-dt harness — **no donor binary** |
| **S7** | `PORT1TO1_rng_owner_protocol.md` | P0-7 (S-RNG-G1) | Headless fixed-dt harness (L1) + owner-only donor native state-dump breakpoints (L2, **not** a GPU frame) |

**Minimum count = seven dedicated owner blocks, one per packet.** S1–S4 are GPU sessions, S5 is a paired-save session, S7 carries a native state-dump layer, S6 never touches the donor. No merge reduces this count (§2).

## 2. Why seven is the minimum (merge-incompatibility, not a preference)

`PORT1TO1_decision_sim.md:93` states the binding bound: "one owner-authorised session can execute at most one packet protocol at a time, and only if that session supplies that packet's exact scene/camera/dumps/repeats." Shared pin/seed/camera/config lets the owner **prepare once** (§3); it does **not** permit merging, because a merge voids at least one packet's zero-mismatch frame set:

| Candidate merge | Blocking incompatibility (verbatim packet constraints) | Result |
|---|---|---|
| S1 water + S2 FOW | Water needs a **water-visible map**, unmodified `water.lib`, GL/FBO trace and **level→pitched camera move**; FOW needs pinned fixture `land/med/plains`, FOW on, one **fixed** camera target and **no camera move**; FOW dumps are `GetFOWLOSData` script reads, not pixels. | Void — camera move + scene + readout class conflict. |
| S1 water + S3 blend / S4 selection | Water's moving camera and trace session conflict with blend's fixed-camera 30 Hz paused-step 3/3 trials and selection's fixed survey rig / 4 poses. | Void. |
| S2 FOW + S4 selection (both use the 58 / −32° / 400 rig) | FOW: pinned skirmish fixture, FOW **on**, no camera move, script cells, 3 seeds where mandated. Selection: flat area, FOW **off** except veto probes, ≥5 owner-surveyed markers, 4 camera poses, ≥3 aspect/DPI arms, pixel reprojection to 0 px. Different fixture, FOW state, camera policy and readout. | Void — the shared camera pin alone is insufficient. |
| S2 FOW + S5 save | FOW P4 save+reload is **lane A only** (N9 caveat); S5 requires a fresh profile, known-state paired saves and an identical-state re-save control. | Void — harness control and seed-rewrite admissibility conflict. |
| S3 blend + S4 selection / S5 save | Per-sid 3/3 per-tick traces vs surveyed-marker/minimap session vs single-field paired saves; different sids, scenes and artifacts. | Void. |
| S6 tick + S7 RNG (both share the fixed-step contract) | Tick: 12 players × 3600 frames × 3 seed key pairs × restarts × 3 load profiles; RNG: seven different series (R20/L20/C300/U50/F1M/K0/A600) with a distinct synthetic X21 oracle context and process-restart seed checks. They may be queued in one owner/COORD harness window, but they are **two distinct packet runs with distinct manifests**; neither is a donor session and neither settles the other. | Two blocks (S6, S7), not one. |

Consequence: **one session per packet is both necessary and sufficient**; "one session settles all P0" is false, and "close"/metric/still/replay pair/port fallback never settles any row (`p0_packet_index.md:55`).

## 3. Exact shared setup — prepared by the owner, applied per session

### 3.1 Pin (S1, S2, S3, S4, S5 and S7-L2; S6 has no donor target)

`t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`. Owner re-hashes read-only at each session; the binary is never copied, patched or committed. All donor VAs/evidence ids are re-cited pinned `[O]/[D]`; decompilation context is Ghidra 12.2 + built-in 0.6.1, Deep mode. Line anchors marked `VERIFIED` are re-read at apply time because concurrent drift is observed (water `bind_reflection_map` now `:501`; blend `_frame_blend_fields` now `anim3d.gd:1020-1041`; tick block now `game.gd:5727-5787`/`6059-6088`).

### 3.2 Seed contexts (never conflated)

| Context | Exact value | Used by |
|---|---|---|
| Acceptance / harness literal | `20261113` | S2 FOW, S3 blend, S5 save, S6 tick (×3 pinned `randkey0`/`randkey1` pairs), S7 RNG L1 |
| Synthetic X21 oracle pair | `(key0=0x44A108F9, key1=0x00000001)` — **never a donor seed, never written to `Data.RANDOM_SEED`** | S7 L20/S6 oracle only |
| Owner-recorded fixed seed | recorded as run metadata, no packet-pinned value | S4 selection |
| No literal seed pinned by packet | water-visible map + shipped unmodified `water.lib` (`CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`) | S1 water |

Never `--seed random` (Class-N1), never the menu Random button (N2). S2 repeats the identical packet at two further recorded seeds where §5 mandates 3 runs (tint, sampler domain, knob defaults) — never pooled across seeds. S7 keeps the two contexts strictly separate (`rng_owner_protocol §1.2`).

### 3.3 Camera (exact pins)

- **Gameplay rig (S2, S4):** `SphereHeight/SphereLength=58`, `Min=20`, pitch `−32°`, focal `400` (`camera.cfg:6-10,32-35,44-45`); S4 additionally `Min/MaxFocalLength=400`, `FocalLengthPower=1.0`; S2 requires `DynFogDepth=False` so visual fog cannot confound a readout. One fixed target per battery; any camera/map change voids the frame set.
- **S1 water:** level→pitched camera move is **mandatory** to expose clip-plane dependence of the reflection matrix and per-frame FBO/copy refresh; every dump tagged with camera pose and map name.
- **S3 blend:** one fixed camera per battery, paused-then-stepped sim at donor 30 Hz; `sim_tick` recorded separately from wall clock; port frame count never substituted for donor tick.
- **S4 selection:** fixed rig held within a battery; 4 widely separated camera poses for V2-MINI-QUAD (incl. map-edge clip); both DPI arms (`scale = 2 iff ViewerHeight > 1535`); fixed viewport size with `GetViewerWidth/Height` logged per capture.
- **S5 save / S6 tick / S7 RNG:** no survey camera; S5 is a known-state save scenario, S6/S7 are headless fixed-dt with authoritative 1280×720 viewport.

### 3.4 Config / engine contract

- **Port approximation labels stay on:** `fov_deg = 17.27`, `FOV_DEG_ASSUMED = 17.27`, `NEAR_M=0.1/FAR_M=4096`, screen-UV bias, `cull_disabled`, nearest-single fetch, depth tie-break, dual drag anchor, `±2.96`, `1 res = 1 m`, `_time += delta`. None is adopted as a donor fact by any session; each flips only on its own zero-mismatch row.
- **Harness packets (S6, S7, and optional S2 lane B):** opt-in fixed-step path `--deterministic-capture --capture-ticks N`, literal `--seed`, `deadline_ms=0`, `watchdog=0`, authoritative 1280×720 windowed, CPU fallback refused, N3 fisher `randf()` code-neutralised and no fishing delivery; config SHA-256 pinned; explicit "Class-N none active" assertion in the manifest; excluded paths: `--seed random`, menu Random, wall-clock watchdog, frame-paced stepping, async-load yields, 800×600 fallback, `load_save` seed rewrite, audio RNG/wall-clock dedup.
- **S2 lane B only:** temp copy of `variant3d/config_donor_capture.json`, bytes + SHA-256 before/after; D0 preflight required; if `--deterministic-capture`/`--capture-ticks` are absent, lane B is unavailable and the packet stays donor-runtime `[U]`.
- **S3:** one temp config copy; `config_sha256_file` byte-identical across all 3 trials; manifest asserts `deterministic == true`, `seed == "20261113"`.
- **S5:** fresh user profile (owner backs up/renames existing dir aside), headless boot with no Start pressed, profile-store snapshots at §4 capture points.

### 3.5 Manifest / log schema (exact fields)

| Session | Mandatory per-run / per-dump fields |
|---|---|
| S1 | PATH ∈ {DEV,BUILTIN,FIXED}, map name, camera pose, breakpoint VA + register/memory dump, API-trace event ids, sentinel checks, tracer frame file + per-item verdict tuple |
| S2 | `{run_id, seed, config_sha256, fixture_id, tick, camera_pose, viewer_set_count, per_viewer_res[], FOWBuildFull_flag, knob_getter_values, readout_kind, raw_values[]}`; knob `Get*` log, no `Set*` in P1–P5; dash rule recorded |
| S3 | Per-tick row: `sim_tick, t_seconds, donor_frame_clock, selected_anim_token, AAF_first, AAF_last, requested_frame_clock, displayed_frame_index, GetGameObjectFrameAnimationName_value, frame_data_sf_ef, sample_frame(port), blend_args(min,max), requested_blend(port), blend_bypass(port), blend_bypass_violation(port), pose_vertex_hash, joint_track_hash_or_ankle_joint_xy, engine_state, handler_events[], tag_fields(...)`; 3/3 trials per setting/sid |
| S4 | Per probe: `GetCameraAbsolutePosition` (cPos), `GetCurrentMouseWorldCoord` (mPos), `GetGameObjectRayCastCount` + post-`SortRayCastList` order, prio branch, `(1+dist)/prio`, returned handle, `GetCountGameManagerPickedObjects` membership, selection-mode onset frame, panel screenshot + `GetGUIMiniMapPosition/Width/Height`; ≥5 surveyed markers (owner-placed, none pinned here) |
| S5 | Two `.map` saves + third identical-state re-save per case, file size + SHA-256 each, first-256-B hexdump, full divergent dump verbatim with offsets/neighbouring field names, native store snapshots, 3 identical-seed repeats |
| S6 | Keyed `(seed, run_kind, global_frame f, event_seq)`, canonical JSON sorted keys + full Float precision (R2 veto compares `==`, never quantise); `H_0…H_3599` per run; manifest: config SHA, 3 seed key pairs, startid set, speed factor, 12-player roster, Class-N "none active"; winner + loser list |
| S7 | Keyed `(series, seed_context, run_kind, tick, event_seq)`, canonical JSON; §3.1–§3.6 frame header/per-site RNG record/reseed log/G count-only; stage-keyed ledger `(stage_id, generator_version, stream_name)`; L2 breakpoint dumps; oracle = canonical `test_vectors.json` + f32 round-trip (the row-7 `bits LE` Markdown discrepancy is disclosed, not hand-transcribed) |

## 4. New pins that shorten sessions (narrow only — none removes a zero-mismatch requirement)

| Pin (all `[O]`/`[D]`, static) | Where it lands | What it lets the owner skip / focus on — and what it does **not** allow |
|---|---|---|
| **Blend 8-arg native prototype** @`0x630100`, non-blend twin @`0x642e00`; `a3/a5/a6` → `randomcycles/randomframe/randomfbcycles/randomfbframe`, tail `minframeblend/maxframeblend` (`DEC_U_blend_deep.md`) | S3 | R-B3 is narrowed to the **FB semantic only** (`[U]-B3-FB`, no name assigned); arg-name derivation can be skipped. **Cannot** skip `(6,8)` vs `(0,0)` 3/3 per-tick traces, `w(t)` (B1), frame fetch (B2), handler ticks (C1/C2), or R-P1. `afpLinear` names a mesh mode, **not** `w(t)`. |
| **Tick CODE API cluster** — `GetPlayerCurrentPlHandle @0x690692`, player-index `0x68f4e2`, section `0x693a00–0x693c00`, thread `0x693f89`/`0x6a8894`, time/state `0x69faf6–0x69fbce`, GO-delay `ExecuteState @0x63c4c4…` (`DEC_U_tick_deep.md`) | S6 | Harness narrowed to U-S1/S2/S3 + U-DSP/U-THR; no need to re-hunt API names. Global `0..MaxPlayerCount-1` loops are proven bookkeeping, **not** rotation; `sub_690048`/`0x690624→0x690692` decode as data-as-code garbage and are discarded. **Cannot** skip the 3600-frame ×12-player ×3-seed ×restart matrix, or infer rotation/rate/stage order from names. |
| **Water 30-key tables & selector** — `wst*` @`0x853834+`, plain @`0x853c70+`, binder `FUN_00854054` mask `0x3FFFFFFF`, two-flag AND @`0x856530`, embedded BUILTIN VP/FP source verbatim, link-error strings in `FUN_00855b38` (`DEC_U_water_shader_deep.md` §§0–2 only; file self-truncated mid-§2) | S1 | U1 narrowed to BUILTIN-vs-LEGACY (needs two runtime globals); shader-source text need not be re-derived but **must** be hooked (`glShaderSource`) and all 30 keys actually queried logged. `CustomEnable=False` excludes CUSTOM, does **not** force BUILTIN. No unwritten remainder may be cited. |
| **U12 copy thunk chain** — static edge `0x4ed44c → 0x4afb3c → __imp_glCopyTexImage2D`; container `sub_4ed28c`, caller `sub_7715f4 @0x771b50`; no water-scoped static caller (`DEC_U12_deep.md`) | S1 | U12-A/A2/Q/R1/R2 narrowed to one GPU trace with backtrace + write-watchpoint on `C+0x4c`. `TOSWRefTextureImage` is a suggestive name `[I]`, **not** the proven backer `[O]`. |
| **hmap f32 clamp `±2.9639999866`** byte-proven from D04 height specimens (`DEC_U_hmap_num_deep.md`) | S1 | U3 narrowed to per-map live `(W,H,Min,Max)` tuple + file-grid comparison + GL name history. It is a **record clamp, not a live uniform**; `±2.96` (`texturemap.inc:29`) is classification-only and `2.964` is generation text — none may be wired as recovered hmap uniforms. |
| **FOW numeric negatives** — string-table DATA anchors `FOWEnable @0x1d9daa`/VA `0x5da9aa`, `GetFOWLOSData @0x2a7812`/VA `0x6a8412`, `FOWBuildFull @0x2a7906`; `53.333…` has zero f32/f64 hits image-wide; `1.0f @0x3613f5` is boolean-to-float (`DEC_U_fow_numeric_deep.md`) | S2 | Replaces static value hunting with script transects + owner debugger RTTI reads. **Cannot** supply cell size, slope, operator, layout or knob default. |
| **Save shipped `.map` heads** — `ausmis1.map`/`battle1.map` open `35 00 00 00` + `OSWMap13…` + `GameMapEnd`; fresh-save word `5C 00 00 00` (92) is a `[D]` prediction (`DEC_U_save_deep.md`) | S5 | E-C/E-G paired build-92 saves and E-A/E-B store snapshots are bounded. Build-53 envelope is **not** the build-92 wire; no checksum/transform byte may be invented. |
| **Selection `GetCameraFieldOfViewByFocalLength(focallength, viewportdimension)` @`0x5fece6` + inverse @`0x5fed52`; `m = max(w,h)` divisor; world-segment-vs-AABB predicate @`0x63153e` (`DEC_U_select_deep.md`)** | S4 | One fixed rig with ≥5 surveyed markers replaces name hunting; `viewportdimension` is a named argument, not a resolved dimension. **Cannot** supply sensor widths `216/36/121.4`, FOV `17.27°`, near/far from `96`/`0.0001f`, a drag anchor or a marquee rule. |

## 5. Per-session ordered plans

Each session is executed top-to-bottom by the owner/COORD under the §3 setup. `★` = stop-and-gate: a failed gate records the divergent dump verbatim and leaves the item `[U]`; it is never smoothed over, averaged, retried-until-green or threshold-retuned.

### S1 — Water: P0-1 / 1b / 2 (`water_owner_protocol.md`)

1. **Phase 0 (§3 steps 1–3, ★):** launch under tracer on pinned build, water-visible map, shipped unmodified `water.lib`, pause; exec-break `FUN_00603d30 @0x603d30` entry and read `[ebp+0x1c]` — **no field break ⇒ session void, nothing settled**; start API trace + frame counter; from here ≥2 water-visible frames + one level→pitched move for every phase.
2. **Phase 1 (steps 4–8, ★ U1):** break `FUN_00851bdc @0x851bdc` (`param_2`: `0`→ctor `0x856080` ENGINE, nonzero→copy `0x852f5c` FILE), `FUN_00855b38` (link), `FUN_00856530` (two-flag selector: CUSTOM `0x8565d2` / BUILTIN `0x856897` / FIXED `0x856846`); hook `glShaderSource` + `glGetUniformLocation`; write `PATH ∈ {DEV,BUILTIN,FIXED}`. Every later dump is tagged with this PATH; a dump on the wrong path settles nothing.
3. **Phase 2 (steps 9–11, ★ U4*):** dump `C+0x88..+0xc4`, dirs `C+0xb4/+0xbc`, colours, `C+0xc4` Speed; hook `glUniform1f`/`glUniform2f` for S1–S11/W0/W1/S10/S11; captured tuple must be bit-exact one donor tuple (0 ULP, 2 frames + move). Literals `0.01/0.02` are pre-bind defaults, never live uniforms.
4. **Phase 3 (steps 12–17, ★ U12):** break reflection gate + `FUN_00854054` bit `7c.01`; record unit `u=C+0xf8`, `(target,name)`, texture object `C+0x4c` ↔ `[C+0x4c+8]` agreement; full-frame provenance test (FBO attachment / copy dst / static upload), tex params, 4×4 matrix at caller `+0x60` with level/pitched recorded separately, U12-S waves-name identity; verdict `(class,target,name,w,h,unit,matrix,viewport)`. `cameraModel` is **not** a reflection matrix.
5. **Phase 4 (steps 18–20, ★ U3):** binder rows `7e.10–7f.1`, height gate `C+0xe0 != 0 && [C+0xe0+8] != 0` (closed gate ⇒ void frame); record `(W,H,Min,Max)`, chain pointers, GL identity/provenance, one texel block; no `heightmapwaves0.tga`/1×1 neutral substitution.
6. **Phase 5 (steps 21–23, ★ U6):** virtual `+0x98` from `FUN_00826b30`; dump `MultiTexCoord0`, indices/first-count, `CULL_FACE`/`FRONT_FACE`, same-frame `hmapW/H`; `max‖attr/(W,H)−0.5 − VS_TexCoord1.xy‖ == 0.0` bit-exact f32.
7. **Phase 6 (step 24, ★ U5):** `glUniform1f(time)` over ≥3 frames/≥2 s; writer watchpoint on `C+0xc8` or constant-0 with silent watchpoint over 10 s; formula `float(dbl[+0xc8]*dbl[+0xc4])` 0 ULP, `C+0xc4=1.0`.
8. **Close:** export one tracer frame + breakpoint log + all dumps tagged PATH/camera/map; apply §6 port changes **only** on zero mismatch.

**Can settle:** P0-1, P0-1b, P0-2 (each sub-item only on its own tuple's zero mismatch). **Does not settle:** parity; any other P0. **Stays open:** all water hard-fails/UNSET/labelled substitutes until their verdicts; no water renders until a real reflection bind lands; other maps need their own U3 row.

### S2 — FOW: P0-3 (`fow_owner_protocol.md`)

1. **P0 (steps 1–4, ★):** launch at seed `20261113` with pinned fixture (record which), gameplay rig 58/−32°/400, `DynFogDepth=False`; assert §3.2 Class-N exclusions; set FOW on via shipped gate path; call each readable `Get*` knob once — **no `Set*` in P1–P5**; any pin mismatch/Class-N/missing knob log ⇒ void run.
2. **P1 (steps 5–7, ★ E-GRID-a):** one peasant, vision 0/3/8 and reveal radius 10/20/30, `FOWBuildFull` + settled tick, two perpendicular 1.0-unit transects through viewer spanning ±(res+8), plus one 0.25-unit fine transect; all six radii fit one linear scale `k` with 0 off-step cells.
3. **P2 (steps 8–11, ★ E-GRID-b):** two-viewer overlap transect + bisector; three-viewer removal sequence; ally vs enemy split. The raised `SetFOWFillMaxNum` arm is the **only** permitted knob write and only inside this arm.
4. **P3 (steps 12–14, ★ E-GRID-c):** no-interposition control + hill / forest / wall interpositions on the fixture actually present; map shadow edge and confirm the fitted blocker rule on a **second, rotated transect**; no slope/blocker list/FOWElevation effect without it.
5. **P4 (steps 15–17, ★ persistence):** walk-away, player-switch round-trip, balloon/victory gate, viewer kill, **save+reload (lane A only, N9 caveat)**, ally/enemy probe; full matrix ×2 repeats with 0 flapping cells; confirm capture/transfer issues no FOW invalidation.
6. **P5 (steps 18–20, ★ E-GRID-e):** 0.25-unit fine transect, raw `Integer` returns, stability/tile-border/count tests; domain enumerated with 0 out-of-domain values ×3 repeats; `>0` remains the port predicate until then.
7. **P6 (steps 21–24, ★ F1-MINI-TINT):** mark never-seen / seen-now / explored-not-visible cells; capture 240² panel + paired `GetFOWLOSData` per cell; both DPI arms; ×3 seeds where mandated, never pooled; resource `1.0/0.5/hidden` paired control; three pixel sets pairwise disjoint with 0 misclassified samples before any RGBA/threshold enters the port.
8. **Close:** export dump log + transects + knob log + panels tagged `run_id`/seed/config SHA/fixture/camera.

**Can settle:** P0-3 (F-GRID a–e, persistence, tint, knob defaults) only on zero mismatch. **Does not settle:** parity; lane B admissibility (needs D0 preflight + a real donor frame). **Stays open:** all port provisional labels (`1 res = 1 m`, `fog_counts > 0`, sticky `fog_explored`); no `FOWColor`/`FOWSmooth`/etc. as grid law.

### S3 — Blend: P0-5 (`blend_owner_protocol.md`)

1. **Controls (§1):** seed `20261113` literal, one temp config copy with byte-identical `config_sha256_file`, 3/3 trials per setting/sid, fixed camera per battery, paused-then-stepped 30 Hz; Class-N paths (N3 fisher, N4 audio, N5 watchdog, N6 frame-paced, N7 yields, N8 fallback, N9 save/load) void a trial; do not request donor-dead `walk1`.
2. **Schema (§2):** emit every listed per-tick column for every trial; `displayed_frame_index` is an engine read, `requested_frame_clock` the sim clock; no row smoothed/averaged/dropped; `null` = missing dump, not zero.
3. **§3 control arm:** exercise the seven `(0,0)` bypass sites V1–V7; under every one, `displayed_frame_index == requested_frame_clock` with no snap/window; death `Switch(6,8)→Reset` is carved out as **not** a bypass.
4. **R-B1 (§4):** peaukr walk→idle seam, 1 tick/frame, `(6,8)` vs forced `(0,0)`, ticks `[-2,+10]`; support = step-response length; a `w(t)` curve is named only on 0 residual across all ticks and 3/3 trials, else `w(t)` UNNAMED; sim-inclusive vs movie-exclusive window law captured, never assumed.
5. **R-B2 (§5):** `GetGameObjectFrameAnimationName/Data(sf,ef)` + displayed-index sequence byte-identical 3/3; co-occurring donor frames, not the port's 6-frame decimated subset.
6. **R-B3 (§6):** sim `a3=False` vs aix-idle `a3=True`; identical-or-different verdict + tick table 3/3; **no semantic name** assigned to `a3/a5/a6` either way; the new 8-arg prototype narrows this to FB semantic only.
7. **R-B4 (§7):** movie `bBlend` true/false, `maxblend=5` vs `0`; `"0,5"` is added to the port **only** on a zero-mismatch applicability result.
8. **R-C1 (§8):** musketeer attack1→idle1 and peasant death; hold-at-last vs snap-to-idle vs freeze verdict **with tick numbers** and last-3-tick hash, 0 mismatch 3/3 per sid; no `EndCyclesReached` handler invented.
9. **R-C2 (§9):** cannon firing; PFX/damage/sound ticks relative to `Attack`/`AttackEnd` handler firing ticks, 3/3; the recovered `_unit_TryAttack` + `SwitchTo('Nothing')` re-attack body is kept.
10. **Supporting (§1.2):** R-W/W2, R-S/R-A/R-R batteries; then §10 gate (every item identical frame-for-frame and hash-for-hash across 3/3) before any §11 port change.

**Can settle:** P0-5 B1–B4/C1/C2 plus W/S/A/R tails, item-by-item. **Does not settle:** parity. **Stays open:** zero interpolation / one nearest frame / clamp-at-last / empty hook until their rows terminate; `[U]-P1` native player tail and `FB` semantic remain open even on partial green.

### S4 — Selection/projection: P0-8 (`selection_owner_protocol.md`)

1. **§1 rig:** flat area, owner-recorded fixed seed, camera 58/−32°/focal 400 with `Min/MaxFocalLength=400`, FOW off except veto probes, fixed viewport, ≥5 owner-surveyed markers; log cPos/mPos/ray order/prio/score/handle/membership per probe; port approximation tags stay untouched.
2. **§2 V2-PROJ + V1-SENSOR first:** break `sub_4cd334` entry/exit (mode byte `*(p1+200)`, `(w,h)`, `focalArg`, struct floats, chosen of 5 GL paths), `GetCameraFieldOfView`/`ByFocalLength` @`0x5fece6`/`0x5fecfa`, whole-frame GL sequence from `sub_5d1c60`; re-project ≥5 surveyed points to **0 px**, clip battery (far `DepthOfView=1200` bracketed either side; near bracketed to eye), ≥3 aspect ratios.
3. **§3 V2-PROJ-DRAG (after §2):** LMB press + 1–3 px steps across epsilon in four directions; onset frame + frozen corner must match press-point or first-move-point at 0 px/0.0 m; world mapping from §2 is a prerequisite.
4. **§4 V2-BOX:** idle-peasant grid, inset/outset rects by 1–3 px, both drag directions, four corners, 1-px edges; fitted inside rule predicts all memberships with zero mismatches.
5. **§5 E-U13:** own peasant / wood / unbuilt building / enemy overlapping within 1–2 px; log `(1+dist)/prio` with donor XZ metres, exact tie (1e-6, first-in-ray wins), seed-`0.5` probe (or documented unconstructible), 1-px nudge, FOW-on veto probe returns 0; zero mismatches.
6. **§6 AABB:** break `GetGameObjectRayCastAABBByHandle` and `OctreeRayCast` pair, sweep 1-px across the ray at two depths per handle class; one fitted inside-test with zero mismatches and zero residual sort inversions.
7. **§7 V2-MINI-SCALE/-QUAD (needs §2):** ≥6 markers across both axes, affine fit `u=sx·x+ox`, `v=sz·z+oz`, both DPI arms and a non-square map; 4 camera poses with panel captures, incl. map-edge clip; ≥5 corners to 0 px and all 4 stroked edges to 0 px (×8 audit).
8. **§8 T1–T10 gate** before any §9 C-1…C-6 port change; C-7 explicitly forbids save/tick/ai/fow/water edits from this packet.

**Can settle:** P0-8 T1–T10, item-by-item. **Does not settle:** parity. **Stays open:** `FOV 17.27°`, near/far, sensor widths, drag anchor, marquee rule, minimap affine/quad until their rows; fog tint ladder is outside P0-8.

### S5 — Save: P0-6 (`save_owner_protocol.md`)

1. **§1 pins:** donor pin re-hash, seed `20261113`, one canonical known-state scenario (one unit/squad/roster, all else frozen); shipped map is a read-only wrapper oracle; fresh-save word `5C 00 00 00` is a `[D]` prediction; six load-jitter fields excluded from every comparison.
2. **§5 control first (E-T0):** an identical-state re-save pair must be byte-identical except the six jitter fields — **otherwise the harness is broken and no case is admissible**.
3. **§2 cases (A vs B differ in exactly one field + re-save control, 3 repeats each):** E-R1b float (4 B LE `00 00 80 3F`/`00 00 00 40`) and Boolean (1 B `00`→`01`); E-R1c codepage prefix; E-T2 TObj 866 B offsets; E-R1d transform placement outside `TObj`; E-R1e `victorystate` `0/1/2`; E-T1 `orders[].trg` = uid not handle; E-R1a envelope, E-R1g trailer/checksum, E-T3/T4/T5 projectile/`prevstouid`/TProj companions.
4. **§3 procedure:** copy `.map`s to owner temp dir outside repo, record size + SHA-256, hexdump first 256 B, locate field by predicted offset (search prediction, not observed address), byte-diff only that field, report divergent dump verbatim with offsets/neighbours; one unpredicted divergence ⇒ FAIL.
5. **§4 profile-store capture points:** save-path write, `UserSaveProfile`/`UserSaveProfileExt`, `StateMachineGlobalVariables*`, `GetAppSaveDirectoryPath` suffix, `custommap` Start-only snapshot; byte format and flush timing are `[U]` learned from snapshots.
6. **§6:** additive keys only, no v5 key removed/renamed/reordered, **no version bump**, no byte patterns emitted from JSON; contract stays "PORT EXTENSION, no byte-parity claim".

**Can settle:** P0-6 byte questions, case-by-case. **Does not settle:** parity; no donor `.sav` exists (`.sav` is a non-question). **Stays open:** build-92 envelope bytes, transform placement, trailer/checksum until their own cases terminate; network untouched.

### S6 — Tick: P0-4 (`tick_owner_protocol.md`)

1. **§2.1 admissibility:** fixed-step contract (§3.4), `N=3600` ticks = 112.5 s; 12 roster slots incl. slot 11 mercenary; 3 literal seed key pairs × process restart = 6 runs per candidate; idle / full skirmish / forced-veto load profiles; manifest immutable; N3 neutralised; Class-N "none active".
2. **§2.2 step 2:** reset all §1.2 init phases (`progresstick:=id*2`, four absolute deadlines, entity `floor(RandomExt*32)`); assert each slot before tick 0.
3. **§2.2 steps 3–5:** for `f=0…3599`, advance `time_s += 1/32` once, execute candidate stage-boundary permutation with internally-`[O]` blocks frozen, emit §3 schema and `H_f`; at player slice emit candidate rotation and R1/R2/R3 gates; count S and G draws per site (§3.5) — a wrong stream/count fails the candidate.
4. **§4 candidates:** U-O1a (i)/(ii)/(iii) rotation; U-O1c block-boundary interleave; U-O1b rate; U-O5 veto reachability; companion U-O1d/O2/O3/O4/O6/O7 and U-A6r/A7 (600 s / 19200-tick batteries are separate, never conflated with the 3600-frame matrix).
5. **§2.2 steps 6–7 + §5:** compare `H_0…H_3599` byte-for-byte across all 6 sequences and load profiles; **single survivor only**, losers deleted/listed; any single-tick divergence, missing dump, wrong-stream draw or closed gate ⇒ no order adopted.
6. **§6:** adopt only the surviving rotation/rate/permutation and re-tag `TICK_ORDER v1`; U-O7 unobservable ⇒ `[U]-O1 PERMANENTLY NATIVE` and **no port change**.

**Can settle:** P0-4 rotation/rate/interleave/cadence items, only on single-survivor zero mismatch. **Does not settle:** parity — this is port-internal self-consistency against donor-text-pinned algebra; no donor binary is involved. **Stays open:** `TICK_ORDER v1 PORT APPROXIMATION`, index-order slice, AI body internals `[U]-A1`, mixed 2.4 s gate / 1.0 s interval snapshot.

### S7 — RNG: P0-7 (`rng_owner_protocol.md`)

1. **§2.1 setup:** fixed-step contract, literal seed `20261113`, config SHA-256, Class-N "none active"; the `(0x44A108F9, 0x00000001)` oracle is injected **only** into the deterministic model / L20-S6 boot assert, never into `Data.RANDOM_SEED`.
2. **§2.2 steps 1–4:** pin manifest fields; reset S to fixture pair for oracle context and to `20261113` for harness context, record G start state; advance fixed dt and emit one §3 log line per site per draw into the stage-keyed ledger; cross-check every S draw against X21 and every G draw **count-only** — wrong stream/count/extra draw ⇒ FAIL.
3. **§3.5 L2 (owner debugger only, pinned build, no GPU frame):** break `0x60f64c` (S state before/after + f32 return), `0x403a0c` (G state + byte), `0x8f2008` (process-start seed + stage boundaries), `0x8f206c` (2^-32 divisor); terminate when S values match the model with 0 mismatches, G advances once per draw, and restart changes `0x8f2008` while S reseeds stay identity.
4. **§4 full series:** R20 (Bankers `donor_round`, 23-value set + 14 PUSSTRELA rows), L20 (20-vector S sequence `3C6FEF6C…A2C21855`, G count-only), C300 (300 shots), U50 (50 spawns + 50 shots, scatter-before-frnd), F1M (f32/f64 sweep), K0 (four `key0` values), A600 (1 AI vs 1 idle human, 600 s); canonical `test_vectors.json` + f32 round-trip is the oracle — the row-7 `bits LE` Markdown discrepancy is disclosed, not guessed.
5. **§5 checks:** same-seed restart, process restart (G seed must change), same-process regeneration (no per-map G reseed), `key0`-only and `key1`±1 seed changes, reseed identity, restart-after-save/load seed assertion.
6. **§6/§7:** only if **all** series and checks are 0-mismatch flip the specific G1 sub-item to `[D]+harness-id`, wire the listed sites → G (`delphi_rng`) vs → S (`sim_rng`), keep additive save keys only; never retune a threshold or invent a draw.

**Can settle:** P0-7 G1 sub-items, only on full-series zero mismatch. **Does not settle:** parity — internal, donor-text-pinned consistency only; L2 is a **native state dump, not a donor GPU A/B frame**. **Stays open:** G **values** (count-only forever), native `@Round` address, signed-`key0` donor behaviour, spawn/version-gated counts, f32 promotion beyond tested range, generation-owned `GenerateMapRandKey`/saved-map key bytes, live-replay equivalence.

## 6. What remains for later sessions (after all seven terminate cleanly)

1. **All seven sessions green still leaves parity UNVERIFIED.** Each retires only its named `[U]` to `[D]+capture-id/harness-id`. No session produces a matched donor GPU A/B frame, a COORD ruling, or `blocking_unverified = []`.
2. **Route A is a separate owner action and settles zero P0 (§0).** It can supply chain condition 1 only; conditions 4/5/6 remain BLOCKED/PARTIAL until fresh gates, READY spec/toolchain, `blocking_unverified = []` and a COORD-signed geometry+pixel ruling (`decision_sim §3`).
3. **Later sessions still required:** (a) owner Route A paired donor capture + written manifest (`X39 §3`); (b) COORD candidate capture + G0-a…e admissibility and identical ground-only ROI; (c) fresh COORD-ruled gate battery incl. 575/582/585 owner acknowledgement with evidence-backed reasons, D1/D3 rulings, `app/**` byte-identity; (d) spec/toolchain closure: §§01–14 READY, X15 root `manifest.json`, I05 atlas + I03 feed bound, N17 populated/signed; (e) COORD final ruling of condition 6 (demonstrated byte-identical geometry + pixel-identical matched frame).
4. **Non-P0 tails remain outside these seven packets:** `PT-V1…PT-V7`, `W-R1`, `T-SEED`, `T-CALLBACK`, `atlas-layout`, `X17`, `U-INJ-1…11` and the other domain residuals listed in `owner_brief_addendum §4`; none is promoted by a packet battery.
5. **Failure ⇒ later repeat of the same session, not a fix-by-substitute.** Any mismatch, missing dump, void session, Class-N path, wrong PATH/seed/fixture/camera or closed gate keeps the item `[U]`; the same packet must be re-run at its exact setup. No threshold retune, retry-until-green, port fallback, metric, still, replay pair or "close" value is admissible.
6. **Per-item tails stay open even on a packet-level green:** other maps' water U3 rows; blend `FB` semantic / `P1` native player; tick 600 s companion batteries and `[U]-O1 PERMANENTLY NATIVE` if unobservable; save build-92/trailer cases not yet terminated; RNG generation-owned and signed-`key0` items; selection's fog-tint ladder (outside P0-8).

## 7. Status and verdict (verbatim form)

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

`RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all tier-2 conditions hold — not after these sessions alone. Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", or "gate PASS" derived from a capture.

## 8. Claim register and file discipline

| # | Claim | Label |
|---|---|---|
| 1 | Minimum is seven dedicated owner blocks — one per packet; no merge is legal because scene/camera/F-state/dump/repeat constraints conflict. | [D] `decision_sim:93`; packet §§0/3 |
| 2 | Zero P0 settled by the existing terrain Route A capture; Route A is terrain + manifest, necessary but not sufficient. | [D] `decision_sim:81`, `X39:34/178` |
| 3 | Donor execution is owner-only; no worker runs/copies the donor, captures a frame, runs Godot/gate/harness or promotes a `[U]`. | [D] `CHARTER:66-72`; all seven packets §0 |
| 4 | Parity remains UNVERIFIED until a matched donor GPU A/B frame **and** an explicit COORD ruling; six-condition chain 0/6. | [D] `decision_sim §0/§3`, `parity_recheck` |
| 5 | Shared pin `87f0f3c130b0…`, literal seed `20261113`, camera 58/−32°/400 and fixed-step config/manifest are prepared once but do not authorise merging sessions. | [D] §3; packet setup sections |
| 6 | New pins (8-arg prototype, tick CODE cluster, 30-key tables, hmap f32 clamp, U12 copy thunk, FOW negatives, save heads, selection API) narrow but never remove a zero-mismatch requirement. | [D] §4; deep-pass reports |
| 7 | No approximation is adopted, no port value wired, no parity claimed; exactly one repository file written, no code/Godot/git/donor execution by this worker. | [O] scope guard |

*End of PORT1TO1-P0-SESSION-PLAN. Read-only; exactly one repository file written; no code/Godot/git/donor execution; no approximations; no parity claim. Seven owner blocks specified, zero performed; zero P0 settled by the existing Route A capture; parity UNVERIFIED until matched A/B + COORD ruling; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
