---
title: "GDIGNORE-01 — `.gdignore` markers and missing imported resources in the 3D variant"
area: coord_swarm_2026-11-25
task_id: GDIGNORE-01
job_id: none (read-only audit; no runner job submitted)
owner: read-only build-hygiene worker (subagent)
date: 2026-11-25
status: AUDITED__REPORT_ONLY__NO_EDITS
exit: 0
scope: "report-only — no code, asset, config, .godot, runner or git change"
labels: [observed, derived, inferred, UNVERIFIED]
---

# GDIGNORE-01 — `.gdignore` audit and stale-import load-path risk

## 0. Method and label vocabulary

Read-only `os.walk` / `os.path.getsize` / regex over `variant3d/assets/**`,
`variant3d/.godot/imported/`, `variant3d/scripts/*.gd` and the cited reports;
plus `grep`. No Godot invocation, no runner job, no selftest, no git command,
no `.godot` write, no source/asset edit.

- **observed** — read directly from disk this pass.
- **derived** — arithmetic or deterministic cross-check of observed values.
- **inferred** — explanation consistent with observed evidence but not proven by an engine log.
- **UNVERIFIED** — not proven here (runtime/export behaviour, ownership intent, pending jobs).

## 1. Sources

| # | Source | Use |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-24/reports/V70_scaffold.md` §5, lines 157–183 | Documents only **3** variant `.gdignore` markers (anim, sprites, sprites_hi) and the 5 runtime JSON metrics read via `FileAccess`; states `.gdignore` removes files from the import scan, not from disk. |
| S2 | `docs/coord_swarm_2026-11-25/reports/ASSET_IMPORT_01.md`, lines 17–48, 90–100, 123–135 | Owner error for `mill_rotor.png`, 2,806→2,818 imported files, **2,097** missing-ctex imports unchanged, inference that `.gdignore` is the cause. |
| S3 | `docs/variant3d/README.md` §"No 2D bake pipeline", lines 57–85; runner §129–158 | Dead-weight dirs (`models/anim/**`, `sprites/**`, `sprites_hi/**`), kept dirs (`obj/**`, `tex/**`, terrain blocks/heightmap), and explicit note that copied 2D scripts still `FileAccess`-read five JSONs inside ignored trees. |
| S4 | `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md` §2.1 line 86 (1,849 baked sheets / 269,611,324 B), §2.2 lines 96–112, Table C line 409 (sprite-sheet billboards = PORT APPROXIMATION) | Quantifies the 2D bake set that the markers exclude and declares it non-parity dead weight for 3D. |
| S4b | `docs/coord_swarm_2026-11-24/reports/W29_dead_assets.md:11-45`; `COMPLETENESS_05_shipping.md:61-70`; `IMPROVEMENTS.md:38`; `WAVE2_CHARTER.md:25`; `AUDIT3D_07_resources.md` E13/E18/E19 | The **decals** dead-weight dirs and their 111-B explanatory markers live here, **not** in V72. Source-note: the task's "V72 report on dead-weight dirs" is taken to mean S3 + S4 + S4b; the exact intended document is **UNVERIFIED**. |
| S5 | `docs/coord_swarm_2026-11-25/reports/MOTION_ANIM_01.md` §8, lines 191–243 | Rotor hard-error root cause, direct-`Image.load()` fallback, and the port-to-port copy into `assets/models/tex/`. |
| S6 | `variant3d/scripts/world.gd`, `world3d.gd`, `world3d_entities.gd`, `main.gd`, `game.gd`, `data.gd`, `anim3d.gd` (line refs in §4) | Load-site classification. |

## 2. `.gdignore` inventory (`variant3d/assets/**`)

**observed** — five markers, not the three of S1. Counts include the marker itself and are recursive (a marker excludes the whole subtree).

