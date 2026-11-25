---
id: FOLD-04
ticket: "ASSET ORGANIZATION FOLD-04 — is variant3d/assets/models/anim/ used by the 3D variant?"
date: 2026-11-25
owner: FOLD-04 read-only subagent
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_EDITS
owns:
  - "docs/terrain_swarm_2026-11-25/reports/FOLD_04_anim_usage.md"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
scope: "READ ONLY. No Godot run, no runner job, no source/asset/test/config/git edit. One report only."
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md + WAVE_G_CHARTER.md read first"
owner_question: "'if you dont need in 3d variant3d/assets/models/anim we can empty that folder?'"
---

# FOLD-04 — definitive usage audit of `variant3d/assets/models/anim/`

## 0. Answer: **NO — the folder cannot be emptied.**

**OBSERVED:** `variant3d/assets/models/anim/` is **not** dead weight. It contains
five JSON files that are read at runtime by scripts the 3D variant actually
instantiates (`game.gd`, `data.gd`), plus one PNG that is an authorized live
fallback in `world3d_entities.gd`. Only the 1,849 bake PNGs + 1,849 `.import`
sidecars are inert for 3D gameplay — and even those are needed by registered
3D-variant tests and by a documented fallback. **Do not empty the folder.**

| Question | Answer | Label |
|---|---|---|
| (a) Any LIVE 3D consumer? | **YES** — `buildings.json`, `sco_units.json`, `land_units/index.json` (menu path), `mill_rotor.png` (fallback) | OBSERVED (code + call graph) |
| (b) Any test/doc reference? | **YES** — 6 tests + many docs; two registered "ready" tests read anim files directly | OBSERVED |
| (c) What is safe to delete? | Only the 2 `.TMP` files, and *conditionally* inert bake PNGs/`.import` sidecars — **never** the 6 tracked files, `mill_rotor.png`, or `common/naval/yacht_*.png` | OBSERVED / UNVERIFIED (conditional items) |
| (d) Does `app/` have its own copy? | **YES** — `app/assets/models/anim/` is a separate full tree (3,703 tracked files, 259.14 MiB, no `.gdignore`). Must stay untouched. | OBSERVED |

---

## 1. Folder inventory (OBSERVED, on-disk enumeration)

`variant3d/assets/models/anim/` — **3,706 files / 271,727,036 bytes (259.14 MiB)**:

| Content | Count | Git status | Relationship to `app/` |
|---|---|---|---|
| `.png` baked sprite sheets | 1,849 | **untracked**, ignored by `.gitignore:114` | NTFS **hardlinks** to `app/assets/models/anim/**` |
| `.png.import` sidecars | 1,849 | **untracked**, ignored by `.gitignore:115` | real variant-only copies |
| `.json` metrics | 5 | **tracked** | hardlinks to `app/` |
| `.TMP` leftovers | 2 | untracked | variant-only |
| `.gdignore` | 1 (0 bytes) | **tracked** | variant-only (app has none) |

**OBSERVED:** `git ls-files variant3d/assets/models/anim` returns exactly **6**
files: `.gdignore`, `buildings/buildings.json`, `buildings/mill_rotor.json`,
`land_units/index.json`, `land_units/sco_units.json`, `naval_units/index.json`.
Everything else is ignored/untracked, so "empty the folder" would delete ~259 MiB
of untracked local hardlinks — but it would also delete 4 of those 6 live files.

**OBSERVED:** `fsutil hardlink list` on
`variant3d/assets/models/anim/common/buildings/mill_rotor.png` returns two paths:
the variant path and `app/assets/models/anim/common/buildings/mill_rotor.png`.
Deleting the *variant* link leaves the `app/` link intact. **In-place editing**
a hardlinked file would silently modify `app/` too — another reason to back up
before any deletion.

---

## 2. (a) LIVE 3D consumers — evidence table

