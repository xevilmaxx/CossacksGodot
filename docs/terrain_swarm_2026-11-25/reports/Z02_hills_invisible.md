---
id: Z02
ticket: "HEIGHT WAVE / Z02 — why height is present in the mesh (world3d_terrain.gd:1311) but the owner never sees hills"
agent: "Z02 (read-only diagnostic, subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_DONOR_ACCESS
scope: "This report is the ONLY repo file written. No source, shader, config, asset, test, JSON, PNG, donor, queue or git edit; no Godot process and no runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, REFUTED, BLOCKED, PORT APPROX]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3, §5). Every visual reading is INFERRED or UNVERIFIED. All substitutes and port-authored rules are labelled PORT APPROX. NO DONOR PARITY CLAIM."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A05_relief_visibility.md
  - docs/terrain_swarm_2026-11-25/reports/G17_perf_audit.md
  - docs/terrain_swarm_2026-11-25/reports/P05_shader_cost.md
  - docs/terrain_swarm_2026-11-25/reports/G22_2d_vs_3d.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
  - docs/terrain_swarm_2026-11-25/reports/A10_regression_constraints.md
  - docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md
  - docs/terrain_swarm_2026-11-25/reports/P02_draw_calls.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md
  - docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md
  - variant3d/scripts/world3d_terrain.gd, game.gd, pattern_gen.gd, camera3d.gd
  - variant3d/shaders/terrain_tileindex.gdshader, variant3d/config.json
verdict: "HEIGHT IS REAL BUT GEOMETRICALLY TINY: THE mesh vertex Y is literally height[i]*1.0, but ±2.964 m is spread over 126x164 m footprints (~1° slopes), so unshaded Blinn-Phong under a 70° donor sun produces no readable shading, verbatim cDiff 0.5/0.55 face gates never fire, and the donor's actual hill silhouette comes from terrainmesh props that the port never shipped. B04's attempt to force cliff art via scaled cDiff/absolute-height gates produced concentric contour rings and was reverted. MINIMAL DONOR-GROUNDED FIX: land G07's donor-active relief grids (game.gd), then feed the producer's ALREADY-WRITTEN-BUT-UNREAD _relief_stamp_mask into the existing vf/vs face path (world3d_terrain.gd) so donor rock art fires only on donor-stamped cells and never on near_start boundary steps. Reject HEIGHT_SCALE fudging and shadow/AO fakery."
---

# Z02 — Height exists in the mesh; hills never appear

> [!IMPORTANT]
> **Donor is truth.** Labels: **observed** (literal current source line, decoded
> donor field quoted from a prior read-only report, or direct on-disk file
> listing), **derived** (arithmetic/control-flow consequence of observed lines),
> **inferred** (attribution without a pixel-aligned donor A/B), **UNVERIFIED**
> (not measurable with available instruments), **REFUTED**, **BLOCKED**, and
> **PORT APPROX** (an explicit substitute or port-authored rule, not donor
> truth). No donor file was read, run or copied by this worker; donor facts are
> cited from prior read-only reports. No Godot process or runner job was used.
> **No donor parity claim.**

---

## 0. Short answer

**DERIVED + OBSERVED (one real capture confirms the visual outcome):** the
height array is not lost between `game.gd` and the mesh. It is written verbatim
to vertex Y (`world3d_terrain.gd:1310-1312`), and its normals are uploaded and
consumed by the shader (`world3d_terrain.gd:1387`, `:1423`;
`terrain_tileindex.gdshader:294-306`, `:427`). The failure is one of **scale and
of missing silhouette geometry**, not of data transport:

1. ±2.964 m (and, after RCODE-FIX-01, only about +0.50 / −0.56 m in the base
   grid) is spread over footprints of roughly **126 × 164 m** at the shipped
   240² map, giving ≈1° slopes; adjacent 2 m cells differ by ≈0.03–0.14 m.
2. The shader is `unshaded` and there is **no shadow map, no AO and no voxel
   pass**, so the only depth cue is a Blinn-Phong dot product under a ≈70° sun,
   which changes by a few percent across a 1–4° slope.
3. The **verbatim donor `cDiff1=0.5` / `cDiff2=0.55` face gates need a height
   step five to fifteen times larger than the port supplies**, so `face` stays
   0 and the already-shipped grey `rockNvf`/`rockNvs` art is never selected.
