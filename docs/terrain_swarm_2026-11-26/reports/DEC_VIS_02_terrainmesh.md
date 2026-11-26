---
id: DEC-VIS-02-TERRAINMESH
title: "DEC-VIS-02 — donor terrainmesh1..4 rendering, placement, material and LOD"
agent: "DEC-VIS-02 (read-only Craft Anything decompilation worker)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_GODOT_GIT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_VIS_02_terrainmesh.md
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
targets:
  - "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
  - "t_68474ddde43f — C:\\Games\\Cossacks 3\\editor.exe, PE32, 7,874,416 B, sha256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab"
rules: "Donor read-only. No donor binary executed or copied. No source/asset/config/test/shader/git change. No Godot or runner job. Exactly one repository file written: this report. No donor-parity claim."
---

# DEC-VIS-02 — `terrainmesh1..4` donor render/placement recovery

## 0. Executive answers

1. **[O] The square footprint is real rendered donor mesh geometry, not an editor/authoring grid.**
   `terrainmeshN.prop` selects `terrainmeshN.mesh`; `terrainmeshN.actor` loads
   `data/actors/env/terrainmeshN.osm`; the converted OBJs retain the broad triangulated
   base and the donor UVs. The actor inherits `AutoCentering=false`. Deleting the square
   base would therefore delete donor geometry. **[I]** The port's former pale/white
   “plinth” appearance is consistent with a material-binding failure; it is not evidence
   that the donor square was an editor aid.

2. **[O]/[D] The donor object transform is not “round Position, add stamp cell, yaw”.**
   In `sub_755f30`, each `Objects` record is transformed in this order:
   **record `Position.xz` → rotate by `π - rotangle` → multiply by `ObjectsScale` → add
   either the raw stamp centre or the pattern-size-rounded half-cell centre**. Record Y is
   zero unless `ObjectsHeightOffset` is true. Terrain height is sampled and added only
   when `ObjAutoOffset` is true and the created object's own predicate says to do so.
   Direction, Up and `Scaling * ObjectsScale` are then installed, followed by the donor's
   final `sub_7cca74(obj, rotangle)` turn call.

3. **[O] Donor relief materials are lit, two-sided alpha cut-outs.**
   `env.mat:terrainmesh1..4` inherit `refbase.mat`: `bmAlphaTest50`, `fcNoCull`,
   `moNoLighting=False`, front/back ambient `0.25`, diffuse `0.78125`, emission/specular
   zero, linear filtering with linear mipmaps, user UVs and modulate texture mode.
   `cossacks.exe` material case 3 enables alpha test and calls
   `glAlphaFunc(GL_GEQUAL, 0.5)`. This is **not** alpha blending.

4. **[O]/[I] The square blends into ground through geometry + height stamping + albedo,
   not a translucent square plane.** The relief albedos have a grass-coloured outer
   margin around the rocky centre. For `g_mnt_1`, `HeightFieldReplaceForWater=True`,
   scale/min/max/offset are zero/one as applicable, the relief grid is zero (D05/X25),
   and height smoothing is enabled; the stamp therefore makes a zero-height interior
   with a smoothed transition. The mesh base then sits in that surface while its
   grass-margin UVs continue the ground colour. Donor videos show continuous ground and
   no white square plate; those videos remain direction-only references.

5. **[O] There is no per-record RNG or random LOD choice.** The `GameObjectsStand` loop
   visits every record. With `minangle<=0 && maxangle>=90` it accepts every candidate;
   otherwise it applies map-bound tests and requires both donor normal-angle metrics to
   lie strictly between `minangle` and `maxangle`. The actor has one mesh LOD range
   `0..150`, no alternate mesh LOD/imposter, plus a separate shader/distance range
   `0..2500`. I09's current batch-level `2500` visibility rule is not that mesh LOD rule.

> **NO DONOR PARITY CLAIM.** All runtime conclusions are static donor-byte/text reads.
> No donor frame was rendered. Third-party donor videos are appearance direction only.

---

## 1. Read-first and scope

Read before analysis:

- `VISUAL_WAVE_CHARTER.md`
- `reports/D05_relief_stamp.md`
- `reports/X25_relief_silhouette_reference.md`
- `reports/X16_prop_mesh_coverage.md`
- `HANDOFF.md §9.11` — the only on-disk FIX-PROP-MAT completion summary; its fix facts are
  explicitly COORD-supplied, not independently measured.
