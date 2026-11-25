---
id: DEC-07
scope: "Donor data\\cameras and data\\shaders — full parameter dump, projection math, shader semantics"
owner: DEC-07 (decompilation documentation micro-worker)
date: 2026-11-25
role: read-only documentation (no code/asset/config/git edits, no donor binary run, no donor copies)
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python bytes + latin-1; never executed, unpacked or copied)"
output: docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md
labels: "observed = literal file text/byte fact | derived = arithmetic/control-flow from observed | inferred = plausible reading with caveat | UNVERIFIED = not provable from read text"
---

# DEC-07 — Donor `data\cameras` and `data\shaders`: full dump, projection math, shader semantics

## 1. Goal

Produce the definitive read-only reference for the two donor directories that drive today's
selection-rectangle and terrain-quality work:

1. enumerate **every** file under `C:\Games\Cossacks 3\data\cameras` (4 files) and
   `data\shaders` (109 files), with size, encoding and full parameter lists (`path:line`);
2. recover the actual shader semantics (inputs, constants, samplers, blend/fog/lighting/alpha,
   water, terrain tile index);
3. derive the main-view camera matrix chain and closed-form screen↔ground formulas, with every
   number cited and every uncertain step labelled;
4. compare against the current `variant3d` shaders/camera read-only and name the missing donor
   behaviours.

No donor file was modified, executed or copied into the repo. No repo source was edited.

---

## 2. Prior docs read (all read-only this session)

| Doc | What it supplied / how it was checked |
|---|---|
| `docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md` | perspective-vs-ortho verdict (`:40-63`, claim 1 `:225`), height grid, shader binding `:89-96`, open questions `:260-275`. |
| `.../DEEPDEC_01_camera.md` | 49-key loader `sub_7ab704`, defaults/fields (`:73-127`), wheel/pan/minimap formulas (`:138-225`), port implications (`:266-315`), UNVERIFIED list (`:317-335`). Re-checked against raw donor text below — **two corrections** in §8. |
| `.../V711_camera3d.md` | original `camera3d.gd` contract, donor-citation table (`:28-44`), FOV/yaw/clip assumptions (`:41-43`, `:84-90`). |
| `.../V790_donor_camera_changes.md` | landed height/wheel/pan changes, exact diffs (`:46-277`), open ArcTan/FOV items (`:326-332`). |
| `.../V784_donor_water_shader.md` | donor→`water3d.gdshader` equation ledger (`:49-66`), UNVERIFIED bindings (`:122-133`). |
| `.../V786_tileindex_shader.md` | donor tile-index equation ledger D01–D20 (`:45-72`), APPROX ledger (`:75-120`), uniform contract (`:134-165`), line-label correction (`:225-231`). |
| `.../V761_donor_key_colors.md` | player-slot key colours, `koef` and >1.0 handling (`:39-115`) — relevant to `custColor` shader uniforms. |
| `docs/audit/RENDER_ARCH_CAMERA.md` | key/value table (`:38-123`), perspective derivation (`:126-168`), numeric FOV note `:162-167` (**correct** 5.2° for 36 mm). |
| `docs/audit/RENDER_ARCH_SHADERS.md` | 109-file inventory (`:64-79`), evidence E1–E34 (`:128-166`), gap table (`:218-237`), port plan (`:241-325`). |
| `docs/audit/RENDER_ARCH_SYNTHESIS.md` | 2D-vs-3D verdict (`:8-23`), staged plan (`:49-63`). |
| `.../DEEPDEC_08_ui_minimap.md` (grep) | E3 `control.script:574-613` marked PROVEN — confirms correction §8.2. |
| `docs/coord_swarm_2026-11-24/reports/DECOMP_03_render_api.md`, `DECOMP_04_strings_config.md` (grep) | projection-token scan (no additional camera/shader literals needed here). |
| `investigation.cany/investigation/findings.md` | fnd_1–fnd_4; no camera/shader finding contradicted by this report. |
| `variant3d/scripts/camera3d.gd`, `variant3d/shaders/{terrain_tileindex,water3d,water_overlay}.gdshader` | read-only port comparison (§9). |

---

## 3. Camera file records

### 3.0 Format inventory (observed)

| File | Bytes | Encoding | Line endings | SHA-256 prefix |
|---|---:|---|---|---|
| `data\cameras\camera.cfg` | 1613 | ASCII, no BOM, no NUL | 65 CRLF | `abd5ab7755952ff2` |
| `data\cameras\cameradebug.cfg` | 1543 | ASCII, no BOM, no NUL | 63 CRLF | `fecf90b9556dac4c` |
| `data\cameras\camerascreenshot.cfg` | 1755 | ASCII, no BOM, no NUL | 69 CRLF | `a6e744633ff393b0` |
| `data\cameras\default.cameras` | 2571 | ASCII, no BOM, no NUL | 96 CRLF | `37080409a6a04d2a` |

All values are plaintext Delphi-style `key = value`; booleans are `True`/`False`/`true`/`false`
(case varies). `//` starts a comment. Structs are `Name : struct.begin` / `struct.end`;
arrays use `[*]`.

### 3.1 `camera.cfg` — main RTS profile (49 active keys)

Every row: **key | value | meaning | `camera.cfg:line`**. Meaning labels are **derived** from the
key name + the loader destinations decoded in DEEPDEC-01 `:73-127` (field offsets quoted there are
OBS from the binary, not re-derived here); where no consumer is provable the row says so.

| Key | Value | Meaning | path:line |
|---|---|---|---|
| `HeightTarget` | 1 | target height above terrain (field `+0x298`) | `:3` |
| `HeightTargetMin` | 5 | min target height (`+0x200`) | `:4` |
| `//SphereHeight` | 49 | **commented** older max altitude; matches `default.cameras` bookmark | `:5` |
| `SphereHeight` | 58 | orbit sphere max vertical radius / max height (`+0x204`) | `:6` |
| `SphereHeightMin` | 20 | sphere min vertical radius (`+0x208`) | `:7` |
| `//SphereLength` | 49 | **commented** older max depth | `:8` |
| `SphereLength` | 58 | sphere max horizontal radius; wheel zoom maxHeight (`+0x20c`) | `:9` |
| `SphereLengthMin` | 20 | sphere min horizontal radius; wheel zoom minHeight (`+0x210`) | `:10` |
| `MoveVelocity` | 0.125 | elastic move velocity (`+0x218`) | `:14` |
| `HeightVelocityFactor` | 0.05 | elastic height velocity factor (`+0x214`) | `:15` |
| `RotationVelocity` | 0.05 | elastic rotation velocity (`+0x21c`) | `:16` |
| `TargetOffset` | 0 | elastic target offset (`+0x220`) | `:17` |
| `CameraOffset` | 0 | elastic camera offset (`+0x224`) | `:18` |
| `IntervalTime` | 10 | int32 interval time (`+0x228`) | `:19` |
| `StepTimeMove` | 0.00001 | elastic step time, move (`+0x22c`) | `:20` |
| `StepTimeMoveDirection` | 1 | elastic step time, direction (`+0x230`) | `:21` |
| `StepTimeMoveAccel` | 0.00001 | elastic step time, accel (`+0x234`) | `:22` |
| `StepTimeMoveDecel` | 0.00001 | elastic step time, decel (`+0x238`) | `:23` |
| `StepTimeRotation` | 0.00001 | elastic step time, rotation (`+0x23c`) | `:24` |
| `StepTimeTargetRaycast` | 0.05 | target raycast smoothing (`+0x240`) | `:25` |
| `StepTimeCameraRaycast` | 0.05 | camera raycast smoothing (`+0x244`) | `:26` |
| `StepTimeCameraDistance` | 0.005 | camera-distance smoothing (`+0x248`) | `:27` |
| `FreeRotationMode` | True | enables free-rotation init path (`+0x31f`) | `:30` |
| `MinHeightMinAngle` | -32 | tilt slot A (`+0x24c`) | `:32` |
| `MinHeightMaxAngle` | -32 | tilt slot B; drives `angleZ` (`+0x250`) | `:33` |
| `MaxHeightMinAngle` | -32 | tilt slot C (`+0x254`) | `:34` |
| `MaxHeightMaxAngle` | -32 | tilt slot D; drives `angleZ` (`+0x258`) | `:35` |
| `AngleLerpPower` | 1 | tilt interpolation exponent (`+0x25c`) | `:36` |
| `MinDistToTargetObject` | 1 | min elastic distance to target object (`+0x260`) | `:37` |
| `MaxDistToTargetObject` | 10 | max elastic distance to target object (`+0x264`) | `:38` |
| `MaxHeightLerpFactor` | 0.15 | height lerp limit (`+0x268`) | `:39` |
| `Bounded` | True | cfg requests map-bounded camera (`+0x31c`); **runtime overrides** to False at `docreate.inc:93` (commented) | `:42` |
| `DistToGroups` | 15 | distance to unit groups (`+0x338`) | `:43` |
| `MinFocalLength` | 400 | perspective focal lower bound (`+0x350`) | `:44` |
| `MaxFocalLength` | 400 | perspective focal upper bound (`+0x354`) | `:45` |
| `FocalLengthPower` | 1.0 | focal interpolation power (`+0x360`) | `:46` |
| `ElasticTargetRaycastMode` | false | target raycast bit at `+0x29c` | `:48` |
| `ElasticCameraRaycastMode` | false | camera raycast bit at `+0x29c` | `:49` |
| `PowerDOF` | 0.5 | DOF power (`+0x368`) | `:51` |
| `MinLengthDOF` | 128.0 | DOF length min (`+0x370`) | `:52` |
| `MaxLengthDOF` | 128.0 | DOF length max (`+0x374`) | `:53` |
| `MinNearDOF` | 256.0 | DOF near min (`+0x384`) | `:54` |
| `MaxNearDOF` | 256.0 | DOF near max (`+0x388`) | `:55` |
| `MinFarDOF` | 256.0 | DOF far min (`+0x398`) | `:56` |
| `MaxFarDOF` | 256.0 | DOF far max (`+0x39c`) | `:57` |
| `DynFogDepth` | False | dynamic depth fog **off** in gameplay (`+0x3bc`) | `:59` |
| `DynFogStart` | 0.25 | dyn fog start (`+0x3c0`) | `:60` |
| `DynFogEnd` | 0.025 | dyn fog end (`+0x3c4`) | `:61` |
| `DynFogDensity` | 2.0 | dyn fog density (`+0x3c8`) | `:62` |
| `DynFogPower` | 0.85 | dyn fog power (`+0x3cc`) | `:63` |
| `DynFogOffset` | 0 | dyn fog offset (`+0x3d0`) | `:64` |

Count check: 6 RestrictInfo + 14 ElasticInfo + 8 FreeRotationInfo + 21 top-level = **49** active
keys (the two `//Sphere*` lines are comments, not active keys). This matches DEEPDEC-01's 43 float
+ 1 int + 5 bool loader breakdown (`:125-127`). **observed + derived (verified twice)**.

### 3.2 `cameradebug.cfg` — debug/free profile

Same 49-key schema; differences only (full key set present at `:1-63`, each key at the same
relative position as §3.1):

