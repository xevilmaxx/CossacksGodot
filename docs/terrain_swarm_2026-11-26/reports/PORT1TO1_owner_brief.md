---
id: PORT1TO1-OWNER-BRIEF-2026-11-26
title: "Concise owner brief — full 1:1 Cossacks 3 donor port, before final review"
worker: OWNER-BRIEF (read-only subagent)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md]
files_edited: []
scope_guard: "Repo file/line reads only. No source, shader, config, asset, test, manifest, queue, result JSON, backup or git mutation; no Godot job, gate, capture, donor binary or donor GPU frame. Exactly one repository file written: this brief."
labels: [O, D, U, "PORT APPROXIMATION", "PRESERVE-ONLY", "NO_PARITY_CLAIM"]
parity_status: UNVERIFIED
parity_claim: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty"
sources:
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_runbook.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_guard_audit.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md
  - docs/terrain_swarm_2026-11-26/HANDOFF.md (§9.21)
---

# PORT1TO1 — concise owner brief (2026-11-26)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> This brief is a read-only summary of landed reports, not a new claim, a gate pass or a parity verdict. Every `[O]`/`[D]` line below is a pointer into a cited report; every `[U]` stays open with its named zero-mismatch experiment. No approximation is endorsed and no parity is claimed.

## 1. Donor-exact vs still approximation / `[U]`

1. **Broad donor-exact static recovery `[O]/[D]` is real but is *text/byte* recovery, not a donor-identical frame.** 300 reports across 5 domains (evidence index); e.g. generation stage/RNG/reseed order, terrain records/LUTs/`tsDouble`, exact `sceneColor=0.2`, alpha/blend enums, 710/710 `.pattern` closure, 680/680 `pattern.lib`, 124-tile mapping, donor death/ghost/capture/team law. Presence of a report is evidence of existence only.
2. **Landed implementation lanes cover the deterministic, text-recoverable layer.** Terrain gen/renderer (`IMPL-GEN-1TO1`, `IMPL-RENDER1TO1`), 8 skirmish law sets, 77 weapon + 33 protection rows, per-sid collision/vision/radius tables, AAF 8→40 action export, death families, ghost blink, team/tick/capture laws, additive-only v5 save keys (`PORT1TO1_PLAN.md` tasks 1–165).
3. **Verification tooling is behaviourally donor-neutral, not donor-validating.** MCP host `cossacksgodotmcp` protocol + all 6 tools verified live; opt-in deterministic capture mode (`--deterministic-capture --capture-ticks N`); `compare_frames.py` always prints `parity=UNVERIFIED`. All are port-internal evidence.
4. **Water is not donor-exact.** BUILTIN is `[D]` default; **no water is drawn until U12 FBO is bound (hard-fail, no grey fallback)**; U1/U3/U4*/U5/U6 remain `[U]`; `map_size`/`±2.96`, `_time += delta`, screen-UV bias and the decoded-grid hmap alias are labelled scaffolding, not donor values.
5. **FOW is not donor-exact.** Cell size `1 res = 1 m`, Boolean-OR combine, pure-radius disc, sticky explored and the minimap tint ladder are PORT APPROXIMATION; grid a–e, occlusion, persistence and tint remain `[U]`.
6. **Simulation/visual law residuals remain `[U]`.** `TICK_ORDER v1` is PORT APPROXIMATION; no lerp/slerp on the pose path (`requested_blend` is intent-only); save is key-order + round-trip determinism only (never byte parity); S-vs-G RNG attribution and camera FOV `17.27°` are open/APPROX; engine AABB, marquee and projection are scaffolding.
7. **Non-P0 residuals and `U-INJ-1…11` stay labelled.** These are deterministic but undocumented donor divergences (morale stack, garrison fire/heal, alpha/specular/fog literals, audio clip/pitch, etc.); each keeps its zero-mismatch experiment. No silent fallback, no invented constant, no weakened test (final guard: parity strings PASS, tests PASS, 3 MINOR label-only gaps GF1–GF3).

## 2. P0 blockers that actually prevent a 1:1 visible / simulation result — and the one experiment each

| P0 | Why it blocks | One experiment needed (owner/RUNTIME; worker-forbidden) |
|---|---|---|
| **P0-1 Water U12/U4* (+U1/U3/U5/U6)** | No live reflection provenance ⇒ no water drawn at all; wrong scalar source ⇒ wrong colour/phase. | One-session GPU trace: reflection `glBindTexture`/FBO/copy/upload at `FUN_00856530`/`FUN_00854054` + layer-pointer branch at `FUN_00851bdc`, across ≥2 water-visible frames + camera move; 0-mismatch tuple/classification (`owner_decisions §1`, `DEC_U_water_capture.md`). |
| **P0-3 FOW grid / occlusion / persistence / tint** | Vision radius, LOS blocking and explored/tint state define what is visible. | Fixed-seed vision transects (peasant `vision` 0/3/8, reveal radii, hill/forest/wall blockers) → fit one scale/rule; 0 mismatching cells on two transects ×2 runs (`owner_decisions §2`). |
| **P0-4 Native tick interleave** | Mutual order of global/player/unit/projectile blocks drives all simulation state. | Fixed-seed state-hash harness: 12 mixed players, 3600 frames, 3 seeds; permute only block boundaries until one order survives with byte-identical hashes, 0 mismatches (`owner_decisions §3`). |
| **P0-5 Animation blend / completion** | No donor weight curve ⇒ poses/at-effect timing differ visually. | Fixed-camera per-tick pose/vertex-hash trace across `walk→idle` seam under `(6,8)` vs forced `(0,0)`, stepped 1 tick; step-support length byte-identical 3/3 (`owner_decisions §4`). |
| **P0-7 RNG stream split (G1)** | S/G attribution and per-site draw counts control sim order. | Deterministic replay with the X21/L20/C300/U50 oracle (`rng_model.py`, fixed fixture seed), canonical state hash; any single mismatch keeps it `[U]` (`owner_decisions §6`). |
| **P0-8 Selection / camera projection** | Pick winner and projection define what the player sees and clicks. | Fixed 58 m/−32°/400 rig with ≥5 surveyed ground markers: solve projection to 0 px and log ray-cast sort/prio/AABB/FOW-veto winner on every probe, 0 mismatches (`owner_decisions §7`). |

