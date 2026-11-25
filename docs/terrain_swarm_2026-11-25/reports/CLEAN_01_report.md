---
id: CLEAN-01
ticket: "Wave FOLD integration — CLEAN-01: quarantine superseded flat-root originals under variant3d/assets/models/**"
date: 2026-11-25
owner: "CLEAN-01 subagent — EXCLUSIVE owner of variant3d/assets/models/**"
status: DELIVERED__QUARANTINED__NO_DELETION__NO_RUNNER__NO_GODOT__NO_CODE_EDIT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, reports/FOLD_04_anim_usage.md, reports/FOLD_05_all_folders.md, reports/FOLD_06_impl.md, reports/FOLD_07_impl.md]
scope: "Only variant3d/assets/models/** plus inbox/cleanup_20261125/** and this report. No .gd/.py/.tscn/config/test/manifest edit, no Godot, no runner."
parity_guard: "Organization/cleanup only. No donor GPU A/B frame or capture produced; donor parity stays UNVERIFIED (CHARTER.md:57-58,122-130)."
note: "'CLEAN-01' also names an unrelated coord-swarm queue-hygiene ticket (docs/coord_swarm_2026-11-25/SWARM_BOARD.md:177). This report is the terrain-swarm asset-cleanup CLEAN-01."
---

# CLEAN-01 — reversible quarantine of superseded flat-root originals

## 0. Result (OBSERVED)

**5,574 files / 606,257,818 bytes (578.21 MiB) were MOVED out of `res://` into
`inbox/cleanup_20261125/`.** Nothing was deleted, copied-in-place, or edited —
every move was a same-volume NTFS rename, so the `app/` hardlink side of every
PNG is untouched (verified with `fsutil hardlink list`, §5).

- All five flat roots are emptied of originals; **all bucket trees, `manifest.json`,
  `skin/index.json`, `asset_paths.gd`, `sprites/.gdignore` and `sprites_hi/.gdignore`
  are byte-intact** (§5).
- `anim/` retains exactly **19 files** (the 6 FOLD-04 live files + `mill_rotor.png`
  fallback + 12 index-referenced `common/naval/*.png` needed by the registered
  `t_naval.gd` gate).
- Restore is **one command**: `powershell -ExecutionPolicy Bypass -File
  inbox\cleanup_20261125\undo.ps1` (SHA-256 verified before and after each move).

**No permanent deletion was performed. This ticket does not authorize it.**

---

## 1. Step 1 — FINAL REFERENCE AUDIT (OBSERVED)

Searched every `variant3d` `.gd`, `.py`, `.json`, `.tscn` and `.import` file for
the flat patterns `assets/models/obj/<flat>.obj`, `tex/<flat>.png`, `sprites/`,
`sprites_hi/`, `skin/` (ripgrep over the whole `variant3d` tree, plus targeted
reads of every hit). FOLD-07's "0 flat fallbacks in resolution paths" claim was
**independently re-derived**, not taken on trust.

### 1.1 Verdict per family

| Family | Live flat-path consumer in a resolution path? | Action | Evidence |
|---|---|---|---|
| `obj/` | **No.** All runtime loads go through `AssetPaths`. `OBJ_DIR` is referenced only by telemetry strings. | quarantine flat originals | `world3d_entities.gd:84` const, used only at `:503` `"obj_dir"`; resolver calls at `:463,467,472-473,481,483,637,744-745,1063,1213,1225,1341,1955` (FOLD-06 §2.2). `world3d_fx.gd:680-682`, `world3d_relief.gd:342` use `AssetPaths.existing()`. |
| `tex/` | **No.** `ROTOR_TEX_IMPORT_PATH` is the **bucket** path; `TEX_DIR` is telemetry-only. | quarantine flat originals | `world3d_entities.gd:86` const used only at `:505`; `:271` = `res://assets/models/tex/shared/buildings/mill_rotor.png`. |
| `skin/` | **No.** `anim3d.gd` reads `skin/index.json` at the root (kept) and concatenates bucket-relative `entries[].file` values. | quarantine the 66 bare flat JSONs; keep `index.json` | `anim3d.gd:112-113` (`SKIN_INDEX_PATH`, `SKIN_ASSET_DIR`), `:825-828` (`SKIN_ASSET_DIR + file_name`); verified on disk: `skin/index.json` `count=66`, first entries `rus/land_units/pearus.json`, `shared/land_units/peasant.json`, … |
| `sprites/` | **No live flat fallback.** Resolver-composed mapped path wins first; the flat branch is an explicitly labelled diagnostic that is **dead for every shipped key**. | quarantine 179 PNG + 179 `.import`; keep `.gdignore` | `world.gd:396-399` prefix guard, `:404-414` `_sprite_res_path` (mapped first at `:405-407`, diagnostic at `:408-413`). FOLD-07 §3 independently probed 116 low + 90 hi probes: **0 flat fallbacks**. This pass re-read the same code and confirms mapped-first order. |
| `sprites_hi/` | same as `sprites/` | quarantine 90 PNG + 90 `.import`; keep `.gdignore` | same |
| `anim/` | **Live test consumer of `common/naval/*.png`** — see §1.3. | quarantine only files outside the enumerated keep-set | `t_naval.gd:22-23,57-60,108-168` (registered `manifest.json:122-128`, `ready`). |

