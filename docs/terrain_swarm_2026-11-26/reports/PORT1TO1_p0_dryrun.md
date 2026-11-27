---
id: PORT1TO1-P0-DRYRUN-2026-11-26
title: "P0 dry-run classification — which parts of each P0 experiment are portable-internally checkable right now (full 1:1 Cossacks 3 donor port)"
worker: P0-DRYRUN (read-only subagent)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_dryrun.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_dryrun.md]
files_edited: []
scope_guard: "Repo/doc/source read-only inspection only. No source, shader, config, asset, test, fixture, result JSON, queue, gate, capture, MP4, ROI metric, MCP probe, Godot process, git state or donor binary was created, modified or executed. No command quoted below was run by this worker; the exact checks are transcribed/cited from landed reports and from direct read-only file inspection. Exactly one repository file written: this report."
labels: [CLASSIFICATION, PORT_INTERNAL_ONLY, OWNER_ONLY_EXPERIMENTS, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM]
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_internal_validation.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — nine P0 rows remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no port-internal check closes any P0; no approximations; no parity claim."
reviewer_line: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 — P0 dry-run classification (2026-11-26)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

This is a **read-only classification**, not a verification run. The eight numbered items below are the eight experiments named in the task brief; they map onto the nine open P0 rows (`PORT1TO1_u_register_update.md §1`; `PORT1TO1_internal_validation.md §0`: P0-1 Water U12, P0-1b U4*, P0-2 U1/U3/U5/U6, P0-3 FOW grid, P0-4 tick interleave, P0-5 blend, P0-6 save container, P0-7 RNG G1, P0-8 selection/projection). The capture item (§8) is the fixed-seed `CS-*` tail that the skirmish owner packets carry across those rows.

**Governing rule, repeated because it is load-bearing:** every row has a *port-internal* part (a law/gate/telemetry string, a fixture table, a self-check function, or a labelled hard-fail) that is readable **now**, and a *donor-zero-mismatch* part that is **owner-only** and has not been executed. A port-internal check may confirm **internal consistency only**. **No P0 may be marked closed by any check in this report.** Parity stays `UNVERIFIED`; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation is adopted and no parity is claimed anywhere below.

---

## 0. Classification legend

| Class | Meaning | What it licenses |
|---|---|---|
| **A — structural/telemetry** | The port's law, constant, gate, mirror or fixture is literally present in source or in a landed report/artifact; confirmable by read-only inspection *today*. | Confirm only that the port says/encodes what it claims it says. **Never** donor fidelity. |
| **B — replayable-port-internal (NOT executed here)** | A pure self-check or fixed-seed replay path exists in code/artifacts; a *permitted* worker/owner could run it under the single Godot door. This worker ran nothing, so its runtime result is **not** asserted. | At most port-vs-port repeatability (cf. `PORT1TO1_internal_validation.md §2.6`, condition 6 = PARTIAL, chain 0/6). Never a donor A/B. |
| **C — donor-runtime required** | The numeric/order/provenance result can only come from an owner-authorised donor GPU/paired-save/debugger session. No port check substitutes for it. | Nothing until its own 3-run/zero-mismatch packet terminates. |

Every item below is **A (structure) + B (replay path exists, not run) + C (termination owner-only)** in varying proportions. The "does NOT prove" line is the same discipline applied per item: it names the gap that keeps the row `[U]`.

---

## 1. RNG X21 20-vector replay against port `sim_rng` / fixture — P0-7 (G1 stream split)

**Classification:** A (fixture + LCG constants readable now) + B (pure self-check exists, not run) + C (live-path S/G attribution requires the L20/S6 series and donor state dumps).

