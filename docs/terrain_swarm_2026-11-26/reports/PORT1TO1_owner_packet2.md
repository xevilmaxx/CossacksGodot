# PORT1TO1 — Owner packet 2 (consolidated actionable list, read-only)

- id: PORT1TO1-owner-packet2-2026-11-27
- worker: OWNER-PACKET2 (read-only consolidation)
- date: 2026-11-27
- sources: `PORT1TO1_terrain_gap_packet.md` (corrected), `PORT1TO1_terrain_brief.md`, `PORT1TO1_owner_brief2.md`, `PORT1TO1_p0_final_status.md`, `PORT1TO1_ack_evidence.md`, `PORT1TO1_checklist_final.md`, `PORT1TO1_signoff.md`, `PORT1TO1_p0_session_plan.md`, `PORT1TO1_rng_owner_protocol.md`, plus the nine P0 packets
- parity: UNVERIFIED. No parity claim. No approximations.
- scope: READ-ONLY consolidation. No code/Godot/git/donor-execution. Exactly one file written (this packet). No item closed. No parity.

## 0. Standing rules

- Parity UNVERIFIED for every landscape subdomain; chain 0/6; nine P0 OPEN; `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.
- No item below is a parity closure. Static work never closes class-A value/behaviour items. Deterministic repeats and ROI metrics never promote parity.
- `RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all tier-2 conditions hold — not today.

## 1. The nine P0 rows — all OPEN, exact packet path + one-sentence required action

Paths relative to `docs/terrain_swarm_2026-11-26/reports/`. Every experiment is owner/COORD-only; workers forbidden. Each row retires only on its own zero-mismatch capture/harness; packets close nothing by themselves.

