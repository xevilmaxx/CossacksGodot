---
owner: P3
wave: perf
date: 2026-11-24
scope: read-only recon — asset sizes, memory/load-time, on-disk footprint
output: docs/coord_swarm_2026-11-24/reports/P03_assets_memory.md
---

# P3 — Asset / memory / load-time recon (no edits)

**Method:** Python `os.walk` + `hashlib.sha256` + Pillow over `app/assets/**`;
static reads of `app/scripts/*.gd`, `app/tools/bake_sprites.py`, `.import` files,
`git ls-files` / `git check-ignore`. No Godot, no runner, no screenshots were run
by this lane. **MEASUREMENT** = file bytes/counts or code lines re-readable at
`file:line`; **ESTIMATE** = unbenchmarked magnitude. `app/shots/**` (525.41 MB on
disk) is diagnostic and is **excluded from all shipped-size claims**; `app/.godot/**`
(1731.61 MB) is gitignored cache, not shipped.

## 1. Size table — top 20 largest shipped assets (source bytes)

| # | path (rel. `app/`) | bytes | MiB | note |
|---|---|---:|---:|---|
| 1 | assets/sounds/pie.ogg | 15,680,184 | 14.96 | national music track |
| 2 | assets/sounds/sco.ogg | 15,175,213 | 14.48 | national music track |
| 3 | assets/sounds/pol.ogg | 14,481,355 | 13.81 | national music track |
| 4 | assets/sounds/den.ogg | 13,466,330 | 12.84 | national music track |
| 5 | assets/sounds/sax.ogg | 13,270,219 | 12.66 | national music track |
| 6 | assets/sounds/aus.ogg | 12,783,807 | 12.20 | national music track |
| 7 | assets/sounds/rus.ogg | 12,237,628 | 11.67 | national music track |
| 8 | assets/sounds/tur.ogg | 12,082,254 | 11.53 | national music track |
| 9 | assets/sounds/pru.ogg | 11,988,953 | 11.44 | national music track |
| 10 | assets/sounds/ukr.ogg | 11,668,066 | 11.13 | national music track / fallback |
| 11 | assets/sounds/ven.ogg | 11,426,237 | 10.90 | national music track |
| 12 | assets/sounds/bat1.ogg | 11,378,218 | 10.85 | music |
| 13 | assets/sounds/net.ogg | 11,166,482 | 10.65 | national music track |
| 14 | assets/sounds/swi.ogg | 11,041,350 | 10.53 | national music track |
| 15 | assets/sounds/hun.ogg | 10,949,560 | 10.44 | national music track |
| 16 | assets/sounds/alg.ogg | 10,893,144 | 10.39 | national music track |
| 17 | assets/sounds/fra.ogg | 10,477,666 | 9.99 | national music track |
| 18 | assets/sounds/swe.ogg | 10,420,774 | 9.94 | national music track |
| 19 | assets/sounds/spa.ogg | 10,053,346 | 9.59 | national music track |
| 20 | assets/sounds/bav.ogg | 9,909,466 | 9.45 | national music track |

**Totals (MEASUREMENT, `app/assets/**` source files):** 7,846 files,
2,485,217,904 B = **2,370.09 MiB**. By extension: `.png` 2,929 / 1,456.50 MiB;
`.dds` 468 / 613.57 MiB; `.ogg` 325 / 281.81 MiB; `.obj` 116 / 10.29 MiB;
`.import` 3,383 / 2.91 MiB; JSON 18 / 1.39 MiB; rest negligible.
Largest folders: `terrain/decals_png` 859.71 MiB (462 PNG), `terrain/decals_dds`
605.62 MiB (462 DDS), `sounds` 281.81 MiB (325 OGG), `terrain/blocks` 166.06 MiB
(112 PNG), `models/tex` 133.38 MiB (116 PNG).

## 2. Duplicate table (sha256-identical, top groups)

