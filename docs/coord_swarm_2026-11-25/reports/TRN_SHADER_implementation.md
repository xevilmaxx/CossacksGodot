---
id: TRN-SHADER
title: "Donor-grounded terrain shader fix — world texgen + donor sun + 64² alpha patch grid"
date: 2026-11-25
status: DELIVERED__ONE_SHADER_EDITED__HEADLESS_SMOKE_GREEN__NO_DONOR_EXECUTED
scope: "Exactly two owned files touched: variant3d/shaders/terrain_tileindex.gdshader and this report. Required backup written to inbox/backup/. No other file edited."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; light.cfg, dmscript.global, reftile.lib / .mat read as latin-1 text this agent; nothing copied, executed or rendered)"
owner_file: "variant3d/shaders/terrain_tileindex.gdshader"
backup: "inbox/backup/terrain_tileindex.gdshader.bak-TRNSHADER"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
smoke_job: {id: trnshader-smoke, ticket: 342, runner: "variant3d/tools/godot_runner.py", status: ok, exit: 0, stderr_bytes: 0, script_errors: 0, atom_result: "t_terrain3d PASS 6/6"}
parity_claim: false
---

# TRN-SHADER — donor-grounded terrain shader implementation

## 0. Mandate and evidence base

Implement the TRN-SHADER row of `PLAN_IMPLEMENTATION.md:30` in **one** owned shader:
world-ground texgen, the real donor sun, and the confirmed 8×4 grid of 64² alpha
patches, without inventing constants or adding effects the donor lacks.

Read first (all under `docs/coord_swarm_2026-11-25/`): `GAPS.md` §2 (Texgen / Lighting /
Alpha rows), `reports/DTRN_01_donor_terrain_pipeline.md` (C6/C7/C15–C19/M2/M4/M5/M7),
`reports/RV_TRN_01_texgen_mask_reverify.md` (verdicts A/B/C/D; §4.1 seam proof),
`reports/DTRN_06_donor_grass_decals.md` (C11–C17, M1–M4/M10),
`reports/V3D_02_terrain_render_audit.md` (P2/P3/P4/P7; F1/F2/F4), and the full
shader. Donor files used below were re-read read-only this agent (`light.cfg`,
`dmscript.global:165-176`, `reftile.lib`). No donor binary was executed or copied.

Backup taken **before** the first edit:
`inbox/backup/terrain_tileindex.gdshader.bak-TRNSHADER` — 20,579 B, SHA-256
`8ADD6027488C52E4B5108BED866EF2CB189AB9BD99FCE9A6202C0387A7999263`, identical
to the pre-edit shader (verified by hash before editing).

## 1. Claim / change table

`observed` = literal donor byte/line re-read this agent or cited published measurement;
`derived` = arithmetic on observed values; `PORT APPROXIMATION` / `UNVERIFIED` = no
donor literal exists. **No claim of donor GPU parity is made anywhere.**

