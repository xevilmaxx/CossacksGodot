---
id: Z05
ticket: "HEIGHT WAVE / Z05 — exact minimal relief-prop conversion design (8 donor relief OSMs -> derived port assets)"
agent: "Z05 (read-only design subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_DONOR_COPY__NO_GODOT
scope: "This report is the ONLY repo file written. No source/shader/config/asset/test/JSON/PNG/manifest/CREDITS/donor/queue/git edit. No Godot process, no runner job (submit/cancel/ack/unwedge/reset). Donor install read in place (bytes/latin-1/struct/Pillow); no donor file copied into the repo."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3 (private use, read-only)"
owner_file: docs/terrain_swarm_2026-11-25/reports/Z05_relief_prop_conversion.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58, :122-130). Pixel/visual attribution and runtime selection are INFERRED/UNVERIFIED. NO DONOR PARITY CLAIM."
verdict: "MINIMAL CONVERSION IS ADDITIVE AND SMALL: 3 insertion points in variant3d/tools/convert_models.py (new relief_models() after :496, --include-relief after :508, additive models extension after :523), 4 donor terrainmeshN.osm + 4 terrainmeshN.dds -> 4 derived OBJ/MTL/PNG + 4 appended manifest entries. The 4 terrainplateauN.osm have geometry but NO donor albedo, no .prop and zero pattern.lib BaseName refs -> defer (UNVERIFIED). Z03's 'authored scale 1' needs refinement: donor pattern records carry per-placement Scaling 0.3539..0.6562 (OBSERVED); the OBJ must stay in raw donor units and scale must be applied at placement."
tool_baseline_sha256: 2022DB2A7661944D4FF55256AC38579CC09DA18DE377EB46596AD68FD42E1CBD
---

# Z05 — Exact minimal relief-prop conversion design

> [!IMPORTANT]
> **Labels.** **OBSERVED** = literal donor line / decoded donor byte / direct on-disk
> listing / literal port source line. **DERIVED** = arithmetic or control-flow
> consequence of observed values. **INFERRED** = best reading without a pixel-aligned
> donor A/B. **UNVERIFIED** = not provable with the files/instruments available.
> **PORT APPROXIMATION** = an explicit port substitute, never donor truth. All donor
> paths are under `C:\Games\Cossacks 3\`; all local paths under the repo root. No
> donor binary was executed or copied. **No donor parity claim.**

---

## 0. Mandate and method

Ticket Z05 asks for the **exact minimal conversion plan** that Z03
(`Z03_donor_relief_props.md:155-207`) left as a proposal: which 8 `.osm` files,
exact tool entry-point changes with `file:line`, output OBJ names and manifest
additions, texture conversion for `terrainmesh1..4.dds`, SIZE/scale handling,
and a guarantee that the existing 280 OBJ entries stay byte-identical (additive
only). It also requires license-respecting provenance, validation against donor
bbox/vertex counts, a risk list, and UNVERIFIED labels for engine-side runtime
selection.

Documents read first (all read-only):

| # | Document | What it supplied |
|---|---|---|
| 1 | `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` | standing rules: one Godot owner (G04, `:31`), report root (`:32`), disjoint ownership/backups (`:11-13`) |
| 2 | `docs/terrain_swarm_2026-11-25/CHARTER.md` | observed/inferred/UNVERIFIED separation (`:55-58`), no test weakening, additive discipline, `"donor parity stays UNVERIFIED"` (`:57-58`, `:122-130`) |
| 3 | `docs/terrain_swarm_2026-11-25/reports/Z03_donor_relief_props.md` | two donor relief channels, 8 prop OSMs, blockers B1–B7, proposed path (`:155-207`) |
| 4 | `docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md` | IDP2 prop decode (C9 `:105`), Step 4 bake recipe (`:394-399`), C20 metre-scale gap (`:116`), Q5 engine-side selection (`:444`) |
| 5 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` | `.osm` IDP2/version-8 layout, `ou/ot/of` offsets, `<3f I>` vertex records, winding swap `(0,2,1)` (`:174-243`) |

New direct reads this ticket (read-only, no copies): the 8 relief `.osm` headers
and all vertex/triangle indices; the 8 relevant `.dds` files (dimensions + alpha
histograms); `terrainmesh{1..4}.prop`, `terrainmesh1.actor`,
`actors/actors.lib:1200-1229`, `objects/ref/refmountain.prop`,
`scripts/common.inc/dogenerate.inc:1984-1985`, `pattern.lib` `BaseName` /
`Scaling` records; `variant3d/tools/convert_models.py` (full), both copies'
SHA-256, `variant3d/assets/models/manifest.json`, the OBJ/MTL/PNG/`.import`
directory censuses, `variant3d/scripts/world3d_entities.gd:84-87,391-405,1146-1153,1253-1266`,
`variant3d/CREDITS.md`, `README.md:215-224`, `docs/WAIVERS.md:57-64`.