| Key | Value | Meaning | path:line |
|---|---|---|---|
| `SphereHeight` / `SphereHeightMin` | 19 / 5 | debug altitude/depth range | `:5` / `:6` |
| `SphereLength` / `SphereLengthMin` | 19 / 5 | debug sphere range | `:7` / `:8` |
| `MoveVelocity` | 0.25 | faster elastic move | `:12` |
| `IntervalTime` | 20 | smoothing interval | `:17` |
| `StepTimeMove` / `StepTimeRotation` | 0.001 / 0.001 | faster step | `:18` / `:22` |
| `StepTimeMoveAccel` / `StepTimeMoveDecel` | 0.01 / 0.01 | accel/decel | `:20` / `:21` |
| `StepTimeCameraDistance` | 0.05 | distance smoothing | `:25` |
| `MinHeightMinAngle` / `MinHeightMaxAngle` | -30 / -30 | tilt at min height | `:30` / `:31` |
| `MaxHeightMinAngle` / `MaxHeightMaxAngle` | -48 / -48 | tilt at max height | `:32` / `:33` |
| `MinFocalLength` / `MaxFocalLength` | 86 / 100 | dynamic focal range | `:42` / `:43` |
| `ElasticTargetRaycastMode` / `ElasticCameraRaycastMode` | true / true | both raycasts on | `:46` / `:47` |
| `Bounded` | True | same as main | `:40` |
| `FocalLengthPower` | 1.0 | same as main | `:44` |
| DOF/fog block | identical to §3.1 | no profile-specific change | `:49-62` |

Debug runtime also overrides max height to 500 and tilt to ±90 at `docreate.inc:108-119`
(**commented script text**, so activity UNVERIFIED).

### 3.3 `camerascreenshot.cfg` — screenshot/cinematic profile

| Key | Value | Meaning | path:line |
|---|---|---|---|
| `HeightTarget` | 1 | same | `:3` |
| `//HeightTargetMin` | 0.200000002980232 | commented older value | `:4` |
| `HeightTargetMin` | 0.35 | min target height | `:5` |
| `SphereHeight` / `SphereHeightMin` | 13 / 0.75 | altitude range | `:6` / `:7` |
| `SphereLength` / `//SphereLengthMin` | 13 / 0.35 | length max / commented old min | `:8` / `:9` |
| `SphereLengthMin` | 0.6 | active min length | `:10` |
| `MoveVelocity` | 0.5 | elastic move | `:14` |
| `HeightVelocityFactor` | 1.25 | height velocity | `:15` |
| `RotationVelocity` | 0.0500000007450581 | rotation velocity (f32 literal) | `:16` |
| `IntervalTime` | 100 | interval | `:19` |
| `StepTimeMove` | 9.99999974737875E-5 | move step (f32 literal) | `:20` |
| `StepTimeMoveDirection` | 1 | direction step | `:21` |
| `StepTimeMoveAccel` / `StepTimeMoveDecel` | 0 / 1 | accel off, decel on | `:22` / `:23` |
| `StepTimeRotation` / raycast steps | 0.00100000004749745 / 0.0500000007450581 | all f32 literals | `:24-27` |
| `MinHeightMinAngle` / `MinHeightMaxAngle` | -90 / 20 | full free tilt at min height | `:32` / `:33` |
| `MaxHeightMinAngle` / `MaxHeightMaxAngle` | -90 / 20 | full free tilt at max height | `:34` / `:35` |
| `AngleLerpPower` | 0.4 | tilt interpolation | `:36` |
| `MinDistToTargetObject` / `MaxDistToTargetObject` | 0.5 / 10 | distance bounds | `:37` / `:38` |
| `MaxHeightLerpFactor` | 0.01 | height lerp | `:39` |
| `Bounded` | False | unbounded camera | `:42` |
| `DistToGroups` | 15 | same | `:43` |
| `//MinFocalLength` / `//MaxFocalLength` | 45 / 50 | commented old focal | `:44` / `:45` |
| `MinFocalLength` / `MaxFocalLength` | 95 / 95 | screenshot focal | `:46` / `:47` |
| `FocalLengthPower` | 0.5 | focal interpolation | `:48` |
| `ElasticTargetRaycastMode` / `ElasticCameraRaycastMode` | true / true | both on | `:50` / `:51` |
| DOF block | identical to §3.1 | no change | `:53-59` |
| `DynFogDepth` | True | depth fog **on** (contrast with gameplay) | `:61` |
| other DynFog* | 0.25 / 0.025 / 2.0 / 0.85 / 0 | same values as §3.1 | `:62-66` |

Screenshot runtime sets max/min camera height 140/20 and more fog overrides at
`docreate.inc:308-320` (**commented**).

### 3.4 `default.cameras` — named camera bookmarks (3 records, 28 keys each)

Keys are identical across records; values differ. Columns below are the literal values.

| Key | Camera0 | @Camera0 | @CameraDebug | Meaning | path:line (Cam0 / @Cam0 / @Dbg) |
|---|---|---|---|---|---|
| `Name` | Camera0 | @Camera0 | @CameraDebug | record id | `:4` / `:34` / `:64` |
| `TargetX` | 0 | 0 | 0 | ground-focus X | `:5` / `:35` / `:65` |
| `TargetY` | 49 | 49 | 19 | **height** h (metres) | `:6` / `:36` / `:66` |
| `TargetZ` | 78.42125 | 78.42125 | 18 | **back-offset** at that height | `:7` / `:37` / `:67` |
| `PosX` | 0 | 0 | 0 | rotated offset dx | `:8` / `:38` / `:68` |
| `PosY` | 0.0529899597167969 | same | 0.074314475 | rotated offset dy | `:9` / `:39` / `:69` |
| `PosZ` | 0.084808349609375 | same | 0.066913068 | rotated offset dz | `:10` / `:40` / `:70` |
| `DirX` | 0 | 0 | 0 | look direction X | `:11` / `:41` / `:71` |
| `DirY` | 0 | 0 | 0 | look direction Y | `:12` / `:42` / `:72` |
| `DirZ` | -1 | -1 | -1 | look toward −Z (yaw 0) | `:13` / `:43` / `:73` |
| `UpX` | 0 | 0 | 0 | up vector X | `:14` / `:44` / `:74` |
| `UpY` | 1 | 1 | 1 | up vector Y | `:15` / `:45` / `:75` |
| `UpZ` | 0 | 0 | 0 | up vector Z | `:16` / `:46` / `:76` |
| `FocalLength` | 400 | 400 | 100 | perspective focal | `:17` / `:47` / `:77` |
| `DepthOfView` | 1200 | 1200 | 50 | DOV | `:18` / `:48` / `:78` |
| `MoveSpeedToMark` | 1 | 1 | 1 | bookmark move speed | `:19` / `:49` / `:79` |
| `TurnSpeedToMark` | 0.100000001490116 | same | same | bookmark turn speed | `:20` / `:50` / `:80` |
| `RelativeMarkQuarter` | rqBack | rqBack | rqBack | mark quadrant | `:21` / `:51` / `:81` |
| `MoveToMarkObject` | False | False | False | flag | `:22` / `:52` / `:82` |
| `TurnToMarkObject` | False | False | False | flag | `:23` / `:53` / `:83` |
| `Tracking` | False | False | False | flag | `:24` / `:54` / `:84` |
| `TrackingDistance` | 1 | 1 | 1 | tracking distance | `:25` / `:55` / `:85` |
| `TrackingOffsetX/Y/Z` | 0 / 1 / 0 | 0 / 1 / 0 | 0 / 1 / 0 | tracking offset | `:26-28` / `:56-58` / `:86-88` |
| `MarkCustomName` | empty | empty | empty | string | `:29` / `:59` / `:89` |
| `MarkPlayerName` | empty | empty | empty | string | `:30` / `:60` / `:90` |
| `AutoRayCast` | False | False | False | flag | `:31` / `:61` / `:91` |
| `SmoothingChange` | False (file-level) | — | — | smoothing toggle | `:94` |
| `SmoothingTime` | 3000 (file-level) | — | — | smoothing ms | `:95` |

Numeric verification (derived, checked twice with Python):

- `TargetZ / TargetY = 78.42125 / 49 = 1.6004337`; `cot(32°) = 1.6003345` → 0.0062 % apart.
- `49·cot(32°) = 78.41639` vs stored `78.42125` (Δ 0.00486 m).
- `PosY = 0.05298996 ≈ 0.1·sin(32°) = 0.05299193`; `PosZ = 0.08480835 ≈ 0.1·cos(32°) = 0.08480481`.
- `PosZ / PosY = 1.60046 ≈ cot(32°)`.

**Interpretation (derived, strong):** `TargetY/TargetZ` encode (height, back-offset), and
`PosX/Y/Z` encode the tiny rotated offset vector produced by
`dz := 0.1; VectorRotateX(dx,dy,dz,angleZ)` in `onmousewheel.inc:51-52` /
`control.script:598-599`; they are **not** an absolute world position. The exact VM rotation
sign convention remains UNVERIFIED (§6.5).

---

## 4. Shader file records

### 4.0 Format inventory (observed)

- **109 files**, total **272,517 bytes**, all ASCII, no BOM, all CRLF (8,562 CRLF, 0 bare LF).
- Extensions: `.frag` 58, `.vert` 47, `.bak` 2, `.lib` 1, `.ref` 1.
- Directories: `obj\` 75, `tone\` 26, `water\` 6, root 2.
- `shaders.lib` is **1,813 lines**; `shaders.ref` 180 lines.
- Six exact duplicate pairs (SHA-256 identical), so the 109 files are fewer distinct programs:
  `def.ppl.sm.vert = ppl.sm.id1.vert`; `def.ppl.smx9.frag = ppl.smx9.id1.frag`;
  `def.pvl.sm.vert = pvl.sm.id0.vert`; `def.pvl.smx3.frag = tree.pvl.id6.frag`;
  `gr.pvl.smx1.frag = pvl.smx1.id0.frag`; `rim.sm.id2.vert = unit.sm.id8.vert`.
- Twenty bone-caster/skinned vertex files collapse to **two** templates differing only in
  `#define NBONES`: `b{1,3,5,16,18,20,22,24,27,42}` (flat caster, normalized hash
  `8ae50f58fe69`) and `unit.sm.b{1,3,5,16,18,20,22,24,27,42}` (lit skinned, `a6893c9e1b0f`).
- `shaders.lib` contains 74 active `vertex =` records, 34 active `fragment =` records and 84
  uniform `name =` records (plus 4 commented `vertex` lines). **109 files ≠ 109 programs** —
  correction §8.5.

### 4.1 `shaders.lib` — master registry (full parameter dump)

Register block `shaders.lib:2-14` maps engine uniform aliases:

| Key | Value | line |
|---|---|---|
| `srShadowColor` | shadowColor | `:3` |
| `srEyePos` | eyePos | `:4` |
| `srCameraMVM` | cameraMVM | `:5` |
| `srFogMode` | fogMode | `:6` |
| `srShadowed` | shadowed | `:7` |
| `srVertexColor` | vertexColor | `:8` |
| `srTexShadow` | texShadow | `:9` |
| `srNewTime` | newTime | `:10` |
| `srTexGen` | texGen | `:11` |
| `srShadowSize` | shadowSize | `:12` |
| `srPostProc` | postProc | `:13` |