| Marker (relative to repo root) | Marker bytes | Excluded contents (observed) | Files | Bytes | Sidecars left inside |
|---|---:|---|---:|---:|---|
| `variant3d/assets/models/anim/.gdignore` | 0 | 1,849 PNG sheets + 1,849 `.png.import` + 5 metrics JSON (`buildings/buildings.json`, `buildings/mill_rotor.json`, `land_units/index.json`, `land_units/sco_units.json`, `naval_units/index.json`) + 2 `.TMP` | 3,706 | 271,727,036 | **1,849 `.import`**, 0 `.uid`, 0 `.ctex`, 0 `.md5` |
| `variant3d/assets/models/sprites/.gdignore` | 0 | 179 PNG + 179 `.import` | 359 | 4,064,270 | **179 `.import`**, 0 `.uid` |
| `variant3d/assets/models/sprites_hi/.gdignore` | 0 | 90 PNG + 90 `.import` | 181 | 16,778,472 | **90 `.import`**, 0 `.uid` |
| `variant3d/assets/terrain/decals/.gdignore` | 111 | 6 raw donor `.dds` + 6 orphaned `.uid` | 13 | 8,389,765 | 0 `.import`, **6 `.uid`** |
| `variant3d/assets/terrain/decals_dds/.gdignore` | 111 | 462 raw donor `.dds` + 462 `.uid` + 4 `.lib` + 4 `.mat` | 933 | 635,045,712 | 0 `.import`, **462 `.uid`** |
| **TOTAL** | 222 | — | **5,192** | **936,005,255** (~892.6 MiB) | **2,118 `.import` + 468 `.uid`** |

- The two decals markers carry the identical comment: `# W2-9 / G-A1: raw donor DDS decals + orphaned .uid; runtime uses decals_png/*.png. Godot ignores this folder.` (**observed**; matches S4b). They were added by W2-9, outside the V70 §5 three-marker list — hence the 3-vs-5 documentation drift (**derived**).
- `AUDIT3D_07_resources.md` E18 also reports a 6th marker at `variant3d/.godot/.gdignore`; it is generated-cache state, outside `assets/**`, and was **not re-enumerated** here (**observed from report**).
- No `.ctex` or `.md5` file exists inside any ignored tree; the 468 decals `.uid` are orphaned IDs with no `.import` partner (**observed**). They are dead weight, not missing-ctex candidates.

## 3. Stale-import / missing-resource counts

**observed** — every `.import` inside each ignored tree was parsed (`path=` and `dest_files=`), and each advertised `.ctex` filename was tested for existence in `variant3d/.godot/imported/` (**2,818** files present).

| Ignored tree | `.import` found | Advertise a `.ctex` | `.ctex` **present** | `.ctex` **missing** | No ctex advertised |
|---|---:|---:|---:|---:|---:|
| `assets/models/anim` | 1,849 | 1,849 | 0 | **1,849** | 0 |
| `assets/models/sprites` | 179 | 179 | 0 | **179** | 0 |
| `assets/models/sprites_hi` | 90 | 90 | **21** | **69** | 0 |
| `assets/terrain/decals` | 0 | 0 | 0 | 0 | 0 |
| `assets/terrain/decals_dds` | 0 | 0 | 0 | 0 | 0 |
| **TOTAL** | **2,118** | **2,118** | **21** | **2,097** | **0** |

Exact examples of stale sidecars (**observed**):

- `assets/models/anim/alg/buildings/alg_cen.png.import` → `alg_cen.png-0e89fb4707113120dd7a603a9ca2b27d.ctex` — absent (also spot-checked in S2).
- `assets/models/anim/common/buildings/mill_rotor.png.import` → `mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` — **absent**; source PNG and sidecar both still present.
- `assets/models/sprites/aca.png.import` → `aca.png-2f10d699cbb5181ab6b93bdaf2f37e73.ctex` — absent.
- `assets/models/sprites_hi/bush1.png.import` → `bush1.png-8a8cdc339a9d4240673a4e01414c48e4.ctex` — absent.

Cross-checks:

