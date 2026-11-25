---
id: FOLD-06
ticket: "ASSET ORGANIZATION integration — five-folder bucket migration"
title: "FOLD-06 — implement nation/shared bucket tree, additive resolver map, reversible copy-only migration"
owner: FOLD-06 subagent
created: 2026-11-25
status: DELIVERED__IMPLEMENTED__NO_GODOT__NO_RUNNER__NO_DELETION_OF_ORIGINALS
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROX"]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, FOLD_01_folder_split.md, FOLD_02_path_audit.md, FOLD_04_anim_usage.md, FOLD_05_all_folders.md, C01_asset_impl.md]
authority: "FOLD_05_all_folders.md supersedes FOLD-01 for bucket names and the 37/262 count; C01_asset_impl.md:6,464-470 contains the RELEASE statement."
parity_guard: "Folder layout is organization only. No donor GPU A/B frame and no capture were produced; visual/donor parity stays UNVERIFIED (CHARTER.md:57-58,122-130)."
scope: "Exclusive owned files only: variant3d/assets/models/**, manifest.json, world3d_entities.gd, world3d_fx.gd, anim3d.gd (left byte-identical), tools/convert_models.py; one report; two inbox ledgers; backups under inbox/backup/."
---

# FOLD-06 — implementation report

> [!IMPORTANT]
> Oxide rule: **copy, never move**; the flat originals are still on disk and
> byte-identical to the pre-migration backup. No Godot was launched and no
> runner job was submitted (WAVE_G_CHARTER.md:31). Every downstream runtime
> claim is **UNVERIFIED** until G04 reimports and re-runs the gates.

## 0. Gate check and authority (OBSERVED)

