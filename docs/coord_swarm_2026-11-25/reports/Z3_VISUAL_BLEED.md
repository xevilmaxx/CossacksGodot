---
id: Z3-VISUAL-BLEED
title: "Read-only render-path trace of the residual near-white pixels after MASK-ALPHA-FIX-01 (sky-strip dominated), with ranked causes and disjoint fix ownership"
agent: "Z3-TERRAIN-VIS (visual-diagnosis subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GIT_OP
scope: "Exactly one file written: this report. variant3d/ read only; app/ never opened; no donor binary access; no Godot run, queue mutation or git operation."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/Z3_VISUAL_BLEED.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed anywhere in this report."
---

# Z3 VISUAL BLEED — render-path-only diagnosis of the remaining ~7k near-white pixels

## 0. Boundary and definitions

- **observed** = literal source line, report number or artifact byte; **derived** = arithmetic/control-flow consequence of observed data; **inferred** = attribution without a pixel-aligned donor A/B; **UNVERIFIED** = not established by anything read here. No parity claim (§0 of `QA_WHITE_PIX_02.md:44-45`).
- Baseline frame: `relief_on.png.raw.png`, 1280×720, ticket 532, seed 20261113 (`WHITE_MARKS_PIX_01.md:10-14`). Post-fix frame: `maskalpha_after.png`, ticket 563, same seed/fixture (`MASK_ALPHA_FIX_01.md:138-157`). Strict near-white = `min(R,G,B)>180` (`WHITE_MARKS_PIX_01.md:73`; `MASK_ALPHA_FIX_01.md:161-162`).
- All line numbers below are **current on-disk** lines. Where the brief quotes pre-fix line numbers (`:469`, `:631/:649`), the shipped file has shifted; both are noted explicitly.

---

## 1. RENDER-PATH TRACE — `variant3d/scripts/world3d_terrain.gd` (consumer only)

### 1.1 Relief consumer: FULL donor grid for geometry; 8×10 coarse tables are opt-in and inert

- **Full-grid path (observed).** `build()` decodes the complete base64 `height[]` into `PackedFloat32Array` (`world3d_terrain.gd:1162-1193`); the mesh is one surface with `w*h` vertices at `:1240-1255`, and normals use a 1-cell stencil on that same array (`:905-906`, `:1463-1465`). The 64² dump decoded in `WHITE_MARKS_PIX_01.md:139-147` (4,096 float32, min −1.1/max +2.964) is therefore the *source* of the visible geometry.
- **Coarse path (observed).** `apply_relief_grid()` at `:465-513` reads only `RELIEF_TABLES` entries that are exactly `RELIEF_COARSE_W*RELIEF_COARSE_H = 10*8 = 80` values (`:193-194`, `:477`, `:497`) — these are the 8×10 block-mean DEBUG numbers from `DPATTERN_01_relief_grids.md:602-626`, cited at `:75-85`. It adds `coarse[gy,gx]*scale` additively with a min/max clamp (`:496-500`) and labels itself `PORT APPROXIMATION — donor engine blend UNVERIFIED` (`:457-462`, `:511`).
- **No-op for this seed (observed/derived).** The only caller is `_apply_relief_stamps_from_dump()` (`:522-557`), invoked at `:1193` gated on `dump["relief_stamps"]`. The current dump schema has no such field (`:516-524`; `main.gd:736-743` cited there), and the same-seed dump has `relief_stamps=[]` (`WHITE_MARKS_PIX_01.md:143-144`). Hence `relief_applied=0`, `_relief_applied=[]`; stamping is **not** what renders the bands.
- **What `stats.relief_grid` reports (observed).** `:1445-1458`: `label` (PORT APPROX blend), `blend_form`, `tables = ["k_ravine_1 (DPATTERN-01 A1)", "plt2 (DPATTERN-01 A2)"]`, `coarse_size=[10,8]`, `source`, `marker_field`, `applied = relief_applied`, `stamps = _relief_applied.duplicate(true)`, and `not_done = ["full 26-grid float32 tables", "mountain terrainmesh props", "exact donor engine blend", "2x collision sampler"]`. **Derived:** the stat advertises *absence* of full donor grids, not their use; geometry uses the full height[] while relief stamping uses the coarse tables only when explicitly marked.