**No Godot process and no runner job were started** (only G04 may,
`WAVE_G_CHARTER.md:31`). This report is the sole file written.

---

## 1. The eight donor relief OSMs — exact inputs (OBSERVED)

All eight are IDP2 version 8 files under `data/actors/env/`. Header layout is
DEC-04 §4.2 `17×i32` at `0x0`; `ofs_uv=132`, `ofs_tris`, `ofs_frames` at header
ints 12/13/14; vertices are `num_verts × <3f I>` at `ofs_frames+16`; triangles
are `num_tris × <6i>` at `ofs_tris` with the `(0,2,1)` winding swap already
implemented at `convert_models.py:86-89`. Closure
`ou+nu·8 = ot`, `ot+nt·24 = of`, `of+16+nv·16 = filesize` holds **8/8 with zero
slack** (this ticket, fresh decode; matches Z03 §1.2 / DTRN-02 C9).

| # | Donor path (`data/actors/env/`) | Bytes | `nv` | `nu` | `nt` | `nf` | Decoded bbox x / y / z | Convert? |
|---|---|---:|---:|---:|---:|---:|---|---|
| 1 | `terrainmesh1.osm` | 191,356 | 2,662 | 2,662 | 5,305 | 1 | x[−14.0205,13.8877] y[−13.5237,13.4457] z[0.0700,**7.4485**] | **YES** (Tier A) |
| 2 | `terrainmesh2.osm` | 163,452 | 2,272 | 2,273 | 4,532 | 1 | x[−13.2274,13.0921] y[−12.6664,12.9535] z[−0.0251,**8.0346**] | **YES** (Tier A) |
| 3 | `terrainmesh3.osm` | 156,092 | 2,177 | 2,170 | 4,323 | 1 | x[−12.9348,12.9880] y[−12.8390,12.9765] z[0.0106,**9.5503**] | **YES** (Tier A) |
| 4 | `terrainmesh4.osm` | 201,604 | 2,509 | 5,158 | 5,002 | 1 | x[−12.6697,12.6697] y[−12.8276,12.8276] z[0.0125,**6.9330**] | **YES** (Tier A) |
| 5 | `terrainplateau1.osm` | 25,540 | 472 | 472 | 586 | 1 | x[−10.8806,11.3490] y[−12.3489,11.3131] z[−5.3496,5.3496] | **DEFER** (see §1.3) |
| 6 | `terrainplateau2.osm` | 15,788 | 231 | 239 | 418 | 1 | x[−8.7753,8.7753] y[−5.6059,5.6059] z[−0.2393,**10.9325**] | **DEFER** |
| 7 | `terrainplateau3.osm` | 45,340 | 645 | 645 | 1,238 | 1 | x[−4.4927,4.3110] y[−3.5146,3.2364] z[−0.3193,2.8398] | **DEFER** |
| 8 | `terrainplateau4.osm` | 46,444 | 655 | 655 | 1,274 | 1 | x[3.1445,11.0032] y[−3.4613,3.8073] z[−0.5249,4.3355] | **DEFER** |

**Index sanity (OBSERVED, new check this ticket).** `write_obj()`
(`convert_models.py:127-130`) emits face indices verbatim `+1`; a donor index
outside `0..nu-1` would produce an invalid OBJ. Max triangle vertex index < `nv`
and max UV index < `nu` for **8/8** (e.g. `terrainmesh3` `nu=2170 < nv=2177` but
max UV index 2,169; `terrainmesh4` `nu=5158 > nv=2509` but max UV index 2,508).
No reader/writer change is required for the count mismatch — do not "fix" it.

### 1.1 Texture sources (OBSERVED)

`data/materials/env/` contains exactly these albedo candidates (all 5,592,560 B,
Pillow `RGBA` **2048×2048**):

- Summer: `terrainmesh1.dds`, `terrainmesh2.dds`, `terrainmesh3.dds`, `terrainmesh4.dds`
- Winter (already named in `variant3d/assets/terrain/prop_winter_materials.json`):
  `terrainmesh1w.dds` … `terrainmesh4w.dds`
- Desert variants also exist (`terrainmeshdesert1..4.dds`), out of minimal scope.

Alpha is **real, not garbage** (this ticket, Pillow read-only): `terrainmesh1.dds`
alpha extrema `(0,255)` with ~1.68e5/2.62e5/2.56e5 pixels in the lowest three
bins, and similarly broad histograms for mesh2/3/4. Therefore relief entries must
use `force_opaque=False`. In `main()` (`convert_models.py:542-543`) that is
achieved by giving them a `kind` that is **not** `"unit"`/`"building"`
(e.g. `"relief"` or the existing `"env"`). Using `"building"` would flatten
the alpha and is a visual regression; whether the donor shader treats that alpha
as cutout is **UNVERIFIED**.

