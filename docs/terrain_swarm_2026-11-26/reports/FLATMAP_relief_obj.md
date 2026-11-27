# FLATMAP_relief_obj — READ-ONLY investigation: `world3d_relief` "relief OBJ map miss" warnings for terrainmesh1..4

- worker: FLATMAP-2 (full 1:1 Cossacks 3 donor port, READ-ONLY investigation worker)
- scope: READ-ONLY. No code/Godot/git/donor-execution. Exactly one file written (this report). No OBJ created, altered, or invented.
- parity: UNVERIFIED. No parity claim. No approximation. Chain 0/6. RESULT IS NOT GOOD.
- context: owner run log shows 4 warnings: `world3d_relief: relief OBJ map miss for terrainmesh1..4 — flat diagnostic fallback res://assets/models/obj/shared/terrain/terrainmeshN.obj`. Prior reports recorded these as labelled-expected.

## 1. Port path traced (exact lines)

- `variant3d/scripts/world3d_relief.gd:51`: `RELIEF_SIDS := ["terrainmesh1".."4"]`.
- `variant3d/scripts/world3d_relief.gd:86-92` `bind()`: `_load_table()` + `_load_manifest_bboxes()` + `_load_meshes()` + `rebuild()`.
- `variant3d/scripts/world3d_relief.gd:341-359` `_load_meshes()`: for each sid, `var path: String = AssetPaths.existing(sid, "obj")` (`:347`); if `path.begins_with(AssetPaths.LEGACY_OBJ_DIR)` then `push_warning(... "relief OBJ map miss ... flat diagnostic fallback %s" ...)` (`:348-349`); then if not `ResourceLoader.exists(path)` → second warning `OBJ not imported yet` (`:352-353`) and `continue` (mesh never enters `_meshes`); `load()` result kept only `if res is Mesh` (`:355-357`).
- `variant3d/scripts/asset_paths.gd:15-18`: `LEGACY_OBJ_DIR := "res://assets/models/obj/"`; `:86-93` `existing()`: mapped bucket path first, then untouched flat original, then mapped path.
- `variant3d/scripts/terrain_donor_props.gd:187-189`: same four sids, cited `donor actors.lib:1200-1213`.
- FOLD-07 diff added this warning (`docs/terrain_swarm_2026-11-25/reports/FOLD_07_impl.md:170-197`), claiming (`:199-203`) it "fires only when the flat branch was actually taken, so a healthy mapped tree is silent".

## 2. On-disk byte evidence (read-only reads this pass)

- Bucket OBJs EXIST (4/4): `variant3d/assets/models/obj/shared/terrain/terrainmesh{1..4}.obj` — glob hit this pass.
- Legacy flat-root OBJs do NOT exist: glob `variant3d/assets/models/obj/terrainmesh*.obj` → no files this pass.
- Manifest mapped bucket (`variant3d/assets/models/manifest.json:376-470`, `[O]` read this pass):
  - terrainmesh1: kind `relief`, donor `data/actors/env/terrainmesh1.osm` + `data/materials/env/terrainmesh1.dds`, bbox `[-14.0205,13.8877,-13.5237,13.4457,0.0700,7.4485]`, verts 2662 / faces 5305, bucket `shared/terrain`, assets.obj `res://assets/models/obj/shared/terrain/terrainmesh1.obj`.
  - terrainmesh2: bbox `[-13.2274,13.0921,-12.6664,12.9535,-0.0251,8.0346]`, verts 2272 / faces 4532, same bucket pattern (`:400-422`).
  - terrainmesh3: bbox `[-12.9348,12.9880,-12.8390,12.9765,0.0106,9.5503]`, verts 2177 / faces 4323 (`:424-446`).
  - terrainmesh4: bbox `[-12.6697,12.6697,-12.8276,12.8276,0.0125,6.9330]`, verts 2509 / faces 5002 (`:448-470`).
