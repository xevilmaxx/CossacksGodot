---
id: FOLD-05
ticket: "ASSET ORGANIZATION FOLD-05 — extend per-nation organization to ALL five asset folders"
title: "FOLD-05 — one classification rule for obj/tex/skin/sprites/sprites_hi, index rewrites, and a reversible 5-folder migration"
owner: FOLD-05 subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_MOVES__NO_EDITS__NO_RUNNER__NO_GODOT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, FOLD_01_folder_split.md, FOLD_04_anim_usage.md, N07_all_nations_assets.md, C01_metric_tool.md, CREDITS.md]
scope: "Only this report is written. No file moved/copied/deleted; no .gd/.py/.json/.import/.mtl edited; no Godot launched; no runner job; no donor file copied."
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58,122-130). Folder layout is organization only; visual/donor parity stays UNVERIFIED."
note_on_priors: "FOLD_02_path_audit.md and C01_asset_impl.md are NOT on disk at write time; see §1.2. FOLD_01 (obj only) and FOLD_04 landed this session and are incorporated."
---

# FOLD-05 — per-nation organization across all five model folders (read-only)

> [!IMPORTANT]
> **Labels.** **OBSERVED** = literal file:line, on-disk count or decoded byte read
> this pass. **DERIVED** = deterministic consequence of observed code/data.
> **INFERRED** = reasonable reading without an engine run. **UNVERIFIED** =
> needs a Godot import/gate run (G04 only, WAVE_G_CHARTER.md:31). No donor
> parity claim anywhere. FOLD-01's obj-only plan is the baseline; this report
> **extends** it, does not replace its loader/resolver design.

## 0. Direct answer

1. **One rule, five folders (DERIVED).** Classify every sid by
   `(manifest kind, explicit nation allow-list)` into
   `<root>/<nation>/{buildings,land_units,naval_units}/` or
   `<root>/shared/{buildings,land_units,naval_units,terrain}/`, then apply the
   **same relative bucket path** inside `obj/`, `tex/`, `skin/`, `sprites/`
   and `sprites_hi/`. Paths stay **sid-based for obj/skin/sprites** and
   **texture-basename-based for tex** (stage sids reuse a base texture).
   Full rule §3; worked partition §3.3.
2. **Relief props and FX/decals → a new `shared/terrain/` bucket, NOT
   `shared/buildings` (DERIVED decision).** All 93 `env` + 4 `relief` sids
   (97) are terrain adornments; the field decals already live outside the
   models tree under `assets/terrain/deco_png/`. `shared/terrain/` keeps them
   semantically honest and resolves FOLD-01 §5 open question 1 by merging
   FOLD-01's proposed `shared/env` + `shared/relief` into one bucket.
   Mines stay in `shared/buildings` because the manifest says `kind=building`.
3. **Index rewrites are small but mandatory (OBSERVED).** `manifest.json`: add a
   per-entry `assets` res:// map (FOLD-01 §6), keep all 299 existing fields
   byte-identical; **do not** use `obj`/`texture_png` as the source of truth —
   all 299 are absolute OS paths into the *flat* tree and break on move.
   `skin/index.json`: stay at `skin/` root, rewrite only the 66
   `entries[].file` values to bucket-relative strings (no `anim3d.gd` code
   change). **There is no sprite index** (OBSERVED): sprite paths are 100%
   code-composed in `world.gd:399,407,411-413`; extend the same manifest
   `assets` map with `sprite`/`sprite_hi` keys and add one manifest read to
   `world.gd`, or add a new `sprites/index.json` — recommendation §4.3.
4. **All five folders must be copied, never moved in place (DERIVED, with an
   OBSERVED hardlink hazard).** `variant3d/assets/models/sprites/*.png` and
   `sprites_hi/*.png` are **NTFS hardlinks** to `app/assets/models/{sprites,
   sprites_hi}/` (verified `fsutil hardlink list` for `aca.png` and
   `rock_sea1.png`). Copy bytes; never edit a hardlinked PNG in place. `.gdignore`
   and `.import` sidecars are variant-only.
5. **Reversible sequence (INFERRED procedure, OBSERVED precedent):** freeze →
   plan → copy/backup → per-folder copy+verify+switch (obj → tex → skin →
   sprites → sprites_hi) → G04-only reimport + gates → move originals aside
   to a dated backup → one-gate-cycle observation → undo log rollback.
   No deletion at any step. §6.
6. **Blocking hard-coded paths are enumerated in §5** (runtime, offline tools,
   sidecars, MTL, docs). The single most dangerous one is
   `_nation_mesh_on_disk()` at `world3d_entities.gd:718-722`: with nation OBJs
   in subfolders it probes the old flat path, reports `exact=false`, and
   silently falls back to Ukrainian art. It must use the resolver first.