- `reports/DONOR_VIDEO_analysis.md`
- `variant3d/scripts/terrain_donor_props.gd`
- converted `terrainmesh1..4.obj/.mtl`
- donor `data/materials/env/env.mat` and `data/materials/ref/refbase.mat`
- donor `pattern.lib`, `terrainmeshN.prop/.actor`, `refobj.actor`, `refmountain.actor`

The global active target remained `t_87f0f3c130b0`. Every native call pinned
`document:` to `t_87f0f3c130b0` or `t_68474ddde43f`; no target selection/open/close call
was made.

---

## 2. Evidence ledger

`[O]` = directly observed bytes/text; `[D]` = deterministic consequence;
`[I]` = interpretation; `[U]` = unresolved. Evidence ids resolve in the Craft Anything
session ledger.

| ID | Evidence | Establishes |
|---|---|---|
| E01 | `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237` — Ghidra pseudo-C, `FUN_00755f30`, entry `0x755f30` | Deep/Ghidra pass: full stamp function, object loop, flags and call order. |
| E02 | `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5` — 6,751 instructions, `cossacks.exe` | Raw assembly cross-check; object block `0x75b63a..0x75bddf`. |
| E03 | `ev_60bc81a6eb1fdb2e27c9a02a5839d7bf4c1c2c587a17d7611e2a4f5339e92b26`, `ev_dcf6cf07823637d4ee6cafb747aead7a2cbf28a44e83f83da2f7701e8958667f` | `StandPatternWithAngleAdv` wrapper `0x6b2b60`; call to `0x755f30` at `0x6b2bfc`, argument push order. |
| E04 | `ev_25c606330620f7e3756089658080d719200ba936631898498a80cadd73f79e30` | Parser `0x75c314`: `ObjectsScale +0x6c`, offsets `+0x74/+0x78`, object flags `+0x7c..+0x7f`, `GameObjectsStand +0x19`. |
| E05 | `ev_8134dae4e0fb2794b432bcdb0044dc7dd05917f18fae8066e18ffa8fe285aa04`, `ev_c041ddb4f6ae4f8026e8fc0a5bbdfab5816ac6a0f1358a57840ccdb987a2c4b8` | `editor.exe` stamp `sub_8c5b78`; independent 6,751-instruction copy. |
| E06 | `ev_1c2e6d19cef5d1db089e7c4cae004b9812361283a54a24f75991afe2fe82b45c` | `pattern.lib:337461..337495`, `g_mnt_1` literal flags/constants. |
| E07 | `ev_257799c36393aa1a4c41e4d40b6724957fe75b2d3c32b4dad45fee796e7b3a6b`, `ev_c021fbfb576de2fd32542fae75fe68595ac8d90bd1ad3edb404dd7f3c043cb3b` | `terrainmesh1.prop` → actor/material chain; `terrainmesh1.actor` → `terrainmesh1.osm`. Equivalent N=2..4 observed on disk. |
| E08 | `ev_7c075bfc32b83a922906617e2e338cce6bea45440159a938df4a873f741a04a9` | `refbase.mat:1..109`: alpha test, no cull, lighting and texture/front/back properties. |
| E09 | `ev_73c1535835915f0d562b0a2c9e1ac79bccf96a3d1fba8fb76e99fda8bd178f30` | `env.mat:600..615`: `terrainmesh1..4` inherit `refbase.mat`, bind matching DDS. |
| E10 | `ev_25c4005b7321c93116b59965aaae051bb73b9b1c24957dd86a3595fe40424dc3`, `ev_645fe58ee44830fce5860cb28ef7d6137e480cbbb11b8e4d2cb20d4a84f84d12` | Material switch `sub_4ef810`; case 3 at `0x4ef9c1`, alpha ref `0.5`, table index 7 = 518 (`GL_GEQUAL`). |
| E11 | `ev_e09b591ce43b4427443b50ac4ffd01db429a47e712e9a4367fc6e1b5561b7803`, `ev_6ebd3fd5bc50d1ed089f11ea4450340771c5f8c6c107513cb5e09cf8af2ec68d` | `refobj.actor`: auto-centering off; mesh LOD `0..150`; shader/distance `0..2500`; no impostor. |
| E12 | `ev_98156ac68a90653b7f9d09a39fd358ff29fc855d323de5475443e4642ee11e08` | `misc.script:3384..3390`: degrees → radians, then `StandPatternWithAngle(...,0,90)`. |
| E13 | `ev_a52597a2f45f9d3b343966838d6551e3d8d2355006380d0c28a4132bafe69d4a`, `ev_78fbcaaf8b92f2ebf3e0e9a6feb65dd5f093f29fd0797db6f9da7ffcbaa14a8a` | Current I09 placement, bbox recentering, scale collapse and material binding. |
| E14 | `ev_8f583c20b215eb6a1a6fa75ee16df60437bdbbc760ac51389d8175917233f9b5`, `ev_bb5b6bf88c897c12c87515d933eb60a1663dcd8f1bd2ac9b877601421e538dcb` | Converted OBJ header/base vertices and MTL `map_Kd`; OBJ has no `usemtl`. |
| E15 | X25 §4.1/§5; `manifest.json:376..469`; direct PNG reads | 9,620 vertices / 19,162 faces; donor OSM/DDS provenance; all four 2048² RGBA albedos. |

