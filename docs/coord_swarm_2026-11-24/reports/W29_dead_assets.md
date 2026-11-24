---
owner: W2-9
wave: 2
date: 2026-11-24
gap: G-A1 (from P03_assets_memory.md)
status: FIXED — non-destructive `.gdignore` markers added; zero deletions
scope: filesystem-only markers + read-only verification/measurement
output: docs/coord_swarm_2026-11-24/reports/W29_dead_assets.md
---

# W2-9 — Dead DDS decals excluded from Godot (non-destructive)

## 0. Result

G-A1 is **confirmed and mitigated**. Two `.gdignore` marker files were added;
**no file was deleted, untracked, or `git rm`-ed**. All 944 tracked files in the
two directories (468 `.dds`, 468 `.uid`, 4 `.lib`, 4 `.mat`) remain on disk and
in git. Godot will now skip both directories during its filesystem scan/import
and, with the current export presets, they are no longer candidates for the
export pack. Runtime decals are unaffected: the only loader reads
`res://assets/terrain/decals_png/%s%sd.png` (`app/scripts/world.gd:727`).

No Godot job was run: the change is a pure filesystem marker with no `.gd`,
`.tscn`, `.tres` or export-preset edit, so there is no runtime code path in
which a regression could occur; a re-import would only re-scan 4,434 `.import`
files and contend with the other Wave-2 workers on the serialized runner. The
export-packing effect therefore stays labelled **ESTIMATE** (see §5).

## 1. Verification evidence (all `observed`, re-measured from current tree)

### 1.1 Counts and sizes — `python` `os.listdir` + `os.path.getsize`

| directory | ext | files | bytes | MiB |
|---|---|---:|---:|---:|
| `app/assets/terrain/decals_dds/` | `.dds` | 462 | 634,984,224 | 605.62 |
| | `.uid` | 462 | 9,118 | 0.01 |
| | `.lib` | 4 | 20,141 | 0.02 |
| | `.mat` | 4 | 32,118 | 0.03 |
| | **all** | **932** | **635,045,601** | **605.63** |
| `app/assets/terrain/decals/` | `.dds` | 6 | 8,389,536 | 8.00 |
| | `.uid` | 6 | 118 | 0.00 |
| | **all** | **12** | **8,389,654** | **8.00** |
| **both** | **`.dds`** | **468** | **643,373,760** | **613.57** |
| **both** | **all files** | **944** | **643,435,255** | **613.63** |

- Matches P03: 468 DDS / 613.57 MiB, 462 stems in `decals_dds/` 1:1 with
  `decals_png/`. The reported figure covers only `.dds`; the extra 9,236 B of
  `.uid` and 52,259 B of `.lib`/`.mat` are documented here for completeness.
- Largest DDS examples (exact): `algcend.dds`, `algcendw.dds`, `alghoud.dds`
  (1,398,256 B each, members of the 21-file duplicate group in §6).

### 1.2 Import state (`observed`)

- `.import` files in `decals_dds/`: **0**; in `decals/`: **0**.
- `.dds.import` files anywhere under `app/`: **0**.
- `app/assets/**` `.import` files: **3,383** (reproduces P03 §1). Whole `app/`
  excluding `.godot/`: **4,434** — none target a `.dds` file.
- 468 `.uid` files exist (one per DDS, tracked) but contain only a bare
  `uid://…` line, e.g. `algcend.dds.uid` → `uid://deutyc0dv3sry`.
  Cross-reference of all 468 UID strings against every `.gd`, `.tscn`,
  `.tres`, `.json`, `.cfg` under `app/`: **0 hits**. They are orphans.

### 1.3 Runtime-reference grep (`observed`)