4. The donor's **visible hills are largely explicit `terrainmesh*.osm` props
   7–10 units tall**, not grid bumps; the port has none (`world3d_terrain.gd:1515`
   lists `mountain terrainmesh props` as `not_done`).
5. Only 2 of 26 decoded donor grids reach height, and the donor-*active*
   `ravine_big` family has no port grid at all.
6. B04's attempt to lower the barrier via span-scaled `cDiff` and absolute-height
   gates fired on `near_start` protection-disc boundaries and plateau-mask
   contours, producing the **concentric contour "maze"**; it was fully reverted
   (`B04_relief_impl.md:25-40, 55-83, 85-98`).

A fresh real generated-map frame observed this exact state: *"No hills are
visible. There is no rounded elevation silhouette, ridge, slope shading or
self-shadowing anywhere ... ground reads as a flat board"*
(`RELIEF_VISUAL_01.md:134-157`). **The visual effect is therefore OBSERVED in
one frame; no flag-off A/B and no donor GPU A/B exist** (`A05:387-389`).

---

## 1. The height chain, end to end (all observed)

```
mapgen.gd:63-85        relief(R-code): donor literals +2.964 / +1.317 / −2.964
                       (live base amplitudes now +0.496 / −0.558 after RCODE-FIX-01,
                        game.gd:82-84)
        ↓
game.gd:964            map_scale = MAP_W / C3PatternGen.DONOR_UNITS   (160, pattern_gen.gd:9)
game.gd:976-991        stamp loop; donor grid only for id == "plt2" | "k_ravine_1"
game.gd:1063-1072      h = clamp(h + grid*scale, donor min/max ∩ ±2.964)
                       _relief_donor_mask[i]=1; _relief_stamp_mask[i]=1
game.gd:1231-1251      global land clamp / 0.03 dither (donor cells skipped)
game.gd:1252-1276      collision: |dh|>0.5 cardinal / >0.55 diagonal → terrain=5 + blocked
        ↓
world3d_terrain.gd:130-132      TILE_M=2.0, HEIGHT_SCALE=1.0, WATER_LEVEL=−0.25
world3d_terrain.gd:1307-1312     ONE vertex per cell; Y = height[i]*1.0
world3d_terrain.gd:756-778       _face_mode_at(): verbatim cDiff on cell deltas
world3d_terrain.gd:1332          face = 0 if shore else _face_mode_at(...)
world3d_terrain.gd:1340-1354     cliff art only when face != 0
world3d_terrain.gd:1387/1423     normals = 1-cell forward diff, uploaded
world3d_terrain.gd:1407          UV2 = (tile_id, face)
world3d_terrain.gd:709/1160/1455 shadow_enabled=0, sun shadow off, cast_shadow OFF
        ↓
terrain_tileindex.gdshader:43     render_mode blend_mix, unshaded, cull_disabled
terrain_tileindex.gdshader:294-306 donor Blinn-Phong: l, h, n; v_packed=ambient+diffuse
terrain_tileindex.gdshader:427    rgb = albedo * v_packed + v_specular
```

Two facts matter for interpretation:

- **One vertex per 2 m cell is a hard sampling limit** (`DTRN_02:113` C17,
  `:281-285`): the mesh cannot carry a sub-cell escarpment; `(W−1)(H−1)×2`
  triangles, no extruded walls, no LOD.
- **The face-promotion path in the current tree is the pre-B04 baseline.**
  `_face_mode_at()` at `:756-778` is byte-identical to pre-B04; no
  `_relief_face_at()`, no `B04_` constants, no `stats["b04_relief_promotion"]`
  remain (`B04_relief_impl.md:85-98`; direct grep of `world3d_terrain.gd`
  confirms only `_face_mode_at` at `:756`, `_donor_cliff_name` at `:805`,
  `_tilt_face_normal` at `:885`, `_normal_at` at `:901`).

---

## 2. Ranked causes — with file:line evidence