Material binding is one-to-one and donor-cited:
`data/objects/env/terrainmeshN.prop:14` `Mesh[0].DefaultMaterialName = terrainmeshN`,
`:17` summer `terrainmeshN`, `:18` winter `terrainmeshNw` (same pattern for N=1..4,
read this ticket). Actor binding: `data/actors/env/terrainmeshN.actor:5`
`MeshObjects.LoadFromFile = .\data\actors\env\terrainmeshN.osm`;
`data/actors/actors.lib:1200-1213` registers all four mountain LOD actors and
`:1216-1229` all four plateau LOD actors.

### 1.2 SIZE / scale handling — refinement of Z03 (OBSERVED, new read)

Three distinct donor scale facts must not be conflated:

| Fact | Evidence | Label | Port consequence |
|---|---|---|---|
| `refmountain.prop:45` `ScaleFactor = 1`; `:206-219` `scaleproperty` has `DefaultScale X/Y/Z = 0.5`, `RandomScale = False`, `Min/Max/DefaultScaleFactor = 1` | direct read | **OBSERVED** | Template defaults are not per-placement truth; do not copy the `0.5` into OBJ vertices. |
| `dogenerate.inc:1984-1985`: `if StrExists(basename,'terrainmesh') or StrExists(basename,'stones') then continue` before the random rescale block. | direct read; Z03 §1.2 | **OBSERVED** → **DERIVED** | No *extra random* generator scale. Z03's "authored scale 1" is correct in this narrow sense. |
| **Per-placement authored `Scaling` in `pattern.lib`.** 112 `BaseName = terrainmeshN` records; a 60-line lookahead found a uniform triple `Scaling X=Y=Z` for 89 of them, spanning **0.3538637161 … 0.6562154889** (e.g. `g_mnt_1 → terrainmesh4` at `:338482`, `Scaling` at `:338501-338505` = `0.575703918933868`; `:338874 → terrainmesh3` = `0.51`). | direct read this ticket | **OBSERVED** | **The meshes are placed at non-unit scale.** Z03's phrase "authored scale 1" must be refined: *no random rescale*, but a fixed authored scale per object. |

The same object records carry `Position`, `Direction`, `Up` and `Scaling`
(`pattern.lib:338480-338507`), i.e. full placement transforms. None of these is
exported today: `variant3d/tools/export_donor_patterns.py:139-155` writes only
`w/h/cells`, and `donor_patterns.json` has zero `terrainmesh` strings (Z03 §3).
So the converter must **write raw donor units into the OBJ** (`write_obj()` at
`convert_models.py:123-124` already does; do not apply `Scaling` there), and a
later placement consumer must apply the per-object transform. How the donor
engine consumes `Scaling`/`Direction`/`Up` at runtime is **UNVERIFIED**; any port
pick is PORT APPROXIMATION.

### 1.3 Why only four of the eight are in the minimal change (OBSERVED)

`terrainplateau1..4` fail three independent tests for the existing rule:

1. **No donor albedo.** Recursive scan of `data/materials/**` for `*plateau*`
   returns **zero** files; there is no `terrainplateauN.dds` anywhere. `main()`
   (`convert_models.py:531-533`) would print `MISSING texture` and skip them,
   and `:562` would return exit code 1 (`ok != len(models)`).
2. **No `.prop`.** `data/objects/env/` has `terrainmesh{1..4}.prop` and
   `terrainmeshdesert{1..4}.prop`, but no `terrainplateau*.prop` (Z03 §1.2,
   confirmed by listing this ticket).
3. **No placement link.** `pattern.lib` `BaseName = terrainplateau` count =
   **0** (this ticket) vs 112 for `terrainmesh`.

They are still listed in §1 because they are part of the eight relief OSMs and
their decoded geometry is the validation reference for any later geometry-only
conversion. Converting them would require a **chosen substitute albedo** (a
fabricated mapping) and a placement rule that donor itself does not exercise —
both would be PORT APPROXIMATION and are out of "minimal". **Defer; do not guess.**

---

## 2. Exact tool entry-point changes (`variant3d/tools/convert_models.py`)

**Anchor:** current file SHA-256 `2022DB2A7661944D4FF55256AC38579CC09DA18DE377EB46596AD68FD42E1CBD`,
566 lines. All `file:line` references are to this exact tree; apply by context
if the file drifts.

The other copy, `app/tools/convert_models.py` (368 lines, SHA-256
`D28EAC8E7DD184B2561645DD9CA0087FBD21019DF64B5F66C81601861DB0CEBD`), is a
stale 2D-app duplicate with no `stage_models()`/no output overrides. **Do not
edit it** — 2D `app/` must stay untouched (`CHARTER.md:128`; `E02_final_stage_assets.md:7`).

### 2.1 Root cause restated (OBSERVED)