Two profiles: `ShadersSM20` `:15`, `ShadersSM30` `:914`. Each has 7 families
(`HeightField`, `Default`, `None`, `Grass`, `Decal`, `DecalCubeMap`, `Custom`). Family header
lines: SM20 `16/53/79/105/131/157/195`; SM30 `915/952/978/1004/1030/1056/1094`.

Per-program capability flags (key = value, all `observed`; `T`=true, `F`=false; line numbers are
SM20 | SM30 in that order):

| Program | vertex / fragment | tangentSpace | boneMatrices | count | shadowColor | eyePos | cameraMVM | fogMode | shadowed | vertexColor | texShadow | newTime | texGen | shadowSize | uniforms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| HeightField | `hf.pvl.sm.vert` / `hf.pvl.smx3\|smx9.frag` `:17-18`,`:916-917` | F | F | 0 | T | F | T | T | T | T | T | F | **T** | F | texUnit0=0, texUnit1=1 (`:34,43` / `:933,942`) |
| Default | `def.pvl.sm.vert` / `def.pvl.smx3.frag` `:54-55`; SM30 `def.ppl.sm.vert` / `def.ppl.smx9.frag` `:953-954` | F | F | 0 | T | F | T | T | T | T | T | F | F | **T** | texUnit0=0 (`:70` / `:969`) |
| None | `pvl.vert` / `pvl.frag` `:80-81`,`:979-980` | F | F | 0 | F | F | F | T | F | T | F | F | F | F | texUnit0=0 (`:96`/`:995`) |
| Grass | `gr.pvl.sm.vert` / `gr.pvl.smx1.frag` `:106-107`,`:1005-1006` | F | F | 0 | T | F | T | T | T | F | T | F | F | F | texUnit0=0 (`:122`/`:1021`) |
| Decal | `dec.pvl.sm.vert` / `dec.pvl.smx3\|smx9.frag` `:132-133`,`:1031-1032` | F | F | 0 | T | F | T | T | T | F | T | F | F | F | texUnit0=0 (`:148`/`:1047`) |
| DecalCubeMap | `dec.ref.pvl.sm.vert` / `dec.ref.pvl.smx3\|smx9.frag` `:158-159`,`:1057-1058` | F | F | 0 | T | F | T | T | T | F | T | F | F | F | texUnit0=0, texUnit1=1 (`:176,185`/`:1075,1084`) |
| Custom | variable (see below) | varies | varies | 0..42 | varies | F | varies | T | varies | varies | varies | F | F | varies | varies |

`Custom` subrecords (SM20 `:196-709`, SM30 `:1095-1805`), all with `fogMode = true`,
`eyePos = false`, `newTime = false`:

- id0 `:197-198` `pvl.sm.id0.vert` + `pvl.smx1.id0.frag`; id1 `:223-224` `ppl.sm.id1.vert` +
  `ppl.smx3.id1.frag`; id2 `:249-250` rim; id3 `:275-276` env; id4 `:356-357` tbn;
  id5 `:421-422` tbn.env; id6 `:532-533` tree; id7 `:559-560` build;
  id8/29/30/31 `:683-684`,`:767-768`,`:845-846`,`:...` FX family;
  bone records `:603-680` (SM20) / `:1502-1579` (SM30) with `boneMatricesCount` =
  16/18/20/22/24/27/42 for `b*.id9..15` and `unit.sm.b*.id16..22`, then 1/3/5 for
  `b*.id23..25` and `unit.sm.b*.id26..28`;
  `unob` ref at `:600` (`shaders.ref`), `uim` refs at `:602-680`.
- A commented `fx.tbn.id30` record at `:710-761` (SM20) — **not active**; its two source files
  still exist on disk.
- Uniform defaults in Custom: `world` matrix (env/tbn.env), `texUnit0..2` sampler indices,
  `specularPower`, `bumpSmoothness`, `bumpHeight`, `custColor` (vec4 XY/Z/W = 0),
  `randValue/randMax/randStep/randBias` (FX).

### 4.2 `shaders.ref` — 6 override records

| Refkey | vertex / fragment | Flags (differences) | Uniforms | path:line |
|---|---|---|---|---|
| `.shaderssm20.custom.unob` | `unit.sm.id8.vert` / `unit.smx3.id8.frag` | shadowColor=T, cameraMVM=T, fogMode=T, shadowed=T, texShadow=T, shadowSize=T, vertexColor=F | texUnit0=0 | `:4-29` |
| `.shaderssm20.custom.uim` | `b16.id9.vert` / `b.frag` | boneMatrices=T, count=16; **all lighting/fog/shadow flags F** | none | `:30-46` |
| `.shaderssm20.custom.u` | `unit.sm.b16.id16.vert` / `unit.smx3.id8.frag` | boneMatrices=T, count=16, shadowColor=T, cameraMVM=T, fogMode=T, shadowed=T, texShadow=T, shadowSize=T | texUnit0=0, `custColor` vec4(0,0,0,0) | `:47-88` |
| `.shaderssm30.custom.unob` | `unit.sm.id8.vert` / `unit.smx9.id8.frag` | same intent, 9-tap | texUnit0=0 | `:93-118` |
| `.shaderssm30.custom.uim` | `b16.id9.vert` / `b.frag` | same flat caster | none | `:119-135` |
| `.shaderssm30.custom.u` | `unit.sm.b16.id16.vert` / `unit.smx9.id8.frag` | lit skinned, 9-tap | texUnit0=0, `custColor` | `:136-177` |

`custColor` is the shader-side destination of the player key-colour uniform
(`SetGameObjectUniform4fByHandle(...,0,...)` in `misc.script:5073`, V761 `:52-56`); the
operator `tex0.rgb = mix(tex0.rgb, custColor.rgb*tex0.rgb, tex0.a*custColor.a)`
(`unit.smx3.id8.frag:38`, `build.pvl.smx3.id7.frag:13`) is **observed** — a multiplicative tint
blended by texture alpha × uniform alpha, not a replacement.

### 4.3 `obj\` — 75 files (object/terrain/unit/FX stages)

All use OpenGL fixed-function-era GLSL: `gl_Vertex`, `gl_Normal`, `gl_MultiTexCoord0..3`,
`gl_Color`, `gl_ModelViewMatrix`, `gl_NormalMatrix`, `gl_TextureMatrix[0]/[3]`,
`gl_EyePlaneS/T[0]`, `gl_LightSource[0]`, `gl_FrontLightProduct[0]`,
`gl_FrontLightModelProduct.sceneColor`, `gl_Fog.*`, `ftransform()`, `gl_TexCoord[0..7]`.

#### 4.3.1 Terrain heightfield family (`hf*`), 3 files

| File | Bytes | Inputs / uniforms (`path:line`) | Semantics |
|---|---:|---|---|
| `hf.pvl.sm.vert` | 1452 | `uniform mat4 cameraMVM :1`, `int vertexColor :2`, `int texGen :3`, `const vec3 eye=vec3(0.0) :4`; uses `gl_ModelViewMatrix*gl_Vertex :9`, `gl_LightSource[0].position :13`, `gl_NormalMatrix*gl_Normal :15` | eye/light/half/normal basis `:12-15`; ambient `sceneColor+frontAmbient :18`, diffuse `max(dot(l,n),0)*Ld :19`, optional `diffuse*=gl_Color :21-22`, specular `pow(max(dot(h,n),0),shininess)*Ls :23`; **eye-plane texgen** `s=dot(realpos,gl_EyePlaneS[0])`, `t=dot(realpos,gl_EyePlaneT[0])`, then `TextureMatrix[0]*` `:30-32`; `TexCoord[1]=MultiTexCoord1 :34`; shadow coord `TextureMatrix[3]*cameraMVM*realpos :36`; packed `TexCoord[4]=ambient+diffuse :38`, `[5]=specular :39`; fog depth `abs(realpos.z)` on ATI else `length(realpos)` `:42-46`; `ftransform() :49` |
| `hf.pvl.smx3.frag` | 1584 | `sampler2D texUnit0/1 :1-2`, `sampler2DShadow texShadow :3`, `int fogMode :4`, `int shadowed :5`, `vec4 shadowColor :6` | RGB from unit0 `:13`, **alpha from unit1 `:14`**; combine `rgb*TexCoord[4]+TexCoord[5] :17`; 3-tap PCF, `of=1/512 :23`, taps `:26-28`, `/3 :29`, `rgb *= sh + shadowColor*(1-sh) :30`; fog LINEAR/EXP/EXP2 `:38-45` with `1.442695`, `mix(fog.color,color,fog) :46`; `gl_FragColor=color :50` |
| `hf.pvl.smx9.frag` | 2048 | same uniforms `:1-6` | same combine `:13-17`; **9-tap PCF** `of=1/512 :22`, taps `:25-33`, `/9 :34`, multiply `:35`; fog `:43-51`; output `:55` |

Blend/alpha rule for terrain: `color.a` comes from the second mask sampler, **not** from albedo;
lighting multiplies RGB only. `texGen=true` and `vertexColor=true` come from
`shaders.lib:27,30` (and `:926,929`).

#### 4.3.2 Per-vertex lighting (`pvl*`) and per-pixel (`ppl*`) families, 16 files

| File | Bytes | Key parameters / semantics (`path:line`) |
|---|---:|---|
| `pvl.vert` | 1133 | `VCOLOR_FACTOR 2.5 :1`, `int vertexColor :3`; same realpos/e/l/h/n `:9-15`; `ambient+diffuse :18-19`, `specular :20`; `diffuse*=gl_Color*2.5; ambient*=gl_Color*2.5 :22-26`; `TexCoord[0]=MultiTexCoord0 :29`, `[4]=ambient+diffuse :31`, `[5]=specular :32`; fog depth `:35-39` |
| `pvl.frag` | 873 | `sampler2D texUnit0 :1`, `int fogMode :2`; `color=tex0*TexCoord[4]+TexCoord[5] :9`; **`color.a=tex0.a*gl_FrontMaterial.diffuse.a :11`**; fog `:14-26` |
| `def.pvl.sm.vert` | 1233 | identical to `pvl.sm.id0.vert` (SHA-256 equal); adds `cameraMVM :3`, shadow coord `:32` |
| `pvl.sm.id0.vert` | 1233 | as above |
| `pvl.smx1.id0.frag` | 1106 | 1-tap shadow `shadow2DProj(...).r<0.999 ? color*=shadowColor :19`; alpha `:14`; fog `:23-35` |
| `pvl.smx3.id0.frag` | 1417 | `of=1/shadowSize :20`, 3 taps `:22-24`, `/3 :25`, multiply `:26`; alpha `:15`; fog `:30-42` |
| `def.pvl.smx3.frag` | 1507 | SHA-256 equal to `tree.pvl.id6.frag`; `of=1/shadowSize :21`, taps `:23-25`, `/3 :26`, multiply `:27`; alpha `:15` |
| `ppl.sm.id1.vert` | 863 | SHA-256 equal to `def.ppl.sm.vert`; forwards `l/h/n` in `TexCoord[4..6] :22-24` and `gl_Color*2.5` in `[7] :26`; shadow `:20`; fog depth `:29-33` |
| `def.ppl.sm.vert` | 863 | same |
| `ppl.smx3.id1.frag` | 1968 | `vertexColor :3`; recomputes ambient/diffuse/specular in fragment `:15-17`; vertex-colour multiply on ambient **and** diffuse `:19-23`; `color=tex0*(ambient+diffuse)+specular :27`; alpha `:29`; 3-tap `of=1/shadowSize :34-40`; fog `:44-56` |
| `ppl.smx9.id1.frag` | 2522 | SHA-256 equal to `def.ppl.smx9.frag`; same fragment lighting `:15-27`; 9-tap PCF `:34-46`; fog `:50-62` |
| `def.ppl.smx9.frag` | 2522 | same |

