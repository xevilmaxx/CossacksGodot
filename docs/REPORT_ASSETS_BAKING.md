# REPORT — ANIM LAYOUT, BAKING & ASSET OPTIMIZATION

`task: T-DOCS-2` · `date: 2026-11-23` · `status: SHIPPED — with documented gaps`

Scope: the nation-first `anim/` re-layout, .import/cache migration, resolver/baker/tool
changes, donor-fairness audit, frame-dedup investigation and alpha-noise normalization.
This is a documentation-only ticket: no source, asset or tool file was changed here.

Evidence basis: `inbox/anim_nation_plan.json`, `inbox/anim_migration_manifest.json`,
`inbox/anim_migration_undo.json`, `inbox/anim_nation_undo.json`,
`inbox/alpha_noise_audit.json`, `inbox/alpha_norm_plan.json`,
`inbox/alpha_norm_undo.json`, `inbox/alpha_norm_verify.json`,
`inbox/sheet_dup_audit.json`, `inbox/sheet_neardup_audit.json`,
`app/scripts/world.gd`, `app/tools/*.py`, `app/tests/*.gd`,
`app/.godot_queue/status.json`, git log `021fe169` and `63d4a0de`,
plus independent re-counts/re-hashes of the live asset tree and donor data at
`C:\Games\Cossacks 3\data`.

---

## 1. Final layout tree

`app/assets/models/anim/` — 32 folders, 1,849 PNG + 1,849 `.import` pairs:

```
anim/<dir>                 PNGs   anim/<dir>                 PNGs
────────────────────────────────  ────────────────────────────────
alg/buildings/               36   pol/buildings/               78
aus/buildings/               78   pol/units/                   14
aus/units/                   14   por/buildings/               78
bav/buildings/               78   pru/buildings/               78
common/buildings/             1   rus/buildings/               78
common/naval/                12   rus/units/                   14
common/units/               196   sax/buildings/               78
den/buildings/               78   sco/buildings/               18
eng/buildings/               78   sco/units/                   18
eng/units/                   14   spa/buildings/               78
fra/buildings/               78   spa/units/                   14
hun/buildings/               78   swe/buildings/               78
net/buildings/               78   swi/buildings/               78
pie/buildings/               78   tur/buildings/               72
ukr/buildings/               72   tur/units/                   14
ven/buildings/               78   ukr/units/                   14
```

Grouped totals:

| Group | Folders | PNGs | Notes |
|---|---:|---:|---|
| `<nation>/buildings` | 21 | 1,524 | 17 nations × 78; `tur`,`ukr` × 72; `alg` 36; `sco` 18 |
| `<nation>/units` | 8 | 116 | 7 × 14 + `sco` 18 (national peasants + `sco_highlandersword`) |
| `common/units` | 1 | 196 | generic soldier/peasant and `spakh_*` sheets |
| `common/buildings` | 1 | 1 | `mill_rotor.png` only |
| `common/naval` | 1 | 12 | all hull/crew sheets, no nation subfolders |
| **Total** | **32** | **1,849** | no `<nation>/naval` folders (donor has no per-nation hulls) |

Five JSON metadata files deliberately stayed at their legacy paths (key counts
verified): `buildings/buildings.json` 1,524 keys, `buildings/mill_rotor.json` 3,
`land_units/index.json` 54, `land_units/sco_units.json` 1,
`naval_units/index.json` 5. No PNGs remain in the old flat root.

---

## 2. Migration & rollback procedure

Two logged stages:

1. **Flat → category** (`inbox/anim_migration_manifest.json`,
   `inbox/anim_migration_undo.json`): 312 root sheets moved to `land_units/`.
2. **Category → nation-first** (`inbox/anim_nation_plan.json` →
   `app/tools/migrate_anim_nations.py`, `inbox/anim_nation_undo.json`): all
   1,849 pairs moved to the tree above. 1,837 originally sat at the flat anim
   root (1,525 building sheets, plus 312 land-unit sheets that stage 1 had
   placed in `land_units/`); the 12 naval pairs came from `naval_units/`.

