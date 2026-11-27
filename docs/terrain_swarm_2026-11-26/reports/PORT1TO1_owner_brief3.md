# PORT1TO1 — Final Owner Brief 3 (2026-11-27)

- id: PORT1TO1-owner-brief3-2026-11-27
- worker: BRIEF-3 (read-only final owner brief)
- date: 2026-11-27
- scope: READ-ONLY. No code/Godot/git/donor-execution; no other edits. Exactly one file written (this report).
- parity: UNVERIFIED. No parity claim. No approximations. File presence is not fidelity.
- sources: `PORT1TO1_review_consolidate.md` (id `PORT1TO1-review-consolidate-2026-11-27`), `PORT1TO1_terrain_brief.md` (id `PORT1TO1-terrain-brief-2026-11-27`), `PORT1TO1_nation_label.md` (id `PORT1TO1-NATION-LABEL`), `PORT1TO1_claim_recheck17.md` (id `PORT1TO1-CLAIM-RECHECK17-2026-11-27`), `PORT1TO1_p0_final_status.md` (id `PORT1TO1-P0-FINAL-STATUS-2026-11-27`).

## 1. Honest header

The full 1:1 port is NOT full and parity is UNVERIFIED for every subdomain. Nothing in this brief closes a P0 row or any `[U]`. RESULT IS NOT GOOD.

## 2. Earlier delivered state (carried, not re-verified here)

- MCP host 6/6: `game.status/tick/pan_to/screenshot/place_building/video.record_frames` verified as tooling only; no parity evidence (`PORT1TO1_owner_brief2.md`).
- Two byte-identical deterministic repeats port-internal only (`detcheck_20261113` vs `detcheck2_20261113`, 64 ticks/2 frames, `sha256_pixels` identical). Chain condition 6 PARTIAL only; not a donor A/B frame.
- 14 ROI comparisons: all UNVERIFIED (`parity=UNVERIFIED`; cameras `NOT_SHARED` third-party stills).
- Preserve hashes intact (point-in-time identities, not fidelity): `config_donor_capture.json aa857480…`, `main.gd.bak-COORD-I11 3859B605…`, `world3d.gd.bak-COORD-I11 44EE96C0…`; donor pin `87f0f3c1…` never executed.
- `CAPTURE-DEEP`: PENDING, no artifact found (consolidate `:16`).

## 3. The 22 new gaps + 1 label flag (all narrows-only; close nothing)

Domain A — generation/terrain (7). Report: `PORT1TO1-review-gen-2026-11-27` + probe `PORT1TO1-gen-gaps-2026-11-27`.

| ID | Gap | Disposition |
|---|---|---|
| G-NEW-1 | Bridge generation ABSENT (tag constants only) | OWNER-DECISION + OWNER-GPU-RUNTIME |
| G-NEW-2 | Mine far-ring corner relocation code-present, runtime UNVERIFIED | OWNER-GPU-RUNTIME |
| G-NEW-3 | Object-scale 3-branch application explicitly skipped | OWNER-GPU-RUNTIME (static part already ledgered) |
| G-NEW-4 | `tile_smooth_chains` consumer/producer wiring unproven | WORKER-STATIC + OWNER-GPU-RUNTIME |
| G-NEW-5 | Editor UI→cfg-key mapping ABSENT | WORKER-STATIC or OWNER-DECISION (out-of-scope ruling) |
| G-NEW-6 | Legacy `terrain_tileindex.gdshader` uninventoried | WORKER-STATIC |
| G-NEW-7 | Legacy tool per-file dispositions not recorded | WORKER-STATIC |

Domain B — objects/art/AAF (7 gaps + 1 stale-label flag). Report: `PORT1TO1-REVIEW-ART` + probe `PORT1TO1-ART-GAPS`.