---

## 3. Multiple-pass register

| Pass | Instrument | Result |
|---|---|---|
| P1 | Clean-room function study + pseudo-C | Located `sub_755f30`, wrapper and parser. Built-in pseudo-C was useful for control flow but unreliable for x87 operand naming and some call arguments. |
| P2 | Deep/Ghidra pseudo-C (`ev_c176…`) | Confirmed eight-argument signature and the complete object block. Ghidra exposes `param_4=maxangle`, `param_5=minangle`, `param_6=rotangle`, `param_7=standz`, `param_8=standx` after wrapper push-order resolution. |
| P3 | Raw instruction listing (`ev_a920…`) | Re-derived every placement/flag/order conclusion from instructions, not variable names. The 542-instruction object block is `0x75b63a..0x75bddf`. |
| P4 | Helper decompilation/disassembly | `0x4a2188` vector constructor; `0x4a3c7c` out-of-place Y rotation; `0x4a35d4` uniform vector scale; `0x4a36cc` four-float scale; `0x4a6634` `fsincos`; `0x4a6520` radians→degrees; `0x7cca74→0x4cb27c` final object turn. |
| P5 | Constants/xrefs | Decoded x87 π constants, `2.0/0.5/0/90/180`, angle conversion constants, alpha table entry and object-record accessors. |
| P6 | Independent `editor.exe` pass | String xref `0x8cbe20 → 0x8cb9e5` located `sub_8c5b78`. Its object block `0x8cb282..0x8cba27` has **542 instructions and zero normalized mnemonic/operand differences** from the game block. |
| P7 | Data/asset pass | `.prop → .actor → .osm`, material inheritance, pattern literals, OBJ/MTL, albedo images, LOD and auto-centering text. |
| P8 | Port comparison | Compared the recovered operation against I09 `_collect_stamp`, `_normalize_record`, `_add_to_batch`, `_bind_donor_albedo`, and `update_lod`. |

The strange final-turn pseudo-C (`FUN_004a6520` appearing adjacent to
`FUN_007cca74`) was **not** accepted from Ghidra alone. Assembly shows
`push rotangle; call 0x7cca74`; the conversion inside `0x4cb27c` is reported separately.

---

## 4. F1 — The square footprint is runtime geometry

**[O] Asset chain.**

```text
pattern.lib Objects[].BaseName = terrainmeshN
  → data/objects/env/terrainmeshN.prop
      actorproperty.LODActorName = terrainmeshN
      DefaultMeshName = terrainmeshN.mesh
      DefaultMaterialName = terrainmeshN
  → data/actors/env/terrainmeshN.actor
      ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile
        = data/actors/env/terrainmeshN.osm
  → data/materials/env/env.mat
      Material.Name = terrainmeshN
      Material.Texture.image = data/materials/env/terrainmeshN.dds
      refurl = data/materials/ref/refbase.mat
```

**[O]** `terrainmesh1.obj:4..7` contains the broad low base vertices; X25 measured all
four meshes and their base-inclusive bounds. `terrainmesh3.obj:8004..8005,8650..8656`
contains explicit triangulated base faces. The converted files preserve donor UVs and
cite the donor `.osm` in `manifest.json`.

