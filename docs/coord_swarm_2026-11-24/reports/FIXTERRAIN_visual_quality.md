---
id: FIX-TERRAIN
title: "Terrain quality diagnosis, donor-grounded face promotion, and explicit shadow-map disable"
owner: FIX-TERRAIN
date: 2026-11-24
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
status: DELIVERED__PARSE_CLEAN__PROBE_20of20__SELFTEST_29of29__WINDOWED_CAPTURE__SHADOWS_DISABLED_BY_USER_DECISION__NO_DONOR_AB
scope: "ONLY variant3d/scripts/world3d_terrain.gd + variant3d/shaders/terrain_tileindex.gdshader + this report. No atlas/loader/water/app/config/test/git edit."
owns:
  - "variant3d/scripts/world3d_terrain.gd"
  - "variant3d/shaders/terrain_tileindex.gdshader"
  - "docs/coord_swarm_2026-11-24/reports/FIXTERRAIN_visual_quality.md"
labels: [DONOR_GROUNDED_FACE_PROMOTION, PORT_APPROXIMATION, SHADOWS_DISABLED_USER_DECISION, MEASURED_REJECTIONS, NO_VISUAL_PARITY_CLAIM]
visual_parity_claim: false
runner: "variant3d/tools/godot_runner.py only; tickets 257,262,264,268,269,275,278,281,283,284,285,286,287,288,289,290,291,292,293,294"
verification:
  parse: "ticket 288 ok, exit 0, 3.21 s"
  probe: "ticket 293 ok, exit 0, 17.73 s, 20/20 PASS (temporary probe DELETED)"
  selftest: "ticket 294 ok, exit 0, 144.02 s, variant3d/selftest.json passed=true, 29/29 steps"
  captures: "ticket 257 BEFORE, 283 controlled terrain A/B, 289 AFTER full-game"
shadow_decision: "EXPLICIT USER DECISION THIS WAVE — DirectionalLight3D.shadow_enabled=false and terrain cast_shadow=OFF. Donor sun colours/energy/sky untouched."
---

# FIX-TERRAIN — diagnosis and smallest donor-grounded fixes

## 0. Verdict and honesty guard

The live tile-index pipeline was **already correct** (COMP-03 S1, independently
re-verified here): `game.tileblock` → `UV2.x` → donor atlas → donor shader all
reach the GPU. The low visual quality is therefore **not** a plumbing bug. Four
separate causes were identified; two are outside this module's ownership, one
was fixable here with donor-readable slope data, and one was removed by explicit
user decision.

**NO donor A/B was run. No donor visual parity is claimed.** Every substitute
carries `PORT APPROXIMATION` / `PORT SUBSTITUTE` / `UNVERIFIED` in code and here.
Where an experiment was tried and made things worse, it was **reverted and the
measurement is published** rather than hidden.

## 1. Line-by-line source diagnosis (the five mandated questions)

| # | Question | Finding | Evidence |
|---:|---|---|---|
| Q1 | Are live tile indices written to UV2 for **all** vertices? | **YES.** The `for z / for x` loop writes `uvs2[i]` for every cell, then attaches `ARRAY_TEX_UV2`. | `world3d_terrain.gd:697-709`, `:720`; probe 293 read **102,400** entries, 0 mismatches; V7-92 job 251 had already measured the same. |
| Q2 | Is the 4-sub-tile-per-cell structure used? | **NO — and it cannot be from the live source.** The live field is `game.tileblock: PackedByteArray` sized `MAP_W*MAP_H` with **one uint8 per cell**; the 2D sibling decodes one byte per cell. Donor `tsDouble/ttExtended` 16×16 sub-tile packing lives in `reftile.lib:3-12` and is engine-side/UNVERIFIED. No 4-sub-tile data is available; none was invented. | `game.gd:53,1621-1689`; `app/scripts/world3d.gd:185-202`; `TERRAIN2-01 E03/E22/E37`; `V792 §3`. |
| Q3 | Is `atlas_grid` from the manifest? | **YES.** Loader `_load_grid()` reads the V7-85 manifest; module forwards `atlas_grid()` verbatim with no donor default. | `tile_atlas_loader.gd:297-304`; `world3d_terrain.gd:237,313`; probe 293: `(16.0, 8.0)`, manifest `atlas.grid=[16,8]`. |
| Q4 | Are masks sampled in the right channel / right UV? | **Channel YES, UV only APPROX.** Grayscale PNGs are repacked R→A (`_repack_mask_alpha`), shader reads `.a`. But the mask UV is `fract(eye-plane st)` over the whole 512×256 / 1024×512 mask; donor per-tile sub-rect mapping (`AlphaRows=8, AlphaCols=4, AlphaTileSize=64`, `reftile.lib:7-11`) is commented/UNVERIFIED, so no sub-rect is guessed. | `world3d_terrain.gd:270-283`; shader `:60-70,250,308`; `TERRAIN2-01 E37`; `V792 §6.3`. |
| Q5 | Is the material actually assigned (not overwritten)? | **YES.** `mesh.surface_set_material(0, surface_mat)`; the terrain MeshInstance has no `material_override` anywhere in `variant3d/scripts/**`. Tile material wins whenever live indices + atlas exist. | `world3d_terrain.gd:740`; repo-wide grep for `material_override` found none on the terrain instance. |