#### 4.3.3 Grass (`gr*`), 2 files

`gr.pvl.sm.vert` (1200 B): wind displacement
`position.xyz += gl_MultiTexCoord1.x * sin(gl_MultiTexCoord1.y*gl_MultiTexCoord1.z + gl_MultiTexCoord1.w) :8`;
lighting `:12-20`; shadow coord `:25`; fog `:31-35`; `gl_Position=gl_ModelViewProjectionMatrix*position :38`.
`gr.pvl.smx1.frag` (1106 B, SHA-256 equal to `pvl.smx1.id0.frag`): 1-tap shadow `:19`,
alpha `:14`, fog `:23-35`.

#### 4.3.4 Decal (`dec*`) family, 6 files

`dec.pvl.sm.vert` (1063 B): `TexCoord[0]=TextureMatrix[0]*MultiTexCoord0 :21`, shadow `:23`,
lighting `:16-18`, fog `:29-33`.
`dec.pvl.smx3.frag` (1393 B): `of=1/512 :19`, 3 taps `:21-23`, `/3 :24`, multiply `:25`,
alpha `:14`, fog `:28-41`.
`dec.pvl.smx9.frag` (1947 B): 9 taps `:21-29`, `/9 :30`, multiply `:31`, fog `:34-47`.
`dec.ref.pvl.sm.vert` (1138 B): adds **cube reflection vector**
`TexCoord[1]=vec4(reflect(vec3(realpos),n),1.0) :23`.
`dec.ref.pvl.smx3.frag` (1558 B): `samplerCube texUnit1 :2`, `textureCube :12`,
`color = tex0*cub0*TexCoord[4]+TexCoord[5] :15` (commented `mix` alternative `:14`), alpha `:17`,
3-tap `:22-28`, fog `:31-44`.
`dec.ref.pvl.smx9.frag` (2112 B): same with 9-tap `:24-34`.

#### 4.3.5 Rim lighting (`rim*` + `unit.sm.id8`), 5 files

`rim.sm.id2.vert` (823 B, equals `unit.sm.id8.vert`): forwards eye in `TexCoord[7] :23`.
`rim.smx3.id2.frag` (2454 B) / `rim.smx9.id2.frag` (3008 B): constants
`edgeWidth=0.1 :8`, `edgeMinScale=0.1 :9`, `edgeMulScale=4.0 :10`,
`edgeAddDiff=(0.2,0.2,0.2,0.2) :11`, `edgeMulLight=0.0 :12`, `edgeMinLength=0.0 :13`;
`bias(value,b) = (b>0)?pow(value,log2(b)/log2(0.5)):0 :15-18`;
`edgescale=max(edgeMinScale, edgeMulScale*bias(1-max(dot(e,n),0), edgeWidth)) :31`;
`edgelight=edgescale*(((ambient+diffuse)*edgeMulLight)+edgeAddDiff) :32`;
`color=tex0*(ambient+diffuse+edgelight)+specular :37`; alpha `:39`; 3-/9-tap `:44-50`/`:44-56`;
fog `:53-66`/`:59-72`.
`unit.smx3.id8.frag` (2671 B) / `unit.smx9.id8.frag` (3225 B): same rim constants `:10-20`,
plus **`custColor` multiplicative tint `tex0.rgb=mix(tex0.rgb,custColor.rgb*tex0.rgb,tex0.a*custColor.a) :38`**;
`color.a=gl_FrontMaterial.diffuse.a :42` (texture alpha **ignored** for units);
shadow block wrapped in `#vendor_ifdef ATI` (skipped on ATI due to indexed-uniform bug) `:45-58`;
fog `:60-74`/`:66-80`.

#### 4.3.6 Cube-map environment (`env*`), 3 files

`env.sm.id3.vert` (1033 B): `uniform mat4 world :1`, `cameraMVM :2`; reflection
`refnormal=world*vec4(gl_Normal,0) :17`, `refpos=world*gl_Vertex :18`,
`reflection=vec4(reflect(refnormal.xyz,normalize(eye-refpos.xyz)),1) :19`, `TexCoord[1]=reflection :23`.
`env.smx3.id3.frag` (1960 B) / `env.smx9.id3.frag` (2514 B): `samplerCube texUnit1 :2`,
`textureCube :14`, `specular = pow(max(dot(h,n),0),shininess)*Ls*tex1*tex0.a*specularPower :22`
(note `specularPower` uniform `:8`), colour `:25`, alpha `:27`, 3-/9-tap `:32-38`/`:32-44`,
fog `:41-54`/`:47-60`.

#### 4.3.7 Tangent-space normal mapping (`tbn*`), 6 files

`tbn.sm.id4.vert` (942 B): `t=normalize(NormalMatrix*MultiTexCoord1.xyz) :10`,
`b=...MultiTexCoord2.xyz :11`, `n=...gl_Normal :12`, `mat3 tbn=mat3(t,b,n) :13`,
`e/l` transformed into tangent space `:16-17`, `h=normalize(l+e) :18`,
packed `l/h` in `TexCoord[4]/[5] :25-26`.
`tbn.smx3.id4.frag` (2050 B) / `tbn.smx9.id4.frag` (2604 B): uniforms
`bumpSmoothness :8`, `bumpHeight :9`, `specularPower :10`;
`n=normalize(tex1.xyz*bumpSmoothness - bumpHeight*bumpSmoothness) :21`;
`specular*=tex1.a*specularPower :24`; alpha `:29`; 3-/9-tap `:34-40`/`:34-46`; fog `:43-56`/`:49-62`.
`tbn.env.sm.id5.vert` (1184 B): TBN `:11-14`, cube reflection in `TexCoord[2] :22-28`.
`tbn.env.smx3.id5.frag` (2143 B) / `tbn.env.smx9.id5.frag` (2697 B): `samplerCube texUnit2 :3`,
`tex2 :18`, `specular*=tex2*tex1.a*specularPower :26`; alpha `:31`; fog `:45-58`/`:51-64`.

#### 4.3.8 Trees (`tree*`), 4 files

`tree.pvl.id6.vert` (1648 B): `VCOLOR_FACTOR 2.5 :1`, `VLUMIN_FACTOR 0.5 :2`,
`uniform float postProc[6] :6`; ATI hack `if(n.z<0.000001) n.z=-n.z :21-24`;
`VCOLOR` multiply `:31-34`; luminance floor
`lumcont=1+(1-postProc[4])*0.5 :35`, `luminavg=vec3(0.5) :36`,
`diffuse.xyz=max(diffuse.xyz,mix(luminavg,diffuse.xyz,lumcont)) :37` (ambient `:38`).
`tree.pvl.id6.frag` (1507 B): equals `def.pvl.smx3.frag`; 3-tap `:21-27`, fog `:30-43`.
`tree.ppl.id6.vert` (977 B): per-pixel variant, forwards `l/h/n :27-29`, `gl_Color*2.5 :31`.
`tree.ppl.id6.frag` (2980 B): `VLUMIN_FACTOR 0.5 :1`, `postProc[6] :10`, luminance floor `:26-29`,
9-tap `:41-53`, debug block `:72-77` (commented), fog `:56-69`.

#### 4.3.9 Buildings (`build*`), 4 files

`build.pvl.sm.id7.vert` (1043 B): standard PVL lighting `:9-18`, shadow `:23`, fog `:28-33`.
`build.pvl.smx3.id7.frag` (1597 B): `uniform vec4 custColor :7`,
`tex0.rgb=mix(tex0.rgb,custColor.rgb*tex0.rgb,tex0.a*custColor.a) :13`,
`color.a=gl_FrontMaterial.diffuse.a :17` (texture alpha ignored), 3-tap `:23-29`, fog `:32-45`.
`build.ppl.sm.id7.vert` (771 B): per-pixel vectors `:20-22`.
`build.ppl.smx9.id7.frag` (2456 B): tint `:20`, alpha `:24`, 9-tap `:29-41`, fog `:44-57`.

#### 4.3.10 FX (`fx*`) family, 6 files

`fx.id29.vert` (731 B): forwards `l/h/n` in `TexCoord[1..3] :18-20`, `gl_Color :22`, fog depth `:25-29`.
`fx.id29.frag` (1428 B): per-pixel lighting `:8-13`, vertex-colour multiply `:15-19`,
alpha `:25`; **fog block is commented out `:28-41`** — no fog on this FX program despite
`fogMode=true` in `shaders.lib:691`.
`fx.id30.frag` (1664 B): uniforms `randValue :3`, `randMax :4`, `randStep :5`, `randBias :6`,
two samplers `:1-2`; `texr=tex0[int(randValue*randMax)*randStep+randBias] :28`,
`tex1=texture2D(texUnit1,vec2(texr,0)) :29`, `color=tex1*(ambient+diffuse)+specular :31`,
`color.a=gl_FrontMaterial.diffuse.a :33`; fog commented `:36-49`.
`fx.id31.frag` (2422 B): single sampler, same `texr :43`,
`color=texr*(ambient+diffuse)+specular :44`, **custom alpha**
`color.a=gl_FrontMaterial.diffuse.a*texr + clamp(texr-(1-gl_FrontMaterial.diffuse.a),0,1) :49`;
fog commented `:52-65`.
`fx.tbn.id30.vert` (865 B) / `fx.tbn.id30.frag` (1659 B): TBN from hard-coded
`t=(1,0,0)`, `b=(0,0,1) :9-10`; `bumpSmoothness=1.0`, `bumpHeight=0.1 :13-14`;
normal from `texUnit1 :15`; fog **active** `:32-45`; registry record commented (`shaders.lib:710-761`).

#### 4.3.11 Bone/skin vertex stages, 20 files

Flat shadow casters `b{1,3,5,16,18,20,22,24,27,42}.id*.vert` (210–211 B each):
`#define NBONES n :1`, `uniform mat4 boneMatrices[NBONES] :3`,
`pos=gl_MultiTexCoord1.x*(boneMatrices[int(gl_MultiTexCoord2.x)]*gl_Vertex) :7`,
`gl_Position=gl_ModelViewProjectionMatrix*pos :8`; no normals/lighting. Paired with `b.frag`
(60 B) which writes flat white `gl_FragColor=vec4(1,1,1,1) :3` — a **shadow-map caster pass**.

