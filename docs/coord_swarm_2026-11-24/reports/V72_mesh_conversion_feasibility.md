---
owner: V7-2
date: 2026-11-24
mode: read-only recon
scope: "SINGLEPLAYER SKIRMISH ONLY — units/buildings/trees/FX meshes and their animation; no campaign, missions, cutscenes, DLC or network assets (WAVE7_3D_VARIANT_CHARTER.md:37-38, D-12)"
governing_rule: "Leverage existing DONOR code — do not invent; every 3D decision cites donor path:line or an evidence id; UNVERIFIED where unreadable (WAVE7_3D_VARIANT_CHARTER.md:29-38)"
revision: "2026-11-24 — verdict split into donor-backed vs BLOCKED/UNVERIFIED; 2.5D paths labelled PORT APPROXIMATION"
donor: "C:\\Games\\Cossacks 3 (private use, bytes+latin-1/struct only; no donor binary run or copy)"
toolchain: "python 3.14; Blender 5.2 present at C:\\Program Files\\Blender Foundation\\Blender 5.2\\blender.exe"
deliverable: this file only
godot_runs: none
blender_runs: none
code_edits: none
---

# V7-2 — Mesh conversion feasibility: donor-equivalent 3D units/buildings for Godot

**Bottom line (singleplayer skirmish only):**
- **Donor-backed conversions (§5 Table A)** — static buildings/trees/rocks/units
  from the 116 `.obj`, AAF timing, env scale/LOD metadata, camera/light constants,
  FX inventory — are **FEASIBLE**, each grounded in readable donor bytes/config.
- **Donor-faithful skinned units (§5 Table B1)** are **BLOCKED / UNVERIFIED**: the
  skin payload is readable, but no donor-readable bone hierarchy exists, so no
  donor-parity rig may be specified. No invented rig is proposed here.
- **CPU-sampled morph/billboard paths (§5 Table C)** are acceptable only as
  explicitly labelled **PORT APPROXIMATION — NOT DONOR PARITY**.
No command in §4 has been executed — this is a plan, and each row is gated by a
verification test.

---

## 1. Sources read (all read-only)

| id | Source | Use |
|---|---|---|
| S1 | `docs/audit/RENDER_ARCH_UNITS.md` | donor-live-3D verdict, `.oss`/`.osm` layouts, mesh evidence D1/D2, R-ARCH claim table C1–C12 |
| S2 | `docs/decomp/DC_FORMATS.md` (note: **not** in `docs/audit/`) | §2.1 `.oss` fully decoded, §2.2 `.osm` offsets 12/13/14, T-2 reader sweep |
| S3 | `docs/audit/RENDER_ARCH_PORT_FEASIBILITY.md` | §5 `.obj` quality constraints, §2 items 7–8, M0–M4 gates, C11/C12 |
| S4 | `app/tools/convert_models.py` | `read_oss` :43–66, `read_osm` :69–94, `write_obj` :109–125 (v/vt/f only), `convert_texture(force_opaque)` :135–153, model tables :160–308, manifest :361 |
| S5 | `app/tools/bake_sprites.py` | `read_oss` :91–103, `qmat` :118–129 (transposed quaternions), `skin` :131–143 (**working CPU skinning path**), camera rig :213–245, `bake_building` :562–599 |
| S6 | `rustport/README.md` | scaffold-only; runtime donor-asset plan (`.oss`, `.osm`, `.aaf`, `.dds`); no mesh converter exists there either |
| S7 | direct Python `bytes`/`struct` reads of donor + repo files this pass | all `[MEASURE]` lines below |
| S8 | `docs/coord_swarm_2026-11-24/WAVE7_3D_VARIANT_CHARTER.md:29-38` | GOVERNING RULE + singleplayer-skirmish-only scope |

### 1.1 Donor citation ledger (governing-rule compliance)

Donor **text** files carry real line numbers; donor **binary** files (`.oss`/`.osm`)
carry byte offsets, so they are cited by donor path **plus** the repo decode
doc line and evidence id where the layout was established. All reads this pass
were Python `bytes` / `latin-1` / `struct`; no donor executable was run.

