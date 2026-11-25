---
id: H04
ticket: "TERRAIN-SWARM-WAVE-G / H04 — heightmap fix (branch: H03 REFUTED)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT_JOB
scope: "Exactly one report written. No shader/script/asset/config/test/git edit; no Godot process; no runner job, queue mutation or capture. Donor values cited READ-ONLY from H01/H03/A08 path:line evidence, not re-rendered."
owner_file: docs/terrain_swarm_2026-11-25/reports/H04_heightmap_fix.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
verdict: "NO HEIGHT-LAYER FIX TO APPLY — H03 (and independently H05) REFUTE the hypothesis. This report takes the charter's refuted branch: short statement plus the correct-cause fix proposal."
parity_claim: false
---

# H04 — Heightmap fix proposal: H03 refuted, correct-cause fix instead

## 0. Branch taken

`WAVE_G_CHARTER.md:118-124` makes H04 conditional: a ready-to-apply unified diff **only if H03
confirms**; otherwise a short refutation note and the correct cause fix. H03 has landed and is
**REFUTED** (`reports/H03_heightmap_hypothesis.md:210-214`: *"no candidate layer is both a donor
height source and drawn as albedo in this port. Therefore the decisive test does not confirm the
owner hypothesis as stated"*). H05 independently reaches the same verdict
(`reports/H05_refutation.md:43-59`). **No unified diff is produced, because there is no
height-layer misroute to fix.** Labels below follow H03 §0 / H05 §0; no donor GPU A/B exists
(CHARTER §3), so visual claims are INFERRED and donor parity is UNVERIFIED.

## 1. Why the heightmap fix must not be applied (short)

- **Only C1 partly supports the owner's intuition, and it refutes the mechanism.** The alpha /
  alphavert atlas is drawn as a visible albedo darkener — shader `terrain_tileindex.gdshader:417`
  samples `.a`, `:427` folds it into RGB, `mask_to_alpha=1.0` at `:235` — so "should not be visible"
  holds. But H03's C1 verdict is *"CONFIRMED for 'the port wrongly VISUALISES a mask'; REFUTED for
  'this layer is a height source that should be heightmap-only'"*
  (`H03_heightmap_hypothesis.md:73-74,98-99`). Donor explicitly denies the height role: `alpha.bmp`
  is bound at `data\terrain\ref\reftile.mat:6` (`Texture2Name = alpha`) and `:17`
  (`BlendingMode = bmTransparency`), decoded as intensity at
  `data\terrain\ref\reftilealpha.mat:30-37`, read as `color.a` at
  `data\shaders\obj\hf.pvl.smx3.frag:14` against `texUnit0` RGB at `:13`; it is a **blend crossfade
  weight, "not a colour layer, a height ramp, a distance field, or a noise source"** (A08 §2,
  H03-E5). The port's `a`→RGB fold is a **PORT APPROXIMATION** of that one-pass blend.
- **Every genuine height/selection layer is already data, not albedo.** Donor terrainmask TGA R/B
  enter height at `data\scripts\common.inc\generatemap.inc:567-573`; `.pattern` float32 relief windows are
  height stamps (H01 §1 rows 1/2/5/7, `:45-51`); detail bitmaps `tile_lowground.bmp` /
  `tile_highground.bmp` R bytes **select tile ids** at
  `data\gen\bitmap\ext\*` / `loadtextureterrainfrombitmap.inc:4,8-9,25-41`. In the port the same
  holds: `mapgen.gd:166,180,212-215` decodes masks to `height[]` on the CPU; `game.gd:1903-1952`
  writes tile ids; the only four terrain samplers are `tile_atlas`/`alpha_atlas`/
  `alphavert_atlas`/`shadow_map` (`terrain_tileindex.gdshader:60,66,72,83`, H03-E1/E13/E14).
  `splat_albedo.png` A is "normalised height DATA … never blend it"
  (`world3d_terrain.gd:761`, only the V7-82 fallback `:1541-1545`, **PORT APPROX**).
- **Therefore: no file grant, no diff.** COORD should **not** grant shader (B01),
  `world3d_terrain.gd` (B04) or `game.gd` (B03) for a height reroute. H05 §5 shows what it would
  break: donor tile identity (§5.1), the published `mask_to_alpha` A/B — `a` must exist at `:427` or
  the knob becomes a no-op (§5.2, shader A/B block `:478-502`) — and mesh invariants
  `height_at_world()` / `height[]` length / ±2.964 clamp (§5.3). It also leaves the actual streaks
  in place (H03 §3 point 4).

## 2. The real cause (visible path, with evidence)

1. **The albedo art itself carries the veins.** Atlas cells are byte-identical copies of the
   shipped block PNGs (A03 E01, H03-E9); `grass_ground1/2/3` contain the bright diagonal vein
   lattice / crosshatch (A03 §2 rows 14/15/16, F03/R02). Donor role of those blocks is visible
   albedo — `data\terrain\tiles\textures\*.dds` sampled as `texUnit0` at
   `data\shaders\obj\hf.pvl.smx3.frag:13` (H01 row 15, `:59`) — so this layer is **drawn correctly in donor too**.
2. **The alpha crossfade adds a second repeating pattern.** The id→patch decomposition
   (`terrain_tileindex.gdshader:365-378`: `id mod 4`, `(id/4) mod 4`, `(id/16) mod 2`,
   `(id/64) mod 2`) gives only 32 roles for 124 ids and is sampled unconditionally on every 2 m
   cell, with no neighbour input (A02 §1 Q1/Q2, H03-E6/E7). The sentinel guard and contrast
   compression (`:410-419`, B01/A02-P1/P4) are landed **PORT APPROX** mitigations, not a height
   change.
3. **Verbatim 2 m repeat + filtering amplify both.** `uv_repeat=(0.5,0.5)` (`:214`) and
   `tile_rgb(v_tile, fract(v_st*uv_repeat))` (`:392`) repeat one cell per 2 m on world-XZ texgen;
   A01 Rank 1 / A06 Rank 2 attribute the faint diagonal streaks to this repeat under minification
   (≈76 px measured period). World-XZ planes, `TILE_M=2` and the mirror/warp + `textureGrad` +
   half-texel inset (`:331-337`) are all **PORT APPROX**; donor eye-plane values stay
   CONFIRMED_UNVERIFIED (A08 §8.2).
4. **Relief is a separate, already-diagnosed gap** (A05 amplitude-vs-footprint; G07 active grids),
   not a display bug and not the source of the streaks (A05 §4 cross-check, H03-E14).

B01/B02/B03/B04 mitigations are all landed. **No post-fix capture exists** — G04 is blocked at
pre-flight (`reports/G04_gate_log.md:25-58,155-165`) — so the residual mask-vs-atlas share is
**UNVERIFIED** (H03 §4 item (a), A02-E11).

## 3. Correct fix for the real cause (proposal — NOT applied)

- **Step 0 — partition first, no code edit.** Have G04 (sole runner owner, `WAVE_G_CHARTER.md:31`)
  run the published `mask_to_alpha` A/B at an **identical camera**: `1.0` shipped vs `0.0` flat,
  both endpoints of the same compiled program (shader `:427`, `:475`, A/B block `:478-502`), with
  a real `set_shader_parameter("mask_to_alpha", …)` binding plus an additive config key per gate
  **G-A0** (`reports/C02_gate_plan.md:389`) — a config-only arm is UNVERIFIED and FAIL. Use unique
  ids and a second-agent C04 visual read (`C02_gate_plan.md:398-404`). This is A02-P3, H05 §6 #3,
  and the missing frame H03 §4 flags; until it exists, further visual tuning is guesswork.
- **Step 1a — if the mask share dominates:** implement the donor-shaped, transition-only mask
  (A02-P5): carry a neighbour tile id into the mesh (a new UV attribute in
  `world3d_terrain.gd`, B04's file) and gate `a` so it modulates only where neighbouring ids
  differ. Keep `:427`'s formula and both `mask_to_alpha` endpoints byte-identical; do **not**
  remove `a` from `:427` (H05 §5.2). Requires COORD grant of `world3d_terrain.gd` **and** the
  shader after B01/B04 are closed; backups `inbox/backup/<file>.bak-<TICKET>` (CHARTER §3:66).
  **PORT APPROXIMATION** — one blend pass vs donor `bmTransparency`
  (`data\terrain\ref\reftile.mat:17`).
- **Step 1b — if the atlas-repeat share dominates:** work tile identity, not height. Verify the
  current tile mix with a fresh `--dump-map` histogram (G15 method) rather than the pre-B03
  figures; B03's redirect of `grass_ground1/2/3` → `grass9`/`test8`/`test7`
  (`game.gd:2191-2196`, **PORT APPROX**, not donor parity) may already cover the loudest cells.
  Any further diversity edit is `game.gd` (B03's file, COORD grant) and must add **no** noise,
  dither or invented donor constant (CHARTER §3 S-25-09; A08 §7 #2/#5).
- **Never** route the mask/atlas into `height[]`: resolution mismatch, no fragment→geometry path,
  broken `height_at_world()` invariant and void A/B (H05 §5.1–§5.3).

## 4. Gates/captures that must verify any follow-up fix

G0 pre-flight `pending=0`/lock free/0 Godot (`C02_gate_plan.md:382`); G1 parse smokes with
`script_error_lines: 0` (`:383`); G2 windowed 64² P0 1280×720, non-blank, `non_black_fraction ≥
0.9`, `mean_luma ≥ 40`, `max_luma ≥ 100`, no diagonal streak/grid/repeated blotch (`:384`); G3
real-map with `full_width_dark_rows == 0` where water and no new seams (`:385`); G-A0 binding
proof (`:389`); G5 selftest **29/29**, G6 uitest **17/17**, G7 `t_render_mode` PASS, G8
`assert_clean` CLEAN, G9 `app/` byte-untouched (`:392-396`); A11/C01 metrics and second-agent C04
review (`:391,398-404`). No threshold lowered, no assertion deleted. **Donor parity stays
UNVERIFIED** — none of these gates is a donor A/B.

*End of H04. One report written. No code, shader, asset, config, test, git, Godot or runner state changed; no donor-parity claim.*