Each move rewrote exactly 3 fields of the sibling `.png.import`, byte-preserving
everything else (`uid`, `importer`, `type`, `metadata`, all `[params]`):

```
[deps] source_file = res://assets/models/anim/<nation|common>/<kind>/<name>.png
[remap] path        = res://.godot/imported/<stem>-<NEW_MD5>.ctex
[deps] dest_files[0]= res://.godot/imported/<stem>-<NEW_MD5>.ctex
NEW_MD5 = md5("res://assets/models/anim/<nation|common>/<kind>/<name>.png".encode())
```

Undo logs hold, per operation, the PNG/import names, source and target dirs,
the three reverse replacements, and the original `.import` bytes as SHA-256 +
base64; `anim_nation_undo.json` additionally lists the 32 created dirs.

```bash
python app/tools/migrate_anim_nations.py --verify     # targets, fields, counts, leftovers
python app/tools/migrate_anim_nations.py --rollback   # restore .import bytes, move pairs back
python app/tools/migrate_anim_nations.py --apply      # re-apply (--dry-run is the default)
```

Rollback order: undo the nation-first move first (1,849 ops), then — only if a
full pre-category restore is wanted — replay `anim_migration_undo.json` (312
ops). Remove created dirs only when empty. Never touch the five JSON metadata
files. The two stale editor TMP files named in the plan
(`rus_sta_s4.png.import~RF139ced6.TMP`, `rus_sto_dead.png.import401825162.tmp`)
were explicitly excluded and are no longer present. Stale `.godot/imported/*-<OLD>.ctex`
files are Godot's to regenerate; do not hand-delete them as part of a rollback.

---

## 3. Resolver rules (`app/scripts/world.gd`)

- `const NATIONS` (lines 14–18): the 21 codes that own `<nat>/{units,buildings}`.
- `nation_of(name)` (822–827): strips `.png`, requires `stem[3] == '_'`, then checks
  the 3-letter prefix. The underscore guard is mandatory — `spakh_*` starts with
  a valid code (`spa`) but has no underscore at index 3, so it stays in
  `common/units`.
- `_nation_sheet(base, name, kind, legacy)` (833–844): probes, in order,
  `res://assets/models/anim/<nat>/<kind>` and `.../common/<kind>` for the canonical
  root, then the same pair under `base` when a quality preset redirected
  `_anim_dir()`, then the caller's legacy chain.
- `_sheet(base, name, dirs)` (850–855): unchanged — first existing candidate wins,
  else returns `<base>/<name>`.

Call sites:

| Line | Function | kind | Legacy fallbacks |
|---:|---|---|---|
| 481 | `_anim_sheet` (units/crew) | `units` | `common/naval`, `land_units`, `naval_units`, `buildings`, anim root |
| 572 | `_bld_key` (nation skin probe) | `buildings` | `buildings/`, anim root |
| 579 | `_mill_rotor` | `buildings` | `buildings/`, anim root |
| 613 | `_bld_anim` | `buildings` | `buildings/`, anim root |
| 2799 | `_hull_tex(key)` | `naval` | `naval_units/`, anim root |
| 2801 | `_hull_tex("yacht")` fallback | `naval` | same |