`read_osm()` at `:74-99` already parses these files (Z03 §4.1 verified all 8).
`write_obj()` `:114-131`, `write_mtl()` `:133-137`, `convert_texture()` `:140-158`
and the manifest loop `:526-557` are format-agnostic. The only gap is
**enumeration**: `main()` at `:519-520` builds `models` from
`unit_models()+building_models()+ship_models()+env_models()`; `env_models()`
(`:412-496`) contains trees/rock/stone/field/decor/gifts and zero relief props.
This is Z03 blocker B1.

### 2.2 Change 1 — new additive table function, insert at `:497`

Insert **between the end of `env_models()` (`:496`) and `def main()` (`:499`)**,
i.e. into the two blank lines at `:497-498`. No existing line is modified:

```python
def relief_models(game: str) -> list:
    """Z05 — additive donor relief-prop table (terrainmesh1..4 only).

    Donor sources (read-only, private use):
      data/actors/env/terrainmeshN.osm      (DEC-04 §4.2 IDP2/version 8)
      data/materials/env/terrainmeshN.dds   (terrainmeshN.prop:14 summer albedo)
    Geometry and pixels are DERIVED by the existing read_osm()/write_obj()/
    convert_texture() path. No donor .osm/.dds is copied into the repo.
    terrainplateau1..4 are deliberately excluded: no donor DDS, no .prop,
    zero pattern.lib BaseName refs (Z05 §1.3). Per-object Scaling/Position/
    Direction are placement data (pattern.lib), NOT mesh data, and belong to a
    later instancing consumer — keep OBJ vertices in raw donor units.
    """
    actors = os.path.join(game, "data", "actors", "env")
    mats = os.path.join(game, "data", "materials", "env")
    table = {
        "terrainmesh1": "terrainmesh1",
        "terrainmesh2": "terrainmesh2",
        "terrainmesh3": "terrainmesh3",
        "terrainmesh4": "terrainmesh4",
    }
    return [{
        "sid": sid, "kind": "relief",
        "mesh": os.path.join(actors, base + ".osm"),
        "texture": os.path.join(mats, base + ".dds"),
        "directions": 1,
    } for sid, base in table.items()]
```

Notes (DERIVED from `:537-539`): no `obj_name`/`tex_name` overrides are needed —
with `sid == "terrainmeshN"` the defaults give OBJ/MTL/PNG basenames equal to the
sid. That matters because the runtime loads by exactly that name
(`world3d_entities.gd:410`, `:1146`, `:1262`); an override would silently break
runtime pickup. `kind="relief"` keeps `force_opaque=False` at `:543`, preserving
the real donor alpha (§1.1).

### 2.3 Change 2 — opt-in flag, insert after `:508`

Insert immediately after the `--include-stages` block (`:505-508`) and before
`args = ap.parse_args()` (`:509`):

```python
    ap.add_argument("--include-relief", action="store_true",
                    help="Z05: also convert the 4 donor terrainmeshN relief props "
                         "(opt-in; the default run stays byte-identical to the "
                         "280-entry base pipeline)")
```

Rationale: mirrors the existing `--include-stages` precedent (`:505-508`,
`:521-523`) and makes the default invocation provably unchanged. This is the
single most important guard for the "byte-identical 280" requirement (§4).

### 2.4 Change 3 — additive extension, insert after `:523`

Leave `:519-520` (`models = (unit_models + building_models + ship_models + env_models)`)
and the whole `--include-stages` block `:521-523` **byte-unchanged**. Insert after
`:523`, before `manifest = {"game": game, "models": []}` at `:524`:

```python
    if args.include_relief:
        # Additive only: relief sids are new; the 280 existing entries keep
        # their sid/obj/mtl/png paths and are emitted in the same order.
        models = models + relief_models(game)
```

Because relief entries are **appended last**, `json.dump(..., indent=2)` at
`:559-560` writes the original 280 entry objects in the same order with the same
field values.

### 2.5 Nothing else changes

Untouched: `read_oss()` `:48-71`, `read_osm()` `:74-99`, `read_mesh()` `:102-107`,
`write_obj()` `:114-131`, `write_mtl()` `:133-137`, `convert_texture()` `:140-158`,
all five existing model tables `:165-496`, resolution/makedirs `:511-517`, the
per-model loop `:526-557`, manifest dump `:559-560`, and exit code `:562`.
No new import is required (`os` is already imported at `:30`).

### 2.6 Invocation (do not run in this ticket; G04 owns Godot, not the converter)

```
python variant3d\tools\convert_models.py --game "C:\Games\Cossacks 3" --out variant3d\assets\models --include-relief
```

Baseline/default invocation (`:14-16`) stays exactly as before and must produce
a byte-identical `manifest.json` (§5 gate G0). Using `COSSACKS3_DIR` instead of
`--game` also remains unchanged (`:35-36`, `:501-503`).

---

## 3. Outputs — exact names and manifest additions (DERIVED from `:537-554`)

For each sid `terrainmeshN` with `N=1..4`:

