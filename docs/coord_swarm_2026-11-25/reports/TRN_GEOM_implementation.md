---
id: TRN-GEOM
title: "Implementation — donor-grounded terrain geometry / face / environment fix (world3d_terrain.gd)"
agent: TRN-GEOM (implementation builder, coordination swarm 2026-11-25)
date: 2026-11-25
status: DONE — parse smoke clean; no gates / ladder / direct godot
owner_files:
  - variant3d/scripts/world3d_terrain.gd
  - docs/coord_swarm_2026-11-25/reports/TRN_GEOM_implementation.md
backup: inbox/backup/world3d_terrain.gd.bak-TRNGEOM
backup_sha256: E255059F516C84C2873EF7918BB06821D85EDDE2AD431826E164E25A00DFF9BF
smoke_job: ticket 361 / `--id trngeom-smoke` — runner END ok, run 5.80 s, stderr.txt 0 bytes, SCRIPT ERROR == 0
earlier_smoke: ticket 350 / same id — runner END ok, run 7.33 s (pre-handoff state)
verdict: DONOR_LITERALS_IMPORTED__PARITY_UNVERIFIED__TOPOLOGY_UNCHANGED
labels: [observed, derived, inferred, UNVERIFIED]
---

# TRN-GEOM — donor-grounded face / environment / normal implementation

## 0. Scope and ownership

**Only two files were edited**: `variant3d/scripts/world3d_terrain.gd` (exclusive
ownership) and this report. The terrain shader (`terrain_tileindex.gdshader`),
water shader and `water3d.gd`, all test files, configs and docs outside this
report were **NOT edited**. Donor material was **read in place only** (`C:\Games\Cossacks 3`,
read-only Python/PowerShell text reads); no donor binary was executed or copied.

Guard list honoured (GAPS.md §3, PLAN_IMPLEMENTATION.md §2): no redo of the mesh
structure, `HEIGHT_SCALE`, live tile-index path, atlas grid, mask R→A repack, or
camera seam. Fog stays default OFF; shadows stay OFF by the recorded explicit
A/B decision. Relief-grid stamping from `.pattern` files is a **separate ticket**
(§7) and was not attempted.

## 1. Read-first evidence base

| Source | What it supplied |
|---|---|
| `GAPS.md` §2 Geometry/Cliffs/Light rows (`docs/coord_swarm_2026-11-25/GAPS.md:33,37,41`) | gap ranking; "do not redo mesh/height scale", "import donor light/sky", "25° tilt not applied" |
| `reports/DTRN_02_donor_terrain_geometry.md` C12/C13/C14/C17/C19/C20 (`:108-116`) | collision thresholds, rock art gates, normals per-vertex, LOD UNVERIFIED, metre scale |
| `reports/RV_TRN_01_texgen_mask_reverify.md` verdict C (`:185-196,206,254`) | exact `vf`/`vs` literals, 36+36 blocks, face alpha planes + 0.125; promotion rule UNVERIFIED |
| `decomp/DEC_03_configs.md` §4.3/§4.4 (`:168-193,222-242`) | `light.cfg` ambient/diffuse/specular/position; `skydome.cfg` band colours |
| `reports/V3D_02_terrain_render_audit.md` P3/P5/P8/F2/F5 (`:88,90,93,125,128`) | headlight, partial face promotion, smoothed normals |
| `PLAN_IMPLEMENTATION.md` TRN-FACE row (`:33`) | 25° tilt + h overrides + recovered face planes, labelled APPROX |
| `reports/DTRN_01_donor_terrain_pipeline.md` C12/C13/C19/C20 (`:126-127,133-134`) | 8-sector aspect, cliff names, fog OFF by default |
| Donor read-only `data\scripts\common.inc\texturemap.inc:433-448,463-472,474-529,559-601` | **exact** sector tables and height gates (transcribed verbatim) |
| Donor read-only `data\terrain\tiles\tiles.lib:119-296,543-719`, `tiles.mat:142-210`, `reftile.mat:120-170` | `vf`/`vs` metadata, refkey bindings, eye planes, scale |
| `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:41-46` + `structs/presets_summer.json:2-125` | donor name↔index dictionary (sandsea1=93, sandsea5=97, sandsea6=98, rock4=20/59/60, rock7/8=23/24/65..68) |