## 2. Root causes of the low visual quality — ranked, with evidence

### RC1 — **Data-level, outside ownership:** the live tile field is near-uniform and transition-tile-heavy.
Read-only measurement of `app/shots/g32_dump.json` `tileblock`: **102,400 bytes, 31
distinct ids, range 0..85**; top ids `14:28535` (`grass_ground1`), `0:15993`
(`grass1`), `16:15962` (`grass_ground3`), `79:7667` (`test8`), `78:6691`
(`test7`), `25:4135` (`rock9`). The top five cover **73.0%** of the map and
`test7/8/9` alone are **14,358 cells (14.0%)** — these are donor *transition
blend* tiles, which is exactly the repeated light "maze" pattern visible in the
capture. Manifest check: only **82 unique block PNGs** serve 124 named cells
(e.g. `grass_ground1` and `grass_ground3` are byte-identical), and empty cells
**86/110/123** exist but are outside this map's 0..85 range. **Cannot be fixed in
the two owned files** without inventing tile data.

### RC2 — **Face mode was always 0 (COMP-03 RED, E3).**
`world3d_terrain.gd:631` previously wrote `UV2.y=0` for all 102,400 cells, so the
donor `rockNvf/vs` face path, `alphavert` projection and eye-linear face texgen
were dead. COMP-03 §3 row 2b / §4 gap 2 independently flagged this. **Fixed here**
(§4) with donor-readable slope thresholds; ~7% of cells promoted.

### RC3 — **Godot shadow map on a 640×640 m self-shadowing mesh (user-reported artifact).**
The shipped rig had `sun.shadow_enabled=true`, `directional_shadow_max_distance=400`
and terrain `cast_shadow=ON`. The donor sun vector is near-vertical after the
Z-up→Y-up transform (`SUN_LIGHTVEC=(-0.0861828,0.9387015,0)`, `light.cfg:26-29`,
`water.dev.vert:22`), and the shadow matrix is engine-side/UNVERIFIED
(TERRAIN2-01 §6). A 400 m shadow frustum over a 640 m surface plus near-vertical
light is a plausible source of unbounded directional streaks. **Shadows disabled
by explicit user decision** (§6). Important diagnostic: the tile shader is
`unshaded`, so terrain never *receives* the Godot shadow map; the visible dark
horizontal bands in the BEFORE frame are the height-aware water fields
(`water3d.gd`, outside ownership), not shadows on terrain.

### RC4 — **Dark donor art + deliberately `unshaded` donor lighting.**
Atlas cell art means are dark olive (measured cell 14 = `[82.5,79.3,36.6]`),
and the shader reproduces donor `rgb*(ambient+diffuse)+specular` exactly
(`hf.pvl.smx3.frag:17`; donor text re-read this pass). Donor `light.cfg`
Ambient/Diffuse constants are declared but unused (COMP-03 E7). They **cannot be
substituted directly**: the shader's packed terms are
`sceneColor + lightAmbient*materialAmbient` and `lightDiffuse*materialDiffuse`,
with `sceneColor` engine-bound; a raw light-colour swap measured only **+0.9 luma**
and is not donor-faithful. Rejected, documented (§5).

### RC5 — **Eye-plane UV values are neutral substitutes.**
The shader implements `dot(realpos, eye_plane_s/t)` from `hf.pvl.sm.vert:26-33`,
but `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` are engine-bound and UNVERIFIED;
defaults `(1,0,0,0)/(0,1,0,0)`, identity matrix and 1 m `fract` period are
placeholders. These make the projected tiling camera-dependent. No donor value
was invented, so this remains a gap.