| Output | Exact path (relative to `variant3d/assets/models/`) | Source |
|---|---|---|
| OBJ | `obj/terrainmeshN.obj` | `write_obj()` `:540`, mesh from donor `.osm` |
| MTL | `obj/terrainmeshN.mtl` (`newmtl model`, `map_Kd ..\tex\terrainmeshN.png`) | `write_mtl()` `:541` |
| PNG | `tex/terrainmeshN.png` (2048² RGBA) | `convert_texture()` `:542-543`, donor `terrainmeshN.dds` |
| Manifest | 1 appended object in `manifest.json:models` | `:548-554` |

No `.dds` file is written into the repo; the PNG is a **derived conversion** of
the donor pixels, not a copy. Godot-side `.import` files for the 4 new OBJs and
4 new PNGs would be generated on the next editor/Godot pass (owned by G04);
**no Godot run occurred in this ticket, so import behaviour is UNVERIFIED**.

Exact appended entry shape (values are the full-precision floats decoded this
ticket; `obj`/`texture_png` are absolute paths because `:549-550` joins the
resolved absolute `out` from `:513`):

```json
{
  "sid": "terrainmesh1",
  "kind": "relief",
  "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\env\\terrainmesh1.osm",
  "texture": "C:\\Games\\Cossacks 3\\data\\materials\\env\\terrainmesh1.dds",
  "directions": 1,
  "obj": "<out>\\obj\\terrainmesh1.obj",
  "texture_png": "<out>\\tex\\terrainmesh1.png",
  "bbox": [-14.020532608032227, 13.887716293334961, -13.523690223693848, 13.445695877075195, 0.07003044337034225, 7.4485321044921875],
  "verts": 2662,
  "faces": 5305
}
```

The other three appended entries use the same shape with these `bbox / verts / faces`:

| sid | bbox `[xmin,xmax,ymin,ymax,zmin,zmax]` | verts | faces |
|---|---|---:|---:|
| `terrainmesh2` | `[-13.227381706237793, 13.092061042785645, -12.666378021240234, 12.953508377075195, -0.025098413228988647, 8.034555435180664]` | 2272 | 4532 |
| `terrainmesh3` | `[-12.934804916381836, 12.987985610961914, -12.839000701904297, 12.97647476196289, 0.010640978813171387, 9.550311088562012]` | 2177 | 4323 |
| `terrainmesh4` | `[-12.669700622558594, 12.66971206665039, -12.827607154846191, 12.82760238647461, 0.012505292892456055, 6.932950973510742]` | 2509 | 5002 |

**Manifest count:** 280 → **284** entries. `obj/` file count 840 → 848
(+4 OBJ +4 MTL). `tex/` 348 → 356 (+4 PNG). These counts assume no separate
winter pass (§8 R5).

**Consumer note (OBSERVED).** `world3d_entities.gd:1146-1153` loads
`res://assets/models/obj/<sid>.obj` and normalises by the manifest bbox
(`"obj_zup_bbox_normalised"`, `:26`), then `_bake_mesh(..., scale, target_h, ...)`.
So an entity spawned by sid would **not** appear at raw donor scale/placement.
A relief-prop placement consumer must therefore either bypass that normalisation
or be written as a dedicated instancing path in `world3d_terrain.gd` (or
`world3d_entities.gd`, contested by M03/P11 — COORD ownership grant required,
Z03 B3). **No such consumer is part of this minimal conversion change.** Adding
the 4 assets is necessary but not sufficient for visible hills; this is the
same distinction Z02 draws between its Stage A/B and Stage C (`Z02_hills_invisible.md:279-295`).

---

## 4. How the existing 280 entries stay byte-identical (additive only)

Four layers of guarantee, all DERIVED from the exact code paths above:

1. **Tables untouched.** `unit_models()` `:165-243`, `building_models()` `:246-297`,
   `ship_models()` `:384-409`, `env_models()` `:412-496`, `stage_models()` `:300-381`
   are not edited. No existing `sid`, mesh path, texture path, `kind` or
   `directions` value changes.
2. **Writers untouched.** `:114-158` produce the same text from the same donor
   bytes for the same sids. No format/rounding change (`v %.6f`, `vt %.6f`, face
   index `+1` at `:123-130`).
3. **Opt-in flag.** Default invocation never calls `relief_models()`; `--include-relief`
   appends **after** `--include-stages` (§2.4), so `--include-stages` behaviour also
   remains byte-identical (both flags together = 280 + 108 + 4 = 392 entries).
4. **Append-only manifest ordering.** `:548-554` builds each entry as `dict(m)`
   and appends; `:559-560` dumps in list order. The 280 original entry objects
   are therefore identical as parsed JSON **and** as serialised text, except that
   the former last entry now ends with `},` instead of `}` (the file necessarily
   grows 4 objects). That comma is the only byte-level difference in the old
   range; no original field is rewritten.

