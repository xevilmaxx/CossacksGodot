---
id: CLEAN-02
ticket: "Wave CLEAN — CLEAN-02: repoint render_models.py to the FOLD-06 additive bucket map"
date: 2026-11-25
owner: "CLEAN-02 subagent — EXCLUSIVE owner of variant3d/tools/render_models.py"
status: DELIVERED__IMPLEMENTED__NO_GODOT__NO_RUNNER__NO_RENDER__NO_DELETION__NO_PARITY_CLAIM
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
priors_read: [CHARTER.md, reports/CLEAN_01_report.md, reports/FOLD_06_impl.md, reports/FOLD_07_impl.md]
scope: "Only variant3d/tools/render_models.py edited; one backup under inbox/backup/; two throwaway verifiers under %TEMP%/opencode/; this report. No manifest, .gd, asset, test, config, .import, .godot/** or app/** edit. No Godot, no runner job, no Blender render."
backup: "inbox/backup/render_models.py.bak-CLEAN02 (18,356 B, sha256 0fbc299010213768c776cc764d36912e50d7fb46f0dc847637bab11aa4985dc3) — byte-identical to pre-edit file when taken."
parity_guard: "Path-source change only; no donor GPU A/B frame and no capture produced. Donor parity stays UNVERIFIED (CHARTER.md:57-58,122-130)."
---

# CLEAN-02 — bake tool source repointed to the additive bucket map

## 0. Result (OBSERVED)

`variant3d/tools/render_models.py` no longer opens the manifest's absolute flat
`obj` / `texture_png` fields (which CLEAN-01 moved into quarantine). It now
resolves every model through FOLD-06's **additive `assets` map**
(`assets.obj` / `assets.tex`, `res://`-rooted) and translates `res://` to a
filesystem path derived from the manifest location. The legacy flat fields are
read **only** to print a labelled `SKIP … DIAGNOSTIC ONLY … never used` message
when a bucket path is missing; they are never opened and never supply a render
source.

- All **299/299** entries resolve through the bucket tree; **0** diagnostic SKIPs.
- **0 quarantine hits** and **0 flat-original paths** in any resolved obj/tex.
- All resolved bucket OBJ/PNG files are **byte-identical (SHA-256)** to the
  quarantined flat originals ⇒ rendered sprite bytes are unchanged.
- Tool CLI (all 11 flags), render math, postprocess and CLI modes unchanged.
- `python -m py_compile` exit **0**.

**No permanent deletion, no manifest edit, no Godot, no runner, no Blender run.**

---

## 1. Backup taken before edit (OBSERVED)

| Backup | Source | Bytes | SHA-256 |
|---|---|---:|---|
| `inbox/backup/render_models.py.bak-CLEAN02` | pre-edit `variant3d/tools/render_models.py` | 18,356 | `0fbc299010213768c776cc764d36912e50d7fb46f0dc847637bab11aa4985dc3` |

Verified byte-identical to the working file at backup time; no prior backup of
that name existed. Post-edit file: 21,361 B, SHA-256
`c6249367d6237095021c230bcf91b18d6582b76b12ac566d018ff03bced8d384`.

---

## 2. Exact diff (backup → working tree)

Complete change set — three hunks, no other edit in the file.