| Rank | Cause | Status | Evidence (`path:line`) | What it explains |
|---:|---|---|---|---|
| **1** | **Amplitude vs footprint.** `HEIGHT_SCALE=1.0`, `TILE_M=2.0`; ±2.964 m over a plt2 cap of 42×55 donor cells scaled by `W/160` = 63×82 port cells = **126×164 m** at 240². Base R-code now only +0.496/−0.558. | **CONFIRMED source; visual effect OBSERVED in one frame** | `world3d_terrain.gd:130-132, 1310-1312`; `game.gd:81-90, 964, 1063-1072, 1231-1251`; `pattern_gen.gd:9`; `DPATTERN-01:154` (cited by `A05:144-145`); `RELIEF_VISUAL_01.md:153-157` | Near-flat board; no silhouette, ridge or self-shadow; weak diffuse contrast |
| **2** | **No silhouette geometry: donor relief props absent.** Donor mountains instantiate `terrainmesh{1..4}.osm` / `terrainplateau*.osm` props, 6.9–10.9 units tall (≈14–22 m if 1 unit≈2 m), ≈52–56 m wide — the donor's visible mountain relief is mostly *props*, not grid bumps. Port has zero such geometry. | **CONFIRMED (port negative); donor decode observed** | `DTRN_02:104-109` C8/C9, `:272-277, 323-327, 394-399`; `world3d_terrain.gd:1515` (`"mountain terrainmesh props"` in `not_done`); direct glob of `variant3d/assets/models/**`: **no** `terrainmesh*.obj/.glb` (only `prop_winter_materials.json:719-756` names them, materials only) | No hills/mountains at all, however the grid is tuned; whole silhouette class missing |
| **3** | **Shading cannot carry the read.** `unshaded` shader (so no Godot lighting/shadow pass), donor Blinn-Phong dot product, near-up normals because heights are near-up, high ≈70° sun. No shadow map shipped, no AO/SSAO/voxel/contact darkening. | **CONFIRMED source; contribution INFERRED** | `terrain_tileindex.gdshader:37-43, 180, 294-306, 427`; `P05_shader_cost.md:68-70` (shadow block runtime-not-taken); `world3d_terrain.gd:709, 1160, 1455`; `A12_config_knobs.md:122, 174`; `P02_draw_calls.md:37-45, 152` | Few-percent luma change across a 1–4° slope; no depth cue; amplifies rank 1 |
| **4** | **Face gates cannot fire → no grey cliff art.** `_face_mode_at()` requires |Δh|>0.5 cardinal / >0.55 diagonal; at ≈1° a 2 m step is ≈0.03 m (≈0.14 m even at 64²/4°). `face` stays 0, so `rockNvf`/`rockNvs` art is never selected. | **CONFIRMED mechanism; visual contribution INFERRED** | `world3d_terrain.gd:153-162, 756-778, 1332, 1340-1354, 805-836`; `game.gd:1252-1276`; `A05:238-249` | Reference ravine/cliff faces absent even where small height variation exists |
| **5** | **B04's forced promotion is unusable.** Span-scaled `cDiff` + absolute-height rock gate fired on `near_start` one-cell steps (up to ≈2.964 m) and on concentric plateau-mask terraces → dense contour rings around every building; fully reverted. | **CONFIRMED (owner visual verdict + revert proof)** | `B04_relief_impl.md:25-40, 55-83, 85-98`; `game.gd:960-975, 1046` (protect disc), `:1244-1251` (0.03 dither terraces) | Explains why simply lowering thresholds is NOT the fix; maze mechanism identified |
| **6** | **Grid coverage: only 2 of 26 decoded donor grids reach live height.** Id gate hard-codes `plt2`/`k_ravine_1`; donor-active `ravine_big` is placed (`pattern_gen.gd:47`) but has no port grid; `k_ravine_1` is BLOCKED and donor-disabled. | **CONFIRMED (BLOCKED for `k_ravine_1`)** | `game.gd:91-128, 986-991`; `pattern_gen.gd:43-52`; `A05:213-236`; `G07_relief_plan.md:107-131, 202-230`; `RELIEF_02:68-84` | Whole donor ravine class and asymmetric lip/cap shapes absent; most stamps use analytic fallback (`game.gd:998-1012, 1074+`) |
| **7** | **Camera/sun contrast.** `pitch_degrees=-32`, height 58 m, V-FOV 17.27°, so a shallow oblique view compresses silhouettes; the donor sun is high (≈70°). Both settings are donor-legal. | **CONTRIBUTING (inferred); NOT ACTIONABLE** | `config.json:61-70`; `camera3d.gd:58, 64, 78-88, 278-280`; `world3d_terrain.gd:137-138`; `RELIEF_VISUAL_01.md:105` (`camera_pos=(21.98,58,70.26)`, target `(85.98,41.44)`); `A05:182-193` | Amplifies ranks 1 and 3; changing it would be a non-donor visual fudge |
| **8** | **RCODE-FIX-01 lowered base amplitudes** from legacy ±1.317/±2.964 to +0.496/−0.558 at R=96/48. A correctness fix, not a regression, but it makes rank 1 decisive. | **CONFIRMED source; effect derived** | `game.gd:81-87`; `A05:154-161`; `DTRN_02:97-102` C1/C2 | Current base grid is ~2.7× flatter on hills / ~5.3× on ravines than earlier captures |
| **9** | **No voxel/AO pass and no shadow map.** Ambient+diffuse only; no SSAO/SSR/glow/fog in the environment; turning the shader shadow uniform on is inert without a shipped shadow texture and is an explicitly guarded invariant. | **CONFIRMED (port); donor AO usage UNVERIFIED** | `P02_draw_calls.md:37-45, 152`; `A12_config_knobs.md:122, 174`; `A10_regression_constraints.md:61, 86, 297`; `F01_almanac_terrain.md:247` | Removes the last cheap contact/depth cue; not a fix target |