- OBJ head (`terrainmesh1.obj:1-4`, `[O]`): `# Cossacks 3 original mesh, converted by tools/convert_models.py`, `mtllib terrainmesh1.mtl`, `o model`, then `v` records with non-constant Z (e.g. `7.333359`, `0.080045`, `4.761071`, `4.799033`) — the file on disk is relief geometry, not a flat plate.
- Byte-proven non-flat reference (re-cited, not re-parsed): X25 E01/E02 (`docs/terrain_swarm_2026-11-26/reports/X25_relief_silhouette_reference.md:35-44,86-98`): four OBJs parse to **9,620 vertices / 19,162 triangular faces**, computed bboxes agree with `manifest.json` to **≤ 4.4e-7 donor units**, Z-spans 6.920–9.540; all four 2048² RGBA albedos exist. FOLD_07 resolver proof (`FOLD_07_impl.md:221`): "`terrainmesh1..4` resolve to `obj/shared/terrain/*.obj` — 4/4, file exists, none legacy" `[O]`.
- Derived donor table (`variant3d/assets/terrain/mountain_props.json:1-17`, `[O]`): version 1, source `data/pattern/pattern.lib — read-only parse of Objects records with BaseName=terrainmesh*`, `source_sha256 f7b421b1…`, `bbox_m` spans 7.38/8.06/9.54/6.92 with note "NOT metres"; `by_pattern` shows `desert_mnt_*` records pointing at `terrainmeshdesert1..4` (no converted sid) vs `g_mnt_*` pointing at terrainmesh1..4.

## 3. Donor-derived law for terrainmesh1..4 (re-cited pinned records; no new lift)

- Donor mounts REAL 3D prop meshes `terrainmesh1..4.osm` (+ `terrainplateau1..4.osm`) as game objects inside mountain patterns: DTRN-02 C8 (`docs/terrain_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:104`): `pattern.lib:338482` (`g_mnt_1`→`terrainmesh4`), `:344362`, `:348758`, `:356906`; `actors.lib:1200-1213`; `terrainmesh1.actor:1-5`; `dogenerate.inc:1984` scale exemption.
- Placement inputs are donor `pattern.lib` `Objects` Position/Up/Scaling literals + line numbers, yaw `atan2(-Up.Z, Up.X)` DERIVED (`world3d_relief.gd:10-19`); `mountain_props.json` holds 112 records / 30 sections / 20 port-stampable sections / 45 stampable records (X25 §4.2; V59 audit row).
- Everything engine-side stays UNVERIFIED by the code's own labels: `StandPatternWithAngle(..., angle=0)` transform (`world3d_relief.gd:21-35` PLACEMENT_LABEL / SELECTION_LABEL / `terrain_donor_props.gd:204-233` UNVERIFIED_BASE: TRANSFORM_MATH, YAW_SIGN, TERRAINMESH_HALF_CELL, TERRAINMESH_TURN_AXIS, METRES_PER_CELL, DESERT_SIDS, WINTER_RELIEF, PLATEAU_PROPS); DEC-VIS-02 §6 donor-order terrainmesh path in `terrain_donor_props.gd:134-176,1511-1654` is donor-literal only for the 31 listed patterns, legacy PORT APPROX otherwise; relief rows absent from envscales table (X70:173).
- `terrain_donor_props.gd:1098-1103` notes the converted OBJs declare `mtllib` but no `usemtl`, and `terrainmesh3.obj:4,6-8,8004-8005,8650-8656` keeps the broad square base — triangulated donor relief, not an editor grid.

## 4. Determination

**(a) Are the flat fallbacks a deliberate labelled gap or an unresolved port defect? — BOTH, split by layer:**

