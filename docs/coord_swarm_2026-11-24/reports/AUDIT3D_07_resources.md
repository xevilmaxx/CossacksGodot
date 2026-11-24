---
id: AUDIT3D-07
owner: AUDIT3D-07
scope: "Resource/project integrity of variant3d/ — project.godot, .import sidecars, hardlinks, res:// path resolution, .gdignore, fresh-clone behaviour, drift vs app/"
date: 2026-11-24
status: complete (audit only; no source edits, no git commands)
---

# AUDIT3D-07 — Resource / project integrity of `variant3d/`

## Scope & method

- Read `variant3d/project.godot` and `app/project.godot` in full; diffed them; checked `[application]`, `[display]`, `[rendering]`, autoloads, input map, features.
- Scanned **all 78** `variant3d/**/*.gd` with a regex for quoted strings containing `res://`; resolved each against the `variant3d/` project root. Reported 306 references. Strings found only in comments / `push_error` / forbidden-token lists were manually re-classified as false positives; format strings (`%s`, `%d`) were classed `UNVERIFIED` (dynamic).
- Enumerated every file by extension; for each Godot-importable type (png/dds/bmp/ogg/obj/glb/…) checked for a sibling `.import`; parsed every `.import` for its `path=`/`source_file=` cache target and tested existence in `.godot/imported/`.
- Identified hardlinks by NTFS file index (Win32 `GetFileInformationByHandle`) across `app/` and `variant3d/`, cross-checked with `fsutil hardlink list` on samples.
- Enumerated all `.gdignore` files, `.uid` sidecars, and read `.gitignore` to infer fresh-clone composition. **No git commands were run** (charter), so *actually-tracked* status is `UNVERIFIED`.

Counts are from the local working tree on 2026-11-24. Anything requiring git history or a fresh clone is labelled `UNVERIFIED`.

## Evidence table