7. **UNVERIFIED:** Godot's handling of depth-rewritten MTL `map_Kd`, sidecar
   hash rewrites, whether the 19 C01-ASSET assets are imported at all (no
   `.import` sidecars), and any scene/UID reference outside our code. No run
   was performed.

---

## 1. What landed, what did not, and what changed under this report

### 1.1 Current on-disk state (all OBSERVED this pass)

`variant3d/assets/models/`:

| Folder | Files | Breakdown | Notes |
|---|---|---|---|
| `manifest.json` | 1 (235,476 B) | 299 entries; `kind` = building 129, unit 73, relief 4, env 93 | LastWriteTime 3:58:15 PM; all 299 `obj` + 299 `texture_png` are absolute OS paths into the flat tree |
| `obj/` | 878 | 299 `.obj`, 299 `.mtl`, 280 `.obj.import` | 19 new C01-ASSET OBJs have **no** sidecar |
| `tex/` | 367 | 193 `.png`, 174 `.png.import` | 192 unique manifest texture basenames + `mill_rotor.png`; 19 new C01 PNGs have no sidecar |
| `skin/` | 67 | 66 `.json` + `index.json` | index: `count=66`, 7 skipped ships, 0 failed; `entries[].file` are bare filenames |
| `sprites/` | 359 | 179 `.png`, 179 `.png.import`, `.gdignore` | PNGs are hardlinks to `app/assets/models/sprites/`; no index file |
| `sprites_hi/` | 181 | 90 `.png`, 90 `.png.import`, `.gdignore` | PNGs hardlinked to `app/assets/models/sprites_hi/` |
| `anim/` | 3,706 | already `<nation|common>/<kind>` | FOLD-04: **cannot be emptied**; unchanged by this plan |
| `glb/` | **absent** | code probes it | mirror the bucket tree if V7-8 lands |

### 1.2 Missing priors — handled explicitly, not silently

- `FOLD_02_path_audit.md` — **not landed** at write time (reports dir lists only
  `FOLD_01_folder_split.md` and `FOLD_04_anim_usage.md`). FOLD-05 therefore
  **re-derived** the "manifest-driven vs code-composed" distinction directly
  from source (§2). Result agrees with FOLD-01 §2/§6: the manifest's
  `obj`/`texture_png` fields are **never read by runtime loaders**; paths are
  composed in GDScript. If FOLD-02 lands with a contradicting fact, §2/§4 must
  be re-checked before apply.
- `C01_asset_impl.md` — **not landed under that name**. The only `C01_*` report
  is `C01_metric_tool.md` (a different, tool-only ticket). C01-ASSET itself
  *has* landed as uncommitted edits: `inbox/backup/{manifest.json,index.json,
  convert_models.py,convert_skins.py,CREDITS.md}.bak-C01ASSET` and 19 new
  manifest entries (§1.3). FOLD-05 uses the on-disk result as the authority.
- **Stale FOLD-01 fact (OBSERVED, superseded).** FOLD-01 §1.4/R7 reports the 19
  new entries pointing at `...\Temp\opencode\c01as_stage\...`. Current bytes
  show **all 299** `obj` and `texture_png` fields already normalized to
  `...\variant3d\assets\models\{obj,tex}\<sid>.*`. The staging-path warning is
  therefore stale, but its conclusion is **stronger**: every one of the 299
  absolute paths breaks on a folder move, so they must not drive runtime.

### 1.3 C01-ASSET additions to classify (OBSERVED vs backup)

19 manifest entries added relative to `manifest.json.bak-C01ASSET` (280 → 299),
none removed:

| Class | Sids | Folder bucket |
|---|---|---|
| Nation halls | `ruscen bavcen polcen swecen` | `<nat>/buildings` |
| Peasants | `pearus peaukr peapol peaaus peaeng peaspa peatur peasco` | `<nat>/land_units` for `pearus/peaukr/peapol/peasco`; `shared/land_units` for the four multi-nation forms |
| Signature units | `pikemanrus musketeer18bav pikeman18swe` | `<nat>/land_units` |
| Relief props | `terrainmesh1..4` | `shared/terrain` |

Plus skin JSONs for the 11 new unit sids (`skin/index.json count=66` vs 55
pre-C01) and env/relief props converted earlier by Z05 (trees, rocks, bushes,
reeds, ferns, gifts, `field`) — all `kind=env` → `shared/terrain`.

---

## 2. Manifest-driven vs code-composed — re-derived (OBSERVED)

