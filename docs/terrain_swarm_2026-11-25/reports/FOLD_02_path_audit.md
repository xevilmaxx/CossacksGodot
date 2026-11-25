---
id: FOLD-02
title: "Asset organization — hard-coded OBJ/manifest path-fragment audit"
owner: FOLD-02 (read-only subagent)
created: 2026-11-25
status: DELIVERED
labels: [observed, derived, UNVERIFIED]
---

# FOLD-02 — path audit (read-only)

**Ticket:** asset organization, FOLD-02. Complementary to FOLD-01.
**Scope:** exhaustive grep for hard-coded asset path fragments across
`variant3d/**/*.gd`, `*.py`, `*.json`, `*.cfg`, `*.tscn`, `*.import`, `tests/**`,
`docs/**`, plus the 2D `app/` mirror where it shares the same asset tree, and
`.gitignore`.
**Constraints honoured:** CHARTER.md §3 and WAVE_G_CHARTER.md §"Standing rules":
one report only; **no code edits, no Godot run, no runner job, no donor read**.
All runtime-behaviour predictions are explicitly `DERIVED`/`UNVERIFIED` because
no capture or Godot execution was performed in this ticket.

## 0. Migration scenarios assumed

| ID | Scenario |
|---|---|
| **S1** | OBJ files move **into subfolders under the existing root**, e.g. `assets/models/obj/units/<sid>.obj`, `assets/models/obj/buildings/<sid>.obj`. Root `res://assets/models/obj/` stays. |
| **S2** | The OBJ root itself is renamed/moved, e.g. `assets/models/meshes/obj/...`. |

"The OBJ files move into subfolders" in the ticket reads as **S1**; both are
covered below because S2 additionally breaks `.gitignore` and the `OBJ_DIR`
constant.

## 1. Executive summary (OBSERVED)

1. **Runtime mesh access is code-composed, NOT manifest-driven.** The models
   manifest is read at `world3d_entities.gd:421-435`, but only `sid`, `bbox`
   and `texture` (donor DDS path) are consumed. The manifest's `obj` and
   `texture_png` fields are **never read by Godot runtime code**. Mesh and
   albedo paths are composed from hard-coded constants
   (`OBJ_DIR`, `TEX_DIR`, `GLB_DIR`) at `:84-87` and `:440,449-450,458,460,614,721,1023-1024,1184,1300,1909`.
   → **Updating manifest paths alone will NOT keep the game working.**
   `world3d_fx.gd:678-680` duplicates the OBJ prefix as three literal strings
   and must change in lockstep.
2. **Manifest-driven consumers are safe (update manifest paths only):**
   `tools/render_models.py:397-404` reads `m["obj"]` / `m["texture_png"]`.
   `tools/convert_skins.py:284-329` is manifest-driven but reads donor
   `.mesh`/`.texture`, not OBJ. `anim3d.gd:814-830` is index-driven for skins
   (`index.json` entries carry bare filenames), with a hard-coded prefix
   `SKIN_ASSET_DIR`.
3. **Offline generator hard-codes the flat layout:**
   `tools/convert_models.py:640-641` (`obj_dir = os.path.join(out,"obj")`),
   `:674-678`, `:686-687`, `:696-698`. Re-running it after an S1 migration
   would regenerate flat files and rewrite the manifest, undoing the move.