| # / row | Exact packet path | Required action (one sentence, status OPEN) |
|---|---|---|
| 1 — P0-1 / W-U12 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` (S1 Ph3) | In one authorised donor GPU/debugger session classify U12 as (a) FBO / (b) `glCopyTexImage2D` dst / (c) static upload and dump `(target,name,w,h,unit,matrix)`, identical with 0 mismatches across ≥2 water-visible frames + 1 camera move. |
| 2 — P0-1b / W-U4* | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` (S1 Ph2) | Break `FUN_00851bdc`, read the layer pointer and hook the S1–S11/W0/W1/S10/S11 uniforms on the U1 program, proving a bit-exact ENGINE-or-FILE tuple (0 ULP across 2 frames + move). |
| 3 — P0-2 / W-U1,U3,U5,U6 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` (S1 Ph1/4/5/6) | Hook `glShaderSource` + program hash + 30-key uniform log, dump live `(W,H,Min,Max)` and GL texture history, write-watch `C+0xc8`, and dump UV/index/cull state, all 0 differing bits across ≥2 frames + move. |
| 4 — P0-3 / F-GRID a–e + persistence + tint | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md` (S2) | At seed `20261113` run reveal transects (visions 0/3/8), overlap/removal/team-split, blocker and walk-away/reload arms plus raw `GetFOWLOSData` dumps, fitting one linear scale with 0 mismatching cells/edges. |
| 5 — P0-4 / S-TICK-O1 + D1–D3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md` (S6) | Run the headless fixed-dt hash harness (12 players × 3600 frames × 3 seeds × restarts, idle/battle/forced-veto) permuting only block boundaries until one byte-identical order survives with 0 tick mismatches. |
| 6 — P0-5 / E-B1…B4, C1, C2 + W/S/A/R | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md` (S3) | At 30 Hz stepped frames run R-B1…B4/C1/C2 and R-W/S/A/R batteries at 3/3 trials per sid, stepping `(6,8)` vs forced `(0,0)`, with byte-identical frame/hash tables and 0 mismatches. |
| 7 — P0-6 / S-SAVE-R1a…g | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md` (S5) | Produce paired donor `.map` saves differing in exactly one field plus an identical-state re-save control at seed `20261113`, 3 repeats, with exactly the predicted word diverging at the predicted offset and all else byte-identical. |
| 8 — P0-7 / S-RNG-G1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md` (S7) | Run the full R20/L20/C300/U50/F1M/K0/A600 series vs the X21 oracle plus the L2 state-dump breakpoints, requiring the exact S sequence and 0 mismatches across all series. |
| 9 — P0-8 / E-U13 + F-V1/V2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md` (S4) | On the fixed `58 m/−32°/focal 400` rig with ≥5 surveyed markers, solve projection to 0 px and run pick/AABB/drag/marquee/minimap probes to 0 mismatches incl. exact ties, 1-px edges and FOW veto. |

## 2. OWNER-GPU-RUNTIME items (terrain/landscape brief — exact zero-mismatch or capture requirement)

- Water U12: owner captures U12 reflection FBO provenance — classify (a) FBO / (b) `glCopyTexImage2D` dst / (c) static upload; zero-mismatch = provenance fields all present and matching, no substitute frame accepted.
- Water U4*: owner captures U4* FILE-vs-ENGINE scalar winner + engine wave dirs — break `FUN_00851bdc`, hook S1–S11/W0/W1/S10/S11; zero-mismatch = 0 ULP across 2 frames + 1 camera move.
- Water U3: owner captures U3 height-object identity — live `(W,H,Min,Max)` + GL texture history; zero-mismatch = 0 differing bits across ≥2 frames + move, no neutral-substitute texture.
- FOW grid/combine: owner runs reveal transects + `GetFOWLOSData` dumps at seed `20261113`; zero-mismatch = one fitted linear scale with 0 mismatching cells/edges, no slope/blocker rule without a second rotated transect.
- Tick interleave: owner/COORD runs headless fixed-dt harness 12 players × 3600 frames × 3 seeds × restarts; zero-mismatch = single surviving byte-identical order `H_0…H_3599`, no retry-until-green.
- Camera derive: owner runs fixed `58 m / −32° / focal 400` rig with ≥5 surveyed markers; zero-mismatch = ≥5 points reproject to 0 px, pick/membership 0 mismatches incl. exact ties and FOW veto; `17.27°` stays PORT APPROXIMATION, zoom 0.75 stays PORT CHOICE, never donor fact.
- RNG live state: owner/COORD runs full R20/L20/C300/U50/F1M/K0/A600 series vs X21 oracle `(0x44A108F9, 0x00000001)` plus L2 native state-dump breakpoints (`0x60f64c/0x403a0c/0x8f2008/0x8f206c`); zero-mismatch = exact S sequence `3C6FEF6C…A2C21855`, G count-only, 0 mismatches — L2 is a state dump, not a GPU frame.
- Byte-level death OBJ: owner-side byte verification [U]-G2 only — record per-OBJ bytes/verts/bbox + manifest rows for 48/48 (12 stems × `_death1/_death2/_death1a/_death2a`); zero-mismatch = every stem resolves to bytes or is marked ABSENT, no assumed conversion.
- Grass props: owner proves render/swap live — fixed-camera close-up captures per BaseName mesh+material manifest (mesh PRESENT/ABSENT, albedo PNG + dimensions, winter PRESENT/ABSENT); zero-mismatch = no PNG claimed wired without a manifest row, no data-only JSON counted as wired.

## 3. OWNER-DECISION items

- D4 market scope: D4 stays `[U]`, NOT CLOSED — blocking if market prices/trades/active-dlt in scope; owner rules it in or out with all four out-of-scope conditions recorded, else it remains in `blocking_unverified`.
- Deferred aliases: owner rules normalisation-vs-quarantine for `desert_forests_big` (+ `n_desert_frt_big_1..17`), `k_pump_`, `plant*` bodies uncited ([U]-G3), and `desert_frt_un` needs no work; quarantine re-affirmation for `m_swamp_12_old` (17×20 vs binary 18×23) and `lake_big := plain*2*0` literal — donor bytes byte-identical, no silent rename or "fix".
- Zoom PORT CHOICE: zoom 0.75 and FOV `17.27°` stay labelled PORT CHOICE / PORT APPROXIMATION; owner alone may adopt a donor value on a 0-mismatch row — no worker wires a `[U]` as a value.
- Policy labels: owner owns I03 F-01 ownership, V16-26/V16-27 feed ownership, GR-A24 repoint to `mountain_props.json`, `terrain_donor_tiles.gd` ownership, FILE-vs-ENGINE scalar winner (U4*), kernel accept-open ruling, `set_season()` canonical-shape ruling, and signed capture/criteria verdicts per class at pinned camera/roi — every O-item ruled or proven, none silently dropped.

## 4. 575/582/585 ack or fresh-rerun rule

- Tickets 575/582/585 remain owner-only and UNACKED; no worker ack and no gate pass inferred from an ack.
- Fresh gate sequence A′-0…A′-3 then D-0…D-6 must be run by owner/COORD with unique job ids (D1: 5 streams × 3 sizes, zero-byte dumps; D3: `script_error_lines=0`; 29/29 + 17/17 + render-mode + 5/5 variety + `scan_map ALL GREEN`); 575/582/585 acknowledged only with evidence-backed reasons, never `--ignore-history`; a dirty spool without ack leaves gates not green.

## 5. Hash-before/after-capture and preserve-only never-flip rule

- COORD must hash every preserve-only witness before AND after every capture; a changed witness invalidates that run.
- Preserve-only — never flip / revert / repair / re-apply / re-hash-as-proof: `variant3d/config_donor_capture.json` (`backend=donor`, `demo_mill=true`, `alpha_confine=true`/`shore_prox=false`); `inbox/backup/main.gd.bak-COORD-I11` and `world3d.gd.bak-COORD-I11` (single-applied I11 seam); `variant3d/config.json` (`backend=donor`, `color_unify=true`, `fov_deg=17.27` APPROX); `manifest.json` (ukr/buildings, EUR aliases, field conversions, rollback by id only); six acceptance tools (COORD re-runs `py_compile` at A′-1 on the frozen tree); donor pin `cossacks.exe` read-only, never executed/copied; v5 save keys additive-only (no key removed/renamed/reordered, restore `>=5`, no version bump); preserved donor contradictions (`TileSmoothPasses=6` vs `SmoothTileMap(...,3)`, swamp 17×20/18×23, `alphanull`, `specular_rgb` effective `vec3(0)`, `lake_big := plain*2*0`, demo-mill/fields/stands) and stale ghost test/assets.
- No `[U]` may be wired as a value, no approximation adopted, no test/gate weakened.

## 6. Canonical verdict (verbatim)

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

*End of PORT1TO1_owner_packet2. Read-only consolidation; exactly one file written; no code/Godot/git/donor execution; no item closed; no approximation; parity UNVERIFIED; RESULT IS NOT GOOD while blocking_unverified is non-empty.*