```diff
--- inbox/backup/render_models.py.bak-CLEAN02
+++ variant3d/tools/render_models.py
@@ -61,6 +61,70 @@ def parse_args() -> argparse.Namespace:
     return args
 
 
+# --- CLEAN-02 — additive bucket-map path resolution -------------------------
+# FOLD-06 added an additive `assets` map to every manifest entry:
+#   m["assets"]["obj"] = "res://assets/models/obj/<bucket>/<sid>.obj"
+#   m["assets"]["tex"] = "res://assets/models/tex/<bucket>/<sid>.png"
+# These point into the retained bucket trees and are the ONLY paths this bake
+# tool opens. The old absolute flat fields (m["obj"] / m["texture_png"]) were
+# moved into quarantine by CLEAN-01: they are read ONLY to label a diagnostic
+# when a bucket path is missing, and are NEVER used for rendering.
+
+def manifest_res_root(manifest_path: str) -> str:
+    """Return the Godot project root that ``res://`` maps to.
+
+    The shipped manifest always lives at ``<res_root>/assets/models/manifest.json``.
+    Deriving the root from the manifest path keeps the existing CLI unchanged
+    (no new flag) and works from any working directory.
+    """
+    abs_manifest = os.path.abspath(manifest_path)
+    suffix = os.path.join("assets", "models", "manifest.json")
+    norm = abs_manifest.replace("/", os.sep)
+    if norm.lower().endswith(suffix.lower()):
+        return abs_manifest[: -len(suffix)]
+    # Generic fallback: nearest ancestor that actually holds the manifest.
+    d = os.path.dirname(abs_manifest)
+    while True:
+        if os.path.isfile(os.path.join(d, "assets", "models", "manifest.json")):
+            return d
+        parent = os.path.dirname(d)
+        if parent == d:
+            break
+        d = parent
+    return os.getcwd()
+
+
+def res_to_fs(res_path: str, res_root: str) -> str:
+    """Translate a Godot ``res://`` path into a filesystem path for Blender."""
+    if res_path.startswith("res://"):
+        return os.path.normpath(os.path.join(res_root, res_path[len("res://"):]))
+    return res_path
+
+
+def resolve_model_paths(m: dict, res_root: str):
+    """Return (obj_fs_path, tex_fs_path) from the FOLD-06 additive bucket map.
+
+    Primary (and only render) source: ``m["assets"]["obj"]`` / ``["tex"]``.
+    If either mapped file is absent, the legacy flat fields are consulted ONLY
+    to print a labelled diagnostic -- CLEAN-01 quarantined those originals, so
+    this tool must never fall back to and render from them.
+    """
+    assets = m.get("assets") or {}
+    obj_res = assets.get("obj", "")
+    tex_res = assets.get("tex", "")
+    obj = res_to_fs(obj_res, res_root) if obj_res else ""
+    tex = res_to_fs(tex_res, res_root) if tex_res else ""
+    if obj and tex and os.path.isfile(obj) and os.path.isfile(tex):
+        return obj, tex
+    # Diagnostic only -- the flat fields are never opened. Quoting them here
+    # makes a migration miss loud without reintroducing the quarantined art.
+    print("SKIP %s (bucket-mapped obj/tex missing from res:// tree; "
+          "legacy flat fields are DIAGNOSTIC ONLY and quarantined by CLEAN-01 "
+          "-- never used: obj=%s tex=%s)" % (
+              m.get("sid", "?"), m.get("obj", ""), m.get("texture_png", "")))
+    return None
+
+
 # --- Donor-derived blue lift (asset fix for verdict_decor palette FAILs) -----
@@ -386,6 +450,7 @@ def main() -> int:
         return 0
     with open(args.manifest, "r", encoding="utf-8") as f:
         manifest = json.load(f)
+    res_root = manifest_res_root(args.manifest)
     os.makedirs(args.out, exist_ok=True)
     only = set(x for x in args.only.split(",") if x)
 
@@ -398,14 +463,15 @@ def main() -> int:
         sid = m["sid"]
         if only and sid not in only:
             continue
-        if not os.path.exists(m["obj"]) or not os.path.exists(m["texture_png"]):
-            print("SKIP %s (missing obj or texture)" % sid)
+        paths = resolve_model_paths(m, res_root)
+        if paths is None:
             continue
-        objs = import_obj(m["obj"])
+        obj_path, tex_path = paths
+        objs = import_obj(obj_path)
         if not objs:
             print("SKIP %s (no mesh imported)" % sid)
             continue
-        mat = make_material(m["texture_png"])
+        mat = make_material(tex_path)
         assign_material(objs, mat, sid)
         lo, hi = mesh_bounds(objs)
         size = max(hi.x - lo.x, hi.y - lo.y, hi.z - lo.z)
```