Precise honesty: the *files* `manifest.json` and the 4 new objs/pngs are new/changed;
the 280 `obj/*.obj`, 280 `obj/*.mtl` and 174 `obj`-referenced `tex/*.png` are
rewritten by a converter run but must verify byte-identical (gate G1 below).
`convert_texture()` short-circuits on existing non-empty PNGs when
`force_opaque=False` (`:143-144`), which is the case for all existing `"env"`
entries, so those PNGs are not even re-encoded.

---

## 5. Validation plan (before/after any future implementation)

All checks are static/file-based except where marked; none requires Godot.
Only G04 may run Godot (`WAVE_G_CHARTER.md:31`).

| Gate | Check | Expected / acceptance | Evidence |
|---|---|---|---|
| G0 | Default run (no `--include-relief`), SHA-256 of `manifest.json` | **byte-identical** to pre-change baseline | §2.3, §4.3 |
| G1 | SHA-256 of all 280 existing `obj/*.obj` + 280 `*.mtl` + 174 `tex/*.png` before/after `--include-relief` | every hash equal; 0 changed | §4.2 |
| G2 | Parse `manifest.json` before/after; deep-compare `models[0:280]` | equal field-for-field and in order; `len=284`; new sids exactly `{terrainmesh1..4}`; all appended at indices 280..283 | §3 |
| G3 | Per new OBJ: count `v`, `vt`, `f` lines | equals donor `nv/nu/nt` from §1 table: 2662/2662/5305; 2272/2273/4532; 2177/2170/4323; 2509/5158/5002 | `:123-130`, fresh decode |
| G4 | Per new manifest entry `bbox`/`verts`/`faces` | equals §3 table floats (computed at `:544-553` from the same vertices); z-max ≤ 9.5504 for mesh3, ≤ 8.0346 for mesh2 | §1, §3 |
| G5 | OBJ face index range | all `f` vertex/UV indices within `1..nv`/`1..nu` (already proven on donor indices this ticket, §1) | `:127-130` |
| G6 | Per new PNG | Pillow opens, size `(2048,2048)`, mode `RGBA`, alpha extrema includes 0 and 255, size > 0 | §1.1, `:140-155` |
| G7 | License hygiene | no file named `terrainmesh*.osm` or `terrainmesh*.dds` anywhere under repo; SHA of any new file ≠ donor source SHA; `variant3d/CREDITS.md` contains the new provenance section (§6) | §6 |
| G8 | Exit code / log | converter prints 4 `OK terrainmeshN osm ...` lines and returns 0; no `MISSING ...` line | `:528-533,556-562` |
| G9 | Consumer sanity (static) | repo grep confirms no `.gd` instantiates the new sids yet (expected for this additive-only ticket), so no false "hills now visible" claim | Z03 §3 negative audit |

**Do not** assert visual parity in any gate: no donor GPU A/B frame exists
(`CHARTER.md:57-58`). A later capture (G04 + G05) is required before any claim
about silhouettes.

---

## 6. License and provenance (proposed text, NOT applied)