### 1.2 tileblock → UV2 wiring and face promotion

- One uint8 per cell is decoded from `dump.tileblock` (base64 or `PackedByteArray`) or live `game.tileblock` at `:956-988` (game.gd:53, 1610-1689; main.gd:741 cited at `:956-958`). The brief's `:631/:649` are, in the shipped file, mask-texture binding (`_repack_mask_alpha` calls at `:629-633`), not tile wiring.
- Per cell: `raw_tid` → `water_sentinel` (`raw_tid > max_tile_id`) → `shore_gate` (`water_sentinel or height[i] < DONOR_SHORE_H`) at `:1245-1272`; `UV2 = Vector2(float(tid), float(face))` at `:1350`, uploaded as `Mesh.ARRAY_TEX_UV2` at `:1368`. The donor **mask-B shore test** (`texturemap.inc:464`) is explicitly not readable here → the gate is `PORT APPROX` (`:1303-1306`).
- **Face promotion (observed).** `_face_mode_at()` at `:746-768` applies donor `cDiff1=0.5` on 4 axis neighbours and `cDiff2=0.55` on the diagonal (constants `:153-162`, texturemap.inc:63-64/116-129 cited at `:735-736`), then picks mode 1/2 by dominant gradient. `:1275` suppresses promotion on water/shore cells; `:1283-1297` re-selects a donor cliff/block name; the vf/vs promotion rule itself is `UNVERIFIED` (`:742-745`, `:1280-1282`). Flat cells stay mode 0. The shader consumes this as `v_face` (`terrain_tileindex.gdshader:325`) selecting a *second mask sampler* only — it never changes RGB albedo source (`:397-412`).

### 1.3 Water plane, sun/sky rig (render-only)

- Water is a single height-aware module (`:1402-1406`); its plane is 4 vertices spanning exactly the same 128×128 m extent as the ground (`water3d.gd:213-221` vs `world3d_terrain.gd:1253-1255`). Fallback quad exists but is not stacked (`:1402-1406`).
- Sky is `ProceduralSkyMaterial` with donor horizon/top colours (`:1065-1079`; constants `:142-147`), sun is `DirectionalLight3D` with `shadow_enabled=false` (`:1092-1113`). Terrain material is `unshaded` so it receives no Godot lighting/shadow (`:1395-1398`; shader `:31-43`, `:180-182`, bound OFF at `:698-699`). Donor light axis is identity Y-up per `LIGHT_02_light_space.md:13,159-159,224-226`; the shader applies `normalize(vec3(P.x,P.y,P.z))` at `:294-296` with the raw sun bound at `:694`. **No sim change is implicated by this trace.**

---

## 2. FULL SHADER READ — `variant3d/shaders/terrain_tileindex.gdshader`

### 2.1 Alpha path, then vs now

| Stage | Current line | Pre-fix line (MASK_ALPHA_FIX_01) | Status |
|---|---|---|---|
| `render_mode blend_mix, unshaded, cull_disabled` | `:43` (choice justified `:27-42`) | unchanged | **observed**; one pass, no donor second base pass (`DTRN_01` C17 cited at `:27-29`, `:237-238`) |
| `mask_to_alpha = 1.0` knob | `:235-246` | `:235` | **observed**; shipped value deliberately kept (`MASK_ALPHA_FIX_01.md:224-226`) |
| 8×4 patch decomposition | `:365-378` | `:338-375` (brief) | **observed**; `dir=mod(id,4)`, `variant=mod(id/4,4)`, `half=mod(id/16,2)`, `opposite=mod(id/64,2)`, `cell=(half*4+variant,row)`, inset `clamp(local,0.0078125,0.9921875)`, `((c+u)/8,(r+v)/4)` |
| `.a` sample | flat `:419`; face `:412` | `:417` (brief) | **observed**; mask repacked R→A by `world3d_terrain.gd:652-665` |
| Mask applied | `rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular` at `:427` | `rgb = rgb*v_packed + v_specular` | **observed**; mask now an RGB albedo factor |
| Framebuffer alpha | `ALPHA = 1.0` at `:475` | `ALPHA = mix(1.0,a,1.0) == a` at old `:469` | **observed**; OPAQUE now, sky bleed closed at source |