**Exact read-only check available now:**
- `variant3d/scripts/game.gd:205-237` — `class DonorRandomExt`: `DONOR_LCG_M := 64525` (`0xFC0D`, `:206`), `DONOR_LCG_C := 1013904223` (`0x3C6EF35F`, `:207`), `random_f32()` (`:229`) and `get_random(n) = int(floorf(random_f32()*n))` (`:236-237`). `key0` is declared discarded at `:221`. `:239` declares `var sim_rng := DonorRandomExt.new()` as the single sim S stream; `:378/:601` seed it from `Data.RANDOM_SEED`.
- `game.gd:9714-9736` — `donor_rng_x21_fixture()` is the verbatim 20-row `[s_hex, f32, bits_LE, floor3, floor5, floor10, floor256]` table for the synthetic pair `(key0=0x44A108F9, key1=0x00000001)`; `:9716..:9735` cover `0x3C6FEF6C … 0xA2C21855`.
- `game.gd:9739-9789` — `donor_rng_x21_selfcheck()` is a **pure/static** check (`"static_only": true` at `:9788`): it walks all 20 vectors comparing `get_state()` and f32 (`:9745-9751`), asserts `key0` discard over 20 draws (`:9752-9758`), checks `s=0` no-stick (`:9759-9763`) and records swapped/key0-only states (`:9764-9771`). `:9782-9787` explicitly records the `[U]-RPT` **bits_LE digit transpositions at rows 7 and 12** — fixture kept ledger-verbatim, recompute labelled, no value invented.
- `game.gd:9391-9394/:9518-9521` — `rng_state/gen_rng_state/sim_rng_state` additive save keys; `:9796` self-describes `sim_rng` as `"single donor RandomExt stream (no split claimed)"`.
- Source reports: `docs/terrain_swarm_2026-11-26/reports/X21_rng_vectors.md §§2/4-5`, `DEC_U_rng_ledger.md §§2/4/6`, `PORT1TO1_rng_owner_protocol.md §§3-5` (L20 oracle `3C6FEF6C…A2C21855`; K0/F1M arms; wrong-stream/count FAIL rule at `:111/:206`).

**What this does NOT prove:** The self-check proves only that the *port's own* LCG reproduces the *port's own* transcribed table; the table's `bits_LE` column is admittedly corrupted at rows 7/12 and the oracle provenance is a synthetic pair, never a donor seed (`rng_owner_protocol:59-60/:182`). It does not prove live-path stream attribution — all G-attributed sites (`_misc_random_int` `:5919-5920`, headshot `:7581`, AI die rolls `:7542/:8676`, easy-gate `:8622`, capture jitter `:8547`) still draw from `sim_rng` and remain `[U]-G1`; it does not prove the S/G split, G values (count-only), Bankers rounding at the native `@Round`, or any donor draw order. No L20 zero-mismatch capture exists; P0-7 stays open. Parity `UNVERIFIED`.

---

## 2. Save additive v5 round-trip for TObj / Boolean / float mirrors — P0-6

**Classification:** A (v5 wire + additive mirrors + telemetry readable now) + B (JSON round-trip path exists, not run) + C (paired-save byte/hexdump is owner-only).

**Exact read-only check available now:**
- `game.gd:9130-9299` — the `serialized:` contract commentary: 19-section order `[O]`, `TObj` declaration order at `:9177-9194` (`bdead,bbuilt,bstandground,bsearchenemy:L, insideofuid …`), `TProj` 15-field order at `:9287/:9635`, and the explicit `[U]-R1d` note that engine transform is **not** in `TObj` (`:9194`).
- `game.gd:9313-9349` — additive `orders12` (12-slot `TOrderInfo`, default-zero, never truncated) and `uniqrnd` mirrors; `:9391-9410` top-level additive keys `rng_state/gen_rng_state/sim_rng_state/save_donor_version=92`; no version bump. `:9512-9543` deserialize restores keys with seed fallbacks; `:9580-9697` `_save_contract_telemetry()` carries `"PORT EXTENSION, no byte-parity claim"` metadata and the 63-field/866 B `TObj` span note (`:9664`).
- Report artifacts: `PORT1TO1_save_owner_protocol.md §§2/5/6` (float `00 00 80 3F`/`00 00 00 40` at TObj offsets 57/61; Boolean 1 B `00→01` at `fStandGround`; 866 B span with `hp`@20, `uniqrnd`@148; additive-only change rule at `:160-175`), `DEC_U_save_tobj.md`, `DEC_U_save_bits.md`, `DEC_U_save_float.md`, `DEC_U_save_deep.md`, `DEC_U_save_contract.md`.

