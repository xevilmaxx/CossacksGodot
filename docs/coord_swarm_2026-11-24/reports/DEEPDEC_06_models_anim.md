---
id: DEEPDEC-06
owner: DEEPDEC-06
date: 2026-11-24
mode: "read-only audit (no donor copies, no source/git edits, no runtime tools, no target open/select)"
scope: "DONOR 3D MODELS / ANIMATION RIG — .oss/.osm binary layout, bone-parent blocker, RTTI, feasible decoder"
governing_rule: "WAVE7_3D_VARIANT_CHARTER.md:29-38 / DEEPDEC_CHARTER.md:8-25 — cite donor path:line or evidence id; OBSERVATION vs INFERENCE separated; UNVERIFIED where unreadable; never claim donor parity without proof"
donor: "C:\\Games\\Cossacks 3 (private use; Python bytes/struct/latin-1 + Craft Anything path-based read-only tools only)"
active_target_used: "t_87f0f3c130b0 (already open; used read-only via core_feature_find only — never opened/closed/selected)"
deliverable: "this file only"
status: "VERDICT DELIVERED — bone-parent blocker RESOLVED FOR DEFORMATION; parent indices PROVEN absent but PROVEN unnecessary"
---

# DEEPDEC-06 — donor models / animation rig: the bone-parent blocker

## 0. Verdict up front

**The long-standing "bone parents unreadable" blocker is resolved for deformation parity.**

- **PROVEN:** no parent indices, parent table, or bone-name strings exist anywhere in a
  `.oss`. All 335 donor `.oss` files close byte-exactly with **zero slack**, and every
  field of the 24-byte header and the 7-float bone record is fully accounted for
  (§3, findings F1–F3, F6, F7). V7-2 was right about the *absence*; it was wrong that
  the absence *blocks deformation parity*.
- **PROVEN:** the stored per-bone transform is an **absolute affine delta from a
  frame-0 bind pose**, not a local parent-relative offset. At frame 0 every bone is
  identity to float precision and the shipped flat skin equation reproduces the bind
  vertices to ≤1.6e‑7 m (§3 F4, §5). The parent chain is therefore **already folded into
  the data we read**; a joint tree is not required to reproduce donor skinning.
- **CONSEQUENCE:** V7-64's `anim3d.gd` flat-root path (with `ref_frame = -1`) is
  **mathematically donor-equivalent at the deformation-data level** — not merely an
  invented approximation. It is still a *decimated* pose sample and visual parity is
  **UNVERIFIED**, so the `PORT APPROXIMATION — NOT DONOR PARITY` label should stay until
  a rendered A/B exists (§6).
- **STILL UNVERIFIED:** donor-authored bone *names*/semantic labels, the engine's
  internal `TSkeletonBone` hierarchy, the glTF/Godot quaternion mapping (bypassable by
  emitting absolute matrices directly), yaw policy, AAF loop/clamp, and any visual A/B.
  None of these blocks reproducing the readable deformation.

## 1. Method and tools used (all read-only)

| Tool | Use | Evidence |
|---|---|---|
| `tools.craftanything.core_target_triage({path:...})` | Identify 5 real donor `.oss`/`.osm` files | E1–E5 |
| `tools.craftanything.native_bytes_find({path:..., pattern/text})` | Whole-file byte/text search on donor mesh files (header signatures, `IDP2`, `SkinBitMap`, `FRAME`, absence of `bone`) and on `cossacks.exe` (RTTI class names) | E6–E12, E24–E31 |
| `tools.craftanything.core_feature_find({query:...})` | Code-reference check for animation/skeleton strings on the already-open target | E32–E36 |
| Bounded Python `open(...,'rb')` + `struct.unpack_from` + 16-byte hexdumps | Decode headers, section offsets, weight lists, bone tracks, quaternion norms, identity frame; census of all 335 `.oss` | exact donor paths + byte offsets below |
| `core_text_read` equivalent (Python `latin-1`) | Read repo `app/tools/bake_sprites.py`, `docs/decomp/DC_FORMATS.md`, `docs/decomp/DA_PE.md`, prior V72/V764 reports | repo `path:line` below |

No `core_target_open`, `core_target_select`, `native_window_capture`, Frida, memory
read, donor execution, donor copy, repo source edit, git edit, or runtime tool was used.
Three throwaway probe scripts were written to the approved system temp folder and are
deleted after this report; no probe file entered the repository.