| group | files | bytes each | reclaimable | paths (representative) |
|---|---:|---:|---:|---|
| decals_png national trim | 21 | 2,126,727 | 40.56 MB | `terrain/decals_png/{alg,pie,...}*dw.png` |
| decals_dds national trim | 21 | 1,398,256 | 26.67 MB | `terrain/decals_dds/{alg,pie,...}*dw.dds` |
| rock sea texture | 4 | 6,531,253 | 18.69 MB | `models/tex/rock_sea{1,4,5,6}.png` |
| winter/test blocks | 5 | 1,750,219 | 6.68 MB | `terrain/blocks/{test19,winter23..26}.png` |
| small sea rocks | 16 | 355,347 | 5.08 MB | `models/tex/rock_{smallstonesea,stonessea}*.png` |
| eur decals (w) | 3 | 2,384,054 | 4.55 MB | `terrain/decals_png/eur{coad,gold,irod}w.png` |
| eur decals | 3 | 2,292,802 | 4.37 MB | `terrain/decals_png/eur{coad,gold,irod}.png` |
| flowers | 6 | 848,576 | 4.05 MB | `models/tex/{flower,plantain}{1..3}.png` |
| mill sheet (nations) | 20 | 136,647 | 2.48 MB | `models/anim/<nat>/buildings/<nat>_mil.png` |

**Total: 134 duplicate groups, 271,962,213 B = 259.36 MiB reclaimable across
`app/assets`** (MEASUREMENT). Of this, `decals_png` alone contributes 27 groups /
100,929,875 B (96.3 MiB). Caveat: these are distinct *paths* referenced by name
(e.g. `world.gd:712` builds `decals_png/<nat><sid>d.png`), so dedup must preserve
filenames (hardlink/canonical copy), not delete the extra paths.

## 3. Claim table — opportunities

| ID | path / site | measured | minimal fix | visual / functional risk | verify no regression | label |
|---|---|---|---|---|---|---|
| A1 | `app/assets/terrain/decals_dds/**` + `app/assets/terrain/decals/**` | 468 DDS, **613.57 MiB**; 462 stems 1:1 with `decals_png`; **0 `.import` files**; **0 runtime refs** (only `tools/copy_assets.py`) | Exclude both dirs from shipped export / stop tracking; keep `decals_png` (the runtime format) | **None by construction** — no `.gd`/`.tscn` load path, Godot never imports them | grep runtime `decals_dds`/`.dds` → 0; existing capture harness screenshot sha256 before/after identical | **MEASUREMENT** (size, refs); gain on export size = ESTIMATE until export run |
| A2 | `app/scripts/audio.gd:46-47` | `for f in files: _stream(f)` eagerly `load()`s **all 325 OGGs / 281.81 MiB** at `_ready()` (invoked via `main.gd:550-551`); 22 national tracks alone 246.7 MiB | Delete the 2-line eager loop; `files` (used by `names_for()`) and lazy `_stream()` already suffice | Low: first play of a sound pays one synchronous `load()` (~ms; OGG decode is streaming). Possible one-off hitch | `app/tests/t_audio_events.gd` selftest; confirm every `play(prefix)` still resolves via `names_for()`; startup wall-clock before/after | code **MEASUREMENT**; latency gain **ESTIMATE** |
| A3 | `app/assets/terrain/decals_png/**` duplicates | 27 groups / **96.3 MiB** redundant PNG | Replace duplicate paths with hardlinks to one canonical file per hash (paths unchanged for Godot) | Low if every filename and byte is preserved; zero visual change | sha256 of every retained path must equal pre-change value; screenshot diff = 0 | **MEASUREMENT** |
| A4 | `app/assets/models/tex/*.png` (20 files 2048×2048) | **~90 MiB** source; 344 PNGs >1024px = 238.35 MiB; all 2,942 `.import` use `compress/mode=0` (lossless), `mipmaps/generate=false` | Set `process/size_limit=1024` on import for textures whose on-screen footprint is <512px at max zoom, or bake 1024 versions | **Medium**: visible softening on close zoom; must not touch UI/minimap art | Side-by-side capture at game zoom + max zoom, SSIM/pixel diff review; keep sources in git | sizes **MEASUREMENT**, savings/visual delta **ESTIMATE** |
| A5 | `app/.godot/imported/*.ctex` | 4,195 `.ctex` = 1,440.1 MiB; **607 stale (144.6 MiB)** with no matching source basename (deleted `app/shots` diagnostics: `contact.png`, `t6t90_*`, `ref_*.jpg`, `variant_*`) | Remove only stale `.ctex` + `.md5` orphan pairs; gitignored, not shipped | **None** — 0 `.import` files have a missing source | `git check-ignore app/.godot/` confirmed; re-import and confirm no `.import` references stale ids | **MEASUREMENT** (disk only, not export size) |
| A6 | `app/tools/bake_sprites.py:541` | `sheet.save(...)` uses Pillow default PNG compression; bake output currently 100.93 MiB (`models/anim/common/units`) | `optimize=True` / `compress_level=9` on re-bake (offline only) | **None visually** (lossless) | byte-for-byte pixel equality via Pillow `Image.tobytes()`; file bytes may differ | **ESTIMATE**, unbenchmarked |
| A7 | giant JSON at startup | `anim/land_units/index.json` 99,840 B + `buildings/buildings.json` 215,874 B + `manifest.json` 86,879 B parsed in `world.gd:308-319,656-664`; `donor_patterns.json` 982 KB via `pattern_gen.gd:42` | Already lazy/cached (`bld_scale_idx`, `naval_index` guarded by `is_empty()`); `donor_patterns` only on random-map gen. No change recommended | n/a | confirm call sites above | **MEASUREMENT** — **NO_WIN** at <1.5 MB total |

