---
id: C01-ASSET
ticket: "C01-ASSET — additive asset conversion integration (nation T0 + N06 plan + Z05 relief)"
owner: C01-ASSET subagent
created: 2026-11-25
status: DELIVERED__IMPLEMENTED__NO_GODOT__NO_RUNNER__NO_DONOR_COPY__RELEASED
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROX"]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (standing rule :31 — only G04 runs Godot)
parity_guard: "No donor GPU A/B frame exists. 'Donor-derived' means file/byte provenance only, never a rendered-look claim. No Godot was launched, no runner job was submitted, no donor binary was copied into the repo or executed."
ownership: "EXCLUSIVE owner of variant3d/tools/convert_models.py, convert_skins.py, variant3d/assets/models/** and variant3d/CREDITS.md. No .gd source, config, test or app/** file was edited."
scope_note: "Files written: 2 tools, variant3d/CREDITS.md, variant3d/assets/models/manifest.json, skin/index.json, 68 new derived asset files, 5 inbox/backup/*.bak-C01ASSET files, this report. Other modified/untracked files in git status belong to concurrent agents (N04/M03/P12/Y03/FOLD)."
---

# C01-ASSET — additive conversion integration (implementation report)

## 0. Direct answer (OBSERVED)

One additive pass derived **19 new sids** (4 T0 nation halls, N06's exact 8 peasants,
3 T0 signature units, Z05's 4 relief props) into a **staging** directory, then merged
them into the shipped asset tree **without rewriting a single pre-existing byte**:
the 280 original manifest entries and all 1,783 pre-existing asset files (other than
the intentionally updated `skin/index.json`) remain byte-identical.

- `manifest.json`: **280 → 299** entries (+19); `skin/index.json`: **count 55 → 66**,
  `total_bytes 3,720,747 → 4,489,087`.
- File counts: `obj/` **840 → 878** (+19 OBJ +19 MTL), `tex/` **348 → 367** (+19 PNG),
  `skin/` **56 → 67** (+11 JSON).
- Validation: **164 checks, 0 failures** (§4), plus G0/G1 default-pipeline regression.
- `ruscen` is genuinely a different hall: **15,348 verts / 9,936 faces** vs the
  Ukrainian-derived `cen.obj` **5,611 / 3,714** (N06 §1.1, re-measured this pass).
- Relief OBJs keep **raw donor units**; the per-object `Scaling` (0.3539–0.6562,
  `pattern.lib`) is deliberately **not** baked in — it is placement data for a later
  instancing consumer (§6.3). Adding the assets alone does **not** make hills visible.
- **UNVERIFIED:** every visual outcome. No donor GPU A/B frame, no Godot, no capture.

> COORD note on FOLD01's "temp staging paths" flag: the initial merge did carry
> staging prefixes; these were normalized to the repo-absolute prefix during
> integration (38 path fields in the 19 new entries only). The merged file now uses
> the exact same absolute repo-path format as all 280 pre-existing entries; the
> original 280-entry byte slice SHA is unchanged. No further fix required.

---

## 1. Backups (created BEFORE any edit)

All under `inbox/backup/`, suffix `.bak-C01ASSET`:

| Backup | Original size | SHA-256 of original |
|---|---:|---|
| `convert_models.py.bak-C01ASSET` | 24,660 B | `2022db2a7661944d4ff55256ac38579cc09da18de377eb46596ad68fd42e1cbd` (matches Z05's anchor exactly — no drift) |
| `convert_skins.py.bak-C01ASSET` | 14,623 B | `ab5193cd02164b85077d66b0a6e1f320666bfd6b3bae2a34dd3835cb505cff2f` |
| `manifest.json.bak-C01ASSET` | 220,968 B | `d9789ada402f4311f982f405ce71f6ce106d7bc30e0b0932b63c55bc0b192a81` |
| `index.json.bak-C01ASSET` | 34,018 B | `0ef8085d09a2908b3777e3d3b3fa5dfbfb2c9c1f713830d96b0765a02fe4a137` |
| `CREDITS.md.bak-C01ASSET` | 5,949 B | `cb0d678f315d6b342e5c4f15e083797260925f2f2373a0eba691a0fc56c3597f` |

---

## 2. Exact tool diff

### 2.1 `variant3d/tools/convert_models.py` (5 hunks, all additive)

Backup: `inbox/backup/convert_models.py.bak-C01ASSET`.

```diff
@@ -496,6 +496,121 @@ def env_models(game: str) -> list:
     return out
 
 
+# --------------------------------------------------------------------------
+# C01-ASSET — additive nation / relief tables.
+#
+# Every function below is OPT-IN. A default invocation still calls only the
+# five original tables (unit/building/ship/env/stage) and produces the exact
+# same 280-entry manifest. The additive run writes a SEPARATE manifest name
+# and the asset owner text-inserts its entries into the shipped manifest so
+# all 280 existing entries and all 280 existing asset bytes stay untouched
+# (N06 §3, Z05 §4). No donor binary is copied into the repo: the same
+# read_mesh()/write_obj()/convert_texture() path derives OBJ/MTL/PNG from the
+# private install, which is only ever read.
+# --------------------------------------------------------------------------
+
+def nation_building_models(game: str) -> list:
+    """C01-ASSET / N07 T0 — additive nation-hall table (4 default nations).
+
+    Donor sources (read-only, private use):
+      data/actors/buildings/<nat>/<nat>cen.osm
+      data/materials/buildings/<nat>/<nat>cen.dds
+    N02 A2 / N07 §3.2 confirm a distinct hall mesh+albedo for all 21 nations;
+    the port only converts ukrcen (as the generic `cen`). `ruscen` is the
+    owner-mandated different Russian hall (15,348 verts/9,936 faces vs
+    ukrcen's 5,611/3,714 — N06 §1.1). bav/pol/swe are N07's other T0 starts.
+    """
+    actors = os.path.join(game, "data", "actors", "buildings")
+    mats = os.path.join(game, "data", "materials", "buildings")
+    # port sid -> (actor folder, actor base, texture folder, texture base)
+    table = {
+        "ruscen": ("rus", "ruscen", "rus", "ruscen"),
+        "bavcen": ("bav", "bavcen", "bav", "bavcen"),
+        "polcen": ("pol", "polcen", "pol", "polcen"),
+        "swecen": ("swe", "swecen", "swe", "swecen"),
+    }
+    return [{
+        "sid": sid, "kind": "building",
+        "mesh": os.path.join(actors, af, ab + ".osm"),
+        "texture": os.path.join(mats, tf, tb + ".dds"),
+        "directions": 1,
+    } for sid, (af, ab, tf, tb) in table.items()]
+
+
+def nation_peasant_models(game: str) -> list:
+    """C01-ASSET / N06 §1.2 — exact 8-nation peasant table.
+
+    The port previously mapped only `peasant -> peaukr`, so no nation-stemmed
+    peasant mesh existed on disk (N01/N03). Each `.oss` is a distinct donor
+    binary with its own bone/vertex/face counts; `convert_skins.py` reads each
+    nation's own AAF for action ranges (N06 B5: `pearus k=486`, others 483).
+    `peaukr` is a derived duplicate of the shipped `peasant.obj` (N06 B12);
+    the uniform 8-stem mapping is kept deliberately for a consistent sid map.
+    """
+    actors = os.path.join(game, "data", "actors", "units")
+    mats = os.path.join(game, "data", "materials", "units")
+    bases = ("pearus", "peaukr", "peapol", "peaaus",
+             "peaeng", "peaspa", "peatur", "peasco")
+    return [{
+        "sid": base, "kind": "unit",
+        "mesh": os.path.join(actors, base + ".oss"),
+        "texture": os.path.join(mats, base + ".dds"),
+        "directions": 8,
+    } for base in bases]
+
+
+def nation_signature_models(game: str) -> list:
+    """C01-ASSET / N07 §6.1 T0 — additive signature units for the 4 starts.
+
+    N07 T0 picks one donor-distinct signature unit per default nation:
+    Russia `pikemanrus`, Bavaria `musketeer18bav`, Sweden `pikeman18swe`.
+    Poland's signature `wingedhussar` is already converted in the base set,
+    so it is NOT re-emitted here. All three are real donor `.oss`+`.dds`+`.aaf`
+    triples; no shape or frame range is invented.
+    """
+    actors = os.path.join(game, "data", "actors", "units")
+    mats = os.path.join(game, "data", "materials", "units")
+    bases = ("pikemanrus", "musketeer18bav", "pikeman18swe")
+    return [{
+        "sid": base, "kind": "unit",
+        "mesh": os.path.join(actors, base + ".oss"),
+        "texture": os.path.join(mats, base + ".dds"),
+        "directions": 8,
+    } for base in bases]
+
+
+def relief_models(game: str) -> list:
+    """Z05 — additive donor relief-prop table (terrainmesh1..4 only).
+
+    Donor sources (read-only, private use):
+      data/actors/env/terrainmeshN.osm      (IDP2 version 8, first frame only)
+      data/materials/env/terrainmeshN.dds   (terrainmeshN.prop:14 summer albedo)
+    Geometry and pixels are DERIVED by the existing read_osm()/write_obj()/
+    convert_texture() path; no donor .osm/.dds is copied into the repo.
+
+    terrainplateau1..4 are deliberately excluded: no donor albedo, no .prop,
+    zero pattern.lib BaseName refs (Z05 §1.3). Per-object Scaling/Position/
+    Direction are placement data (pattern.lib), NOT mesh data — the OBJ stays
+    in RAW donor units (scale is left raw) and a later instancing consumer
+    applies the authored per-placement transform. kind="relief" keeps
+    force_opaque=False so the real donor alpha is preserved (Z05 §1.1).
+    """
+    actors = os.path.join(game, "data", "actors", "env")
+    mats = os.path.join(game, "data", "materials", "env")
+    table = {
+        "terrainmesh1": "terrainmesh1",
+        "terrainmesh2": "terrainmesh2",
+        "terrainmesh3": "terrainmesh3",
+        "terrainmesh4": "terrainmesh4",
+    }
+    return [{
+        "sid": sid, "kind": "relief",
+        "mesh": os.path.join(actors, base + ".osm"),
+        "texture": os.path.join(mats, base + ".dds"),
+        "directions": 1,
+    } for sid, base in table.items()]
+
+
 def main() -> int:
     ap = argparse.ArgumentParser(description=__doc__)
     ap.add_argument("--game", default=DEFAULT_GAME,
@@ -506,6 +621,17 @@ def main() -> int:
                     help="BUILD-ART-CONV-01: also convert the 108 donor "
                          "construction-stage / scaffold OSMs (opt-in; the "
                          "default run is byte-identical to the base pipeline)")
+    ap.add_argument("--nation-art", action="store_true",
+                    help="C01-ASSET: emit ONLY the additive nation halls, "
+                         "peasants and signature units (opt-in; never mixed "
+                         "with the 280 base entries)")
+    ap.add_argument("--include-relief", action="store_true",
+                    help="Z05: also convert the 4 donor terrainmeshN relief "
+                         "props (opt-in; scale stays raw in the OBJ)")
+    ap.add_argument("--manifest-name", default="manifest.json",
+                    help="C01-ASSET: manifest filename written under --out "
+                         "(default: manifest.json; an additive run must use a "
+                         "separate name, e.g. manifest_addendum.json)")
     args = ap.parse_args()
 
     # expanduser makes ~/: Linux/macOS paths work; Path.resolve is cross-platform.
@@ -521,6 +647,17 @@ def main() -> int:
     if args.include_stages:
         # Additive only: base entries keep their original sid/name/texture.
         models = models + stage_models(game)
+    if args.nation_art:
+        # C01-ASSET: an additive run emits ONLY the new nation sids. The asset
+        # owner text-inserts them into the shipped manifest so all 280
+        # existing entries and asset bytes stay byte-identical (N06 §3).
+        # Never mix the base tables into an additive manifest rewrite.
+        models = (nation_building_models(game) + nation_peasant_models(game)
+                  + nation_signature_models(game))
+    if args.include_relief:
+        # Z05: append the 4 relief props (after nation art when both flags
+        # are set, so one run derives the whole additive set).
+        models = models + relief_models(game)
     manifest = {"game": game, "models": []}
     ok = 0
     for m in models:
@@ -556,9 +693,10 @@ def main() -> int:
         print("OK %-12s %-8s verts=%-5d faces=%-5d bbox z %.2f..%.2f" % (
             sid, mesh["format"], len(verts), len(mesh["faces"]), min(zs), max(zs)))
 
-    with open(os.path.join(out, "manifest.json"), "w", encoding="utf-8") as f:
+    manifest_path = os.path.join(out, args.manifest_name)
+    with open(manifest_path, "w", encoding="utf-8") as f:
         json.dump(manifest, f, indent=2)
-    print("done: %d models, manifest at %s" % (ok, os.path.join(out, "manifest.json")))
+    print("done: %d models, manifest at %s" % (ok, manifest_path))
     return 0 if ok == len(models) else 1
```

Untouched by design: `read_oss()` `:48-71`, `read_osm()` `:74-99`, `read_mesh()` `:102-107`,
`write_obj()` `:114-131`, `write_mtl()` `:133-137`, `convert_texture()` `:140-158`, all five
original tables `:165-496`, resolution/makedirs `:511-517`, the per-model loop `:526-557`,
`json.dump(indent=2)` and exit code `:562`. `app/tools/convert_models.py` was **not** edited.

### 2.2 `variant3d/tools/convert_skins.py` (2 hunks)

Backup: `inbox/backup/convert_skins.py.bak-C01ASSET`.

```diff
@@ -285,6 +285,10 @@ def main() -> int:
     ap.add_argument("--out", default="variant3d/assets/models/skin")
     ap.add_argument("--frames-per-action", type=int, default=6)
     ap.add_argument("--actions", default=",".join(DEFAULT_ACTIONS))
+    ap.add_argument("--index-name", default="index.json",
+                    help="C01-ASSET: index filename written under --out "
+                         "(default: index.json; an additive run must use a "
+                         "separate name, e.g. index_nation.json)")
     args = ap.parse_args()
 
     game = Path(args.game)
@@ -322,12 +326,13 @@ def main() -> int:
         "skipped": skipped,
         "failed": failed,
     }
-    with open(out_dir / "index.json", "w", encoding="utf-8") as fh:
+    index_path = out_dir / args.index_name
+    with open(index_path, "w", encoding="utf-8") as fh:
         json.dump(index, fh, separators=(",", ":"), ensure_ascii=False, indent=None)
 
     print("exported %d skins, %d skipped, %d failed; total %.2f MB -> %s"
           % (len(entries), len(skipped), len(failed),
-             index["total_bytes"] / 1e6, out_dir))
+             index["total_bytes"] / 1e6, index_path))
     for row in entries[:5]:
         print("  %-18s k=%4d b=%2d v=%4d frames=%2d actions=%s %7d B"
               % (row["sid"], row["k"], row["bones"], row["v"],
```

`convert_unit()` is unchanged: AAF path is derived from the mesh stem and frame ranges
come from each nation's own AAF (`:208-227`), so `pearus k=486` is not clipped by a
hard-coded 483 ceiling (N06 B5).

### 2.3 The single additive run

```
python variant3d\tools\convert_models.py --game "C:\Games\Cossacks 3" \
  --out <TEMP>\c01as_stage --nation-art --include-relief \
  --manifest-name manifest_addendum.json
# -> 19 models, exit 0

python variant3d\tools\convert_skins.py --game "C:\Games\Cossacks 3" \
  --manifest <TEMP>\c01as_stage\manifest_addendum.json \
  --out <TEMP>\c01as_skins --index-name index_nation.json
# -> exported 11 skins, 0 skipped, 0 failed
```

Merge discipline: copy the 68 derived files (never overwrite); text-insert the 19 new
manifest objects immediately after `  "models": [` (CRLF preserved, original byte slice
untouched); text-insert the 11 new skin-index entries immediately after `"entries":[`
and update only `count`/`total_bytes`; normalize the 38 new path fields to the repo prefix.

---

## 3. Added asset list — all 19 sids / 68 new files

Donor headers re-measured read-only this pass with the repo's own `read_mesh()`; manifest
`verts`/`faces` and OBJ `v`/`f` line counts match every row exactly (§4).

| # | sid | Tranche / role | Donor mesh + albedo | verts | faces | Files added |
|---:|---|---|---|---:|---:|---|
| 1 | `ruscen` | T0 hall (rus) | `buildings/rus/ruscen.osm` + `.dds` | 15,348 | 9,936 | obj/mtl/png |
| 2 | `bavcen` | T0 hall (bav) | `buildings/bav/bavcen.osm` + `.dds` | 11,738 | 8,676 | obj/mtl/png |
| 3 | `polcen` | T0 hall (pol) | `buildings/pol/polcen.osm` + `.dds` | 14,933 | 11,598 | obj/mtl/png |
| 4 | `swecen` | T0 hall (swe) | `buildings/swe/swecen.osm` + `.dds` | 15,862 | 11,566 | obj/mtl/png |
| 5 | `pearus` | N06 peasant (rus) | `units/pearus.oss` + `.dds` + `.aaf` | 527 | 864 | obj/mtl/png + skin json |
| 6 | `peaukr` | N06 peasant (ukr) | `units/peaukr.oss` + `.dds` + `.aaf` | 577 | 921 | obj/mtl/png + skin json |
| 7 | `peapol` | N06 peasant (pol, hun) | `units/peapol.oss` + `.dds` + `.aaf` | 629 | 935 | obj/mtl/png + skin json |
| 8 | `peaaus` | N06 peasant (aus, pru, **bav**, sax, swi) | `units/peaaus.oss` + `.dds` + `.aaf` | 714 | 1,058 | obj/mtl/png + skin json |
| 9 | `peaeng` | N06 peasant (fra, eng, **swe**, den, net) | `units/peaeng.oss` + `.dds` + `.aaf` | 566 | 923 | obj/mtl/png + skin json |
| 10 | `peaspa` | N06 peasant (spa, ven, por, pie) | `units/peaspa.oss` + `.dds` + `.aaf` | 557 | 960 | obj/mtl/png + skin json |
| 11 | `peatur` | N06 peasant (tur, alg) | `units/peatur.oss` + `.dds` + `.aaf` | 565 | 1,039 | obj/mtl/png + skin json |
| 12 | `peasco` | N06 peasant (sco) | `units/peasco.oss` + `.dds` + `.aaf` | 570 | 952 | obj/mtl/png + skin json |
| 13 | `pikemanrus` | T0 signature (rus) | `units/pikemanrus.oss` + `.dds` + `.aaf` | 612 | 876 | obj/mtl/png + skin json |
| 14 | `musketeer18bav` | T0 signature (bav) | `units/musketeer18bav.oss` + `.dds` + `.aaf` | 699 | 987 | obj/mtl/png + skin json |
| 15 | `pikeman18swe` | T0 signature (swe) | `units/pikeman18swe.oss` + `.dds` + `.aaf` | 658 | 989 | obj/mtl/png + skin json |
| 16 | `terrainmesh1` | Z05 relief | `env/terrainmesh1.osm` + `.dds` | 2,662 | 5,305 | obj/mtl/png |
| 17 | `terrainmesh2` | Z05 relief | `env/terrainmesh2.osm` + `.dds` | 2,272 | 4,532 | obj/mtl/png |
| 18 | `terrainmesh3` | Z05 relief | `env/terrainmesh3.osm` + `.dds` | 2,177 | 4,323 | obj/mtl/png |
| 19 | `terrainmesh4` | Z05 relief | `env/terrainmesh4.osm` + `.dds` | 2,509 | 5,002 | obj/mtl/png |

File totals: **19 OBJ + 19 MTL + 19 PNG + 11 skin JSON = 68 new files**, all under
`variant3d/assets/models/{obj,tex,skin}/`. Full sid/file list is also in `git status`
(untracked files). OBJ/MTL/PNG basename == sid for every row, so the runtime's on-disk
probe by sid works without an invented name. Polish signature `wingedhussar` was already
converted, so it is intentionally not re-emitted (N07 §6.1).

Relief UV counts intentionally differ from vertex counts (Z05 §1 index sanity, left
unfixed): `terrainmesh1 2662/2662`, `terrainmesh2 2272/2273`, `terrainmesh3 2177/2170`,
`terrainmesh4 2509/5158` (verts/uvs). All OBJ face indices are within `1..nv`.

---

## 4. Validation (no Godot, no runner)

Static/file checks only. Full 164-line log was produced by a throwaway script in
`%TEMP%\opencode` (outside the repo). **Result: 164 checks, 0 FAIL.**

| Gate | Check | Result |
|---|---|---|
| G0 | Backup hashes match pre-edit state; `convert_models.py` hash == Z05 anchor `2022db2a…` | PASS |
| G1 | Default converter run (no additive flags, `--include-stages`) → 280 entries; all entry fields identical to shipped baseline (path fields excluded because `--out` is temp); **0** OBJ/MTL byte diffs vs shipped | PASS (172 entries without `--include-stages`, as expected: 62 unit +17 building +93 env) |
| G2 | `manifest.json` parses; len **299**; new sids at indices 0..18 exactly the list in §3; original 280 entries deep-equal backup; game header unchanged | PASS |
| G3 | **Byte identity:** original 280-entry slice SHA `fa36c340eeef6f66f8782b48fa790787f9ad6dccb4f1bf9f6f46e4744dd9a840`, len **220,906 B** in both backup and merged file | PASS |
| G4 | Pre-existing asset bytes: **1,783** of 1,784 hashed files unchanged; the sole change is `skin/index.json` (intentionally merged) | PASS |
| G5 | Per new sid: OBJ `v`/`vt`/`f` counts == donor `num_verts`/`num_uv`/`num_tris`; manifest `verts`/`faces` == donor | PASS for all 19 |
| G6 | OBJ face indices `1..nv`; MTL `map_Kd ..\tex\<sid>.png` resolves; PNG exists | PASS for all 19 |
| G7 | `terrainmesh1..4` PNGs: 2048×2048 RGBA, alpha extrema `(0,255)` — real donor alpha preserved (`kind="relief"` → `force_opaque=False`) | PASS |
| G8 | `skin/index.json` parses; count 66, entries 66; new skins at 0..10; original 55 entries deep-equal + **byte-identical** slice; `skipped`/`failed` unchanged; `total_bytes` recomputed; every new JSON parses with correct `sid`/`k`/`fps=30` and byte size | PASS |
| G9 | License hygiene: no donor `.osm/.oss/.dds/.aaf` in `variant3d/assets/models/`; every new OBJ SHA differs from its donor source SHA; no donor binary copied or executed | PASS |
| G10 | Tool syntax: `python -m py_compile` on both tools | PASS |

Note on scope: pre-existing `.dds` files under `app/assets/terrain/decals/` and
`variant3d/assets/terrain/decals/` are documented in `CREDITS.md:15-20` and are **not**
files added by this ticket.

---

## 5. CREDITS provenance note

`variant3d/CREDITS.md` already existed (it was not created). A new section
`## C01-ASSET — additive derived nation art + relief props (derived, not copied)` was
appended after the existing private-use statement, backed up as
`inbox/backup/CREDITS.md.bak-C01ASSET`. It records:

- the four `<nat>cen.osm` + `<nat>cen.dds` → `obj/<nat>cen.obj` (+ `.mtl`) + `tex/<nat>cen.png`
  conversions (`ruscen` distinguished from the Ukrainian-derived `cen.obj`);
- the eight `pea<X>.oss/.dds` → OBJ/PNG and each nation's own `.aaf` → flat-root skin JSON,
  with per-nation ranges (e.g. `pearus k=486`);
- the three T0 signature units (`pikemanrus`, `musketeer18bav`, `pikeman18swe`);
- the four `terrainmeshN.osm/.dds` → OBJ/PNG, with placement truth **read, not copied**
  (`.prop`, `.actor`, `actors.lib:1200-1213`, `pattern.lib` 112 records,
  `dogenerate.inc:1984-1985`) and the explicit statement that raw donor units and
  authored `Scaling` are placement data, never baked into the mesh;
- private-use / never-redistribute stance (`README.md:220-224`, `app/CREDITS.md:1-5`,
  `docs/WAIVERS.md`), and the labels STATIC bind-pose / flat-root PORT APPROXIMATION,
  winter/desert/plateau assets NOT converted, visual donor parity UNVERIFIED.

No donor binary, pixels or executable were added under `docs/` (G24 Finding 1/3 respected).

---

## 6. Code-owner handoff (NO edits made by this ticket — all .gd files untouched)

### 6.1 `variant3d/scripts/world3d_entities.gd` — hall + peasant + animation sid
- **Halls:** with `ruscen.obj`/`bavcen.obj`/`polcen.obj`/`swecen.obj` on disk the existing
  chain should resolve them: `_donor_building_prefix()` (~`:715-740`) keeps `cen` in
  `OWN_FAMILIES`, `_entity_mesh_sid()` (~`:790-791`) probes `<nat>cen`,
  `_nation_mesh_on_disk()` (~`:702-706`) now succeeds, `_mesh_info()` (~`:1132+`) reads
  the manifest bbox/OBJ. Re-check exact lines (concurrent agents moved them).
- **Peasants (presentation-only):** in `_entity_mesh_sid()`'s units branch (~`:774-789`)
  add a donor-derived map and append `pea<X>` as a candidate for `base_sid == "peasant"`:
  `rus→pearus`, `ukr→peaukr`, `pol→peapol`, `aus/pru/bav/sax/swi→peaaus`,
  `fra/eng/swe/den/net→peaeng`, `spa/ven/por/pie→peaspa`, `tur/alg→peatur`, `sco→peasco`
  (N02 B1, N07 §4.1). Keep `exact=true` only on a real disk hit; keep the fallback.
- **Do NOT add `NATION_UNITS.peasant`**: `data.gd:1565-1568` `resolve_sid()` rejects any sid
  absent from `UNITS_BASE`, so the naïve map is a silent no-op (N06 B1). Keep sim stats on
  `peasant`. The 8 peasant stems cover all 21 port nations via the donor groupings above.
- **Signature units:** `pikemanrus`, `musketeer18bav`, `pikeman18swe` are presentation art;
  leave `NATION_UNITS` remaps and sim sids unchanged. Note Poland's `wingedhussar` already
  existed, and T1's 17 remaining halls are **not** converted — label that mismatch honestly.
- **Carry the resolved sid into animation (N03 M6 / N06 B2):** `add_unit()` (~`:1653-1695`)
  computes `ns["sid"]` but does not store it; `sync()` (~`:2111, :2127-2142`) samples with the
  raw sim sid, so a nation mesh would animate with `peasant`/`peaukr` skin. Store the
  resolved sid on the presentation slot and pass e.g. `{"sid": sid}` to `pose_for()` and
  `has_skin()`/`_morph_mesh()`. Never mutate the sim entity's `sid`.
- **Labels/telemetry:** update `NATION_MESH_FALLBACK_STATUS`, `NATION_MESH_BLOCKED_EVIDENCE`
  (~`:206,213`) and the stats fields (~`:490,492`) so telemetry stops claiming "0 prefixed
  OBJs / NOT VISUALLY FIXED". Keep "visual UNVERIFIED".
- **Stage/ghost art remains nation-blind** (`_stage_mesh_info()` ~`:1875+`,
  `world3d_fx.gd:658-669`): build stages still show Ukrainian-derived art because no
  `ruscen1..4`/`ruscen*a` geometry was converted (N06 §1.4/B3). Accept with an explicit
  PORT APPROX label or schedule a T2 stage conversion.

### 6.2 `variant3d/scripts/anim3d.gd` — no registration edit required
`_ensure_shipped_skins()` (~`:806+`) lazily reads `res://assets/models/skin/index.json` and
`_load_shipped_skin()` registers each sid; the 11 new JSONs are enough. `_sid_of()` (~`:683+`)
accepts a Dictionary with a `sid` key — the clean route for §6.1's animation sid carry.
`_action_range_for()` (~`:987+`) uses each shipped skin's own `actions`/`donor`; `AAF_ACTIONS`
(~`:71-90`) remains the **peaukr-only legacy fallback** and must not drive nation sids.
`BLOCKED_RIG` (~`:66`) stays: no invented parent matrices.

### 6.3 Relief instancing — still required for visible hills
The 4 `terrainmeshN` assets are necessary but **not sufficient**. `world3d_entities.gd`
(~`:1146-1153`) loads `res://assets/models/obj/<sid>.obj`, normalizes by manifest bbox and
calls `_bake_mesh(..., scale, target_h, ...)` — a generic sid spawn would ground/scale the
prop rather than place it at the authored transform. A dedicated placement path (in
`world3d_terrain.gd`, or `world3d_entities.gd` after COORD's ownership grant; contested by
M03/P11) must:
1. bypass bbox normalization / entity grounding;
2. keep raw donor OBJ units and apply the authored per-object `Scaling` (0.3539–0.6562),
   `Position`, `Direction` from `pattern.lib` at placement — never bake scale into the OBJ;
3. pick among `terrainmesh1..4` behind an explicit PORT APPROX policy (runtime selection
   is engine-side, UNVERIFIED — Z05 R1);
4. generate Godot `.import` sidecars on the next editor pass (no Godot ran here; UNVERIFIED).

### 6.4 Owner requirements — status
- **Russian hall must differ:** DONE (`ruscen` 15,348/9,936 vs `cen`/`ukrcen` 5,611/3,714).
- **Check ALL nations unit/building associations:** DONE for the donor's 8 peasant forms
  (covering all 21 port nations), 4 T0 halls and 3 T0 signature units; the 17 non-T0 nation
  halls and the common-family (`rus*`/`tur*`/`spa*`/`porpor`) variants remain a documented
  T1/T2 gap (N07 §6.2/§6.3), not silently ignored.
- **Hills must be visible:** asset side DONE; runtime instancing still needed (§6.3).

---

## 7. Scope / safety attestation

- Only owned files touched: two tools, `variant3d/CREDITS.md`, `variant3d/assets/models/**`,
  five `.bak-C01ASSET` backups and this report. No `.gd`, `.gdshader`, config, test or
  `app/**` edit by this ticket. Other modified files in `git status` belong to concurrent
  agents.
- No Godot process, no runner job (submit/cancel/ack/unwedge/reset none), no capture.
- Donor install accessed read-only for bytes/text; throwaway probe/validation scripts live
  in `%TEMP%\opencode`, outside the repo. No donor file was copied into the repo or executed.
- **No donor parity claim.** All visual outcomes remain UNVERIFIED.

## 8. RELEASE

I hereby **RELEASE** exclusive ownership of `variant3d/assets/models/**` (including
`manifest.json` and `skin/index.json`), `variant3d/tools/convert_models.py`,
`variant3d/tools/convert_skins.py` and `variant3d/CREDITS.md` to COORD / the folder-migration
agent. No further edits will be made by this ticket after this report lands. Available for
follow-up questions.

*End of C01-ASSET implementation report.*