Footnote: **P0-6 save container / transform** is also open but affects persistence rather than a visible/sim frame — closing experiment is the owner paired-save hexdump battery (single-field divergence at expected offset + re-save byte-identical); wire format stays v5 additive (`owner_decisions §5`). No item above is settled by a port fallback, a "close" value, a still, a metric or a green-looking test.

## 3. Verification status (honest, as of 2026-11-26)

- **MCP host: VERIFIED.** All 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`) appear in `tools/list` and returned without error in the live probe on a QA 64×64 donor-backend map; `game.tick({})` is a clean refusal. Presentation/telemetry only — no parity claim (`HANDOFF §9.20/§9.21`, `acceptance_runbook §5`).
- **`cap_fullport8.png`: CLEAN apart from the deliberate water U4* hard-fail.** Deterministic mode landed (opt-in flags, fixed 1/32 ticks, authoritative viewport, 1280×720 asserts, no CPU fallback, audio seed in manifest); I11 seam and config hashes unchanged (`HANDOFF §9.21`).
- **14 ROI metrics: all UNVERIFIED.** 14/14 `compare_frames.py` comparisons executed, 0 refusals; all print `parity=UNVERIFIED`; donor/port cameras are explicitly `NOT_SHARED` (third-party H.264 stills, unknown build/camera) — metrics are support cues only, no threshold or similarity % (`PORT1TO1_roi_metrics.md`).
- **Deterministic two-run byte-identical hashes: PASS (port-internal only).** `detcheck_20261113` vs `detcheck2_20261113`, seed 20261113, 64 ticks, 1280×720 → per-frame `sha256_pixels` byte-identical (`def18ad9…`, `18e1e72…`). Validates the opt-in mode only; closes no donor A/B, camera match or `[U]` (`HANDOFF §9.21`, plan task 149).
- **Parity chain: 0/6 closed.** No `PORT1TO1_parity_recheck.md` landed (the only `*recheck*` file is the unrelated `X36_mountain_visual_recheck.md`), so the audit stands: conditions 1–6 blocked/partial, no COORD ruling, no donor GPU A/B frame, 575/582/585 unacked, `blocking_unverified` non-empty (`PORT1TO1_parity_chain.md`). Ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED".
- **Guard: PASS.** Parity strings negated/guarded; no unauthorized test weakening (`check()` counts unchanged); preserve-only hashes byte-identical (final guard audit).

## 4. Preserve-only choices and hashes — never flip / revert / repair / re-apply

| Item | Rule | Hash / witness |
|---|---|---|
| `variant3d/config_donor_capture.json` | Keep `backend=donor`, `demo_mill=true`, water `alpha_confine=true`/`shore_prox=false`. | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` — **byte-identical witness**. |
| `inbox/backup/main.gd.bak-COORD-I11` | Single-applied I11 seam; never re-apply or flip default. | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` — **byte-identical witness**. |
| `inbox/backup/world3d.gd.bak-COORD-I11` | Single-applied I11 seam. | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` — **byte-identical witness**. |
| `variant3d/config.json` | Keep `backend=donor`, `color_unify=true`, `fov_deg=17.27` (APPROX), numeric overrides, comments. | `223767E57B506577EAD54633708380A425A0B8AA439C8E3C28478C15C8ED44E2` — point-in-time reading, **no recorded baseline**. |
| `variant3d/assets/models/manifest.json` | Keep `ukr/buildings`, EUR aliases, `field` conversions; rollback by id only. | `36F6A378548F3116DC1585D7CDD34526A17B5C46D1DED02E3A93C7C736F22731` — point-in-time reading, **no recorded baseline**. |
| Six acceptance tools (P-9) | COORD must re-run `py_compile` at A′-1 on the frozen tree. | Prefixes `ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77` (recorded; not re-verified in this brief). |
| Donor pin `cossacks.exe` | Read-only, never executed/copied. | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`. |

Also preserve: additive-only v5 save keys (no key removed/renamed/version-bumped; restore `>=5`); shader/mesh opt-ins (W04 texgen, tile-map binding, neutral shore alpha, hires/array-atlas/light-match, exact `sceneColor=0.2`); demo-mill/fields/builder stands; preserved donor contradictions (`TileSmoothPasses=6` vs `SmoothTileMap(...,3)`, `lake_big := plain*2*0`, swamp 17×20/18×23, `alphanull`, `specular_rgb` effective `vec3(0)`); stale ghost test/assets. COORD must hash before **and** after every capture and never use `--ignore-history`.

## 5. Exact verdict template (choose exactly one)

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

*End of PORT1TO1_owner_brief. Read-only: exactly one repository file written (this brief). No code, Godot, git, donor execution, capture, gate or ROI metric by this worker. No approximation, no parity claim.*