| # | Change in `terrain_tileindex.gdshader` | Donor citation | Label |
|---|---|---|---|
| A1 | Ground texgen `POSITION` switched from eye-space `realpos` to `MODEL_MATRIX * VERTEX` (world X/Z); planes `eye_plane_s=(1,0,0,0)`, `eye_plane_t=(0,0,1,0)`; `fract()`/texture-matrix/filter intent kept | Equation shape `hf.pvl.sm.vert:9,30-32` (`texGen=true`, `shaders.lib:30`); ground material is `tmmUser` S/T=(1,0,0,0)/(1,0,0,0), `TextureScale=1` (`reftile.mat:34,38-48`); runtime eye planes `CONFIRMED_UNVERIFIED` (`RV-TRN-01` verdict A) | **PORT APPROXIMATION** (stable world substitute; not a donor literal). Donor scale below is donor-grounded. |
| A2 | `uv_repeat` `(1,1) -> (0.5,0.5)` = 1 / 2 m ⇒ one atlas cell per 2 m of ground | `gc_meters_to_tile = 2`, `data\scripts\dmscript.global:171` (read verbatim this agent; corrects older DTRN-01 C6 "metres UNVERIFIED" via DEC-05) | **observed** donor constant; its application to our world XZ texgen is a PORT APPROXIMATION. |
| B1 | `light_position_eye = 0` headlight removed: new `donor_sun_position = (-0.344731152057648, 0.938701450824738, 0.0)`; `l = normalize(VIEW_MATRIX * vec4(sun_world,0))` — constant parallel direction, **no** `realpos` subtraction | `light.cfg:26-31` Position (read verbatim); `LightStyle = lsParallel` (`light.cfg:17`); `hf.pvl.sm.vert:13` equation shape | donor vector **observed**; eye-space/axis treatment **PORT APPROXIMATION / UNVERIFIED**. |
| B2 | Z-up→Godot Y-up sun conversion `sun_world = normalize(vec3(x/4, z/2, y))` | `water.dev.vert:22` (`lightVector=(LightPos.x/4, LightPos.z/2, LightPos.y)`) and the already-cited port translation `world3d_terrain.gd:100-101` | **derived / PORT APPROXIMATION** (engine's own light transform UNVERIFIED). |
| B3 | `ambient_rgb` `0.15686 -> (0.196078434586525, 0.184313729405403, 0.129411771893501)`; `diffuse_rgb` `0.78125 -> (0.811764717102051, 0.780392169952393, 0.694117665290833)` | `light.cfg:2-7` Ambient, `light.cfg:9-14` Diffuse (read verbatim) | **observed** donor literals; energy multiplication with material terms UNVERIFIED. |
| B4 | `unshaded` **KEPT**, shadows **still OFF** | Shader writes the donor final colour at `hf.pvl.smx3.frag:50` after `hf.pvl.sm.vert:37-38` packing and `:17,:20-30,:34-46` combines; shadow-OFF is the recorded A/B decision (`V3D_02` "already correct" #7) | deliberate PORT render-mode decision (donor has no `unshaded` flag). |
| C1 | Flat-mask sampling changed from whole `alpha_atlas` at `fract(v_st)` to ONE 64² sub-rect via new `alpha_patch_uv()`; `v_alpha_uv` uses the same 2 m phase | 512×256 `alpha.bmp` = **8 cols × 4 rows of 64²** patches: seams only at x/y multiples of 64 (mean |ΔI| 64–185 vs ~8 interior) — `RV-TRN-01 §4.1`, `DTRN_06 C15`; commented donor `AlphaRows=8, AlphaCols=4, AlphaTileSize=64`, `reftile.lib:10-12` | grid geometry **derived/confirmed**; **tile→patch index UNVERIFIED** (`RV-TRN-01` verdict B). |
| C2 | Deterministic approximate tile→patch map `5 + mod(abs(tile),22)` and half-texel inset `0.5/64 = 0.0078125` | 28 graded patches 5..26 avoid the constant-255 patches 0/4 and constant-0 patches 27/31 measured in `RV-TRN-01 §4.1`; inset uses donor `AlphaTileSize=64` (`reftile.lib:12`) | **PORT APPROXIMATION / UNVERIFIED** — no donor mapping is asserted; sentinel avoidance is a safety guard. |
| C3 | Face-alpha eye planes kept and explicitly restored/cited: front S=(1,0,0,0) T=(0,0,1,0), side S=(0,1,0,0) T=(0,0,1,0), `face_scale=0.125` | `reftile.mat:130-141,156-167`; `TextureScale=0.125` `reftile.mat:124-126,150-152`; `RV-TRN-01` verdict C / §4.3 | donor literals **observed**; Z-up→Y-up axis conversion remains PORT APPROXIMATION. |
| C4 | `mask_to_alpha = 1.0` **unchanged** | donor `bmTransparency` (`reftile.mat:17`) pass count CONFIRMED_UNVERIFIED (`RV-TRN-01` D); measured A/B removing it darkens luma 42.735→38.425 (`V3D_02` P7) | measured diagnostic; deliberately not removed. |
| D | No normal map, foam, anisotropy, dither/noise/mottle, shadow enable, or other new effect | donor has none: `shaders.lib:19` + `hf.pvl.sm.vert:15` (no tangent map); `DTRN_01` C15/C16/C18; `DTRN_06` C22/M10 | declaration honoured (§6). |

## 2. Before → after summary

| Aspect | Before (backup) | After (shipped edit) |
|---|---|---|
| Ground UV source | `dot(eye-space realpos, (1,0,0,0)/(0,1,0,0))`, identity matrix, repeat 1 ⇒ t mixed height+view depth, 1 m `fract` period, camera-swimming | `dot(world MODEL_MATRIX*VERTEX, (1,0,0,0)/(0,0,1,0))`, repeat 0.5 ⇒ stable world XZ ground, 2 m/cell, `fract`/filter intent intact |
| Sun / colour | `light_position_eye=0` ⇒ `l ≈ -normalize(realpos)` headlight; material ambient 0.15686 / diffuse 0.78125 | donor sun vector + `lsParallel` constant direction; donor ambient/diffuse colours; still one in-shader Blinn-Phong combine |
| Alpha mask | whole 512×256 atlas sampled at `fract(v_st)` | one donor 64² patch per tile from the confirmed 8×4 grid; tile→patch map explicitly UNVERIFIED |
| Face mask | donor planes/scale already present but not flagged as recovered | unchanged math; comments now cite the recovered donor literals (`RV-TRN-01` C) |
| `unshaded`, shadows, fog, mask-to-alpha, PCF taps, tile atlas path | shipped values | **unchanged** |

Why `unshaded` stays: the donor heightfield shader already computes the final lit
colour in the vertex/fragment pair and writes it at `hf.pvl.smx3.frag:50`. This
shader reproduces that final colour (ambient+diffuse packed, specular, PCF, fog)
and now feeds the *donor* sun into it. Enabling Godot lighting would shade ALBEDO
a second time. The donor has no `unshaded` flag — this is a port render-mode
choice, not a donor configuration value. Shadows remain disabled per the explicit
prior A/B decision; no bounded donor-grounded frustum exists to justify enabling.

## 3. Validation (variant runner only)

Command (exactly the sanctioned headless smoke path):

```
python variant3d\tools\godot_runner.py run --id trnshader-smoke --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Field | Result |
|---|---|
| Job id / ticket | `trnshader-smoke` / **342** |
| Runner status / exit | `ok` / **0** (wait 76.34 s, run 14.34 s) |
| stderr | **0 bytes** ⇒ `SCRIPT ERROR == 0` (no shader/GDScript parse or compile error reported) |
| stdout | `T_TERRAIN3D PASS 6/6` (`module_load_and_api`, `build_ok`, `surface_count`, `vertex_count`, `has_chunk_or_fallback`, `height_at_world_samples`) |
| Result file | `variant3d\.godot_queue\results\00000342.json`; logs in `00000342_trnshader-smoke\` |

No transient error attributed to another builder's file was observed in this job.
No full gates, no windowed piece-test ladder, and no direct `godot` invocation were
performed (COORD owns those). This smoke proves parse/build/geometry health, **not**
visual parity or that a GPU-level donor A/B exists.

## 4. What remains APPROX / UNVERIFIED

1. **Ground eye-plane and texture-matrix values** — CONFIRMED_UNVERIFIED (`RV-TRN-01`
   verdict A: no assignment in 12 binaries or 16,564 text files; engine `.bind`
   entropy 7.96). World XZ planes are stable substitutes, never donor literals.
2. **Tile id → 64² alpha patch index** — UNVERIFIED (`RV-TRN-01` verdict B). The
   grid geometry is donor-confirmed; `5 + mod(tile,22)` is a deterministic
   approximation chosen to avoid the measured sentinel patches.
3. **Sun direction space / engine light transform** — `light.cfg` Position is a
   donor literal, but whether the engine feeds its eye-space `gl_LightSource` as
   direction or point, and whether the `/4`,`/2` mapping applies to terrain (it is
   cited from the water shader), remain UNVERIFIED. Prior raw-colour swap measured
   only +0.9 luma (`V3D_02` P3), so the new lighting is not claimed as parity.
4. **Face promotion rule and 25° `AngleX/AngleZ` path** — UNVERIFIED and out of
   this ticket's scope (`TRN-FACE` / `world3d_terrain.gd` owner).
5. **`bmTransparency` pass count** — CONFIRMED_UNVERIFIED (`RV-TRN-01` D);
   `mask_to_alpha` remains a measured diagnostic knob.
6. **No donor GPU A/B exists** — every visual statement here is structural; the
   acceptance criteria of `PLAN_IMPLEMENTATION.md:30` (pan/zoom texel displacement
   ≈0, luma/contrast delta, no dark streak) require the F0 baseline + T0/T5
   captures owned by COORD and are NOT claimed here.

### Needs reported to other owners (no edit made by this agent)

- `world3d_terrain.gd:810-812` stats string `uv_model` still describes the old
  "eye-plane dot(realpos,...) + fract" model and is now stale. The owning builder
  (`TRN-FACE` / terrain-module owner) should update it to world-ground XZ / 2 m.
- No **new uniform binding is required** for this implementation: all new/changed
  uniforms (`donor_sun_position`, `ambient_rgb`, `diffuse_rgb`, `eye_plane_t`,
  `uv_repeat`) have donor-cited defaults, and `_tileindex_material()`
  (`world3d_terrain.gd:303-325`) binds none of them. If the team later wants the
  sun to come from the live `DonorSun` node rather than the donor-cited default,
  that owner must add `set_shader_parameter()` calls for those three uniforms.
- Shadow state is consistent: `world3d_terrain.gd:315` already binds
  `shadow_enabled=0`, matching the unchanged shader default.

## 5. Constant provenance index (no invented numbers)

| Constant in shader | Value | Source |
|---|---|---|
| metres per tile → `uv_repeat` | 2 → 0.5 | `dmscript.global:171` (observed) |
| donor sun position | (-0.344731152057648, 0.938701450824738, 0) | `light.cfg:26-31` (observed) |
| light style | `lsParallel` | `light.cfg:17` (observed) |
| sun axis mapping | (x/4, z/2, y) | `water.dev.vert:22`; `world3d_terrain.gd:101` (derived, APPROX for terrain) |
| ambient | (0.196078434586525, 0.184313729405403, 0.129411771893501) | `light.cfg:2-7` (observed) |
| diffuse | (0.811764717102051, 0.780392169952393, 0.694117665290833) | `light.cfg:9-14` (observed) |
| specular / shininess | 0 / 16 | `reftile.mat:70-74,98-102` / `:76,:104` (observed, unchanged) |
| face scale | 0.125 | `reftile.mat:124-126,150-152` (observed, unchanged) |
| face planes | front S=(1,0,0,0) T=(0,0,1,0); side S=(0,1,0,0) T=(0,0,1,0) | `reftile.mat:130-141,156-167` (observed, unchanged) |
| alpha grid | 8×4×64² | `reftile.lib:10-12` (commented donor default) + `RV-TRN-01 §4.1` pixel proof |
| patch map / inset | `5 + mod(tile,22)` / 0.5/64 | UNVERIFIED approximation; 64 from `reftile.lib:12`; sentinel patch ids from `RV-TRN-01 §4.1` |
| mask_to_alpha / shadow_enabled | 1.0 / 0.0 | measured A/B `V3D_02` P7 / explicit shadow-OFF decision (unchanged) |

## 6. No-forbidden-change declaration

I did **not** add a terrain normal map, a foam image, anisotropic filtering, any
synthetic dither/noise/mottle/gain field, any new shadow setting, or any invented
physical constant. Every numeric value introduced is either a verbatim donor
literal with a `path:line` citation above or a clearly labelled deterministic
approximation derived from a donor-cited grid size (64) / donor scale (2 m).
Shadows remain OFF. The donor tile-index/atlas/mask R→A/mesh/water paths and the
`mask_to_alpha` diagnostic were left intact.

**No other file was edited.** The only tracked file changed by this agent is
`variant3d/shaders/terrain_tileindex.gdshader`; this report is the only other new
owned file; the backup listed in frontmatter is the required pre-edit copy.
Concurrent modifications by other builders (`world3d_terrain.gd`, `water3d.*`,
`input_controller.gd`, tests, etc.) visible in `git status` were **not** touched,
reverted, or re-submitted by this agent.

## 7. Open questions

1. What runtime values does the engine write to `gl_EyePlaneS/T[0]` and
   `gl_TextureMatrix[0]` for the ground refkey? (blocks parity for A1/A2)
2. Which of the 32 (practically 28 graded) alpha patches does each donor tile id
   select, and how do `tsDouble`/`ttExtended` + `TileXOffset=0.1`/`TileYOffset=0.2`
   compute it? (blocks parity for C1/C2)
3. Does the donor multiply `light.cfg` colours by the material ambient/diffuse
   energies (`gl_FrontLightProduct`) before packing, and in what coordinate space
   is `gl_LightSource[0].position`? (blocks parity for B1/B3)
4. Is the water-shader `lightVector` scaling (`/4`,`/2`) also applied to terrain
   lighting, or is it water-specific? (B2)
5. What promotes a base tile to `rockNvf`/`rockNvs` and how is `AngleX/AngleZ=25`
   applied? (TRN-FACE scope)
6. How many `bmTransparency` passes does the fixed-function renderer emit, with
   which blend factors? (C4)
7. Can a permitted donor GPU A/B frame ever be produced? Without it, the
   `PLAN_IMPLEMENTATION.md:30` acceptance tests remain unrun by this ticket.

---

*End of TRN-SHADER implementation report. One shader edited, one backup copied, one
report written; headless smoke green; no donor binary executed or copied; no visual
parity claimed.*
