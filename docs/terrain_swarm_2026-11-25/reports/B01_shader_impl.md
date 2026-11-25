---
id: B01
ticket: TERRAIN-SWARM-2026-11-25 / B01 (implementation, exclusive shader owner)
date: 2026-11-25
status: IMPLEMENTED_NOT_RUN
labels: [observed, derived, inferred, PORT APPROXIMATION, UNVERIFIED]
file_owned: variant3d/shaders/terrain_tileindex.gdshader
backup: inbox/backup/terrain_tileindex.gdshader.bak-B01
backup_sha256: 98671F38946EEF0D23AB1DB49DD4EE9CF1530DD54A3F700D16E6B7CFD5CC6034
gates_run: NONE (per ticket — COORD runs Godot / runner jobs)
---

# B01 — terrain shader anti-tiling / anti-blotch implementation

## 1. Scope and stance

Only `variant3d/shaders/terrain_tileindex.gdshader` was edited (plus this report and the
pre-edit backup). No Godot process was started and no runner job was submitted.

**No donor parity is claimed.** Every new behaviour is labelled `B01 PORT APPROX` /
`A02-P1 PORT APPROX` / `A02-P4 PORT APPROX` in the shader itself. Structural donor evidence
is cited with its read-only path:line; the runtime eye-plane/texture-matrix values, the
alpha patch-selection rule, metres-per-cell and all blend semantics stay
CONFIRMED_UNVERIFIED (A08 §1/§2/§8, RV-TRN-01 A–D, DALPHA-01 §5, DALPHA-02 §5). No donor
GPU A/B frame exists (CHARTER §3), so all visual claims below are **predictions [D/I]**,
not observations.