| query (case-insensitive) | scope | hits |
|---|---|---|
| `decals_dds` | all `app/scripts/**/*.gd`, `app/**/*.tscn`/`.tres` | **0** |
| `.dds` | same | 2, both comments: `world.gd:3`, `world.gd:6` |
| `decals/` | same | 3, all comments: `world.gd:6`, `world.gd:717`, `terrain3d_sandbox.gd:215` |
| `load/preload/FileAccess/ResourceLoader … .dds` or `res://… .dds` | `.gd`, `.tscn`, `.tres`, `.gdshader`, `.cfg`, `.json` | **0** |
| `uid://` for the 468 orphan UIDs | code + scenes + config | **0** |

Whole-repo `git grep -i -e decals_dds -e decals/ -e \.dds` returns 1,083 lines,
dominated by `app/assets/models/manifest.json` donor-path strings
(`C:\Games\Cossacks 3\...`), `app/CREDITS.md`, docs and backups. Outside
`app/assets/**` and docs, the only tool reference is
`app/tools/copy_assets.py:207` (the offline copy step that produced the raw
DDS twins). No runtime consumer exists.

Positive control (the format actually used at runtime): `app/scripts/world.gd:727`
`var path := "res://assets/terrain/decals_png/%s%sd.png" % [nat, sid]`.

### 1.4 Git exposure (`observed`)

`git ls-files` → 932 files under `decals_dds/` and 12 under `decals/`, all
tracked; `git check-ignore -v` reports **not ignored** for the directories,
the `.uid` files, or a prospective `.gdignore`. `git diff --stat --` on both
directories is **empty** after this change (no tracked file modified).

## 2. Files created (the entire edit)

| path | bytes | content (one line) |
|---|---:|---|
| `app/assets/terrain/decals_dds/.gdignore` | 111 | `# W2-9 / G-A1: raw donor DDS decals + orphaned .uid; runtime uses decals_png/*.png. Godot ignores this folder.` |
| `app/assets/terrain/decals/.gdignore` | 111 | same line |

Godot treats the mere presence of `.gdignore` as the marker; the comment is
documentation only and is not parsed. Neither file existed before
(`Test-Path` → `False` for both). Sibling `decals_png/` is untouched.

## 3. Non-destructive guarantee

- No `git rm`, `rm`, `Remove-Item`, or `git add` of tracked files was executed.
- `git ls-files` counts remain 932 + 12; `git diff --stat -- app/assets/terrain/decals_dds app/assets/terrain/decals` is empty.
- Spot-check SHA-256 after the change:
  `app/assets/terrain/decals_dds/algcend.dds` =
  `6E99642FF49ADF98BA02FFC50CAA85E36D4241116A14775500335746D8E58394`.
- The 468 `.uid` files and the 8 donor `.lib`/`.mat` descriptors are still on
  disk and tracked. Ignoring them in Godot does not change their git state.
- Concurrent Wave-2 edits by other workers appear in `git status`; none are in
  this lane's two directories.

## 4. Expected effect

**MEASURED:** 944 files / 643,435,255 B (613.63 MiB) now sit in directories
carrying a Godot ignore marker; 0 `.import` files and 0 runtime loads were
removed or invalidated (§1). `export_presets.cfg` (read-only) has
`export_filter="all_resources"` with empty `include_filter`/`exclude_filter`
in all three presets — there was no pre-existing DDS exclusion (answers P03
open question 1: gain is **not** already zero by preset filter).

**ESTIMATE:** an export run should shrink the exported data by up to
~613.6 MiB if the packer previously swept these unrecognized files as raw
resources, and the editor scan should no longer enumerate these 944 entries.
This is not benchmarked: no export and no import re-scan were run (§0). To
convert to MEASURED, run one export with `godot_runner.py` in a free slot and
compare `.pck` bytes before/after; **do not** delete any source file to test.

**Runtime risk:** none by construction — zero `.gd`/`.tscn` load paths and zero
UID references (§1.2–1.3); `decals_png/` remains importable.

## 5. Follow-up A — 259 MiB sha256 duplicates (measured, NOT changed)

