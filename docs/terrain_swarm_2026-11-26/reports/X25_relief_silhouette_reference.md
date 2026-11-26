---
id: X25
ticket: "TERRAIN-SWARM-2026-11-26 / X25 — quantitative silhouette reference for converted relief, tree and mine props"
agent: "X25 (DONOR-FIRST terrain swarm, read-only analysis worker)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_OR_ASSET_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X25_relief_silhouette_reference.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope: "Python read-only OBJ/JSON parse + system-Pillow orthographic contact sheets. Repo writes: ONLY this report. Generated PNG/JSON/scripts live solely in %TEMP%\\opencode\\silhouette_ref\\. Donor at C:\\Games\\Cossacks 3 never executed, copied or committed. No Godot process, no runner job, no gate/capture run."
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md
  - docs/terrain_swarm_2026-11-26/reports/V07_relief_asset_readiness.md
  - docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md (listed; not read this ticket)
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58,122-130). Every silhouette number below is a GEOMETRIC reference for internal I09 checking, never a donor-parity verdict. NO PARITY CLAIM."
tools: "Python 3.14.3 (C:\\Python314\\python.exe), Pillow 12.1.1 (C:\\Users\\Maxym.Oboyshev\\AppData\\Roaming\\Python\\Python314\\site-packages\\PIL). Bundled cp313 Pillow deliberately avoided."
---

# X25 — relief / tree / mine silhouette reference (read-only, quantitative)