4. **Two manifests carry absolute Windows paths.** `variant3d/assets/models/manifest.json`
   has **299 entries**, all with `obj` under `...\variant3d\assets\models\obj\`
   and `texture_png` under `...\variant3d\assets\models\tex\` (OBSERVED; 598/598
   referenced files exist on this machine). `app/assets/models/manifest.json`
   has **116 entries**, all under `...\app\assets\models\obj\` / `tex\`.
5. **Per-file `.import` sidecars hard-code source paths.** **280** `.obj.import`
   files carry `source_file="res://assets/models/obj/<sid>.obj"` at line 13;
   all 280 verified consistent. **299** `.mtl` files carry
   `map_Kd ..\tex\<sid>.png` at line 3; all 299 targets resolve today.
6. **19 OBJ files have no `.import` sidecar** (nation-art + relief additions:
   `ruscen, bavcen, polcen, swecen, peaaus, peaeng, peapol, pearus, peasco,
   peaspa, peatur, peaukr, pikemanrus, musketeer18bav, pikeman18swe,
   terrainmesh1..4`) — OBSERVED on disk. Whether `ResourceLoader.exists()`
   resolves them is **UNVERIFIED** (no Godot run); the repository's own
   `NATION_MESH_BLOCKED_EVIDENCE` string at `world3d_entities.gd:216` already
   declares exact nation art absent/blocked.
7. **No live test asserts an exact OBJ path string.** Several live tests assert
   exact *non-OBJ* paths; two are source-scans that forbid 2D-bake path tokens.
   Exact OBJ path assertions exist only as **proposals in docs**, listed in §5.
8. `.gitignore:19` (`obj/`) ignores any `obj` directory; `:123-124`
   (`!variant3d/assets/models/obj/**`) re-includes everything under the existing
   root. S1 subfolders stay tracked; a *new* directory also named `obj` elsewhere
   would be silently ignored.

## 2. Main findings table — functional access

Legend: `[CODE]` = code-composed path (needs code change); `[MAN]` = manifest/
index-driven (update data only); `[GEN]` = generated sidecar/derived file;
`[META]` = prose/telemetry, no runtime effect.
Labels: **O** = OBSERVED (read directly), **D** = DERIVED (breakage reasoning),
**U** = UNVERIFIED (no Godot execution).

| # | Path fragment | file:line | How it is used | What breaks if OBJ files move into subfolders | Required change | Class | Label |
|---|---|---|---|---|---|---|---|
| C1 | `res://assets/models/obj/` (`OBJ_DIR`) | `variant3d/scripts/world3d_entities.gd:84` | Constant root for every runtime OBJ path | **S1:** every composed path misses the flat root → `ResourceLoader.exists()` false; mesh resolution falls to GLB (`:1172-1183`) or `donor_bbox_proxy` (`:1189-1190`). Silent visual regression: no error, only `stats.obj_available → 0` and `mesh_sources_loaded` losing `obj_*`. **S2:** constant itself wrong. | Change the constant to the new root **and** add a sid→subfolder resolver (or switch to a manifest field carrying `res://`-relative paths). Keeping a flat root avoids this entirely. | CODE | O + D/U |
| C2 | `OBJ_DIR + str(sid) + ".obj"` | `world3d_entities.gd:440`, `:449`, `:458`, `:460` | `bind()` availability probes → `stats.obj_available`, `tree_pool_available`, `build_stage_obj_sids`, `build_scaffold_obj_sids` | Telemetry reports zero art; BUILD-ART-C stage/scaffold swaps never resolve even though files exist one level down | Same as C1; do not merely lower a count/threshold (CHARTER no-test-weakening) | CODE | O + D |
| C3 | `OBJ_DIR + sid + ".obj"` | `world3d_entities.gd:721` | `_nation_mesh_on_disk()` probe for nation-specific meshes | All nation candidates report "not on disk" → `exact=false` + fallback label; already BLOCKED, would stay blocked silently | Same as C1 | CODE | O + D |
| C4 | `OBJ_DIR + sid + ".obj"` | `world3d_entities.gd:1184-1186` | `_mesh_info()` loads `Mesh` (primary geometry path) | All units/buildings/resources fall back to bbox proxy; ghost preview and normal rendering lose real geometry | Same as C1 | CODE | O + D/U |
| C5 | `OBJ_DIR + sid + ".obj"` | `world3d_entities.gd:1300-1304` | `_load_obj_topology()` `FileAccess.open()` for morph index space | Returns empty topology → donor-pose morph mesh rebuild (`:_morph_mesh*`) uses wrong/empty index space; flat-root pose data no longer matches the mesh | Same as C1; topology reader must use the same resolver as the mesh loader | CODE | O + D/U |
| C6 | `OBJ_DIR + sid + suffix + ("a.obj" if scaffold else ".obj")` | `world3d_entities.gd:1909-1911` | `_stage_mesh_info()` — `<sid>1..4`, `<sid>1a..4a`, `<sid>a` | Construction stages and scaffold children revert to base mesh; ghost "finished stage" logic (`world3d_fx.gd:667-672`) then misreports source strings | Same as C1, applied to suffixed stems | CODE | O + D/U |
| C7 | `res://assets/models/obj/" + sid + ".obj"` (literal, duplicated) | `variant3d/scripts/world3d_fx.gd:678`, `:679` (glb), `:680` (`4.obj`) | Standalone ghost-mesh fallback when no entities provider exists | Ghost fallback returns `null` → no ghost mesh in isolated/parse-probe runs; duplicated prefix drifts from `OBJ_DIR` | Replace with the entities provider where possible, else import/share the same resolver; never leave a second hard-coded copy | CODE | O + D/U |
| C8 | `res://assets/models/manifest.json` (`MANIFEST_PATH`) | `world3d_entities.gd:87`, read `:421-435` | Supplies `sid`, `bbox`, donor `texture` DDS only | S1 (subfolders only): no break — manifest can stay. S2 if manifest also moves: `_bbox` empty → every mesh becomes a proxy and tint-mask source lost | Keep path stable, or update constant; **do not expect it to fix C1-C7** | CODE | O + D/U |
| C9 | `res://assets/models/tex/` (`TEX_DIR`), `TEX_DIR + sid + ".png"` | `world3d_entities.gd:86`, `:449-450`, `:614`, `:1023-1024` | Albedo PNG lookup | Unaffected by OBJ-only S1. If `tex/` is reorganised in the same move, albedo load fails → untinted/white proxies; tree pool probe at `:449-450` also collapses | Update `TEX_DIR` + resolver if tex moves; keep coupled to OBJ plan | CODE | O + D |
| C10 | `res://assets/models/glb/` (`GLB_DIR`) | `world3d_entities.gd:85`, `:1172-1174`, `:444`, `:722` | GLB is tried **before** OBJ | Not broken by an OBJ move; but a GLB hit masks a broken OBJ path, hiding the regression from telemetry. `stats.glb_available` stays misleading | No change required for S1; re-check before claiming "obj regression seen" | CODE | O + D |
| C11 | `res://assets/models/skin/index.json`, `res://assets/models/skin/` (`SKIN_INDEX_PATH`, `SKIN_ASSET_DIR`) | `variant3d/scripts/anim3d.gd:112-113`, `:814-830`, `:843-849` | Reads `index.json` → `entries[].file` (bare names, e.g. `"pearus.json"`) joined onto `SKIN_ASSET_DIR` | Unaffected by OBJ-only S1. If the whole `assets/models/` root is reorganised, both constants break → shipped donor skins fail to register → pose data falls back to donor `.oss` parsing path (already non-production, `:41`) | If moving skin/, update both constants; `file` values stay bare (index-driven) | CODE/MAN | O + D |
| C12 | `res://assets/models/" + "anim/common/buildings/mill_rotor.png"`, `.../tex/mill_rotor.png`, `.../anim/buildings/mill_rotor.json` | `world3d_entities.gd:242`, `:248`, `:249` | Rotor texture/meta paths (telemetry at `:523-525`) | Unaffected by OBJ-only S1; coupled if `tex/` or `anim/` reorganises | Update only if those roots move | CODE | O |

## 3. Manifest / data-file table

| # | Path fragment | file:line | How it is used | What breaks if OBJ files move into subfolders | Required change | Class | Label |
|---|---|---|---|---|---|---|---|
| M1 | `...\variant3d\assets\models\obj\<sid>.obj` (`obj`) — **299/299 entries** | `variant3d/assets/models/manifest.json` (e.g. `:10`, `:29`, `:48`; 299 entries) | Absolute Windows path string per model | **Runtime: nothing** — Godot never reads `obj` (see §1). **Offline:** `render_models.py:401-404` fails to find the mesh → sprite bake skips the model. Docs/QA that cite the string become stale | Update `obj` strings to the new location (prefer repo-relative/`res://`-style over `C:\Users\...` absolute). Mandatory **only** for manifest-driven consumers and if runtime is switched to manifest-driven loading | MAN | O + D |
| M2 | `...\variant3d\assets\models\tex\<sid>.png` (`texture_png`) — **299/299 entries** | same manifest (e.g. `:11`, `:30`, `:49`) | Absolute PNG path per model | Same as M1 for `render_models.py:401`; runtime uses `TEX_DIR`, not this field | Update alongside M1 if `tex/` moves | MAN | O + D |
| M3 | `...\app\assets\models\obj\<sid>.obj` — **116/116 entries** | `app/assets/models/manifest.json` (e.g. `:10-11`) | Legacy 2D-variant manifest; consumed by `app/tools/render_models.py` | Unaffected if only `variant3d/` OBJ move. If the shared/hardlinked `app/` tree also moves, its 116 strings and its converter must update | Update app manifest only if app OBJ also move | MAN | O |
| M4 | `assets/models/obj/<sid>.obj` (as `coord` prose) | `variant3d/assets/models/skin/index.json:1`; all **66** `skin/<sid>.json` `:1` | Documentation string `coord: "donor Z-up metres; vertex i == assets/models/obj/<sid>.obj vertex i ..."` | Stale text only; **no runtime effect** (anim3d loads `verts` arrays, not this string) | Optional textual refresh; keep as provenance if the index space is unchanged | META | O |
| M5 | `assets/models/obj/<sid>.obj` (as `MORPH_COORD` / comment) | `variant3d/tools/convert_skins.py:64`; `variant3d/tools/anim3d.gd:106`, `:19`; `world3d_entities.gd:15`, `:19`, `:26`, `:79`, `:173`, `:209`, `:216`, `:488`, `:517` | Provenance/telemetry strings | Stale text only; no path resolution. Some strings feed `stats` fields consumed by reports | Refresh alongside code if desired; never treat as a path input | META | O |
| M6 | `app/assets/models/obj/mine_gold.obj` (`converted_obj`) | `variant3d/tools/piece_specs/mines_display.json:29`; `app/tools/piece_specs/mines_display.json:29` | Data-only `geometry_source` citation; no reader found for `converted_obj` in any tool | Stale citation only (no code reads the key) | Optional refresh | META | O |
| M7 | `source_file="res://assets/models/obj/<sid>.obj"` | **280** files `variant3d/assets/models/obj/*.obj.import:13` (verified 280/280 consistent) | Godot importer sidecar + `uid://` + cached `res://.godot/imported/<sid>.obj-<hash>.mesh` (`:7`, `:11`, `:14`) | **S1:** sidecars left at old flat path no longer reference the moved files → `ResourceLoader.exists()/load()` false even though the `.obj` is on disk (C1–C7 worsen). `uid://` and `.godot/imported` cache keys go stale. **S2:** root string wrong | Move each sidecar with its OBJ, rewrite `source_file` to the new `res://` path, reimport so the `.godot/imported` cache/uid are regenerated. Do not hand-edit hashes | GEN | O + D/U |
| M8 | `mtllib <sid>.mtl` | **299** files `variant3d/assets/models/obj/*.obj:2` | Resolves relative to the OBJ file | `.mtl` must move with the `.obj`; if left behind, imported mesh material loses its map (warning / default material) | Keep `.mtl` adjacent to the moved `.obj` | GEN | O + D |
| M9 | `map_Kd ..\tex\<sid>.png` | **299** files `variant3d/assets/models/obj/*.mtl:3` (verified 299/299 targets resolve today) | One-level-up relative texture reference | **S1:** adding one subfolder makes `..\tex\` point at `obj/<group>/tex/` → broken texture in Blender bake and possibly imported material. Needs `..\..\tex\` per level | Rewrite `map_Kd` depth per subfolder level (or switch to absolute/`res://`-independent convention) | GEN | O + D |
| M10 | `obj/`, `!variant3d/assets/models/obj/**` | `.gitignore:19`, `:123-124` | `obj/` ignores any dir of that name; negations re-include under the existing root | S1 subfolders remain tracked (`**`). A **new** folder named `obj` elsewhere (e.g. `models/units/obj/`) is ignored silently → files never committed | If S2 introduces another `obj` dir, add a matching negation or rename it | CODE(config) | O + D |

## 4. Offline-tool table

| # | Path fragment | file:line | How it is used | What breaks if OBJ files move into subfolders | Required change | Class | Label |
|---|---|---|---|---|---|---|---|
| T1 | `os.path.join(out, "obj")`, `os.path.join(out, "tex")` | `variant3d/tools/convert_models.py:640-641`; same in `app/tools/convert_models.py:322-323` | Generator hard-codes flat output subdirectories | Re-running the converter after S1 recreates flat `obj/`+`tex/` and writes flat `obj` strings into the manifest, silently undoing the migration. New per-entry `obj_name`/`tex_name` overrides (`:674-676`) cannot express a subfolder | Parameterise output subdir (new flag or manifest field) and update `write_obj`/`write_mtl` (`:677-678`) + `map_Kd` depth | CODE | O + D |
| T2 | `entry["obj"]`, `entry["texture_png"]`, `manifest_path` | `variant3d/tools/convert_models.py:686-687`, `:696-698` | Writes absolute paths into manifest | Manifest strings follow whatever `obj_dir` is; after S1 they must match the new location or downstream manifest-driven tools break | Update with T1 | CODE | O + D |
| T3 | `m["obj"]`, `m["texture_png"]` | `variant3d/tools/render_models.py:397`, `:401`, `:404` | **Manifest-driven** Blender sprite renderer | Breaks if M1/M2 are not updated; safe if they are. Independent of `OBJ_DIR` constant | **Manifest-only** (M1/M2). No code change needed for S1 | MAN | O + D |
| T4 | `--manifest assets/models/manifest.json` (usage text) | `variant3d/tools/render_models.py:7`; `app/tools/render_models.py:7` | Docstring only; real path comes from CLI arg | Stale doc text only | Optional refresh | META | O |
| T5 | `--manifest default=variant3d/assets/models/manifest.json`, `--out .../skin` | `variant3d/tools/convert_skins.py:284-285`, `:296-329` | Reads manifest donor `.mesh`/`.texture`; writes `<sid>.json` + `index.json` | Does not read OBJ → unaffected by S1. Only its `coord` prose (`:64`) goes stale | No functional change for S1 | MAN | O |
| T6 | `"index.json"` default | `variant3d/tools/convert_skins.py:288-290` | Index filename under `--out` | Unaffected | No change | MAN | O |

## 5. Tests — exact path-string assertions

### 5.1 Live tests (OBSERVED)

**No live test asserts an exact OBJ path string or an exact `OBJ_DIR` value.**
Verified by grep over `variant3d/tests/**` for `obj_dir`, `OBJ_DIR`,
`res://assets/models/obj`, `ruscen`, `hall_mesh`, `+ ".obj"` → **no matches**.

| Test | file:line | Exact path string? | S1 impact |
|---|---|---|---|
| `t_entities3d.gd` | `:216-220` | **Forbidden-token scan** of the module source: `"res://assets/models/anim"`, `"assets/models/anim"`, `"models/anim/"`, sprite keywords. Asserts *absence*, not a positive path | None for S1 (paths remain under `obj/`). **Would fail** if OBJ were moved under `assets/models/anim/` |
| `t_fx3d.gd` | `:26-36` | `FORBIDDEN_2D_TOKENS` incl. `"res://assets/models/anim/"`, `"res://assets/sprites*/"` | Same as above |
| `t_anim_metrics.gd` | `:17-18` | Exact `res://assets/models/anim/land_units/index.json`, `.../naval_units/index.json` | None (anim trees untouched) |
| `t_naval.gd` | `:22-24`, `:82` | Exact `res://assets/models/anim/naval_units`, `.../common/naval`, `index.json` | None |
| `t_sheet_load.gd` | `:8-12` | Five exact `res://assets/models/anim/.../*.png` strings | None |
| `t_combo_all.gd` | `:60` | Exact `res://assets/terrain/atlas/tile_index_atlas.manifest.json` | None (terrain) |
| `t_season_overlay.gd` | `:54`, `:59` | Exact summer/winter atlas manifest paths | None (terrain) |
| `t_ghost_final_stage.gd` | `:39`, `:292-294` | SID `"hou"` + API-based mesh availability; detail text mentions "OBJ dir has hou1..hou4 + hou.obj" but does **not** compare a path string | **Behavioural exposure:** if C1/C6 break, `final_art_available` fails (correctly), but no exact-path assertion to update |