Lit skinned `unit.sm.b{1,3,5,16,18,20,22,24,27,42}.id*.vert` (1124–1125 B each):
`NBONES :1`, `boneMatrices :4`, `weight=gl_MultiTexCoord1.x :10`,
`index=int(gl_MultiTexCoord2.x) :11`, `aposn=weight*(boneMatrices[index]*gl_Vertex) :12`,
`anorm=weight*(boneMatrices[index]*vec4(gl_Normal,0)) :13`,
realpos `:16`, e/l/h/n `:19-22`, shadow coord `:27`, packed l/h/n/e `:29-32`,
fog depth `:35-39`, `gl_Position=gl_ModelViewProjectionMatrix*aposn :42`.

#### 4.3.12 Test shaders, 2 files

`test.config.vert` (585 B): `cameraMVM :1`, realpos `:5`, l/e `:6-7`, texgen `:8`,
shadow `:9`, packed l/h/n `:10-12`, fog depth `:13-17`, `ftransform :18`.
`test.config.frag` (615 B): assembles `light = sceneColor + ambient + diffuse + specular :8-11`,
`color.xyz*=light.xyz :12`, **unconditional LINEAR fog** `:13-14`, output `:15`. Template probe,
not in any active `shaders.lib` record.

### 4.4 `tone\` — 26 files (post-processing chain)

Vertex stages: `filter.vert` (85 B, `TexCoord0=ftransform :3-4`), `gauss.vert` (868 B,
`uniform float offset :1`, 8 diagonal/axis UVs in `TexCoord[0..7] :5-12`), `tone.vert` (161 B,
`TexCoord[0..2] :3-5`), `tonedof.vert` (199 B, adds `TexCoord[3] :6`).

Fragment-stage parameter ledger (all `uniform` unless marked `const`/`#define`):

| File | Bytes | Parameters (`path:line`) | Semantics |
|---|---:|---|---|
| `filter.frag` | 509 | `texUnit0 :1`, `filterColor :2`, `filterStart :3`, `filterEnd :4`, `smoothStart :5`, `smoothEnd :6` | `c=dot(color.rgb,filterColor.rgb) :12`; darken with `1-smoothstep(filterStart,filterEnd,c) :13`; bright-pass `smoothstep(smoothStart,smoothEnd,sum) :16`; alpha forced 1 `:18` |
| `gauss.frag` | 585 | `texUnit0 :1` | 8 taps averaged `/8 :5-13`, alpha 1 `:14` |
| `tone.frag` | 660 | `texUnit0/1/2 :4-6`, `blurOpacity :7`, `hdrIntencity :8`, `mulColor :9`, `brightMax :10` | `color0 += color1*blurOpacity :20`; Reinhard-like `yd=hdrIntencity*(hdrIntencity/brightMax+1)/(hdrIntencity+1) :22`; `color0 *= yd + color2*mulColor :23` |
| `tonecont.frag` | 2399 | tone params `:4-10` + `bright :14`, `saturate :15`, `contrast :16`, `avgLumR/G/B :17-19`, `afterBlur :20`, `vignetteInner/Outer/Adjust :21-23` (comments give 0.7/1.75/1.25); `const lumcoeff=(0.2125,0.7154,0.0721) :50` | `vignette(pos,inner,outer)=vignetteAdjust-smoothstep(inner,outer,length(pos)) :35-40`; `contrastSaturationBrightness :43-58`; `color0*=yd/vignetteAdjust+... :71`; `mix(color0,color1,afterBlur) :76`; vignette `:78-79` |
| `tonecontgamma.frag` | 2807 | as `tonecont` + `colorCurveSampler :27`, `fade :28` | same `:70-84`; gamma LUT lookup per channel `:88-92`; `mix(color0,newcolor,fade) :92`, alpha 1 `:93` |
| `tonegamma.frag` | 1068 | tone `:4-10`, `colorCurveSampler :14`, `fade :15` | tone `:22-28`, LUT `:32-37` |
| `tonedof.frag` | 1207 | tone `:4-11`, `texUnit3 /*depth*/ :7`, `focalLength :15`, `focalDNear :16`, `focalDFar :17` | `getDepth(coord)=2·1·focalDFar/(focalDFar+1-(2·tex3.x-1)(focalDFar-1)) :19-22`; DOF blur `if(depth>=focalLength) mix(color0,color1,clamp(abs(depth-focalLength)/focalDNear,0,1)) :35-40` |
| `tonedofcont.frag` | 2715 | tonedof + contrast params `:21-30`, lumcoeff `:48` | DOF `:76-81`, tone `:85-88`, contrast `:92-93`, vignette `:95-96` |
| `tonedofgamma.frag` | 1629 | tonedof + `colorCurveSampler :21`, `fade :22` | DOF `:42-47`, tone `:51-54`, LUT `:58-63` |
| `tonedoffxaa.frag` | 3614 | tonedof + `viewPort :18`; FXAA consts `SUBPIX_SHIFT=0 :29`, `EDGE_SENS=1/64 :30`, `SPAN_MAX=8 :52`, `REDUCE_MUL=0 :53`, `REDUCE_MIN=1/128 :54`; luma `(0.299,0.587,0.114) :56` | `fxaa()` depth-edge gate `if(d_m-d_av<EDGE_SENS) return texture(buf,coord) :44-50`; 5-tap span `:76-87`; applied at `:95` |
| `tonedofcontfxaa.frag` | 5122 | tonedofcont + FXAA (`viewPort :18`, consts `:70-71`, `:93-95`) | same FXAA `:68-128`, DOF `:142-145`, tone/contrast/vignette `:153-...` |
| `tonedofgammafxaa.frag` | 4036 | tonedofgamma + FXAA (`:18`, `:37`, `:59-61`) | FXAA `:34-95`, DOF `:108-111`, tone+LUT `:119-128` |
| `tonedofcontgamma.frag` | 3151 | tonedofcont + gamma LUT `:34-35` | DOF `:83-86`, tone `:94`, contrast `:107`, LUT `:107-111` |
| `tonedofcontgammafxaa.frag` | 5558 | previous + FXAA (`viewPort :18`, consts `:78-79`,`:100-102`) | FXAA `:75-136`, DOF `:149-152`, tone/contrast `:160-...`, LUT `:173-177` |
| `tonedofssao.frag` | 3164 | tonedof + `viewPort :26` + `ssaoNearFar :30`, `ssaoCap :31`, `ssaoMultiplier :32`, `ssaoRange :33`, `ssaoDepthTolerance :34`, `ssaoColor :35`; `#define PI 3.14159265 :1`, `SAMPLES 3 :2`, `RINGS 3 :3`, `SSAO_BRIGHT_FACTOR 1.0/1.2 :5/:7` | noise `fract(sin(dot(coord,(12.9898,78.233)))*43758.5453) :48-49`; `ssaoDepth=(2*0.1)/(far+near-tex3.x(far-near)) :53`; compare `:58-62`; rings×samples loop `:64-87`; brightness `SSAO_BRIGHT_FACTOR*yd :111` |
| `tonedofcontssao.frag` | 5181 | as above + contrast `:33-42` | SSAO `:97-143`, tone `:167`, DOF `:156-159` |
| `tonedofgammassao.frag` | 3572 | SSAO + gamma `:30-31` | SSAO `:69-92`, tone `:116`, LUT `:126-130` |
| `tonedofssaofxaa.frag` | 5596 | SSAO + FXAA (consts `:93-94`,`:116-118`) | SSAO `:64-88`, FXAA `:91-152`, tone `:180` |
| `tonedofcontgammassao.frag` | 5133 | SSAO + contrast + gamma (`:30-53`) | full SSAO helper :`99-133` (see §4.4.1), tone `:157`, LUT `:178-182` |
| `tonedofcontssaofxaa.frag` | 7613 | SSAO + contrast + FXAA | SSAO `:97-145`, FXAA `:147-208`, tone `:236` |
| `tonedofgammassaofxaa.frag` | 6004 | SSAO + gamma + FXAA | SSAO `:69-95`, FXAA `:96-157`, LUT `:195-199` |
| `tonedofcontgammassaofxaa.frag` | 7565 | **superset**: all tone + DOF + contrast + gamma + SSAO + FXAA (uniforms `:12-53`, FXAA consts `:139-140`,`:162-164`) | most complete chain in the donor; details §4.4.1 |

#### 4.4.1 Full SSAO helper (verbatim-critical lines, `tonedofcontgammassaofxaa.frag`)

```
:85-88  float getDepth(vec2 coord) { return 2.0*1.0*focalDFar/
          (focalDFar+1.0-(2.0*texture2D(texUnit3,coord).x-1.0)*(focalDFar-1.0)); }
:92-97  vec2 ssaoRand(coord) = fract(sin(dot(coord,vec2(12.9898,78.233)))*43758.5453)*0.007
:99-102 float ssaoDepth(coord) = (2.0*0.1)/(ssaoNearFar.y+ssaoNearFar.x
          -texture2D(texUnit3,coord).x*(ssaoNearFar.y-ssaoNearFar.x))
:104-108 float ssaoCompareDepths(d1,d2) =
          min(ssaoCap,max(0,d1-d2-ssaoDepthTolerance)*ssaoMultiplier)
          * sqrt(clamp(1-(d1-d2)/(ssaoRange/(ssaoNearFar.y-ssaoNearFar.x)),0,1))
:110-133 float ssao(): depth=ssaoDepth(TexCoord3.st); aspect=viewPort.x/viewPort.y;
          noise=ssaoRand(...); w=(1/viewPort.x)/clamp(depth,0.05,1)+noise.x*(1-noise.x);
          h=(1/viewPort.y)/clamp(depth,0.05,1)+noise.y*(1-noise.y);
          for i=-RINGS..RINGS-1, j=-SAMPLES..SAMPLES-1:
            step=PI*2/float(SAMPLES*i); pw=cos(j*step)*i; ph=sin(j*step)*i*aspect;
            d=ssaoDepth(TexCoord3.st+vec2(pw*w,ph*h)); ao+=ssaoCompareDepths(depth,d);
          ao/=s; ao=1-ao
```

Tuned values are **not** in the shader: `posteffects.lib:2-61` gives default preset
`DOFEnable=False :29`, `FocalLength=128 :30`, `FocalDNear=256 :31`, `FocalDFar=256 :32`,
`SSAOEnable=False :33`, `SSAO* :34-44`, `TMBlurOpacity=0.0390625 :20`, `TMHDRIntencity=1.5 :21`,
`ContrastContrast=0.95 :12`, vignette 0.9/1.9/1 `:17-19`, `GammaEnabled=False :58`.
`posteffects.shaders:51-52` names `tonedofcontgammassaofxaa.frag` as the active stage pair.

### 4.5 `water\` — 6 files

#### `water.dev.vert` (928 B) — **shipped vertex stage**

| Parameter | line | Semantics |
|---|---|---|
| `uniform vec4 eyePosition` | `:1` | eye position for `eyeVector` |
| `uniform int hmapW`, `hmapH` | `:2-3` | height-map dimensions (engine-bound, UNVERIFIED) |
| `uniform mat4 cameraModel` | `:6` | shadow camera matrix |
| `varying vec3 eyeVector`, `lightVector` | `:8-9` | forwarded to fragment |
| `varying float fogFragCoord` | `:10` | view-space fog depth |