| Reader | What it reads | Path source |
|---|---|---|
| `world3d_entities.gd:421-435` | `manifest.json` **only** `sid`, `bbox`, `texture` (donor DDS) | **`assets`/`res` map absent today** |
| `world3d_entities.gd:84-87` | `OBJ_DIR`, `GLB_DIR`, `TEX_DIR`, `MANIFEST_PATH` | **code-composed** |
| `world3d_entities.gd:440,444,449-450,458-460,614,721,1023-1024,1172,1184,1300,1909` | `OBJ_DIR+sid+".obj"`, `TEX_DIR+sid+".png"`, etc. | **code-composed** |
| `world3d_entities.gd:718-722` | exact-nation mesh probe | **code-composed flat** (critical, §5) |
| `anim3d.gd:112-113,825-828` | `skin/index.json` `entries[].file` → `SKIN_ASSET_DIR + file` | **manifest-driven** (bare filename, no subfolder today) |
| `world.gd:399,407,411-413` | `sprites/<key>_<000..315>.png`, `sprites_hi/<key>.png`, `sprites/<key>.png` | **code-composed** |
| `world3d_fx.gd:678-680` | ghost standalone fallback | **code-composed flat** |
| `tools/render_models.py:397-408` | manifest `obj`/`texture_png` absolute paths | **manifest-driven (absolute OS)** — breaks for all 299 on move |

**DERIVED consequence.** A raw folder move with no code/index change produces:
proxy boxes (`donor_bbox_proxy`) instead of meshes, false nation fallbacks,
missing skins, blank 2D sprites, and broken offline render tooling. The
migration must be **resolver-first, physical move second** (FOLD-01 §6,
extended to `sprite`/`sprite_hi` in §4.3).

---

## 3. One classification rule for all five folders

### 3.1 Rule (DERIVED proposal; deterministic, allow-list not regex)

```
classify(sid, manifest_kind):                 # sid = manifest sid OR sprite key
    if sid in NAVAL_SIDS:              kind = "naval_units"
    elif manifest_kind == "building":  kind = "buildings"
    elif manifest_kind == "unit":      kind = "land_units"
    elif manifest_kind in ("relief","env"):
                                       kind = "terrain"          # NEW shared bucket
    nation = NATION_SID.get(sid, "")
    if nation == "" or sid in SHARED_MULTINATION or sid in SHARED_BY_ALIAS:
                                       nation = "shared"
    bucket = nation + "/" + kind

# tex is the ONLY exception: use basename(manifest[sid].texture_png)
# to find the owning sid, then reuse that sid's bucket. Never use sid as
# the tex filename (stage sids such as cen1 reuse cen.png).
```

- `NAVAL_SIDS` (OBSERVED `data.gd`, FOLD-01 §4.1): `yacht fishboat yachttur
  galley frigate xebec battleship`. `yachttur` is a distinct identity sid, not
  a Turkey skin (N07 §4.3) → `shared/naval_units` (INFERRED, conservative).
- `SHARED_MULTINATION` (DERIVED from N07 §4.1/§4.4): `peaaus peaeng peaspa
  peatur peasant pope mullah bagpiper` — `peaaus` serves aus/pru/bav/sax/swi,
  `peaeng` fra/eng/swe/den/net, `peaspa` spa/ven/por/pie, `peatur` tur/alg.
  Do **not** use a `pea*` prefix rule: `pearus/peaukr/peapol/peasco` are
  nation-specific.
- `NATION_SID` explicit allow-list — **37 sids**, copied from FOLD-01 §4 and
  verified present in the current manifest this pass:

| Nation | Sids |
|---|---|
| rus | `ruscen pearus pikemanrus strelet vityaz cossackdon` (6) |
| bav | `bavcen musketeer18bav` (2) |
| pol | `polcen peapol wingedhussar` (3) |
| swe | `swecen pikeman18swe hackapell` (3) |
| ukr | `peaukr serdiuk hetman cossackregister` (4) |
| sco | `peasco sco_highlandersword pikemansco swordsmansco musketeersco archersco officersco lancersco raidersco` (9) |
| tur | `jannisary sipahi spakh tatar` (4) |
| alg | `mameluke` (1) |
| aus | `croat pandur` (2) |
| fra | `chasseur` (1) |
| eng | `highlander` (1) |
| pie | `padre` (1) |

- `SHARED_BY_ALIAS` (sprite folder only, OBSERVED `world.gd:212-214`):
  `SPRITE_ALIAS` maps `musk18→serdiuk`, `grenadier→roundshier`,
  `officer18→officer`, `drummer→officer`, `priest→officer`,
  `howitzer→cannon`, `mortar→cannon`. Classify by the **resolved sprite key**,
  so `serdiuk_000.png` sits in `ukr/land_units` even though other sim sids
  borrow it. Keep the alias behavior unchanged; label the borrowing as an
  alias-pair caveat (INFERRED; dedupe is an owner decision, not this ticket).