| ID | OBSERVATION (with `path:line`) | Classification / impact |
|----|--------------------------------|-------------------------|
| E1 | `variant3d/project.godot:8` `run/main_scene="res://scenes/main.tscn"`; `scenes/main.tscn:3` `ext_resource ... res://scripts/main.gd` — both exist. | OK. Main scene graph resolves. |
| E2 | `variant3d/project.godot:9` `config/features=PackedStringArray("4.4","GL Compatibility")`; `:15-19` 1280×720, resizable, `canvas_items`/`expand`; `:25-28` `gl_compatibility` renderer + clear colour. `app/project.godot:9,15-19,25-28` byte-identical. | **No drift** in features/window/rendering. No gameplay or rendering change from `project.godot`. |
| E3 | Only diff: `variant3d/project.godot:6-7` name/description vs `app/project.godot:6-7`. | Cosmetic only. |
| E4 | Neither `project.godot` declares `[autoload]` or `[input]`; 0 uses of `InputMap`/`is_action_pressed` in `variant3d/scripts/*.gd`, 15 raw `is_key_pressed`/`is_mouse_button` uses. | No autoload/input-map drift possible; input is raw-key in both. |
| E5 | `variant3d/config.json` vs `app/config.json`: only added `"render_mode": "3d"` + one doc line. Documented port extension, no donor key. | Intentional, not drift. (Matches charter established fact.) |
| E6 | 306 quoted `res://` refs in 78 `.gd`: **278 resolve**, **28 do not**. Of the 28: 9 dynamic `%s/%d` (UNVERIFIED), 19 static (see E7–E12). | No static `load()`/`preload()` of a real runtime asset is broken. |
| E7 | 3 static non-resolving paths are *guarded legacy fallbacks*, never reached because the primary path exists: `scripts/data.gd:266` (OK) → `:268` `res://assets/models/anim/sco_units.json`; `scripts/game.gd:1494`/`:1525` (OK) → `:1496`/`:1527` `res://assets/models/anim/buildings.json`. All guarded by `FileAccess.file_exists`. | Dead branches, benign. |
| E8 | 7 strings are **not resource references** (false positives): `scripts/input_controller.gd:114`, `scripts/main.gd:947,958`, `scripts/world3d_terrain.gd:61`, `tests/t_fx3d.gd:28,29`, `tests/t_upgrades.gd:87` — all comment / `push_error` / forbidden-token text. Their real loads (`:112`, `:945`, `:956`) resolve. | No action. |
| E9 | 7 write-target paths under a **missing `shots/` dir** (dir absent locally; `.gitignore:91` `variant3d/shots/**` excludes it from fresh clone): `scripts/main.gd:1539` (`bench.json` — no dir creation, falls back to stdout at `:1546`), `scripts/terrain3d_sandbox.gd:6,12,13,16,17`, `tests/mill_render_test.gd:71`. | Reports/captures silently lost on fresh clone. |
| E10 | `scripts/world3d_entities.gd:53` `GLB_DIR="res://assets/models/glb/"` — dir absent, 0 `.glb` files in variant3d. Uses at `:118`, `:293` are guarded by `ResourceLoader.exists` (`:294`); falls back to `.obj` (`:305`). | Dead extension point, benign. |
| E11 | `tests/_v716_probe.gd:6` `res://tests/results/v716_probe.json` — output file not yet generated; `tests/results/` exists. | Not a bug. |
| E12 | 9 dynamic paths UNVERIFIED: `scripts/input_controller.gd:73` `cursor_%s.bmp`; `scripts/world.gd:1019` `blocks/%s.png`, `:399` `sprites/%s_%03d.png`, `:407,411-413` `sprites_hi/%s.png`, `:503` `anim%d`, `:735` `decals_png/%s%sd.png`. | Runtime string-built; cannot statically verify. `scripts/world.gd:_load_env_tex` decodes via `Image.load_from_file` with `FileAccess.file_exists` guard — deliberate no-import workaround (see E16). |
| E13 | `.import` coverage of importable source types: **2931/2931 PNG**, **325/325 OGG**, **116/116 OBJ**, **13/13 BMP** have sidecars. **468 DDS have none**, but all sit in `.gdignore` dirs (`assets/terrain/decals`, `decals_dds`) and are never `load()`-ed (only mentioned in comments at `scripts/world.gd:3,6,3604`, `scripts/world3d_fx.gd:190`). | Complete where required; DDS omission intentional. |
| E14 | **2 orphan `.import`**: `shot_final.png.import`, `shot_zoom.png.import` at variant3d root (also present at app root). Their `source_file="res://shot_*.png"` and hashed `.ctex` targets do not exist anywhere in the repo. | Harmless copy leftovers; editor may log missing-source warnings. |
| E15 | Import cache state: 3387 `.import` sidecars; only 1288 cache destinations present in `.godot/imported/` (847 `.ctex` + 325 `.oggvorbisstr` + 116 `.mesh`); **2099 texture sidecars point to absent `.ctex`**. All 15 *statically loaded* textures checked (`tile_low/highground`, `splat_albedo`, `grass1`, `icons.bmp`, `iconsunits.bmp`, 4× overlay, 3× diffusewaves, 2× envfield) have CACHED destinations. | Cache is gitignored (`.gitignore:2,88`) so regenerated on editor open — **not a fresh-clone break**. Dynamic sprites handled by E16. `UNVERIFIED`: headless run without prior editor import. |
| E16 | `scripts/world.gd` `_load_env_tex` comment + body: "ASSET-2 ships .import files whose .ctex cache entries are absent … load() returns null … Decode the source PNG directly when it is on disk"; uses `FileAccess.file_exists` → `Image.load_from_file(globalize_path)` → `load(path)` fallback. Same workaround documented at `scripts/world3d_terrain.gd:60-64`. | Known, handled condition — explains E15 without functional break. |
| E17 | Hardlinks: of 8298 variant3d files (excluding `.godot/`), **3999 are NTFS hardlinks to `app/`** — png 2930, dds 468, ogg 325, mtl 116, obj 116, json 19, bmp 13, lib 4, mat 4, `.gdignore` 2, `.TMP` 2; **4299 are real/unique copies** (mostly `.import`, `.md5`, `.ctex`, `.uid`, scripts, docs). Verified e.g. `variant3d/assets/models/anim/buildings/buildings.json` ≡ `app/.../buildings.json`. `project.godot`, `config.json`, `scripts/main.gd` are real divergent copies. | Git does not preserve hardlinks: a fresh clone gets independent copies. Local hazard only — editing a shared asset in one project silently changes the other. |
| E18 | 6 `.gdignore`: `.godot/.gdignore`, `assets/models/anim/.gdignore`, `assets/models/sprites/.gdignore`, `assets/models/sprites_hi/.gdignore`, `assets/terrain/decals/.gdignore`, `assets/terrain/decals_dds/.gdignore` (last has explanatory comment: raw donor DDS, runtime uses `decals_png`). 2D bake dirs correctly excluded. | OK — consistent with charter scope. |
| E19 | Stale `.import` inside `.gdignore` dirs: `assets/models/anim` 1849 png + 1849 `.png.import`, `sprites` 179+179, `sprites_hi` 90+90. Godot skips these folders; sidecars are inert locally. | Inert, but see G1. |
| E20 | `.gitignore:114-119` excludes all `variant3d/assets/models/{anim,sprites,sprites_hi}/**/*.png` **and** their `.png.import` — 4236 files locally (2118 PNG + 2118 sidecar). Those paths are referenced at `scripts/world.gd:399,407,411-413` (2D fallback) and `tests/t_sheet_load.gd:8-12` (normal `load()`). | **P1 conditional** — fresh-clone omission if not already force-tracked (`UNVERIFIED`, no git). 3D default path unaffected. |
| E21 | 17 `.gd` files lack `.uid` sidecars — almost all new 3D files (`anim3d.gd`, `camera3d.gd`, `hud3d_adapter.gd`, `picking3d.gd`, `world3d_{entities,fog,fx,terrain}.gd`, and 3D tests). `.tscn` references scripts by path (E1). | Editor import state incomplete; Godot regenerates `.uid` on open. Low risk. |
| E22 | 2 stray import temp files: `assets/models/anim/buildings/rus_sta_s4.png.import~RF139ced6.TMP`, `rus_sto_dead.png.import401825162.tmp`. | Harmless cruft; `.gitignore` ignores `*.tmp` but not `*.TMP` on case-sensitive hosts. |