| Decision | Donor source (read-only) | Repo decode / evidence |
|---|---|---|
| `.oss` = 24-byte `<6i k,fps,b,v,fc,t>` + verts + faces + UVs + UV-faces + weights + `b×k×<7f>` tracks | `data\actors\units\peaukr.oss` (header at byte 0; exact size closure 312,376 B, tail 0, §3.2) | `docs/decomp/DC_FORMATS.md:46-64`; evidence `ev_392885a6…`; this pass `[MEASURE]` §3.2 |
| `.osm` IDP2 static mesh, section offsets at longs 12/13/14 | `data\actors\env\spruce1.osm`, `data\actors\units\yacht.osm` | `docs/decomp/DC_FORMATS.md:66-94`; evidence `ev_0bbb20c1…` |
| AAF named action ranges (`walk 1..20`, `idle 64..113`, 18 actions) | `data\animations\aaf\peaukr.aaf:1-20` (line 2 `18`; `"walk",1,20,morph` at line 4) | `docs/decomp/DC_FORMATS.md:96-109`; evidence `ev_6a6b0380…` |
| ACL clip list (semantics partial) | `data\animations\acl\cannon.acl:1-18` (`items[0].AnimationName = idle`, `From = walk`) | `docs/decomp/DC_FORMATS.md:14`; evidence `ev_e5ad6408…` |
| Per-instance random scale for env meshes | `data\game\var\envscales.cfg:43-46` (`stones` scale 0.329, minscale 0.85), `:231-234` (`pine1` 0.475), `:371-374` (`spruce1` 0.5), `:25-28` (`minegold` 0.3152) | S1 §2.3 / claim C5 |
| Env LOD + seasonal material selection | `data\objects\env\spruce1.prop:9-18` (`LODActorName = spruce`, `DefaultMeshName = spruce1.mesh`, `UseableMeshes[0..3]`) and `:20+` (`materialproperty`) | S1 §2.3 / claim C5 |
| Donor camera pitch **−32°** (now donor-confirmed, not inference) | `data\cameras\camera.cfg:32-35` (`MinHeightMinAngle = -32` … `MaxHeightMaxAngle = -32`); `:6-10` `SphereHeight = 58`, min 20 | S1 camera rig `:235-238`; S3 `data.gd:161-163` |
| Lighting constants for a lit 3D scene | `data\env\lights\light.cfg:2-14` (Ambient RGB 0.196/0.184/0.129; Diffuse RGB 0.812/0.780/0.694) | S3 §2 item 9 |
| FX source is a particle/animated-sprite config, **not** a mesh | `data\pfx\source.pfx:1-18` (`LibManagerName = aspriteblank`, `FrameWidth = 512`, `FrameRate = 10`) | `docs/decomp/DC_FORMATS.md:20` (`.pfx` count 1, "Partial — text parses; particle semantics unmapped") |

**Scope guard:** all rows above are used only for singleplayer-skirmish
units/buildings/trees/FX. Campaign, mission maps, cinematics and network remain
deferred per `WAVE7_3D_VARIANT_CHARTER.md:37-38`.

---

## 2. Inventory of converted meshes (repo, measured this pass)

All counts/sizes from Python `os.path.getsize` / `glob` over
`app/assets/models/**` — labelled **[MEASURE]**.

### 2.1 Files

| Item | Count | Total bytes | Range |
|---|---:|---:|---|
| `models/**/*.obj` | **116** | **10,787,411** | 1,880 – 1,472,798 |
| `models/obj/*.obj` (same set) | 116 | — | — |
| `models/**/*.mtl` | **116** | 6,289 | 47 – 63 |
| `models/tex/*.png` | **116** | **139,862,342** | 48,365 – 6,531,253 |
| `models/**/*.glb` | **0** | 0 | — |
| `models/**/*.gltf` | **0** | 0 | — |
| `models/**/*.dae` | **0** | 0 | — |
| `models/anim/**/*.png` sheets | **1,849** | **269,611,324** | 17,199 – 1,924,918 |

Subdirectories under `app/assets/models`: `anim`, `obj`, `sprites`, `sprites_hi`, `tex`.

**[MEASURE] `manifest.json`:** top keys `['game','models']`, `models=116`,
`game=C:\Games\Cossacks 3`. Kind split: **unit 9 / building 14 / env 93**.
Matches S4 tables (9 units; 11 buildings + 3 mines = 14; 93 env).

### 2.2 Animation manifest — correction to the task's "116 sets"

**[MEASURE]** There is **no** `app/assets/models/anim/index.json`. The indexes are:

| Path | Keys | Notes |
|---|---:|---|
| `anim/land_units/index.json` | **54** | all 54 have an `actions` dict; **0** `alias_of` entries |
| `anim/naval_units/index.json` | **7** | `yacht`, `yachttur`, `fishboat`, `frigate`, `galley`, `battleship`, … |

So **116 is the static-`.obj` count, not the anim-set count** (54 land + 7 naval =
61 anim keys). The `ALIAS_OF = {"peasant":"ukr_peasant"}` map in `bake_sprites.py:48`
is present in code but produced **no** `alias_of` records in the current index —
likely a `--no-alias` regeneration; UNVERIFIED.

**[SAMPLE] `land_units/index.json["peasant"]`:** `cell=160`, actions include
`walk` (12 frames, 1.08 s, loop, `ortho=5.465`, `center=[0,0,1.101]`, `ax=0.5`,
`ay=0.8037`, `tool=null`), `idle` (6 frames), `attack` (12 frames, `tool="axe"`).
The index also carries per-action `bbox`, `fig_h`, `foot`, `cx` — useful for a 3D
contact-shadow/foot-anchor adapter.