### 1.2 Classification of every grep hit (no live flat resolution path found)

| Hit class | Examples | Why benign |
|---|---|---|
| Comments / docstrings / telemetry labels | `anim3d.gd:19,37,106`; `world3d_entities.gd:15-20,175,190,218,336,520`; `world3d_relief.gd:16`; `convert_skins.py:64`; `convert_models.py:9`; all 66 skin JSON `coord` strings; `tools/piece_specs/*.json` | Provenance/labels; never opened as a path. |
| Resolver's intentional legacy fallback | `asset_paths.gd:16-18` (`LEGACY_*_DIR`), `:59-66` `legacy_for()`, `:86-93` `existing()` | **Kept untouched by ticket order.** `existing()` checks mapped bucket path first, flat original second (`:88-92`); it is the designed rollback surface, not a primary resolution path. |
| Mapped bucket paths | `manifest.json` 299 × `assets.obj` / `assets.tex`, 66 `assets.skin`, 123 `assets.sprite`, 90 `assets.sprite_hi`, `extra_assets.mill_rotor`; `convert_models.py:729-730`; `world3d_entities.gd:271` | These are the runtime source of truth (FOLD-06 §2.5) and point **into** the bucket trees, which were retained. |
| Diagnostic-only flat composition | `world.gd:408-413` | Dead for all shipped keys (FOLD-07 §3: `flat_fallbacks=0`). Retained in code; the files it would probe are now in quarantine, so a future map miss becomes loud rather than silently working. |
| Offline-tool absolute manifest data | `render_models.py:387-408` (`m["obj"]`, `m["texture_png"]`) | **Still-needed — reported in §4**, not stripped. |
| `.tscn` | **0 matches** | — |
| `.import` | flat sidecars `source_file="res://assets/models/obj/aca.obj"`; bucket sidecars `source_file="res://assets/models/obj/alg/land_units/mameluke.obj"` | Flat sidecars were moved **with** their flat originals (avoiding stale-sidecar errors); bucket sidecars were left intact with their rewritten mapped paths. |

**Conclusion:** the audit is clean under the ticket's criterion (no live consumer
composes a flat `res://` path in a resolution path). Quarantine proceeded. The
two residual consumers (`render_models.py`, `world.gd` diagnostic) are reported in §4.

### 1.3 What `t_naval.gd` actually requires (anim keep-set derivation)

`naval_units/index.json` has 7 owners (`yacht yachttur fishboat frigate galley
battleship xebec`) with 12 action sheets in `anim/common/naval/`. The test fixes
`OWNER := "yacht"` (`:24`) but FOLD-04 §4 item 4 names all index-referenced sheets
as test-critical. All 12 `common/naval/*.png` were therefore **kept** (2,145,205 B)
— cheap insurance against weakening a registered gate. `t_anim_metrics.gd:17-18`
reads only the two JSON indexes (both kept). `t_sheet_load.gd` is unregistered and
already broken by `.gdignore` (FOLD-04 §3); its `yacht_hull.png` path is satisfied
by the keep-set anyway.

---

## 2. Step 2/3 — what was moved, counts and bytes (OBSERVED)