**Separation of OBSERVATION vs INFERENCE:** E1–E22 are direct observations from the local tree. The *fresh-clone consequences* in G1/G2 and the "no break" conclusion for E15 are **INFERENCES** from `.gitignore` and Godot's documented import behaviour; they are `UNVERIFIED` where a git clone or headless run would be required to prove them.

## Ranked gaps

**P0 — none confirmed.** No real static `load()`/`preload()` of a runtime asset is broken; both `.tscn` files resolve; all statically loaded textures are cached; import sidecars are complete for every Godot-importable source type. Nothing found that blocks acceptance on resource grounds.

| # | Rank | Gap | Evidence | Smallest fix (donor-grounded) |
|---|------|-----|----------|-------------------------------|
| G1 | **P1 (conditional / UNVERIFIED)** | Fresh clone may omit 4236 2D-bake PNG + `.import` files under `anim/`, `sprites/`, `sprites_hi/`, which runtime 2D fallback and `t_sheet_load` test reference. 3D default path unaffected. | E19, E20; `.gitignore:114-119`; `scripts/world.gd:399,407,411-413`; `tests/t_sheet_load.gd:8-12` | No new art: `git add -f` the exact already-present files that are byte-identical hardlinks to tracked `app/` copies (or narrow the ignore rule to `.png.import` only). If already tracked, no action — confirm tracking status first. |
| G2 | **P2** | `shots/` output dir absent on fresh clone; 7 write targets lack dir creation — bench/capture reports silently lost (bench degrades to stdout). | E9; `scripts/main.gd:1539,1546`; `scripts/terrain3d_sandbox.gd:6,12,13,16,17`; `tests/mill_render_test.gd:71` | One line before each write: `DirAccess.make_dir_recursive_absolute("res://shots")`. No donor data needed. |
| G3 | **P2** | 2 orphan `.import` files with no source PNG or cached `.ctex` (copy leftovers from app). | E14 | Delete `variant3d/shot_final.png.import` and `shot_zoom.png.import`. |
| G4 | **P2** | 17 new 3D `.gd` files have no `.uid` sidecar (incomplete editor import state). | E21 | Open project in Godot once / re-import, or copy the generated `.uid` from editor cache. Scripts are referenced by path so no immediate break. |
| G5 | **P2 (note only)** | 2099 texture sidecars reference uncached `.ctex`; cache is gitignored and regenerated; dynamic loads handled by E16. | E15, E16 | None required. If acceptance runs headless without editor import, run one editor import pass first (AUDIT3D-09). |
| G6 | **P2 (note only)** | 3 guarded legacy flat fallback paths that can never resolve (primary paths exist). | E7 | Optional cleanup: delete the fallback lines. |
| G7 | **P2 (note only)** | `GLB_DIR` → non-existent `assets/models/glb/`; 0 `.glb` in variant3d; guarded, falls back to OBJ. | E10 | Optional: remove constant or add the converted `.glb` meshes that `.gitignore` explicitly permits (`app/assets/models/glb/` is un-ignored for V7-2). |
| G8 | **P2 (note only)** | 2 stray import temp files in `assets/models/anim/buildings/`. | E22 | Delete them; ignore `*.TMP` case-insensitively. |
| G9 | **P2 (note only)** | 468 DDS without `.import` — intentional: `.gdignore` dirs, never `load()`-ed. | E13, E18 | No action. Do not "fix" (would pull donor-adjacent raw decals into Godot import). |
| G10 | **P2 (observation, cross-scope)** | 3D variant inherits `gl_compatibility` renderer from the 2D app (both identical). Compatibility renderer caps some 3D features (no SSAO/SSR/volumetric fog). Not drift, but a 3D fidelity consideration. | E2, E4; `variant3d/project.godot:25-26` | None from this lane; see AUDIT3D-05/09. |