**[O]** `refobj.actor:2..7` sets `macCenterX/Y/Z=false` and
`macUseBarycenter=false`. The donor therefore keeps the OSM origin; it does not recenter
the mesh on its bbox.

**[D]** The square is a deliberately textured ground-contact skirt. It is not a selection
rectangle, debug grid or editor-only plane. The correct FIX-PROP-MAT action is to bind the
donor albedo and material state while **keeping** the square geometry and UVs.

---

## 5. F2 — Call chain, arguments and record layout

### 5.1 Call chain

```text
DScript StandPattern / StandPatternWithAngle / StandPatternWithAngleAdv
  → native wrapper(s), including sub_6b2b60 at VA 0x6b2b60
  → sub_755f30(pattern*, player/group*, 0,
               maxangle, minangle, rotangle, standz, standx)
```

**[O]** `sub_6b2b60` pushes wrapper stack values `+0x10,+0x14,+0x18,+0x1c,+0x20`
in that order at `0x6b2be7..0x6b2bf3`, then calls `0x755f30` at `0x6b2bfc`.
The public signature recovered from the DScript table is:

```text
StandPatternWithAngleAdv(plhandle, patternname,
  standx, standz, rotangle, minangle, maxangle,
  makegr, movetopar, grname, parbase, parind)
```

The right-to-left stack push resolves the callee's first stack argument as `maxangle`.
Ghidra's `param_4..param_8` therefore map as follows:

| Ghidra | Callee stack | Meaning |
|---|---:|---|
| `param_4` | `[ebp+8]` | `maxangle` |
| `param_5` | `[ebp+0xc]` | `minangle` |
| `param_6` | `[ebp+0x10]` | `rotangle` (radians in the DScript call path) |
| `param_7` | `[ebp+0x14]` | `standz` |
| `param_8` | `[ebp+0x18]` | `standx` |

### 5.2 Parsed pattern fields used here

| Field | Offset | Default | Observed `g_mnt_1` |
|---|---:|---:|---:|
| `GameObjectsStand` | `+0x19` | true | true |
| `ObjectsScale` | `+0x6c` | 1.0 | 1 |
| `RotationAngle` | `+0x70` | 1.0 | 0; **not read by this stamp block** |
| `OffsetX` / `OffsetZ` | `+0x74` / `+0x78` | 0 | 0 / 0 |
| `ObjectsOffset` | `+0x7c` | false | false |
| `ObjectsHeightOffset` | `+0x7d` | false | false |
| `IgnoreMatrix` | `+0x7e` | false | false |
| `ObjAutoOffset` | `+0x7f` | false | false |
| `HeightFieldScale` | `+0x48` | 1.0 | 1 |

### 5.3 Object record layout [D]

The loop gets the count from `sub_75c370` (`[[pattern+8]+0xc]`) and each record from
`sub_754e88` (`sub_89df30([pattern+8], index)`). Accesses establish:

| Record offset | Use |
|---:|---|
| `+4`, `+8` | names passed to game-object creation / failure log |
| `+0xc`, `+0x10`, `+0x14` | `Position.x/y/z` |
| `+0x1c` | 16-byte Direction value copied to object `+0x48` |
| `+0x2c` | 16-byte Up value copied to object `+0x4c` |
| `+0x3c` | four floats multiplied by `ObjectsScale`, copied to object `+0x50` |

This matches the `pattern.lib` `Position/Direction/Up/Scaling` blocks; the binary record
is the loaded representation, not the 24-byte tile payload discussed in D05.

---

## 6. F3 — Exact donor placement transform

### 6.1 Donor rotation helper

`sub_4a3c7c` calls `sub_4a6634` (`fsincos`) and computes:

```c
RotateY_donor(v, a) = {
    sin(a)*v.x + cos(a)*v.z,
    v.y,
    sin(a)*v.z - cos(a)*v.x
};
```

The same math is used in-place by `sub_4a3b9c`. No degree conversion occurs in these
rotation helpers.

### 6.2 Stamp/base centre

For non-axis-aligned angles the donor first rotates `(OffsetX,0,OffsetZ)` by
`-rotangle` and adds `(standx,standz)`. Near an axis-aligned multiple of π it uses the
offsets directly. Let the resulting raw centre be `(cx,cz)`.