The 3D variant instantiates shared `game.gd` (C3Game), `data.gd` (Data) and
`ai.gd` in both render modes: `main.gd:40-48` preloads them; `main.gd:1085-1086`
does `game = C3Game.new()`; `main.gd:131` and `:1094` call `game.setup(...)`.
`world.gd` is only instantiated in the **2D** branch (`main.gd:590-593`,
`:1119-1122`); the 3D branch uses `world3d.gd` (`main.gd:1037-1045`, `:1103-1106`).
So `world.gd`'s anim reads are NOT live in 3D, but `game.gd`/`data.gd`'s are.

| File | LIVE consumer (file:line) | Reached in 3D? | Label |
|---|---|---|---|
| `buildings/buildings.json` | `game.gd:1872-1875`, `:1903-1906` — `FileAccess.get_file_as_string` in `bld_rm()` / `bld_block_rect_for()`. Callers: `ai.gd:484,557`; `game.gd:1885,1937,2486,2496,4068`; `selftest.gd:160,175` (a gate). | **YES** — C3Game + AI + selftest are instantiated in 3D | OBSERVED |
| `land_units/sco_units.json` | `data.gd:311-323` `load_extra_anim_index()` → `FileAccess.get_file_as_string`; called from `game.gd:415` inside `setup_begin()`, from `main.gd:995` (deserialize) and `world.gd:332` (2D only). | **YES** — `game.gd:415` runs on every 3D game setup via `game.setup()` | OBSERVED |
| `land_units/index.json` | `main.gd:1549-1552` — quality-dropdown callback in `_show_options()` reads `String(world.call("_anim_dir")) + "/land_units/index.json"` via `FileAccess.get_file_as_string`. `world3d.gd:813-820` supplies `_anim_dir()` returning `res://assets/models/anim`. | **YES, user-triggerable** — the callback is not render-mode gated; `world` is the 3D world at `:1103-1106`. Whether a 3D gate actually clicks this dropdown is UNVERIFIED. | OBSERVED (code path) / UNVERIFIED (runtime exercise) |
| `common/buildings/mill_rotor.png` | `world3d_entities.gd:242` `ROTOR_TEX_PATH`; read in `_rotor_material()` at `:1812-1818` as the **second** fallback after `ROTOR_TEX_IMPORT_PATH` (`tex/mill_rotor.png`, `:248`), via `FileAccess.file_exists()` + `Image.load()`. | **LIVE fallback** — dormant while `tex/mill_rotor.png` exists (verified both exist), but deleting it changes the code's documented fallback and leaves only the tex/ copy. | OBSERVED |
| `buildings/mill_rotor.json` | `world3d_entities.gd:249,525,1862` — only a **label/meta string**, never `FileAccess`-read. `MILL_ROTOR_ORTHO = 6.352` is hardcoded at `:252`; `world.gd:205` mentions it only in a comment. | **NO runtime read** (but tracked + documented as part of the 5-metric contract) | OBSERVED |
| `naval_units/index.json` | `world.gd:193` (2D-only), `t_anim_metrics.gd:18` (test). No 3D gameplay reader found. | **NO gameplay read; test-only** | OBSERVED |
| All other 1,848 PNG sheets + 1,849 `.import` | No 3D gameplay reader found. `world3d.gd:811-820` explicitly says "world3d.gd never loads from this directory"; `world3d_entities.gd:17-20` declares "NEVER reads the 2D bake: assets/models/anim/**". | **NO** | OBSERVED (greps over all `variant3d/**/*.gd`, `.tscn`, tools, config) |

### Why the rotor PNG is not an ASSET-IMPORT-01 regression (OBSERVED)

The known `mill_rotor.png` load errors came from the leftover `.import` in the
`.gdignore`-excluded tree advertising a ctex Godot never generates
(`ASSET_IMPORT_01.md:125,141`; `GDIGNORE_01.md:79,117`; `SWARM_BOARD.md` ASSET-IMPORT-01).
`world3d_entities.gd:1803-1818` fixed this by trying the importable
`assets/models/tex/mill_rotor.png` first and decoding with `Image.load()` instead
of `load()`. So the anim PNG is now a **dormant but deliberate** fallback; its
`.import` sidecar is inert. Removing the PNG does not reintroduce the ctex error,
but it does remove the documented donor-original fallback (`MOTION_ANIM_01.md:208-210`).