**Why an allow-list:** `sco_highlandersword` (prefix-like but a roster key),
`serdiuk`/`strelet`/`mameluke` (nation-specific with no prefix), and
`peatur` (nation-looking prefix but multi-nation) defeat any prefix regex
(FOLD-01 §4; N07 §4.2/§6).

### 3.2 Decision — relief props, decor and FX/decals

**Decision: `shared/terrain/` (DERIVED, resolves FOLD-01 §5/Q1).**

- Contents: 93 `kind=env` decor/props (trees, rocks, bushes, flowers,
  plantain, reeds, ferns, gifts, `christmastree*`, `field`, `stone`, `rock`)
  + 4 `kind=relief` (`terrainmesh1..4`) = **97 sids**.
- FX/decals: `FIELD_DECAL_SUMMER/WINTER` at
  `res://assets/terrain/deco_png/envfieldd.png` / `envfielddw.png`
  (`world3d_entities.gd:290-291`, OBSERVED) already live under the terrain
  module, **outside** the models tree. **Leave them there** for this tranche;
  if a future owner consolidates them into models, the target is
  `shared/terrain/fx_decals/`, never `shared/buildings/`.
- Rejected `shared/buildings`: it would mix 97 terrain adornments with the
  125 building sids and contradict the donor's env-keyed provenance
  (N07 §3.1 mines are the only env-like assets that ARE buildings).
- This **supersedes** FOLD-01's two-bucket `shared/env` + `shared/relief`
  proposal with one bucket, and keeps `anim/` untouched (FOLD-04:
  live 3D consumers, hardlinked bake PNGs, cannot be emptied).

### 3.3 Resulting partition (DERIVED, recomputed this pass)

| Bucket | sids | Applies to |
|---|---|---|
| `<nat>/buildings` | 4 | `ruscen bavcen polcen swecen` |
| `<nat>/land_units` | 33 | allow-list units (peasants + signatures + nation-unique) |
| `shared/buildings` | 125 | 17 core + 108 stage/scaffold + 3 mines |
| `shared/land_units` | 33 | generic roster + 4 multi-nation peasants + `peasant`, `pope`, `mullah`, `bagpiper` |
| `shared/naval_units` | 7 | ship hulls |
| `shared/terrain` | 97 | 93 env + 4 relief |
| **Total** | **299** | 37 nation + 262 shared |

> **Arithmetic note (OBSERVED).** FOLD-01 §0/§4.1 headline says "38 nation /
> 261 shared". Its own per-bucket table and this independent recomputation
> give **37 nation / 262 shared** (4+33=37; 125+33+7+93+4=262; sum 299).
> Use 37/262 in plan/gate assertions; do not assert 38/261.

Per-folder application:

| Folder | What lands there | Counts |
|---|---|---|
| `obj/` | `<sid>.obj` + `<sid>.mtl` + `<sid>.obj.import` in the bucket | 299 triads (280 sidecars; 19 to generate) |
| `tex/` | `<texture_basename>.png` + `.import` in the **owning sid's** bucket | 192 unique + `mill_rotor.png` (→ `shared/buildings`, explicit) |
| `skin/` | `<sid>.json` in the owning bucket; `index.json` stays at root | 66 skins; no building/naval/terrain skins |
| `sprites/` | `<key>_<000..315>.png` (+ `.import`) in key's bucket | 179 PNG sets (8-direction units + single-frame buildings/env) |
| `sprites_hi/` | `<key>.png` (+ `.import`) in key's bucket | 90 env hi-res PNGs |

`mill_rotor.png` is the only disk tex without a manifest entry (FOLD-01 R12).
Decision: classify it explicitly as `shared/buildings/mill_rotor.png` and
update `ROTOR_TEX_IMPORT_PATH` (`world3d_entities.gd:248`); leave
`ROTOR_TEX_PATH` / `ROTOR_META_PATH` (`:242,:249`) pointing at `anim/` unchanged
(FOLD-04 live fallback). Alternative: leave it flat — but then the ticket's
"all five folders" is not fully satisfied. Flag to owner (§7).

---

## 4. Exact index / manifest rewrites

### 4.1 `manifest.json` — additive `assets` map (FOLD-01 §6, extended)

Add one field per entry; **all 299 original fields stay byte-identical**
(including the now-normalized absolute `obj`/`texture_png`, which the resolver
must ignore):

```json
{
  "sid": "ruscen",
  "kind": "building",
  "assets": {
    "obj":   "res://assets/models/rus/buildings/ruscen.obj",
    "tex":   "res://assets/models/rus/buildings/ruscen.png",
    "skin":  "res://assets/models/rus/land_units/pearus.json",
    "sprite":    "res://assets/models/shared/buildings/cen.png",
    "sprite_hi": "res://assets/models/shared/terrain/rock_sea1.png"
  },
  "...": "sid/kind/mesh/texture/directions/obj/texture_png/bbox/verts/faces unchanged"
}
```