**[MEASURE]** Sheet geometry: `peasant_walk.png` **1280×1920** = 8 dirs × 12 frames
× 160 px; `peasant_idle.png` 1280×960 = 8×6; `ukr_hou.png` / `ukr_cen.png`
**320×320** (single-view building bake, S5 `:562–599`).

### 2.3 Verification of the R-ARCH `.obj` quality claims

| Claim (from S3 §5 / S1 §4.1) | Status | Direct evidence this pass |
|---|---|---|
| No normals in the OBJs | **CONFIRMED** | `[MEASURE]` OBJ lines beginning `vn `: **0 / 116**. Samples `aca.obj`, `archer.obj`, `bar.obj` all `has_vn=False`. |
| UVs present | **CONFIRMED** | `vt `: **116 / 116**; **128,435** total `f` lines; faces are `v/vt` (sample `peasant.obj`: `f 12/1 27/2 2/3`). |
| Z-up coordinates | **CONFIRMED** | `[SAMPLE] peasant.obj` first verts `v 0.062326 -0.057036 0.384664`; manifest unit bboxes have height in **Z**: peasant z `0.0069..1.9955`, pikeman z `0.0014..3.5164`, archer z `0.0015..2.0079`. |
| Skinning/animation discarded | **CONFIRMED** | S4 `write_obj` :109–125 emits only `v`, `vt`, `f`; `read_oss` parses weights/animation but they are never written. `0` glb/gltf/dae/bones files. |
| Unit/building textures forced opaque | **CONFIRMED at binary level** | `[MEASURE]` PNG IHDR color type: **unit 9/9 = type 2 (RGB, no alpha channel)**, **building 14/14 = type 2**, **env 93/93 = type 6 (RGBA)**. Exactly matches `force_opaque=(kind in ("unit","building"))` at S4 `:344–345` and `img.convert("RGB")` at `:146`. |
| MTL texture wiring | **CONFIRMED** | `peasant.mtl` = `newmtl model\nKd 1 1 1\nmap_Kd ..\tex\peasant.png\n`. Relative Windows separator; Blender's OBJ importer resolves it. |
| "Baked at 512 px" | **N/A for geometry** | `.obj` carry no pixel resolution (S3 §5). Texture PNGs are donor DDS-derived at native resolution (sizes measured above); sprite sheets are 160 px cells / 320 px buildings. |

Representative **[MEASURE]** manifest bbox spans (x, y, z) in donor units ≈ metres:
`hou [10.782, 8.174, 5.529]`, `cen [14.104, 13.050, 12.135]`,
`tow [4.348, 4.941, 9.428]`, `aca [23.720, 6.859, 7.915]`,
`tree_spruce1 [3.133, 3.495, 6.930]`, `tree_pine [3.338, 3.197, 7.722]`,
`rock [14.335, 7.740, 5.074]`, **`field [58.519, 51.925, 20.453]`**.
Caveat: `field` is a ground patch, so normalising every prop by its Z span would
be wrong — only upright units/buildings/trees should use height normalisation.

---

## 3. Donor animation truth (read-only)

### 3.1 Animation directory inventory

**[MEASURE]** `C:\Games\Cossacks 3\data\animations` ext census:
`.aaf` **246** (36,448 B), `.acl` **30** (455,550 B), `.lib` 5, `.library` 1,
**`.oss` 0**. The skinned meshes are **not** stored under `animations/`.