**What this does NOT prove:** A JSON key round-trip is **not** a byte-level donor save. The v5 wire is JSON with UTF-8 strings, not a compiled `.map`; no donor paired save, no first-256-B hexdump, no codepage prefix, no float-width/Boolean-byte divergence at a predicted offset, and no transform placement have been observed by this worker (`save_owner_protocol:49/:154`). Every encoding fact is a `[D]`/`[O]` prediction used to *shape* the owner experiment; E-T0 control byte-identity and the three-repeat criterion are unrun. P0-6 stays open; parity `UNVERIFIED`.

---

## 3. Blend nearest-frame / `0,0` bypass telemetry behaviour — P0-5

**Classification:** A (telemetry + bypass labels readable now) + B (pose path is port-internal, not run) + C (donor 30 Hz per-tick frame/hash traces are owner-only).

**Exact read-only check available now:**
- Direct read-only grep of `anim3d.gd` for `lerp|mix|slerp` returned **no occurrences** — confirming the port has zero interpolation on the pose path. `anim3d.gd:137 FRAME_BLEND_STATUS` = `PORT-LEVEL NEAREST-FRAME POLICY [U] U2`; `:160-161` `DONOR_BLEND_NONE="0,0"` / `DONOR_BLEND_MINMAX="6,8"`; `:166 DONOR_BLEND_BYPASS_SITES` enumerates V1–V7 with the `displayed==requested` invariant under `0,0`.
- `anim3d.gd:428 play()` / `:847 pose_for()` compute `sample_frame` **before** `:454/:870 _frame_blend_fields()` returns telemetry; `:1020-1038` sets `blend_bypass_violation` (`:1036`), `fetch_policy:"nearest_single_no_blend [U]-B2"` (`:1038`); `:1522-1527 _nearest_exported_frame()` fetches exactly one frame from the 6-frame subset; `:1794-1804 aaf_completion_probe()` reports `"clamp-at-last [U]-C1, no EndCyclesReached handler armed"` (`:1802`).
- Report artifacts: `PORT1TO1_blend_owner_protocol.md §3` (seven `0,0` sites V1–V7 with file:line; death `Switch(6,8)→Reset` carved out as not-a-bypass), `DEC_U_blend_op.md`, `DEC_U_blend_deep.md` (8-arg prototype + ACL tables `[O]`; B1/B2/FB/P1 `[U]`), `DEC_U_state_map.md`, `DEC_U_aaf_triggers.md`.
- `t_anim_metrics.gd` is present as a landed metrics harness (not executed by this worker).

**What this does NOT prove:** Telemetry presence is not behaviour. There is no donor `w(t)`, no co-occurring donor frame pair, no handler firing tick, no `a3/a5/a6` polarity and no `0,5` movie-applicability verdict — all are `[U]` in `blend_owner_protocol §11/:160-167`. The port's nearest-single fetch, ascending tie-lower, 6-frame decimation and clamp-at-last are **labelled PORT choices**, not donor facts. A `blend_bypass_violation=false` would only confirm the port's own label; the `0,0` == single-tick hard-cut invariant must be shown frame-for-frame/hash-for-hash across 3/3 donor trials (`§10/:140/:151`). P0-5 stays open; parity `UNVERIFIED`.

---

## 4. FOW vision law `20+4V` and reveal plumbing — P0-3 (F-GRID a–e, persistence, tint)

**Classification:** A (scalar law + reveal lifecycle + grid labels readable now) + B (port grid mirror replayable, not run) + C (fixed-seed donor `GetFOWLOSData` transects / tint panels are owner-only).