Notes: `skin`, `sprite`, `sprite_hi` are emitted only where that sid has such
an asset. `sprite` values use the **alias-resolved key** (§3.1). Stage/scaffold
sids inherit the parent bucket; `obj` paths for `<sid>1..4`/`<sid>a` are derived
by basename + suffix (FOLD-01 §6 helper), not by extra fields per stage.

### 4.2 `skin/index.json` — rewrite 66 `file` strings; index stays at root

`anim3d.gd:112-113,825-828` concatenates `SKIN_ASSET_DIR + file_name`, so a
bucket-relative string works with **zero code change**:

| sid | old `file` | new `file` |
|---|---|---|
| `pearus` | `"pearus.json"` | `"rus/land_units/pearus.json"` |
| `peaukr` | `"peaukr.json"` | `"ukr/land_units/peaukr.json"` |
| `peaaus` | `"peaaus.json"` | `"shared/land_units/peaaus.json"` |
| `pikemanrus` | `"pikemanrus.json"` | `"rus/land_units/pikemanrus.json"` |
| `musketeer18bav` | `"musketeer18bav.json"` | `"bav/land_units/musketeer18bav.json"` |
| `pikeman18swe` | `"pikeman18swe.json"` | `"swe/land_units/pikeman18swe.json"` |
| `peasant` | `"peasant.json"` | `"shared/land_units/peasant.json"` |

Update the `coord` doc string (currently
`assets/models/obj/<sid>.obj vertex i`) in the index and the 66 skin JSONs as
a separate doc pass; it is a label, not a loader input. `schema`, `count`,
`entries[].bytes`, AAF `frames`, `k`, `fps`, `bones`, `v` stay unchanged.

### 4.3 Sprite index — none exists; choose one owner of truth (DERIVED)

**OBSERVED:** no sprite index anywhere under `assets/models` (only
`anim/land_units/index.json`, `anim/naval_units/index.json` and
`skin/index.json`). Sprite paths are built in `world.gd:399,407,411-413`
against a fixed flat root; `SPRITE_ALIAS` (`:212-214`) and `_env_sids()`
(`:357-369`) enumerate the keys.

**Recommendation:** extend the **same** manifest `assets` map with `sprite`
and `sprite_hi` keys (§4.1) and add one `manifest.json` read to `world.gd`
(e.g. `SPRITE_MANIFEST_PATH` + a `_res_for_sprite(key, hi)` helper with a
legacy flat fallback). Reuse the resolver shape from FOLD-01 §6 so all five
folders have a single source of truth and staged switching.

**Rejected alternative:** a new `sprites/index.json` mapping
`key → {low, hi}`. It would duplicate the manifest and drift as C01 adds sids,
but it is a valid fallback if `world.gd` ownership cannot be granted (it is a
2D-branch file, `main.gd:590-593`; FOLD-04 §2). If chosen, the index must
contain all 179 low + 90 hi keys with bucket-relative paths and `world.gd`
must load it once. **UNVERIFIED** which owner grants the `world.gd` edit.

---

## 5. Hard-coded paths that break (flag list)

All rows **OBSERVED** unless the last column says UNVERIFIED. "Fix" = use the
§4 resolver/map; keep the old path only as a legacy fallback until switch.

### 5.1 3D runtime (highest risk)

| File:line | Hard-coded value | Effect of move / fix |
|---|---|---|
| `world3d_entities.gd:84-87` | `OBJ_DIR`, `GLB_DIR`, `TEX_DIR`, `MANIFEST_PATH` consts | Keep as fallback; add resolver |
| `:421-435` | manifest loop reads only `bbox`/`texture` | Natural home for `_asset_paths` map |
| `:438-445` | `ResourceLoader.exists(OBJ_DIR+sid+".obj")` / GLB telemetry | `obj_available` drops → use resolver |
| `:449-450` | tree pool needs OBJ **and** `TEX_DIR+sid+".png"` | both sides must resolve |
| `:456-460` | stage probes `OBJ_DIR+s+"1.obj"`, `"a.obj"` | suffix-aware resolver |
| `:471-473` | stats strings `obj_dir`,`glb_dir`,`tex_dir` | label update only |
| `:614`, `:1023-1024` | `TEX_DIR+sid+".png"` albedo | resolver (tex) |
| **`:718-722` `_nation_mesh_on_disk()`** | flat `OBJ_DIR+sid+".obj"` / GLB | **critical**: exact-nation probe fails → `exact=false`, `:819/:1729-1740` emits false fallback, Ukrainian mesh reused (`:209,:216`). Fix first. |
| `:1172-1188` `_mesh_info()` | GLB then `load(OBJ_DIR+sid+".obj")` | resolver; else `donor_bbox_proxy` |
| `:1300-1304` `_load_obj_topology()` | `FileAccess.open(OBJ_DIR+sid+".obj")` | resolver; morph indexing breaks |
| `:242` | `ROTOR_TEX_PATH = res://assets/models/anim/common/buildings/mill_rotor.png` | leave anim/ unchanged (FOLD-04) |
| `:248` | `ROTOR_TEX_IMPORT_PATH = res://assets/models/tex/mill_rotor.png` | breaks if mill_rotor moves to `shared/buildings/` → update |
| `:249` | `ROTOR_META_PATH = .../anim/buildings/mill_rotor.json` | unchanged |
| `:1812`, `:1861-1862` | rotor consumers of above consts | inherited |
| `:1902-1911` `_stage_mesh_info()` | `OBJ_DIR+sid+suffix+…`, bbox from manifest `art_sid` | suffix + bucket-aware resolver |
| `:488,:506-517,:209,:216` | status/provenance strings naming flat paths | stale text; doc pass |