The pattern-size-rounded centre is then:

```c
r0 = Round((W - 1)/2 - cx);
r1 = Round((H - 1)/2 - cz);
x1 = W + r0 - 1;
z1 = H + r1 - 1;

mx = Round((x1 + r0)/2) + 0.5;
mz = Round((z1 + r1)/2) + 0.5;

dx = (x1 + r0)/2 - mx;
dz = (z1 + r1)/2 - mz;

base = RotateY_donor({dx,0,dz}, PI - rotangle) + {mx,0,mz};
```

Constants are `2.0` at VA `0x75c1a4`, `0.5` at `0x75c1a8`, and x87 π at
`0x75c198`/`0x75c1ac`.

### 6.3 Per-record pseudocode [O]/[D]

```c
if (!pattern.GameObjectsStand) skip_objects;

for (i = 0; i < object_count; ++i) {
    rec = object_record(pattern, i);

    // 0x75b66d..0x75b6ad
    p = { rec.Position.x, 0, rec.Position.z };
    p = RotateY_donor(p, PI - rotangle);
    p *= pattern.ObjectsScale;

    // 0x75b6b2..0x75b717
    if (pattern.ObjectsOffset)
        pos = { cx, 0, cz } + p;
    else
        pos = base + p;

    // 0x75b717..0x75b733
    if (pattern.ObjectsHeightOffset)
        pos.y = rec.Position.y * pattern.ObjectsScale * heightScale;

    // Optional map/angle selection, described in §8.
    if (!selected) continue;

    obj = CreateGameObject(player, rec.name1, rec.name2, pos, ...);

    if (obj) {
        // 0x75bc87..0x75bce4
        if (pattern.ObjAutoOffset && !ObjectOwnOffsetPredicate(obj)) {
            float h = BilinearWorldHeight(world, pos.x, -pos.z); // 0x810498
            pos.y += h;
            SetObjectPosition(obj, pos);
        }

        // 0x75bce4..0x75bd08
        if (pattern.ObjectsHeightOffset) {
            sub_7ca724(obj, 0);
            SetObjectPosition(obj, pos);
        }

        // 0x75bd08..0x75bddf
        if (!pattern.IgnoreMatrix) {
            SetObjectValue(obj + 0x48, rec + 0x1c);       // Direction
            SetObjectValue(obj + 0x50, (rec + 0x3c) * ObjectsScale);
            SetObjectValue(obj + 0x4c, rec + 0x2c);       // Up
            sub_7cca74(obj, rotangle);                    // final donor turn
            pos.y = ObjectMatrixY(obj);
            SetObjectPosition(obj, pos);
        }
    }
}
```

### 6.4 Final-turn unit trap

**[O]** `sub_7cca74` calls `sub_4cb27c`, which immediately passes its argument through
`sub_4a64e4`: multiply by `0.01745329238474369` (`π/180`) before rotating the object's
Direction/Up basis. The placement trigonometry, however, uses `rotangle` directly as
radians. The DScript caller explicitly computes `angleRad = angle*pi/180`.

**[D]** The donor code therefore contains a unit discontinuity between placement rotation
and final object turn. Do not silently “correct” this in a donor-derived implementation.
Record it as an observed donor quirk; validate any Godot translation with static vectors
before claiming equivalence.

---

## 7. F4 — Material, alpha, culling and lighting

### 7.1 Literal material state

`terrainmesh1..4` sections in `env.mat` contain only the material name and DDS binding;
all other state is inherited from `refbase.mat`.

| Property | Donor value |
|---|---|
| Blending | `bmAlphaTest50` |
| Alpha comparison | `GL_GEQUAL`, ref `0.5` |
| Face culling | `fcNoCull` |
| Lighting | `moNoLighting=False` |
| Ambient, front/back | `0.25,0.25,0.25` |
| Diffuse, front/back | `0.78125,0.78125,0.78125` |
| Emission / specular | `0` |
| Shininess | 16 |
| Texture mode | `tmModulate` |
| Alpha source | `tiaDefault` |
| Filters | `maLinear`, `miLinearMipmapLinear`, isotropic |
| Wrap / mapping | `twBoth`, `tmmUser` |