### Refuted / rejected as explanations or fixes

- **"Normals are smoothed away" — REFUTED.** `NORMAL` is transformed and used in
  `terrain_tileindex.gdshader:298, 301, 305, 306, 427`; the mesh uses a 1-cell
  forward difference specifically so a 1-cell step survives
  (`world3d_terrain.gd:896-917`). Normals are near-up because heights are
  near-up (`A05:168-180`).
- **"Flag/marker never reaches the live mesh" — REFUTED for the current tree.**
  `plt2` was runtime-confirmed to fire (seed 20261150, `applied_cells=443`,
  `RELIEF_SEED_PROBE_01:143-181`) and the grid was wired into the live path
  (`RELIEF_LIVE_FIX_01:156-175`); `A05:195-211`. Coverage, not transport, is the
  gap.
- **"Enable shadows" — REJECTED.** `shadow_enabled=0.0` (`shader:180`,
  `world3d_terrain.gd:709`), sun shadow off (`:1160`), terrain cast shadow OFF
  (`:1455`); no shadow map shipped (`A12:122,174`). `A10:86` explicitly records
  "do not enable shadows to fake relief". Turning it on is non-donor and inert.
- **"Raise `HEIGHT_SCALE` / invent a steeper amplitude" — REJECTED as primary.**
  It is an invented visual multiplier with no donor citation; it violates the
  charter guardrail (`CHARTER.md:55-63`; `A05:163-166`), it breaks entity
  ground alignment (`world3d_entities.gd:1534-1535` reads `game.height_at()`),
  it desynchronises the water/shore gate (`world3d_terrain.gd:1326`), and —
  decisively — it would make the existing verbatim `_face_mode_at()` fire on
  `near_start` steps, recreating the B04 maze. If COORD nonetheless orders it,
  every value is **PORT APPROX** and must be config-gated, default OFF, with a
  fresh capture before any claim.

---

## 3. Why B04 is not available as the "small" fix

`B04` did exactly what one would try: scale `cDiff1/cDiff2` by height span
(`span×0.03`, floor 0.05) and add the donor absolute-height gates
(`|h|>2.4/>2.7`). The owner's fresh real-map capture showed dense concentric
topographic rings / maze patterns and rings around every building (`B04:25-40`).
The mechanism is now understood (`B04:55-83`):

1. `game.gd:960-975` marks a `near_start` protection disc; relief skips those
   cells at `:1046`, so the disc boundary is a **one-cell step up to ≈2.964 m**.
2. `game.gd:1244-1251` quantises/dithers the height cap by ~0.03 R-levels,
   creating numerous small terraces; the plateau mask shape itself is
   concentric.
3. Any local-delta promotion gate fires on (1) and (2); the absolute-height gate
   fires on plateau interiors. Together they trace the mask contours.

B04's own handoff says: **keep the revert; land donor-active relief grids first;
taper the producer boundary or feed promotion an explicit producer-side relief
mask; only then retry one threshold at a time with a fresh capture**
(`B04:100-114`).