**Derived consequence of the fix:** under `blend_mix`, `dst = src.rgb*1 + dst.rgb*(1-1)`, so *terrain can no longer expose the clear colour at any mask value*. The observed −84.252 % drop (44,381→6,989) and elimination of all exact cyan below `y=12` (`MASK_ALPHA_FIX_01.md:164-177`) are the expected measurement of that one-line change.

### 2.2 Every alpha<1.0 path in the current render — and where sky-cyan can/cannot appear on land

1. **Constant patches `(0,0)/(4,0)=255`, `(3,3)/(7,3)=0`** — donor-authored sentinels (`DALPHA_01_alpha_subrect.md:443-444,575-576`). They are now *reachable* by the decomposition (`DALPHA_02_patch_mapping.md:156-159`; shader `:366-377`): e.g. tile id 80 (`test9`) → `(7,3)` full cut. **Pre-fix** this wrote `ALPHA=a=0` → exact sky on land (old `:469`); **shipped** it multiplies RGB by 0 at `:427` and writes `ALPHA=1` at `:475` → **dark olive/specular cell, never sky**. Sentinel-vs-unused-slack role remains `UNVERIFIED` (`DALPHA_01:634-635`).
2. **Feather/graded seams** — 28 non-constant 64² patches span 0…255 with 234–251 levels and seams at x/y multiples of 64 (`DALPHA_01:413-444,559-567`); the half-texel inset at shader `:376` avoids edge sampling. No neighbour direction exists in `UV2` (`DALPHA_02:149-152`; shader `:358-364`), so adjacent cells can pick non-complementary patches → tone steps (MAD 9.77–17.6, `DALPHA_01:455-473`). **Post-fix** these steps are RGB brightness steps only; they cannot render cyan.
3. **Water-band overlap** — `water3d.gdshader:246,260` writes `ALPHA = coastfade2*water_cell` (0 at waterline, 1 at 1.07 m); `water_overlay.gdshader:276` likewise `alpha=coverage*coastfade2`. Both are `blend_mix` over the **now-opaque** terrain (shader `:475`). Water colours are dark (`water3d.gd:79-87`) and the reflection map is a neutral alpha-0 1×1 (`water3d.gd:209`), so a bright exact-cyan pixel from water is **not supported** (matches `WHITE_MARKS_PIX_01.md:183` LOW/REFUTED). Partial water/sky blend at the map edge is `UNVERIFIED`.
4. **Sky-strip below terrain** — the ground mesh is finite (`world3d_terrain.gd:1253-1255`); outside it the clear colour/sky shows. **Observed:** after the fix there are **zero** exact-cyan pixels for `y≥12` (`MASK_ALPHA_FIX_01.md:169-170`), so no instance occurs in this frame. Whether any partial blend exists at the horizon is `UNVERIFIED` (no depth buffer in the artifact, `MASK_ALPHA_FIX_01.md:244-246`).
5. **Legitimate sky strip `y<12`** — not a terrain leak at all. 6,825 of 15,360 strip pixels were exact cyan before (`WHITE_MARKS_PIX_01.md:90`); after the fix all 6,571 remaining exact-cyan pixels lie there (`MASK_ALPHA_FIX_01.md:168-177`). Colour equals the frame corner `p00=(0.7137,0.9137,1.0)` sky constant (`world3d_terrain.gd:146,1072-1077`; `QA_WHITE_PIX_02.md:102`).