**[O]** `sub_4ef810` switches on material byte `[ebx+0x20]`. Case 3 starts at
`0x4ef9c1`, sets alpha-test state and pushes `0x3f000000` (`0.5`) before
`sub_88fb34`. `sub_88fb34` indexes the GL enum table at `0x8fb18c`; index 7 is 518,
`GL_GEQUAL`.

**[D]** `bmAlphaTest50` is a binary cut-out. There is no source-alpha/destination-alpha
blend equation for these relief materials. Alpha-soft appearance at distance can only
come from texture/mip/colour/geometry/lighting interactions, not an alpha-blend pass.

### 7.2 Season

`terrainmeshN.prop` sets `UseSeasonMaterial=True`, summer `terrainmeshN`, winter
`terrainmeshNw`. I09 currently has no winter relief material binding; that remains a
separate gap.

---

## 8. F5 — Ground integration, selection and LOD

### 8.1 Why the square does not read as a plate in donor references

1. **[O]** The base is triangulated geometry and carries the same donor UV/material as
   the relief; it is not a separate white card.
2. **[O]** Direct inspection of all four converted 2048² RGBA albedos shows a
   grass-coloured outer margin around the rocky centre. The square's perimeter samples
   ground-like albedo rather than a neutral plinth colour.
3. **[O]/[D]** `g_mnt_1` has `HeightFieldReplaceForWater=True`, zero height offset and a
   zero relief grid (D05/X25). D05's recovered replace branch sets the interior height to
   `grid*scale + offset = 0`. `HeightFieldSmooth=True`, radius 3, factor 4, offset 2 gives
   the ordered edge smoothing recovered by D05.
4. **[O]** `ObjAutoOffset=False` for `g_mnt_1`; the donor does not lift the mesh to a later
   terrain sample. The mesh base and stamped surface are designed to meet at the same
   zero-height datum.
5. **[O]** Donor videos show continuous grass and no white square base. Unknown build,
   map, camera and compression make this appearance direction only.

**[I]** The likely donor visual blend is therefore: zero-height stamped interior +
smoothed height boundary + grass-margin albedo + lit two-sided cut-out shading. It is not
alpha blending and not an editor grid.

### 8.2 Object selection rules

The loop visits `object_count` records in feed order; no RNG call exists in the object
block.

```c
if (minangle <= 0 && maxangle >= 90) {
    selected = true;                 // bypass per-object map/angle tests
} else {
    selected = PointInsideMap(pos.x, pos.z);
    if (selected) {
        a0 = DonorNormalAngle(triangle(x,z; x+1,z+1; x,z+1));
        a1 = DonorNormalAngle(triangle(x,z; x+1,z; x+1,z+1));
        selected = (minangle < a0 && a0 < maxangle &&
                    minangle < a1 && a1 < maxangle);
    }
}
```

The two metrics come from normalized triangle normals, donor helpers `sub_50dbf0` and
`sub_4a6520`, then the observed `if (deg > 180) deg = 180 - deg` fold. The exact
normalization inside `sub_50dbf0/sub_4a6530` is intentionally **not** promoted to a clean
slope/aspect formula: multiple helper passes showed non-obvious x87 range normalization.
The selection inequalities themselves are directly observed in Ghidra and assembly.

`misc.script:3390` calls `StandPatternWithAngle(...,0,90)`, which takes the accept-all
branch. Pattern-level mask/occupancy checks still occur outside this object loop.

### 8.3 LOD

| Donor setting | Value |
|---|---|
| `ActorList.Items[0].LODList.Items[0].DistanceMin/Max` | `0 / 150` |
| Alternate mesh LOD entries | none in `terrainmeshN.actor` |
| `Impostored` | false |
| `ShaderLODList.List[0].MinDist/MaxDist` | `0 / 2500` |
| `DistanceMax` | 2500 |
| `refmountain.actor` override | `ShaderLODList.ChildPooled=poNone` plus LOD texcoord-index metadata; no distance override |

**[D]** There is one donor mesh, not a chain of simplified relief meshes. The `150` mesh
range and `2500` shader/distance range are distinct controls. Their world-unit meaning is
not proven by text alone.

---

## 9. F6 — Comparison with current I09