1. **derived** — 1,849 + 179 + 69 = **2,097**, exactly S2's whole-assets missing-ctex count. Therefore *every* missing-ctex import under `variant3d/assets` is inside a `.gdignore` tree; there are none outside. This is the systemic confirmation requested by the task.
2. Whole-assets context (**observed**): 3,502 `.import` total, 3,005 advertise a ctex, 908 of those ctex present, 2,097 missing; the other 497 advertise non-ctex targets (e.g. `models/obj/aca.obj.import` → `.mesh`) and are excluded from the ctex mismatch count.
3. **derived** — ctex names are `md5("res://" + source_path)`: `md5("res://assets/models/sprites_hi/tree_firsmall2.png") = dba0783f65b0984f072e1913ec1e00e4`, matching the advertised ctex name. A stale sidecar therefore deterministically names a cache file Godot never writes while the marker is present.
4. The **21** present ctex in `sprites_hi` are all `tree_*` env textures (`tree_firsmall2/3/4`, `tree_oak`, `tree_pine*`, `tree_spruce1..4`, `tree_stump1..4`). Why they survive under an active marker is **UNVERIFIED** (likely cache created before the marker landed or during an import with the marker absent — **inferred**). They are locally loadable today but would not be regenerated by a clean `--import` with the marker present (**derived**).
5. Rotor follow-up state (**observed**): `assets/models/tex/mill_rotor.png` (the relocation from S5) exists, 36,081 B, but has **no `.import` sidecar and no ctex** at this read; queue dir `00000462_rotorasset01-import` exists with an empty result folder and no `00000462.json`. Job completion is **UNVERIFIED**. The relocated path is currently safe only because the owner code decodes raw bytes (§4, R2).

## 4. Risky load sites, ranked

Literal-path grep found **26** `res://` references into ignored prefixes across 4 scripts (`world.gd` 18, `game.gd` 4, `data.gd` 2, `world3d.gd` 2), plus dynamic builders (`_anim_dir()`, `_nation_sheet()`, `_sheet()`) that expand into the same trees. One grep hit, `world.gd:735` (`decals_png`), is a **prefix false positive** — `decals_png` is *not* ignored.

Mechanism (**derived**, corroborated by S2/S5): `_res_exists()` is `ResourceLoader.exists(path) or FileAccess.file_exists(path)` (`world.gd:866-868`). A stale `.import` makes `ResourceLoader.exists()` return **true**, so the probe passes, then `load()` requests the absent `.ctex` and Godot emits hard `ERROR:` lines before returning null.

Default render mode is `3d` (`variant3d/config.json:40`), where `main.gd:578-584/1072-1089` constructs `world3d.gd`, not `world.gd`. `world3d.gd:811-820` explicitly says it "never loads from this directory" (only a path string for legacy index resolution). So `world.gd` rows are **dormant on the default 3D path but live if `gameplay.render_mode=2d`** — reachability of that override in shipped play is **UNVERIFIED**.