**Answer to "which exact lines allow background/sky colour on land cells":** **none in the shipped terrain shader** — old `:469` was the only such line and is replaced by `:475`. Pre-fix the sky path was `alpha_patch_uv :365-378` → `.a :419` → `ALPHA=mix(1.0,a,1.0)` (old `:469`) with `dst=sky`; that mechanism is CONFIRMED at source level but its pixel attribution was INFERRED (`MASK_ALPHA_FIX_01.md:48-61`). The remaining sky-cyan is background, not land.

### 2.3 Tile→patch rule and unshaded/shadow-OFF rationale

- The rule is a **PORT APPROXIMATION, CONFIRMED_UNVERIFIED** (`shader:345-364`; `DALPHA_01:545`; `DALPHA_02:12,140-143`): one `UV2.x` tile id is decomposed into direction/half/variant/opposite stand-ins; no donor enum readable (`DALPHA_01:625-628`).
- `unshaded` is a **port render-mode decision, not a donor value** (`:31-38`): the shader itself reproduces donor per-vertex Blinn-Phong + PCF + fog (`:274-326`, `:422-466`), so Godot must not shade ALBEDO twice. Shadows are OFF by explicit prior A/B (`:38`, `:180-182`, `world3d_terrain.gd:698-699`; `TERRAIN_DARK_FIX.md:112,217`; `LIGHT_02_light_space.md:271`). World-XZ texgen at 2 m/cell uses `eye_plane_s/t`, `texture_matrix`, `v_st`, `uv_repeat=0.5` (`:120-122`, `:214-218`, `:311-316`), donor-grounded by `gc_meters_to_tile=2` but engine values `CONFIRMED_UNVERIFIED` (`:112-118`; `world3d_terrain.gd:1480-1484`).

---

## 3. DALPHA-01/02 — what remains UNVERIFIED and the smallest donor-grounded next step

**Still UNVERIFIED (all observed as labels):**
- Exact `tile_id + boundary_direction → patch` rule: `CONFIRMED_UNVERIFIED` (`DALPHA_01:16,545,658-661`; `DALPHA_02:141-143`). Proof of absence: 17,237-file scan, 11 binaries × 3 encodings, packed `.bind`, UV from `gl_MultiTexCoord1` (`DALPHA_01:501-547,611-614`).
- No neighbour-direction input in the port vertex stream; corner-vs-full-edge role not separately encoded (`DALPHA_02:149-152`; shader `:358-364`).
- Complement structure only PARTIAL: graded MAD 9.77–17.6 left half, 18–84 right (`DALPHA_01:455-473,654-657`; `DALPHA_02:153-155`).
- Sentinel-patch role vs unused atlas slack (`DALPHA_01:634-635`); two-half equivalence INFERRED (`DALPHA_02:162`); `TileXOffset/TileYOffset` effect UNVERIFIED (`DALPHA_01:587,625-628`); `bmTransparency` multi-pass blend factors UNVERIFIED (`DALPHA_01:638-639`); no donor GPU A/B (`DALPHA_02:163-164`).

**Smallest donor-grounded next step (proposal only, NOT run):** resolve the *source* of `gl_MultiTexCoord1`: unpack the packed `.bind` or take a read-only donor GL trace of the patch UVs for **two adjacent known tile ids** (`DALPHA_01:625-628`), which is the single observation that can promote item 5 from CONFIRMED_UNVERIFIED to RESOLVED. This agent has no donor access, so it cannot do it. Port-side, the smallest *diagnostic* is to exercise the existing `mask_to_alpha` knob at identical camera (0 = flat opaque, 1 = shipped RGB mask modulation; `shader:235-246`, `MASK_ALPHA_FIX_01.md:237-239`) and record near-white/bbox/luma — no new patch rule should be guessed.

---

## 4. Ranked cause table — remaining 6,989 near-white pixels (NOT the fixed 84.252 %)