| Area | Donor | Current I09 | Verdict |
|---|---|---|---|
| Base geometry | Keep OSM square/base and origin | Keeps OBJ square; recenters X/Y and zeroes Z | **Divergent origin**; donor `AutoCentering=false`. |
| Local position | Float XZ; rotate by `π-rotangle`; scale; add donor centre | `round(px/pz)` then add stamp cell | **PORT APPROXIMATION**; rotation and pre-rounding are wrong. |
| Centre | Width/height nested rounding + half-cell + offset rotation | Stamp cell + rounded record offset | **Divergent**; can shift by a half cell and ignores pattern dimensions. |
| Scale | `Scaling` vector × `ObjectsScale` | Uses only `scale.x`, uniform | Correct for current equal XYZ/scale=1 records only; general rule divergent. |
| Record Y | Zero unless `ObjectsHeightOffset`; then `Y*ObjectsScale*HeightScale` | Stored but not used in transform | Missing flag semantics. |
| Terrain snap | Only `ObjAutoOffset` path | Always `_ground_y(...)` | **Divergent**; `g_mnt_1` has `ObjAutoOffset=False`. |
| Orientation | Direction + Up + scaled Scaling + final donor turn | Yaw derived from Up, then Z-up→Y-up; no stamp turn | Partial approximation; missing Direction/full basis and final turn. |
| Material | Lit, no cull, alpha test `>=0.5`, donor DDS | Lit `StandardMaterial3D`, no cull, scissor 0.5, donor PNG | **State class aligned**; PBR/fixed-function energy mapping remains approximation. |
| Selection | Every record candidate; optional map/angle gate | Every record instantiated | Matches accept-all case; not general angle semantics. |
| LOD | Per-object mesh 0..150; separate shader 0..2500 | Whole batch visible by holder distance ≤2500 | **Not donor mesh LOD**; holder-origin distance is also wrong for a batch. |
| Winter | `terrainmeshNw` material swap | No winter relief binding | Missing. |

### 9.1 Exact recommendations to COORD/I09

1. **Keep the square base and donor UVs.** FIX-PROP-MAT should continue to mean “remove the
   untextured white appearance”, not “delete the footprint geometry”. The current script
   comment at `terrain_donor_props.gd:995..996` is correct.
2. **Replace the placement approximation with a donor-derived transform helper.** Carry
   `rotangle`, pattern W/H, `OffsetX/Z`, `ObjectsScale`, and all four object flags into the
   placement record. Do not round `Position.x/z` before rotation.
3. **Implement the donor base-centre formula** from §6.2, including nested `Round`, the
   `+0.5` half-cell and the `π-rotangle` correction. Keep the raw-centre branch for
   `ObjectsOffset=true`.
4. **Preserve the full Scaling vector.** Multiply XYZ (and the donor fourth component if
   retained) by `ObjectsScale`; do not collapse to `scale.x`.
5. **Do not bbox-recenter or zero the mesh origin in the donor-derived path.** If a
   separate port-authoring path needs recentering, keep the original pivot and label that
   path `PORT APPROXIMATION`.
6. **Make terrain sampling conditional.** `ObjAutoOffset=false` means no `_ground_y` snap.
   For `g_mnt_1`, rely on the zero-height stamped interior and smoothed boundary.
7. **Implement `ObjectsHeightOffset` and `IgnoreMatrix` exactly.** The former uses record
   Y × `ObjectsScale` × the same height-scale local used by the stamp; the latter skips
   record Direction/Up/Scaling and the final turn.
8. **Resolve the final-turn units before porting orientation.** Preserve the observed
   `π-rotangle` placement rotation and the donor's separate `rotangle → π/180` turn-helper
   conversion as distinct operations. Add static vector tests; do not infer the sign only
   from a screenshot.
9. **Keep material state in the recovered class:** albedo bound, lighting on, cull off,
   alpha scissor threshold 0.5, no alpha blend. Donor ambient `0.25`, diffuse `0.78125`,
   zero emission/specular and fixed-function front/back lighting are not automatically
   equivalent to Godot PBR defaults; label the energy mapping approximation.
10. **Keep all-record candidate iteration and add the optional angle gate.** No synthetic
    scatter or RNG. `0..90` is the accept-all sentinel, not a slope threshold that should
    discard records.