## 2. Claim table (labels per GAPS.md §4)

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | `rockNvf AngleX=0 AngleZ=25`; `rockNvs AngleX=25 AngleZ=0`; 36 vf + 36 vs blocks | `tiles.lib:119-296,543-719`; RV-TRN-01 `:110-113,187-192` | **observed** |
| 2 | Donor never *selects* vf/vs in a readable script; engine application of 25° unknown | RV-TRN-01 `:114-115,193-196` verdict C | **UNVERIFIED** |
| 3 | Face alpha planes front S=(1,0,0,0) T=(0,0,1,0), side S=(0,1,0,0) T=(0,0,1,0), scale 0.125 | `reftile.mat:120-170`; RV-TRN-01 `:113,191-192` | **observed** |
| 4 | Cliff gate `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none` | `texturemap.inc:594-601`; DTRN-01 C13 | **observed** |
| 5 | Land cliff 6-sector → bRB/bLB/bR/bB/bT/bL → rock4/7/4/1/4/3 | `texturemap.inc:559-591` (verbatim read) | **observed** |
| 6 | Shore 8×45° (after `vecangle+=180`) → sandsea1/5/6 by sector | `texturemap.inc:463-472,474-529,503-511` | **observed** |
| 7 | `BLK_WATER=255` was clamped to tile 0 (`grass1`) in the port | prior `world3d_terrain.gd:697-702` (pre-edit); `t_terrain_shore.gd:837-841` | **observed** (port) |
| 8 | Light colours ambient (0.196,0.184,0.129), diffuse (0.812,0.780,0.694), specular (0.278,0.267,0.212), position (−0.3447,0.9387,0,1) | `light.cfg:3-6,10-13,20-23,26-29`; DEC-03 §4.3 | **observed** |
| 9 | Sky band colours pale (0.6,0.7765,0.9922) / deep (0,0.1412,0.8078) | `skydome.cfg:11-40`; DEC-03 §4.4 | **observed**; dome→gradient mapping **inferred/APPROX** |
| 10 | Fog default palette `FogMode=0` | `colors.lib:23,34-43`; DTRN-01 C20 | **observed** |
| 11 | 1-cell normals; `TILE_M=2.0` donor-grounded by `gc_meters_to_tile=2` | DTRN-02 Step 5 (`:401-404`); `dmscript.global:171` via DEC-05 | **derived** |
| 12 | Donor surface-mesh LOD / engine blend of 25° into geometry/texgen | DTRN-02 C19; RV-TRN-01 verdict C | **UNVERIFIED** |
| 13 | Donor ground `gl_EyePlaneS/T[0]` and `TextureMatrix[0]` values | RV-TRN-01 verdict A (CONFIRMED_UNVERIFIED) | **UNVERIFIED** |
| 14 | Mask B gate for shore cells in the port | `texturemap.inc:464` needs `gMapMask[ix,iy].b`; port has no readable mask B | **UNVERIFIED** |

## 3. Before → after (owned file only)