### RC6 — **No donor GPU A/B exists** (COMP-03 E20 / RAG Red). Universal blocker for any parity claim.

## 3. Incorporated COMP-03 evidence

COMP-03 (`COMPLETENESS_03_donor_fidelity.md`) verified in current source:

- S1 / E1 / RAG row 2 — tile indices **TRANSLATED** (Green). Confirms Q1.
- E3 / RAG row 2b — faces **MISSING** (Red), `UV2.y=0` at `:631`; gap 2. This agent's implementation is the direct response: the RED verdict applied to the **pre-fix** source; after this change `UV2.y` is no longer constant, but the change is a **PORT APPROXIMATION**, so the honest verdict becomes AMBER, not Green — the exact vf/vs promotion rule is still ENGINE/UNVERIFIED.
- E7 / RAG row 4 / gap 3 — donor ambient/diffuse recorded but unused. Investigated and measured; not consumed because the packed light terms are engine-bound products (RC4).
- E8 / gap 3 — port sky, no clouds: **outside this module's fix scope**; no sky constant changed here.
- E20 / RAG row 15 — no donor A/B: preserved, no parity claim.

## 4. Exact diff

### `variant3d/scripts/world3d_terrain.gd`

```diff
@@ header + constants (~:17, :109-118)
+# FIX-TERRAIN: UV2.y = 0 ground / 1 front / 2 side from donor cDiff1/cDiff2 slope
+#   + aspect axis (PORT APPROXIMATION — NOT DONOR PARITY, see _face_mode_at).
+const DONOR_CDIFF1: float = 0.5   # data/scripts/common.inc/texturemap.inc:63
+const DONOR_CDIFF2: float = 0.55  # data/scripts/common.inc/texturemap.inc:64

@@ state (~:162), invalidate() (~:619)
+var _face_hist: Dictionary = {}
+_face_hist = {}

@@ new function (~:347-388)
+# PORT APPROXIMATION — NOT DONOR PARITY. Steep test from texturemap.inc:63-64,
+# :76-79, :88-129; aspect axis from :438-447, :559-575; front plane reftile.mat:130-141,
+# side plane reftile.mat:156-167. Exact vf/vs promotion ENGINE/UNVERIFIED.
+func _face_mode_at(height, w, h, x, z) -> int:
+    # abs(c-lh/rh/th/bh) > 0.5 OR diagonal cDiff2 0.55 -> steep
+    # gx=lh-rh, gy=th-bh -> 1 if abs(gy)>=abs(gx) else 2; else 0

@@ build() (~:681, :692-709)
+_face_hist = {"0": nverts}
+var face: int = _face_mode_at(height, w, h, x, z)
+if face != 0: ... update _face_hist ...
-uvs2[i] = Vector2(float(tid), 0.0)
+uvs2[i] = Vector2(float(tid), float(face))

@@ stats (~:813, :824)
-"face_model": "UV2.y=0 ground; A5 face-flag atom not landed ..."
+"face_model": "UV2.y = donor cDiff1/cDiff2 slope + aspect axis -> 0/1/2; "
+   "PORT APPROXIMATION — NOT DONOR PARITY; vf/vs promotion ENGINE/UNVERIFIED ..."
+"uv2": "x=donor tile id, y=face mode 0/1/2 ..."
+"face_hist": _face_hist.duplicate(true)
+"material_model": "... V7-86 mask blend retained (measured removal darkens) ..."

@@ _make_environment() (~:580-589)
-sun.shadow_enabled = true
+# FIX-TERRAIN — EXPLICIT USER DECISION (this wave): shadows DISABLED.
+sun.shadow_enabled = false
+sun.directional_shadow_max_distance = 400.0  # retained, now INERT

@@ terrain MeshInstance (~:751-756)
-mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
+# FIX-TERRAIN — EXPLICIT USER DECISION: OFF; no donor-grounded bounded frustum.
+mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

@@ _tileindex_material() (~:316-325)
+# FIX-TERRAIN — MEASURED, DELIBERATELY NOT CHANGED: removing the donor mask
+# blend darkened the port frame (luma 42.735 -> 38.425). Shader keeps default.
```

### `variant3d/shaders/terrain_tileindex.gdshader`