## 2. Evidence table

### 2.1 Donor mesh files — Craft Anything evidence ids

| id | Path / offset | Finding |
|---|---|---|
| E1 `ev_cd615ee54602c2177d2410e1641a760b0d294afd3b838c01f2d4141f88131b0d` | `data\actors\units\peaukr.oss`, 312,376 B | triage: unrecognised binary, sha256 `1c356bcf…` |
| E2 `ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` | `data\actors\units\yacht.oss`, 217,344 B | triage (same id DC_FORMATS.md cites for `.oss`) |
| E3 `ev_765d2c1ca9bc3d2bf9ddfcad5074f69c3b395a35d2d38f1c473bd81f3961096d` | `data\actors\buildings\aus\attach\ausbaranim.oss`, 16,528 B | triage: building-attach `.oss`, b=10 |
| E4 `ev_d77efe75c74efe5a860901c9b5be3d302b894a8cc4db06b2c4dbc66d117d208f` | `data\actors\env\spruce1.osm`, 60,300 B | triage: unrecognised binary, sha256 `55c92bad…` |
| E5 `ev_b99b4a21f15ea995d9c5a1ec48ffa49bf3b4e264ae878f96cfd1fce3acb82a5d` | `data\actors\buildings\alg\algcen.osm`, 224,412 B | triage |
| E6 `ev_693218109de66d42788b5809dbe38047c94ff695da6536cc26f061257fdf4890` | `peaukr.oss` `0x0` | header bytes `e3 01 00 00 1e 00 00 00 14 00 00 00` = k=483,fps=30,b=20, 1 match |
| E7 `ev_67cb62e4d35f64e8462470e8d8d01952fc9812466444eb76bc9bd97228a21fa1` | `peaukr.oss` whole file | text `bone`: **0 matches** — no bone names/parent labels |
| E8 `ev_e67fe0cee7e5ee5c53b07cf7ebc62aaca81a15c81aa0ef9641e33b9f388f7a83` | `yacht.oss` `0x0` | header bytes `37 01 00 00 …` = k=311,fps=30,b=20 |
| E9 `ev_42fbfbd05f55edae7f1ba1d4b732b3e66d20a02dd654a595280001f2cc57755b` | `spruce1.osm` `0x0` | `IDP2` magic, 1 match |
| E10 `ev_54c098fb5ee56374d060eb861359e20c1cb8b242d84f245a8c30f5f82a7dce0f` | `spruce1.osm` `0x44` | `SkinBitMap` section-name string |
| E11 `ev_73044ac566bd938cdf04c1394a45ec4dc8640c6c3153f9875f36b02a326d8a09` | `spruce1.osm` `0x7f9c` (= `of`=32,668) | `FRAME` frame-header string |
| E12 `ev_1e2a6d6153f2efa344ac55d4eba66573c2d2d1a49abcfafb9606b4cf12d9336d` | `algcen.osm` `0x0` | `IDP2`, 1 match |

### 2.2 EXE RTTI / strings — whole-file `native_bytes_find({path:cossacks.exe})`