## Smallest donor-grounded fix (summary)

No new art or donor binaries are needed for any gap. The only fix with real consequence is **G1**: force-track (or un-ignore) the exact PNG/sidecar files already on disk, which are byte-identical hardlinks to the tracked `app/` copies — i.e. reuse donor-derived data already in the repo. Every other item is a one-line hygiene edit (G2/G3/G8) or an editor re-import (G4). Do not add or regenerate DDS/GLB assets from the private-use donor (charter hard rule).

## Open questions

1. **Are the 4236 ignored PNG/`.import` files already force-tracked in git?** `UNVERIFIED` — no git commands permitted (charter). Decides whether G1 is a real break or a non-issue.
2. **Does acceptance boot a fresh clone headless without an editor import pass?** If yes, any static texture whose `.ctex` is absent would fail `load()`. `UNVERIFIED` — AUDIT3D-09 owns runtime proof.
3. **Does 3D (`render_mode="3d"`, the variant3d default) ever execute the 2D sprite fallback at `scripts/world.gd:399-413`?** If never, G1's gameplay impact is test-only (`t_sheet_load.gd`).
4. **Is `render_mode` a runtime switch that reloads resources, or fixed at boot?** Affects whether a fresh-clone 2D toggle could hit the missing bake dirs at all.
5. **Should the 2 orphan root `.import` files be removed in both `app/` and `variant3d/`?** They are identical leftovers in both projects; a single-lane deletion could reappear via a re-copy sync.
