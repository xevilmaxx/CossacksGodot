---
id: PORT1TO1-OWNER-BRIEF2-2026-11-27
title: "FINAL concise owner brief — full 1:1 Cossacks 3 donor port (post-final-wave)"
worker: BRIEF-FINAL2 (read-only subagent)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md]
files_edited: []
scope_guard: "Repo file/line reads only. No code, shader, config, asset, test, fixture, manifest, queue, result JSON, backup, git, Godot job/gate/capture/ROI metric or donor execution by this worker. Exactly one repository file written: this brief."
labels: [O, D, U, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; all nine P0 rows OPEN; six-condition chain 0/6 CLOSED; no donor GPU A/B frame."
sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief_addendum.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_sync2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d4_reclass.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck5.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_recheck.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
---

# PORT1TO1 — FINAL concise owner brief (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> This brief closes the sequence after `PORT1TO1_owner_brief.md` + addendum: it folds in the final wave only (randkey derivation, quad copy site, relief field defaults, T-VER envelope, first-camera wires, B-angle final, D4 market reclassification, final P0 sync, U classification A42/B14/C5/D10, claim rechecks). Every `[O]`/`[D]` below is static donor text/byte recovery; **no donor GPU/visual parity is claimed**. Implementation lanes carry labelled telemetry/law only and keep every live value `[U]`.

## 1. Most important donor STATIC recoveries ([O]/[D]) — implemented vs reported-only (no behavioural parity)

| # | Recovery (`[O]`/`[D]`, pinned `t_87f0f3c130b0`) | Status | Source |
|---|---|---|---|
| 1 | **NB-4 randkey derivation `[D]`:** `GenerateMapRandKey` impl `0x6ac244`; `randkey0=0`, `randkey1=Random($7FFFFFFF)` one draw; var-out slots `+0x18/+0x108=randkey1`, `+0x1c/+0x10c=randkey0`. U-KEY derivation CLOSED `[D]`. | **IMPLEMENTED** — `IMPL-RANDKEY-DERIV` in `terrain_donor_gen.gd`; labelled authority/data/telemetry ONLY, "NEVER read by generation", no RNG behaviour change; caller keys stay verbatim; runtime timing/state `[U]`. Non-gate parse artifact `00000133.json` is `--check-only`, not verification. | `DEC_U_nb4.md §2`, `DEC_U_nb4` ; recheck5 §6 |
| 2 | **NB-5 quad copy site `[D]`:** chain `sub_818920→sub_818824→sub_81ac54→sub_812e34`; two 32-B `rep movsd` row lifts + 4-iteration scatter; offsets `+0x05/+0x25→+0x10/+0x30`, `+0x0b` shift anchored. U-copy-site static angle CLOSED `[D]`. | **IMPLEMENTED** — `IMPL-QUAD-COPY` in `terrain_donor_mesh.gd`; telemetry only, "NOT a memcpy… no constant invented… no geometry/mesh/shader/sim change"; value-level byte dump `U-copy-values` stays `[U]`. | `DEC_U_nb5.md §§2-3`, recheck5 §6 |
| 3 | **D4 market law `[O]`/`[D]`:** rational blend `(c+bound·w)/(1+w)`, buy-to-max then sell-to-min, two rows, `:340` `buyres.sellexp` quirk, `buyamount=floor(sell·sellcost/buycost)`; live `garr_res_dlt` = `round(Lerp(dlt,ClampInt(r−trg,1,1000),dt))`, factor `dt·0.025·Max(1,dlt·0.01)`. | **IMPLEMENTED** — `game.gd` `trade()`/`tick_market()` carry the rational law, two-row scope, `MARKET_EXP` quirk and live dlt tracker; old linear push + hardcoded factor `1` absent. Float-semantics tails `U6-T`/`DLT` + interleave `O1` stay `[U]`; D4 itself remains `[U]`, NOT CLOSED (blocking if market prices/trades/active-dlt in scope). | `PORT1TO1_d4_reclass.md §§1-4` |
| 4 | **First-camera wires (2D+3D):** start-derived target exposed through existing API; FOV/zoom/height/time derivation seams located in `camera.gd`/`camera3d.gd`/`game.gd`. | **IMPLEMENTED** — `IMPL-START-CAMERA-WIRE`; derivations kept `[U]` with "NO PARITY CLAIM"; `17.27°` stays PORT APPROXIMATION; no new assertion. | recheck3 §6, recheck5 §6, `PORT1TO1_parity_chain.md §3` |
| 5 | **NB-2 relief field defaults `[D]`:** CODE property table `0x75c6a0–0x75ca2c`; `sub_75c314` name→offset→default (float `1.0f`; `HeightFieldMin/Max` default **one, not zero**); 4 wrapper arities; 5 shipped `pattern.lib` section concretes `[O]`. | **REPORTED-ONLY** — no per-pattern float promoted into generator; 675 sections, angle use, `Objects[]→mesh`, outside-stamp `Max`, MDEN 4th word, atlas literals stay `[U]`. | `DEC_U_nb2.md §§2-5`, `PORT1TO1_b_angle_final.md §3.3` |
| 6 | **T-VER shipped envelope `[O]`/`[D]`:** four shipped heads byte-identical `35 00 00 00` (=53) + `OSWMap13`/Build 2843; extents 320²×3 + 384×1; sole writer `gDataVersion:=92`; `gc_MaxTerrainTypeCount=9`; mapsize enum `0→320,1→480,2→640,3→256`. | **REPORTED-ONLY** — port pin **92/240² MISMATCHES** the shipped 53-envelope/320²–384² at word 0 (zero-mismatch FAIL); live `gRecordGeneratorVersion`/`mapsize`/terraintype `[U]`; fresh-save `5C 00 00 00` a `[D]` prediction, not an observed literal. No selector wired. | `DEC_U_tver_deep.md §§2/4`, `PORT1TO1_p0_sync2.md §0` |
| 7 | **UREG-CTOR partial single-instance ownership `[D]`:** `hmapTex@0x853e0c`, `hmapMin@0x853e3c`, `HeightMapTexUnit@0x852b84` (valueless); schema init `0x853ad4`→`[C+0xf4]+0x54..+0x64`; shader ctor `0x856080` defaults `C+0xd8=0xde1/+0xdc=2/+0xe0=0`; zero TOSW* ctor→field stores. | **REPORTED-ONLY** — `C+0x54..+0x64` numerics explicitly excluded as draw-time hmap supply; pointee class/GL name/provenance `[U]`; `TOSWRefTextureImage` stays `[I]`. | `DEC_U_ureg_ctor.md §§2-5`, recheck5 §5 |
| 8 | **B-angle final + U classification:** original class-B **14/14 EXECUTED** (B4, B5 partial), new **6/7** NB (NB-5 pending then executed; only NB-4 a new numeric `[D]`, NB-2 parser defaults `[D]`). All still-open `[U]` items classified **A42 / B14 / C5 / D10 = 71**. | **REPORTED-ONLY** (governance/outcome) — class-B static results never close class-A value/behaviour items; no P0 closed; no value promoted. | `PORT1TO1_b_angle_final.md §§2-4`, `PORT1TO1_u_classify.md §3`, recheck5 §5 |

## 2. The nine P0 rows — all OPEN, no row CLOSED

One-sentence owner action each; all experiments owner/COORD-only (workers forbidden). Paths relative to `docs/terrain_swarm_2026-11-26/reports/`. Packets close nothing by themselves; each row retires only on its own zero-mismatch capture/harness.

| Row (governing form) | One-sentence owner action | Packet / session |
|---|---|---|
| **1 — P0-1 / W-U12** (static narrowing only) | In one authorised donor GPU/debugger session, classify U12 (a) FBO / (b) `glCopyTexImage2D` dst / (c) static upload and dump `(target,name,w,h,unit,matrix)`, identical with 0 mismatches across ≥2 water-visible frames + 1 camera move. | `PORT1TO1_water_owner_protocol.md` / S1 Ph3 |
| **2 — P0-1b / W-U4\*** (structure closed, value open) | Break `FUN_00851bdc`, read the layer pointer and hook the S1–S11/W0/W1/S10/S11 uniforms on the U1 program, proving a bit-exact ENGINE-or-FILE tuple (0 ULP across 2 frames + move). | `PORT1TO1_water_owner_protocol.md` / S1 Ph2 |
| **3 — P0-2 / W-U1,U3,U5,U6** (structure closed, value open) | Hook `glShaderSource` + program hash + 30-key uniform log, dump live `(W,H,Min,Max)` and GL texture history, write-watch `C+0xc8`, and dump UV/index/cull state, all 0 differing bits across ≥2 frames + move. | `PORT1TO1_water_owner_protocol.md` / S1 Ph1/4/5/6 |
| **4 — P0-3 / F-GRID a–e + persistence + tint** (static narrowing only) | At seed `20261113` run reveal transects (visions 0/3/8), overlap/removal/team-split, blocker and walk-away/reload arms plus raw `GetFOWLOSData` dumps, fitting one linear scale with 0 mismatching cells/edges. | `PORT1TO1_fow_owner_protocol.md` / S2 |
| **5 — P0-4 / S-TICK-O1 + D1–D3** (static narrowing only) | Run the headless fixed-dt hash harness (12 players × 3600 frames × 3 seeds × restarts, idle/battle/forced-veto) permuting only block boundaries until one byte-identical order survives with 0 tick mismatches. | `PORT1TO1_tick_owner_protocol.md` / S6 |
| **6 — P0-5 / E-B1…B4, C1, C2 + W/S/A/R** (structure closed, value open) | At 30 Hz stepped frames run R-B1…B4/C1/C2 and R-W/S/A/R batteries at 3/3 trials per sid, stepping `(6,8)` vs forced `(0,0)`, with byte-identical frame/hash tables and 0 mismatches. | `PORT1TO1_blend_owner_protocol.md` / S3 |
| **7 — P0-6 / S-SAVE-R1a…g** (structure closed, value open) | Produce paired donor `.map` saves differing in exactly one field plus an identical-state re-save control at seed `20261113`, 3 repeats, with exactly the predicted word diverging at the predicted offset and all else byte-identical. | `PORT1TO1_save_owner_protocol.md` / S5 |
| **8 — P0-7 / S-RNG-G1** (algebra closed, attribution/counts open) | Run the full R20/L20/C300/U50/F1M/K0/A600 series vs the X21 oracle plus the L2 state-dump breakpoints, requiring the exact S sequence and 0 mismatches across all series. | `PORT1TO1_rng_owner_protocol.md` / S7 |
| **9 — P0-8 / E-U13 + F-V1/V2** (static narrowing only) | On the fixed `58 m/−32°/focal 400` rig with ≥5 surveyed markers, solve projection to 0 px and run pick/AABB/drag/marquee/minimap probes to 0 mismatches incl. exact ties, 1-px edges and FOW veto. | `PORT1TO1_selection_owner_protocol.md` / S4 |

## 3. Verification status (honest, as of 2026-11-27)

- **MCP host: VERIFIED.** All 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`) appear in `tools/list` and returned without error in the live QA 64×64 donor-backend probe; `game.tick({})` is a clean refusal. Presentation/telemetry only — **no parity claim** (`owner_brief §3`).
- **Deterministic two-run byte-identical repeats: port-internal PASS.** `detcheck_20261113` vs `detcheck2_20261113` (seed `20261113`, 64 ticks / 2 frames, 1280×720) have byte-identical per-frame `sha256_pixels` (`def18ad9…`, `18e1e72…`), identical PNGs and `seq_index.json`; `repcheck`/`finalcheck` add repeat-verification artifacts. Validates opt-in `--deterministic-capture --capture-ticks N` mode only — **chain condition 6 PARTIAL, not closed**; NOT a donor A/B frame, camera match, geometry-byte equality or `[U]` closure (2 frames vs the 24-frame/768-tick design target; `parity=UNVERIFIED` in both manifests).
- **14 ROI comparisons: all UNVERIFIED.** 14/14 `compare_frames.py` runs executed, 0 refusals; every run prints `parity=UNVERIFIED`; donor/port cameras explicitly `NOT_SHARED_donor-oblique_vs_port-17p27` (third-party H.264 stills, unknown build/camera); metrics are support cues only, no threshold or similarity % (`PORT1TO1_roi_metrics.md`).
- **Six-condition parity chain: 0/6 CLOSED.** Conditions 2 and 6 PARTIAL (port-internal only); 1, 3, 4, 5 BLOCKED. No donor GPU A/B frame, no matched-input manifest, no COORD ruling, `blocking_unverified` non-empty — ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED" (`PORT1TO1_parity_chain.md`, `PORT1TO1_parity_recheck.md`).
- **Guard/preserve hashes: PASS (byte-identical witnesses).** `config_donor_capture.json` = `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da`; `main.gd.bak-COORD-I11` = `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8`; `world3d.gd.bak-COORD-I11` = `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` (all match recorded baselines). `config.json` = `223767E5…44E2` and `manifest.json` = `36F6A378…2731` are point-in-time readings with **no recorded baseline**. Tool prefixes `ABBF0571/DDFB8688/00C0591A/667B71FB/3A92D053/5A3B9E77`; donor pin `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` (report id only; never opened/hashed/executed here). No unauthorized test weakening; parity strings negated/guarded (claim rechecks 1–5).

## 4. Preserve-only constraints — never flip / revert / repair / re-apply / re-hash-as-proof

- `variant3d/config_donor_capture.json`: keep `backend=donor`, `demo_mill=true`, water `alpha_confine=true`/`shore_prox=false` (byte-identical witness above).
- `inbox/backup/main.gd.bak-COORD-I11` and `world3d.gd.bak-COORD-I11`: single-applied I11 seam; never re-apply or flip default.
- `variant3d/config.json`: keep `backend=donor`, `color_unify=true`, `fov_deg=17.27` (APPROX), numeric overrides, comments. `manifest.json`: keep `ukr/buildings`, EUR aliases, `field` conversions; rollback by id only.
- Six acceptance tools (P-9): COORD must re-run `py_compile` at A′-1 on the frozen tree. Donor pin `cossacks.exe`: read-only, never executed/copied.
- Additive-only v5 save keys (no key removed/renamed/reordered/version-bumped; restore `>=5`). Shader/mesh opt-ins (W04 texgen, tile-map binding, neutral shore alpha, hires/array-atlas/light-match, exact `sceneColor=0.2`). Demo-mill/fields/builder stands. Preserved donor contradictions (`TileSmoothPasses=6` vs `SmoothTileMap(...,3)`, `lake_big:=plain*2*0`, swamp 17×20/18×23, `alphanull`, `specular_rgb` effective `vec3(0)`). Stale ghost test/assets.
- COORD must hash before **and** after every capture and never use `--ignore-history`. No `[U]` may be wired as a value, no approximation adopted, no test/gate weakened.

## 5. Verdict line (verbatim governing form)

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

`RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all tier-2 conditions hold — not today; given the current tree, `RESULT IS NOT GOOD` unconditionally. Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or treating `--assert-ab-verified`/a parse check as verification. **No approximation is endorsed and no parity is claimed.**

---

*End of PORT1TO1_owner_brief2. Read-only: exactly one repository file written (this brief). No code, Godot, git, donor execution, capture, gate or ROI metric by this worker. No P0 closed; no value promoted; no approximation; no parity claim.*