**Exact read-only check available now:**
- `variant3d/scripts/world3d_fog.gd:625-626` `DONOR_VISION_BASE=20.0`, `DONOR_VISION_PER_POINT=4.0`; `:1198-1218 donor_unit_vision()` implements `floor(20 + 4*vision)` (`:1218`) with the fogreveal `dx` branch (`:1205-1208`) and dead/unbuilt/not-visible → 0 (`:1209-1210`); the comment at `:1201` records `vision 0/1/3/8 → 20/24/32/52`.
- `:1235-1242 get_fog_reveal()` mirrors the donor px/pz epsilon scan; `:914-957` is the viewer-disc → `fog_counts` → `fog_explored` commit chain; `:1221-1232 _vision_radius_m()` returns `float(res)` with `1 res = 1 port metre` explicitly labelled **provisional** `[U] F1-GRID`; `:1280/:1297` carry `GetFOWLOSData` and the `>0` veto.
- Report artifacts: `PORT1TO1_fow_owner_protocol.md §1` (`[O]` `_unit_GetVision` `unit.script:11563-11614`; `_misc_GetOrCreateFogReveal/Remove` `misc.script:5883-5944`; `map_revealZone` `scenario.script:1851-1864`; veto `control.script:270-273`), `DEC_U_fow_numeric_deep.md` (zero FOW numeric assignments; anchors are string-table DATA), `DEC_U_fow_grid_deep.md`, `DEC_U_vision_audit.md`, `DEC_U_fow_persist.md`, `DEC_U_fow_knobs.md`.

**What this does NOT prove:** `20+4V` is recovered **donor text** `[O]`; the port mirroring it proves only internal consistency. Everything that makes it a *FOW* rule is still `[U]`: cell size/`res` world units (F-GRID-a), combine operator, blocker/occlusion rule, `GetFOWLOSData` domain beyond the grounded `>0`, explored persistence across save/reload, and minimap tint RGBA (`fow_owner_protocol:223-261`). `fog_explored`/`fog_counts` are port inventions (`world3d_fog.gd:632-634/:102`) and `_vision_radius_m` is a labelled port driver — no cell size, combine, colour or blocker is asserted. No donor transect shows `20+4V` producing the port's discovered cells; P0-3 stays open; parity `UNVERIFIED`.

---

## 5. Tick absolute-deadline / cadence gates — P0-4

**Classification:** A (R1/R2/R3 gate + init phases + cadence constants readable now) + B (fixed-dt harness exists as design, not run) + C (12-player/3600-frame/3-seed winner selection is owner-only).