---

## 3. (b) Tests and docs that reference it (OBSERVED)

### Tests

| Test | Reference | Reads files? | Registered? |
|---|---|---|---|
| `t_entities3d.gd:215-234` | forbids any `anim/` substring in `world3d_entities.gd` source (gate). The `ROTOR_*` paths are assembled from two literals at `:242,:249` precisely to keep this gate green. | No (structural scan) | `manifest.json:219-225`, status `ready`; gate |
| `t_fx3d.gd:24-36` | `FORBIDDEN_2D_TOKENS` includes `"res://assets/models/anim/"` | No (structural scan) | `manifest.json:227-233`, status `ready`; gate |
| `t_anim_metrics.gd:17-18` | `MAIN_PATH = .../anim/land_units/index.json`; `NAVAL_PATH = .../anim/naval_units/index.json` | **YES** | `manifest.json:114-120`, status `ready`; `results/t_anim_metrics.json` passed=true |
| `t_naval.gd:22-23,108,122-127,139-165` | `NAVAL_DIR = .../anim/naval_units`; `NAVAL_PNG_DIR = .../anim/common/naval`; loads `yacht_walk.png`, `yacht_hull.png`, action sheets | **YES** | `manifest.json:122-128`, status `ready`; `results/t_naval.json` exists |
| `t_sheet_load.gd:8-12` | loads 5 representative anim PNGs via `ResourceLoader.exists()`/`load()` | **YES** | **Not in manifest**; copy of a 2D test (`--path app` in its header), already broken by `.gdignore` — UNVERIFIED whether it is ever run in the 3D variant |
| `selftest.gd:160,175` | calls `game.bld_rm()` / `bld_block_rect_for()` → `buildings.json` | Indirectly **YES** | canonical gate (29/29) |
| `mill_visual_test.gd` / `mill_render_test.gd` (manifest `:35-40`) | rotor render test | Indirectly via `world3d_entities.gd` | `ready`, `windowed: true` |

### Docs (sample, OBSERVED)

- `variant3d/README.md:43,51-59` — documents `.gdignore` and the 5 JSON runtime dependency.
- `variant3d/CREDITS.md:65`, `variant3d/MECHANICS.md:516,591,649-650` — provenance/docs.
- `docs/coord_swarm_2026-11-25/reports/ASSET_IMPORT_01.md:46,125-141`,
  `GDIGNORE_01.md:46,79,113-125,132`, `MOTION_ANIM_01.md:208-210`, `SWARM_BOARD.md:213,404`.
- `docs/terrain_swarm_2026-11-25/reports/M01_mill_rotor_audit.md:63,133`.
- `docs/coord_swarm_2026-11-24/reports/V70_scaffold.md:157-180`,
  `AUDIT3D_07_resources.md:41-43`, `COMPLETENESS_05_shipping.md:68`.
- `.gitignore:110-115` — explicitly ignores `variant3d/assets/models/anim/**/*.png` and `.png.import` as "hardlinked leftovers from app/assets/models/anim".

---

## 4. (c) What exactly is safe to delete — proposal only, **nothing deleted**

### Never delete (OBSERVED live or contract-critical)

1. `variant3d/assets/models/anim/.gdignore` — empty marker. Removing it pulls
   1,849 stale bake PNGs into Godot's import scan, recreating the
   ASSET-IMPORT-01/GDIGNORE-01 stale-sidecar problem. `GDIGNORE_01.md:115` says
   explicitly **"Do not remove or narrow"**.
2. The 5 tracked JSONs: `buildings/buildings.json`, `buildings/mill_rotor.json`,
   `land_units/index.json`, `land_units/sco_units.json`, `naval_units/index.json`.
   Four have runtime/test readers; `mill_rotor.json` is part of the documented
   contract even though it is not read (`:249` label).
3. `common/buildings/mill_rotor.png` — live fallback at
   `world3d_entities.gd:1812`.
4. `common/naval/yacht_walk.png`, `yacht_hull.png` and any action sheet listed in
   `naval_units/index.json` — `t_naval.gd` is a **ready** registered test that
   asserts their existence and dimensions.