> [!IMPORTANT]
> `[O]` = literal on-disk byte/line/file read this pass · `[D]` = arithmetic or set
> consequence of observed values · `[I]` = best reading without an engine run ·
> `[U]` = UNVERIFIED · `PORT APPROXIMATION` = explicit port substitute, never donor truth.
> Donor paths are under `C:\Games\Cossacks 3\`; local paths are repo-root-relative.
> **No donor binary was run or copied; no Godot job was submitted; only this report was
> written inside the repo. NO DONOR PARITY CLAIM.**

---

## 1. Executive summary

1. **[O] Exact geometry recovered.** Four relief OBJs at
   `variant3d/assets/models/obj/shared/terrain/terrainmesh{1..4}.obj` parse to
   **9,620 vertices / 19,162 triangular faces total**. Raw donor-unit bounding boxes
   (Z-up) are `[-14.021,13.888]×[-13.524,13.446]×[0.070,7.449]` (mesh1),
   `[-13.227,13.092]×[-12.666,12.954]×[-0.025,8.035]` (mesh2),
   `[-12.935,12.988]×[-12.839,12.976]×[0.011,9.550]` (mesh3) and
   `[-12.670,12.670]×[-12.828,12.828]×[0.013,6.933]` (mesh4). Computed bboxes agree with
   `variant3d/assets/models/manifest.json` to **≤ 4.4×10⁻⁷ donor units** and with vertex
   and face counts exactly — the manifest is a faithful mirror of these OBJs, not an
   independent donor decode (§5 pass M1). `[O]`/`[D]`
2. **[D] Height/width ratios differ meaningfully:** 0.264 (mesh1), 0.306 (mesh2),
   **0.368 (mesh3, the tallest at Z-span 9.540)**, 0.270 (mesh4). Z-span range is
   **6.920–9.540** donor units; the manifest's `bbox_m` note values 6.92/7.38/8.06/9.54
   are the **spans**, not `zmax` (spans match within 0.0015; `zmax` differs by up to
   0.0685). A04's "6.93–9.55" wording is the `zmax` frame; both readings are recorded so
   I09 does not mix them. `[D]`
3. **[D] The 20 port-stampable sections are asymmetric in readiness.** Of 45 stampable
   records in `variant3d/assets/terrain/mountain_props.json`, **22 records in 7 `g_mnt_*`
   sections resolve to converted sids** and can render; **23 records in 13 `desert_mnt_*`
   sections point at `terrainmeshdesert1..4`, which have no converted sid** and are
   incremented as `skipped_unknown_sid` by `world3d_relief.gd:166-167`. I09 must expect
   zero silhouette from 13 of the 20 stampable sections on a green-map seed. `[O]`/`[D]`
4. **[D] Expected silhouette under the landed consumer contract is bounded.**
   `world3d_relief.gd:232-234` applies only the authored scale (`sx`, 0.4460–0.6400 on
   renderable records) and **no metres-per-unit factor**; scaled prop heights are
   **3.52–5.81 "metres" (raw donor units × scale)** = **1.76–2.91 port tiles at
   `TILE_M=2.0`** (`world3d_relief.gd:49`). **8 of 22 renderable records fall below
   A04's +4 m ridge cue** (lowest 3.520 m, `pattern.lib:348756`) — so that cue cannot be
   asserted as met by the current transform. This is a measurement input to I09, not a
   pass/fail verdict. `[D]`/`PORT APPROXIMATION`
5. **[D]/[U] Stamp footprint vs prop envelope is not self-consistent at one map size.**
   Stamp footprints are 22–44 cells wide (44–88 m); renderable prop clusters fit inside
   the stamp at 240² for 7/7 `g_mnt_*` sections, but at 320² three sections
   (`g_mnt_3`, `g_mnt_6`, `g_mnt_7`) put prop centres + half-widths beyond the stamp
   half-extent, and `g_mnt_3` exceeds it at **both** cell scales. Cause is UNVERIFIED
   (frame/scale mapping, not proven geometry error) — see §8 M3. `[D]`/`[U]`
6. **[O] Tree and mine meshes are also measured.** 23 `tree_*.obj` (13,860 V / 17,377 F)
   span 0.332–7.803 Z-units (`tree_stump1` → `tree_oak`); three `mine_{gold,iron,coal}.obj`
   are **byte-identical in geometry** at 1,065 V / 1,234 F with bbox
   `[-7.142,7.885]×[-7.913,7.909]×[-1.551,0.362]` — a flat plate/disc with only 1.913
   units of Z relief. Mines are not a silhouette source; trees and terrainmesh props are.
   `[O]`/`[D]`
7. **[U] X16 was not landed** at the time of this pass
   (`reports/X16_prop_mesh_coverage.md` → `FileNotFound`); `spec/08_FIELDS_AND_PROPS.md:65,85`
   names it as the mesh-coverage audit. This report supplies the missing geometric
   numbers but does **not** substitute for X16's coverage verdict.

---

## 2. Evidence table

| ID | Evidence (exact path / line / on-disk value) | Label | Establishes |
|---|---|---|---|
| E01 | `variant3d/assets/models/obj/shared/terrain/terrainmesh{1..4}.obj`; file sizes 302,651 / 256,005 / 244,123 / 342,497 B; SHA-256 in `x25_analysis.json:meshes[*].sha256` | `[O]` | Exact read-only geometry source; no donor binary involved |
| E02 | Two independent OBJ parsers (line-prefix and token-split) agree on every V/F count; all `f` indices resolve; mesh bbox vs `manifest.json` `bbox` max abs Δ = 4.43×10⁻⁷; `manifest.verts`/`faces` equal parsed counts | `[O]`/`[D]` | Counts and bboxes reproducible; manifest mirrors OBJ (§8 M1) |
| E03 | `variant3d/assets/models/tex/shared/terrain/terrainmesh{1..4}.png` — Pillow 12.1.1 reports `(2048, 2048)` `RGBA` for all four (V07 E02 sizes 7,758,343 / 7,780,004 / 7,853,483 / 8,005,498 B) | `[O]` | Albedo dimension claim verified independently of V07 |
| E04 | All faces triangular; Euler χ = 1 (mesh1/2/4), χ = 4 for mesh3; mesh3 has 4 connected components (2,168 + 3 + 3 + 3 vertices); duplicate vertices mesh1 = 1, mesh3 = 6 | `[O]`/`[U]` | Mesh3 topology anomaly (§8 M2); provenance UNVERIFIED |
| E05 | `variant3d/assets/terrain/mountain_props.json`: `derived_stats` = 30 sections / 112 records / 20 port-stampable sections / 45 stampable records; `bbox_m` = {1:7.38,2:8.06,3:9.54,4:6.92} with note "NOT metres" | `[O]` | Authoritative prop-record table and span note |
| E06 | Sample record `g_mnt_1` line 338480: `base=terrainmesh4`, `px=-8.986`, `py=0`, `pz=5.6228`, `Direction=(0,1,0)`, `Up=(0.9397,0,-0.3420)`, `yaw_deg=20`, `sx=sy=sz=0.57570`; `pattern_meta.g_mnt_1` = width 43.0, height 38.0 | `[O]` | Position/Direction/Up/Scaling are literal `pattern.lib` numbers; footprint frame is in cells |
| E07 | `variant3d/scripts/world3d_relief.gd:48-49,137,175-181,188-189,215-234`: `DONOR_UNITS=160`, `TILE_M=2.0`, `cell_scale=map_w/160`, `dx=round(px*cell_scale)`, `wx=(st_x+dx+0.5)*TILE_M-half_w`, `sc=sx`, basis Z-up→Y-up then yaw then `basis.scaled(sc)` | `[O]` | The exact engine transform used to derive expected footprints; yaw sign and unit mapping labelled `PORT APPROX` at `:230` |
| E08 | `reports/A04_landscape_props.md:266-269` (ridge top ≥ centre terrain +4 m and ≥ footprint max +2 m; props ON/OFF ≥200 changed px, ≥8 px upward rise, outside-change <1%); `reports/V07_relief_asset_readiness.md:43-53,150,195` (QA atom stale, 22/45 renderable) | `[O]` prior | Acceptance cues this reference is meant to support; no cue is a donor claim |
| E09 | `variant3d/assets/models/obj/shared/terrain/tree_*.obj` (23 files, 13,860 V / 17,377 F) and `variant3d/assets/models/obj/shared/buildings/mine_{gold,iron,coal}.obj` (3 files, 1,065 V / 1,234 F each, identical bbox) | `[O]`/`[D]` | Tree/mine silhouette census; mine geometry identical across ores (material-only identity, A04 §4.8) |
| E10 | `docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md` → `FileNotFound`; `SWARM_BOARD.md` has no X16 row; `spec/08_FIELDS_AND_PROPS.md:65,85` names X16 | `[O]` negative | X16 not landed; its coverage verdict is still open |
| E11 | Temp artifacts `%TEMP%\opencode\silhouette_ref\x25_{analysis,props,topology}.json`, `x25_{silhouette,props}_contact_sheet.png` (full paths §6) | `[O]` | Reproducible evidence, kept outside the repo |

---

## 3. Method

1. **Read-first.** CHARTER, SWARM_BOARD, A04, V07, spec §08 were read in full before any
   measurement. X16 was probed and found absent (E10).
2. **Parse (pass 1).** `analyze.py` opens each relief OBJ as ASCII with `errors="replace"`
   and collects `v` and `f` records by **two independent methods in the same pass**:
   line-prefix (`s.startswith("v ")`) and generic token split (`toks[0]=="v"`). The two
   counts are asserted equal. Bounding boxes, spans, centroid (arithmetic mean of all
   vertices) and bbox centre are computed in raw donor units; height/width ratio is
   `z_span / max(x_span, y_span)`. Every face token's leading index is resolved
   (including negative relative indices) and bad indices counted (all zero).
3. **Cross-check (pass 2).** Parsed bbox is compared element-wise against
   `manifest.json:models[kind=relief].bbox`, `verts` and `faces`; parsed Z-span is compared
   against `mountain_props.json:bbox_m[*]`. Face arity, unique edge count and Euler χ are
   computed; albedo PNG dimensions are read with Pillow; connected components and exact
   duplicate coordinates are computed in `pass3.py`.
4. **Placement derivation.** For each of the 20 `derived_stats.port_stampable_sections`,
   `pattern_meta.width/height` gives the stamp footprint in **cells**, converted to
   metres at `TILE_M=2.0` (`world3d_relief.gd:49`). Each record's `sx` scales the mesh
   Z-span to a prop height; the consumer applies **no cell_scale to mesh dimensions**
   (`:232-234`), so the reported "metres" are raw donor units × authored scale and are
   explicitly `PORT APPROXIMATION`. Prop cluster extent uses the consumer's
   `dx=round(px*map_w/160)` and centre `(dx+0.5)*TILE_M`, evaluated at 240² and 320².
5. **Projection / contact sheets.** `sheet.py` projects the parsed vertices
   orthographically to three planes (FRONT X-Z, SIDE Y-Z, TOP X-Y) with one common
   pixels-per-unit scale for all panels; projected faces are filled grey, the 2-D convex
   hull is drawn cyan and the centroid amber. `props.py` does the same for 8 tree/mine
   representatives (FRONT X-Z, TOP X-Y). **No donor image or decoded donor texture is
   copied into the sheets** — every pixel is generated from port OBJ vertex coordinates.
6. **No engine work.** No Godot process, runner job, capture, test or renderer was
   started. All numbers are static-geometry derivations.

**Frame caveat.** `world3d_relief.gd:229-231` applies a Z-up→Y-up basis and then a yaw
whose sign is labelled UNVERIFIED at `:230`; this reference therefore reports **object
space** bboxes and spans (invariant under those rotations) and treats the scaled Z-span
as the vertical silhouette only under the PORT APPROX assumption that the basis does not
change the vertical extent. A yaw-only rotation about the up axis preserves height; the
−90° X rotation maps donor Z to world Y. `[D]`/`PORT APPROXIMATION`

---

## 4. Silhouette tables

### 4.1 Relief mesh geometry (object space, raw donor units, Z-up)

V = vertices, F = triangular faces, dup = exact duplicate vertex coordinates,
Δ = max absolute bbox difference vs `manifest.json`.

| Prop | V | F | bbox `[xmin,xmax,ymin,ymax,zmin,zmax]` | span `[x,y,z]` | h/w | centroid | dup | Δ |
|---|---|---|---|---|---|---|---|---|
| `terrainmesh1` | 2662 | 5305 | [-14.021, 13.888, -13.524, 13.446, 0.070, 7.449] | [27.908, 26.969, 7.379] | 0.264 | [-0.710, -0.041, 2.858] | 1 | -3.9e-07 |
| `terrainmesh2` | 2272 | 4532 | [-13.227, 13.092, -12.666, 12.954, -0.025, 8.035] | [26.319, 25.620, 8.060] | 0.306 | [0.545, 0.351, 2.635] | 0 | -2.9e-07 |
| `terrainmesh3` | 2177 | 4323 | [-12.935, 12.988, -12.839, 12.976, 0.011, 9.550] | [25.923, 25.815, 9.540] | 0.368 | [0.193, -0.063, 3.487] | 6 | -8.4e-08 |
| `terrainmesh4` | 2509 | 5002 | [-12.670, 12.670, -12.828, 12.828, 0.013, 6.933] | [25.339, 25.655, 6.920] | 0.270 | [-0.022, 0.447, 3.165] | 0 | -3.8e-07 |

Reading notes `[D]`:
- All four are broad, shallow relief caps: XY span 25.3–27.9, Z span 6.9–9.5.
- `terrainmesh3` is the strongest ridge candidate (h/w 0.368, centroid Z 3.487).
- `terrainmesh4` is the flattest (h/w 0.270) and carries 8 of the 22 "below +4 m"
  records because its scale is often ~0.51.
- The bbox is not centred on the origin; `world3d_relief.gd:222-224` re-centres X/Y and
  zeroes base Z per instance using these exact manifest numbers.

### 4.2 Expected footprint / silhouette for the 20 stampable sections

`Cells` = `pattern_meta.width×height`; `Footprint m` = cells × `TILE_M=2.0`;
`Rec` = records; `Conv/UConv` = records whose `sid` does/does not resolve to a converted
mesh; `Height m` = min–max of `mesh.z_span × sx` (PORT APPROX); `Tiles` = height ÷ 2.0.
QA cue is a **measurement target for I09**, not a donor claim.

| Section | Cells | Footprint m | Rec | Conv/UConv | Height m | Tiles | QA cue |
|---|---|---|---|---|---|---|---|
| `desert_mnt_1` | 30x29 | 60x58 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_10` | 25x23 | 50x46 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_11` | 28x20 | 56x40 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_12` | 23x20 | 46x40 | 1 | 0/1 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_13` | 22x21 | 44x42 | 1 | 0/1 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_2` | 29x25 | 58x50 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_3` | 28x26 | 56x52 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_4` | 27x25 | 54x50 | 2 | 0/2 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_5` | 24x27 | 48x54 | 1 | 0/1 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_6` | 25x24 | 50x48 | 1 | 0/1 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_7` | 31x28 | 62x56 | 3 | 0/3 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_8` | 31x25 | 62x50 | 3 | 0/3 | - | - | NO-SID / skipped_unknown_sid |
| `desert_mnt_9` | 23x24 | 46x48 | 1 | 0/1 | - | - | NO-SID / skipped_unknown_sid |
| `g_mnt_1` | 43x38 | 86x76 | 5 | 5/0 | 3.53-4.87 | 1.76-2.43 | ridge top ≥ 3 tiles (≥ 5 m) above ground; 5 instances |
| `g_mnt_2` | 43x29 | 86x58 | 2 | 2/0 | 4.01-5.34 | 2.01-2.67 | ridge top ≥ 3 tiles (≥ 5 m) above ground; 2 instances |
| `g_mnt_3` | 32x37 | 64x74 | 4 | 4/0 | 3.90-4.62 | 1.95-2.31 | ridge top ≥ 3 tiles (≥ 5 m); cluster-vs-stamp envelope UNVERIFIED |
| `g_mnt_4` | 31x26 | 62x52 | 1 | 1/0 | 4.87-4.87 | 2.44-2.44 | single ridge ≥ 3 tiles (≥ 5 m); 1 instance |
| `g_mnt_5` | 38x43 | 76x86 | 4 | 4/0 | 3.52-5.09 | 1.76-2.55 | ridge top ≥ 3 tiles (≥ 5 m); one 3.520 m outlier |
| `g_mnt_6` | 40x38 | 80x76 | 4 | 4/0 | 3.67-5.58 | 1.84-2.79 | ridge top ≥ 3 tiles (≥ 6 m); 320² envelope outside stamp `[U]` |
| `g_mnt_7` | 44x50 | 88x100 | 2 | 2/0 | 4.72-5.81 | 2.36-2.91 | tallest: ≥ 3 tiles (≥ 6 m); 320² envelope outside stamp `[U]` |

