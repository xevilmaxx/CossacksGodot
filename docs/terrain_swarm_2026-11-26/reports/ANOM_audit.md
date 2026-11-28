# ANOM Audit — ticket-180 DEBUG run (seed 20261113, 240x240 donor backend)

- Role: worker ANOM-AUDIT, read-only consolidation. No code/Godot/donor-execution performed.
- Source: `variant3d/.godot_queue/results/00000180_debug-audit-run/stdout.txt`
  (verified: 589 total lines, **585 lines containing `C3LOG**`; `stderr.txt` = 69 lines).
- Run config (stdout lines 3–6): `render_mode=3d terrain=donor seed=20261113`,
  `map=240x240 type=mediterranean quality=high biome=summer relief=hills richness=med`,
  `starts=2 water=3 stage_seed=-1`, `C3_LOG_LEVEL=DEBUG`.
- Parity: **UNVERIFIED**. Chain **0/6**. **RESULT IS NOT GOOD** while
  `blocking_unverified` is non-empty. No parity claim is made in this report.
- Decomp-worker citations: **all three PENDING — no artifacts landed.**
  No `ANOM*.md` exists under `docs/terrain_swarm_2026-11-26/reports/` at audit time, so
  no per-anomaly decomp report can be cited. Anything below marked UNVERIFIED stays
  UNVERIFIED until its owner lands evidence.

## 1. Full stage ledger (exact numbers from ticket-180 stdout)

### 1.1 pattern_gen (lines 7–46)

- tiles: `family=tiles done=4 skip=5`; rejects `d_tls_3` (x225 y45), `d_tls_2`
  (x225 y135), `d_tls_3` (x45 y225), `d_tls_4` (x135 y225), `d_tls_3` (x225 y225).
- replay mng: `done=18 reject empty=0 bounds=30 water=3 stand=7`; rejects include
  `bounds x247 y19`, occupied `mng_5 x143 y30`, `mng_2 x139 y50`, water `x155 y72`,
  `bounds x239 y13`.
- mines passes: `added=16 (pass1+pass2)` (line 19).
- stamp_family rows (count/done per line 20–38):

| family | kind | count | done | water | region | stand | empty |
|---|---|---|---|---|---|---|---|
| stones | stone | 2 | 1 | 11 | 183 | 18 | 0 |
| forests_pine_small | forest | 1 | 1 | 0 | 2 | 0 | 0 |
| stones | stone | 2 | 1 | 21 | 182 | 12 | 0 |
| forests_pine_small | forest | 1 | 1 | 3 | 35 | 2 | 0 |
| forests_pinefir_big | forest | 8 | 4 | 114 | 0 | 895 | 0 |
| forests_spruce_big | forest | 8 | 4 | 92 | 0 | 838 | 0 |
| forests_pine_big | forest | 8 | 8 | 9 | 0 | 106 | 0 |
| forests_pine_big_2 | forest | 8 | 3 | 139 | 0 | 1184 | 0 |
| forests_spruce_medium | forest | 11 | 0 | 229 | 0 | 1971 | 0 |
| forests_pinefir_medium | forest | 11 | 0 | 228 | 0 | 1972 | 0 |
| forests_pine_medium | forest | 11 | 11 | 18 | 0 | 184 | 0 |
| forests_pinefir_small | forest | 9 | 3 | 155 | 0 | 1355 | 0 |
| forests_pine_small | forest | 9 | 9 | 10 | 0 | 56 | 0 |
| stones | stone | 7 | 7 | 4 | 0 | 28 | 0 |
| stoneforests | stone | 5 | 5 | 3 | 0 | 23 | 0 |
| hills_dark | hill | 5 | 1 | 80 | 0 | 737 | 0 |
| hills_light | hill | 5 | 0 | 101 | 0 | 899 | 0 |
| decor | decor | 7 | 5 | 72 | 0 | 633 | 0 |
| dcr1 | decor | 5 | 0 | 0 | 0 | 0 | 5 |

- stamp_relief rows (lines 39–45): `plateau_big` plateau needed=1 done=1 stand=35;
  `plain_huge` plain needed=7 done=4 stand=1968; `ravine_big` ravine needed=2 done=0
  stand=1024; `plateau` plateau needed=1 done=1 stand=80; `plateau_small` plateau
  needed=1 done=0 stand=512; `hills_dark` hill needed=9 done=1 stand=4222;
  `hills_light` hill needed=9 done=1 stand=4380. All `reject empty=0`.
- build summary (line 46): `stamps=92 kinds={ "tile": 4, "mine": 16, "stone": 14,
  "forest": 44, "hill": 3, "decor": 5, "plateau": 2, "plain": 4 }`
  `res={ "gold": 5, "iron": 3, "coal": 8 }`
  `rejects={ "empty": 10, "water": 1292, "region": 402, "stand": 23146, "bounds": 30, "blocked": 3072 }`
  `samples=10`.