| Family | Files moved | Bytes moved | MiB | Moved from | Moved to |
|---|---:|---:|---:|---|---|
| `obj` | 897 | 60,452,310 | 57.65 | flat root (299 `.obj` + 299 `.mtl` + 299 `.obj.import`) | `inbox/cleanup_20261125/obj/` |
| `tex` | 386 | 251,249,376 | 239.59 | flat root (193 `.png` + 193 `.png.import`) | `inbox/cleanup_20261125/tex/` |
| `skin` | 66 | 4,489,087 | 4.28 | flat root bare JSONs (`index.json` excluded) | `inbox/cleanup_20261125/skin/` |
| `sprites` | 358 | 4,064,270 | 3.88 | flat root (179 `.png` + 179 `.png.import`; `.gdignore` excluded) | `inbox/cleanup_20261125/sprites/` |
| `sprites_hi` | 180 | 16,778,472 | 16.00 | flat root (90 `.png` + 90 `.png.import`; `.gdignore` excluded) | `inbox/cleanup_20261125/sprites_hi/` |
| `anim` | 3,687 | 269,224,303 | 256.78 | non-keep bake files | `inbox/cleanup_20261125/anim/` |
| **TOTAL** | **5,574** | **606,257,818** | **578.21** | | |

`anim` breakdown: 1,836 bake `.png` (267,430,038 B) + 1,849 `.import` sidecars
(1,792,333 B) + 2 `.TMP` leftovers (1,932 B). Kept: 19 files / 2,502,733 B.

**"Bytes freed" honesty label.** These 606,257,818 bytes were removed from the
Godot `res://` project tree; physical disk usage is conserved until COORD
permanently deletes the quarantine, which this ticket explicitly does **not** do.

### Kept in `variant3d/assets/models/` after CLEAN-01 (all verified on disk)

| Path | State |
|---|---|
| `manifest.json` | **320,756 B**, SHA-256 `cbc22b42…f73d`, untouched (§4) |
| `skin/index.json` | **42,188 B**, SHA-256 `1ccfd820…42cf`, untouched |
| `variant3d/scripts/asset_paths.gd` (outside `assets/models`, listed for completeness) | **3,384 B**, SHA-256 `935ce7db…ddee`, untouched |
| `obj/` bucket tree | 13 dirs / 897 files — byte-intact |
| `tex/` bucket tree | 13 dirs / 386 files — byte-intact |
| `skin/` bucket tree | 13 dirs / 66 files — byte-intact |
| `sprites/` bucket tree | 2 dirs / 358 files + root `.gdignore` — byte-intact |
| `sprites_hi/` bucket tree | 1 dir / 180 files + root `.gdignore` — byte-intact |
| `anim/` | exactly 19 files: `.gdignore`, 5 JSONs, `common/buildings/mill_rotor.png`, 12 `common/naval/*.png` |

Flat-root file counts after the move: `obj` 0, `tex` 0, `skin` 1 (`index.json`),
`sprites` 1 (`.gdignore`), `sprites_hi` 1 (`.gdignore`).

---

## 3. Step 4 — `manifest.json` report: originals still-needed (OBSERVED)

**Not stripped, not edited.** All 299 entries retain their original `obj` and
`texture_png` fields **byte-identically**; every one is an absolute OS path into
the now-quarantined flat tree (verified: `obj` flat=299 / bucket=0, `tex` flat=299
/ bucket=0). Sample (`ruscen`):

```
obj         = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\assets\models\obj\ruscen.obj
texture_png = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\assets\models\tex\ruscen.png
bucket      = rus/buildings
assets.obj  = res://assets/models/obj/rus/buildings/ruscen.obj
assets.tex  = res://assets/models/tex/rus/buildings/ruscen.png
```

- **Runtime path = FOLD-06's additive `assets` map** (`asset_paths.gd:70-93`);
  the resolver explicitly ignores the absolute fields (`asset_paths.gd:9-10`).
- **Still-needed consumer:** `render_models.py:387-408` reads `m["obj"]` /
  `m["texture_png"]` directly with `os.path.exists()` and `import_obj()` /
  `make_material()`. Those fields must stay for that offline bake tool (ticket
  step 4).
- **Consequence of quarantine (reported, not hidden):** `render_models.py` will
  now print `SKIP … (missing obj or texture)` for all 299 sids until its source
  is repointed to the bucket map or to the quarantine directory. No runtime/Godot
  gate depends on this tool. This is a **blocking follow-up before permanent
  deletion** (§6, gate P0).

---

## 4. Residual live consumers / risks (all reported, none silently broken)