After-frame decomposition (**derived** from `MASK_ALPHA_FIX_01.md:164-177`): 6,989 total; 6,571 exact cyan, **all** at `y<12`; 55 near-white at `y≥12`; hence 6,934 near-white in the sky strip and 418 non-exact-cyan overall (363 in strip + 55 below).

| Rank | Cause | Count / label | Exact file:lines + mechanism | Why tile-art is refuted for cyan | Minimal next fix + verification |
|---:|---|---|---|---|---|
| 1 | **Rendered sky strip (legitimate background)** | **6,934 px = 99.2 % of remaining**; observed + derived | `world3d_terrain.gd:142-147,1065-1079` (donor sky colours, mapping PORT APPROX), `:149` exposure; pixel = `p00` (`QA_WHITE_PIX_02.md:102`); `MASK_ALPHA_FIX_01.md:168-177` (all 6,571 exact cyan at `y<12`) | `(181,234,255)/(182,233,255)` occur **0** times in all 112 `blocks/*.png` (`QA_WHITE_PIX_02.md:98`); all summer DDS mid-tone, `minRGB>180 = 0 %` (`MASK_ALPHA_FIX_01.md:46`) | **No terrain fix** — any change to donor sky colour would be an invention. Metric should exclude `y<12` as background. Verify by measuring the strip and ground separately in the same PNG. |
| 2 | **Sky-gradient / tone-mapped cyan neighbours inside strip** (e.g. `(181,233,255)`, `(176,232,248)`) | **~363 px**, inferred | `QA_WHITE_PIX_02.md:109-112` (top-3 palette; remainder buckets); `WHITE_MARKS_PIX_01.md:93` | Same zero-occurrence/CIELAB evidence (`QA_WHITE_PIX_02.md:113-119`, 97.28 % nearest `winter0` at ΔE≈17) | Same as rank 1; no rendered-colour model has been fitted (`WHITE_MARKS_PIX_01.md:229`) — record as UNVERIFIED, do not invent a correction. |
| 3 | **Below-sky residual 55 px: partial RGB mask fold / AA / tone map** | **55 px**, UNVERIFIED split | shader `:412/:419` sample, `:427` fold, `:475` opaque; `MASK_ALPHA_FIX_01.md:170,240-242` | 7 px nearest `rock4` among 44,381 pre-fix (`QA_WHITE_PIX_02.md:132`); no exact block cyan | Capture at identical camera with `mask_to_alpha` 0 vs 1; compare near-white below `y≥12`, bbox and luma. If 55→0, RGB fold is the cause; if unchanged, AA/tone map. |
| 4 | **Water-band alpha overlap at the waterline** | subset of rank 3 (≤55), LOW | `water3d.gdshader:246,260`, `water_overlay.gdshader:276`; blend over opaque terrain (shader `:475`); plane extent `water3d.gd:213-221` = ground `world3d_terrain.gd:1253-1255`; dark water colours `water3d.gd:79-87` | Water constants cannot emit exact sky cyan (`WHITE_MARKS_PIX_01.md:124-128`, `:183`) | Water-plane hide A/B at fixed camera (`WHITE_MARKS_PIX_01.md:206-209`); water file has a separate owner — not bundled with the terrain fix. |
| 5 | **Terrain tile albedo (`test*`/`rock*`)** | REFUTED for cyan; UNVERIFIED only for ≤55 px | old attribution `TERRAIN_MARKS_01.md:100,120-124`; refutation `QA_WHITE_PIX_02.md:98,113-119`; `PALE_TILES_DEEP_01` §2 cited at `MASK_ALPHA_FIX_01.md:46` | ΔE76 53.05/33.62/31.84 from `test8`/`rock4`/`sandsea1`; quoted bright colours 0 occurrences (`QA_WHITE_PIX_02.md:98-100`) | No tile-art change; fix would violate the "do not chase albedo" mandate (`MASK_ALPHA_FIX_01.md:23-26`). |
| 6 | **Relief stamps** | REFUTED for this seed | `world3d_terrain.gd:522-557,1193` (no marker → no-op); `relief_stamps=[]` (`WHITE_MARKS_PIX_01.md:143-147`) | Stamps write `height[]` only (`:465-513`), never colour | None. |
| 7 | **Sky visible past the finite ground edge below terrain** | UNVERIFIED, 0 observed instances | ground extent `world3d_terrain.gd:1253-1255`; `MASK_ALPHA_FIX_01.md:169-170` (0 exact cyan below `y=12`) | — | Orthographic/top-down capture to test cell-by-cell (`WHITE_MARKS_PIX_01.md:210-214`) if a horizon symptom ever appears. |