A decisive new observation for this ticket: **`_relief_stamp_mask` is currently
write-only.** It is declared at `game.gd:80`, resized at `:958-959`, and written
at `:978` (near_start disc) and `:1071` (donor-grid stamp cells); a whole-tree
grep finds **no reader anywhere** (not in `game.gd`, not in
`world3d_terrain.gd`, not in the dump schema). The comment at `game.gd:74-79`
claims the gradient/collision pass uses it, but the code does not. This is
important twice over: B03's claimed maze suppression is not actually wired, and
the producer already computes exactly the donor-grounded cell mask a safe face
promotion needs.

---

## 4. Minimal donor-grounded change proposal

### 4.1 Options considered and verdict

| Option | Donor-grounded? | Changes what the owner sees? | Maze risk | Verdict |
|---|---|---|---|---|
| **A. G07 donor-active relief grids** (`k_ravine_big_stone_1`, `hil1`, `g_hil4`) in `game.gd` | **Yes** — numbers decoded from `.pattern`/`pattern.lib`, no binary copied; blend remains **PORT APPROX** | Restores ravine/hill *shape classes*, but 8×10 block means over a 126+ m footprint still read flat at 240² (`A05:296-298`, `G07:226-230`) | Low (no face change) | **Do first — necessary, not sufficient** |
| **B. Mask-gated face collars / `rockNvf` art from G22 option 3** (`world3d_terrain.gd`) | **Yes** for art and thresholds (`texturemap.inc:63-64, 594-601`; `G22:120, 136`); the *promotion rule* is **PORT APPROX** | **Yes** — grey cliff faces become visible without any height fudge | **Contained** if driven by `_relief_stamp_mask`, not by a lowered global threshold | **Recommended minimal visual fix** |
| **C. Bake `terrainmesh*.osm` props** (`DTRN_02:394-399`) | **Yes** — donor geometry, derived glTF/OBJ only | **Yes** — real hill silhouette, the donor's own mechanism | Low (no face/path change) | **Correct but NOT minimal**: no derived assets exist yet (glob: none); new tool + new assets + new instancing owner; COORD must grant |
| **D. `HEIGHT_SCALE` / amplitude exaggeration** | **No** — invented multiplier | Possibly, at the cost of entity/water/gate desync | **High** — re-triggers baseline face gates on near_start steps | **Reject as primary; PORT APPROX only if ordered** |
| **E. Enable shadows / add AO** | **No** — no shadow map shipped; donor AO usage UNVERIFIED | No (inert) / unverified | n/a | **Reject** (`A10:86`, `A12:122`) |

### 4.2 Recommended: Stage A + Stage B (both donor-grounded, no new assets)

**Stage A — data/code, owner: `variant3d/scripts/game.gd` only**
(COORD grants exclusive ownership; B03 was the prior owner, `G07:261-276`).

- Extend `RELIEF_GRID_META` at `game.gd:125-128` and the id gate at
  `:986-991` with the G07 subset: Tier 1 `k_ravine_big_stone_1` (derived 8×10
  table after the bit-exact min/max gate, `G07:202-230`) and Tier 2 `hil1`,
  `g_hil4` (80 floats each already printed in `DPATTERN_01` Appendix A,
  `G07:158-200`; note `hil1.scale = 0.65`).
- **Leave byte-identical:** `_sample_relief_grid()` `:927-943` (current tree;
  older reports cite `:918-934`), blend/clamp
  `:1063-1072`, footprint math `:1013-1047`, collision pass `:1252-1276`,
  main.gd producer, `pattern_gen.gd` (no `ravine_medium` recipe), `main.gd`.
  `k_ravine_1` stays **BLOCKED** and unreachable.
- Every table is **PORT APPROX** (8×10 block means, "debug/preview aids only",
  `DPATTERN_01:595-600`); keep `row_flip: UNVERIFIED`; no new RNG draw.
- Backup `inbox/backup/game.gd.bak-Z02A` before edit.

**Stage B — visual read, owner: `variant3d/scripts/world3d_terrain.gd` only**
(COORD grants; B04 file is currently clean/reverted, `B04:85-98`; back up as
`inbox/backup/world3d_terrain.gd.bak-Z02B`).

- In `_face_mode_at()` (`:756-778`), add a **producer-mask precondition** before
  the verbatim `cDiff` test: only a cell whose producer-side relief mask bit is
  set is eligible for relief-face promotion. Read the mask from the game dump
  (`_dump_from_game()` at `:926-960` already translates game arrays) or from a
  new dump key added by Stage A's owner; **do not lower `DONOR_CDIFF1/2`
  (`:161-162`) and do not reinstate an absolute-height gate**.
