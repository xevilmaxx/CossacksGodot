# Donor-asset licence-exposure remediation plan

Author: worker **agentAA** (AAA swarm). Status: **PLAN ONLY — nothing executed.**
Scope: remove raw donor assets from **git tracking** while preserving every file on
disk. No index changes, no deletions, no `.gitignore` edits and no Godot runs were
performed while producing this document.

Evidence basis: `ASSET_AUDIT.md` (worker Y, read-only audit, 2026-11-21),
`WAIVERS.md`, `SWARM_OPS.md` §3.5, `SWARM_BOARD.md` P-05 and "Unowned pre-existing
changes", `.gitignore`, `app/CREDITS.md`, plus read-only `git ls-files`,
`git status --short`, `git check-ignore -v` and filesystem counts taken for this plan.
`res://` maps to `app/`.

## 1. Exposure classes

| Class | Exact path glob | Count (verified) | Current git state | Runtime usage (per Y's audit) | Risk |
|---|---|---|---|---|---|
| **A — raw donor decal textures** | `app/assets/terrain/decals_dds/*.dds` (462)<br>`app/assets/terrain/decals/*.dds` (6)<br>companion `.uid`: same two dirs, 462 + 6 | 468 `.dds` + 468 `.uid` = **936 index entries** | **TRACKED** (`git ls-files` confirms 462 + 6 `.dds` and 462 + 6 `.uid`) | **Zero.** `.dds`/`.lib`/`.mat` names occur only in comments in `world.gd:3,6,66,130`. Runtime decals are the converted `app/assets/terrain/decals_png/*.png` (462 files) loaded at `world.gd:463`. | **HIGH** — private-use donor binaries are committed; any push/publish redistributes them. Orphaned `.uid` if only `.dds` is removed. |
| **B — donor decal descriptors** | `app/assets/terrain/decals_dds/*.lib`, `app/assets/terrain/decals_dds/*.mat` (specifically `decals_{dlc1,dlc2,dlc3,exp1}.{lib,mat}`) | 4 `.lib` + 4 `.mat` = **8 index entries** | **TRACKED** | **Zero.** Same comment-only references as class A. | **HIGH** — donor metadata committed alongside A. |
| **C — donor intermediate meshes** | `app/assets/models/obj/*.obj` (29), `*.mtl` (29), `*.import` (29) | **87 files on disk**, **0 tracked** | **IGNORED** — `.gitignore:19` `obj/` matches `app/assets/models/obj/` (`git check-ignore -v` confirms); `git ls-files` returns 0 `.obj`/`.mtl` | **Zero.** Intermediate Blender/bake geometry; the port consumes converted `models/sprites/*.png`, `models/anim/*.png` + `index.json`. | **MEDIUM** — not in the index/history, but still physically in the working tree and vulnerable to an accidental `git add -f`. |
| **D — donor-derived scratch under `res://` (ticket P-05)** | `app/assets/models/anim/_mill_tmp/eurmil.png` and `app/assets/models/anim/_mill_tmp/eurmil.png.import` | **2 files** (1 tracked, 1 untracked) | `eurmil.png` **TRACKED**; `.png.import` **UNTRACKED** (`??` in `git status --short`) | **Zero** per Y's audit. Not the runtime rotor: runtime uses `mill_rotor.png` (`world.gd:356`). This is scratch for the **unowned mill-rotor feature** listed under "Unowned pre-existing changes" in `SWARM_BOARD.md`. | **MEDIUM/HIGH** — donor-derived scratch inside `res://`; **blocked** until the coordinator/user signs off on that feature (P-05 is INTAKE, unowned). |

Cross-cutting note: the 19 other tracked `.uid` files (`app/scripts/*.gd.uid`,
`app/tests/*.gd.uid`) are legitimate Godot metadata for scripts/tests and are
**not** part of any exposure class. Do not touch them.

## 2. Proposed remediation (per class)

All commands below are **reversible**: because every target remains on disk,
`git add <same path>` re-stages a removed file. `git rm --cached` (never `-f`)
only edits the index. `:(glob)` pathspec magic keeps `*` from crossing `/`.

### Class A — raw donor `.dds` + companion `.uid` (1 index-removal command set)

```sh
git rm --cached -- ":(glob)app/assets/terrain/decals_dds/*.dds" ":(glob)app/assets/terrain/decals/*.dds"
git rm --cached -- ":(glob)app/assets/terrain/decals_dds/*.uid" ":(glob)app/assets/terrain/decals/*.uid"
```

Equivalent single-step alternative (directory-scoped; also covers class B, so do
**not** run both forms):

```sh
git rm --cached -r -- app/assets/terrain/decals_dds/ app/assets/terrain/decals/
```

`.gitignore` lines to append (these cover classes A **and** B):

```gitignore
# Raw donor decal sources — private-use only, never redistributed (remediation)
/app/assets/terrain/decals_dds/
/app/assets/terrain/decals/
```

Do **not** use the broader `app/assets/terrain/decals*/` suggested in
`ASSET_AUDIT.md`: it also matches `app/assets/terrain/decals_png/`, the 462
converted PNGs (plus their 462 `.import` files) that the port actually loads.

### Class B — donor `.lib` / `.mat` descriptors

```sh
git rm --cached -- ":(glob)app/assets/terrain/decals_dds/*.lib" ":(glob)app/assets/terrain/decals_dds/*.mat"
```

No additional `.gitignore` line needed — already covered by
`/app/assets/terrain/decals_dds/` above.

### Class C — donor `.obj` / `.mtl` / `.import`

No git command is required or appropriate: these files are **already untracked
and ignored**, so there is nothing to untrack. Do **not** force-add and do not
delete them in this plan.

Optional documentation-only `.gitignore` line (redundant with `obj/` at line 19,
adds explicit intent; requires approval to edit `.gitignore`):

```gitignore
# Donor intermediate meshes (already covered by obj/ above)
/app/assets/models/obj/
```

Any on-disk purge of these 87 files is a separate filesystem operation that
needs its own sign-off; it is out of scope here.

### Class D — `_mill_tmp/` scratch (P-05) — **CONDITIONAL, DO NOT EXECUTE YET**

This is tied to the unowned mill-rotor feature. `SWARM_BOARD.md` P-05 is INTAKE
and explicitly says "needs owner + user sign-off on mill-rotor feature". Proposed
commands **only if that sign-off is granted**:

```sh
git rm --cached -- "app/assets/models/anim/_mill_tmp/eurmil.png"
```

`.gitignore` line to append, also conditional on sign-off:

```gitignore
# Donor-derived scratch for the mill-rotor bake — never redistributed
/app/assets/models/anim/_mill_tmp/
```

The untracked `eurmil.png.import` needs no git command; the ignore line keeps it
out of the index. It is a generated companion — leave it on disk and do not
delete it. Routing the scratch writer to the system temp directory is a code
change owned by the mill-rotor feature and is **not** part of this plan.

## 3. "Do not do" list

- **No `git rm -f`** (and no `git rm --cached -f`): force can delete working-tree
  copies; the requirement is to preserve every file on disk. Use `--cached` only.
- **No deleting the converted PNGs**: keep `app/assets/terrain/decals_png/*.png`
  (462) and their `.import` files, `app/assets/models/sprites/*.png`,
  `app/assets/models/anim/*.png` and every other converted/derived asset.
- **No touching `index.json` / `buildings.json`** (or any `app/assets/**/*.json`):
  Y's audit found 54 keys / 299 unit sheets and 1506 building keys, all consistent.
- **No broad `app/assets/terrain/decals*/` ignore rule** — it would also hide
  `decals_png/`.
- **No `git add -A`, `git commit`, `git push`, `git reset --hard`, `git clean`** or
  history-rewriting tool as part of this plan (see open questions).
- **No Godot runs** (per task instruction; all Godot work goes through
  `app/tools/godot_runner.py` by another worker).
- **No edits to `.gitignore`, `app/CREDITS.md`, `WAIVERS.md`, `SWARM_BOARD.md`**
  or any other file by this plan; only `REMEDIATION_PLAN.md` is owned here.

## 4. Verification checklist (what should be true afterwards)

1. `git ls-files "app/assets/terrain/decals_dds/*" "app/assets/terrain/decals/*"`
   → **0 lines** (936 raw donor decal index entries gone).
2. `git status --short -- app/assets/terrain/decals_dds app/assets/terrain/decals`
   → only staged deletions (`D ` in column 1); **no `??` entries** once the
   ignore lines are added.
3. `Test-Path app/assets/terrain/decals_dds/algcend.dds` and
   `Test-Path app/assets/terrain/decals/eurgold.dds` → **True** (files preserved).
4. `git check-ignore -v app/assets/terrain/decals_dds/algcend.dds` and
   `git check-ignore -v app/assets/terrain/decals/eurgold.dds` → show the new
   ignore rules.
5. `git status --short -- app/assets/models/obj` → **empty** before and after
   (still ignored; 29 `.obj` + 29 `.mtl` + 29 `.import` still on disk).
6. `git diff --cached --stat` → deletions only, all under the two decal dirs
   (and `_mill_tmp/eurmil.png` only if P-05 was separately approved). No converted
   PNG, `.json`, `.gd`, `index.json` or `buildings.json` appears.
7. `git ls-files "app/assets/terrain/decals_png/*.png"` → still **462**;
   `git diff --name-only -- app/assets/models/anim/index.json
   app/assets/models/anim/buildings.json` → **empty**.
8. If P-05 was approved: `git status --short` shows
   `D  app/assets/models/anim/_mill_tmp/eurmil.png`, no `??` for `.import`, and
   the file is still present on disk; otherwise `_mill_tmp/` status is unchanged
   (`?? eurmil.png.import`, `eurmil.png` still tracked).
9. No selftest/uitest result is claimed here — no Godot run was performed for
   this plan, and no runtime behaviour should change (all removed files were
   unreferenced at runtime).

## 5. Open questions

- **History:** `git rm --cached` only affects future commits; the donor files
  remain in existing commits. Purging them from history needs a separate,
  explicitly approved rewrite (and coordination with anyone holding a clone).
  Not part of this plan.
- **CREDITS / documentation drift:** `app/CREDITS.md:15-20` says the
  `assets/terrain/decals/*.dds` files are "kept as reference", and `WAIVERS.md`
  §"Licence families" lists `terrain/decals/*.dds` as present. Removing them
  would make both statements stale; updates are owned by worker V-01
  (`CREDITS.md`, `WAIVERS.md`) and need coordinator assignment.
- **6 `.dds` in `decals/`:** these are the ones CREDITS calls reference plates.
  Confirm they are safe to untrack rather than intentionally retained rebuild
  sources (the audit already found zero runtime use).
- **Companion `.uid`:** recommend removing the 468 `.uid` files together with
  their `.dds`; Godot will regenerate them if a donor file is ever re-imported.
  Confirm no worker needs them.
- **Class C on-disk purge:** are the 87 ignored `.obj/.mtl/.import` meshes still
  needed for future sprite rebakes? A filesystem delete is a separate decision.
- **P-05:** owner and user sign-off on the unowned mill-rotor feature is still
  outstanding; class D stays blocked until then.

PLAN ONLY — not executed; requires coordinator/user approval.