Aggregate `[D]`: renderable records **22** across **7** sections; skipped records **23**
across **13** sections; renderable scale range **0.4460–0.6400**; all 45 stampable
records span **0.3539–0.6562**, matching `derived_stats.scale_min/scale_max`.
Height cue `ceil(max_tiles)=3` for all seven renderable sections; **8 of 22** records are
below 4 m under the current no-metre-factor transform (see §1.4).

### 4.3 Tree / mine prop census

| Mesh family | Count | V total | F total | Z-span range (raw units) | Representative extremes |
|---|---|---|---|---|---|
| `tree_*.obj` (`obj/shared/terrain/`) | 23 | 13,860 | 17,377 | 0.332 – 7.803 | `tree_stump1` 0.332 (24 V/22 F); `tree_oak` 7.803 (1697 V/2249 F); `tree_pine` 7.722 |
| `mine_{gold,iron,coal}.obj` (`obj/shared/buildings/`) | 3 | 1,065 each | 1,234 each | 1.913 (identical bbox) | `[-7.142,7.885]×[-7.913,7.909]×[-1.551,0.362]`, h/w 0.12 |

Reading `[D]`/`PORT APPROXIMATION`: with A04-cited authored scales of 0.165–0.71 for
trees and 0.3152 for deposits (A04 §4.6/§4.8, E23), expected tree silhouettes are
≈0.05–5.5 raw units and a deposit is ≈0.60 units tall — mines cannot supply a ridge
cue; their albedo disc is the donor identity carrier (A04 §4.8). Per-record scale binding
for forest/stone/mine decor is still UNVERIFIED (V07 Q5, F08 not landed).