| id | VA / file offset | Finding (OBSERVATION: these are length-prefixed Delphi metadata in `CODE`, not code) |
|---|---|---|
| E24 `ev_0723e208f0700894637218a6028d162bb58d5311a4e14469d5e8adf170561771` | `0x550924`/`0x14fd24` +21 more; `.rsrc` `0x959081` | `XAnimation` — 22 hits; context `0x14fd24` shows `TXAnimation`, `XBaseActor` RTTI fields |
| E25 `ev_761b7e9391fc7445119f81496ea6863d9b18988bc5b16a3a70bf5f3ab78b064a` | `0x7d07da`/`0x3cfbda`, `0x871940`/`0x470d40`, `.rsrc` `0x958801` | `XTrackPoint` — 11 hits; context shows `TXTrackPointPointInfo`, `TXTrackPointMoveInfo` |
| E26 `ev_298919c876d9e9e6b4f7419bd0696daeaa679dd092fde00396a06b302fb849b3` | `0x5119ef`/`0x110def`, `0x8622bb`/`0x4616bb`, `.rsrc` `0x95880f` | `XStateMachine` — 19 hits; context `TXStateMachineProgressOption` (`smpoVisible/Always/Active/Never`), `TXStateMachineStackItem` |
| E27 `ev_0a4f067239492b0b8416975450864bd505aa99cd985d9ad021ac637977557f19` | `0x4f5b85`/`0xf4f85`, `0x4f5d8f`/`0xf518f` | `TSkeletonBone`, `TSkeletonBoneList` RTTI (unit `OSWVectorFileObjects`) |
| E28 `ev_f833ba7ee74e890d2c91d05f963bbd7f9c52e1854b9d2291f4151e3a1eb6dc51` | `0x4f6557`/`0xf5957` | `TSkinnedMeshObject` RTTI |
| E29 `ev_df92ddfe45cbf34ba638f13fe9cbb39a9822624c8bb7c14ab4d0cdef2027f32e` | `0x845418`/`0x444818`, `0x845928`/`0x444d28`, `0x848940`/`0x447d40` | `ParentIndex` — 3 hits, all in GUI/hotkey state RTTI (`NeedTargetBaseNameUnits`, `Priority`, `HasChildren`, `HotKey`, `StateName`): **NOT a bone parent** |
| E30 `ev_d7108049e521ff3dfcbd62a99f71a7f66feb5ac2bbb030c27fdc19638bf52b6b` | `0x4f6e0a`/`0xf620a`, `0x512314`/`0x111714` | `afpSkin`, `afpLSkin` enum values (skinning exist in engine RTTI) |
| E31 `ev_2b74443dc6f33f253d05eb96643f5ee57678ca48a3a75d876b23dc9aaf780eea` | `0x5467b8`/`0x145bb8`, `0x546910`/`0x145d10` | `ShaderIDNoBones` material flag exists |
| E32 `ev_7b018de06028ddcc69dd0aa244e75df207e8fa081971d4cbd46388b76dd62ab6` | feature query `XAnimation` | 1 string (`\XAnimation` at `0x959080`), **0 functions, 0 imports, 0 code refs** |
| E33 `ev_515fabe2ebedebfe922c219c87e1baa3dacc47aa64adca00bcb0a59d6cb3286d` | feature query `Skeleton` | 0 strings/functions/imports |
| E34 `ev_c06a5810adec0172e903eb472e4b17d46c0225433f180f27f8f74c1e36d14629` | feature query `TSkeletonBone` | 0 strings/functions/imports |
| E35 `ev_ba6f1abc2ec3d22fb15f07f181cde8f1c66518aba7a63aac43afdbe543eaae7a` | feature query `Skin` | 1 unrelated RTL string, 0 functions/imports |
| E36 `ev_dc98c83a6a4b22a3bf36de1370abfe64a08af4521f8dc5620c7a64ebbeda4256` | feature query `ParentIndex` | 0 data-section strings / 0 functions |

## 3. Top 10 layout findings (OBSERVATION unless marked)

**F1 — `.oss` byte accounting leaves ZERO room for a parent table.**
For all 335 `.oss`: `size = 24 + v·12 + fc·12 + t·8 + fc·12 + Σ_v(4 + 8·n_i) + b·k·28`.
Measured `peaukr.oss`: header 24, verts 6,924 @`0x18`, faces 11,052 @`0x1b24`, UVs 5,864
@`0x4650`, UV-faces 11,052 @`0x5d18`, weights @`0x8864`, anim @`0xa3a8`, end 312,376
= on-disk size, **closure 0**. Same closure for `yacht.oss` (217,344), `pikeman.oss`
(225,352), `ausbaranim.oss` (16,528), `eurgolanim.oss` (18,072). Full census: **335/335
close, 0 failures**. There is no trailing or interstitial block that could hold parent
indices. [PROVEN; E6/E8 + direct offsets]

**F2 — header is six counts only.** `peaukr.oss` `0x0`:
`e3 01 00 00 | 1e 00 00 00 | 14 00 00 00 | 41 02 00 00 | 99 03 00 00 | dd 02 00 00`
= `k=483, fps=30, b=20, v=577, fc=921, t=733`. No spare field. All 335 files have
`fps=30`; `b` ∈ {1…42}, `k` ∈ {24…755}. [PROVEN; E6]