**Note on a new, non-near-white symptom (observed/inferred):** pinning `ALPHA=1` makes the constant-0 sentinel patches render near-black (`rgb·0 + v_specular` at shader `:427`, with `specular_rgb` bound to `DONOR_SPECULAR` at `world3d_terrain.gd:690`), i.e. the bright bands became dark steps (`MASK_ALPHA_FIX_01.md:178-179,232-236`). This is a *darkness* question, not a near-white cause; any floor value would be an invented constant and is `UNVERIFIED` (`MASK_ALPHA_FIX_01.md:234-236`).

---

## 5. Minimal next fix, pixel-level verification, and disjoint ownership

### 5.1 Minimal fix proposal (NOT applied by this agent)

Keep `ALPHA = 1.0` (shader `:475`) — the one donor-grounded, measured improvement (`MASK_ALPHA_FIX_01.md:251-270`). The only *remaining* actionable work is diagnostic, not a new rendering rule:

1. **Shader owner:** expose the existing `mask_to_alpha` knob (`:235-246`) as an A/B pair at identical camera: value `1.0` = shipped RGB mask modulation (`:427`), value `0.0` = flat opaque terrain. No new patch rule, sampler, floor or art. This isolates ranks 3–5 without touching geometry.
2. **Terrain-gd owner (separate):** add *dump-only* per-cell provenance (neighbour tile ids / derived boundary direction already available from `_tile_indices`, `:959-993`, and `height`, `:746-768`) so a future patch-rule A/B can be scored per cell. **No `UV2` change** in this step (mesh invariants `:94-95` preserved).

### 5.2 Pixel-level verification protocol (per `CAPTURE_RECHECK.md`)

- **Capture integrity (observed requirements):** windowed (no `--headless`), seed 20261113, 64² fixture, fixed camera (explicitly **identical camera x/y/z and target** — the prior A/B differed by 1.352 m in camera x: `MASK_ALPHA_FIX_01.md:181-186`), 1280×720, ~10 frames, runner only (`CAPTURE_RECHECK.md:56-60`); `stats` inspector is qualitative (`CAPTURE_RECHECK.md:82`); `scan-stderr` must give `script_error_lines: 0` (`CAPTURE_RECHECK.md:59`).
- **Measure before/after in the SAME PNG set** (read-only Pillow/NumPy, outside repo): strict near-white count and fraction of 921,600; bbox; Rec.709 luma min/max/mean; exact-cyan `(181,234,255)+(182,233,255)` count **split at `y=12`**; near-white count below `y≥12`; `minRGB>200`; and, if camera is truly registered, per-pixel delta + 4×4 cell grid (`WHITE_MARKS_PIX_01.md:78-93`). Reference numbers: before 44,381 / bbox (0,0)-(1279,719) / 0.0,253.845,115.039 / 39,569 cyan; after 6,989 / 0.0,253.628,79.256 / 6,571 cyan with 0 below `y=12` (`MASK_ALPHA_FIX_01.md:164-173`).
- **Second-agent rule:** the re-checker must be a different agent than the builder, must open the PNG (metrics never override visual judgement), and must record "what the image shows" and "atom assertions satisfied" separately (`CAPTURE_RECHECK.md:34-36,91,237-238`). **PORT APPROX only; no donor parity.**

### 5.3 Disjoint file ownership — ONE builder each (no shared file)