### 5.2 Other runtime readers

| File:line | Hard-coded value | Effect / fix |
|---|---|---|
| `world3d_fx.gd:678-680` | `res://assets/models/obj/<sid>.obj`, `/glb/<sid>.glb`, `/obj/<sid>4.obj` | ghost standalone fallback misses → same resolver or delegate to provider |
| `anim3d.gd:112-113` | `SKIN_INDEX_PATH`, `SKIN_ASSET_DIR` | index must stay at `skin/` root; code unchanged |
| `anim3d.gd:825-828` | `SKIN_ASSET_DIR + entries[].file` | manifest-driven; rewrite 66 `file` strings (§4.2) |
| `anim3d.gd:106`, `convert_skins.py:64`, skin `coord` strings | doc text `assets/models/obj/<sid>.obj` | stale labels only |
| **`world.gd:399`** | `res://assets/models/sprites/%s_%03d.png` | all 8-direction sprites vanish in 2D mode → sprite resolver |
| **`world.gd:407,411`** | `res://assets/models/sprites_hi/%s.png` | hi-res env sprites vanish → sprite resolver |
| **`world.gd:412-413`** | `res://assets/models/sprites/%s.png` | low-res fallback vanishes → sprite resolver |
| `world.gd:371-380` `_load_env_tex()` | uses `ProjectSettings.globalize_path(path)` + `Image.load_from_file` | new `res://` paths must exist on disk in editor; exported builds use `load()` |
| `world.gd:212-214,357-369,436` | `SPRITE_ALIAS`, `_env_sids()`, `_sprite_frames()` | keys unchanged, but alias-resolution must feed the bucket map (§3.1) |

### 5.3 Offline tools and sidecars

| File:line | Hard-coded value | Effect / fix |
|---|---|---|
| `tools/convert_models.py:640-641` | `obj_dir = out/obj`, `tex_dir = out/tex` | needs mapped layout or per-entry destination |
| `:677-679,686-687` | writes flat `obj/`, `tex/`; manifest `obj`/`texture_png` absolute | emit target tree + `assets` map |
| `:678`, `:133-137` | `map_Kd ..\tex\<tex_name>.png` | depth change breaks it → same-folder mirror (`map_Kd <basename>.png`) or `..\..\tex\<basename>.png`; engine correctness **UNVERIFIED** |
| `:631-634,651-654` | `--manifest-name` additive discipline | preserve; new sids must use §3 rule |
| `tools/convert_skins.py:258,284-290,329` | `--out .../skin`, writes flat + `index.json` | write bucket tree or rewrite `index.file` post-copy; `--index-name` additive preserved |
| `tools/render_models.py:397-408` | reads manifest `obj`/`texture_png` absolutely | all 299 break after move → map-based resolution |
| `.import` sidecars (280 obj, 174 tex, 179 sprites, 90 sprites_hi) | `source_file="res://assets/models/<flat>"`, `path=…hash…`, `dest_files[…]` | stale after move → exact byte rewrite with `md5(utf-8(new res:// path))` (FOLD-01 §1.3 verified rule; `migrate_anim_layout.py:11-21`, `migrate_anim_nations.py:6-17` precedent). Preserve `uid`. |
| `tools/migrate_anim_layout.py`, `migrate_anim_nations.py` | dry-run/apply/rollback/verify + undo log | **reuse**, do not reinvent |

### 5.4 Hardlinks and docs