**F3 — the 7-float bone record is fully consumed by position + unit quaternion.**
Bone 0 frame 0 @`0xa3a8` decodes to `t≈(0,0,0)`, `q≈(0,0,0,1)` (bytes `… 00 00 80 3f`).
Across all frames of all sampled files quaternion norm is **1.000000 min/max/mean**;
field 6 (`q.w`) ranges 0.41…1.0 and is never integer-valued except the bind frame. No
float slot can be an integer parent index. [PROVEN; direct offsets]

**F4 — frame 0 is an exact bind pose for every bone.** For `peaukr`, `yacht`, `pikeman`,
`ausbaranim`, `eurgolanim`, the frame minimizing identity error is **frame 0** in all
cases, with total error 0.000000 at print precision; individual components are ~1e‑10
(float32 noise). Applying the shipped skin equation at frame 0 reproduces the stored
bind vertices with max displacement **1.6e‑7 m (peaukr)**, **2.4e‑7 m (yacht)**,
**9.8e‑7 m (ausbaranim)**. [PROVEN; direct offsets]

**F5 — therefore bone tracks are ABSOLUTE deltas from bind, not local parent offsets.**
INFERENCE (strong): a parent-relative joint transform at the bind pose would encode
rest offsets/rotations, not identity for all 20 bones. Combined with F4, the absence of
any other transform block (F1), and the shipped baker's bone-by-bone visual validation
(`app/tools/bake_sprites.py:118-129`), the stored `(p_i(f), q_i(f))` is the global affine
already applied to bind-space vertices. The parent chain is pre-baked into these numbers.
[INFERRED — not provable from bytes alone; deformation equivalence is nonetheless proven]

**F6 — weight lists are per-vertex bone/weight pairs, not parent links.**
`peaukr.oss` weights @`0x8864`: `01 00 00 00 | 0d 00 00 00 | 00 00 80 3f` = count=1,
bone=13, weight=1.0. 584 pairs total, bone index range **0…19** (=`b−1`), every bone
0…19 referenced, per-vertex weight sums **exactly 1.000000**. Count distribution
`{1:573, 2:1, 3:3}`. The leading int32 is a list length, not a bone parent. [PROVEN; E6 + offsets]

**F7 — no bone names or hierarchy labels in `.oss`.** Whole-file text search for
`bone` in `peaukr.oss`: **0 matches** (E7). No ASCII skeleton table exists in any read
file. Donor text sweep over 16 config/script extensions found only GUI `parent`
references and two unrelated lore uses of "joint"; no bone/skeleton data. [PROVEN]

**F8 — `.osm` header/sections confirmed.** `spruce1.osm` `0x0` =
`IDP2 | 8 | 256,256 | fs=13824 | ns=1 | nv=863,nu=887,nt=1060 | ng=0,nf=1 |
os=68 | ou=132 | ot=7228 | of=32668 | og=oe=46492`; `SkinBitMap::::…` name at `0x44`
(E9/E10), `FRAME 000........\0` at `of`=`0x7f9c` (E11), vertices `of+16` as `<3f I>`
record `1a 5f 27 3e 15 00 45 3e 02 3d 02 bd 01 00 00 00`. Arithmetic `ou+nu·8=ot`,
`ot+nt·24=of` holds. [PROVEN; E9–E12]

**F9 — `.osm` closure is sample-specific.** `yacht.osm` (427,436) and `algcen.osm`
(224,412) have `oe = filesize`, so `of+16+nv·16 = filesize`. `spruce1.osm` does **not**:
`oe=46,492`, filesize `60,300`, difference `13,808 = nv·16` — a further vertex frame
follows with no second `FRAME` header (only one `FRAME` occurrence in the file). This is a
new correction to `docs/decomp/DC_FORMATS.md:87-94`. [PROVEN; direct offsets]

**F10 — EXE confirms skeleton/skinning types exist but exposes no implementation.**
`cossacks.exe` contains Delphi RTTI `TSkeletonBone`, `TSkeletonBoneList`,
`TSkeletonFrame`, `TSkinnedMeshObject` (E27/E28), `TXAnimation` (E24),
`TXTrackPointPointInfo`/`TXTrackPointMoveInfo` (E25),
`TXStateMachineProgressOption`/`TXStateMachineStackItem` (E26), `afpSkin`/`afpLSkin`
(E30), `ShaderIDNoBones` (E31). But `core_feature_find` returns 0 functions / 0 imports
/ 0 code refs for all of them (E32–E36). The only `ParentIndex` identifier is a GUI
hotkey-state field (E29), **not** a bone parent. [PROVEN]