Re-hashed every file under `app/assets/` (size-bucket prefilter, sha256):
7,846 files, 2,485,217,904 B scanned; 134 duplicate groups covering 799 files;
**reclaimable = 271,962,213 B = 259.36 MiB** — exactly reproduces P03 §2.
No hardlink, copy or deletion was made.

| files | bytes each | reclaim | exact paths (representative group) |
|---:|---:|---:|---|
| 21 | 2,126,727 | 42,534,540 (40.56 MiB) | `app/assets/terrain/decals_png/algcendw.png`, `pieacadw.png`, `pieartdw.png`, `pieba2dw.png`, `piebardw.png`, … (`pie*dw.png` ×11, `swi*dw.png` ×10 — full 21-path list reproduced by the size/sha256 script) |
| 21 | 1,398,256 | 27,965,120 (26.67 MiB) | `app/assets/terrain/decals_dds/{alg,pie,swi}{acad,art,ba2,bar,blad,cend,dip,houd,stad,tem}dw.dds` (21 paths) |
| 4 | 6,531,253 | 19,593,759 (18.69 MiB) | `app/assets/models/tex/rock_sea1.png`, `rock_sea4.png`, `rock_sea5.png`, `rock_sea6.png` |
| 5 | 1,750,219 | 7,000,876 (6.68 MiB) | `app/assets/terrain/blocks/test19.png`, `winter23.png`, `winter24.png`, `winter25.png`, `winter26.png` |
| 16 | 355,347 | 5,330,205 (5.08 MiB) | `app/assets/models/tex/rock_smallstonesea1..6.png`, `rock_stonessea1..10.png` |
| 3 | 2,384,054 | 4,768,108 (4.55 MiB) | `app/assets/terrain/decals_png/eurcoadw.png`, `eurgoldw.png`, `eurirodw.png` |
| 3 | 2,292,802 | 4,585,604 (4.37 MiB) | `app/assets/terrain/decals_png/eurcoad.png`, `eurgold.png`, `eurirod.png` |
| 6 | 848,576 | 4,242,880 (4.05 MiB) | `app/assets/models/tex/flower1..3.png`, `plantain1..3.png` |
| 4 | 1,398,256 | 4,194,768 (4.00 MiB) | `app/assets/terrain/decals/eurgold.dds`, `decals_dds/eurcoad.dds`, `decals_dds/eurgold.dds`, `decals_dds/eurirod.dds` |

Subgroup totals: `decals_png/` 27 groups / 100,929,875 B (96.3 MiB);
`decals_dds/` 32 groups / 74,261,568 B; `decals/` 6 groups / 11,186,048 B.

**Caveat (derived from `world.gd:727`):** duplicate *paths* are addressed by
filename; any dedup must preserve every path via hardlink or canonical byte
copy, never delete an "extra" name. The `decals_dds`/`decals` share
(85.4 MiB) is already excluded from Godot by §2, so only the PNG groups are
worth a future export-size change. Reproduce with the P03 script pattern:
group by `os.path.getsize`, hash only same-size buckets, sum `(n−1)×size`.

## 6. Follow-up B — 144.6 MiB stale `.godot` cache (measured, NOT changed)

Definition used: a `.ctex` whose source key (filename before the final
`-<32 hex>.ctex`) does not occur anywhere under `app/assets/**`. This exactly
reproduces P03's A5 figure.

- `app/.godot/imported/`: **4,195** `.ctex`, 1,510,044,750 B total.
- **607 stale**, **151,647,726 B = 144.62 MiB**.
- All 607 have a matching `.import` source (0 missing sources), so they are
  cache orphans from diagnostic images (deleted/ignored `app/shots/**`), not
  live game assets. `app/.godot/` carries its own `.gdignore` and 0 tracked
  files — **not shipped**; purging affects local disk only.
- Largest stale entries (exact path relative to `app/.godot/imported/`, bytes):