| Item | Evidence | Effect / fix |
|---|---|---|
| `sprites/*.png`, `sprites_hi/*.png` are NTFS **hardlinks** to `app/assets/models/…` | `fsutil hardlink list` on `sprites/aca.png` and `sprites_hi/rock_sea1.png` (OBSERVED) | copy bytes, never in-place edit; verify link list before apply; app/ tree untouched |
| `sprites/.gdignore`, `sprites_hi/.gdignore` | OBSERVED | variant-only; carry into new tree or keep at root — **UNVERIFIED** which Godot honors after split |
| `CREDITS.md:54-57,100-118` | doc citations of flat obj/tex/skin | separate owned doc pass |
| `MECHANICS.md:425-426,481-486`, `README.md:43-48` | same | separate owned doc pass |
| scene/UID references outside `.gd`/`.json` | not exhaustively enumerated | **UNVERIFIED** — gate must catch import misses |

---

## 6. Reversible migration sequence (5 folders, per-folder copy/verify/switch)

Precedent: `tools/migrate_anim_layout.py:2-33` / `migrate_anim_nations.py:19-24`
(dry-run → apply → rollback → verify with exact byte rewrites and undo log).

**Step 0 — freeze/owner gate.**
Snapshot `git status --short`; sha256 `manifest.json`, `skin/index.json`, all
`.obj/.mtl/.png/.json/.import` in all five trees. Require C01-ASSET and any
concurrent impl (P10/P11/P12/M03) to finish; re-check hashes immediately before
Step 3. Refuse if any model path changed mid-run. Record this report's
37/262 partition as the expected count.

**Step 1 — read-only plan.** Generate `inbox/FOLD_05_asset_plan.json`:

```
per sid: {kind, nation, bucket, src_obj, src_tex, src_skin,
          src_sprite, src_sprite_hi, dst_res_paths, texture_basename,
          sha256, sidecar_rewrite_triples, mtl_map_Kd_target,
          hardlink_paths[]}
```

Assert: 299 sids; 192 unique tex basenames + `mill_rotor`; 66 skins; 179 low
+ 90 hi sprite keys; no two sids map to one target (case-insensitive on win32);
no target collides with an existing file; 37 nation / 262 shared. Warn (do not
silently fix) about the 19 missing sidecars.

**Step 2 — backup by copy, not move.**
`inbox/backup/models_FOLD05_<UTC>/` receives full copies of `obj/`, `tex/`,
`skin/`, `sprites/`, `sprites_hi/`, `manifest.json`, `skin/index.json` and all
sidecars. Write `inbox/FOLD05_undo.json` with exact src/dst pairs and original
bytes of every rewritten file. **Do not edit hardlinked PNG bytes in place.**

**Step 3 — per-folder apply, in this order (originals stay flat as fallback).**

| # | Folder | Copy/verify | Switch |
|---|---|---|---|
| 3a | `obj/` | copy `.obj/.mtl/.import` to bucket; rewrite 3 sidecar fields with new md5 hash; rewrite MTL `map_Kd` from texture basename | add `assets.obj` to manifest copy |
| 3b | `tex/` | copy `.png/.import` to owning sid's bucket; rewrite sidecars | add `assets.tex`; update `ROTOR_TEX_IMPORT_PATH` if mill_rotor moved |
| 3c | `skin/` | copy 66 JSON to buckets; leave `index.json` at root | rewrite 66 `entries[].file` strings |
| 3d | `sprites/` | copy 179 `.png/.import` (hardlink-safe) to key buckets | add `assets.sprite`; add `world.gd` manifest read |
| 3e | `sprites_hi/` | copy 90 `.png/.import` to key buckets | add `assets.sprite_hi`; same helper |

After each sub-step: Python static gate for that folder only (paths exist,
sidecar `source_file` equals mapped path, hash recomputes, counts match plan,
no `res://res://`, MTL target exists). **Stop on any mismatch; do not proceed
to the next folder.**

**Step 4 — code resolver (separate owned change).** `world3d_entities.gd`
(contested by M03/P11 — COORD must grant ownership, WAVE_G_CHARTER.md:102-104),
`world3d_fx.gd`, `world.gd`; backups `inbox/backup/<name>.bak-FOLD05`.
Resolver: prefer mapped `res://` path, fall back to today's composed path.

**Step 5 — Godot cache invalidation (G04 ONLY).**
Allow reimport; do **not** hand-edit `.godot/`. Verify each edited sidecar's
`uid` preserved and new `.godot/imported/<basename>.<newhash>.mesh/.ctex`
produced; old cached files become unused and are cleaned only after the
observation window. Generate sidecars for the 19 C01-ASSET assets (none exist
today). **UNVERIFIED** until this run: depth-rewritten `map_Kd` handling,
and whether the 19 assets were proxying before migration.