**Exact read-only check available now:**
- `game.gd:6016-6035 _check_progress_lasttime_and_increase()` — comment defines R1 (`lasttime := gametime+addtime`, no catch-up), R2 (exact-float cross-player veto `checktime - addtime == time_s`, `:6033`), R3 (only caller's deadline written, `:6035`); called for itype 0 at `:6075`, itype 1 at `:6081-6082`; `progresstick+=1` at `:6087`, unconditional `lastprogresstime=time_s` at `:6088`.
- `game.gd:477-478` consts `_TICK_CALCSQUADS_S=0.3`, `_TICK_AI_S=2.4`; `:514-519` init phases `lastprogresstime=0`, `progresstick=index*2`, `lastcalcsquadsmovecounttime=id*0.25+0.3`, `lastprogressaitime=id*0.25+2.4`.
- Source reports: `DEC_U_tick_order.md §§1-3` (stage order, R1/R2/R3 primitives, four itypes, `mod 2/53/3/31/7` cohorts), `DEC_U_tick_driver.md`, `DEC_U_tick_deep.md` (player-handle API CODE cluster localized; no dispatch loop/order), `PORT1TO1_tick_owner_protocol.md §§1.2/3.3/5` (absolute-deadline write assertion, veto-skip with no deadline write, stale `ai.gd:1324` "1.0 vs 2.4" comment, `data.gd:407 AI_THINK_INTERVAL=1.0`).

**What this does NOT prove:** The gate *form* is donor text `[O]`; whether the port actually fires in donor order is untested. `plInd` rotation, stage-boundary interleave, firing rate, AI `2.4 + 0.25·id` cadence and R2 veto reachability are `[U]` with one-survivor/6-sequence termination (`tick_owner_protocol:168/:172-182`). The harness records what executes and does **not** trust comments; the mixed `2.4 s` gate / `1.0 s` interval snapshot is disclosed, not settled. No 3600-frame ×12-player ×3-seed hash set exists, so no order is adopted and `TICK_ORDER v1` stays frozen; P0-4 stays open; parity `UNVERIFIED`.

---

## 6. Water hard-fail / UNSET gating — P0-1 / 1b / 2 (U12, U4*, U1/U3/U5/U6)

**Classification:** A (hard-fail + UNSET gates readable now) + A (the absence of water in captures is a recorded port observation) + C (U12 provenance, U4* tuple, U1 path, U3 numbers/texture, U5 writer, U6 UV/winding all owner-only).

**Exact read-only check available now:**
- `water3d.gd:168 DEFAULT_WATER_SHADER_PATH = BUILTIN` (labelled `[D]`, not `[O]`); `:215-219 WATER_SCALAR_SOURCE_UNSET=-1` with "NO default — unset ⇒ push_error + no water" (`:215`); `:364-366` runtime state `_water_scalar_source = UNSET`, `_reflection_map = null`.
- `:446-463 set_water_scalar_source()` and `:462-463` returns `"UNSET[U4*]"` while unset; `:501-510 bind_reflection_map()` refuses null (`:503`); `:601/:678-685 _finalize_water_node()` pushes `"no grey fallback"` when BUILTIN is selected but `reflectionMap` unbound (`:680-682`); `:745-747` refuses the UNSET scalar source with `push_error` + no water. `:107-108` `BUILTIN_TEX_SCALE_S/T=0.01/0.02` are explicitly "EMBEDDED-SOURCE-DEFAULT, not a live uniform".
- As cited (not re-lifted by this worker) in `PORT1TO1_water_owner_protocol.md:31`: `world3d_terrain.gd:1089-1106 _make_water3d()` calls `build()`+`bind_height_grid()` but **never** `bind_reflection_map()`; `water3d.gdshader:126 reflectionMapBound=false`.
- Artifacts: `PORT1TO1_water_owner_protocol.md §§1-6` (pinned VAs/breakpoints, PATH gate, U12 a/b/c matrix, UNSET kept at `:185/:211-212`), `DEC_U12_deep.md`, `DEC_U_water_scalar_select.md`, `DEC_U_water_runtime.md`, `DEC_U_hmap_identity.md`, `DEC_U_water_capture.md`; recorded render observations `cap_fullport6/7/8.png` clean **except** the deliberate U12/U4* hard-fail (`PORT1TO1_internal_validation.md §2.3`, with the disk-presence discrepancy preserved verbatim at `:82`).

**What this does NOT prove:** A hard-fail is a **policy** for not inventing a reflection target, not a match to donor water. Nothing here supplies U12 texture provenance/size/unit/matrix, a U4* FILE/ENGINE tuple, the U1 path, U3 hmap numbers/texture, U5 writer or U6 UV/winding (`water_owner_protocol:211-219`). No water renders, so **zero water pixels are scored**. No donor GPU A/B frame, PATH tag, FBO dump or scalar layerPtr dump exists. "No grey fallback" proves the absence of a substitution, not donor fidelity; P0-1/1b/2 stay open; parity `UNVERIFIED`.

---

## 7. Selection prio / name-swap — P0-8 (and cross-cutting E-U13)

**Classification:** A (prio integers, score shape, seed `0.5`, name-swap law readable now) + A (no donor camera frame) + C (rig/projection/AABB/marquee/minimap captures are owner-only).

**Exact read-only check available now:**
- `input_controller.gd:45 DONOR_PICK_SEED=0.5`; `:829-876 donor_pick_priority()` returns the Float seed for nil/unknown arms (`:832/:849/:859`) and donor integers per arm; `:880-887` score `(1+dist)/prio` with `prio<=0` excluded. `picking3d.gd:61 TIE_PX=0.5` labelled screen-px epsilon; `:103-124 _donor_prio()/_donor_score()`; `:470-479` min-wins strict-`<`, first-eligible installs, and the **explicit PORT camera-depth tie-break** (`:473-475`).
- `hud.gd:343-344/:2087-2089` the donor name-swap law: visible → `building ? pl3x3.<color> : pl2x2.<color>` (+`.sel` when selected), invisible → release; on capture only `.<color>`/(`.sel`) may change, position/size class static. `:329-332` donor core/cell pixel counts as data, palette/rims/`.sel` RGB labelled `[U]` (`:310/:2098`).
- Report artifacts: `DEC_U_selection.md`, `DEC_U_camera_projection.md`, `DEC_U_minimap_tail.md`, `PORT1TO1_selection_owner_protocol.md §§5-8` (T1–T10 zero-mismatch gates), `DEC_U_select_deep` (active).

**What this does NOT prove:** Priority integers 1..7, the `0.5` seed arm, the `(1+dist)/prio` min-wins shape, strict-`<` first-in-ray, winner-only FOW veto and the minimap name-swap are donor **text** `[O]`; the port encoding them proves no numerical behaviour. `dist` units (screen px vs donor XZ metres), `SortRayCastList` order/key, engine AABB inside-test, drag anchor, marquee inside-test, minimap affine/quad and the whole sensor→FOV chain remain `[U]` (`selection_owner_protocol:31/:190`). Port `FOV 17.27°`, `NEAR_M=0.1/FAR_M=4096`, screen-UV bias and camera-depth tie-break are retained **PORT APPROXIMATION**; the name-swap's `.sel` RGB lives only inside `primitives.bmp` and is never decoded to donor fact. No matched camera, no ≥5 reprojected survey points, no donor pick log; P0-8 stays open; parity `UNVERIFIED`.

---

## 8. Capture first-tick boolean flip — cross-cutting `CS-PROGRESS` (skirmish rows)

**Classification:** A (boolean-instant law + cadence mirrors + withdrawn rate law readable now) + B (port capture block replayable, not run) + C (fixed-seed `lasttimecheckcapture`/`TObj.pl` transect is owner-only).

**Exact read-only check available now:**
- `game.gd:8241-8246` registers the `CS-PROGRESS` law and experiment verbatim: `"boolean-instant flip on first passing lasttimecheckcapture tick"`, cadence `1.875 s`/`0.475 s` art, `EV-CS-NOCAP` zero-hit (no capture-progress/cooldown field), and the 3-run zero-mismatch criterion with **no intermediate partial state**. `:8242` records single-protector veto (not majority) and no post-capture cooldown.
- `game.gd:8531-8555` preserves the cadence mirrors (`lasttimecheckcapture`, `cap_interval`, per-object `uniqrnd` jitter); `:8646-8688` is the actual gate: comment declares "FIRST passing tick flips ownership BOOLEAN-INSTANT; no accumulator", the port rate law is **"PORT APPROXIMATION, WITHDRAWN"** (`:8650-8652`), `bCapture=true` → `_donor_capture_flush` → `e.player = capturer` (`:8658/:8666/:8688`); `:8684/:8687` zero `capture_t`; `:8784-8789` the else arm has **no decay/cooldown** ("rate law WITHDRAWN; no capture_lock field invented"). `:3127` keeps `capture_t` as a dormant v5 key.
- Artifacts: `DEC_U_capture_state.md §§1/2/6` (EV-CS-CAD, EV-CS-NOCAP, CS-PROGRESS termination), `DEC_U_capture_state2.md`, `DEC_U_capture_flush.md`, `IMPL-CAPTURE-STATE-GAME`; `t_capture.gd` present as port logic harness (not run here).

**What this does NOT prove:** The boolean-instant law is recovered donor **text** `[O]` and the port block is written to match it — but no fixed-seed trace has observed `TObj.pl` flipping on a tick where `gametime > lasttimecheckcapture` with `lasttimecheckcapture` unchanged, and no 3-run identity exists (`DEC_U_capture_state.md:149`). The port's remaining ledger gaps (`CS-LEDGER`), mine-insider/STO handling, `captured_nations` G-07 roster projection, `_default_rally` re-arm and `cap_evt_t` chat throttle are explicitly labelled `[U]`/PORT RULE, not donor results. A structurally correct gate is not a captured behaviour; this row stays open; parity `UNVERIFIED`.

---

## 9. What every check above has in common

1. **Read-only scope.** Every file:line cited was inspected, not modified; no Godot process, gate, runner, donor binary, capture, git command or ROI metric was executed by this worker. The "exact check" columns describe *read-only inspections and existing artifacts*; they are not runtime results.
2. **The internal-consistency ceiling.** The best honest outcome from §§1–8 is: *port law/gate/telemetry present as labelled; no donor comparison; no P0 closure.* This is the same ceiling recorded in `PORT1TO1_internal_validation.md §4` — "gates green / internal consistency PASS / donor parity UNVERIFIED" — and even "gates green" is not claimed here.
3. **Six-condition chain stays 0/6** (`PORT1TO1_parity_recheck.md:40-63`; `PORT1TO1_parity_chain.md:93-108`). Condition 2 and 6 are PARTIAL (port-internal only); a PARTIAL is not a CLOSE.
4. **Never promote.** A structural match, a labelled substitute, a port replay pair, a "close" value or a metric never retires a `[U]`. Each item retires solely on its own owner-run zero-mismatch capture, and even then becomes `[D]` + capture-id — not a parity proof (`PORT1TO1_p0_packet_index.md:53-55`).

---

## 10. Verdict template (verbatim)

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — blocking_unverified is non-empty (no donor A/B frame; water U12/U4*;
FOW grid; tick interleave; animation blend; save container; RNG G1; selection/projection;
no COORD ruling).
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = [PT-V1, PT-V2, PT-V3, PT-V4, PT-V5, PT-V6, PT-V7,
                       P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8,
                       W-R1, T-SEED, T-CALLBACK, atlas-layout, X17, U-INJ-1..11,
                       plus the domain residuals]
```

`RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all tier-2 conditions hold — not today (`PORT1TO1_owner_brief.md:94`; `PORT1TO1_acceptance_runbook.md:345`).

---

## 11. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Eight item classifications are read-only; no code/Godot/git/donor executed; exactly one file written | [O] scope |
| 2 | RNG: LCG constants + 20-vector fixture + pure selfcheck readable; bits_LE rows 7/12 admitted `[U]-RPT`; S/G split open | [O] `game.gd:206-207/9714-9789`, `rng_owner_protocol:59-60/:182` |
| 3 | Save: v5 additive mirrors + telemetry readable; paired-save byte check unrun | [O] `game.gd:9177-9194/9313-9349/9580-9697`, `save_owner_protocol:49/:154` |
| 4 | Blend: zero `lerp`/`mix`/`slerp` (read-only grep), nearest-single + `0,0` bypass labels readable; donor curve unrecovered | [O]/[D] `anim3d.gd:137/:160-166/:1020-1038/:1794-1804`, `blend_owner_protocol §§3/11` |
| 5 | FOW: `20+4V` coefficients + reveal/grid labels readable; scale/combine/occlusion/tint `[U]` | [O]/[U] `world3d_fog.gd:625-626/:1198-1232`, `fow_owner_protocol:223-261` |
| 6 | Tick: R1/R2/R3 gate + cadence constants readable; rotation/interleave/rate `[U]` | [O]/[U] `game.gd:477-478/:514-519/:6027-6035/:6075-6088`, `tick_owner_protocol §§1.2/5` |
| 7 | Water: hard-fail + UNSET gates readable; no water drawn; U12/U4*/U1/U3/U5/U6 `[U]` | [O]/[U] `water3d.gd:168/:215-219/:501-510/:601/:678-685/:745-747`, `water_owner_protocol:211-219` |
| 8 | Selection: prio/score/seed + minimap name-swap readable; projection/AABB/drag `[U]`, FOV 17.27° PORT APPROX | [O]/[U] `input_controller.gd:45/:829-887`, `picking3d.gd:103-124/:470-479`, `hud.gd:343-344/:2087-2089` |
| 9 | Capture: boolean-instant law + withdrawn rate law readable; CS-PROGRESS trace unrun | [O]/[U] `game.gd:8241-8246/:8531-8555/:8646-8688/:8784-8789`, `DEC_U_capture_state.md:149` |
| 10 | No P0 closed by any check above; chain 0/6; parity `UNVERIFIED`; `RESULT IS NOT GOOD` | [D] `internal_validation:26-38`, `parity_recheck:40-63`, `owner_decisions:14/39` |

---

*End of PORT1TO1_p0_dryrun. Read-only classification; exactly one repository file written (this report). No source, shader, config, asset, test, fixture, result JSON, queue, git state, Godot process, runner job, gate, capture, MP4, ROI metric, MCP probe or donor binary was created, modified or executed by this worker. All commands/procedures/line anchors are quoted or directly read; none was run. No approximation adopted, no donor parity claimed, no camera match asserted, no P0 item closed. `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