**[MEASURE]** Global recursive census under `data\`:
`.oss` **335**, `.osm` **3,897**, `.aaf` **246**, `.acl` **30** —
independently reproduces S1 §2.2 and S2 §1 counts.

### 3.2 `.oss` header reads and exact size closure

Read with `struct.unpack("<6i")` + sequential section skips; **no donor code run**.
Formula: `size = 24 + v*12 + fc*12 + t*8 + fc*12 + (v*4 + pairs*8) + b*k*28`.

| File | Bytes | `k` frames | fps | bones `b` | verts | faces | UVs | weight pairs | anim bytes | closure tail |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `actors\units\peaukr.oss` | 312,376 | **483** | **30** | **20** | 577 | 921 | 733 | 584 | 270,480 | **0** |
| `actors\units\yacht.oss` | 217,344 | 311 | 30 | 20 | 584 | 947 | 793 | 593 | 174,160 | **0** |
| `actors\units\pikeman.oss` | 225,352 | 312 | 30 | 20 | 733 | 1,062 | 939 | 735 | 174,720 | **0** |

**→ R-ARCH's "20 bones / 483 frames @30 fps" is CONFIRMED** on `peaukr.oss`, with
exact file-size closure (no trailing unknown blocks). `yacht.oss` and `pikeman.oss`
differ in frame count but share the 20-bone/30-fps skeleton shape.

**[MEASURE]** `animations\aaf\peaukr.aaf`: 20 lines, line 2 = `18` actions;
`"idle",64,113,morph`, `"walk",1,20,morph`, `"death",115,149,morph`,
`"attack0",237,254,morph`, `"workfood",278,299,morph` … — inclusive ranges,
matches S2 §2.3.

### 3.3 Readable vs UNVERIFIED

**Readable / confirmed:** `.oss` header counts, vertices, faces, UVs, weight
pairs, per-bone `k×<7f>` tracks (position xyz + quaternion xyzw), exact size
closure (S2 §2.1, S4 `read_oss`, S5 `skin`); `.osm` IDP2 headers and offsets
12/13/14 with exact closure (S2 §2.2); AAF action names/ranges; `.acl`/`.lib`/
`.mat` text parse but not semantics (S2 §1).

**UNVERIFIED (must not be asserted):**
1. **Bone parent hierarchy.** `.oss` stores a flat list of `b` tracks with no
   parent indices. glTF skins need a joint hierarchy; a flat root-joint skin may
   or may not reproduce donor deformation — needs a bind-pose render test.
2. **Quaternion convention.** S5 `qmat` applies the donor rotation **transposed**
   (row-vector) — established for the Blender bake by visual bone-by-bone checks
   (`bake_sprites.py:119–129`). Whether the same transpose is required when
   feeding glTF (column-vector convention) is UNVERIFIED.
3. **Arbitrary yaw.** S1 C4 infers yaw is a renderer transform (zero
   turn/rotate actions in 246 `.aaf`); not proven without donor scripts/run.
   This matters: if true, a 3D mode needs **1 skinned pose per frame, not 8
   facing copies** (§4.3).
4. **How many of the 335 `.oss` are truly multi-frame** — S2 ticket T-2 reader
   sweep not run.
5. **ACL clip→playback semantics** — S2 T-4; action names come from `.aaf` today.
6. **Godot 4 `gl_compatibility` GLES3 skinning performance** with hundreds of
   skinned instances — no windowed measurement exists (S1 C11).

---

## 4. Conversion plan (exact command patterns — UNEXECUTED)

Ground rules: import into Blender with donor Z-up preserved, perform **one**
Z-up→Y-up conversion at GLB export, and let the GLB be the single Godot import
unit (S3 M0 recommendation). All paths relative to PROJECT ROOT unless absolute.

### 4.1 Axis / scale / material transform (applies to (a) and (c))

- Blender internal space is Z-up; donor OBJ is Z-up. Import with
  `forward_axis='Y', up_axis='Z'` so vertices enter Blender **unchanged**
  (verify: `peasant.obj` vertex 0 must read `(0.062326, -0.057036, 0.384664)`).
- Export with `export_yup=True` (glTF default). This applies the single
  determinant-preserving rotation `(x,y,z)_Zup → (x,z,-y)_Yup`; no face-winding
  flip is needed. **Do not double-swap** — the `.osm`→OBJ writer already swapped
  winding `(0,2,1)` (S4 `:83`, S2 §2.2).
- Scale/centre from `manifest.json` bbox per sid:
  `s = H_target / (z1-z0)`, `t = (-(x0+x1)/2, -(y0+y1)/2, -z0)`;
  apply `me.transform(Matrix.Translation(t) @ Matrix.Scale(s, 4))` before export
  (or use object `location`/`scale` with `export_apply=True`). For units, donor
  metres are already ≈1.9–3.5 m so `H_target = z1-z0`, `s=1.0` is the sane first
  pass; for `field`-class ground props skip normalisation (§2.3 caveat).
  Note the bind-pose X offsets on mounted sids (`cossack` x 1.466..2.871,
  `dragoon` x 1.317..2.710) — the X/Y centring step is mandatory for them.
- Materials: OBJ MTL already points at `..\tex\<sid>.png`; Blender's OBJ importer
  resolves it. Export `export_format='GLB'` embeds the PNG in the binary.
  Env textures are RGBA (§2.3): set the material's blend/cutoff before export
  and **verify the resulting `alphaMode`/`alphaCutoff` in the GLB JSON** — the
  exact Blender 5.2 material property is toolchain-dependent and UNVERIFIED
  until a GLB exists. Unit/building textures are RGB (opaque by donor design),
  so no cut-out is needed there.

### 4.2 (a) Static buildings / trees / rocks from the 116 `.obj` → GLB — FEASIBLE

Create (new file, not done here) `app/tools/obj_to_glb.py` that loops the
manifest and calls, per sid:

```python
import bpy, json, sys
from mathutils import Matrix
bpy.ops.wm.obj_import(filepath=obj_path, forward_axis='Y', up_axis='Z')
ob = bpy.context.selected_objects[0]
bpy.ops.object.shade_smooth()          # synthesise normals the OBJ lacks
x0,x1,y0,y1,z0,z1 = bbox_from_manifest[sid]
s = 1.0  # or H_target/(z1-z0)
t = (-(x0+x1)/2, -(y0+y1)/2, -z0)
ob.data.transform(Matrix.Translation(t) @ Matrix.Scale(s, 4))
bpy.ops.export_scene.gltf(
    filepath=out_glb, export_format='GLB', export_yup=True,
    export_apply=True, export_materials='EXPORT', export_image_format='AUTO')