**Non-goal / not proposed:** re-encoding OGG music (audio-quality change), switching
runtime to DDS (quality unknown), copying or redistributing any donor asset
(`reference/`, `data/`) — none of these are in scope.

## 4. Top 5 by gain × safety

| rank | opportunity | gain | safety | why this order |
|---|---|---|---|---|
| 1 | **A1** drop 613.57 MiB unreferenced DDS decals | 613.57 MiB source; largest single safe win | highest — zero code imports them, zero `.import` | measurable, irreversible-only-on-disk, no render path |
| 2 | **A2** remove eager audio preload | 281.81 MiB off startup RAM/I/O; only played nation's track loads | high — lazy path already exists; first-play hitch verifiable | biggest load-time win, tiny patch |
| 3 | **A3** hardlink duplicate PNG decals | 96.3 MiB source | high — paths/bytes preserved | safe dedup with zero path changes |
| 4 | **A5** purge stale `.godot` cache | 144.6 MiB disk | highest | cheap but **not shipped**, so ranked below A3 |
| 5 | **A4** downscale oversized textures | ~90 MiB source + large `.ctex`/VRAM reduction | **lowest** — visual risk at zoom; requires capture review | high gain but only if zoom tests pass |

## 5. Git exposure (MEASUREMENT — no git state changed)

- `git ls-files`: 10,638 tracked files; 7,496 under `app/assets/`, **932 under
  `app/assets/terrain/decals_dds/` (634,984,224 B)**, 650 under `app/assets/sounds/`.
- 750 **tracked** PNGs under `app/shots/**` = 268,643,283 B, despite
  `.gitignore:54` `app/shots/**/*.png` — ignore rules do not untrack files already
  committed. Largest: `app/shots/j2/contact.png` (3.48 MB), unit-piece walk sheets,
  `map_variants/compare_with_originals*.png`. **Exposure risk: historical size,
  not shipped.** Do not change git state from this lane.
- `app/.godot/` (0 tracked), `app/.godot_queue/` and `app/shots/**/*.png` are
  correctly ignored going forward; the two `.tmp` / `.TMP` files under
  `app/assets/models/anim/buildings/` are untracked and covered by ignore rules.
- All 22 large national OGGs are tracked and **not ignored** — expected (they are
  shipped), noted for completeness.

## 6. Open questions

1. Does export (`export_presets.cfg`, itself gitignored) already filter
   `decals_dds`/`decals`? If yes, A1's export gain is 0 and only repo/VCS size
   improves — needs an export run to confirm (ESTIMATE flagged above).
2. Are hardlinks preserved by the Godot export packer for A3? If the packer
   dereferences them, the 96.3 MiB is saved on disk but **not** in the `.pck`.
3. Which `.import` files are referenced by scenes for the 607 stale `.ctex`?
   None found by basename match, but a full `uid://` cross-reference would make
   A5 airtight.
4. Is `models/obj/**` (232 files / 10.29 MiB, zero runtime `.gd` refs) needed
   only by offline bakers? Likely safe to exclude from export; low gain.
5. Is `audio.gd`'s eager loop load-bearing for any capture/headless harness that
   expects `cache` to be pre-populated? `t_audio_events.gd` must be run first.