1. **`render_models.py`** (offline Blender bake tool) — absolute flat manifest
   fields; see §3. Runtime unaffected; tool needs migration or must read the
   quarantine tree. **Blocker for permanent deletion.**
2. **`world.gd:408-413`** diagnostic flat-sprite branch — dead for all shipped
   keys (0 fallbacks verified by FOLD-07 §3 and re-read here). After quarantine it
   cannot silently mask a resolver miss; the `flat_fallbacks` counter stays 0 in
   a healthy tree. Not a blocker; G04 gate G4 observes it.
3. **`asset_paths.gd:16-18,59-93`** legacy flat fallback — intentionally retained
   per ticket order. With flats quarantined, `existing()` always returns the
   mapped bucket path; a rollback is a pure data operation (`undo.ps1`).
4. **Godot import cache** — the removed flat `.import` sidecars leave stale
   `.godot/imported/<old hash>.*` entries; the bucket sidecars need a G04 editor
   import pass. No `.godot/**` was touched by this ticket. (FOLD-07 §5 G1.)
5. **No donor parity claim.** No Godot run, no capture, no donor file read.

---

## 5. Quarantine / undo paths and integrity proof (OBSERVED)

```
inbox/cleanup_20261125/
  undo.json         1,766,685 B  # 5,574 entries: src, dst, sha256, bytes
  undo.ps1                       # one-command restore
  obj/    (897 files)  tex/    (386)   skin/   (66)
  sprites/(358)        sprites_hi/ (180)   anim/ (3,687)
```

`undo.json` fields: `ticket`, `created_utc`, `policy`, `models_root`
(`variant3d/assets/models`), `quarantine_root` (`inbox/cleanup_20261125`),
`file_count`, `total_bytes`, `by_family`, and `files[]` of `{src, dst, sha256,
bytes}` — one record per moved file.

**Restore (from anywhere, one command):**

```powershell
powershell -ExecutionPolicy Bypass -File inbox\cleanup_20261125\undo.ps1
```

`undo.ps1` resolves the repo root from its own location, refuses to overwrite an
occupied destination, verifies SHA-256 of each quarantined file before moving it
back and again after the move, then reports the restored count.

**Integrity verification performed after the moves:**

| Check | Result |
|---|---|
| `undo.json` entries | 5,574 (matches moved count) |
| Quarantined file missing from ledger path | **0** |
| SHA-256 mismatch vs ledger | **0** |
| Duplicate destination keys | **0** |
| Original destination already occupied (would block undo) | **0** |
| Bucket-tree file counts before vs after move | **identical** for all 5 families |
| Keep files present after move | **all 19 anim + manifest + index + resolver + 2 `.gdignore`** |
| `fsutil hardlink list` on quarantined `anim/alg/buildings/alg_cen.png` | 2 links: `app/...` + `inbox/cleanup_20261125/...` |
| `fsutil hardlink list` on quarantined `sprites/aca.png` | 2 links: `app/...` + `inbox/cleanup_20261125/...` |
| `app/` hardlink targets still present | **True** (both samples) |

**Move semantics:** all sources and destinations are on volume `C:` within the
same repo, so `Move-Item` was a directory-entry rename. NTFS hardlinked PNGs were
never opened for write; only the `variant3d` link moved. `app/assets/models/**`
was not touched.

---

## 6. Exact G04 gate list required BEFORE permanent deletion (G04 only)

Standing rule: **only G04 runs Godot / submits runner jobs** (WAVE_G_CHARTER.md:31).
This agent submitted none. Pre-flight every run: `python variant3d\tools\godot_runner.py
status` — pending=0, `godot.lock` free, `now_serving == next_ticket`. Each run
gets a unique id; one Godot at a time.

1. **G1 — editor import pass (blocking).** Reimport so the retained bucket
   `.import` sidecars regenerate `.ctex`/`.mesh` under `.godot/imported/<new hash>`;
   verify `uid` preserved, no hand edit of `.godot/**`, and that the 188
   missing-resource errors from FOLD-07's y04 capture clear. Generate the 19
   missing C01-ASSET sidecars. No stale-sidecar errors from the (now absent) flat
   tree.
2. **G2 — parse.** `world.gd`, `world3d_relief.gd`, `world3d_entities.gd`,
   `world3d_fx.gd`, `asset_paths.gd` load with 0 script errors; specifically
   `world3d_relief.gd:342` still reads `var path: String = AssetPaths.existing(sid, "obj")`.