**Step 6 — gate checks (all must pass before switch).**
- Python static: full plan assertions (§Step 1) + all five folder sub-gates.
- Godot: `mesh_sources` gains **no** `donor_bbox_proxy`; `obj_available` does
  not drop; `nation_mesh_usage` shows exact hits for
  `ruscen/pearus/pikemanrus/bavcen/musketeer18bav/polcen/swecen/pikeman18swe`;
  shipped skin count stays 66; sprite sets loaded count unchanged (2D mode).
- Existing gates: selftest 29/29, uitest 17/17, `t_render_mode`,
  `t_ghost_final_stage`, `assert_clean CLEAN` (CHARTER §5.3).
- Windowed captures: 3D P0 + real map (no new seams/proxy boxes) **and** a 2D
  capture, because `world.gd` sprites are live in the 2D branch (FOLD-04 §2).
- **Refusal condition:** any count/stat/capture regression → stop, no switch.

**Step 7 — switch originals aside (still reversible).** Only after Step 6 green,
rename flat originals into `inbox/backup/models_FOLD05_predelete/<UTC>/`.
Never `rm`. Keep legacy fallback code until the observation window closes.

**Step 8 — rollback / follow-ups.** Rollback = restore backups from
`FOLD05_undo.json`, restore flat tree + manifest/index, revert code patches,
reimport (G04). Keep the backup one full gate cycle; delete only on explicit
owner instruction. Follow-ups (separate owners): doc strings §5.4, tool output
layout §5.3, alias-pair dedupe decision (§7 Q7).

---

## 7. UNVERIFIED / open register

1. Owner decision: approve consolidated `shared/terrain` (this report) over
   FOLD-01's `shared/env` + `shared/relief` (§3.2).
2. Owner/COORD decision: grant `world3d_entities.gd` (contested) and `world.gd`
   (2D-branch) ownership; else use the separate sprite-index fallback (§4.3).
3. Owner decision: move `mill_rotor.png` into `shared/buildings/` (requires
   `:248` edit) or leave flat (§3.3).
4. **UNVERIFIED:** Godot OBJ importer's handling of depth-rewritten MTL
   `map_Kd` (Windows backslashes).
5. **UNVERIFIED:** whether the 19 C01-ASSET OBJ/PNG files are imported/loaded
   today (no `.import` sidecars); no Godot run by this agent.
6. **UNVERIFIED:** scene/UID resource references outside `.gd`/`.json`.
7. **INFERRED:** `peaukr` (`ukr/land_units`) and generic `peasant`
   (`shared/land_units`) are byte-duplicate donor geometry; likewise
   `serdiuk` ↔ `musk18` sprite alias. Keep as alias pairs; dedupe is not in
   this ticket.
8. **UNVERIFIED:** `yachttur` → `tur/naval_units` vs `shared/naval_units`
   (chose shared, identity sid, N07 §4.3).
9. **UNVERIFIED:** whether FOLD-02 lands with facts that change §2/§4.
10. **UNVERIFIED (win32 vs export):** case-insensitive local FS vs
    case-sensitive exported builds; target names are lowercase-only.

## 8. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | All five folders are flat today; sprites are hardlinked to `app/` | on-disk census; `fsutil hardlink list` | OBSERVED |
| 2 | Runtime composes obj/tex/sprite paths; only skins are index-driven | §2 file:line table | OBSERVED |
| 3 | One allow-list rule yields 37 nation / 262 shared across five folders | §3.3 recomputation; FOLD-01 §4 | DERIVED |
| 4 | relief/env/FX → new `shared/terrain`, not `shared/buildings` | manifest kinds; `world3d_entities.gd:290-291` | DERIVED decision |
| 5 | manifest needs `assets` map; skin index needs 66 `file` rewrites; no sprite index exists | §4.1-4.3 | OBSERVED + DERIVED |
| 6 | 19 C01 assets lack `.import` sidecars; MTL `map_Kd` is depth-fragile | 299-280 / 193-174; `obj/*.mtl` | OBSERVED |
| 7 | `_nation_mesh_on_disk()` is the critical break point | `world3d_entities.gd:718-722,819` | OBSERVED |
| 8 | Visual/donor parity of any migrated asset | none | UNVERIFIED |

## 9. Attestation

- **Read-only:** no file in `variant3d/`, `inbox/`, `app/`, `docs/` (other than
  this report), no manifest/index/sidecar/MTL/test/config/git state was
  modified. No file was moved or copied. No donor file was copied or executed.
- No Godot launched, no runner job submitted (WAVE_G_CHARTER.md:31).
- **One repo file written:**
  `docs/terrain_swarm_2026-11-25/reports/FOLD_05_all_folders.md`.
- **No donor parity claim.** Visual result of any future migration is
  UNVERIFIED until a real gate/capture exists.

*End of FOLD-05 report.*
