# Asset Integrity Audit — agentY

Read-only audit. No asset or script was modified. `res://` maps to `app/`.

## Summary counts

| Check | Result |
|---|---|
| `.gd` scripts scanned | 17 |
| Static `res://` literals | 59 (all resolve on disk) |
| Dynamic/constructed `res://` paths | 18 (all target directories exist) |
| Distinct literal targets verified | 32 / 32 OK, 0 MISSING |
| `index.json` unit keys | 54 |
| Expected `<key>_<action>.png` from index.json | 299 — **0 missing, 0 orphan** |
| `buildings.json` keys | 1506 — **0 missing `<key>.png`, 0 unclaimed PNGs** |
| PNG files under `app/assets` | 2626 |
| `.import` files under `app/assets` | 2973 — **0 without source** |
| PNG files without `.import` | **0** |
| Raw donor-format files present | 468 `.dds` + 29 `.obj` + 29 `.mtl` + 4 `.lib` + 4 `.mat` |
| Scratch donor-derived file under res:// | 1 (`_mill_tmp/eurmil.png`) |

**Bottom line: asset-reference integrity is clean.** Every path literal, every
`index.json`/`buildings.json` key and every `.import` resolves to a file on disk.
There are no missing referenced assets causing blank sprites, and no orphaned
`.import` files. All findings below are **licence-exposure / hygiene** issues, not
broken references.

## Path patterns discovered (from `.gd`)

Static literals (all OK): `res://scripts/*.gd` preloads; `res://assets/missions.json`;
`res://assets/models/anim/{index.json,buildings.json}`; `res://assets/terrain/structs/*.json`;
`res://assets/terrain/structs/tile_{low,high}ground.png`;
`res://assets/terrain/water_png/diffusewaves2.png`; `res://assets/ui/icons.bmp`,
`iconsunits.bmp`, `overlays/{shadow,ring_p0,ring_p1,ring_sel}.png`;
`res://assets/sounds/btnclick.ogg`; `res://assets/terrain/masks/manifest.json`;
`res://assets/terrain/patterns/donor_patterns.json`.

Dynamic patterns (all target dirs exist):
- `res://assets/models/sprites/%s_%03d.png` (world.gd:186) and `.../%s.png` (:197-198)
- `res://assets/models/sprites_hi/%s.png` (world.gd:194,196)
- `res://assets/models/anim%d/{index.json,…}` for `SPRITE_CELL` 64/96/160 (world.gd:264-271) — dirs `anim64/anim96/anim160` do **not** exist, but code falls back to `anim`, so harmless
- `%s/%s.png` inside anim dir: unit `<key>_<action>.png` (world.gd:294), nation building `<nat>_<sid>.png` (:350), `mill_rotor.png` (:356), building `<key>.png` (:383), per-entity anims (:1530-1531)
- `res://assets/terrain/decals_png/%s%sd.png` (world.gd:463), `blocks/%s.png` (:620), `dmask/d_%02d.png` (:652)
- `res://assets/ui/cursor_%s.bmp` (input_controller.gd:35)
- `res://assets/sounds` + name (audio.gd:13)
- `res://assets/terrain/masks/` + manifest `file` (mapgen.gd:125)
- `res://shots/bench.json`, `seq_index.json`, `frame_%04d.png` (main.gd:953,1339,1345)

## Top 20 missing / orphaned / exposure paths

No missing or orphaned *referenced* assets exist. The 20 highest-priority paths
are the raw donor-format / scratch files (all reported, none deleted):

1. `app/assets/terrain/decals_dds/algcend.dds` (of 462 tracked `.dds` in `decals_dds/`)
2. `app/assets/terrain/decals_dds/algcendw.dds`
3. `app/assets/terrain/decals_dds/alghoud.dds`
4. `app/assets/terrain/decals_dds/ausacad.dds`
5. `app/assets/terrain/decals/eurgold.dds`
6. `app/assets/terrain/decals/ruscend.dds`
7. `app/assets/terrain/decals/ukrbard.dds`
8. `app/assets/terrain/decals/ukrcend.dds`
9. `app/assets/terrain/decals/ukrhoud.dds`
10. `app/assets/terrain/decals/ukrstad.dds`
11. `app/assets/terrain/decals_dds/decals_dlc1.lib`
12. `app/assets/terrain/decals_dds/decals_dlc2.lib`
13. `app/assets/terrain/decals_dds/decals_dlc3.lib`
14. `app/assets/terrain/decals_dds/decals_exp1.lib`
15. `app/assets/terrain/decals_dds/decals_dlc1.mat`
16. `app/assets/terrain/decals_dds/decals_dlc3.mat`
17. `app/assets/terrain/decals_dds/decals_exp1.mat`
18. `app/assets/models/anim/_mill_tmp/eurmil.png` (tracked scratch; P-05)
19. `app/assets/models/anim/_mill_tmp/eurmil.png.import` (untracked companion)
20. `app/assets/models/obj/aca.obj` (git-ignored via `obj/`; 29 `.obj` + 29 `.mtl` pairs)

## Licence exposures (donor raw files, not converted/derived assets)

- **468 `.dds` decals (TRACKED in git).** `app/assets/terrain/decals_dds/` (462) and
  `app/assets/terrain/decals/` (6). These are native donor textures; the port uses
  only the converted `decals_png/*.png` (924 files). `.dds`, `.lib`, `.mat` are
  referenced in `.gd` **only in comments** (world.gd:3,6,66,130) — zero runtime use.
- **8 donor descriptor files (TRACKED).** `decals_dds/decals_{dlc1,dlc2,dlc3,exp1}.{lib,mat}`.
- **29 `.obj` + 29 `.mtl` + 29 `.import` in `app/assets/models/obj/`.** Intermediate
  donor geometry used for baking; on disk but **git-ignored** (`.gitignore:19 obj/`),
  so not committed — still physically in the repo folder.
- **Scratch `_mill_tmp/eurmil.png` + `.import`.** Donor-derived scratch inside
  `res://`; `eurmil.png` is **tracked**, `.import` untracked. Already flagged as
  P-05 by Review desk (mill-rotor feature, unowned). Not touched.

Per instruction: paths only, nothing deleted.

## Recommended actions

1. Compliance/coordinator decision on the 468 tracked `.dds` + 8 `.lib/.mat`
   donor decals: if not needed for the private-use build, remove from `res://`
   and add `app/assets/terrain/decals*/` to `.gitignore`; keep only converted
   `decals_png/`. Do not redistribute any of it.
2. Resolve P-05: route `_mill_tmp/` scratch to system temp, untrack
   `eurmil.png`, drop its `.import`. Needs owner + user sign-off.
3. Keep the `obj/` ignore rule (already prevents the 29 donor meshes from being
   committed); consider purging the on-disk copies from the working tree.
4. No action needed for `index.json`, `buildings.json`, `.import` files, or any
   script path literal — all are internally consistent.

## Files changed

- `ASSET_AUDIT.md` (new) — this report only. No asset or script modified, no
  Godot run used.

## Open questions

- Are the tracked raw `.dds`/`.lib`/`.mat` decals intentionally retained as
  rebuild sources, or accidental donor copies? Compliance (Review desk) to decide.
- Are the git-ignored `.obj` models still needed for future sprite rebakes?
- Confirm P-05 ownership before any `_mill_tmp/` removal (unowned mill-rotor feature).