| Rank | Owner file : line | Path / tree | Call and mechanism | Risk assessment | Label |
|---:|---|---|---|---|---|
| 1 | `scripts/world.gd:628-634` `_mill_rotor()` | `anim/common/buildings/mill_rotor.png` → `1,849` missing | `_res_exists()` then `load()` | Exact owner-error pattern; ctex proven absent. Dormant in default 3D, **HIGH** in 2D mode | observed code; derived risk |
| 2 | `scripts/world.gd:556-560` `_draw_anim()` | `_anim_sheet()` → `res://assets/models/anim/**` | `_res_exists()` then `load()` | Every anim ctex missing; called per moving/dying unit in 2D mode | observed code + counts; derived risk |
| 3 | `scripts/world.gd:664-669` `_bld_anim()` | `anim/**/<bld>_s1..s4.png`, `<sid>.png` | `_res_exists()` then `load()` | Same pattern for every drawn building / construction stage | observed; derived risk |
| 4 | `scripts/world.gd:3154-3165` `_hull_tex()` | `anim/**/<key>_hull.png` (naval) | `_res_exists()` then `load()` | Same pattern for naval hull sheets | observed; derived risk |
| 5 | `scripts/world.gd:3405-3408` | `_anim_sheet(ckey,"death")` → `anim/**` | `_res_exists()` then `load()` | Same pattern for death sheets | observed; derived risk |
| 6 | `scripts/world.gd:398-402` `_load_sprites()` | `res://assets/models/sprites/%s_%03d.png` (179 sheets, all ctex missing) | `_res_exists()` then `load()` | 8 azimuth frames per sid, 2D mode | observed; derived risk |
| 7 | `scripts/world.gd:371-380` `_load_env_tex()` | `sprites_hi/**`, `sprites/**` | `FileAccess.file_exists()` → `Image.load_from_file(globalized)`; fallback `load(path)` at :380 | **Safe locally** (direct PNG decode); fallback would hit missing ctex where raw PNG is absent (export) | observed; export risk UNVERIFIED |
| 8 | `scripts/world3d_entities.gd:1454-1484` `_rotor_material()` | `ROTOR_TEX_IMPORT_PATH` (`tex/`, no sidecar/ctex) then `ROTOR_TEX_PATH` (`anim/`, stale ctex) | `FileAccess.file_exists()` + `Image.load()` on both; null → white quad + one labelled warning | No `load()` → no engine ERROR; visual fallback and export packaging UNVERIFIED | observed; derived safe-locally |
| 9 | `scripts/main.gd:1518-1525`; `scripts/game.gd:1684-1717`; `scripts/data.gd:282-284`; `scripts/anim3d.gd:220-222`; `scripts/world3d_entities.gd:219,586-589,1018` | five metrics JSONs in `anim/**`; donor mask DDS in ignored decal dirs | `FileAccess` raw reads | No import pipeline → no missing-ctex error locally; raw files must be explicitly shipped in an export (S1 §5, S3 note) | observed; export UNVERIFIED |
| 10 | `scripts/world3d.gd:813-820` `_anim_dir()` | `res://assets/models/anim[160]` | String builder only; no `load()` | No risk by itself | observed |
| — | `scripts/world.gd:923-925,1019`, `scripts/game.gd:1756`, `scripts/heightmap_world3d.gd:174-176` | `terrain/water_png/**`, `terrain/blocks/**`, `terrain/structs/**` | `ResourceLoader.load()` | Not ignored; sanity control — not at risk | observed |

## 5. Mitigation proposals — **NOT applied**

Every item below is a proposal for an owner ticket. **No file was edited by this worker.**

| ID | Target / owner | Minimal proposal | Why minimal | Status |
|---|---|---|---|---|
| M1 | `variant3d/scripts/world.gd` — owner **UNVERIFIED** (2D-copy script; V7-4 owns `world3d.gd`/`world3d_terrain.gd` per S3 phase map) | Reuse the existing `_load_env_tex()` direct-`Image.load()` policy for ranks 1–6: probe with `FileAccess.file_exists()`, decode from `ProjectSettings.globalize_path()`, return null + one labelled warning on failure; remove the `load()` calls that the stale `.import` lures into | No asset relocation, no `.gdignore` change, no new art; touches one script's 6 call sites | **Proposed only** |
| M2 | `variant3d/scripts/world3d_entities.gd` — owner MOTION-ANIM-01 (S5) | Keep the direct-bytes rotor path; if an exported PCK is required, either add an explicit raw-PNG include for `assets/models/tex/mill_rotor.png` or have the owner generate its `.import`/ctex via the variant runner in a separate ticket | Does not reintroduce `load()`; avoids pulling ~1,800 bake sheets into the import set | **Proposed only** |
| M3 | `.gdignore` markers — owner V7-0 / W2-9 (S1/S4b) | **Do not remove or narrow** the three sprite markers: that would pull ~1,849 + 179 + 90 stale bake PNGs into Godot's import scan (S5 §8). Narrowing only `common/buildings/` was raised in S2 Q1 and is **not recommended** without an owner decision | Removing the marker is the root-cause inverse of the intended no-2D-bake design | **Proposed only** |
| M4 | 2,118 stale `.import` sidecars — owner **UNVERIFIED** (they are real copies from `app/`, S1 §1) | Optional cleanup: delete sidecars from the variant only, making `ResourceLoader.exists()` false so guarded loads bail out instead of erroring. **Not done** — it changes copied asset state and would need owner approval plus a fresh-clone check | Alternative to M1, not additive to it | **Proposed only; needs approval** |
| M5 | Export/packaging owner **UNVERIFIED** (S1 §5 open question, `COMPLETENESS_05_shipping.md:70`) | If a 3D export preset is built, add an explicit include list for the 5 metrics JSONs and any raw PNGs consumed by `Image.load()` (rotor copy, `sprites_hi` env, atlas PNGs) | Preserves the `.gdignore` cache win while shipping bytes the loaders actually read | **Proposed only; export UNVERIFIED** |
| M6 | 468 orphaned decals `.uid` — owner W2-9 | Leave in place. They advertise no ctex, cause no engine load error, and are tracked/confirmed dead weight (S4b). No cleanup in this ticket | Zero runtime benefit from deletion | **No action recommended** |