- `_gen_base done` (line 47): `stamps=92 starts=2 hmin=-1.100 hmax=2.964
  water=5776/57600 mask_water=0.096`.

### 1.2 post-pattern stages (lines 48–55)

- `_gen_patterns done`: `stamps=92` (same kinds), `res_nodes=727` (line 49).
- `_gen_forests done`: `res_nodes=869 added=142` (line 51).
- `_gen_resources done`: `res_nodes=869 added=0` (line 53).
- `_gen_finish done`: `res_nodes=960 ore={ "gold": 5, "iron": 3, "coal": 8 }
  wealth=1.000` (line 55).

### 1.3 world build / donor_inputs / mesh / water (lines 57–80)

- `donor_inputs.build begin w=240 h=240` (line 59).
- `donor_inputs case-fix alias hit k_ravine_2 -> K_ravine_2` (line 60; one hit shown).
- `donor_inputs.build done shape=nowater2 raw=land
  mask=res://assets/terrain_new/masks/height/dlc5/nowater2/4pl_mask_nowater_170_gauss.height.png
  exact=7 families=28 patterns=64/64 skipped=2 absent=0 casefix=3 gates=9 source=file`
  (line 61).
- `donor_inputs mask_count=66 chains=22 const_ids=248 loaded=99` (line 62).
- `world.build gen applied=true params=17` (line 64).
- mesh atlas: `tier=terrain_new_2048x1024_128cell`,
  `manifest=res://assets/terrain_new/atlas/tile_index_atlas.manifest.json`,
  `masks=2`, `grid=(16.0, 8.0)`, `tile_array layers=1 ids=1` (lines 65–72).
- water (lines 73–76):
  - `build begin w=240 h=240 path=BUILTIN scalar=UNSET[U4*] level=-0.250 plane_y=-0.500`.
  - `[ERROR][water] build REFUSED U4* UNSET scalar_enum=-1 label=UNSET[U4*]
    path=BUILTIN grid=240x240 capture=U4* (DEC-U §6: break FUN_00851bdc @0x851bdc,
    record layer ptr; dump C+0x88..+0xc4 + C+0xb4/+0xbc; hook glUniform1f/2f
    S1–S11 + W0/W1; 0-ULP / 0-mismatch over 2 frames + camera move)`.
  - `[WARN][terrain] mesh.water build failed w=240 h=240`.
  - `mesh.water gate water=false w=240 h=240`.
- `mesh.build cells=57600 verts=230400 tris=115200 surfaces=1 sentinel=0 oor=0
  relief_guard=0 unmapped=0` (line 77).
- `mesh.build done ... mode=single water=false` (line 78); `world.build mesh build=true`
  (line 79).

### 1.4 relief.bind / entities.bind (lines 81–90)

- `relief.bind begin` (line 81); meshes `terrainmesh1..4` loaded `4/4`,
  `legacy_fallback=false` (lines 82–86).
- `relief.bind done props=0 batches=0 stamps=92 matched=0 missing_mesh=0 unknown_sid=0`
  (line 87).
- `entities.bind done manifest_sids=335 bbox_sids=335 obj_available=335
  glb_available=0` (line 89).
- `entities.bind field preflight skipped=0 converted=16 tree_pool=19 stage_obj=12
  scaffold_obj=61` (line 90).

### 1.5 entities.sync / fog / misc (lines 92–589)

- First sync: `units=16 res=858 buildings=2 batches=26` (line 169); steady state
  `res=858` through line 588 (`units=16 res=858 buildings=3 batches=38..68`).
- `fog update SKIP fow_disabled viewers=1 grid=240x240`, `fow_enabled=false` (lines 155–158).
- `stderr.txt` (69 lines): missing optional `variant3d/config_donor_capture.json`
  plus export-time image-load WARNINGs (`tile_index_atlas.png`, `alpha.png`) with
  GDScript backtraces. No fatal error.

## 2. Anomaly-by-anomaly verdicts

Conventions: EXPECTED-BY-DONOR-LAW = behavior the donor law / port gate design
requires; PORT GAP = port-side defect proven by landed evidence; UNVERIFIED =
neither proven nor law-covered — do NOT treat as good or bad.

- **A1. U4\* water hard-fail (lines 73–76). Verdict: EXPECTED-BY-DONOR-LAW — NOT a defect.**
  The water gate deliberately REFUSEs an UNSET scalar instead of inventing one.
  The embedded capture spec (DEC-U §6: break `FUN_00851bdc`, 0-ULP / 0-mismatch over
  2 frames + camera move) is the owner-gated donor action that must land first.
  Downstream state is consistent: `mesh.water gate water=false`, `mesh.build done
  ... water=false`. No decomp citation needed; the refusal text is itself the gate law.