```diff
@@ face override (~:196-200)
+// FIX-TERRAIN: world3d_terrain.gd now WRITES 1/2 on donor-slope cells;
+// the per-vertex UV2.y path is live; override stays a diagnostic hatch.
@@ new diagnostic uniform (~:202-211)
+uniform float mask_to_alpha = 1.0;  // DIAGNOSTIC KNOB, SHIPPED VALUE UNCHANGED
+// Donor bmTransparency expects a second base-tile pass the port lacks, but a
+// real OpenGL A/B MEASURED that removing it darkens (bright port sky behind).
@@ attribute contract (~:217-221)
+// FIX-TERRAIN: UV2.y 1/2 promoted from donor slope+aspect; PORT APPROXIMATION.
@@ fragment (~:374-375)
-ALPHA = a;
+// FIX-TERRAIN: PORT SUBSTITUTE, not donor parity.
+ALPHA = mix(1.0, a, mask_to_alpha);   // shipped mask_to_alpha=1.0
```

## 5. Image evidence and measured statistics

All captures are **1280×720 real GPU frames** written **outside the repo**, via
the serialized runner and `Screenshot3DViewport` (full-game) or a `SubViewport`
(controlled probes). Python/PIL/numpy read-only stats.

| Capture | Ticket | Path | Bytes | non-black | mean RGB | luma |
|---|---:|---|---:|---:|---|---:|
| BEFORE full-game (shipped V7-92 + face fix not yet applied) | 257 | `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/fixterrain_before.png` | 1,636,566 | 0.99792 | [59.686, 48.800, 25.951] | 44.813 |
| V7-86 baseline, controlled terrain-only | 283 | `.../fixterrain_ab_v786.png` | 1,526,745 | 0.98503 | [42.68, 51.50, 34.02] | 42.735 |
| Face promotion live, same scene/camera | 283 | `.../fixterrain_ab_faces.png` | 1,463,946 | 0.98649 | [42.72, 51.96, 34.20] | 42.961 |
| AFTER full-game, shadows still ON | 286 | `.../fixterrain_after_full.png` | 1,743,819 | 0.99795 | [63.094, 63.866, 34.903] | 53.954 |
| AFTER full-game, shadows OFF (shipped) | 289 | `.../fixterrain_after_noshadow.png` | 1,619,954 | 0.99909 | [50.593, 53.548, 27.107] | 43.749 |

**Attribution guard.** Ticket 286/289 full-game frames are **not pixel-comparable
to ticket 257**: other agents changed `world3d_entities.gd`, `camera3d.gd`,
`main.gd` and entity colours between them (buildings changed from red debug to
natural wood; camera framing moved). Terrain-only regions of 257 vs 286 were
measured **pixel-identical** (`changed_gt8 = 0`), i.e. the captured view contains
no promoted cells — so the full-game frames cannot demonstrate the terrain fix.
The **controlled** A/B (ticket 283) holds camera, scene, atlas, water and every
uniform constant except the face override: it measured **52,887 changed pixels
(5.74%)**, max channel-sum delta 325, luma **42.735 → 42.961**, non-black
0.98503 → 0.98649. That is the only quantitative claim made for the face fix.
No donor frame exists; not an A/B against the donor.

**Rejected experiment — mask blend (published, reverted).** Ticket 281 toggled
only `mask_to_alpha` 1→0: luma **42.735 → 38.425**, non-black 0.98503 → 0.97069,
mean RGB [42.68,51.50,34.02] → [40.18,45.53,29.57]. Removing the structurally
wrong mask re-application made the terrain **darker**, because the bright port
sky is behind the semi-transparent ground. Shipped value left at 1.0.

**Rejected experiment — donor light colours.** Ticket 283 third frame
(`.../fixterrain_ab_faces_donorlight.png`): luma 43.635, non-black 0.99276 —
+0.67 luma over face-only. Not adopted: substituting `light.cfg` colours for
engine-bound light×material products is not donor-faithful.

**Shadow A/B (ticket 291).** `.../fixterrain_shadow_shadow_on.png` and
`.../fixterrain_shadow_shadow_off.png`: both 145,418 bytes, non-black 0.99883,
mean RGB [177.897,178.924,148.079], luma 168.30, **0 pixels changed >8**. This is
an honest *limitation*, not proof of the fix's visual effect: the tile shader is
`unshaded` (terrain cannot receive a Godot shadow map) and a synthetic lit
receiver in the `SubViewport` produced no visible shadow in either state. The
shadow disable is therefore justified by the user's explicit decision and the
source-level frustum/self-shadow analysis, **not** by a measurable pixel delta.