Body: `pos=gl_Vertex :14`; projected texcoord `:15`; **height UV**
`TexCoord[1].xy = MultiTexCoord0.xy / vec2(hmapW,hmapH) - 0.5 :16-17`;
`TexCoord[1].z = pos.y` = **water level** `:18`; shadow
`TexCoord[3]=TextureMatrix[3]*cameraModel*ModelView*pos :20`;
`eyeVector=pos.xyz-eyePosition.xyz :21`;
`lightVector=vec3(LightSource[0].position.x/4, .z/2, .y/1) :22`;
fog `abs((ModelView*pos).z)` (ATI) else `length(ModelView*pos) :23-27`;
`gl_Position=ftransform() :29`. **No vertex displacement** — flat plane.

#### `water.dev.frag` (8928 B, 262 lines) — **shipped fragment stage**

Uniforms: `time :1`, `texScaleS :2`, `texScaleT :3`, `sampler2D waveMap :5`,
`sampler2D reflectionMap :6`, `float hdrMultiplier :14`, `sampler2D hmapTex :18`,
`hmapMin :19`, `hmapMax :20`, `int hmapW :21`, `int fogEnabled :23`, `int shadowed :25`,
`sampler2DShadow shadowMap :26`, `int shadowSize :27`, `vec4 shadowColor :28`,
varyings `eyeVector/lightVector/fogFragCoord :30-32`.
**Commented-out uniforms**: `deepColor :8`, `shallowColor :9`, `reflectionAmount :10`,
`waterAmount :11`, `fresnelPower :12`, `fresnelBias :13`, `distFactor :15`, `bumpFactor :16`
— they are present in `water.lib` but **not wired** in the shipped fragment.

Constants: `coast2water_fadedepth=0.57 :37`, `large_waveheight=0.50 :38`,
`large_wavesize=2 :39`, `small_waveheight=0.5 :40`, `small_wavesize=0.5 :41`,
`water_softlight_fact=170 :42`, `water_glossylight_fact=120 :43`, `particle_amount=30 :44`,
`watercolor=(0.1,0.24,0.24) :45`, `watercolor2=(0,0.025,0.05) :46`,
`water_specularcolor=(0.4,0.4,0.4) :47`, `mat2 m=(0.72,-1.60,1.60,0.72) :83`.

Helper semantics: `hash :51-54`; 2-D value noise `:57-63`; `noise(p)=texture2D(waveMap,p/256).x :65-68`;
`height_map(p)=hmapMin+v.w*(hmapMax-hmapMin) :70-75`; `terrain_map(p)=(0.175,0.1375,0.1)+texture(waveMap,p*8).rgb*0.25 :77-81`;
`water_map` (FBM with 9 octaves, rotation matrix `m`, shifts 0.32t/0.24t and 0.38t/−0.26t) `:85-104`;
`nautic` (3 octaves, `pow(1-f,5)`) `:106-117`; `particles` (`p*=200`, `pow(f*0.35,7)*30`) `:119-127`;
`test_shadow` (3-tap PCF, `of=1/shadowSize`, `sh += shadowColor.x*0.7*(1-sh)`) `:129-143`;
`CalcTerrain` (4 height taps at ±0.01, `norm=normalize(vec3(h3-h4,h1-h2,1))`,
`col*=grad+pow(grad,8)`, `col=mix(col*0.25,col,terrainshade)`) `:145-160`.

Main step order (`:162-235`): `WATER_LEVEL = TexCoord[1].z :167`;
`deepwater_fadedepth=0.5+0.57=1.07 :168`;
`height=height_map(uv) :170`;
`waveheight=clamp(WATER_LEVEL*3-1.5,0,1) :174`;
`level=WATER_LEVEL+0.2*water_map(uv*15+t*0.1,waveheight) :175`;
**land discard** `if(height>level) { fragColor=vec4(0); return; } :176-183`;
4-tap finite-difference water normal `normalize(vec3(h3-h4,h1-h2,0.15)) :186-192`;
`wavejitter=normwater.xy*texScaleT*(level-height); uv+=wavejitter :193-194`;
`CalcTerrain :196`;
`coastfade=(level-height)/0.57`, `coastfade2=(level-height)/1.07 :198-199`;
luma weights `0.2126/0.7152/0.0722 :200`;
`watercolor=mix(watercolor*intensity,watercolor2,smoothstep(0,1,coastfade2)) :201`;
**projected reflection** `refuv=TexCoord[0].xyw; refuv.xy-=wavejitter*refuv.z;
refcol=texture2DProj(reflectionMap,refuv); refcol.rgb*=(R+G+B)*hdrMultiplier;
watercolor+=refcol.rgb :207-213` (Fresnel block `:203-206` commented out);
specular `grad=dot(normwater,rd)`, `pow(grad,170)`, `pow(grad,120)`,
`specular1=smoothstep(0,1,pow(gradpos,5))`,
`watercolor*=2.2+watershade :215-226`;
foam `watershade*coastfade*(1-coastfade2)*((0.5,0.6,0.7)*nautic(uv) + white*particles(uv)) :227`;
`rescolor=mix(rescolor,watercolor,coastfade) :229`; **`resalpha=coastfade2 :230`**;
`fragColor=vec4(rescolor,resalpha) :232`.

Fog `:237-253`: same LINEAR/EXP/EXP2 modes with `1.442695`; applied at `:260`.

#### Other water files

| File | Bytes | Parameters / semantics |
|---|---:|---|
| `water.frag` | 8284 | debug variant: `time :1` (`iglobaltime=time*3 :3`), `waveMap :5`, `reflectionMap :6`, `hmapTex :8`, `hmapMin/Max :9-10`; different constants `coast2water_fadedepth=0.10 :21`, `small_waveheight=0.6 :24`, `softlight=15 :26`, `particle_amount=70 :28`, `watercolor=(0.43,0.60,0.66) :29`, `watercolor2=(0.06,0.07,0.11) :30`, specular `(1.3,1.3,0.9) :31`; hard-coded `WATER_LEVEL=1.5 :182`; ray-march shadow `:135-159`; no fog sampler path |
| `water.frag.bak` | 1844 | legacy: `deepColor/shallowColor/reflectionAmount/waterAmount/fresnelPower/fresnelBias/hdrMultiplier/distFactor/bumpFactor/fogEnabled :4-13`; Fresnel `facing=1+eyeVector.y*(distFactor/length(eyeVector))*(0.1-t.y*bumpFactor) :25-28`; reflected `texture2DProj :35`; `gl_FragColor=waterColor+reflecColor :44`, alpha=`alphaDepth :45`; fog `:47-57` |
| `water.vert` | 1364 | debug vertex: `eyePosition :1`, `time :2`, `texScaleS/T :3-4`, `hmapW/H/W2/H2 :6-9`; scrolling texcoords `:21-26`, `alphaDepth=gl_Color.r :28`, `eyeVector=lightVector :33`, fog `:35-39` |
| `water.vert.bak` | 1699 | legacy vertex-wave: `waveFreq/waveAmp/waveDir0/waveDir1 :3-8`; `struct Wave :16-21`; `NWAVES 2 :25`; sine sum with derivatives `:46-54`; `gl_Position=ModelViewProjection*P :61` |

`water.lib` (outside this directory, read for context) binds shipped pair `water.dev.vert/.frag`,
`HDRMultiplier=1 :25`, `TexScaleS=0.1 :32`, `TexScaleT=0.01 :33`, `DiffuseWaves0 :44`,
`HeightMapEnable=True :60`, `ShadowMapEnable=True :61` (`water.lib` lines as cited by V784 `:33`).

---

## 5. Projection math pseudocode

### 5.1 Matrix chain (all labels explicit)

```
OBSERVED inputs:
  focal f = 400                          camera.cfg:44-45; default.cameras:17,47
  tilt theta = 32 deg (angleZ = -(-32))   camera.cfg:32-35; onmousewheel.inc:43-47 (commented)
  H (height) in [20,58]                   camera.cfg:6-10
  bookmark (H, back) = (49, 78.42125)     default.cameras:6-7,36-37
  yaw: DirX=0, DirZ=-1, UpY=1             default.cameras:11-16
  renderer projection switch default 0 = glFrustum (G31:31; port audit ev_030dff8c…)
  sensor / FOV / near / far: UNVERIFIED (no key in data/**)

DERIVED camera frame (ground focus T = (Tx, 0, Tz)):
  B = H / tan(theta)          # back-offset; numeric anchor: 49/tan(32)=78.41639
                              # vs stored 78.42125 (0.006 % apart)
  C = T + (0, H, B)           # camera eye; Z+ is "behind" the focus
  fwd = (0, -sin(theta), -cos(theta))         # from C to T
  right = (1, 0, 0)
  up   = (0,  cos(theta), -sin(theta))        # = right × fwd
  cameraMVM / shadow: TexCoord[3] = TextureMatrix[3] * cameraMVM * (ModelView*vertex)
                                                  hf.pvl.sm.vert:36; water.dev.vert:20
  gl_Position = ftransform() = Projection*ModelView*vertex   hf.pvl.sm.vert:49
```

### 5.2 Ground point → eye coordinates → screen (`derived`, twice checked)

```
Input ground P=(X, 0, Z); d = P - C
  x_e = d·right = X - Tx
  y_e = d·up    = -(Z - Tz) * sin(theta)          # zero at the focus
  s   = d·fwd   = H/sin(theta) - (Z - Tz)*cos(theta)   # >0 in front

Let f_px = focal length in pixels, principal point (W/2, Hpx/2).
  f_px = (Hpx/2) / tan(FOV_v/2) ; FOV_v = 2*atan(sensor_h/(2*f))  [sensor UNVERIFIED]
  u_px = W/2   + f_px * x_e / s
  v_px = Hpx/2 - f_px * y_e / s

Sanity (H=49, theta=32, f_px=1000):
  P=T              -> (u,v)=(W/2,Hpx/2)                 focus is screen centre
  Z=Tz+10 (nearer) -> y_e=-5.299, s=84.0  -> v=Hpx/2+63  nearer draws LOWER
  Z=Tz-10 (farther)-> y_e=+5.299, s=101.0 -> v=Hpx/2-52  farther draws HIGHER
```

This matches the observed donor geometry: eye-plane texgen uses `dot(realpos, EyePlaneS/T)`
(`hf.pvl.sm.vert:30-32`), i.e. perspective view-space projection, not a 2D canvas transform.

### 5.3 Screen pixel → ground Y=0 (`derived` inverse; closed form)

```
a = (u_px - W/2) / f_px                  # x_e/s
b = -(v_px - Hpx/2) / f_px               # y_e/s

  Z - Tz = -b*s/sin(theta)
  s      = H / (sin(theta) - b*cos(theta))       # denominator 0 at horizon
  X      = Tx + a*s
  Z      = Tz - b*s/sin(theta)

Horizon row: b = tan(theta)  =>  v_h = Hpx/2 - f_px*tan(theta)
Out-of-range (b >= tan(theta), or ray behind camera): no finite ground hit (INF).
```

Donor names this concept `ScreenToWorldRayCast(cx,cy,mx,my,mz)` at
`onmousewheel.inc:315` (**commented**) and `onresize.inc:66-69` (**commented**) — the function
name is observed, its body is engine-side/UNVERIFIED. The closed form above is the analytic
equivalent for a flat ground under the derived frame; it is not a recovered donor function.