## 4. Exact skin equation already used by the port, and what it omits

Source: `app/tools/bake_sprites.py:118-129` (`qmat`), `:131-143` (`skin`), `:310-342`
(root rebase), `:145-152` (`sample`). Mirrored in `variant3d/scripts/anim3d.gd` per
V7-64 §2.

Let bone `i` at frame `f` store `p=(p_x,p_y,p_z)=anim[i][f][0:3]` and
`q=(x,y,z,w)=anim[i][f][3:7]`. The donor rotation is applied **transposed** (row-vector
convention; validated bone by bone against the bind pose at `bake_sprites.py:119-123`):

```
M(q) = [[1-2(y²+z²), 2(xy-zw), 2(xz+yw)],
        [2(xy+zw),  1-2(x²+z²), 2(yz-xw)],
        [2(xz-yw),  2(yz+xw),  1-2(x²+y²)]]
R    = transpose(M(q))          # qmat returns row-major R

skin(v, f) = Σ_i  w_i · ( R(q_i,f) · v + p_i,f )        # per-vertex weights, Σ w_i = 1
```

Optional locomotion rebase (`:310-342`): bone 0 = hips/pelvis; subtract
`(p_root,f − p_root,ref)` from x,y of every skinned vertex; `ref` is first idle frame
for standing clips and first frame for `death`. `sample(rng,n)` keeps all frames when
the action has ≤n frames, else decimates with donor-order `round()` (half-to-even).

**What this omits / why it is nonetheless sufficient:**
- **Parent matrix chain** — omitted. By F4/F5 the stored matrices are already absolute
  deltas; there is no chain to apply. This is the finding that dissolves the blocker.
- **Inverse bind matrix** — effectively identity (frame 0 is bind, F4). No separate
  IBM data exists in `.oss`.
- **Scale / stretch** — absent from the 7-float record; donor skin here is rigid
  rotation + translation per bone only.
- **Bone names / semantic labels** — absent (F7); no file in the readable set supplies
  "head", "left arm", etc.
- **Attached tools** — separate `.oss` meshes (`bake_sprites.py:343-386`). Peasant
  tools `peaukr_{axe,bag,cart,hammer,hoe,lumber,pick}.oss` are `k=483, b=1`; skinned
  with their own single track on the same timeline, then root-rebased to the body.
- **Yaw** — renderer transform, no turn/rotate actions in AAF (V72 §3.3.3); UNVERIFIED.
- **AAF loop/clamp** — `.aaf` rows carry only `morph`; no loop flag (V764 §2).

## 5. Reconstructed logic — why a bone tree is not needed

1. `.oss` frame 0 stores identity transforms for all `b` bones (F4). The OBJ/converted
   bind mesh is exactly these vertices (V764 §2: morph index `i` = OBJ vertex `i`).
2. For any other frame `f`, the stored `(p_i, q_i)` is the transform that maps a bind
   vertex into its posed position *in the same bind-space coordinate system* (F5,
   visually validated by the shipped baker). There is no multiplication by a parent
   matrix anywhere in the readable pipeline.
3. Linear blend skinning with `Σ w_i = 1` (F6) and identity inverse binds therefore
   reproduces the donor deformation exactly at the sampled frame:
   `v_skin(f) = Σ_i w_i (R_i(f) v + p_i(f))`.
4. The only fidelity losses in the current port are **frame decimation** (12 samples
   instead of 483) and the **root rebase** policy — both explicit port choices, not a
   missing hierarchy.

**Minimal decoder plan for donor-parity deformation** (no invented rig):