### 5.2 Proposed exact-path assertions in docs (not live tests) (OBSERVED)

These would become exact path assertions if authored into live tests; they must
be rewritten with the migration:

| file:line | Exact assertion |
|---|---|
| `docs/terrain_swarm_2026-11-25/reports/N05_nation_qa.md:64` | `want_hall_obj = "res://assets/models/obj/ruscen.obj"` |
| `N05_nation_qa.md:418`, `:464`, `:707` | `Ent.OBJ_DIR + sid + ".obj"`, `hall_mesh_path_expected`, `hall_mesh_path_exists` reported as literal `res://assets/models/obj/...` |
| `docs/coord_swarm_2026-11-25/reports/NATION_DATA_01.md:192` | `FileAccess.file_exists("res://assets/models/obj/" + result + ".obj")` asserted for every resolved target |
| `docs/terrain_swarm_2026-11-25/reports/E02_final_stage_assets.md:99,129-149,178`; `B06_ghost_impl.md:133-143,178`; `E03_ghost_fix_proposal.md:240-250`; `E05_ghost_mesh_naming.md:23-25,164-175,205,259-263`; `E01_ghost_audit.md:123,210` | Expected-path tables/diff excerpts pinning `res://assets/models/obj/<sid>[1..4][a].obj`; documentation, not executable |