| file | bytes |
|---|---:|
| `contact.png-2b60f492f4dbe652ed9d02a97f21fc89.ctex` | 2,660,510 |
| `ref_contact.jpg-b414d8e836a41364dd225cb6c94b4dad.ctex` | 2,543,656 |
| `t6t90_combo_ravine_grass.png-5173d45b451c22418f4b9f35d291438c.ctex` | 2,124,670 |
| `t6t90_combo_grass_trees.png-c6b8a6094042b98af6c0cede66e1d171.ctex` | 1,997,314 |
| `ref_city.jpg-daa5d178c2ba1fb4caeb5a2864b47064.ctex` | 1,544,386 |
| `ref_official.jpg-f98e4090e8e8e4c41704cfdbe8160d82.ctex` | 1,429,942 |
| `compare_with_originals.png-2b483fb33229e5bdafc3dec9c3da89b3.ctex` | 1,286,750 |
| `compare_with_originals_desert.png-a8ca340ca1ea0708310cc0e2c0291492.ctex` | 1,270,270 |
| `compare_with_originals_winter.png-6f58fd97ec9cf056073a6c84ea41c629.ctex` | 1,267,292 |
| `video_ref_thumb.jpg-614c96936b4f8997a32ad4e98cf49558.ctex` | 1,233,198 |
| `t6t90_confrontation_preview.png-083edd1255dacf802040b6e4de219146.ctex` | 1,157,168 |
| `t6t90_combo_shore_water.png-17a9d2c3145cea2c6459670114c59874.ctex` | 1,137,766 |
| `variant_A_lakeside.png-b24cb7c4d96bdb4ec088c7e1b1fb5b02.ctex` | 1,011,366 |
| `variant_C_river_desert.png-b5b502fa6038cce9c6a8ee6b3e76f945.ctex` | 989,952 |
| `variant_B_highland.png-6d8231884f5df1d65163249cf7dab15d.ctex` | 979,268 |

- Additional observation: **4,634** `.md5` sidecars (421,694 B), of which
  **441** have no same-stem `.ctex` (examples: `aca.obj-f819c3…md5`,
  `alarm.ogg-6df7a163…md5`, `alg.ogg-497a089d…md5`).
- Whole `app/.godot/` = 1,815,721,581 B = 1,731.61 MiB. Nothing was purged.

## 7. Open questions (hand-off, not resolved here)

1. **Export effect:** confirm with one serialized export run whether
   `all_resources` actually packs bare `.dds` files. If it does not, §4's
   export gain is 0 and the benefit is editor-scan/repo hygiene only.
2. **UID lifecycle:** will Godot's next import prune the 468 now-ignored
   tracked `.uid` files? No `uid://` reference exists, so runtime is safe, but
   pruning could make the working tree dirty — check `git status` after the
   next import in a maintenance window.
3. **Compliance overlap:** `docs/REMEDIATION_PLAN.md:36-66` proposes
   `git rm --cached` for the same donor `.dds`/`.uid`/`.lib`/`.mat` (licensing
   exposure). This is a **different, owner-gated decision**; this lane did not
   untrack or delete anything, and the private-use warning still stands.
4. **Descriptors:** the 4 `.lib` + 4 `.mat` donor descriptors are now also
   ignored by Godot; no runtime reader exists (`TERRAIN_PORT_ASSETS.md:162`).
   Retain vs untrack needs an owner decision.
5. **Cache purge:** 607 stale `.ctex` + 441 orphan `.md5` can be removed in a
   future maintenance window; verify no `.import` references their ids first
   (P03 open question 3).
6. **Godot import check deliberately skipped** (task option): no `.gd`/scene
   change and no `export_presets.cfg` edit means no regression surface; the
   runner is shared with other Wave-2 workers and a full re-scan of 4,434
   `.import` files would cost time without new evidence. Re-run only if the
   coordinator wants §4 ESTIMATE promoted to MEASURED.