### 5.4 Zoom / dolly (donor-authored text; `derived` from commented source)

```
minHeight = SphereLengthMin = 20     camera.cfg:10
maxHeight = SphereLength   = 58     camera.cfg:9
oldHeight = height                   onmousewheel.inc:39 (commented)
height = Clamp(height + deltaHeight, minHeight, maxHeight)   :40-41
angleZ = -Lerp(-32,-32, Clamp((height-minHeight)/(maxHeight-minHeight),0,1)) = +32   :43-47
dz = 0.1; VectorRotateX(dx,dy,dz,angleZ)    :49-52
dstZ = Tz + ArcTan(-angleZ)*oldHeight;  offZ = ArcTan(angleZ)*height    :56,:60
newX = dstX+offX+dx; newY = dstZ+offZ+dz    :66-67
wheelDelta = -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2    :296
wheelspeed default 0.5 -> delta = -(Delta/60) -> 2 m per standard Delta=120 notch
                                                (verified: -(120/60)*(0.5*0.5+0.25)*2 = -2.0)
SetMainCameraMoveToTargetXZ(newx,newy) after clearing elastic target  :298-303
```

**Key caveat:** every line of `onmousewheel.inc` from `:4` to `:339` is prefixed `[*] = ;`,
i.e. **commented-out script text** in the shipped file. It is donor-authored and self-consistent
with the active `control.script` helper, but its runtime activity is **UNVERIFIED** (§8.1).

### 5.5 Minimap jump — ACTIVE donor helper (`observed`, `control.script:574-613`)

```
angleZ = -Lerp(minHeightMaxAngle, maxHeightMaxAngle,
               Clamp((height-minHeight)/(maxHeight-minHeight),0,1))   :595
dx = cx - tx;  dy;  dz = 0.1;  VectorRotateX(dx,dy,dz,angleZ)         :596-599
offZ = ArcTan(angleZ)*height                                           :602
angleX = VectorAngle(0,0,1, dx,0,dz); if dx<0 then angleX := -angleX   :605-607
VectorRotateY(offX, tmp, offZ, angleX)                                 :609
newX = dstX + offX + dx;  newZ = dstZ + offZ + dz                      :611-612
```
This is the body DEEPDEC-01 E26 called "absent"; see correction §8.2. `ArcTan()` VM body and
degrees-vs-radians remain **UNVERIFIED**; only the numeric `cot(32°)` agreement is `derived`.

### 5.6 Pan (donor-authored, commented text)

```
keySpeed   = keyscrollspeed*4    = 2.0 (default 0.5)   oncamera.inc:10
mouseSpeed = mousescrollspeed*4  = 2.0                 oncamera.inc:11
SetCameraElasticMoveFactor(speed)                       oncamera.inc:29
absolute directions summed, SetCameraElasticMoveDirection(fcx,fcy,fcz)  :60-72
middle drag: deltaX=((prevX-curX)/60)*(0.5+middlemousescrollspeed)
             deltaY=((prevY-curY)/45)*(0.5+middlemousescrollspeed)
             dombtncameracontrol.inc:19-20; additive to target+camera :29-32
edge bands cMargin=8, cCornerMargin=24, tags 20..27    cameracontrol.inc:12-21,27-35
profile defaults 0.5, clamped [0,1]                    profile.script:17-20,513-516
```

### 5.7 Port implementation (read-only comparison)

`variant3d/scripts/camera3d.gd:152-155` sets `PROJECTION_PERSPECTIVE`,
`fov = 17.27`, `near = 0.1`, `far = 4096` — all port assumptions.
`:247-252` computes `base = _target - map_half`, `back = h*cos(pitch)/(-sin(pitch))`,
`global_position = base + (0,h,back)`, `look_at(base, UP)`.
`:266-275` implements `screen_to_world` as `project_ray_origin/normal ∩ Y=0`;
`:322-331` the same at an arbitrary height; `:259-260` uses `unproject_position` for
`world_to_px`. These are Godot equivalents of §5.2/§5.3 **provided** the FOV is calibrated.

---

## 6. Key constants table

| Constant | Value | Status | Source (`path:line`) | Note |
|---|---:|---|---|---|
| tilt `theta` | 32° (stored −32) | observed | `camera.cfg:32-35`; `onresize.inc:82,102,108` | all four slots identical |
| back-offset anchor | 78.42125 at h=49 | observed | `default.cameras:7,37` | ratio 1.60043 ≈ cot32 (derived) |
| rotated offset | (0, 0.05298996, 0.08480835) | observed | `default.cameras:9-10,39-40` | ≈ (0, 0.1 sin32, 0.1 cos32) |
| height/dolly min | 20 | observed | `camera.cfg:7,10` | wheel uses **Length** pair |
| height/dolly max | 58 | observed | `camera.cfg:6,9` | |
| focal min = max | 400 | observed | `camera.cfg:44-45`; `default.cameras:17,47` | |
| focal screenshot | 95 | observed | `camerascreenshot.cfg:46-47` | debug 86..100 `:42-43` |
| DOV | 1200 | observed | `default.cameras:18,48`; `docreate.inc:86` (commented) | |
| near / far planes | **UNVERIFIED** | — | absent from `data/**` | port uses 0.1 / 4096 |
| sensor / FOV | **UNVERIFIED** | — | absent from `data/**` | see §8.3 |
| scene scale | `(viewheight/2400)*4` if mode<5 else `(viewwidth/3840)*2.5` | observed (commented) | `onresize.inc:111-114` | |
| wheel factor | `-(Δ/60)*(wheelspeed*0.5+0.25)*2` | observed (commented) | `onmousewheel.inc:296` | 2 m / 120Δ at 0.5 |
| key/mouse pan speed | `profile*4` = 2.0 | observed (commented) | `oncamera.inc:10-11`; `profile.script:17-18` | zoom-independent |
| middle drag divisors | 60 / 45 | observed (commented) | `dombtncameracontrol.inc:19-20` | |
| edge bands | 8 / 24 | observed (commented) | `cameracontrol.inc:20-21` | |
| shadow PCF `of` | 1/512 = 0.001953125 | observed | `hf.pvl.smx3.frag:23`, `smx9:22`; `dec*:19` | `def*`/`ppl*`/`env*`/`rim*` use `1/shadowSize` |
| shadow compare threshold | 0.999 | observed | `hf.pvl.smx3.frag:26-28` | |
| fog exponential constant | 1.442695 | observed | `hf.pvl.smx3.frag:42,45`; all lit fragments | = log2(e) |
| vertex colour gain | 2.5 | observed | `def.pvl.sm.vert:1,25`; `pvl.vert:1,24`; `ppl.sm.id1.vert:1,26` | NOT in heightfield shader |
| tree luminance factor | 0.5, floor vec3(0.5) | observed | `tree.pvl.id6.vert:2,35-38`; `tree.ppl.id6.frag:1,26-29` | |
| rim edge constants | 0.1 / 4.0 / 0.2 | observed | `rim.smx3.id2.frag:8-11` | |
| face mask texgen scale | 0.125 | observed | V786 D17 `reftile.mat:124-126,150-152` | external to `data\shaders` |
| water fade depths | 0.57 / 1.07 | observed | `water.dev.frag:37`,`:168` | |
| water exponents | 170 / 120 / 30 | observed | `water.dev.frag:42-44` | |
| water colours | (0.1,0.24,0.24), (0,0.025,0.05), (0.4,0.4,0.4) | observed | `water.dev.frag:45-47` | |
| water tex scales | 0.1 / 0.01 | observed | `water.lib:32-33` | |
| post FOV/depth | focal=128, near=256, far=256, DOF/SSAO disabled | observed | `posteffects.lib:29-33` | note post `FocalLength` ≠ camera focal 400 |
| FXAA constants | 1/64, 8.0, 1/128 | observed | `tonedoffxaa.frag:30,52,54` | |
| SSAO constants | PI 3.14159265, SAMPLES 3, RINGS 3 | observed | `tonedofcontgammassaofxaa.frag:1-3` | |

---

## 7. Shader semantics synthesis (why terrain/water look the way they do)

1. **Terrain (`hf*`) is per-vertex Blinn–Phong + per-fragment albedo/lighting combine, not a
   flat texture.** `color.rgb = albedo*(ambient+diffuse)+specular` (`hf.pvl.smx3.frag:17`) with
   normals from `gl_NormalMatrix*gl_Normal` (`:15` of the vertex stage), eye-plane projected UVs
   (`:30-32`), 3- or 9-tap PCF (`:23-30` / `:22-35`) and view-depth fog (`:34-46`). A flat
   per-cell quad with a constant up-normal cannot reproduce this — matches G31 §3 findings.
2. **Terrain alpha is a separate mask sampler** (`hf.pvl.smx3.frag:14`), not the albedo's alpha.
3. **Face art uses eye-linear texgen with scale 0.125** (`reftile.mat` external; V786 D17), and
   the 25° `AngleX/AngleZ` metadata (`tiles.lib:119-136`) has an **UNVERIFIED** engine matrix
   path — it is not simply a UV rotation.
4. **Water is a height-aware fragment effect on a flat vertex plane**: land discard, 4-tap
   finite-difference normals, projected reflection with jitter, procedural nautic/particle foam,
   beach fade to alpha 0 at waterline → 1 at 1.07 m (`water.dev.frag:167-232`). Shadow and
   reflection samplers are engine-bound (UNVERIFIED), but the equations are readable.
5. **Fog is view-space depth** (`length(realpos)` / `abs(realpos.z)`) with LINEAR/EXP/EXP2, never
   a screen-space baked image.
6. **Transparency is per-family**: lit generic `alpha=tex0.a*diffuse.a`; units/buildings ignore
   texture alpha (`diffuse.a` only); terrain uses separate mask; FX31 uses a custom additive
   formula; tone stages force alpha 1; water outputs `coastfade2`.
7. **Post-processing is a real depth-aware multi-pass chain** (HDR+bloom, tone, contrast/vignette,
   gamma LUT, DOF, SSAO, FXAA), with default preset disabling DOF/SSAO/gamma but enabling HDR and
   contrast (`posteffects.lib:6,29,33,55,58`).

---

## 8. Corrections to prior docs

1. **All camera `.inc` control scripts are commented-out source.** `onmousewheel.inc:4-339`,
   `oncamera.inc:4-76`, `cameracontrol.inc:4-35`, `dombtncameracontrol.inc:4-59`,
   `onresize.inc:4-126`, `docreate.inc:4-...` are prefixed `[*] = ;` in the shipped donor files.
   DEEPDEC-01 §3 labels the wheel/pan formulas "PROVEN"; the *text* is observed, but **runtime
   activity is UNVERIFIED**. The formulas remain the best donor-authored evidence and agree with
   the active `control.script` helper; they must not be called runtime-proven.
2. **`_control_GetMoveCameraToPositionOffset` body is present and active** at
   `data\scripts\lib\control.script:574-613` (no `[*] = ;` prefix), fully reproducing the
   offset math. DEEPDEC-01 E26/E14 §3.4 says the helper "body is absent from all read donor text
   and from the binary" — **superseded** by DEEPDEC-08 E3 (`:62`, `:107`) and this fresh read.