## 6. OBSERVED vs UNVERIFIED ledger

**OBSERVED (read from disk this ticket)**
- All constants, literal path strings and line numbers in §§2-4, §5.
- 299 OBJ / 299 MTL / 280 `.obj.import` under `variant3d/assets/models/obj/`;
  19 OBJ lack a sidecar; 280/280 sidecars have `source_file="res://assets/models/obj/..."`;
  299/299 `.mtl` have `map_Kd ..\tex\...` and all targets exist.
- 299/299 variant3d manifest entries use absolute `...\variant3d\assets\models\obj\`
  + `tex\` paths; 598/598 referenced files exist. 116/116 app manifest entries
  use `...\app\assets\models\obj\` + `tex\`.
- Runtime manifest read consumes only `sid`, `bbox`, `texture` (`:424-434`);
  no `get("obj")` / `get("texture_png")` anywhere in `*.gd`.
- No live test contains an OBJ path string assertion.

**DERIVED (reasoned, not executed)**
- S1 breaks C1-C7 and M7/M9; the failure mode is **silent fallback** to GLB or
  bbox proxy, not an error.
- Manifest-only update fixes `render_models.py` but not the game.

**UNVERIFIED (would require Godot / a runner — NOT run here)**
- Whether the 19 sidecar-less OBJ currently resolve via `ResourceLoader.exists()`
  (no Godot execution; the repo's own blocked-art label suggests they do not).
- Whether the imported OBJ material actually uses the `.mtl` `map_Kd` at runtime
  (the module overlays its own albedo from `TEX_DIR` at `:1023-1024`, so the
  runtime impact of M9 may be limited; Blender sprite bake definitely uses it).
- Any FPS/visual delta after a migration — no capture was produced.

## 7. Paste-ready verification command set (AFTER migration)

Run from repo root in **PowerShell** (`python`, not `python3`; `;` not `&&`).
Static checks (§7.1-§7.4) are safe for any agent. **§7.5 is G04-only** — this
ticket did not run Godot and neither should any other Wave agent.

### 7.1 Inventory + stale-fragment scan

```powershell
$obj = 'variant3d/assets/models/obj'
"obj=$((Get-ChildItem -Recurse -File $obj -Filter *.obj).Count) mtl=$((Get-ChildItem -Recurse -File $obj -Filter *.mtl).Count) sidecar=$((Get-ChildItem -Recurse -File $obj -Filter *.obj.import).Count)"
Get-ChildItem -Recurse -File $obj -Filter *.obj | Where-Object { -not (Test-Path -LiteralPath "$($_.FullName).import") } | Select-Object -ExpandProperty Name
rg -n --no-heading 'res://assets/models/obj/|assets\\models\\obj\\|models/obj/' variant3d/scripts variant3d/tests variant3d/tools app/scripts app/tools .gitignore
rg -n --no-heading 'assets/models/obj/' variant3d/assets/models/skin/index.json variant3d/assets/models/skin/*.json
rg -n --no-heading 'res://assets/models/obj|OBJ_DIR|obj_dir' variant3d/tests
```

Expected after a complete migration: the third command reports only the
**new** resolver/constant lines (no flat `res://assets/models/obj/<sid>.obj`
literal in `world3d_fx.gd`); the fourth reports only intentional `coord`
prose; the fifth reports **no** exact OBJ path assertion in live tests.
The first command's "without sidecar" list should be **empty** (baseline today:
19 names listed in §1.6).

### 7.2 Manifest path integrity (both trees)

```powershell
foreach ($mf in 'variant3d/assets/models/manifest.json','app/assets/models/manifest.json') {
  $m = Get-Content -Raw -LiteralPath $mf | ConvertFrom-Json
  $bad = 0
  foreach ($e in $m.models) { foreach ($p in @($e.obj, $e.texture_png)) { if ($p -and -not (Test-Path -LiteralPath $p)) { $bad++; "MISSING $mf $($e.sid) $p" } } }
  "$mf entries=$($m.models.Count) missing=$bad"
}
```

Expected: `missing=0` in both (baseline today: 0/598 and 0/232).
Also confirm the strings now point at the new subfolders, not just that they
exist:

```powershell
$m = Get-Content -Raw 'variant3d/assets/models/manifest.json' | ConvertFrom-Json
$m.models | Where-Object { $_.obj -notmatch 'assets\\models\\obj\\' -or $_.texture_png -notmatch 'assets\\models\\tex\\' } | Select-Object sid,obj,texture_png
```

### 7.3 `.import` sidecars and relative MTL/OBJ references

```powershell
$bad = 0
Get-ChildItem -Recurse -File 'variant3d/assets/models/obj' -Filter *.obj.import | ForEach-Object {
  $txt = Get-Content -Raw -LiteralPath $_.FullName
  $src = ($txt -split 'source_file="res://',2)[1] -split '"',2 | Select-Object -First 1
  if (-not (Test-Path -LiteralPath (Join-Path 'variant3d' $src))) { $bad++; "STALE $($_.FullName) -> $src" }
}
"stale import sidecars=$bad"
$badMtl = 0; $n = 0
Get-ChildItem -Recurse -File 'variant3d/assets/models/obj' -Filter *.mtl | ForEach-Object {
  $line = (Get-Content -LiteralPath $_.FullName | Where-Object { $_ -like 'map_Kd *' } | Select-Object -First 1)
  if ($line) { $n++; $rel = ($line.Substring(7).Trim()) -replace '/','\'; if (-not (Test-Path -LiteralPath (Join-Path $_.DirectoryName $rel))) { $badMtl++; "BAD_MTL $($_.Name) $line" } }
}
"map_Kd lines=$n broken=$badMtl"
$badRef = 0
Get-ChildItem -Recurse -File 'variant3d/assets/models/obj' -Filter *.obj | ForEach-Object {
  $line = (Get-Content -LiteralPath $_.FullName | Where-Object { $_ -like 'mtllib *' } | Select-Object -First 1)
  if ($line -and -not (Test-Path -LiteralPath (Join-Path $_.DirectoryName ($line.Substring(7).Trim())))) { $badRef++; "BAD_MTLLIB $($_.Name) $line" }
}
"broken mtllib=$badRef"
```

Expected: `stale=0`, `broken=0`, `broken mtllib=0` (baseline today: 0/0/0).

### 7.4 Git tracking + static parse smoke (no runner)

```powershell
git status --porcelain -- variant3d/assets/models/obj
"tracked obj files=$((git ls-files variant3d/assets/models/obj | Measure-Object).Count)"
python -m py_compile variant3d/tools/convert_models.py variant3d/tools/render_models.py variant3d/tools/convert_skins.py
```

After S1 the tracked count should be >= 299 and `git status` should show the
moved files as tracked (not ignored) — catches `.gitignore:19` surprises.

### 7.5 Godot gates — G04 ONLY (not run by FOLD-02)

```powershell
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id fold02-verify-entities-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_entities3d.gd
python variant3d\tools\godot_runner.py run --id fold02-verify-ghost-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_ghost_final_stage.gd
python variant3d\tools\godot_runner.py run --id fold02-verify-fx-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_fx3d.gd
```

Acceptance: `stats.obj_available > 0`, `stats.build_stage_obj_sids` /
`build_scaffold_obj_sids` unchanged from baseline, `mesh_sources_loaded`
still contains `obj_zup_bbox_normalised`, all three gates exit 0. Any drop to
zero means C1/C6 or M7 broke silently. Use unique ids; query `status` first;
one Godot at a time per WAVE_G charter.

---

*End FOLD-02. No files edited except this report. No Godot run, no runner job,
no donor read. Runtime impact statements are DERIVED/UNVERIFIED as labelled.*