1. **The warning text as emitted is a port labelling defect (unresolved).** The `begins_with(AssetPaths.LEGACY_OBJ_DIR)` test at `world3d_relief.gd:348` over-matches: `LEGACY_OBJ_DIR` is the prefix `res://assets/models/obj/`, and the HEALTHY mapped bucket path `res://assets/models/obj/shared/terrain/terrainmeshN.obj` also begins with that prefix. So the "map miss — flat diagnostic fallback" warning fires even on the FOLD_07-proven good resolution (4/4 bucket, none legacy). FOLD_07's claim ("fires only when the flat branch was actually taken, so a healthy mapped tree is silent") is REFUTED by direct code reading combined with the on-disk bucket layout observed this pass. Prior triage recording all four warnings as "labelled-expected" (`DEEPGEN_water_shore.md:6,52-53`, citing `terrain_donor_mesh.gd:1740` RELIEF-01) relied on that claim and is therefore UNSOUND for this specific warning line — the log line does not prove a miss occurred.
2. **The underlying fail-soft (no relief bound without a Godot import) IS the deliberate labelled gap.** `world3d_relief.gd:352-357` + Z05 R11: without a Godot import pass no `.import` exists, `ResourceLoader.exists(path)` is false, the sid is skipped (`skipped_missing_mesh`), and no fabricated amplitude is substituted. That matches RELIEF-01 single-application / "keeps flat heights rather than inventing relief". But "flat fallback" is then a misnomer at this layer too: no flat OBJ is loaded (legacy root files do not exist on disk); `_meshes` simply lacks the sid and nothing renders for it.

**(b) Byte-proven evidence for real relief geometry:** manifest `verts/faces/bbox` per sid (`manifest.json:376-470`); OBJ `v` records with varying Z (`terrainmesh1.obj:4-20`); X25 independent two-parser counts (9,620 V / 19,162 F, bbox Δ ≤ 4.4e-7, Z-spans 6.920–9.540); `mountain_props.json` header (source + sha + span note); FOLD_07 4/4 bucket-exists-none-legacy proof.

**(c) Owner/donor evidence still needed to replace the fallback path with settled geometry:**

1. G04 Godot import pass over the four bucket OBJs + windowed props-ON/OFF PNGs on a frozen `g_mnt_*` camera (the only authorised renderer of these meshes; X25 §6.4; Z07 §6.1).
2. Decoded donor `StandPatternWithAngle` transform (which terrainmeshN a stamp picks at runtime; Z03 B4 / Z06 §7 Q1) — until then selection stays PORT APPROX by the code's own label.
3. Donor GPU A/B frame for ANY silhouette/height claim (CHARTER bar); plus settlement of metre-per-unit (DTRN-02 C20), yaw sign, final-turn axis (all `[U]`), and the `terrainmesh3` 4-component topology question (X25 M2).
4. Owner decision on `terrainmeshdesert1..4` conversion (23 records → `skipped_unknown_sid`), winter `terrainmeshNw`, and `terrainplateau1..4` (all currently no-sid by design).

## 5. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Bucket terrainmesh1..4 OBJs exist with real relief; legacy flat-root OBJs absent | §2 globs + manifest + OBJ head | `[O]` |
| 2 | The 4 run-log warnings are consistent with a prefix-test false positive, not proof of a miss | `world3d_relief.gd:347-349` vs `asset_paths.gd:16,86-93` + bucket layout | `[D]` from `[O]` |
| 3 | FOLD_07 "healthy tree is silent" claim is refuted for this call site | Same lines + FOLD_07_impl.md:199-203,221 | `[D]` |
| 4 | DEEPGEN "labelled-expected" triage of this exact warning line is unsound | DEEPGEN_water_shore.md:52-53 vs §4.1 | `[D]` |
| 5 | No flat geometry is bound; missing-import fail-soft skips the sid without invention | `world3d_relief.gd:352-357`, Z05 R11 | `[O]`/`[D]` |
| 6 | Donor law: terrainmesh1..4 are real 3D mountain props (actors.lib:1200-1213), placement/selection engine-side UNVERIFIED | DTRN-02 C8, mountain_props.json:1-17, code labels | re-cited `[O]`/`[U]` |
| 7 | No parity verdict on any relief silhouette | No donor GPU A/B frame (CHARTER) | `[U]`, no claim |

*End of FLATMAP_relief_obj. READ-ONLY: no repo asset, source, shader, config, test, fixture, runner job, or git edit; no OBJ created or altered; no geometry invented; no donor binary executed or copied; parity UNVERIFIED.*