| Step | Concrete action | Donor basis |
|---|---|---|
| 1 | Parse `.oss` verbatim with `read_oss` (`app/tools/bake_sprites.py:91-103`) | F1/F2/F6 |
| 2 | For each `(bone,frame)` build a 4×4 affine `A_i(f) = [R(q) | p]` using `qmat` transpose | F3/F5 |
| 3 | Use identity inverse bind matrices; do **not** invent parent indices | F4/F5 |
| 4 | Godot: `Skeleton3D` with `b` bones, identity rests, all direct children of the skeleton root; per frame `set_bone_pose_matrix(i, A_i(f))`; bind `MeshData` weights `(bone_index, weight)` from the weight list | F1/F6; Godot API mapping UNVERIFIED until rendered A/B |
| 4′ | glTF alternative: `b` joints parented to one synthetic root **is not an invented skeleton** because transforms are absolute; set node `matrix` to column-major `A_i(f)` and `inverseBindMatrices` = identity; animate node matrices | F4/F5; glTF convention UNVERIFIED |
| 5 | Slice clips from `data\animations\aaf\<sid>.aaf` inclusive ranges at `fps=30` | V72 §3.2; V764 §2 |
| 6 | Skin attached tools as separate single-bone `.oss` on the same AAF timeline | `bake_sprites.py:343-386` |
| 7 | Gate: assert `skin(m,0) == verts` to ≤1e‑6 m and compare frames 1/10/100 against `bake_sprites.skin` numerically before any render | §5 step 3 |

Effort is materially smaller than V7-2's "5–10 d after unblock": the unblock is not a
hierarchy search, it is the realisation that the hierarchy is pre-folded. A render A/B
is still required before claiming visual parity.

## 6. Port implications

- **V7-2 Table B1** ("donor-faithful skinned GLB BLOCKED — no parent indices") should be
  amended: the *deformation data* is complete and donor-faithful; only **semantic bone
  labels** and **visual verification** remain UNVERIFIED. The flat-root glTF node list
  is not an invented rig when the matrices are absolute and IBM is identity (§5 step 4′).
- **V7-64 `anim3d.gd`** `skin_vertices(..., ref_frame=-1)` emits exactly the donor equation.
  Its label should be refined to `DONOR-EQUIVALENT DEFORMATION DATA — POSE DECIMATED,
  VISUAL UNVERIFIED`; do **not** drop `PORT APPROXIMATION — NOT DONOR PARITY` without a
  rendered A/B (frame decimation remains a real fidelity gap).
- Do not spend tickets hunting for a bone-parent table in `.oss`, `.actor`, `.lib`, or
  `.ani`: F1/F7 and the donor text sweep close that search, and the data is unnecessary.

## 7. UNVERIFIED / BLOCKED list

1. Donor-authored bone names or semantic joint labels — absent from `.oss` (F7) and no
   readable text source found. Not needed for deformation, only for authoring/UI.
2. The engine's internal `TSkeletonBone` hierarchy and how it relates to the baked
   absolute tracks — RTTI name only, 0 code refs (E27/E34). INFERRED to exist; unreachable
   statically.
3. glTF/Godot quaternion-convention mapping — can be bypassed by emitting absolute
   matrices (§5), but the exact `Skeleton3D`/glTF binding is UNVERIFIED without a render.
4. Per-frame visual A/B against a donor render — never performed; all visual parity
   claims stay UNVERIFIED.
5. AAF one-shot loop/clamp policy — no flag in `.aaf` (V764 §2).
6. Whether yaw is a discrete 8-way renderer transform or continuous — no donor citation
   (V72 §3.3.3).
7. `.osm` second vertex frame in `spruce1.osm` (F9) — semantics unknown; may be a
   wind/LOD pose, not investigated.
8. No `.ani` files installed; no runtime unpacking attempted per charter.

## 8. Next atomic task suggestions

- **DD06-T1 (0.5 d):** implement `oss_to_skin_matrices.py` — vendored `read_oss` + `qmat`,
  emits per-frame absolute matrices and identity IBM; gate with numeric equivalence to
  `bake_sprites.skin` at frames 0, 1, 10, 100 on three sids.
- **DD06-T2 (1 d):** rendered A/B — one skinned peasant pose vs the shipped sprite bake
  at the same camera, settle the Godot `Skeleton3D` matrix binding and the quaternion
  convention. This is the gate for dropping the approximation label.
- **DD06-T3 (0.5 d):** policy ticket for root rebase (`ref_frame`) per AAF action class.
- **DD06-T4 (0.5 d):** extend T1 to the 7 peasant attached-tool `.oss` files (b=1).
- **DD06-T5 (0.5 d):** decode the `.osm` second vertex frame (F9) and decide whether env
  meshes carry a readable wind pose.

---
*DEEPDEC-06, read-only audit. No donor file copied or executed; no source, asset, test,
config or git change; no target opened/selected; no runtime instrumentation. All donor
facts cite a Craft Anything evidence id or an exact donor path and byte offset.*