| Area | Before | After (with citation / label) |
|---|---|---|
| Face tilt | `stats.face_model` said "25-degree AngleX/AngleZ remains metadata only"; no tilt applied | `DONOR_FACE_TILT_DEG=25`; promoted cells pick donor `rockNvf`/`rockNvs` atlas cell and get a 25° NORMAL tilt (about Z for vf, about X for vs). `tiles.lib:119-296,543-719`. **PORT APPROXIMATION** — promotion/selection rule UNVERIFIED. No vertex/index change. |
| Face alpha planes | Shader already had front S/T, side S/T, `face_scale=0.125` at `terrain_tileindex.gdshader:309-318` | **Verified read-only, already applied**; module now binds `face_scale = DONOR_FACE_SCALE = 0.125` explicitly. Shader file NOT edited (other owner). |
| Rock height overrides | none | `_donor_cliff_name()` gates `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→no cliff tile` (`texturemap.inc:594-601`), then applies the exact 6-sector cliff table (`:559-591`). |
| Shore orientation | none; water sentinel → `grass1` | `_donor_shore_name()` exact 8-sector table (`texturemap.inc:474-529,503-511`); water sentinel 255 and existing `sandsea*` reoriented to `sandsea1/5/6` via manifest names (93/97/98). Flat-water fallback `sandsea1` labelled PORT APPROX. Water literals −0.25/−0.1/2.96 and coastfade 0.57/1.07 untouched; no foam/new texture. |
| Ambient light env | port `Color(0.86,0.88,0.82)` | `DONOR_AMBIENT` from `light.cfg:3-6` (DEC-03 §4.3). Energies remain M0.6 PORT APPROX. |
| Sun colour / position | default white sun; position only in rig | `sun.light_color = DONOR_DIFFUSE` (`light.cfg:10-13`); `donor_sun_position` uniform bound with the raw `SUN_POS` (`light.cfg:26-29`, TRN-SHADER handoff). |
| Specular | shader default `vec3(0)` | `DONOR_SPECULAR` bound to shader `specular_rgb` (`light.cfg:20-23`). **PORT APPROX**: donor material specular is 0 (`reftile.mat:98-102`), light-product term engine-bound. |
| Sky colours | port-tuned `0.18/0.30/0.42` etc. | donor sky band colours from `skydome.cfg:11-40` via DEC-03 §4.4; **band→gradient mapping is PORT APPROXIMATION** (observed colours, inferred mapping). Curves stay port-tuned. |
| Fog / shadows | OFF / OFF | unchanged: `fog_mode=0` bound explicitly (`colors.lib:23,34-43`), `shadow_enabled=0`, `cast_shadow=OFF`. |
| Normals | central diff over `2*TILE_M` | 1-cell forward diff (backward at last row/col); `TILE_M=2.0` unchanged (`gc_meters_to_tile=2`). Vertex/index/surface counts unaffected. |
| `uv_model` stats | stale "eye-plane dot(realpos…)" | updated to TRN-SHADER world-XZ texgen `eye_plane_s=(1,0,0,0)`, `eye_plane_t=(0,0,1,0)`, `uv_repeat=(0.5,0.5)`, labelled PORT APPROX / donor values CONFIRMED_UNVERIFIED (value-only stats string). |
| Diagnostics | no face/rock/sector/light stats | `stats.face_tilt`, `face_alpha_planes`, `rock_height_overrides`, `sector_tiles`, `water_shore_tiles`, `light_cols` added; `donor_references` extended. |

**Topology invariants**: `mesh_vertices = w*h`, `mesh_triangles = (w-1)*(h-1)*2`,
`mesh_surfaces = 1` are not touched — at 64² these remain 4,096 / 7,938 / 1.
`face_hist` still sums to `nverts` and still matches UV2.y exactly; flat fixture
still promotes 0 cells (shore gate is false at h=0). UV2.x stays ≤ 123 (shore ids
93/97/98; vf/vs ids 53–70; rock ids ≤ 68).

## 4. Implementation notes

- Domain helpers added in the owned file: `_donor_aspect_deg()` (donor signed
  `VectorAngle` equivalent), `_donor_cliff_name()` (6-sector + height gates),
  `_donor_shore_name()` (8-sector), `_tile_index_for_name()` (manifest layout
  lookup), `_tilt_face_normal()` (25° literal on normals only), `_normal_at()`
  (1-cell stencil).
- The name↔index tables come from the V7-85 manifest `layout` array, which
  points at `presets_summer.json:2-125` ← donor `terrain.presets:2-6`. No index
  is hard-coded; if a manifest layout is missing, overrides no-op and stats
  report zero cells.
- Cross-owner compatibility: TRN-WATER's `water_surface_y`, `water_cell` alpha
  gate and removed `shore_prox` are untouched; TRN-SHADER's world-XZ texgen and
  new uniforms are consumed, not edited. No donor water literal was changed.
- Diff size: 384 insertions / 35 deletions, mostly donor citations and
  auditable stats; no renames, no new files except this report.

## 5. Validation

