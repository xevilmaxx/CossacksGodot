---
id: L02
ticket: "Owner directive wave — chessboard review of g04/p0_64.png"
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT__NO_CODE_EDITS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/L02_chessboard_review.md
files_edited: []
godot_runs: 0
runner_jobs: 0
parity_guard: "No donor GPU A/B frame exists. No donor-parity claim is made anywhere in this report. Scratch zoom crops were written only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (outside the repo)."
---

# L02 — independent review: is the "chessboard" the mirror variant, the alpha patch decomposition, or the atlas art?

## 0. Scope, timing and an important concurrency finding

Read as instructed: `WAVE_G_CHARTER.md`, `CHARTER.md`, `reports/B01_shader_impl.md`,
`reports/A06_filtering_aliasing.md`; opened both PNGs; read the **current** shader
`variant3d/shaders/terrain_tileindex.gdshader`; read the P0 fixture definition
`variant3d/tests/t_terrain_only.gd`. No Godot, no runner, no repo code edit, one report.

**Concurrency / timeline [OBSERVED]:** during this review the working tree changed.
- The shader I **first** read had the per-cell mirror at `:331-336` (`key`, `v`, `f`,
  `mix(local_uv, 1.0-local_uv, f)`). That is the version that produced `g04/p0_64.png`
  (`G04_gate_log.md:114` = `g04-p0cap` → `t_terrain_only.gd`, and `B01_shader_impl.md §9:263-312`
  records the owner verdict followed by B01's removal).
- The shader I **re-read** at verification time (`:328-338`) already has the mirror **removed**:
  `:332-333` are now revision comments, `:336` is `fract(local_uv + warp)`. B01's report §9
  documents the same revision. So the directive's question "what B01 must remove" was overtaken
  by a concurrent B01 edit; §5 below states the exact removal and confirms it is **already in place**.

## 1. The two frames, described in words BEFORE the verdict [OBSERVED]

Both files are 1280×720, olive-green, flat (no relief/shore). Measured with Pillow:
old mean luma 88.46 / σ 10.20; new mean 89.19 / σ **4.22** — the new frame is markedly
**softer / lower-contrast**, as expected from mips + linear filtering + mask compression.

**OLD — `...\p0fresh01\p0_final_formula.png` (pre-B01/B02 baseline):**
Uniform, tight, **fine high-frequency grain** ("static") across the entire field, with faint
low-contrast horizontal-ish lamination and a few very soft large blotches. No cell boundaries,
no lattice, no alternating blocks. Autocontrast zoom (scratch `l02_old_zoom.png`) shows
featureless pepper-grain. This is the "fine grain + faint diagonal streaks" described in
A06 §2 / A02-E8.

**NEW — `...\g04\p0_64.png` (post-fix frame the owner prefers):**
Grain is **smoothed away**; the field reads as soft, blurry patches. But the autocontrast zoom
(scratch `l02_new_zoom.png`) reveals a **rigid 2 m rectangular lattice**: straight cell seams
and, inside the cells, a regular alternation of two visibly different appearances —
(a) pale cells with fine **horizontal "barcode" striping**, and (b) darker cells with soft
**lacy/blob** texture. The alternation is locked row-for-row and column-for-column to the
cell grid: a light cell has dark neighbours above/below and left/right. It reads as a
**quilt / chessboard of soft spots**, not as organic mottling. This matches the owner's words
("not like chessboard ... mix light-colour grass with darker in SPOTS").

**Decisive A/B fact [OBSERVED]:** the chessboard pattern exists **only in the new frame**. Both frames
sample the **same atlas art**; only the post-fix shader introduced a per-cell lattice transform.

## 2. Independent cause verification

### 2.1 The alpha patch decomposition is ruled out on this frame [OBSERVED + DERIVED]

`variant3d/tests/t_terrain_only.gd:36-41,61`: the 64² P0 fixture is **all grass tile id 0**
(`GRASS_TILE := 0`), no shore/rock/water, no trees; `G04_gate_log.md:114` confirms `p0_64.png`
came from this atom. Therefore `v_tile = 0` for **every** cell.

Trace `alpha_patch_uv(0, ·)` in the current shader (`:365-378`):
`id=floor(abs(0))=0`, `dir=row=0`, `variant=0`, `half=0`, `opposite=0` → `cell=(0,0)` for
every cell. The flat-branch guard (`:412-419`) computes `srow=0`, `scol=0`, so
`sentinel = step(2.5,0)*step(2.5,0) = 0`; the contrast compression then gives
`a = mix(mix(1, clamp(a,0.35,1), 0.5), 1, 0)`.

Pixel check of `variant3d/assets/terrain/atlas/alpha.png` [OBSERVED, Pillow]: patch (0,0) is
**constant 255** (mean 255.0, std 0.0, min=max=255); its L channel is also constant 255.
Hence `a = 1.0` everywhere and `:427` reduces to `rgb = rgb * v_packed + 0`:
**the alpha path contributes zero spatial variation on `p0_64.png`.**
It cannot be the chessboard. (Other patches are strongly structured — e.g. (1,0) mean 52.3
std 87.5, (3,3)/(7,3) constant 0 — so this conclusion is specific to the all-zero fixture.)

### 2.2 The atlas art itself is ruled out [OBSERVED + DERIVED]

With id 0 every cell samples the **same atlas cell 0** of the 16384×8192 atlas. A downsampled
8×8 mosaic of cell 0 [OBSERVED] shows only a mild smooth gradient (left ≈70–75, right ≈76–79;
bottom slightly brighter than top) — no checkerboard baked into the art. The old frame sampled
the identical art and had no chessboard. The art can be *revealed* differently by a per-cell
transform, but it cannot *generate* a regular alternating lattice by itself.

### 2.3 The per-cell mirror variant is the cause [DERIVED from the pre-revision source; INFERRED for the pixel mechanism]

Pre-revision `tile_rgb()` (read this session, now replaced):
```
vec2 cell = ..., key = floor(v_st * uv_repeat);
float v = mod(key.x + 3.0 * key.y, 4.0);
vec2 f = vec2(step(1.5, v) + step(3.5, v), step(0.5, v) + step(2.5, v));
...
uv = mix(inset, 1.0 - inset, fract(mix(local_uv, 1.0 - local_uv, f) + warp));
```
- `v_st` is world X/Z (`eye_plane_s=(1,0,0,0)`, `eye_plane_t=(0,0,1,0)`, `:120-121`), so
  `key = floor(worldXZ / 2 m)` is the **integer 2 m cell coordinate** — a perfect lattice.
- `v = mod(key.x + 3*key.y, 4) = mod(key.x − key.y, 4)` [DERIVED]: a 4-phase **diagonal-stripe
  pattern on the cell grid**, independent of tile id. It changes orientation on *every* cell —
  the only per-cell-varying input on an all-id-0 frame.
- Exact `f` values [DERIVED from `step` semantics]: v=0→(0,0), v=1→(0,1), v=2→(1,1),
  v=3→(1,2). Note this is **not** the four clean mirror states claimed in B01's original §3:
  for v=3, `mix(a, b, 2) = 2−3a` (a = local_uv.y) leaves [0,1] and is re-folded by `fract()`,
  adding an extra per-cell saw fold. Either way it is a deterministic coordinate-lattice variant.
- Mechanism [INFERRED]: atlas cell 0 has a mild left→right/top→bottom brightness gradient
  (§2.2); mirroring per cell moves the brighter side into different corners, so neighbouring
  cells alternate between pale, horizontally-striped sampling and darker lacy sampling —
  exactly the two cell classes seen in the enhanced new-frame zoom. The `fract()` wrap and
  half-texel inset add the visible straight cell seams.

**Verdict [DERIVED, high confidence]:** the chessboard in `p0_64.png` was caused by the
**per-cell mirror variant `v=mod(key.x+3*key.y,4)` / `f=step(...)` and its
`mix(local_uv,1.0-local_uv,f)` flip**. It was **not** the alpha patch decomposition (constant
patch on this fixture) and **not** the atlas art (same art, no chessboard in the old frame).

## 3. Labels on each claim

| Claim | Label |
|---|---|
| Frame appearances and luma stats (88.46/10.20 vs 89.19/4.22); alpha (0,0)=255; atlas cell-0 gradient | **OBSERVED** (direct pixel reads) |
| Fixture is all tile id 0; `p0_64.png` came from `t_terrain_only.gd`; shader revision landed mid-review | **OBSERVED** (source/report reads) |
| `a=1` everywhere on id 0; `v` periodic mod 4 on the cell lattice; `f` values above | **DERIVED** (exact source arithmetic) |
| Mirror flips move atlas brightness → pale-striped vs dark-lacy cell alternation | **INFERRED** (no shader-only GPU A/B) |
| Visual share of residual tiling after mirror removal; whether seams persist | **UNVERIFIED** (no new capture; I ran no Godot) |
| Donor parity of any kind | **UNVERIFIED** — not claimed |

## 4. What B01 must remove to kill the chessboard (and what must stay)

Against the **pre-revision** shader (the state that produced the frame), the exact removal is:

1. Delete `key = floor(v_st * uv_repeat)` from the `vec2 cell = ...` declaration (old `:331`).
2. Delete `float v = mod(key.x + 3.0 * key.y, 4.0);` (old `:332`).
3. Delete `vec2 f = vec2(step(1.5, v) + step(3.5, v), step(0.5, v) + step(2.5, v));` (old `:333`).
4. In `:336` replace `fract(mix(local_uv, 1.0 - local_uv, f) + warp)` with
   `fract(local_uv + warp)` — keep the continuous low-frequency warp.

**Keep untouched** (these are the softer look the owner likes, all confirmed still present in
the current source): `:60` `filter_linear_mipmap` + B02's runtime mip chain; `:334` warp;
`:335` half-texel inset; `:337` `textureGrad` with unwrapped `dFdx/dFdy`; `:412-419` sentinel
guard and A02-P4 mask contrast compression; `:316/:417` fragment-stage mask wrap; `:427`
mask fold; all 31 uniforms and the `:478-502` A/B block.

**Status [OBSERVED]:** this exact removal is **already applied** in the current shader at
`:331-336` ("B01 REVISION ... per-cell mirror variant REMOVED") and documented in
`B01_shader_impl.md §9`. No further B01 deletion is needed for the chessboard. Do **not**
reintroduce any lattice variant — including a "fixed" mirror — even if the 2 m verbatim repeat
becomes visible again (B01 §9:303-304). A fresh `g04` capture is required before claiming the
chessboard is visually gone; that outcome is **UNVERIFIED** here.

## 5. What must come from tile-ID data instead

- The organic **light/dark spots** must be **tile identity**, i.e. `v_tile` = UV2.x, the per-cell
  donor `.tex` id (`:250-257`, `:324`), selecting different atlas cells. That is B03's domain:
  `game.gd:_assign_tileblocks()` plus the donor test7/test8/test9 re-roll (`WAVE_G_CHARTER.md`
  B03; A08 §1/§3; B01 §7 #3). CHARTER S-25-09 forbids manufacturing the variation with a
  shader luminance/noise/dither field; A08 §7 #2 likewise says mottling is tile identity.
- The alpha path already keys its patch selection on `v_tile` (`:365-378`) — that is the correct
  data-driven channel; P5 ("mask only where neighbouring tile ids differ") needs neighbour data
  and a data handoff, outside this shader.
- The P0 64² control fixture is intentionally all id 0, so after mirror removal it will read
  uniform — that is expected, **not** a regression. Multi-tile organic variation must be judged
  on a real-map capture, not on `p0_64.png`.
- Any future per-cell decoration must be derived from **tile-ID data** (`v_tile`), never from
  `floor(v_st * uv_repeat)`, `mod(key.x + k*key.y, n)` or another world-coordinate lattice.

*End of L02 report.*