Guardrails honoured: no dither/Bayer/quantiser/synthetic luminance or noise "beauty" field
(CHARTER §3 decision S-25-09; A08 §7 #2; F04 P0-3); no anisotropic parity claim (A08 §7 #4);
no new invented donor constant; mesh/topology/UV2 semantics, `atlas_grid`, sampler count and
names, shadow-off decision, donor sun/water literals, all test markers, and the published
`:476` A/B comment block were not touched.

## 2. Reports read before acting

CHARTER.md (all); A02_alpha_pattern.md §1/§2/§4 (P1/P2/P4); A06 (did not exist at edit time —
`docs/terrain_swarm_2026-11-25/reports/` contained no A01/A02/A06 when first opened; A02
landed mid-task and was read before the mask edit); A08_donor_truth_local.md §1, §2, §7, §8;
A10_regression_constraints.md §4; F04_quality_reviews.md §4 #13, §5 P0-1..P0-4;
F05_online_vs_local.md CORRECTIONS row 44 via COORD; coord_swarm_2026-11-25/TEST_MATRIX.md
T0–T5.

## 3. Exact diff summary

Total file length is unchanged: **502 lines before, 502 after**. All edits are
line-count-neutral so every cited anchor keeps its number — in particular `:60`, `:235`,
`:365-378`, `:392`, `:419`, `:427`, `:475`, `:476` and the whole `:478-502` A/B block.

Git diff (`git diff -- variant3d/shaders/terrain_tileindex.gdshader`) has three hunks:

### Hunk 1 — `:52-60`, tile_atlas filter hint (1 behaviour line + 6 comment lines)

- `uniform sampler2D tile_atlas : filter_nearest_mipmap, repeat_enable;`
  → `uniform sampler2D tile_atlas : filter_linear_mipmap, repeat_enable;`
- Sampler **name `tile_atlas` unchanged**; hints `repeat_enable`, and the hints on
  `alpha_atlas` (`:66`), `alphavert_atlas` (`:72`) and `shadow_map` (`:83`) are unchanged.
- Comment rewritten in place: donor `maNearest`/`miNearestMipmapLinear` citation
  (`reftile.mat:29-37`) and `reftilealpha.mat:29-36 / :138-146` retained; new text carries
  `B01 PORT APPROXIMATION`, `F04 §5 P0-4`, `Charter §2 item 3`, and `A08 §7 #4`.
- The old `// ----` separator on line 59 was folded into the new comment; no path:line
  citation was dropped.

### Hunk 2 — `:328-338`, `tile_rgb()` (4 comment lines → 1; function body rewritten)

- Comment compressed but all labels kept: `PORT APPROX`, `TERRAIN2-06 §3.2`,
  `reftile.lib:3-12`, `UV2.x`, `presets_summer.json:2-125`.
- `float col` / `float row` merged into `vec2 cell` (same id→atlas-cell arithmetic as before:
  `col = mod(idx, cols)`, `row = floor(idx / cols)`, `cols = max(atlas_grid.x, 1.0)` PORT GUARD).
- **REVISION (owner verdict on `g04/p0_64.png`, §9): the per-cell mirror variant described
  in the original implementation was REMOVED.** `key`, `v`, `f` and the `mix(..., 1.0-..., f)`
  are no longer in the shader — an axis-aligned 2 m flip lattice read as a chessboard.
- New (final state): `vec2 warp = 0.125 * vec2(sin(dot(v_st, vec2(0.13,0.07))), cos(dot(v_st,
  vec2(0.09,0.11))))`, then `uv = mix(inset, 1.0-inset, fract(local_uv + warp))`. This is a
  continuous, low-frequency **UV** warp (F04 P0-1 wording), not a colour/luminance field and
  not a lattice variant. A06's half-texel inset (§8) keeps it inside the atlas cell.
- `textureGrad(...)` with unwrapped derivatives keeps the donor call shape
  (`hf.pvl.smx3.frag:13`) and the exact `(cell + local_uv)/atlas_grid` packing (A06-F2, §8).
- **`:392` is byte-identical**: `vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));`
  (so the A/B block's "albedo (:392) remains untouched" stays literally true).

### Hunk 3 — `:398-419`, fragment face/flat mask branch (comment compression + guard)

- Face branch comments compressed to 6 lines; **face-branch code is byte-identical**
  (`mask_uv` from the recovered donor eye planes, `reftile.mat:130-141/:156-167`,
  scale `:124-126/:150-152`, `world3d_terrain.gd:57-58`, `TERRAIN2-01 §2.5` INFERRED,
  `PORT APPROX` axis swap). `a = texture(alphavert_atlas, mask_uv).a;` unchanged.
- Flat branch: original 5 comment lines compressed to 2; all citations kept
  (`reftile.mat:6/:17/:39-50`, `UNVERIFIED`, `64² sub-rect`, pointer to `:365-378`).
- **A02-P1 SENTINEL GUARD [mandatory]** added after the same `a = texture(alpha_atlas,
  alpha_patch_uv(v_tile, v_alpha_uv)).a;` line, using the *same* id decomposition as
  `alpha_patch_uv` (`id=floor(abs(tile))`, `dir=id mod 4`, `variant=(id/4) mod 4`,
  `half=(id/16) mod 2`, `opposite=(id/64) mod 2`, `row/variant` mirrored by `opposite`):
  `step(2.5, scol) * step(2.5, srow)` is 1 only for atlas patches `(3,3)`/`(7,3)`,
  the donor-authored constant-0 sentinels (DALPHA-01 §6.4; A02-E4 mean 0/255,
  A02 §2 8/124 ids incl. 15 `grass_ground2`, 31 `sand6`, 63/64 `rock6vf/vs`).
  Those ids now get `a = 1.0` instead of `a = 0.0` → no pure-black cells/cliff faces.
  Implemented inline rather than by changing `alpha_patch_uv`'s signature so that
  `:365-378` (and the A/B block's "patch decomposition (:365-378) remains untouched")
  stays byte-identical.
- **A02-P4 contrast compression [recommended by COORD]**:
  `a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, sentinel)`.
  Non-sentinel masks are clamped at 0.35 and blended 50 % toward 1.0 (final factor
  ∈ [0.675, 1.0]); sentinel masks bypass to 1.0. Keeps the donor-grounded patch shape,
  removes the near-black tail (A02 §4 P4, A02 §5 item 3).
- **`:427` is byte-identical**: `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;`
  — only the value of `a` changed, not the published formula or either endpoint.
- **No border-band mask was added.** The original ticket suggested confining mask
  influence to tile borders; A02 Q4 warns that with one tile id per cell this draws a
  "2 m grid of dark lines", and COORD's follow-up explicitly recommended P4 instead.
  Deviating from the earlier suggestion is deliberate and cited (A02 Q4 warning #2).

## 4. Rationale per change (observed / derived / inferred, with citations)

| # | Change | Grounding | Label / confidence |
|---|---|---|---|
| 1 | Continuous low-frequency UV warp in `tile_rgb` (per-cell mirror **removed** after owner verdict, §9) | Charter §2 #1 [O] 2 m verbatim `fract()` repeat → diagonal streaks; F04 §5 P0-1 [I] "no cell copied verbatim on a fixed lattice"; A08 §1 [O] donor variety is *tile identity* (grass1..10/test7/8/9/12/14 families, 124 ids) not a luminance overlay. We do **not** change tile ids (B03's domain) or luminance; we change only the within-cell sampling transform, which A10 §4 calls SAFE ("changing how a within-cell colour is computed without changing which cell is sampled"). `uv_repeat`, `fract(v_st*uv_repeat)` at :392, UV2 semantics and id→index mapping are untouched. The mirror was rejected by the owner as a chessboard (§9); if the 2 m repeat returns, the fix is B03 tile-ID diversity, not another lattice variant. | **PORT APPROXIMATION**; effectiveness [D/I], needs COORD visual gate |
| 2 | `filter_linear_mipmap` on `tile_atlas` | Charter §2 #3 [O] nearest magnification + `fract()` banding; F04 §5 P0-4 [I] fix sampling at texture/shader level, not post-process AA; F04 §4 #13 gameGPU "AA has virtually no effect"; A10 §4 SAFE (no structural check reads the hint). Donor values `maNearest`/`miNearestMipmapLinear`/`tfIsotropic` remain cited and unchanged on the donor side; linear magnification is a **port-only anti-banding substitute**, not a donor value. No anisotropic claim (A08 §7 #4). Masks stay `filter_nearest` per `reftilealpha.mat:29-36/:138-146`. | **PORT APPROXIMATION**; visual improvement [I] |
| 3 | A02-P1 sentinel bypass | A02 §2 [O]+[D]: 8/124 ids select constant-0 `(3,3)/(7,3)` → `a=0` → :427 `rgb=v_specular` = **pure black** (flat `specular_rgb=0` at :160-163), incl. the promoted cliff faces `rock6vf/vs`. DALPHA-01 §6.4 [O] authored sentinel roles. Hard defect, so guarded unconditionally (independent of `mask_to_alpha`). | **PORT APPROX MITIGATION** (A02-P1); defect [O]+[D] |
| 4 | A02-P4 contrast compression | A02 §2 [D]: 19 ids darkened to a≈0.18–0.23, 11 to ≈0.29–0.33, only 7 ids get a=1 → "flat dark olive". A02 §4 P4 [I] reduce dynamic range instead of adding noise; COORD follow-up recommends P4 over the border-band grid risk. | **PORT APPROX ART** (A02-P4), no donor value claimed |
| 5 | No border-band mask | A02 Q4 [D] warns a 2 m border band draws a grid of dark lines and cannot crossfade without a neighbour sample; COORD follow-up: "P4 … instead of full border-band grid risk". | Deliberate omission, cited |
| 6 | Line-count neutrality | A10 §4 DO NOT TOUCH "the `:476` line-number-preserving comment block"; A/B block :478-502 states "Every cited line above keeps its number". | Verified (§6 below) |

## 5. Risks and open questions

1. **[I] Visual outcome unverified.** No Godot run by B01 (ticket forbids it); the owner
   verdict on `g04/p0_64.png` is recorded in §9. The continuous warp and
   linear-minification hint may shift luma or introduce a larger-period pattern; warp
   periods are ≈48–90 m from the 0.13/0.07 and 0.09/0.11 radians/m frequencies.
2. **[I] Atlas-cell bleed.** `fract()` in `tile_rgb` still wraps at a cell edge; linear
   filtering can touch an adjacent atlas cell. This is now guarded by the A06-F2
   half-texel inset (§8), derived from `textureSize(tile_atlas,0)/atlas_grid`.
3. **[I] 2 m repeat may return.** With the chessboard mirror removed (§9) the verbatim
   2 m RGB repeat can become visible again. **Do not reintroduce a lattice variant** —
   hand it to B03 (`game.gd`) as tile-ID diversity, the donor-grounded mechanism (A08 §1).
   The `fract()` maps both 0 and 1 to the same phase, so the shared cell edge stays
   continuous; donor seam continuity was not measured (A08 §1 #5).
4. **[I] P4 tonal change.** `a` now lies in [0.675, 1.0] for non-sentinels, so previously
   dark transition cells brighten. This should help the `>=40`/`>=100` luma floors and
   `full_width_dark_rows == 0`, but COORD must re-check `non_black_fraction`,
   `ground_mean_luma`, `ground_max_luma` and dark rows/cols in P0/C4/season (A10 §4).
   Do not tune a threshold to compensate.
5. **[I] T1/T3 comparisons.** TEST_MATRIX T1 "ground texgen unchanged vs T0" and T3
   "ground unchanged outside mine bbox" compare runs of the *same* shader version; the
   shader changed for all rows equally, so the comparisons should remain valid, but this
   is a prediction, not a measurement.
6. **[U] No donor parity.** Donor eye-plane values, patch-selection rule, blend pass
   count and metres-per-cell stay CONFIRMED_UNVERIFIED; nothing here recovers them.
7. **[I] Sentinel guard is a mitigation**, not the structural fix. The correct donor-shaped
   solution is P5 (mask only where neighbouring tile ids differ) which needs a data
   handoff and is outside this file/ticket.
8. **[D] Interpolated tile id** steps mid-triangle (A02 §2 amplifier) — untouched: it is a
   mesh/contract issue (B04's file). The sentinel flag uses the same `floor(abs(v_tile))`
   as `alpha_patch_uv`, so it stays consistent with the patch it guards.
9. **Bounded scope.** P0-3 (large-scale grass colour field) and P1 relief/shore are not in
   this file; per A08 §1 and COORD, mottling should come from tile identity (B03) and
   donor relief, never from a shader colour field. **A clean hook is left**: `tile_rgb()`
   still takes the tile index `idx` and still samples exactly the cell `idx` selects, so
   B03 can vary tile ids without touching this shader.

## 6. Self-check — uniform / contract / anchor integrity

Performed by comparing the backup with the edited file (PowerShell `Get-Content`, exact
`-ceq` comparison; results):

- **Total lines: 502 → 502.** No shift of any cited line.
- **Uniform declarations: 31 → 31, same order, same names.** The only textual difference
  in the entire uniform set is the filter *hint* on `tile_atlas`
  (`filter_nearest_mipmap` → `filter_linear_mipmap`); the identifier `tile_atlas` is
  unchanged. **No uniform was renamed, removed or added.**
- Byte-identical anchor lines verified: `:235` (`uniform float mask_to_alpha = 1.0;`),
  `:365`, `:378` (whole `alpha_patch_uv` body :365-378), `:392` (albedo call),
  `:427` (mask fold), `:475` (`ALPHA = 1.0;`), `:476`, and every line of the
  `:478-502` A/B comment block including `:492`/`:495` endpoint definitions and `:498`.
- **A/B contract intact:** both endpoints are still the *same* compiled program;
  `mask_to_alpha = 0.0` → `mix(1.0,a,0.0) == 1.0` → flat opaque `rgb*v_packed+v_specular`,
  `ALPHA=1.0`; `mask_to_alpha = 1.0` → shipped mask-modulated path with `a` now
  sentinel-safe and contrast-compressed. No second variant, sampler, patch rule or
  branch was introduced. Binding name remains the exact string `mask_to_alpha`.
- **Samplers:** four names (`tile_atlas`, `alpha_atlas`, `alphavert_atlas`, `shadow_map`)
  unchanged; `atlas_grid`, `shadow_enabled=0`, donor sun/ambient/diffuse/specular
  literals, fog and eye-plane uniforms untouched.
- **Guardrails:** no `dither`, `noise`, `hash` texture, Bayer matrix or synthetic luminance
  term added to colour math; no donor-parity sentence added; no test marker or threshold
  edited; no other file modified by this agent.
- **Process:** backup created *before* the first edit; no Godot process and no runner job
  started by B01. All gates remain COORD's responsibility.

## 7. Follow-up: A11_reference_metrics.md (read after implementation)

A11 key findings **[O]/[D]**, read after the edits were already in place:

- `BV32 n640` 8.7 vs reference median 247.6 (≈28.6x deficit), deficit present at every
  scale 8–64 px → no coherent low-frequency structure.
- `grad n640` 5.00 vs ref 1.30 → our fine grain is **≈3.9x too high**.
- `luma std` 10.6 vs 20.1; 84 % of P0 pixels in 2 of 16 histogram bins → narrow olive spike.
- A11 §5 direction **[D]**: move energy from HIGH to LOW spatial frequency; do **not** add
  fine dither / palette-only changes.

Mapping to the landed B01 changes (no further shader edit made):

1. **Reduce high-frequency energy** — `filter_linear_mipmap` (`:60`) removes nearest
   magnification of the repeating cell (Charter §2 #3, F04 P0-4); A02-P4 (`:419`) halves
   the mask's modulation depth and clamps its near-black tail, so the per-cell organic
   lobes and dark-edge bands contribute ≈2.7x less fine-scale luma swing
   (0.80 span → 0.325). Together these target `grad n640` downward, the direction A11 §5 #2
   requires. **Predicted [I], not measured** — COORD must re-measure.
2. **Stop black cells** — A02-P1 sentinel bypass (`:412-419`) removes the `a=0` hard defect
   on 8/124 ids, which otherwise adds high-contrast fine dark blotches on cliff faces and
   in transition tiles. This also supports A11 histogram bins 2–4 once B03 supplies the
   real low-frequency spread.
3. **Low-frequency energy is deliberately NOT manufactured in this file.** A08 §1/§3 and
   COORD's follow-up state that donor mottling is *tile identity*; A11 §5 #1 wants 32 px+
   block variance, which a shader luminance/noise field would fake in the wrong way
   (CHARTER S-25-09, A08 §7 #2). `tile_rgb()` still samples exactly the cell selected by
   `idx`, leaving a clean hook for B03's tile-id diversity to raise `BV32` and `luma std`.

**Decision [I]:** no additional P4 strength tuning or extra blur was applied. A11 gives a
direction, not a measured transfer function for this shader; changing the 0.5 mix blind
could flatten the field further (`luma std` is already too low) or over-blur fine detail.
COORD's A/B metric tool (`variant3d/tools/terrain_ab_metric.py`, seen in the worktree) can
measure `grad n640` / `BV32` / `luma std` before any further tuning. The `mask_to_alpha`
A/B contract and all cited anchors remain byte-identical.

## 8. A06 follow-up patch (minimal additive; applied after A06 landed)

A06_filtering_aliasing.md §3.4/§6 Fix 2 identified a **residual risk created by B01+B02**:
with B02's mips and B01's `filter_linear_mipmap`, the `fract()` wrap at each 2 m cell
produces an implicit-derivative spike (LOD≈10) and linear filtering at local UV 0/1 can
bleed into an adjacent atlas cell. It also identified a *unique* cause: vertex-stage
`fract()` at `:316` collapses the mask to one scalar per 2 m cell.

Applied, with **no change to any protected anchor and no change to total length
(502 lines)**:

| Location | Change | A06 citation / label |
|---|---|---|
| `:265` | `v_alpha_uv` comment now says `UNWRAPPED phase (A06-F2)`; declaration/name unchanged. | A06 §6 Fix 2 |
| `:315-316` | `v_alpha_uv = fract(v_st*uv_repeat)*alpha_uv_scale;` → `v_alpha_uv = v_st*uv_repeat*alpha_uv_scale;` (wrap moved to fragment). | A06 §3.3 / §6 Fix 2 |
| `:331-336` (`tile_rgb`) | `cell`/`key` merged to free one line; new `vec2 inset = 0.5 / max(vec2(textureSize(tile_atlas,0))/atlas_grid, vec2(1.0));` (half-texel guard derived from the real atlas size, not a hardcoded donor constant: 16384×8192 / 16×8 = 1024×1024 → 0.000488); `uv = mix(inset, 1.0-inset, fract(...))` keeps the sample inside the atlas cell. | A06 §3.4/§6 Fix 2, §5 rank 5 (**INFERRED**) |
| `:337` | `texture(...)` → `textureGrad(tile_atlas, (cell+uv)/atlas_grid, dFdx(v_st*uv_repeat)/atlas_grid, dFdy(v_st*uv_repeat)/atlas_grid)` — explicit gradients from the **unwrapped** varying kill the seam LOD spike; donor call path `hf.pvl.smx3.frag:13` retained. Verified `textureGrad`, `textureSize` and `dFdx/dFdy` exist in the project's Godot **4.4** shader reference (project.godot `config/features=4.4`), so this is not a 4.7-only API. | A06 §3.4/§6 Fix 2 (**INFERRED**, standard GPU behaviour; no GPU A/B) |
| `:419` | `alpha_patch_uv(v_tile, v_alpha_uv)` → `alpha_patch_uv(v_tile, fract(v_alpha_uv))` — fragment-stage wrap restores intra-cell mask variation; existing half-texel clamp at `:376` still protects the 64² patch border. | A06 §3.3 / §6 Fix 2 (**DERIVED** high confidence) |

Notes / residual risks:

- `:392` is *still* byte-identical (`tile_rgb(v_tile, fract(v_st * uv_repeat))`) as required
  by the A/B anchor list; the derivative fix is applied **inside** `tile_rgb` using the
  unwrapped varying, so no protected line had to change.
- `textureGrad` gradients are taken from the unwrapped world coordinate; the continuous
  warp changes gradient magnitude only marginally (≈0.02 relative), so this is a PORT
  APPROX consistent with A06's recommendation. The per-cell mirror that used to precede
  the warp was removed in §9.
- The inset compresses each cell's usable UV into `[0.000488, 0.999512]`; it slightly
  crops the outer half-texel of every preset and can leave a faint seam if donor art is
  not edge-continuous. This is the deliberate trade A06 asks for to stop cross-cell
  bleed. No donor constant is claimed.
- Moving the mask wrap to the fragment path restores real intra-cell mask variation,
  which increases local detail; A02-P4's 50 % contrast compression and clamp remain in
  force to keep the fine-grain budget (A11 §5 #2).
- Re-verified after this patch: 502 lines; anchors `:235`, `:365-378`, `:392`, `:427`,
  `:475`, `:476`, `:478-502` byte-identical; 31 uniforms with the only textual diff still
  the `:60` filter hint. No Godot run / runner job.

## 9. Owner visual verdict — per-cell mirror removed (final revision)

**Owner (OBSERVED, on `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\p0_64.png`):**
*"I actually like more this kind of terrain than before ... but not like chessboard. I
would mix light-colour grass with darker in SPOTS, not like a chessboard."*

Diagnosis [D]: the B01 per-cell mirror (`v = mod(key.x + 3.0*key.y, 4.0)`, `f = vec2(step(…))`,
`mix(local_uv, 1.0-local_uv, f)`) flipped the atlas cell every 2 m on an axis-aligned
lattice — a chessboard, not the organic spots the owner wants. COORD required removal of
that variant only; all other B01/A02/A06 fixes stay.

**Exact final diff of this revision (inside `tile_rgb()`, `:331-336`; line count unchanged):**

```diff
- vec2 cell = vec2(mod(idx, cols), floor(idx / cols)), key = floor(v_st * uv_repeat);
- float v = mod(key.x + 3.0 * key.y, 4.0);   // B01 deterministic mirror variant, no noise field
- vec2 f = vec2(step(1.5, v) + step(3.5, v), step(0.5, v) + step(2.5, v));
+ vec2 cell = vec2(mod(idx, cols), floor(idx / cols));
+ // B01 REVISION (owner verdict g04): per-cell mirror variant REMOVED — 2 m axis-aligned
+ // flips read as a chessboard. No lattice variant; tile-ID diversity belongs to B03.
  vec2 warp = 0.125 * vec2(sin(dot(v_st, vec2(0.13, 0.07))), cos(dot(v_st, vec2(0.09, 0.11))));
  vec2 inset = 0.5 / max(vec2(textureSize(tile_atlas, 0)) / max(atlas_grid, vec2(1.0)), vec2(1.0)); // A06-F2 half-texel inset
- vec2 uv = mix(inset, 1.0 - inset, fract(mix(local_uv, 1.0 - local_uv, f) + warp)); // no luminance field (S-25-09)
+ vec2 uv = mix(inset, 1.0 - inset, fract(local_uv + warp)); // continuous warp only; no luminance field (S-25-09)
```

No other shader line changed in this revision. `key`, `v`, `f` are gone; grep confirms
no mirror remnants (the only remaining `step(2.5, …)` is A02-P1's sentinel flag at `:419`).

**Kept exactly as required:** `filter_linear_mipmap` (`:60`); the continuous sin/cos UV
warp; the A06-F2 half-texel inset; `textureGrad` with unwrapped `dFdx/dFdy` (`:337`);
A02-P1 sentinel guard and P4 contrast compression (`:412-419`); the fragment-stage mask
wrap (`:316`, `:419`); all 31 uniform names; the `mask_to_alpha` endpoints; and the
`:478-502` comment block.

**Rationale / labels:** removal is an owner-driven [O] correction of an [I] styling
choice, not a donor claim. The continuous warp remains a **PORT APPROXIMATION** of donor
eye-plane texgen (engine values CONFIRMED_UNVERIFIED, A08 §1/§8; F05 CORRECTIONS row 44).
Organic light/dark *spots* are explicitly deferred to B03's tile-ID diversity — A08 §1/§3
says donor mottling is tile identity (grass1..10/test7/8/9/12/14), never a shader
luminance/noise field (CHARTER S-25-09, A08 §7 #2). If the 2 m repeat reappears, do **not**
reintroduce a lattice variant.

**Re-verified after revision:** 502 lines; anchors `:235`, `:365-378`, `:392`, `:427`,
`:475`, `:476`, `:478-502` byte-identical; 31 uniforms with the only textual diff still the
`:60` filter hint; no Godot run or runner job. The backup
`inbox/backup/terrain_tileindex.gdshader.bak-B01` remains the original pre-B01 file (the
rollback point), as required by the original ticket; no new backup file was created.

COORD can re-capture frame `g04` now; B01 stays available for a follow-up.

*End of B01 report.*