### 4.4 Contact-sheet legend

- `x25_silhouette_contact_sheet.png`: 4 rows (`terrainmesh1..4`) × 3 columns
  (FRONT X-Z, SIDE Y-Z, TOP X-Y), 1,220×1,346 px; common scale 8.3 px/unit; grey =
  projected triangles, cyan = convex hull, amber = centroid; footer lists all 20
  section silhouettes and both anomalies.
- `x25_props_contact_sheet.png`: 8 representatives × 2 views (FRONT X-Z, TOP X-Y),
  1,340×566 px; common scale 6.0 px/unit.

---

## 5. Temp artifact paths

All artifacts are **outside the repo** under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\silhouette_ref\`:

| File | Purpose |
|---|---|
| `analyze.py` | Two-pass OBJ parser, bbox/centroid/footprint derivation → `x25_analysis.json` |
| `sheet.py` | Relief contact sheet + topology/albedo cross-check → `x25_topology.json` |
| `pass3.py` | Anomaly pass: components, duplicates, 240²/320² envelope, bbox-note frame |
| `props.py` | Tree/mine census + second contact sheet → `x25_props_analysis.json` |
| `tables.py` | Markdown rows copied into §4.1/§4.2 |
| `qacues.py` | +4 m cue counter (8/22 below) and per-section `ceil` tiles |
| `x25_analysis.json` | Mesh metrics, 20-section footprints, SHA-256 of inputs, raw vertices/faces |
| `x25_topology.json` | Face arity, edge counts, Euler χ, albedo paths |
| `x25_props_analysis.json` | 26-row tree/mine census |
| `x25_silhouette_contact_sheet.png` | Labelled relief multi-view sheet |
| `x25_props_contact_sheet.png` | Labelled tree/mine multi-view sheet |

No PNG or JSON from this list was written into `variant3d/` or anywhere else in the repo.

---

## 6. Implications for I09 / V15 acceptance

1. **I09 can now check instancing without a donor GPU frame.** For a 240² or 320²
   mountain fixture, assert `prop_count == 22` renderable records (or `22 + skipped`),
   `batch_count == 4` for `g_mnt_*`, zero instances from `desert_mnt_*` with
   `skipped_unknown_sid` counted, and per-section instance counts exactly as §4.2.
   These are structural checks, **not** donor parity. `[D]`
2. **Silhouette cue must use the correct frame.** Assert the highest instanced vertex is
   ≥3 port tiles above the grounded base for each renderable `g_mnt_*` section under the
   current transform; record the eight sub-4 m records by `pattern.lib` line so a later
   fix cannot silently pass by lowering the threshold. If V15 adopts a metre-per-unit
   factor, recompute from §4.1 Z-spans — do **not** change the raw OBJ. `[D]`/`PORT APPROX`
3. **V15 must not claim mountains from desert or mine props.** 13 stampable sections have
   no converted sid, and mine meshes are 1.913 units flat; a "mountains present" gate
   must key on the seven `g_mnt_*` sections. `[D]`
4. **QA atom interface gaps remain** (V07 E05, M3/M6): `t_relief_props_qa.gd:30` expects
   `terrainmesh_props.json` (live file is `mountain_props.json`), expects scale 1 and one
   `MeshInstance3D` per stamp (live is MultiMesh with authored scale), and needs the absent
   `small_map_64_mountains.json` fixture. I09/V15 should reconcile **against** this
   reference's counts rather than weaken the atom. `[O]`/`[U]`
5. **No acceptance verdict is issued here.** A props-ON/OFF A/B with frozen cameras and
   the A04 §4.2 pixel deltas still has to be run by an authorised runner owner; this
   report only supplies the expected geometry against which such a capture can be read.
   `[U]`

---

## 7. UNVERIFIED register (do not promote)

1. **All four relief meshes — engine transform / scale provenance.** Authored `sx` is an
   observed `pattern.lib` literal, but Z-up→Y-up basis, **yaw sign** (`world3d_relief.gd:230`)
   and the absence of a metres-per-unit factor (`:232-234`; DTRN-02 C20) are
   `PORT APPROXIMATION`/`[U]`. Units in §4.2 "Height m" are raw donor units × scale.
2. **`terrainmeshdesert1..4`** — four `BaseName`s in `derived_stats.base_name_census`
   (2+5+7+9 = 23 records) have **no converted OBJ/MTL/PNG and no manifest sid**. Scale
   literals observed; mesh provenance UNVERIFIED. Do not substitute terrainmesh1..4.
3. **Winter relief assets, `terrainplateau1..4`** — no sid/albedo/prop link (A04 §4.2,
   V07 §7 UNVERIFIED item 6); not measured here.
4. **`terrainmesh3` topology** — 4 components (main + three isolated 3-vertex triangles)
   and 6 duplicate coordinates; whether these are donor-authored fragments or conversion
   artefacts is `[U]`. No repair was attempted (read-only mandate).
5. **`g_mnt_3` (both scales), `g_mnt_6`/`g_mnt_7` (320² only) envelope** — prop cluster
   extends past the stamp footprint under the consumer's `dx=round(px*cell_scale)` rule;
   cause (frame mismatch vs authored placement) `[U]`.
6. **Stamp `width×height` vs `Objects` Position frame** — `pattern_meta` cells and `px/pz`
   are combined by a port formula (E07), not by decoded donor `StandPatternWithAngle`;
   the resulting footprint is a `PORT APPROX` derivation.
7. **Mine/tree per-record scale binding** — donor scale constants cited by A04/F08, but
   no decoded record→prop map for forest/stone/mine decor (F08 not landed at V07 time);
   expected heights in §4.3 are family-level, not per-instance.
8. **Albedo→geometry mapping** — all four PNGs are 2048² RGBA `[O]`, but UV correctness,
   mip behaviour and material/LOD binding are `[U]`; no donor GPU frame.
9. **X16 coverage verdict** — report absent (E10); this reference does not close its
   ticket.
10. **A04's +4 m / +2 m cue** — under the landed transform 8/22 records miss +4 m;
    whether the cue was written for a different unit frame is `[U]`.
11. **Donor parity of any silhouette** — no donor GPU A/B frame exists. `[U]`, no claim.

---

## 8. Multiple-pass register (CHARTER.md:88-93)

| # | Anomaly / contradiction | Pass 1 | Pass 2 / Pass 3 | Accepted reading |
|---|---|---|---|---|
| M1 | "Vertex/face counts and bbox might disagree with manifest" | Two parsers inside `analyze.py` agree exactly; bbox Δ ≤ 4.4×10⁻⁷ | `manifest.verts`/`faces` read independently and compared; `bbox_m` note compared to Z-span (Δ≤0.0015) and to `zmax` (Δ≤0.0685) | `[O]` counts exact; bbox is a faithful mirror; A04's 6.93–9.55 = `zmax` frame, manifest note = span frame. No contradiction remains |
| M2 | Euler χ = 4 on mesh3 while others χ = 1 | Face-arity and edge-set pass gave χ = 1/1/4/1 | `pass3.py` union-find over faces: mesh3 = 4 components (2168+3+3+3); duplicate-coordinate pass found repeats at (8.7045,-8.2052,0.0416)×4, (8.4408,-7.9316,0.2223)×2, (9.2321,-8.2052,0.0400)×3 | `[O]` real topology anomaly, `[U]` provenance; reported, not repaired |
| M3 | Prop cluster outside stamp footprint | 320² evaluation: `g_mnt_3/6/7` outside | Re-evaluated at 240²: `g_mnt_6/7` become inside, `g_mnt_3` remains outside; both frames printed by `pass3.py` | `[D]` scale-sensitive, not a single reproducible "error"; cause `[U]` |
| M4 | `bbox_m` note vs A04 "z spans 6.93–9.55" | Note values 6.92/7.38/8.06/9.54 vs computed spans | Compared note to span and to `zmax` separately (pass 3D) | `[D]` note = Z-span rounded to 2 dp; A04 used `zmax`; both cited |
| M5 | X16 expected to be present (spec §7) | `read` → `FileNotFound` | `glob reports/X*.md` + `SWARM_BOARD.md` + spec cross-check | `[O]` X16 not landed at this pass; remains an open ticket |
| M6 | `prop_height_cells_320` label ambiguity in first derivation | Name suggested map-cell scale `map_w/160` | Re-derived explicitly: consumer scales mesh only by `sx` (`:232-234`), so height ÷ `TILE_M` = **port tiles**, while height × `cell_scale` is a non-consumer cross-reference | `[D]` report uses `Tiles` (=÷2.0); alternate frame retained in JSON under `prop_height_cells_map_*` |

---

## 9. Open questions

1. Will I09 adopt `mountain_props.json` verbatim (22 renderable records) or re-derive
   props with I02/I03, and which counts become the gate? (A04 Q1; V07 Q1.)
2. Who creates `small_map_64_mountains.json` / a 320² mountains fixture and who is
   authorised to run the ON/OFF capture? (COORD/G04 only.)
3. Is the +4 m ridge cue defined in raw donor units or in metres under a future scale
   contract? Eight records are 3.52–3.98 m today — lowering the threshold is forbidden.
4. Should `g_mnt_3`'s out-of-stamp prop envelope be treated as authored placement or as a
   position-frame bug? Requires decoded `StandPatternWithAngle` (`world3d_relief.gd:53`,
   V07 §7 UNVERIFIED item 3).
5. Will `terrainmeshdesert1..4` be converted for desert stamps, and will
   `terrainmesh3`'s stray triangles be preserved or dropped? (Read-only here.)
6. Does X16 land with a different mesh-coverage census that supersedes §4.3?
7. Are mine/tree decor instances part of I09's props stage or a separate res-node
   consumer, given F08's record→prop binding is still open?

---

## 10. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Four relief OBJs parse to 9,620 V / 19,162 F; bbox matches manifest to ≤4.4e-7 | E01, E02, §4.1 | `[O]`/`[D]` |
| 2 | Z-span 6.920–9.540; manifest note is span, A04 wording is `zmax` | E05, M4 | `[D]` |
| 3 | 22 of 45 stampable records renderable; 23 desert records skipped | E05, E07, V07 M4 | `[O]`/`[D]` |
| 4 | Scaled heights 3.52–5.81 raw units = 1.76–2.91 tiles; 8 records < 4 m | E06, E07, `qacues.py` | `[D]`/`PORT APPROX` |
| 5 | Tree/mine census complete; mine meshes flat and identical | E09, §4.3 | `[O]`/`[D]` |
| 6 | Two labelled contact sheets generated outside repo from port vertices only | E11, §5 | `[O]` |
| 7 | X16 absent; no donor GPU A/B frame; **no parity claim** | E10, CHARTER.md:57-58 | `[U]` |

*End of X25. Read-only geometric reference only: no repo asset, source, shader, config,
test, fixture, runner job or git edit; no donor binary executed or copied; no donor
parity claim.*