1. C01-ASSET's report landed with `status: DELIVERED__IMPLEMENTED__NO_GODOT__
   NO_RUNNER__NO_DONOR_COPY__RELEASED` (`C01_asset_impl.md:6`) and an explicit
   release of `variant3d/assets/models/**`, `manifest.json`, `skin/index.json`
   and `convert_models.py` (`:464-470`). Its 164 checks had 0 failures (`:343`).
2. FOLD-05 landed with the corrected bucket decision: **37 nation / 262
   shared**, `shared/terrain/` (93 `env` + 4 `relief`) instead of FOLD-01's
   `shared/env` + `shared/relief`, `mill_rotor.png` → `shared/buildings`, and
   sprite paths mapped through the same manifest `assets` map
   (`FOLD_05_all_folders.md:25-51,232-264`). This report follows FOLD-05.
3. A first copy pass using FOLD-01's two terrain buckets was executed, then
   **fully rolled back from its own backup before any code edit**; only the
   second, FOLD-05-authoritative pass remains. The stale backup
   `inbox/backup/FOLD06_20261125T150820Z/` is retained for audit, not used.

## 1. Backups taken before edits (OBSERVED)

Authoritative backup: `inbox/backup/FOLD06_20261125T151203Z/`.

| Path in backup | Source |
|---|---|
| `obj/`, `tex/`, `skin/`, `sprites/`, `sprites_hi/` | full `Copy-Item`-equivalent trees, including all `.import` sidecars and both root `.gdignore` files |
| `manifest.json` | pre-migration manifest (299 entries, 235,476 B) |
| `skin_index.json` | pre-migration `skin/index.json` (66 bare `file` values) |
| `scripts/world3d_entities.gd`, `scripts/world3d_fx.gd`, `scripts/anim3d.gd` | current working-tree bytes (post-N04/M03), **not** git HEAD |
| `scripts/convert_models.py` | current working-tree bytes (post-C01) |

Ledgers: `inbox/FOLD06_plan.json` (sid→bucket, 1,849 copy pairs, source/target
SHA-256, sprite alias map, source hashes) and `inbox/FOLD06_undo.json`
(backup root, created files, restore list). The `anim/` tree was **not**
backed up or modified: FOLD-04's 6 live files remain in place (§4).

## 2. Exact changes

### 2.1 New central resolver — `variant3d/scripts/asset_paths.gd` (NEW)

A `RefCounted` script exposing only static path lookups; no nation wiring, no
sim/donor access:

- `bucket_for(sid)` — returns the additive manifest `bucket` string.
- `res_for(sid, ext, suffix="")` — `ext ∈ {obj, tex, glb}`; prefers
  `manifest.assets[ext]`, inserts `suffix` before the extension for
  `<sid>1..4`/`<sid>a`, else composes the legacy flat path.
- `legacy_for(...)` — the old flat `obj/`/`tex/`/`glb/` path.
- `existing(...)` — **checks the mapped bucket path first, then the untouched
  flat original**, returns the first path that exists. This makes the
  copy-only migration safe and makes rollback a data-only operation.
- Lazy one-time `FileAccess` read of `res://assets/models/manifest.json`;
  also indexes top-level `extra_assets` (`mill_rotor`).
- Deliberately contains no 2D-bake path tokens, so the `t_entities3d.gd` /
  `t_fx3d.gd` source-scan gates stay green (verified).

### 2.2 `variant3d/scripts/world3d_entities.gd` (12 path sites, no logic change)

| Current line | Change |
|---|---|
| `:89` | Added `const AssetPaths = preload("res://scripts/asset_paths.gd")`. |
| `:271` | `ROTOR_TEX_IMPORT_PATH` → `res://assets/models/tex/shared/buildings/mill_rotor.png` (FOLD-05 §3.3). |
| `:463`, `:467` | `obj_available` / `glb_available` availability probes use `AssetPaths.existing(...)`. |
| `:472-473` | Tree-pool OBJ **and** TEX probes use resolver. |
| `:481`, `:483` | Stage/scaffold probes use suffix-aware resolver (`"1"`, `"a"`). |
| `:637` | `_default_material()` albedo path via resolver. |
| `:744-745` | **`_nation_mesh_on_disk()` now uses the resolver** — the critical false-fallback path named by FOLD-05 §0.6. |
| `:1063` | Tint-albedo fallback path via resolver. |
| `:1213`, `:1225` | `_mesh_info()` GLB / OBJ loads via resolver. |
| `:1341` | `_load_obj_topology()` `FileAccess` path via resolver (morph index space preserved). |
| `:1955` | `_stage_mesh_info()` path via suffix-aware resolver. |

`OBJ_DIR` / `GLB_DIR` / `TEX_DIR` / `MANIFEST_PATH` constants and the stats
labels at `:473-475` are unchanged; they remain the legacy fallback and
telemetry surface.

### 2.3 `variant3d/scripts/world3d_fx.gd`

- `:86` added the same `AssetPaths` preload.
- `:680-682` replaced the three hard-coded ghost-fallback literals
  (`obj/<sid>.obj`, `glb/<sid>.glb`, `obj/<sid>4.obj`) with
  `AssetPaths.existing(...)` calls. The provider path (`:657-672`) is untouched.

### 2.4 `variant3d/scripts/anim3d.gd`

**No code change** — SHA of current file equals the backup. `SKIN_INDEX_PATH`
and `SKIN_ASSET_DIR` stay at `skin/` root; the 66 index `file` strings now
carry bucket-relative paths, which the existing concatenation
`SKIN_ASSET_DIR + file_name` (`:828`) resolves unchanged.

### 2.5 `variant3d/assets/models/manifest.json` (additive only)

- **All 299 original fields, including the absolute flat `obj` and
  `texture_png` strings, are byte-identical to the backup** (verified field by
  field). Only new keys were added:
  - per entry: `bucket` (`"rus/land_units"`, `"shared/terrain"`, …) and
    `assets` with `obj`, `tex`, and where applicable `skin`, `sprite`,
    `sprite_hi`, all `res://`-rooted;
  - top-level `extra_assets.mill_rotor` → bucket `shared/buildings`, tex
    `res://assets/models/tex/shared/buildings/mill_rotor.png`.
- Result: `obj` 299, `tex` 299, `skin` 66, `sprite` 123 (aliased sids included;
  116 unique sprite stems), `sprite_hi` 90. Sprite values use the alias-resolved
  key (`musk18 → serdiuk`, `officer18/drummer/priest → officer`,
  `howitzer/mortar → cannon`, `grenadier → roundshier`), per FOLD-05 §3.1.

### 2.6 `variant3d/assets/models/skin/index.json`

- Stays at `skin/index.json` root. `count=66`, `total_bytes`, `skipped` (7
  ships), `failed` and every entry field except `file` are unchanged.
- 66 `file` values changed from bare names to e.g.
  `"rus/land_units/pearus.json"`, `"shared/land_units/peasant.json"`.

### 2.7 Physical copies — 1,849 files, 0 originals deleted

| Folder | Copies | Content |
|---|---:|---|
| `obj/<bucket>/` | 878 | 299 `.obj` + 299 `.mtl` + 280 `.obj.import` |
| `tex/<bucket>/` | 367 | 193 `.png` + 174 `.png.import` (192 manifest basenames + `mill_rotor.png`) |
| `skin/<bucket>/` | 66 | 66 skin JSONs |
| `sprites/<bucket>/` | 358 | 179 `.png` + 179 `.png.import` |
| `sprites_hi/<bucket>/` | 180 | 90 `.png` + 90 `.png.import` |

Bucket partition: **37 nation-specific / 262 shared**, including
`shared/terrain` = 97 (93 `env` + 4 `relief`); no `shared/env` or
`shared/relief` directories exist in the authoritative pass.

Rewrites applied **only to the copies**:

- `.import` (1,022 files): `deps/source_file` → mapped `res://` path;
  `path` and `dest_files[...]` cache hash → `md5(utf-8(new res path))`; `uid`,
  params and all other bytes preserved; no `res://res://`.
- `.mtl` (299 files): `map_Kd ..\tex\<name>.png` →
  `map_Kd ..\..\..\tex\<bucket>\<name>.png`. **Correction during this ticket:**
  an initial same-folder form (`map_Kd <name>.png`) was found by verification
  to resolve into the `obj/` tree, not the mirrored `tex/` tree; all 299 copies
  were corrected to the three-level-up form and re-verified (0 dangling refs).
- Sprite PNGs were **copied byte-wise**, never edited in place, so the NTFS
  hardlinks shared with `app/assets/models/{sprites,sprites_hi}/` are intact.

### 2.8 `variant3d/tools/convert_models.py` (minimal opt-in resolver)

- `:614` new `load_bucket_map()` reads the shipped manifest's `bucket` field
  (299 sids, no nation logic, no donor read).
- `:653` new `--bucket-layout` flag; **default off**, so C01-ASSET's
  280-entry / G0-G1 byte-identical pipeline is unchanged.
- `:666-668` load the map only when the flag is set; unknown sids get a
  `WARN no shipped bucket ... writing flat` and never invent a bucket.
- `:704-716` write `obj/<bucket>/` and `tex/<bucket>/`, emit the same-folder
  cross-root `map_Kd` reference and mapped `obj`/`texture_png` strings.
- `:728` emit additive `bucket` + `assets` fields in generated entries.
- `python -m py_compile` exit code **0**.

## 3. Verification output (static, no Godot)

Command: `python %TEMP%\opencode\fold06_verify.py` (throwaway, outside repo).

```
CHECKS=12976 FAIL=0
```

What those checks cover:

- manifest: 299 entries; every pre-existing field deep-equal to backup; only
  `bucket`/`assets` added; `game` unchanged; 37 nation / 262 shared;
  `shared/terrain` = 97; no superseded buckets; all 299 flat `obj` and
  `texture_png` **and** all 299 mapped `assets.obj`/`assets.tex` resolve on disk.
- skin index: root file present; 66 entries; `count`, `total_bytes`, `skipped`
  and every non-`file` field unchanged; all 66 bucket-relative `file` paths exist.
- copy ledger: all 1,849 targets present; 827 unrewritten copies byte-identical
  to their sources; 1,022 rewritten copies have the exact expected logical form.
- dangling refs: 0 stale `source_file`, 0 `res://res://`, 0 bad cache hashes,
  0 bad `map_Kd`, 0 bad `mtllib`, across all copied bucket trees.
- originals: all five flat trees have the exact backup file set and
  byte-identical contents, except the intentionally edited `skin/index.json`.
- code: no forbidden 2D-bake tokens in the two runtime modules; resolver used
  by `_nation_mesh_on_disk()` and the ghost fallback; rotor path mapped;
  `py_compile` clean; `load_bucket_map()` returns 299 sids (97 `shared/terrain`).
- `anim/`: 5 live JSONs + `.gdignore` still present (FOLD-04's 6 tracked files);
  `sprites/.gdignore` and `sprites_hi/.gdignore` still at their roots.

## 4. Risks and blocked follow-ups (UNVERIFIED unless stated)

1. **G04-owned import/gates.** 19 C01-ASSET OBJ/PNG still have no `.import`
   sidecar; the 1,022 rewritten sidecars need Godot reimport so `.godot/imported`
   regenerates with the new hashes. `uid` was preserved. No run by this agent.
2. **MTL depth correctness is UNVERIFIED.** The rewritten `..\..\..\tex\<bucket>\`
   reference resolves on disk (verified) but Godot's OBJ importer behaviour
   with it is not; runtime overlays albedo from the resolver anyway
   (`world3d_entities.gd:1063`), so the main exposure is offline Blender bakes.
3. **`world.gd` not edited (not owned).** Sprite paths at `world.gd:399,407,
   411-413` still compose the flat root. Because originals were **not**
   deleted, 2D sprites keep working; a later owner must switch that module to
   `manifest.assets.sprite` / `sprite_hi` (with flat fallback) before cleanup.
   FOLD-05 §4.3's alternative (`sprites/index.json`) was **not** chosen.
4. **`world3d_relief.gd` not edited (not owned).** `:44` `OBJ_DIR` and `:341`
   `OBJ_DIR + sid + ".obj"` would miss bucketed `terrainmeshN` after originals
   are removed. Needs a separate owner with the same resolver.
5. **Case-insensitive win32 vs case-sensitive export** — all target names are
   lowercase; no collision was found (UNVERIFIED on exported Linux).
6. **Hardlinks** — copies were made byte-wise; `app/` tree untouched. Any
   future in-place edit of those PNGs would alter `app/`; do not.
7. **Aliases remain aliases** — `peaukr`/`peasant` and `serdiuk`/`musk18`
   duplicate bytes under different buckets by design; dedupe is an owner
   decision, not this ticket.
8. **No deletion** — flat originals, including all stale `.import` sidecars,
   remain intentionally. Cleanup is a later ticket after gates.

## 5. Rollback commands (PowerShell, from repo root)

Authoritative backup: `inbox/backup/FOLD06_20261125T151203Z`. These commands
restore the **pre-FOLD-06** bytes; they do not touch `app/` or `anim/`.

```powershell
$B = 'inbox/backup/FOLD06_20261125T151203Z'
Copy-Item -LiteralPath "$B/manifest.json" -Destination 'variant3d/assets/models/manifest.json' -Force
Copy-Item -LiteralPath "$B/skin_index.json" -Destination 'variant3d/assets/models/skin/index.json' -Force
Copy-Item -LiteralPath "$B/scripts/world3d_entities.gd" -Destination 'variant3d/scripts/world3d_entities.gd' -Force
Copy-Item -LiteralPath "$B/scripts/world3d_fx.gd" -Destination 'variant3d/scripts/world3d_fx.gd' -Force
Copy-Item -LiteralPath "$B/scripts/anim3d.gd" -Destination 'variant3d/scripts/anim3d.gd' -Force
Copy-Item -LiteralPath "$B/scripts/convert_models.py" -Destination 'variant3d/tools/convert_models.py' -Force
Remove-Item -LiteralPath 'variant3d/scripts/asset_paths.gd' -Force
foreach ($d in 'obj','tex','skin','sprites','sprites_hi') {
  Get-ChildItem -LiteralPath "variant3d/assets/models/$d" -Directory |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
}
```

Then have G04 reimport/re-run. The exact created-file list is in
`inbox/FOLD06_undo.json`; the per-sid plan and hashes are in
`inbox/FOLD06_plan.json`. If a later cleanup has already moved the flat
originals aside, restore those from
`inbox/backup/models_FOLD06_predelete/<UTC>/` first (not created by this ticket).

## 6. G04 gate list — **G04 only**, not run here

```powershell
python variant3d\tools\godot_runner.py status
# then, each with a UNIQUE id, one Godot at a time:
python variant3d\tools\godot_runner.py run --id fold06-entities-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_entities3d.gd
python variant3d\tools\godot_runner.py run --id fold06-fx-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_fx3d.gd
python variant3d\tools\godot_runner.py run --id fold06-ghost-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_ghost_final_stage.gd
```

Plus the standing gates from CHARTER.md:129 / FOLD-05 §6: selftest **29/29**,
uitest **17/17**, `t_render_mode`, `assert_clean CLEAN`, `t_anim_metrics`,
`t_naval`, and a 2D capture because `world.gd` still uses flat sprites.

Acceptance:

- `stats.obj_available` does not drop; `mesh_sources_loaded` still contains
  `obj_zup_bbox_normalised` and gains **no** `donor_bbox_proxy`.
- `nation_mesh_usage` reports exact hits for `ruscen`, `pearus`, `pikemanrus`,
  `bavcen`, `musketeer18bav`, `polcen`, `swecen`, `pikeman18swe`.
- Shipped skin count stays 66; no missing-skin errors.
- New `.godot/imported/<new hash>.mesh/.ctex` appear for rewritten sidecars;
  19 C01 assets reimport; no stale-sidecar errors.
- Windowed 3D P0 + real-map captures show no new proxy boxes or seams; 2D
  sprite sets unchanged.
- Any refusal condition ⇒ stop; do **not** move the flat originals aside.

## 7. Attestation

- Only owned files were edited; no `app/**`, `anim/**`, `data.gd`, `game.gd`,
  `world.gd`, `world3d_relief.gd`, test, config or `.godot/**` change.
- No original asset was deleted or moved; the only deletions were FOLD-06's
  own superseded first-pass copies during the pre-code rollback.
- No Godot process, no runner job, no capture, no donor read/write.
- Files written: this report; `variant3d/scripts/asset_paths.gd`; the five
  bucket trees under `variant3d/assets/models/`; `manifest.json`,
  `skin/index.json`, `world3d_entities.gd`, `world3d_fx.gd`,
  `convert_models.py`; `inbox/FOLD06_plan.json`, `inbox/FOLD06_undo.json`,
  `inbox/backup/FOLD06_20261125T{150820Z,151203Z}/`.
- **No donor parity claim.** Visual outcome stays UNVERIFIED until G04 gates.

## 8. HANDOFF

**RELEASED (2026-11-25T16:30:49+01:00): world3d_entities.gd, world3d_fx.gd, convert_models.py to COORD for FCOL03/nation/field work; no further edits by FOLD-06.**

*End of FOLD-06 implementation report.*