Line numbers above are against the backup file; the working tree's new code
sits at `:64-125`, `:453`, `:466-474`.

---

## 3. Validation (all static / system-Python, no Godot, no Blender render)

Verifiers were throwaway scripts in `%TEMP%\opencode\` (`clean02_verify.py`,
`clean02_diag_test.py`); they import the **real** edited module with
`sys.argv` containing `--postprocess-only` so `bpy` is not required, then
exercise its actual resolver functions.

### 3.1 Path resolution — all 299 entries (OBSERVED)

| Check | Result |
|---|---|
| Manifest models | 299 |
| Entries resolved via `assets.obj` / `assets.tex` | **299** |
| Diagnostic `SKIP` (bucket path absent) | **0** |
| Resolved paths under `variant3d/assets/models/**` bucket root | **299/299** |
| Resolved paths under `inbox/cleanup_20261125/**` (quarantine hits) | **0** |
| Resolved paths equal to a legacy flat `obj`/`texture_png` value | **0** |
| Flat originals still present at their old flat location | **0** (all quarantined by CLEAN-01) |

Derived res root (from `--manifest assets/models/manifest.json`):
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\`.
Sample resolution (all paths exist on disk):

```
ruscen  obj -> .../variant3d/assets/models/obj/rus/buildings/ruscen.obj
        tex -> .../variant3d/assets/models/tex/rus/buildings/ruscen.png
```

### 3.2 Byte-identical render source (DERIVED → re-verify with G04)

Each resolved bucket OBJ was SHA-256-compared to its quarantined flat original
`inbox/cleanup_20261125/obj/<sid>.obj`; each resolved bucket PNG was compared to
`inbox/cleanup_20261125/tex/<basename>`.

| Check | Result |
|---|---|
| OBJ byte mismatches | **0** |
| PNG (texture) byte mismatches | **0** |

`import_obj()` reads the byte-identical OBJ geometry; `make_material()` loads the
byte-identical PNG; `assign_material()` replaces all imported materials
(including the rewritten bucket `.mtl` `map_Kd`) with that shadeless emission
material, so the MTL rewrite (FOLD-06 §2.7) cannot affect the bake. Camera,
lighting, view transform, resolution, sample count and donor-blue lift are all
untouched ⇒ **rendered sprite bytes are unchanged for all 299 entries**. An
actual Blender single-sid A/B is a G04 gate (§5) — not run here.

### 3.3 CLI and tests (OBSERVED)

| Check | Result |
|---|---|
| `add_argument` flags in backup vs working tree | identical (11 flags: `--elevation --engine --manifest --only --out --post-dir --post-out --postprocess-only --samples --size --start-angle`) |
| `python -m py_compile variant3d/tools/render_models.py` | exit **0** |
| `--postprocess-only` import path (no `bpy`) | loads and runs |
| Tests referencing this tool/source | none found in `variant3d/tests`; no test weakened or edited |

### 3.4 Res-root CWD independence and diagnostic fallback (OBSERVED)

- `manifest_res_root()` returns the same `variant3d\` root for both a relative
  manifest path (run from repo root) and an absolute manifest path.
- A synthetic entry whose bucket map points at non-existent files returns
  `None` (skip) and prints:
  `SKIP ghostsid (bucket-mapped obj/tex missing from res:// tree; legacy flat fields are DIAGNOSTIC ONLY and quarantined by CLEAN-01 -- never used: obj=… tex=…)`
  — proving the flat fields are quoted for diagnosis only, never opened.

---

## 4. Semantics preserved (DERIVED, to be re-verified by G04)

1. Render loop, `--only` filter, direction naming (`sid.png` / `sid_%03d.png`),
   camera/light/world setup, postprocess hook and cleanup are unchanged.
2. On a healthy tree the tool's stdout is unchanged: the only new print is the
   labelled diagnostic, which fires only on a missing bucket path (0 entries).
3. No fallback to quarantined art is possible on any code path: `import_obj()`
   and `make_material()` receive only bucket-derived paths; the flat fields are
   referenced solely inside the diagnostic `print()`.
4. The FLAT legacy branch of `asset_paths.gd` (FOLD-06) and `world.gd`'s
   diagnostic sprite fallback (FOLD-07) are out of this tool's scope and were
   not touched.
5. No donor constant, threshold, assertion or synthetic noise introduced.

---

## 5. G04 gate list — **G04 only**, not run by this agent

Pre-flight every run: `python variant3d\tools\godot_runner.py status`
(pending=0, `godot.lock` free, `now_serving == next_ticket`); unique id per run;
one Godot at a time (CHARTER.md:63-65).

1. **G9a — single-sid bake A/B (CLEAN-01 §6 G9 blocker).** From `variant3d`,
   bake one sid through the migrated tool, e.g.
   `blender --background --factory-startup --python tools/render_models.py -- --manifest assets/models/manifest.json --out <out> --only ruscen --engine eevee`,
   and confirm a sprite is produced from the bucket tree with **no** `SKIP …`
   diagnostic line. Compare its PNG bytes to a pre-CLEAN-01 baseline bake of the
   same sid (expected byte-identical; note Blender version/engine must match).
2. **G9b — full 299 bake dry probe.** Run with a throwaway `--out` and assert
   `done: 299 sprites` (or the per-direction count for multi-direction sids) and
   **0** `SKIP` lines — proves no entry silently falls back. This is the
   decisive proof that CLEAN-01's quarantine no longer breaks the bake tool.
3. **G1–G8 from CLEAN-01 §6 unchanged and still blocking** (editor import pass;
   parse of `world.gd`/`world3d_relief.gd`/`asset_paths.gd`; selftest 29/29,
   uitest 17/17, `t_render_mode`, `assert_clean CLEAN`, `t_anim_metrics`,
   `t_naval`, `t_season_overlay`; anim keep-set; sprite `flat_fallbacks=0`;
   relief QA; 3D regression; windowed 3D + 2D captures).
4. **Refusal condition.** Any missing bucket path, any `SKIP …` diagnostic on a
   shipped sid, any non-identical bake byte diff, or any standing-gate regression
   ⇒ stop; do not delete `inbox/cleanup_20261125/`. Permanent deletion needs
   explicit owner instruction after all gates are green.

No Godot/runner/capture was performed here; all runtime items above are
**UNVERIFIED** until G04 executes them.

---

## 6. Attestation

- **Only one owned file edited**: `variant3d/tools/render_models.py`. Backup,
  two `%TEMP%` verifiers and this report are the only other writes. No manifest,
  `.gd`, asset, test, config, `.import`, `.godot/**` or `app/**` change.
- **No permanent deletion.** CLEAN-01's 5,574 quarantined files are untouched and
  restorable by `inbox\cleanup_20261125\undo.ps1`.
- **No Godot process, no runner job, no Blender render, no capture, no donor file
  read/copied.** All verification was static/system-Python against the real
  resolver functions.
- **No test weakened, no synthetic noise, no invented donor constant.**
- **No donor parity claim.** Render-byte equivalence is argued from source-byte
  SHA-256 identity (§3.2) and must be confirmed by G04's actual bake A/B.
- Files written: this report; `inbox/backup/render_models.py.bak-CLEAN02`;
  edited `variant3d/tools/render_models.py`; throwaway
  `%TEMP%\opencode\clean02_verify.py` and `clean02_diag_test.py`.
- **Staying available** for COORD follow-up (G04 A/B support, rollback to the
  backup, or further gate prep).

*End of CLEAN-02 report.*