| Builder | Sole writable file | Allowed change | Forbidden |
|---|---|---|---|
| **A — shader owner** | `variant3d/shaders/terrain_tileindex.gdshader` | Keep `:475` opaque; expose/-toggle `mask_to_alpha` knob for the 0 vs 1 diagnostic A/B; retain all APPROX labels (`:236-246`, `:345-364`) | No `.gd`, asset, config, test or report of B; no new patch rule, sampler, floor, art or donor claim |
| **B — terrain-gd owner** | `variant3d/scripts/world3d_terrain.gd` | Dump-only neighbour/direction provenance around `:959-993`, plus stats note near `:1445-1458`; bind the A/B uniform value only if A has published its exact uniform name | No shader edit, no `UV2`/mesh/topology/water/light change, no sim change |
| **C — verifier (second agent)** | only `reports/RECHECK_*.md` (outside this report) | Capture re-check + pixel measurement per §5.2 | No code edit, no runner submission by this read-only agent |

Sequencing: A publishes the uniform name; B binds it by name; C measures. Files stay disjoint at every step. `app/` untouched throughout.

---

## 6. Open questions (UNVERIFIED — do not guess)

1. Exact split of the 55 below-sky near-white pixels among RGB-mask fold, AA/tone map and water partial blend — no registered capture exists (`MASK_ALPHA_FIX_01.md:240-242`).
2. Whether the same-seed dump at an identical camera x would change 6,989 by more than the strip count — previous A/B was frame-wide only (`MASK_ALPHA_FIX_01.md:181-186`).
3. Donor-faithful target luma after the mask fold is unknown; the earlier `mask_to_alpha=0` A/B darkened the frame (42.735→38.425) before the fix (`world3d_terrain.gd:702-709`; `MASK_ALPHA_FIX_01.md:224-226`).
4. Exact tile→patch rule, sentinel role, complement quality and `bmTransparency` compositing remain `CONFIRMED_UNVERIFIED` (§3); no donor GPU A/B exists.
5. Whether any sky-coloured pixel lies outside `y<12` at the finite ground edge — 0 observed in this frame (`MASK_ALPHA_FIX_01.md:169-170`).

---

## 7. Summary

**Read-only render trace, no parity claim.** The terrain consumer uses the **full** 64² donor height grid for geometry (`world3d_terrain.gd:1162-1193,1240-1255`); the 8×10 tables are opt-in, marker-gated and inert for this seed (`:465-513,522-557,1193`), and `stats.relief_grid` (`:1445-1458`) explicitly lists the full 26-grid tables under `not_done`. `tileblock`→`UV2` is `:956-988` → `:1245-1272` → `:1350/:1368`; face promotion uses donor cDiff1/cDiff2 at `:746-768` with the promotion rule UNVERIFIED.

In the **shipped** shader the only line that could put sky on land was the pre-fix `ALPHA=mix(1.0,a,1.0)` (old `:469`); it is now `ALPHA = 1.0` (`:475`) with the mask folded into RGB (`:427`). Constant sentinels, feather seams and the water band can no longer expose the clear colour; the sky strip is background, and zero exact cyan remains below `y=12` (`MASK_ALPHA_FIX_01.md:169-170`). Of the remaining 6,989 near-white pixels, **6,934 (99.2 %) are the sky strip**; 418 are non-exact-cyan (363 in strip, 55 below), all UNVERIFIED as to fine mechanism. Tile-albedo attribution is refuted for cyan (`QA_WHITE_PIX_02.md:98,113-119`), relief stamps refuted for this seed. The smallest donor-grounded next step is to resolve `gl_MultiTexCoord1` patch UVs from donor-side data (`DALPHA_01:625-628`), plus a same-camera `mask_to_alpha` A/B measured per `CAPTURE_RECHECK.md`. Disjoint ownership: shader→A, terrain gd→B, verification→second agent C.

---

*End of Z3 VISUAL BLEED. Read-only on repo; no runner job; no donor access; no git operation; PORT APPROXIMATION throughout; no donor parity claim.*