| Job | Command | Result |
|---|---|---|
| 350 (pre-handoff) | `python variant3d\tools\godot_runner.py run --id trngeom-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` | END ok, 7.33 s |
| 361 (final, both handoffs applied) | same command | END ok, 5.80 s; `variant3d/.godot_queue/results/00000361_trngeom-smoke/stderr.txt` = 0 bytes; **SCRIPT ERROR == 0** |

No gates, no piece ladder, no full 29/29 or 17/17, no direct `godot`, no
screenshots. Other builders were editing concurrently (`config.gd`,
`input_controller.gd`, `menu.gd`, test atoms, shader/water files). **No transient
foreign error appeared in either smoke**; no foreign change was reverted.

## 6. Backup

`inbox/backup/world3d_terrain.gd.bak-TRNGEOM` created **before** the first edit.
SHA-256 `E255059F516C84C2873EF7918BB06821D85EDDE2AD431826E164E25A00DFF9BF`
matches the pre-edit file. The working copy retains the original line-ending
style (git's LF/CRLF warning is only autocrlf advice, not a content change).

## 7. Left open / separate tickets

1. **Relief-grid stamping from `.pattern` files** — SEPARATE TICKET, deliberately
   not attempted. DTRN-02 C6/C7 and Step 1–2 (`:372-387`): each `.pattern` embeds
   a `w*h` float32 height grid after the occupancy mask with per-pattern
   `HeightFieldScale/Min/Max/Smooth*`; exact byte offset is ±16 B and engine
   blend (`Replace`/`Smooth`) is UNVERIFIED (DTRN-02 Q1/Q2). Owned by the
   sim/mapgen data lane, not by the terrain module.
2. **Exact vf/vs promotion rule** — UNVERIFIED (RV-TRN-01 verdict C). The port
   still uses `cDiff1=0.5/cDiff2=0.55` as its promotion gate; APPROX label kept.
3. **Donor ground eye planes / texture matrix** — CONFIRMED_UNVERIFIED (RV-TRN-01
   verdict A). World-XZ texgen stays PORT APPROXIMATION, NOT donor parity.
4. **Mask-B shore gate** — donor requires `gMapMask[ix,iy].b>0`
   (`texturemap.inc:464`); not readable here, so height + tile-family gate is
   APPROX. No claim of donor-exact shore *placement*, only donor-exact sector
   *table*.
5. **`sandrock*` rocky-coast orientation** — art ids exist (87–92) but the cited
   donor lines assign `sandsea1/5/6` only; no donor rule was invented.
6. **Winter tile suffix** (`texturemap.inc:525-526,:605-606`) — not applied;
   the port atlas dictionary used here is summer-only (`presets_summer.json`).
7. **GPU donor A/B** — none exists; every visual statement above is a prediction,
   not a parity claim.

## 8. Open questions

- How does the donor engine actually apply `AngleX/AngleZ=25` — geometry tilt,
  texgen rotation, or atlas orientation? No script assigns vf/vs names.
- Does the donor shore branch see the same `height[]` the 3D mesh visualises,
  and what is the exact mask-B footprint at a shoreline cell?
- Is `sandsea1` an acceptable flat-water fallback, or should a dedicated port
  water tile be added (would need a new art asset — out of scope)?
- What are the runtime eye-plane/texture-matrix values for the ground `normal`
  refkey (only a live GL trace can answer)?
- Does restoring donor specular into an otherwise `unshaded` shader overstate
  highlights relative to the donor material (specular = 0 in `reftile.mat`)?
  No donor A/B exists to decide.

## 9. Summary

Donor face literals, cliff/shore sector tables, rock height gates, light and sky
colours, and 1-cell normals were imported into `world3d_terrain.gd` with exact
citations and explicit APPROX/UNVERIFIED labels. The `BLK_WATER → grass1` shoreline
defect (TRN-WATER handoff) and the sun/lighting uniform bindings + stale stats
label (TRN-SHADER handoff) were closed in the same file. Mesh topology, height
scale, live tile-index plumbing, atlas/mask contract, water literals and camera
seam were left untouched. Parse smoke job 361 is clean (`SCRIPT ERROR == 0`);
visual parity remains UNVERIFIED. **No other file was edited.**