- Keep `_face_mode_at()`'s existing signature/thresholds for stub-driven atoms
  (`A10:54-55` flat-grid guard); the new input must return 0 on a flat grid and
  on all un-stamped cells. Face vocabulary stays exactly `0/1/2`
  (`A10:54, 81`).
- Let the existing cliff path run unchanged: `_donor_cliff_name()`
  (`:805-836`, donor `|h|<0.1`, `>2.4`, `>2.7` gates) and the `vf/vs` atlas swap
  (`:1340-1354`, `world3d_terrain.gd:164-175` donor 25°/0.125 literals). This is
  G22 option 3 realised with **zero new mesh, zero new atlas cell, zero shader
  change**: the donor rock art is already byte-identical in both trees
  (`G22:113, 136`).
- The selection rule "stamped cell ⇒ eligible for face art" is a **PORT
  APPROX** rule (donor promotion UNVERIFIED, `RV-TRN-01` verdict C, cited at
  `world3d_terrain.gd:752-755`). Thresholds themselves remain donor literals.
- If the atlas `vf/vs` path still cannot be made contour-clean, G22's separate
  overlay option 3 (`G22:136`) is the fallback: same mask-driven art as a
  decal/overlay mesh, still no tile-index change.

**Why this is minimal:** it adds ~two tables and one id branch in `game.gd`, and
one mask lookup plus one guard in `world3d_terrain.gd`. It uses only donor
numbers, donor art and the donor thresholds already shipped. It does not touch
`HEIGHT_SCALE`, the shader, the atlas, the camera, the producer RNG or `app/**`.
It directly removes the B04 maze mechanism by construction: the producer mask
excludes `near_start` cells (`game.gd:978` writes the disc, `:1046` skips
relief there), so a disc boundary cannot be promoted.

### 4.3 Risks and gates

| Risk | Evidence | Gate / mitigation |
|---|---|---|
| **Maze recurrence** — any remaining terrace edge or disc boundary traced as cliff art | `B04:33-39, 57-79`; `game.gd:1244-1251` | Feed only `_relief_stamp_mask` cells; **one** change at a time; fresh G04 windowed real-map capture; G05 second-agent visual read; explicit check of all historical ring boxes (`RELIEF_VISUAL_01.md:141-147`, `L07:269`). If any concentric ring appears, revert from `world3d_terrain.gd.bak-Z02B` — do not tune a threshold blind. |
| **Mask is write-only today** — Stage A must expose it in the dump for Stage B | direct grep: only 5 hits in `game.gd` (declaration, resize×2, writes×2), none read | Add a dump key in `game.gd` (Stage A owner); assert in a read-only unit probe that `flatten` atoms still see zero promotion on stub grids. |
| **`reach` / walkability regression** from added relief | `G07:313-317`: added relief adds `blocked` cells | `t_map_variety` 5/5 with `same_seed_byte_identical`; `scan_map.py` all green (`cliff>=80`, `tileflow>=99`, `reach` all seeds); staged rollout dropping `g_hil4` first if a gate flips; never lower a threshold. |
| **Flat-grid atoms / mesh invariants** | `A10:54-55, 86`; `G14:115-123` | `flat_grid_promoted==0`, `flat_face_zero==0`, topology 1/4096/7938/4096, UV2 `0/1/2` unchanged, `shadow_enabled==0`, `mi.cast_shadow=OFF`. |
| **No visual proof** — donor parity remains UNVERIFIED | `CHARTER §3/§5`, `G22:145-148`, `A05:367-370` | Accept on "no maze + visibly steeper ravine/hill silhouettes" only after a fresh G04 capture and G05 review. Do **not** flip H-6. |
| **`HEIGHT_SCALE` remains 1.0** | `world3d_terrain.gd:131` | No entity/water alignment change (`world3d_entities.gd:1534-1535`, `world3d_terrain.gd:1326`). |

Only **G04** may submit runner jobs (`WAVE_G_CHARTER.md:31, 67-70`). All other
work in this proposal is analysis or a disjoint implementation after a COORD
ownership grant; backups are mandatory (`CHARTER.md:66`).

### 4.4 If COORD wants real hill *silhouettes* (Stage C, not minimal)