3. **FOV/sensor arithmetic in G31/V711 is numerically wrong.** G31 `:227,262-263` and V711
   `:41,84-85` call 2.90° the "36 mm sensor" result and 17.27° the "216 mm display sensor"
   result. With `f=400`: 36 mm → **5.153°**, 216 mm → **30.219°**; 2.90° would require a
   **20.25 mm** sensor and 17.27° a **121.49 mm** sensor (checked twice in Python).
   `RENDER_ARCH_CAMERA.md:162-167` already gives the correct 5.2° for 36 mm. Both port FOV
   values remain **assumptions**, not donor literals — the arithmetic that motivated them is
   inconsistent.
4. **`default.cameras` is not a normal absolute-position bookmark.** `PosY/PosZ ≈
   (0.1 sin32, 0.1 cos32)` and `TargetZ/TargetY ≈ cot32` (§3.4) show it encodes offsets derived
   from the same `dz=0.1; VectorRotateX` chain. Saying it "gives camera position
   (0,0.05299,0.08481)" (RENDER_ARCH_CAMERA `:81-84`) is a misreading of the schema.
5. **109 is the shader FILE count, not the program count.** G31 `:34` and
   RENDER_ARCH_SYNTHESIS `:19` say "109 GLSL programs". `shaders.lib` defines 7 families × 2
   profiles plus per-profile Custom subrecords; `shaders.ref` adds 6 overrides. Actual file
   count 109 (verified), with 6 exact duplicate pairs and 20 bone variants of 2 templates.
6. **Terrain light energy/mask details**: V786 D13 `:59` states `gl_Color` multiplies diffuse
   never raw albedo — confirmed (`hf.pvl.sm.vert:21-22`, `hf.pvl.smx3.frag:17`). But `hf` has
   `vertexColor=true` (`shaders.lib:27`) while `glColorPointer` has 0 references (DEEPDEC-02 §3.1),
   so the effective multiplier is engine-supplied/UNVERIFIED, not proven to be 1.0.

---

## 9. Port implications (read-only; what our variant3d shaders lack)

### 9.1 Terrain (`variant3d/shaders/terrain_tileindex.gdshader`, 376 lines)

Present: `render_mode blend_mix, unshaded, cull_disabled :37`; donor tile-index representation
(`UV2.x`), atlas samplers, eye-plane uniforms, packed Blinn–Phong, both PCF tap sets and fog
modes (V786 §1). **Missing / neutralised in practice:**

| Donor behaviour | Donor evidence | Current port state | Consequence |
|---|---|---|---|
| 3-/9-tap PCF actually active | `hf.pvl.smx3.frag:23-30`, `smx9:22-35` | `shadow_enabled = 0.0`, neutral `shadow_map`, `shadow_matrix` identity (`:151-158`) | no self-shadow; terrain reads flat |
| view-depth fog | `hf.pvl.smx3.frag:34-46`, `1.442695` | `fog_mode=0`, `fog_density/end/scale=0` (`:169-177`) | no atmospheric depth cue |
| directional light vector | `hf.pvl.sm.vert:13` `gl_LightSource[0].position` | `light_position_eye = vec3(0)` (`:119`) | `l` undefined/zero unless A3 binds it |
| real eye-plane values | `hf.pvl.sm.vert:30-32` | identity/approx `:103-105` | UV projection not donor-like |
| face 25° tilt matrix | `tiles.lib:119-136`, V786 D18 | "no 25° rotation applied" (V786 §2.3) | cliffs lack donor striation angle |
| multi-pass `bmTransparency` | V786 D19 | one `blend_mix` pass | alpha/mask fidelity limited |
| sub-atlas `tsDouble/ttExtended` | V786 §2.7 | whole-preset-per-cell atlas | donor UV seams absent |

**Selection-rectangle coupling:** `world_to_px()` (`camera3d.gd:258-260`) projects Y=0 ground
points through a camera whose `fov = 17.27` is an unverified assumption (§8.3). Any FOV error
scales the entire rectangle linearly. `screen_to_world()` (`:266-275`) ignores terrain height;
`_screen_to_surface()` (`:339+`) does iterative height re-hits, but the selection rectangle path
must use it (or a depth-aware equivalent) or the rectangle will slide over sloping ground. Donor
uses a real `ScreenToWorldRayCast` (`onresize.inc:66-69`) and height-aware camera offsets
(`control.script:595-612`).

### 9.2 Water (`water3d.gdshader` 235 lines vs donor 262-line fragment)

Ported verbatim: wave noise, WATER_LEVEL/waveheight/level, land discard, 4-tap normals/jitter,
coastfades, colour mix, specular exponents 170/120, foam, composite alpha, EXP/EXP2 fog.
**Missing:** `CalcTerrain` 4 height taps + `grad+pow(grad,8)` + 3-tap shadow
(`water.dev.frag:145-160,196`); LINEAR fog (`:242-243`); real projected reflection (port uses
`SCREEN_UV`, `reflection_enabled=0` by default); `watershade` always 1 (donor unshadowed branch,
`:129-143`). The 2D `water_overlay.gdshader` additionally carries port-art constants
(`SHALLOW_LIN`, `DEEP_BED_SUB`, `WATERSHADE=0`, `BODY_SWELL_AMP=0`, `FOAM_GAIN=0.15`, `:77-95`).

### 9.3 No post chain at all

No donor-equivalent HDR/bloom (`tone.frag:20-24`), 8-tap gaussian (`gauss.frag:5-13`),
contrast/vignette/gamma LUT (`tonecontgamma.frag:48-93`), DOF (`tonedof.frag:19-40`),
SSAO (`tonedofcontgammassaofxaa.frag:85-133`) or FXAA (`:139-...`) exists in `variant3d`.
The donor default enables HDR + contrast and disables DOF/SSAO/gamma (`posteffects.lib:6,29,33,55,58`).

### 9.4 What is correctly excluded

`VCOLOR_FACTOR 2.5` belongs to Default/PVL/PPL, **not** the heightfield (`hf.pvl.sm.vert` has no
define) — V786 §2.10 is right to exclude it from terrain. Flat-white `b.frag` is a caster pass,
not a visible material. The commented `fx.tbn.id30` registry entry is inactive.

---

## 10. Open questions

1. Exact `ArcTan()` VM semantics (degrees vs radians, whether it is cotangent) — no donor script
   defines it; numeric `cot(32°)` agreement is corroboration only.
2. Exact `VectorRotateX/Y` sign/axis conventions — only inferable from
   `default.cameras:9-10` offset values.
3. Sensor width / absolute FOV / near / far planes for `f=400` — absent from `data/**`; binary
   projection code not re-reviewed here.
4. Whether the commented `.inc` camera scripts are dead code in the shipped binary, or were
   inlined/recompiled into it (activity UNVERIFIED).
5. Where `gl_EyePlaneS/T[0]`, `TextureMatrix[0]/[3]`, `cameraMVM`, `gl_Fog.*`, `shadowColor`,
   `hmapTex`, `reflectionMap` and `postProc[6]` are bound — all engine-side.
6. Which shader profile is selected at runtime (SM20 `smx3` vs SM30 `smx9`) and whether
   `HeightField` uses `texGen=true` at runtime.
7. How the 25° face-tile tilt and `bmTransparency` multi-pass blending reach the GPU.
8. Whether donor selection uses terrain-surface hits or the flat Y=0 plane for the marquee
   rectangle (the ray API name is observed, its body is not).
9. Why `posteffects.lib` `FocalLength=128` differs from camera `FocalLength=400` — separate
   namespaces (DOF focal distance vs lens) is the likely reading, UNVERIFIED.

---

## 11. Evidence index

All paths below are under `C:\Games\Cossacks 3\` unless marked `port:`.

- `data\cameras\camera.cfg:1-66` — 49-key main RTS profile (§3.1).
- `data\cameras\cameradebug.cfg:1-64` — debug profile (§3.2).
- `data\cameras\camerascreenshot.cfg:1-70` — screenshot profile (§3.3).
- `data\cameras\default.cameras:1-97` — 3 camera bookmarks (§3.4).
- `data\scripts\lib\control.script:574-613` — active minimap offset helper (§5.5).
- `data\gui\common.inc\onmousewheel.inc:4-80,82-107,296-303,315,322-338` — commented zoom/FOV text.
- `data\gui\menu.inc\{oncamera,cameracontrol,dombtncameracontrol,onresize,docreate}.inc` — commented pan/edge/resize/setup text.
- `data\scripts\lib\profile.script:17-20,513-516` — 0.5 speed defaults/clamps.
- `data\shaders\shaders.lib:2-14,15-913,914-1813` — register + 7×2 program families.
- `data\shaders\shaders.ref:1-180` — 6 override records.
- `data\shaders\obj\hf.pvl.sm.vert:1-50`, `hf.pvl.smx3.frag:1-51`, `hf.pvl.smx9.frag:1-56`.
- `data\shaders\obj\{pvl,def,ppl,gr,dec,rim,env,tbn,tree,build,fx,b*,unit*,test}.*` — §4.3 family ledgers.
- `data\shaders\tone\*` — §4.4 parameter ledger; `tonedofcontgammassaofxaa.frag:85-133` SSAO.
- `data\posteffects\posteffects.lib:2-61`, `posteffects.shaders:51-52` — tuned post defaults.
- `data\shaders\water\water.dev.vert:1-30`, `water.dev.frag:1-262`, `water.frag*`, `water.vert*`.
- `data\water\water.lib:25,32-33,44,60-61` — water descriptor (prior doc V784 `:33`).
- `port: variant3d/scripts/camera3d.gd:58-69,152-155,234-275,322-338,590-661`.
- `port: variant3d/shaders/terrain_tileindex.gdshader:37-237`, `water3d.gdshader:21-62`, `water_overlay.gdshader:1-95`.
- Prior evidence ids relied on (not re-minted): DEEPDEC-01 E1–E26; G31 claim table; V784 §3; V786 D01–D20; RENDER_ARCH_SHADERS E1–E29.

---

## 12. Summary

- 4 camera files (all ASCII/CRLF) and 109 shader files (272,517 B, all ASCII/CRLF) were fully
  enumerated; every camera key is tabled with value and `path:line`; every shader family's
  uniforms, constants, samplers, lighting/fog/alpha behaviour is tabled with `path:line`.
- The main view is **perspective**, focal 400, tilt −32°, dolly 20–58 m, yaw 0 toward −Z. The
  bookmark `(h=49, back=78.42125)` corroborates `back = h·cot(32°)` to 0.006 %. Closed-form
  ground↔screen formulas are derived in §5.2–5.3 and sanity-checked.
- Three material corrections: the camera `.inc` scripts are **commented** source (runtime
  activity UNVERIFIED); the minimap offset helper **is** active at `control.script:574-613`;
  and the 36 mm/216 mm → 2.90°/17.27° FOV arithmetic in prior reports is numerically wrong.
- Port gaps are therefore not just constants: terrain has no active shadow/fog/light binding,
  water omits `CalcTerrain`/LINEAR fog/real reflection, and no post chain exists. FOV remains an
  assumption, which directly affects selection-rectangle projection accuracy.

**End of report. No code, asset, config, test or git state was changed. No donor file was copied,
executed or modified.**
