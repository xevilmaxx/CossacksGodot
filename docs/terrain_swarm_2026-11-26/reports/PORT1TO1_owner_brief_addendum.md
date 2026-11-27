---
id: PORT1TO1-OWNER-BRIEF-ADDENDUM-2026-11-27
title: "Addendum to the concise owner brief — effect of the post-brief deep passes and the RNG packet"
worker: BRIEF-ADDENDUM (read-only subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief_addendum.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief_addendum.md]
files_edited: []
scope_guard: "Repo file/line reads only. No source, shader, config, asset, test, manifest, queue, result JSON, backup, git, Godot job, gate, capture, ROI metric or donor-execution by this worker. Exactly one repository file written: this addendum."
labels: [O, D, U, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; no P0 closed"
sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U12_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_numeric_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tick_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_select_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_water_shader_deep.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_hmap_num_deep.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md §1
---

# PORT1TO1 — owner brief addendum (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> This addendum updates `PORT1TO1_owner_brief.md` only for what landed **after** it: eight deep static passes and the P0-7 RNG owner packet. It is a read-only pointer summary — not a new claim, no gate pass, no parity verdict. Every deep pass is `STATIC` `[O]/[D]` plus named `[U]` captures; none executed the donor, captured a GPU frame, or retired a zero-mismatch experiment.

## 1. Per-P0 row — what the deep passes did

The brief's §2 table carries **6 P0 experiment rows** (P0-1, P0-3, P0-4, P0-5, P0-7, P0-8) plus the P0-6 footnote; the canonical register (`PORT1TO1_u_register_update.md` §1) carries **9 P0 rows** (water split into P0-1/1b/2). Both granularities are shown here. **No row's required experiment was changed in class; none closed.**

| P0 row | Deep pass | Required experiment | New pin / VA / naming anchor | Status |
|---|---|---|---|---|
| **P0-1 / W-U12** (reflection) | U12 deep | **Unchanged** — still the one-session `RUNTIME-GPU` trace; *expanded*, not replaced, by U12-A2/R1/R2/Q sub-items | Copy thunk `jmp [__imp_glCopyTexImage2D]` @ `0x4afb3c`, sole static `call` @ `0x4ed44c`; chain `sub_7715f4 → 0x771b50 → sub_4ed28c → gap 0x4ed38c`; Delphi `TOSWTextureImage` family (no MSVC RTTI); singleton `wgl*`/FBO name strings with 0 static xrefs | **OPEN `[U]`** |
| **P0-1b / W-U4\*** (scalars) | none of the eight passes | **Unchanged** — layer-pointer branch at `FUN_00851bdc`, two atomic tuples, no per-scalar mix | None added; U12 chain is a different water row | **OPEN `[U]`** |
| **P0-2 / W-U1, U3, U5, U6** | water-shader deep; hmap-numeric deep | **Unchanged** — shader-source hook/program hash and the `FUN_00854054` 4-tuple capture; questions *narrowed* (CUSTOM excluded, BUILTIN-vs-LEGACY still open) and new U-MAP/U-REG sub-runs named | Two 30-key CODE uniform tables; selector two-flag AND @ `0x856530`; byte-proven f32 clamp `±2.9639999866`; getter chain `FUN_0082f060/0082f114` | **OPEN `[U]`** |
| **P0-3 / F-GRID a–e + persistence** | FOW-numeric deep | **Unchanged** — `GetFOWLOSData` transects, 0 mismatching cells; *added* E-NUM-f/g (RTTI layouts, knob defaults) and an explicit evidence-of-absence result | `VA = file-off + 0x400C00`; `1.0f` @ `0x3613f5` classified as boolean-to-float, not a grid step; no `53.333…` float image-wide; 2.5/5 m hypotheses rejected as zero byte support | **OPEN `[U]`** |
| **P0-4 / S-TICK-O1** | tick deep | **Unchanged** — 3600-frame × 3-seed state-hash harness; *added* U-DSP/U-THR rows | CODE API cluster: `GetPlayerCurrentPlHandle` @ `0x690692`, player-index `0x68f4e2`, section `0x693a00–0x693c00`, thread object `0x693f89`/`0x6a8894`, time/state `0x69faf6–0x69fbce`, GO-delay `ExecuteState` `0x63c4c4…` | **OPEN `[U]`** |
| **P0-5 / E-B1…C2** | blend deep | **Unchanged** — R-B1 vertex-hash `(6,8)` vs `(0,0)` 3/3; *added* R-P1 and tightened labels with native field names | 8-arg native prototype @ `0x630100`, property tables `0x550c00`/`0x550dd0`, API `0x62f300–0x630700`, non-blend twin `0x642e00`, enum `0x4f6d00` | **OPEN `[U]`** |
| **P0-6 / S-SAVE-R1** | save deep | **Unchanged** — paired-save single-field divergence + byte-identical re-save; *added* E-A/E-B/E-C/E-D sub-runs and R1h-NEW | Shipped `.map` heads (two maps); profile-verb thunk block ~2.88–3.04M; snapshot template ~3.21–3.23M; nested widths 17/48/55/866 B | **OPEN `[U]`** |
| **P0-7 / S-RNG-G1** | RNG owner packet | **Unchanged series** R20/L20/C300/U50/F1M/K0/A600; the packet *is* the required owner experiment (specified, not performed) and fills the handoff gap — no stream or draw wired | Owner-only L2 breakpoints `0x60f64c`, `0x403a0c`, `0x8f2008`, `0x8f206c`; two distinct seed contexts (`20261113` vs synthetic X21 pair) | **OPEN `[U]`** |
| **P0-8 / E-U13 + F-V1/V2** | selection deep | **Unchanged** — ≥5 surveyed points to 0 px and the 1-px membership battery; *added* an explicit aspect arm V2-PROJ-ASPECT | `GetCameraFieldOfViewByFocalLength(focallength, viewportdimension)` @ `0x5fece6` + inverse @ `0x5fed52`; ray/AABB API VAs; `m = max(w,h)` aspect divisor byte-proven in `sub_4cd334` | **OPEN `[U]`** |

## 2. NEW `[D]` facts — static, bounded, none a live value

- **Blend 8-arg prototype `[O]`:** `GameObjectSwitchToTreeAnimationCyclesBlendByHandle(gohnd, name, randomcycles, randomframe, randomfbcycles, randomfbframe, minframeblend, maxframeblend)` @ `0x630100`; non-blend twin @ `0x642e00` confirms spelling. Arg names resolve B3 *as names only*; `FB` semantic and B1 weight curve / B2 frame fetch stay `[U]`. `smooth` exists only in the never-unit-called Frame family.
- **f32 clamp `±2.9639999866` `[D]`:** byte-proven from the D04 height specimens' LE f32 grid — a **record clamp**, not a live uniform. Port `±2.96` cites `texturemap.inc:29` classification; `2.964` generation text; none may be presented as recovered `(hmapMin,hmapMax)`.
- **Tick CODE API cluster `[O]`:** scheduler/section/thread/time/GO-delay prototype runs at the VAs above; global bookkeeping loops are ascending `[O]`, but `CurrentPlHandle` rotation is `[U]-ORD`. Both callers of `sub_4cd334`-style table data decode as data-as-code garbage and were discarded — no dispatch loop or iteration order recovered.
- **Selection API signatures / `viewportdimension` `[O]`:** the focal↔FOV entries take **two** floats, the second *named* `viewportdimension` (not width, height, `max(w,h)` or sensor) — which viewport dimension feeds it stays `[U]`. `GetGameObjectRayCastAABBByHandle(..., x1,y1,z1,x2,y2,z2): Boolean` @ `0x63153e` proves the inside-test domain is a **world segment vs AABB**, not a screen rect. No `FOVSensor`/`Sensor`/`FarPlane` bytes; `ProjectionMatrix` @ `0x85511c` is GLSL fog text, not a camera API.
- **U12 copy thunk `[O]/[D]`:** unitary static copy edge `0x4ed44c → 0x4afb3c → __imp_glCopyTexImage2D`; no water-scoped caller found; FBO/pbuffer name strings are singleton dispatch-table entries with zero code xrefs under the tool's computed-pointer limit. `TOSWRefTextureImage` is a suggestive name `[I]`, **not** the reflection backer `[O]`; provenance stays `[U]`.
- **Save `.map` heads `[O]`:** `ausmis1.map` and `battle1.map` open `35 00 00 00` + `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` + `UID…` + `GameMapSnapShotBegin/End` + `GameMapRecordBegin`; tail `… "EXT.0" … GameMapEnd`. No `.sav` shipped. Fresh-save word `5C 00 00 00` (92) remains a `[D]` **prediction**, not an observed byte; no checksum/compression verb found.
- **Water-shader 30-key tables & selector bytes `[O]/[D]`:** complete embedded BUILTIN VP/FP source verbatim in CODE, two parallel 30-key CODE tables (`wst*` @ `0x853834+`, plain @ `0x853c70+`), `WaterShaderVP/FP - ` link-error strings referenced inside `FUN_00855b38`, and a two-flag AND at `0x856530`. `CustomEnable=False` excludes CUSTOM but does **not** force BUILTIN. Caveat: the landed file is self-truncated mid-§2 (ends at `eyePosition/cam` plus a literal `[truncated 9113 chars]`); only its §§0–2 text was available here — nothing beyond the quoted lines is inferred.

## 3. Honest 6-P0 / 9-row summary

The brief's "6 P0 experiments" and the register's "9 P0 rows" are the **same blocking set at two granularities** (water = P0-1 + P0-1b + P0-2), not a six-vs-nine contradiction. After all eight deep passes and the RNG packet: **NO P0 closed.** No required zero-mismatch experiment was weakened, substituted or satisfied; the deep passes added VAs, signature/property-table anchors, byte facts and extra sub-items (U12-A2/R1/R2/Q, E-NUM-f/g, R-P1, E-A/E-B/E-C/E-D, U-DSP/U-THR, V2-PROJ-ASPECT, U-MAP/U-REG), and supplied P0-7's missing owner packet — all advice-only. Six-condition parity chain stays 0/6; no donor GPU A/B frame exists; `blocking_unverified` is unchanged and non-empty; preserve-only hashes and additive-only v5 keys are untouched. Best admissible ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED".

## 4. Exact verdict template (repeated from owner brief §5, unchanged)

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

`RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all tier-2 conditions hold — not today. Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or treating `--assert-ab-verified` as verification. Given the current tree, **`blocking_unverified` is non-empty, so `RESULT IS NOT GOOD` unconditionally.**

---

*End of PORT1TO1_owner_brief_addendum. Read-only: exactly one repository file written (this addendum). No code, Godot, git, donor execution, capture, gate or ROI metric by this worker. No approximation promoted; no parity claim; no P0 closed.*