`DTRN_02:394-399` Step 4: bake `terrainmesh1..4.osm` / `terrainplateau*.osm`
read-only to derived `.obj` (the repo already has an established derived-OBJ
pipeline: `variant3d/assets/models/obj/*.obj`, `CREDITS.md:54`,
`world3d_entities.gd:84, 1146`), instantiate at mountain/plateau stamp centres
with **authored scale** (`dogenerate.inc:1984` exempts these from random
scaling). Exact owners: a NEW derived-data tool (e.g.
`variant3d/tools/bake_terrainmesh.py`, built on `convert_models.py:75` /
`bake_sprites.read_osm_first`), NEW derived assets under `assets/models/obj/`,
and an instancing hook in `world3d_terrain.gd` (or `world3d_entities.gd` —
contested by M03/P11, COORD grant required). **No donor `.osm` in the runtime
asset tree.** Risks: which `terrainmeshN` a stamp selects is engine-side and
**UNVERIFIED** (`DTRN_02:444`), new draw calls (P02/P11), 64² may have no
mountain stamp for a chosen seed, asset deriv/licensing review. Gate: one prop
per kind on 64², within bounds, no overlap with starts/build slots, then the
full 29/29 + 17/17 + `t_render_mode` + `assert_clean` ladder and a fresh capture.

---

## 5. UNVERIFIED / BLOCKED register

1. No donor GPU A/B frame exists; no claim about matching the reference hue,
   silhouette, grain or luma is permitted (`CHARTER §3`, `G22:145-148`).
2. Donor engine blend for relief stamps (`Replace`/`ReplaceForWater`/`Smooth`,
   clamp/scale order, `−0.925` sign) has no plaintext consumer — all stamp math
   stays **PORT APPROX** (`A05:371-373`, `G07:366-368`).
3. File-row → map-row sign of the relief grids is **UNVERIFIED** (`A05:374-375`).
4. Donor surface-mesh LOD/tessellation is **UNVERIFIED** (`DTRN_02:115` C19);
   do not invent one.
5. Donor metres-per-cell / height unit is **UNVERIFIED** (`DTRN_02:116` C20,
   `:441-443`); the ≈1° slope arithmetic is derived at the **port** `TILE_M=2.0`,
   labelled PORT APPROXIMATION for donor comparison, not a donor fact.
6. `k_ravine_1` is **BLOCKED** and donor-disabled; do not add a producer, recipe
   or family for it (`G07:128-131, 371-373`).
7. Whether G22's overlay/face-collar transfer preserves pixels and avoids
   z-fighting/seams is **UNVERIFIED** until a capture (`G22:136`).
8. The `_relief_stamp_mask` write-only state and the mask-proposal's runtime
   behaviour are **OBSERVED (static)** and **UNVERIFIED (runtime)** respectively;
   no code was edited or run by this worker.

---

## 6. Summary

- Height is **really in the mesh** (`world3d_terrain.gd:1310-1312`) and its
  normals are really used (`terrain_tileindex.gdshader:294-306, 427`). The
  failure is not transport and not smoothed normals.
- The owner sees no hills because **±2.964 m is spread over 126×164 m (~1°)**,
  there is **no shadow map / AO / voxel depth cue**, the **verbatim `cDiff`
  gates cannot fire**, only **2/26 donor grids** reach height, and the donor's
  actual hill silhouette comes from **relief props the port never shipped**.
  A real generated-map frame confirms the flat-board read
  (`RELIEF_VISUAL_01.md:153-157`).
- B04's threshold forcing produced the concentric maze and was reverted; any
  fix that lowers a global height threshold or raises `HEIGHT_SCALE` inherits
  that failure.
- **Minimal donor-grounded fix:** Stage A = G07's `game.gd` relief grids
  (donor-active shapes, **PORT APPROX** blend); Stage B =
  **mask-gated face collars** in `world3d_terrain.gd` using the already-computed
  but currently unread `_relief_stamp_mask` and G22's existing donor rock art,
  with thresholds left as donor literals and the promotion rule labelled
  **PORT APPROX**. Props (Stage C) are correct but need new derived assets and
  owners; height exaggeration and shadow/AO fakery are rejected.
- **No donor parity claim.** This worker wrote only this report: no code,
  config, asset, test, shader, donor, queue or git edit; no Godot job.

*End of Z02. Read-only; one report; no runner job; no donor-parity claim.*