- **A2. `relief.bind` matched=0 props=0 with stamps=92 (line 87). Verdict: UNVERIFIED.**
  Decomp worker ANOM-MNTPROPS: **PENDING** (no artifact). Meshes loaded 4/4 with
  `missing_mesh=0 unknown_sid=0`, so the zero-match cause is unknown — not proven to be
  law, not proven to be a gap. Blocking.
- **A3. `relief_grid` candidates/applied. Verdict: UNVERIFIED.**
  Decomp worker ANOM-RELIEFGRID: **PENDING** (no artifact). Note: stdout contains
  **no `relief_grid` line at all** (full-text search negative); the only relief-guard
  datum is `mesh.build ... relief_guard=0` (line 77). The `candidates=0/applied=0`
  figures from the task brief are **not confirmed by stdout** and are NOT adopted here.
  Blocking.
- **A4. 23146 stand rejects (line 46) incl. fully-zero families
  (`forests_spruce_medium` 0/11, `forests_pinefir_medium` 0/11, `hills_light` 0/5,
  `ravine_big` 0/2, `plateau_small` 0/1). Verdict: UNVERIFIED.**
  Decomp worker ANOM-STAND: **PENDING** (no artifact). Stand/water/region columns are
  logged per family (all `reject empty=0` except `dcr1 empty=5`), but whether the
  magnitudes match donor law is unproven either way. Blocking.
- **A5. `entities.sync res=858` vs `_gen_finish res_nodes=960` (lines 55 vs 169–588).
  Verdict: UNVERIFIED.** Observed directly in stdout (delta = 102, persistent across the
  whole sync tail). Not in the ticket brief; recorded here as an auditor observation,
  cause unknown, no value invented. Blocking.
- **A6. `donor_inputs` skipped=2 absent=0 casefix=3 (line 61) vs one shown alias hit
  (line 60). Verdict: UNVERIFIED.** The single logged hit (`k_ravine_2 -> K_ravine_2`)
  does not self-evidently account for `casefix=3`, and the 2 skipped patterns are
  unnamed in stdout. Cause unknown, no value invented. Blocking.
- **A7. `dcr1` done=0 with `reject empty=5` (line 38); `mesh.water build failed` WARN
  (line 76); fog `SKIP fow_disabled` (lines 156–158). Verdict: dcr1 UNVERIFIED
  (blocking); water WARN is part of expected A1 refusal (not a separate defect);
  fog SKIP is EXPECTED-BY-CONFIG (`fow_enabled=false`, viewers=1) — not a defect,
  provided disabled-FoW is the intended debug-run config (config ownership outside
  this audit).

## 3. Water hard-fail confirmation (explicit)

The U4\* water hard-fail is **expected behavior and NOT a defect**: with
`scalar=UNSET[U4*]` the builder must REFUSE rather than hallucinate a water level, and
it did (line 74), degrading cleanly to `water=false` mesh output (lines 76–78). The
unblocker is the quoted DEC-U §6 donor capture (0-ULP / 0-mismatch, owner-gated), which
has not run. Treating this ERROR line as a bug to patch around would itself be the defect.

## 4. NEW actions (zero-mismatch / owner condition)

1. **DEC-U §6 water-scalar capture** (from line 74): break `FUN_00851bdc @0x851bdc`,
   record layer ptr, dump `C+0x88..+0xc4` + `C+0xb4/+0xbc`, hook `glUniform1f/2f`
   S1–S11 + W0/W1; accept only on **0-ULP / 0-mismatch over 2 frames + camera move**.
   Condition: owner-approved donor execution. Status: not run → blocking_unverified.
2. **ANOM-RELIEFGRID report** (relief-grid law for candidates/applied + zero-family
   relief rows). Condition: worker lands artifact. Status: PENDING → blocking_unverified.
3. **ANOM-MNTPROPS report** (relief.bind matched=0 law). Condition: worker lands
   artifact. Status: PENDING → blocking_unverified.
4. **ANOM-STAND report** (23146-stand law + zero-done families). Condition: worker lands
   artifact. Status: PENDING → blocking_unverified.
5. **A5/A6 resolution** (sync 858-vs-960 delta; skipped=2 / casefix=3 accounting).
   Condition: owner assigns + zero-mismatch evidence. Status: unassigned → blocking_unverified.

`blocking_unverified` = { water-scalar capture, ANOM-RELIEFGRID, ANOM-MNTPROPS,
ANOM-STAND, A5-delta, A6-accounting }. Chain 0/6 (no link verified).

## 5. No-invention confirmation

No anomaly in this report was "fixed" by inventing a value. Where stdout is silent
(A3 has no `relief_grid` line; A6 names neither skipped pattern; A5 has no logged
cause), the report records absence instead of filling it in. All verdicts above are
`EXPECTED-BY-DONOR-LAW`, `EXPECTED-BY-CONFIG`, or `UNVERIFIED` — no `PORT GAP`
declared, no parity claimed. Parity remains **UNVERIFIED**, chain **0/6**,
**RESULT IS NOT GOOD**.