3. **G3 — standing gates.** selftest **29/29**, uitest **17/17**, `t_render_mode`
   (2D default preserved), `assert_clean CLEAN`, `t_season_overlay`,
   `t_anim_metrics`, `t_naval`. No threshold lowered. Example invocation shape:
   ```powershell
   python variant3d\tools\godot_runner.py run --id clean01-selftest-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/selftest.gd
   ```
4. **G4 — anim keep-set proof.** `t_naval` PASS (the 12 `common/naval/*.png` and
   `naval_units/index.json` survived); `t_anim_metrics` PASS (both JSON indexes
   survived); mill rotor fallback resolves —
   `ROTOR_TEX_IMPORT_PATH = tex/shared/buildings/mill_rotor.png` exists on disk and
   the `anim/common/buildings/mill_rotor.png` fallback is still present.
5. **G5 — sprite observability (2D capture).** `sprites: N sets loaded
   (sids=M, flat_fallbacks=0)`; **no** `world: sprite map miss` warnings; no blank
   sprites; sprite-set count equals the pre-CLEAN-01 2D capture. This is the
   decisive proof that quarantining flat sprites/sprites_hi was safe.
6. **G6 — relief QA.** Z08/Z07 atom reports `skipped_missing_mesh == 0` for all
   four `terrainmeshN` and no `world3d_relief: OBJ map miss` warning; props ON/OFF
   A/B PNGs non-blank.
7. **G7 — 3D regression.** `t_entities3d`, `t_fx3d`, `t_ghost_final_stage` green;
   `stats.obj_available` does not drop; `mesh_sources_loaded` contains
   `obj_zup_bbox_normalised` and **no** `donor_bbox_proxy`; `nation_mesh_usage`
   exact hits for `ruscen pearus pikemanrus bavcen musketeer18bav polcen swecen
   pikeman18swe`; shipped skin count **66**.
   ```powershell
   python variant3d\tools\godot_runner.py run --id clean01-entities-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_entities3d.gd
   python variant3d\tools\godot_runner.py run --id clean01-fx-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_fx3d.gd
   python variant3d\tools\godot_runner.py run --id clean01-ghost-<UNIQUE> --timeout 180 -- --headless --path variant3d --script res://tests/t_ghost_final_stage.gd
   ```
8. **G8 — windowed captures.** 3D P0 + real map and a 2D capture: no new seams,
   proxy boxes or blank sprites; compare against the pre-CLEAN-01 baseline frame.
9. **G9 — offline tool (P0 blocker for permanent deletion).** Either (a) migrate
   `render_models.py:401-408` to resolve `assets.obj` / `assets.tex` via the
   manifest bucket map, or (b) document that the bake tool reads from
   `inbox/cleanup_20261125/` until it is migrated. Verify one single-sid bake
   (`--only ruscen`) produces a byte-comparable sprite.
10. **G10 — observation window.** Keep `inbox/cleanup_20261125/` for one full gate
    cycle. **Refusal condition:** any parse error, missing sprite set,
    non-zero `flat_fallbacks` for a shipped key, missing relief mesh, dropped
    `obj_available`, new proxy box, or tool regression ⇒ stop; do not delete.
    Permanent deletion requires explicit owner instruction after G1–G10 are green.

---

## 7. Attestation

- **No permanent deletion.** 5,574 files are in quarantine and restorable by one
  command; 0 files were deleted, overwritten, or edited in place.
- **No code edit.** No `.gd`, `.py`, `.tscn`, `.json`, config, test, `.import`
  sidecar, `.godot/**` or `app/**` file was modified. `manifest.json`,
  `skin/index.json` and `asset_paths.gd` are byte-unchanged (hashes in §2).
- **No Godot, no runner job, no capture** (WAVE_G_CHARTER.md:31).
- **No donor file read/copied; no donor-parity claim.** All runtime consequences
  above are **UNVERIFIED** until G04 runs G1–G10.
- Files written: this report; `inbox/cleanup_20261125/undo.json`,
  `inbox/cleanup_20261125/undo.ps1`, and the 5,574 quarantined files under
  `inbox/cleanup_20261125/`.
- Staying available for a COORD follow-up (restore, partial restore, or prep for
  permanent deletion after gates).

*End of CLEAN-01 report.*