Governing rules: `README.md:220-224` ("for private use by the game owner only,
on their own machine — never share, publish or redistribute"; "donor code was
only ever read as text; donor binaries were never copied or executed");
`docs/WAIVERS.md:57-64`; `variant3d/CREDITS.md:1-5,98`; `convert_models.py:18-19`
("The donor is private use only — never redistribute it"). Z05 follows the same
pattern as G24's compliance finding (`G24_license_audit.md:34-40`).

**Proposed new section for `variant3d/CREDITS.md`** (to be added by the future
implementation owner, with a backup `inbox/backup/CREDITS.md.bak-Z05` per
`CHARTER.md:66`; **not written by this read-only ticket**):

```markdown
## Relief-prop meshes (derived geometry + pixels, Z05)
- data/actors/env/terrainmesh1.osm .. terrainmesh4.osm ->
  assets/models/obj/terrainmesh1.obj .. terrainmesh4.obj (+ .mtl)
  (DEC-04 §4.2 IDP2/version-8 decode; vertices/faces/UVs only, first frame)
- data/materials/env/terrainmesh1.dds .. terrainmesh4.dds ->
  assets/models/tex/terrainmesh1.png .. terrainmesh4.png
  (2048x2048 RGBA derived by Pillow; donor alpha preserved)
- Placement truth read, not copied: data/objects/env/terrainmeshN.prop,
  data/actors/env/terrainmeshN.actor, data/actors/actors.lib:1200-1213,
  data/pattern/pattern.lib (112 BaseName=terrainmeshN records, per-object
  Scaling/Position/Direction), data/scripts/common.inc/dogenerate.inc:1984-1985.
- Only derived numbers and converted pixels enter the repo. No donor .osm/.dds
  binary is copied, executed or redistributed. Private use only, as above.
- Winter terrainmeshNw.dds and desert terrainmeshdesertN.dds exist in the donor
  but are NOT converted by this step. terrainplateau1..4.osm are NOT converted
  (no donor albedo/.prop/pattern link). Geometry/texture data are donor-derived;
  runtime selection among terrainmeshN is engine-side and UNVERIFIED.
```

No donor bytes, no donor executable and no donor screenshot are embedded in this
report or in the repo. The `C:\Games\Cossacks 3` paths above are references to
the owner's local install only (`docs/WAIVERS.md:59-63`).

---

## 7. Risk list (each with mitigation)

| # | Risk | Evidence / label | Mitigation / gate |
|---|---|---|---|
| R1 | **Runtime selection among multiple `terrainmeshN` in one mountain `Objects` list is engine-side.** Any port choice is PORT APPROX. | Z03 §1.2 `:87`, B4 `:198`; DTRN-02 Q5 `:444`; **UNVERIFIED** | Convert all 4, choose at placement behind an explicit PORT APPROX policy; never claim donor-exact selection; no visual A/B claim. |
| R2 | **Placement `Scaling` is non-unit (0.3539–0.6562) and is NOT in the OBJ.** Applying scale 1 would make props ~1.5–2.8× too large; applying it in `write_obj()` would corrupt the derived asset for other uses. | §1.2, new read; **OBSERVED** values, engine consumption **UNVERIFIED** | Keep raw donor units in OBJ; export `Scaling`/`Position`/`Direction` as *derived* placement data in a later tool; gate with manifest bbox G4 before any instancing. |
| R3 | **Donor metres-per-cell / height unit UNVERIFIED** -> absolute prop-vs-terrain scale cannot be proven. | DTRN-02 C20 `:116`, Z03 §7 Q6 | Do not invent a scale factor; use raw units + authored `Scaling`; label any port mapping PORT APPROX. |
| R4 | **Season materials.** `terrainmeshNw.dds` exists and `.prop:18` selects it in winter; minimal change converts summer only. | §1.1, Z03 B6 `:200` | Keep new sids summer-named; winter needs a second sid/pass (PORT APPROX until selection rule found); document in CREDITS (§6). |
| R5 | **Plateau props unplaceable by the same rule** (no albedo, no `.prop`, zero `BaseName` refs). | §1.3; Z03 B5 `:199` | Defer; do not fabricate an albedo mapping or a placement rule. |
| R6 | **z-up → y-up orientation.** OBJ vertex Z is donor height; the entity renderer relabels/normalises (`world3d_entities.gd:26,1146-1153`). A generic sid spawn will ground/scale the mesh, not place it at authored transform. | OBSERVED (port), visual effect **UNVERIFIED** | Use a dedicated instancing consumer; verify bbox axis order at G4; no capture-based claim. |
| R7 | **`nu != nv`** for mesh2/3/4; a naive "fix" could break the valid indices. | §1 (index sanity), **OBSERVED** | Leave `write_obj()` as-is; gate G5. |
| R8 | **Alpha semantics.** Donor alpha is real (extrema 0..255); flattening it or assuming cutout are both unverified visual choices. | §1.1; **OBSERVED** bytes, shader use **UNVERIFIED** | `kind="relief"` → `force_opaque=False` (§2.2); gate G6; do not claim cutout parity. |
| R9 | **Full converter re-run rewrites 280 OBJs.** If the donor install changed or Pillow changed, bytes could drift. | `:526-557`; CHARTER no-test-weakening/byte identity | Default-run gate G0 + per-file SHA gate G1 before and after; abort on any mismatch. |
| R10 | **Draw-call / ownership cost.** 4 props add instances; `world3d_entities.gd` is contested by M03/P11. | Z03 B3 `:197`, P02/P11 | Asset conversion only; no instancing code here; COORD grants ownership before any consumer edit; measure later. |
| R11 | **`.import` files for new assets.** Godot normally generates them; none exists now. | obj census 280 `*.obj.import`, tex 174 `*.png.import`; **UNVERIFIED** until a Godot pass | Do not hand-author `.import`; let G04's next Godot run generate them; verify in that gate. |
| R12 | **Stale second converter copy.** `app/tools/convert_models.py` lacks the relief table and overrides; editing it would touch 2D app. | §2 preamble, SHA-256s | Explicitly excluded; 2D `app/` stays untouched. |

---

## 8. UNVERIFIED register (do not guess)

1. Which `terrainmeshN` a given mountain stamp selects at runtime; no plaintext
   consumer (Z03 §7 Q2, DTRN-02 Q5).
2. Whether the donor engine applies `pattern.lib` `Scaling` exactly as written,
   and in which space (local/global), for these props.
3. Donor metres-per-cell / height unit (DTRN-02 C20) — blocks absolute scale claims.
4. Whether donor treats the terrainmesh DDS alpha as cutout or opaque.
5. Winter/desert material selection for relief props if converted later.
6. `terrainplateau1..4` authoring/placement (no `.prop`, no `BaseName` refs).
7. Whether any of the two reference screenshots actually contains a converted
   prop pixel — pixel-to-object attribution needs a donor GPU A/B; none exists.
8. Godot `.import` generation and any visual result for the new OBJs/PNGs (no
   Godot run in this ticket; only G04 may run it).
9. Whether a 64² seed in the port even has a mountain stamp at which a prop
   could be placed (Z03 B7; `Z02_hills_invisible.md:293-295`).
10. Effect of the converter's `%.6f` vertex rounding on sub-micrometre bbox
    values in the manifest (manifest keeps full floats at `:551`; OBJ text is
    6-decimal) — both are derived, but only one is exact; validate with tolerance
    1e-6 on OBJ text, exact on manifest.

---

## 9. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Exactly 8 donor relief OSMs: 4 `terrainmeshN` + 4 `terrainplateauN`, all IDP2 v8, exact closure 8/8 | §1 table, fresh decode | **OBSERVED** |
| 2 | Only `terrainmesh1..4` have matching donor albedo DDS; plateaus have none anywhere under `data/materials` | §1.1, §1.3 | **OBSERVED** (negative) |
| 3 | Minimal conversion = 3 insertions in `convert_models.py` (`:497`, `:508`, `:523`), no other line changed | §2 | **DERIVED** from exact source |
| 4 | Outputs = 4 OBJ + 4 MTL + 4 PNG + 4 appended manifest entries; names equal sids | §3 | **DERIVED** from `:537-554` |
| 5 | Existing 280 entries stay byte-identical under default run; with opt-in, entry objects unchanged and appended at 280..283 | §4 | **DERIVED**; verify G0/G1/G2 |
| 6 | Donor prop placement carries non-unit per-object `Scaling` (89 records, 0.3539–0.6562); Z03's "scale 1" = no random rescale only | §1.2 | **OBSERVED** values; engine use **UNVERIFIED** |
| 7 | Runtime selection among `terrainmeshN` is engine-side | DTRN-02 Q5, Z03 B4 | **UNVERIFIED** |
| 8 | No donor binary copied/executed; provenance to be added to `variant3d/CREDITS.md` | §6, scope | **OBSERVED** (this ticket) / proposed |
| 9 | Adding assets alone does not create visible hills; an instancing consumer is a separate step | §3 consumer note, Z02 §4.4 | **DERIVED** (port control flow); visual **UNVERIFIED** |
| 10 | Donor `.osm` first-frame decode is sufficient — `nf=1` for all 8, no extra frames | §1 table (`nf=1`, `extra=0`) | **OBSERVED**; refines DEC-04's "130/3,897 have extra frames" |

---

## 10. Summary — direct answers

- **Which 8 OSMs:** `data/actors/env/terrainmesh{1,2,3,4}.osm` (convert; 2,177–2,662 verts,
  4,323–5,305 faces, z-max 6.93–9.55) and `data/actors/env/terrainplateau{1,2,3,4}.osm`
  (deferred: no donor albedo, no `.prop`, zero `pattern.lib` `BaseName` refs).
  Exact bboxes and counts are in §1.
- **Exact tool changes:** insert `relief_models()` at `convert_models.py:497`
  (new 4-row table, `kind="relief"`); insert `--include-relief` argparse at `:508`;
  insert additive `if args.include_relief: models = models + relief_models(game)`
  at `:523`. Nothing else in the 566-line file changes (SHA-256 anchor in frontmatter).
  Do not edit `app/tools/convert_models.py`.
- **Outputs:** `variant3d/assets/models/obj/terrainmeshN.{obj,mtl}`,
  `tex/terrainmeshN.png` (2048² RGBA, alpha preserved), and 4 appended
  `manifest.json` entries with full-precision donor bboxes (§3). No donor
  `.osm`/`.dds` in the repo.
- **Texture conversion:** `data/materials/env/terrainmeshN.dds` via the existing
  `convert_texture()` with `force_opaque=False`; winter `terrainmeshNw.dds`
  deliberately out of minimal scope (documented).
- **SIZE/scale:** write raw donor units into OBJ; no random generator rescale
  (`dogenerate.inc:1984-1985`); per-object authored `Scaling` (0.3539–0.6562,
  `pattern.lib`) must be applied by a later placement consumer, never baked into
  the OBJ. Donor metres-per-cell **UNVERIFIED**.
- **Byte-identical 280:** untouched tables + untouched writers + opt-in flag +
  append-only manifest; enforce with G0 (default manifest hash), G1 (per-file
  SHA of all 280 existing assets), G2 (first 280 manifest entries deep-equal).
- **License:** derived geometry/pixels only; new `variant3d/CREDITS.md` section
  (§6) citing donor paths and stating private-use/no-copy; no donor binary copied
  or executed.
- **Validation / risk / UNVERIFIED:** §5 gates G0–G9, §7 risks R1–R12, §8 items
  1–10. No donor parity claim; no Godot run; no runner job; this report is the
  sole file written.

*End of Z05. Read-only; one report; no runner job; no donor file copied or run;
no code, asset, config, test, manifest or CREDITS edit; no donor parity claim.*