## 6. Shadow decision — exactly what was disabled

Per explicit user instruction for this wave:

1. `sun.shadow_enabled = false` in `_make_environment()` — **the DirectionalLight3D
   shadow map is off for the whole scene**, so no object can cast an unbounded
   directional streak. `directional_shadow_max_distance = 400.0` is retained but
   inert.
2. Terrain `MeshInstance3D.cast_shadow = SHADOW_CASTING_SETTING_OFF` — the
   640×640 m mesh no longer casts into any future shadow map.
3. **Preserved:** donor `SUN_POS`, `SUN_LIGHTVEC`, `DONOR_AMBIENT`, `DONOR_DIFFUSE`,
   `EXPOSURE`, `AMBIENT_ENERGY`, `SUN_ENERGY`, `WorldEnvironment`, sky colours and
   the near-vertical look-at (no sun constant invented, no axis "correction"
   guessed — engine shadow setup is UNVERIFIED).
4. **Re-enable path:** only after a bounded donor-grounded shadow frustum is
   implemented and A/B'd; then restore both lines and raise
   `directional_shadow_max_distance` to cover the map extent. Do not re-enable
   the current 400 m frustum over a 640 m self-shadowing mesh.

## 7. Verification

| Check | Ticket | Result |
|---:|---|---|
| Parse `--check-only` | 288 | ok, exit 0, 3.21 s, stderr clean |
| Temporary probe (20 checks) | 293 | ok, exit 0, 17.73 s, **20/20** — 102,400 UV2 entries; face hist `{0:95252, 1:3416, 2:3732}`; UV2.y matches hist; atlas grid (16,8); shader shadow 0; sun shadow map disabled; terrain cast off; single water plane; donor sun present |
| Full selftest | 294 | ok, exit 0, 144.02 s, `selftest.json` `passed=true`, **29/29** |
| Windowed capture | 289 | ok, exit 0, 65.56 s, real `Screenshot3DViewport` 1280×720 |
| Temp probes | — | `t_fixterrain_probe.gd`, `t_fixterrain_ab.gd`, `t_fixterrain_shadow.gd` all **DELETED**. A concurrent coordinator `step` commit tracked two of them mid-run; their subsequent `D` in `git status` is this intentional cleanup, not a shipped-file removal. This agent ran **no git command**. |

Failure tickets kept for transparency: 269 (capture blocked by concurrent
`world3d_entities.gd:384` / `camera3d.gd:410` parse errors in another agent's
in-flight edits, since fixed by their owners), 264/287/292 (probe assertion /
`float()` bugs, fixed and re-run).

## 8. Remaining gaps / handoff to TERRAIN-SMALL

1. **Small-map verification is needed and should be assigned to TERRAIN-SMALL's
   64×64 / 128×128 harness.** Expectations its probe **should assert**:
   - `mesh_vertices = w*h`, `mesh_triangles = (w-1)*(h-1)*2`, one surface;
   - `tile_index.cells = w*h` with the fixture's tileblock, UV2.x in `[0,123]`;
   - `face_hist` sums to `w*h`; front/side counts follow the fixture's known
     steep cells; **no face cells on an entirely flat fixture** (regression
     guard for the promotion rule);
   - `stats.atlas.grid = [16,8]` and one 2D atlas texture, masks bound;
   - `DonorSun.shadow_enabled == false` and `HeightmapTerrain.cast_shadow == OFF`
     at **both** map sizes (the shadow bug scales with map extent, so a small
     map is the cheapest regression gate);
   - windowed capture non-black fraction > 0.9 and no full-width dark streaks
     attributable to shadows.
   This agent deliberately did **not** build small-map fixtures (TERRAIN-SMALL's
   exclusive scope).
2. Exact donor vf/vs promotion rule, eye-plane values, alpha sub-rect mapping,
   SM20/SM30 profile and shadow matrix remain ENGINE/UNVERIFIED.
3. Tile histogram / atlas art / water darkness are outside these two files.
4. Donor ambient/diffuse remain unused (measured, justified in RC4); sky/clouds
   untouched (COMP-03 E8).
5. No donor GPU A/B: visual parity UNVERIFIED everywhere.

---

*End of report. FIX-TERRAIN edited only the two owned source files and this
report; no atlas/loader/water/app/config/test/git state was touched. Temporary
probes were deleted; the selftest runner rewrote `variant3d/selftest.json` as its
mandated output.*