5. The 5 PNG paths in `t_sheet_load.gd:8-12` if that test is ever revived.

### Conditionally safe (UNVERIFIED — needs owner decision + test rerun)

- The remaining ~1,840 bake PNGs and their 1,849 `.import` sidecars are inert
  for 3D gameplay (no reader found). Deleting them would save ~259 MiB locally
  and remove the stale-sidecar evidence. But:
  - they are ignored/untracked, so deletion is **not** a git-tracked change and is
    invisible to other clones;
  - `t_naval`/`t_anim_metrics`/`t_sheet_load` must be re-run after deletion to
    prove no registered test regresses;
  - any in-place edit (not delete) of a hardlinked PNG would alter `app/`.
- The 2 `.TMP` files (`buildings/rus_sta_s4.png.import~RF139ced6.TMP`,
  `buildings/rus_sto_dead.png.import401825162.tmp`) are leftover temp garbage —
  lowest-risk deletion.

### Safe deletion sequence (NOT executed)

1. **Back up first**: copy the whole `variant3d/assets/models/anim/` tree to
   `inbox/backup/anim-FOLD04/` (a plain `Copy-Item -Recurse` dereferences the
   hardlinks into an independent snapshot). Record `git ls-files` output and the
   file/size totals from §1.
2. Delete only the 2 `.TMP` files. Re-run no gates (no consumer).
3. If the owner still wants bulk cleanup: enumerate the exact PNG basenames
   referenced by `naval_units/index.json` and `t_sheet_load.gd:8-12`, exclude
   them plus `mill_rotor.png`, then delete only the remaining PNGs and their
   matching `.png.import` sidecars. Keep `.gdignore` and all 5 JSONs.
4. Re-run the 3D gates through the sole runner owner (G04): `selftest`, `t_entities3d`,
   `t_fx3d`, `t_anim_metrics`, `t_naval`, `t_render_mode`, `assert_clean`.
   This worker ran **no** runner job per WAVE_G standing rule.
5. Verify `app/assets/models/anim/` is byte-identical to the backup for every
   deleted hardlink target (its link count should drop by one, file intact).
6. Only after green gates, consider committing the removal of ignored sidecars —
   but note they are untracked, so there is nothing for git to commit.

---

## 5. (d) The 2D `app/` copy — MUST stay untouched (OBSERVED)

- `app/assets/models/anim/` exists as a full independent tree: **3,705 files /
  259.14 MiB, 3,703 git-tracked files**, with the same 25 nation/unit subdirs
  (plus `tmp/`) and **no `.gdignore`** — it is the live 2D runtime source.
- `app/scripts/world.gd`, `app/tools/unit_bakers/*`, `app/tools/sheet_metrics.py`
  read/write `app/assets/models/anim/**`. Removing or editing the `app/` tree
  would break the 2D app, which the charter explicitly keeps green.
- The variant's PNGs are **hardlinks** into this tree (verified via `fsutil hardlink list`).
  Deleting the variant-side link is safe for `app/`; editing in place is not.
- This ticket touched neither tree.

---

## 6. Method + limits

**OBSERVED:** on-disk enumeration, `git ls-files`, `git check -ignore`,
`fsutil hardlink list`, and greps over all `variant3d/**/*.gd`, tools, config,
tests, scenes, `.gitignore` and swarm docs for `models/anim`, `anim/`,
`.gdignore`, `index.json`, `buildings.json` and `mill_rotor.json`. Call graphs
were read directly at the file:line citations above.

**UNVERIFIED:** whether a live windowed 3D session clicks the quality dropdown
that reads `land_units/index.json`; whether ignored bake PNGs are needed by any
non-registered diagnostic not found by the greps; whether a real Godot export of
the 3D variant includes the 5 `.gdignore` JSONs (`GDIGNORE_01.md:125` M5, export
owner UNVERIFIED). No runner job was submitted, so no new runtime evidence was
generated. Nothing was deleted, moved, renamed or edited.

*End of FOLD-04 report.*