11. **Leave donor LOD disabled or implement it per instance after unit validation.** Do not
    describe the current batch-origin `2500` check as the donor's `0..150` mesh LOD.
12. **Add winter material selection separately.** `terrainmeshNw` is a material swap, not a
    new pattern or mesh.

---

## 10. Constants and address card

| Constant / anchor | Address | Value / use |
|---|---|---|
| Stamp function | `cossacks.exe 0x755f30..0x75c187` | 6,751 instructions, 234 blocks |
| Wrapper | `0x6b2b60`; stamp call `0x6b2bfc` | `StandPatternWithAngleAdv` |
| Parser | `0x75c314` | field → offset map |
| Object loop | `0x75b637..0x75bde5` | 542-instruction placement block |
| Object count / getter | `0x75c370`, `0x754e88` | list count / record access |
| π (x87 extended) | `0x75c198`, `0x75c1ac` | 3.141592653589793 |
| Half-cell constants | `0x75c1a4`, `0x75c1a8` | 2.0, 0.5 |
| Angle sentinels | `0x75c1c4/c8/cc` | 0.0, 90.0, 180.0 |
| Degrees→radians | `0x8f4be0` | 0.01745329238474369 |
| Radians→degrees | `0x8f4be4` | 57.295780181884766 |
| Rotation out / in | `0x4a3c7c`, `0x4a3b9c` | donor Y rotation formulas |
| Scale vector / 4-float | `0x4a35d4`, `0x4a36cc` | × `ObjectsScale` |
| Final turn | `0x7cca74 → 0x4cb27c → 0x4a64e4` | argument × π/180 before basis rotation |
| Material switch | `0x4ef810`; alpha case `0x4ef9c1` | `bmAlphaTest50` |
| Alpha function/table | `0x88fb34`, table `0x8fb18c` | index 7 = 518 = `GL_GEQUAL` |
| Editor stamp | `editor.exe 0x8c5b78..0x8cbdcf` | independent identical-shape copy |
| Editor object block | `0x8cb282..0x8cba27` | 542 instructions, normalized-identical |

---

## 11. UNVERIFIED register

| Id | Item | Status |
|---|---|---|
| U1 | Donor GPU appearance / parity | **[U]** no donor execution or same-camera A/B; no parity claim. |
| U2 | Exact semantic name/range of `sub_50dbf0/sub_4a6530` normal-angle output | **[U]** raw selection inequalities are proven; helper normalization is non-obvious after Ghidra + assembly + constants passes. |
| U3 | World-unit meaning of LOD `150` and `2500` | **[U]** literals and distinct controls are observed; metre interpretation is not. |
| U4 | Visual softness contribution of PNG alpha vs colour/mips | **[U]** material is alpha-test, not blend; no donor frame or pixel-alpha census was produced. |
| U5 | Winter rendering in I09 | **[U]/missing** donor material swap is observed; no port winter binding exists. |
| U6 | All non-mountain pattern flag combinations at runtime | **[U]** code paths are recovered; this pass did not audit every one of the 680 sections. |
| U7 | Godot translation of final-turn sign/unit quirk | **[U]** must be settled by static vector tests, not by a visual guess. |

---

## 12. Claim register

1. **[O]** `terrainmesh1..4` are runtime OSM actor meshes; the square base is real geometry.
2. **[O]/[D]** Donor placement is rotate → scale → centre-add, with conditional Y and
   terrain offset, followed by record matrix installation and a final turn.
3. **[O]** Donor relief material state is lit `bmAlphaTest50`, `fcNoCull`,
   `GL_GEQUAL 0.5`; it is not alpha blended.
4. **[O]/[I]** Ground integration comes from the stamped zero-height surface, smoothing,
   grass-margin albedo and lit shading, not a translucent editor plate.
5. **[O]** Every object record is visited; `0..90` bypasses per-object filtering; actor LOD
   has one mesh range `0..150` and separate shader/distance `0..2500`.
6. **[D]** I09's material state class is aligned, but its placement, origin, height snap,
   scale handling, final orientation and LOD remain approximations/divergences.
7. **[U]** Donor parity is not established and is not claimed.

*End of DEC-VIS-02. Exactly one repository file written: this report. Donor read-only;
no donor binary executed or copied; no code, Godot, git, source, asset, config, test,
shader, fixture or runner change; no donor-parity claim.*