| ID | Gap | Disposition |
|---|---|---|
| A-1 | `peaaustools.png` ABSENT at live `TOOL_MATERIAL_PATH` | WORKER-STATIC (land PNG) or OWNER-DECISION (re-point) |
| A-2 | Naval transform + animation data ABSENT (`.tlf`/naval AAF) | OWNER-DECISION |
| A-3 | Nation-art holes ABSENT: chaika, rus/tur mill buildings | OWNER-DECISION |
| A-4 | Ghost blink wired as constants; mesh-identity + runtime proof missing | OWNER-GPU-RUNTIME |
| A-5 | Mill sail: `eurmilanim.obj` on disk, rotor still PNG bake | OWNER-GPU-RUNTIME |
| A-6 | FX compositions: keys/laws wired; sheets unproven, loopers lifeless-by-label | OWNER-GPU-RUNTIME |
| A-7 | Tool attach: resolver + 3D child wired; material texture + runtime proof missing (blocked on A-1) | OWNER-GPU-RUNTIME |
| A-8 | STALE LABEL `NATION_MESH_BLOCKED_EVIDENCE` blanket premise refuted | OWNER-DECISION (label correction; see §4) |

Domain C — skirmish laws/save/fog/camera/HUD/minimap (8 deltas). Report: `PORT1TO1-REVIEW-LAWS-2026-11-27` + addendum `PORT1TO1-LAWS-ADDENDUM-2026-11-27`.

| ID | Gap | Disposition |
|---|---|---|
| L-1 | Upgrade time/cost/gate/preempt/dispatch/loss law ABSENT | OWNER-GPU-RUNTIME |
| L-2 | Peace lobby→sim chain guard-only | OWNER-GPU-RUNTIME |
| L-3 | Team-win scope/stamp precedence batteries missing | OWNER-GPU-RUNTIME |
| L-4 | AI split/cadence + resbalance/officer/squad timing batteries missing | OWNER-GPU-RUNTIME |
| L-5a | Save E-T1 routing + R1h profile-store sub-slots missing from S5 | OWNER-GPU-RUNTIME |
| L-5b | Upgrade-queue build cap/batch/multiplier audit ABSENT (Q1) | WORKER-STATIC |
| L-5c | Delivery-radius per-site split ABSENT (E1) | WORKER-STATIC |
| L-5d | `orders[].info.trg` width/placement ABSENT | WORKER-STATIC + OWNER-GPU-RUNTIME |

Every row above: narrows only when static; runtime rows retire only on their own owner-run zero-mismatch capture/harness. No donor A/B frame or COORD ruling exists in these sources.

## 4. The one label fix applied

COORD applied the `PORT1TO1_nation_label.md:59-67` wording at `variant3d/scripts/world3d_entities.gd:249` (pre-image kept as `.bak-NATIONLABEL`; verified in `PORT1TO1_claim_recheck17.md:61-68`): label-only, const name/type/`BLOCKED` posture/cite/routing/`NOT VISUALLY FIXED` unchanged; evidence clause narrowed to actually-missing items (chaika, rus/tur mills, `grenadierbav` pending, stage/ghost art per `:270`) with `NOT donor visual parity` / `visual UNVERIFIED` guards. No value, logic, guard, branch, behaviour, or visual output changed. Closes no `[U]` and no P0 row.

## 5. P0 and BLOCKED rows still OPEN

All nine P0 rows remain OPEN per `PORT1TO1-P0-FINAL-STATUS-2026-11-27` §1: P0-1/W-U12, P0-1b/W-U4*, P0-2/W-U1-U3-U5-U6, P0-3/F-GRID+persist+tint, P0-4/S-TICK-O1+D1-D3, P0-5/E-B1-B4-C1-C2+W/S/A/R, P0-6/S-SAVE-R1a-g+E-T1, P0-7/S-RNG-G1, P0-8/E-U13+F-V1/V2. Single BLOCKED owner review row: plan task 186 Final owner review (owner-gated on matched donor GPU A/B + camera manifest).

## 6. Canonical verdict (verbatim)

Parity UNVERIFIED. Chain 0/6. Nine P0 OPEN. RESULT IS NOT GOOD while blocking_unverified is non-empty.

*End of PORT1TO1-owner-brief3. Parity UNVERIFIED. Exactly one file written; no completeness or parity declared.*