Invariants: `anim_tex` and `hull_tex_cache` keys remain filename-derived, so no
redraw logic changed; hull lookup uses `e.sid` as the family key (2818–2825), with
`yacht` as the fallback family. Mirror implementations were added to
`app/tools/compute_buildings.py`, `sheet_metrics.py` and `bake_sprites.py`
(the latter's `NATIONS` now includes `sco`), all with the same index-3 guard.

---

## 4. Baker changes

- **One reusable ortho camera per bake** (was one per view per frame — 8 cameras
  per frame). `bake_sprites.py:213–245` adds `camera_create()` / `camera_set()`;
  the unit bake (500–538) and `bake_naval.py:213–217,274` retarget one camera.
  The rig (azimuth `d*45°`, elevation 32°, 50 m offset, same `ortho_scale`) is
  identical, so pixel output is unchanged.
- **Duplicate-key alias** `ALIAS_OF = {"peasant": "ukr_peasant"}`
  (`bake_sprites.py:43–48`). Both keys resolve to donor base `peaukr`;
  `make_alias_entries()` (601–626) writes a full metadata copy plus `alias_of`
  markers into `index.json` and skips writing the duplicate PNGs.
  `--no-alias` restores bake-every-key. Verified on the live tree: **14/14**
  `peasant_*` vs `ukr/units/ukr_peasant_*` pairs are byte-identical;
  3,484,851 bytes = 3.32 MB on disk now (the 3.55 MB figure in the wave brief was
  measured before alpha-noise normalization).
- **`--layout flat|nested|nation`** (default `nation`, 83–85): sheets go to
  `out/<nat|common>/<kind>/`; `index.json` stays in `out/land_units/` either way.
- **Nested-path readers/writers patched**: `bake_sprites.py`, `bake_naval.py`
  (`common/naval/`, index in `naval_units/`), `bake_mill_rotor.py`
  (`common/buildings/`, `--legacy-flat` escape hatch), `bake_scottish.py`
  (`sco/buildings/`, `sco/units/`), `compute_buildings.py`, `sheet_metrics.py`;
  tests `mill_visual_test.gd` and `t_naval.gd` split index paths from PNG paths.

**Caveat (honest):** `alias_of` is written by the baker but is **not read by the
runtime** — `world.gd` has no `alias_of` lookup (grep: only 4 hits, all in
`bake_sprites.py`). Today this is harmless because the old duplicate PNGs are
still on disk. A future re-bake with aliasing enabled that deletes those PNGs
would break the `peasant` key until the resolver learns to redirect.

---

## 5. Donor fairness findings

| Claim | Evidence | Verdict |
|---|---|---|
| Peasants for exactly 8 nations | Donor `data/actors/units/pea{aus,eng,pol,rus,sco,spa,tur,ukr}.oss`; index has exactly `ukr/rus/pol/aus/eng/spa/tur/sco_peasant` | Correct, complete |
| National soldier variants under-represented | Donor has e.g. `grenadier{bav,den,hun,pru,sax}`, `musketeer18{bav,den,pru,sax}`, `musketeer{aus,net,pol,sco,spa}`, `hussar{hun,pru,swi}`, `pikeman{pol,por,rus,sco,spa,swi,tur}`, `jager{por,swi}`; only the 8 peasants are baked as national keys | **Optional fidelity.** The donor-audit tally was 11 nations with such variants; the pattern is verified here, the exact 11-nation count was not re-derived in this docs ticket |
| Naval: no per-nation variants | No `<nat>_hull.png`; all 12 hull/crew sheets are family-keyed (`yacht`, `yachttur`, `fishboat`, `frigate`, `galley`, `xebec`, `battleship`). `yachttur` is a distinct donor family/roster sid, not a Turkey skin of `yacht` | `common/naval` is donor-correct |
| Algeria: 36 buildings | 6 types × 6 states (`cen,hou,mar,mil,sto,tow`). Donor has unique `alg` meshes only for `cen`/`hou`; `bake_building()` falls back to `commoneur/eur<type>` for the rest | Mesh-limited, not a bake bug |
| Scotland: 18 buildings | Only `bar,cen,hou` × 6 baked. Donor `data/actors/buildings/sco/` has 11 families, including `scoba2` (= the port's `bar18`) plus `aca,art,bla,dip,sta,...` | **Real bake gap** for the remaining donor families; `bar18` is the known case |

---

## 6. Dedup verdict — DO NOT COLLAPSE

Two independent scans, different scopes:

- **Exact duplicate audit** — all **1,849** sheets: 0 sheets with duplicate rows,
  15,111 rows / 15,111 unique rows (2,829 transparent rows excluded from the dup
  test), 0 duplicate rows. 11 sheets contain 40 duplicate *cells* (3.91 MB raw
  waste) but `est_png_savings = 0.0 MB`. Spot verification: `alg_cen`, `alg_cen_dead`,
  `alg_cen_s1` rows are **not** byte-identical (best match ~39.7k/51.2k and
  45.6k/51.2k bytes).
- **Perceptual near-dup audit** — 214 unit sheets in `common/units` + `sco/units`,
  1,976 rows: 1,693 adjacent pairs pass the permissive 32×32-grayscale
  MAE < 0.02 threshold, but full-resolution comparison finds **0 exactly
  identical strips**. 1,655 pairs are real `subtle_motion`, only 38 are
  `near_static` across 33 sheets, 0 are `exact_static`. The 1,322.656 MB
  "collapse everything" figure is an unsafe upper bound; the conservative
  exact-only saving is **0 MB**, and even collapsing all near-static groups is
  only ~88 MB *raw RGBA* before PNG compression and playback-map overhead.

Verdict: no frames were collapsed. The 96% pass rate of the 0.02 threshold is an
artifact of downsampling; walk/attack/idle motion dominates, which is exactly
where collapsing would be most damaging, for a realizable saving below 0.3 MB.
The 3.91 MB of duplicate cells is 40 frames spread across 11 sheets and was left
alone for the same reason.

---

## 7. Alpha-noise normalization

`app/tools/normalize_alpha_noise.py` zeroes RGB **only where `alpha == 0`**;
semi-transparent (`0 < alpha < 255`) and opaque pixels keep their values.
All **1,849** PNGs were processed (`--apply`, commit `63d4a0de`).

| Metric | Value |
|---|---|
| PNG bytes before / after | 322,601,400 → 269,611,324 (current tree re-counted: exact match) |
| Saved | **52,990,076 bytes = 50.535 MB = 16.426%** |
| Hidden-noise pixels removed | 21,863,544 (1,845 of 1,849 files affected) |
| Semi-transparent pixels preserved | **14,361,753** (all 1,849 files use semi-transparency) |
| Files with residual alpha0 noise | 0 |

Each PNG's Godot `.md5` cache companion had **only `source_md5`** patched to the
new PNG md5; `dest_md5` and the `.ctex` were left untouched because the visible
image is identical — no reimport was needed for this step.

`inbox/alpha_norm_verify.json`: `ok: true`, `files_checked: 1849`,
`residual_alpha0_noise: 0`, `semi_transparent_mismatches: 0`,
`cache_source_md5_mismatches: 0`, `cache_missing: 0`, `mode_mismatches: 0`,
`problems: []`.

Rollback: `python app/tools/normalize_alpha_noise.py --rollback` restores every
PNG from `%TEMP%/opencode/alpha_norm_backup/...` and writes the original
`source_md5` values back (log `inbox/alpha_norm_undo.json`, report
`inbox/alpha_norm_rollback.json`). Modes: `--dry-run` (default), `--apply`,
`--verify`, `--rollback`.

Note on the earlier projection: `inbox/alpha_noise_audit.json` extrapolated a
60-file sample to ~17 MB / 5.3%. The tool's own docstring records why that is
low: the sample under-weighted the 1,524 building sheets (~13.7% saving) and
over-weighted nation units (~1.2%). The exact full-tree figures above supersede
the estimate.

---

## 8. Verification evidence

- **Counts**: 1,849 PNG + 1,849 `.import`; 32 created dirs in
  `inbox/anim_nation_undo.json`; 5 JSON metadata files intact with 1,524 / 3 /
  54 / 1 / 5 keys.
- **.import rewrites**: independent pass over all 1,849 files — 0 cases where
  `source_file` did not match the file's own nested path. Per-op reverse
  replacements and original SHA-256/base64 are in both undo logs.
- **Wave-level verify**: `verify PASS 1849/1849` was reported by the migration
  executor; no persisted migration-verify JSON exists in `inbox/`, so the
  counts above were re-derived directly from the live tree in this ticket.
- **Reimport fix**: Godot job `anim-reimport2`, ticket 1093,
  `--headless --path app --import`, `run: 381.531 s`, `exit: 0`, `status: ok`.
  This one-time reimport (before normalization) regenerated the `.ctex` files
  that the rewritten `.import` paths referenced and cleared the missing-`.ctex`
  import crash.
- **Load smoke**: `app/tests/t_sheet_load.gd` loads 5 representative sheets
  (rus peasant, aus building, archer, yacht hull, sco peasant). Ticket 1094
  failed on a GDScript type-inference parse error in the test; after the fix,
  tickets 1095 and 1096 both report `SHEET_SMOKE 5/5`.
- **Git**: `021fe169` ("move shit around") carries the move, the 1,849 `.import`
  rewrites and the baker/tool/resolver changes; `63d4a0de` ("compress images?")
  carries the 1,849 PNG byte changes from normalization.
- **Alias**: 14/14 byte-identical peasant pairs, re-hashed in this ticket.
- **Syntax**: `--check-only` on `world.gd` (ticket 1127) exited 0.

---

## 9. Known gaps & honest status

| Item | Status |
|---|---|
| Nation-first layout, resolver, tools | **Shipped**; runtime resolves all six call sites; smoke 5/5 |
| Alpha-noise normalization | **Shipped, verified**; 50.54 MB saved, zero visual change, reversible |
| Duplicate-frame collapse | **Deliberately not done**; no realizable saving, high animation risk |
| Scotland buildings | **Open gap** — 18 of the donor's 11 sco families baked; `bar18`/`scoba2` is the known missing family |
| National soldier variants | **Open, optional** — only 8 national peasants baked; other national soldier meshes are represented by generic sheets (audit tally: 11 nations) |
| Peasant alias | **Baker-only saving right now** — `alias_of` is not consumed by `world.gd`; the duplicate PNGs are still on disk, so behavior is correct today |
| Migration verify artifact | Wave reports PASS 1849/1849; only the plan/undo manifests are persisted, not a verify JSON |
| Donor audit 11-nation tally | Pattern independently confirmed; exact tally accepted from the donor audit, not recomputed here |

No source, asset or tool file was modified by this documentation ticket.

---

## 10. Manual checks (owner / QA)

1. In-engine visual spot check of one sheet per resolver branch:
   `rus_peasant_idle`, `aus_cen`, `archer_walk`, `spakh_walk`, `mill_rotor`,
   `yacht_hull`, `sco_peasant_walk`, `sco_highlandersword`.
2. Confirm generic `peasant_*` sprites still draw after any future re-bake that
   omits those PNGs — if they fail, add `alias_of` handling to `_anim_sheet()` in
   `world.gd` before re-baking.
3. If Scotland fidelity is wanted, bake the missing `sco` donor families
   (`scoba2` → `sco_bar18` first) with `app/tools/bake_sprites.py --buildings`,
   then extend `buildings/buildings.json` and re-run `compute_buildings.py`.
4. If national soldier fidelity is wanted, decide per family whether to add
   bake keys (and a resolver key in `_anim_key`) or formally waive them.
5. Re-run `python app/tools/migrate_anim_nations.py --verify` and
   `python app/tools/normalize_alpha_noise.py --verify` before any further asset
   churn; both are read-only.
6. After any future Godot reimport, re-run `t_sheet_load.gd` (expect 5/5) and
   check `app/.godot_queue/status.json` for the new job's `exit`/`status`.