## 6. Open questions

1. Is `gameplay.render_mode=2d` ever exercised in the shipped variant or its gates? If never, ranks 1–6 are dormant; if used, they reproduce the owner's rotor error at six more sites. **UNVERIFIED**.
2. Why do exactly 21 `tree_*` `sprites_hi` ctex files exist under an active `.gdignore`? (inferred cache history; no engine log) **UNVERIFIED**.
3. Will the pending `rotorasset01-import` (ticket 462, empty result dir) produce a ctex for `assets/models/tex/mill_rotor.png`, or will that copy remain raw-bytes-only? **UNVERIFIED**.
4. Do exported 3D builds include the raw PNGs and 5 JSONs that `.gdignore` keeps out of the import scan? No export was run. **UNVERIFIED**.
5. Does deleting the 2,118 stale sidecars (M4) affect fresh-clone parity with `app/`, where those sidecars are real copies? **UNVERIFIED**.
6. Which document did the task mean by "the V72 report on dead-weight dirs"? V72 covers bake-sheet size and Table C; decal markers are in W29/COMPLETENESS_05 (§1, S4b). **UNVERIFIED**.
7. Are there dynamic (non-literal) load paths into ignored trees beyond the `_anim_dir()`/`_nation_sheet()`/`_sheet()` chains inspected here, e.g. in `tests/` or `tools/`? Not scanned (scripts-only sample). **UNVERIFIED**.

## 7. Summary

**observed / derived:** five `.gdignore` markers exist under `variant3d/assets/**` (three sprite dirs from V70 §5 plus two decals dirs from W2-9); they exclude 5,192 files / ~892.6 MiB and leave **2,118 `.import` + 468 `.uid`** sidecars on disk. Of the 2,118 ctex-advertising sidecars, **2,097 advertise a ctex that does not exist** in `variant3d/.godot/imported/`; only 21 (`tree_*` in `sprites_hi`) do. The 2,097 figure equals ASSET-IMPORT-01's whole-assets missing count, so the stale-import problem is **entirely** contained in `.gdignore` trees — it is systemic, not a one-off rotor defect.

**inferred:** the engine-error mechanism is the stale sidecar making `ResourceLoader.exists()` true, followed by `load()` requesting an ungenerated ctex. Six `world.gd` sites (rotor, unit/building/naval/death sheets, low-res sprite frames) reproduce that pattern; they are dormant in the default `3d` mode but live under a `2d` override. The active 3D rotor path and the JSON/`FileAccess` consumers already bypass the import pipeline.

**UNVERIFIED:** 2D-mode reachability in shipped play, export inclusion of raw PNGs/JSONs, the pending rotor import job, and the reason 21 ctex survived under an active marker. No game was run and no runtime behaviour was measured.

**No file was edited by this worker.** No source, asset, `.import`, `.uid`, `.gdignore`, `.godot`, config, test, backup or git change was made; no runner job was submitted; the only output is this report.