bpy.ops.wm.read_factory_settings(use_empty=True)   # next sid
```

Run:

```powershell
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup `
  --python app\tools\obj_to_glb.py -- `
  --manifest app\assets\models\manifest.json --out app\assets\models\glb --only hou,cen,tow,tree_spruce1,tree_pine,rock
```

Then Godot imports `app/assets/models/glb/*.glb` as `PackedScene` with a
`MeshInstance3D` (or use `GLTFDocument` at runtime); batch identical sids with
`MultiMeshInstance3D` per S3 §2 item 7 / M2.

### 4.3 (b) Skinned units from `.oss` → GLB — DONOR-FAITHFUL PATH **BLOCKED / UNVERIFIED**

What the donor **does** give us (readable): the complete `.oss` skin payload —
20 bones, per-vertex weight pairs, and 483 frames × 7 floats of position+
quaternion per bone at 30 fps, with exact size closure
(`data\actors\units\peaukr.oss`; layout `docs/decomp/DC_FORMATS.md:46-64`,
evidence `ev_392885a6…`; AAF action ranges `data\animations\aaf\peaukr.aaf:1-20`).
`convert_models.py:43-66` already parses all of it; only `write_obj:109-125`
throws it away.

What the donor **does not** expose in any readable file we found: the **bone
parent hierarchy**. A glTF skin needs a joint tree. Choices such as "parent all
20 bones to a synthetic root" or "guess a hip chain" are **invented rigs**, not
donor-faithful, and are explicitly **out of scope** under the governing rule
(`WAVE7_3D_VARIANT_CHARTER.md:29-38`: "do not invent … UNVERIFIED where
unreadable"). Likewise, converting `bake_sprites.qmat`'s row-vector/transposed
rotation (`:118-129`) into glTF's column-vector convention has no donor citation
and is UNVERIFIED.

**Therefore:** no donor-faithful skinned-GLB exporter can be specified from the
readable data today. Do **not** present an invented bone tree as donor parity.
The only permissible skin-like paths are the explicitly labelled PORT
APPROXIMATIONs in §4.4, and they must be recorded as approximations in
`docs/variant3d/`.

If — and only if — a later worker finds donor-readable parent data (e.g. in
`data\animations\ref\*`, `data\actors\**\*.actor` or a `.lib` refkey chain; file
existence alone is NOT proof), the mechanical export step is:

```powershell
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup `
  --python app\tools\oss_to_glb.py -- `
  --game "C:\Games\Cossacks 3" --sid peaukr --out app\assets\models\glb --aaf animations\aaf\peaukr.aaf
```

with `export_skins=True, export_animations=True, export_yup=True`, AAF-sliced
actions, and the donor bone tree copied verbatim. Until that citation exists,
treat this command as a **placeholder**, not a plan. Effort once unblocked:
5–10 worker-days + a windowed benchmark (S1 §4.3); do not schedule as a config
toggle.

### 4.4 (c) **PORT APPROXIMATION — NOT DONOR PARITY**: per-frame CPU-skinned pose meshes → morph-target GLB in a 3D scene

> **LABEL: PORT APPROXIMATION.** This path reproduces donor *geometry* and
> donor *sampled poses* (both computed from readable donor `.oss` bytes by
> donor-derived code), but it does **not** reproduce the donor's runtime skinning
> system. It is acceptable as a pragmatic singleplayer-skirmish compromise, and
> must be documented as such in `docs/variant3d/` — never claimed as donor-faithful.

Reuse the **already-working** pure-Python skinner `bake_sprites.skin(m, fr)` +
`qmat` (S5 `:118–143`): it is verified against the bind pose by the existing
sprite bakes. For each unit sid and each action, sample frames with
`bake_sprites.sample(rng, n)` (e.g. `walk` 12 frames) and compute skinned vertex
arrays. In Blender create **one base mesh + N shape keys** (one per sampled
frame) instead of N separate meshes, then:

```powershell
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup `
  --python app\tools\oss_to_morph_glb.py -- `
  --game "C:\Games\Cossacks 3" --sid peasant --action walk --frames 12 --out app\assets\models\glb
```

export with `export_morph=True, export_animations=False, export_yup=True`.
Runtime: one `MeshInstance3D` per unit; set `shape_key_values[i]` from the
sim's animation clock and **rotate the node for yaw** — because donor yaw is a
renderer transform (§3.3.3), this avoids the 8× mesh blow-up
(54 keys × ~14 actions × ~10 frames × 8 dirs ≈ 60k meshes if naively baked).
This is a genuine 3D mesh in a lit 3D scene (real normals, real shadows,
continuous yaw), but the *deformation* is pose-sampled from a decimated AAF
timeline — a 2.5D compromise on animation fidelity, **not** donor parity.

An even cheaper **PORT APPROXIMATION**: keep the existing sprite sheets as
billboard quads in the 3D world (0 new meshes, fully 2.5D look) — useful as an
M2 visual bridge and as a fallback when an import fails (S3 §4.4). Both are
approximations; neither is a donor-faithful skinning path.

### 4.5 Test ids that prove each path

| Test id | What it proves | Concrete gate |
|---|---|---|
| **T-V72-1** | OBJ→GLB static conversion | Import `peasant.obj` into Blender and assert vertex 0 equals `(0.062326,-0.057036,0.384664)` before export; after export parse GLB JSON: one mesh, `POSITION`+`NORMAL`+`TEXCOORD_0` accessors, embedded PNG, node transform has the Y-up rotation; Godot loads it with no error and the mesh silhouette matches the 2D bake from the same camera. |
| **T-V72-2** | Skinned GLB fidelity (**future gate only — currently BLOCKED**, Table B1) | After a donor-readable bone tree is found: load `peaukr.glb` in Godot, play AAF `walk 1..20`, screenshot bone-by-bone against the donor-baked bind-pose reference (S5 `qmat`); assert no joint separation and frame count = 483 @30 fps. Record draw calls/frame time at 200 and 552 instances on the named weak GPU. |
| **T-V72-3** | Morph fallback | `peasant_walk.glb` has 1 base + 12 morph targets; scripted morph sweep shows feet anchored (`ay=0.8037` equivalent) and continuous yaw via node rotation matches the 8 baked azimuths within the S1 camera rig. |
| **T-V72-4** | Billboard bridge | Existing `peasant_walk.png` loads in a 3D scene as a textured quad, 8-dir snap matches `world.gd` facing logic; used only as failure fallback. |
| **T-V72-5** | Coverage decision | Counting script over `data/**` (335 `.oss`, 3,897 `.osm`) vs 116 converted sids quantifies the remaining re-conversion backlog; gate on curated sid list from the sim's actual `tbl`/unit tables. |

---

## 5. Verdict tables (split per governing rule)

Scope of every row: **singleplayer skirmish units / buildings / trees / FX**
(`WAVE7_3D_VARIANT_CHARTER.md:37-38`). Campaign, missions, cutscenes, DLC and
network assets are **deferred**, not assessed here.

### Table A — DONOR-BACKED: conversion grounded in readable donor files/metadata

Rows here cite a donor path + line (text) or donor path + byte-layout evidence id
(binary). No invented values.

| Asset class | Verdict | Donor source of truth (path:line / evidence) | Why feasible | Effort | Test |
|---|---|---|---|---|---|
| Static skirmish buildings / trees / rocks → GLB (bind pose, textured) | **FEASIBLE** | `data\actors\env\spruce1.osm`, `data\actors\buildings\eng\enghou.osm` static IDP2 layout documented at `docs/decomp/DC_FORMATS.md:66-94` (`ev_0bbb20c1…`); currently converted to `obj/`,`tex/` by `app/tools/convert_models.py:69-94,186-308` | Donor bytes fully readable; 116 converted sids measured (§2.1); only normals + one Z→Y rotation + GLB container needed | 1–2 d | T-V72-1 |
| Static bind-pose skirmish units → GLB (no animation) | **FEASIBLE (static only)** | `data\actors\units\peaukr.oss` header/skin layout `docs/decomp/DC_FORMATS.md:46-64` (`ev_392885a6…`); converted at `app/tools/convert_models.py:43-66,160-183` | Readable bind-pose verts + UVs; bboxes measured Z-up (§2.3); mounted-sid X offsets need donor-bbox centring | included above | T-V72-1 |
| Action ranges / duration metadata for animation timing | **FEASIBLE (metadata only)** | `data\animations\aaf\peaukr.aaf:1-20` (18 actions; `walk 1..20`, `idle 64..113`); decoded `docs/decomp/DC_FORMATS.md:96-109` (`ev_6a6b0380…`); parsed already at `app/tools/bake_sprites.py:105-116` | Plain ASCII; no invention needed for frame ranges/durations | 0.2 d | T-V72-3 |
| Per-instance env scale (trees/rocks/mines) | **FEASIBLE (data wiring)** | `data\game\var\envscales.cfg:25-28` minegold 0.3152; `:43-46` stones 0.329/0.85; `:231-234` pine1 0.475; `:371-374` spruce1 0.5 | Donor constants are readable numbers; translate verbatim into node scale | 0.5 d | T-V72-1 |
| Env LOD / seasonal-material metadata | **FEASIBLE (metadata only)** | `data\objects\env\spruce1.prop:9-18` `LODActorName`, `DefaultMeshName`, `UseableMeshes[0..3]`; `:20+` `materialproperty` | Readable config; donor values can be copied, not guessed. Actual LOD mesh swap is renderer work, not mesh conversion | 1 d | T-V72-1 |
| Scene light/camera constants for the lit 3D view | **FEASIBLE (constants)** | `data\cameras\camera.cfg:32-35` pitch −32°, `:6-10` SphereHeight 58/min 20; `data\env\lights\light.cfg:2-14` ambient/diffuse RGB | Donor pitch/camera/light numbers are now confirmed; donor **yaw** still has no citation (UNVERIFIED) | 0.5 d | T-V72-1 |
| FX source inventory (skirmish) | **FEASIBLE (inventory only)** | `data\pfx\source.pfx:1-18` (`LibManagerName = aspriteblank`, `FrameWidth = 512`, `FrameRate = 10`); `docs/decomp/DC_FORMATS.md:20` marks `.pfx` semantics "Partial" | File exists and parses as text; **behaviour** remains unmapped (see Table B1) | 0.2 d | T-V72-4 |

### Table B1 — UNVERIFIED / BLOCKED because donor data is packed or its semantics unreadable

These are **not** to be filled with invented values or an invented rig under the
governing rule (`WAVE7_3D_VARIANT_CHARTER.md:29-38`). Mark UNVERIFIED in
`docs/variant3d/` until a donor-readable citation appears. (The separate
"readable but not yet converted" backlog is Table B2.)

| Item | Verdict | Donor evidence / gap | What is missing | Effort | Test |
|---|---|---|---|---|---|
| Donor-faithful skinned unit GLB (bone tree + glTF animation) | **BLOCKED / UNVERIFIED** | `.oss` readable (`DC_FORMATS.md:46-64`, `ev_392885a6…`) but contains **flat tracks only** — no parent indices; none in the file read this pass (`data\animations\acl\cannon.acl:1-18`); sibling `.actor`/`.lib` ref chains not traced (UNVERIFIED) | Bone hierarchy; donor→glTF quaternion convention; 483-frame clip size; GLES3 skin perf at 200/552 units (S1 §4.3) | 5–10 d **after** unblock | T-V72-2 |
| ACL clip→playback semantics | **UNVERIFIED** | `data\animations\acl\cannon.acl:1-18` parses (`items[0].AnimationName`, `From`, `global` refurl) but mapping is undocumented; `docs/decomp/DC_FORMATS.md:14` "Partial" | Meaning of `refkey`/`global` chains; currently AAF drives playback instead | 1.5 d (DC T-4) | T-V72-2 |
| FX particle behaviour from `.pfx` | **UNVERIFIED** | `data\pfx\source.pfx:1-18` readable text; `docs/decomp/DC_FORMATS.md:20` "particle semantics unmapped" | How frames/materials map to skirmish FX; no readable mesh | 1–2 d | T-V72-4 |
| Unit/building alpha cut-outs | **BLOCKED in the converted assets** | Converted PNGs forced RGB: 9/9 unit, 14/14 building are IHDR type 2 (§2.3); source DDS would need re-conversion | Donor DDS alpha is documented as garbage (`convert_models.py:144`), so re-conversion may be a no-op — UNVERIFIED | 0.5 d + test | T-V72-1 |
| GLB material `alphaMode` for env foliage | **UNVERIFIED** | Env PNGs are RGBA (93/93, §2.3); donor material intent in `data\materials\**\*.mat` parses only partially (`DC_FORMATS.md:19`) | Exact Blender 5.2 → glTF alpha mapping; no GLB has been produced | 0.5 d | T-V72-1 |

### Table B2 — BLOCKED (backlog, NOT a donor-data gap)

Donor files here are **readable**; the blocker is missing converted assets or a
conversion pass, not packed/unreadable data. Included for completeness of the
singleplayer-skirmish scope.

| Item | Verdict | Donor evidence / gap | Work needed | Effort | Test |
|---|---|---|---|---|---|
| Full donor sid coverage (335 `.oss` / 3,897 `.osm`) | **BLOCKED (near term)** | Donor counts measured §3.1; only 116 sids converted (§2.1); `.oss`/`.osm` layouts fully readable (`DC_FORMATS.md:46-94`) | Generic donor→GLB exporter + curated singleplayer-sid list; disk/memory budget (S3 §5) | 10+ d, curate first | T-V72-5 |
| Naval hulls as GLB meshes | **BLOCKED for skirmish 3D** | No `yacht.obj` among 116; `anim\naval_units\index.json` 7 sheet keys; hull `.osm` readable (`DC_FORMATS.md:66-94`) but unconverted | One converter run + decision whether naval belongs in skirmish scope | 3–5 d | T-V72-5 |
| Construction stages `_s1..s4` / `_dead` GLB | **BLOCKED** | Donor files exist (`bake_sprites.py:584-596` reads `<base><n>.osm` / `<base>_death2.osm`) but no converted sid | Re-convert those donor families | 2–4 d | T-V72-5 |

### Table C — PORT APPROXIMATION only (explicitly NOT donor parity)

Acceptable as pragmatic singleplayer-skirmish substitutes under the owner's
"singleplayer part port for now" instruction, but each must be labelled
**PORT APPROXIMATION** in `docs/variant3d/` and never presented as donor-faithful.

| Approximation | Verdict | Basis (donor-derived inputs) | Non-parity caveat | Effort | Test |
|---|---|---|---|---|---|
| CPU-sampled morph-target poses (`skin`/`qmat` + AAF frames) in a lit 3D scene | **FEASIBLE — PORT APPROXIMATION** | Donor `.oss` verts/weights/tracks + AAF ranges (`DC_FORMATS.md:46-64,96-109`); working port skinner `bake_sprites.py:118-143` | Deformation is decimated pose samples, not the donor runtime skeleton; frame count reduced (12 vs 483) | 2–4 d | T-V72-3 |
| Existing sprite sheets as billboard quads in 3D | **FEASIBLE — PORT APPROXIMATION** | 1,849 baked sheets; 54 land + 7 naval anim keys measured (§2.2) | Fully 2.5D: no real geometry, no continuous yaw, lighting baked into pixels | 0.5–1 d | T-V72-4 |
| Flat/synthetic-root bone tree for a skinned GLB | **NOT APPROVED — invented rig** | No donor parent data (Table B1) | Would be an invented skeleton claimed as donor parity; forbidden by governing rule | — | — |

No row is marked FEASIBLE on the strength of an unrun tool: every feasible row is
gated by a test id in §4.5.

---

## 6. Open questions

0. **Governing-rule constraint:** every 3D decision must cite donor path:line or
   an evidence id (`WAVE7_3D_VARIANT_CHARTER.md:29-38`); anything unreadable stays
   UNVERIFIED. No invented rig/animation value may be presented as donor parity.
   Scope is singleplayer skirmish units/buildings/trees/FX only (`:37-38`).
1. Is there a **donor-readable** bone-parent table anywhere (`.oss` sibling,
   `data\animations\ref\*`, `data\actors\**\*.actor`, `.lib` refkey chain) that
   S4's flat reader ignores? File existence alone is not proof — need the actual
   parent relationships. Without it, skinned-GLB fidelity is UNVERIFIED.
2. Does glTF need the same transposed quaternion as `bake_sprites.qmat` (S5), or
   the textbook convention? No donor citation exists; must be settled by
   T-V72-2 or remain UNVERIFIED — not by reasoning.
3. Reconcile "116 sets" in the owner directive with the measured **54 land + 7
   naval** anim keys: was 116 meant as the static-OBJ count (most likely)?
4. Why are there **0 `alias_of`** records in `land_units/index.json` despite the
   `ALIAS_OF` map in `bake_sprites.py:48`? Regenerated with `--no-alias`?
5. Should unit/building textures be re-converted from donor `.dds` **without**
   `force_opaque`? `convert_models.py:144` says donor alpha is garbage and the
   game draws them opaque; if so, the RGB PNGs are correct and nothing is lost.
6. What `H_target` / `HEIGHT_SCALE` should the 3D mode adopt? Donor metres are
   already 1.9–3.5 m for units, so `s=1.0` may be right; `field`-class ground
   props must be exempt from height normalisation. Donor scale hints are
   readable at `data\game\var\envscales.cfg:25-28,43-46,231-234,371-374` — prefer
   those over a new invented factor.
7. Does yaw need 8 discrete facings in the donor engine, or is S1 C4's
   "renderer transform" inference correct? Donor pitch is now confirmed at
   `data\cameras\camera.cfg:32-35` (−32°), but **yaw has no donor citation yet**.
   If discrete, the morph fallback must bake 8 variants after all (≈8× assets).
8. Can `gl_compatibility` GLES3 skinning actually sustain 200/552 units? Needs a
   windowed benchmark — no such number exists in the repo (S1 C11).
9. Which subset of the 116 sids does the sim actually use per skirmish? Curating
   that list decides whether full donor coverage (class "BLOCKED") is even needed.

---

*V7-2, read-only recon, singleplayer-skirmish scope. No donor file copied or
executed, no Godot or Blender run, no repo file edited other than this report.
Donor-faithful vs PORT APPROXIMATION is separated in §5 Tables A/B1/B2/C per the
governing rule at `WAVE7_3D_VARIANT_CHARTER.md:29-38`.*
