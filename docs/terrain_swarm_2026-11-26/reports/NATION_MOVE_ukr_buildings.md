# NATION-MOVE — Ukrainian buildings from shared/ to ukr/

Date: 2026-11-26
Scope: `variant3d/assets/models/obj/*`, `tex/*`, `manifest.json` only. No code, no donor execution.

## Move executed

- Source: `variant3d/assets/models/obj/shared/buildings/` (126 OBJs)
- 80 OBJs moved (8 sids × 10 stage variants: base, 1..4, 1a..4a, a):
  `cen, hou, bar, sta, bla, aca, art, dip`
- Each with `.mtl` + `.obj.import` moved alongside
- 8 base textures moved: `tex/shared/buildings/{cen,hou,bar,sta,bla,aca,art,dip}.png` (+ `.import`) → `tex/ukr/buildings/`
- Destination: `variant3d/assets/models/obj/ukr/buildings/` (new), `variant3d/assets/models/tex/ukr/buildings/` (new)
- Manifest: 80 entries updated — `bucket: shared/buildings → ukr/buildings`, `assets.obj/tex` rewritten. Sprites left at `sprites/shared/buildings/` to avoid breaking 2D pipeline.
- `.mtl` `map_Kd` rewritten: `tex\shared\buildings\ → tex\ukr\buildings\`
- Backups: `inbox/backup/manifest.json.bak-NATIONMOVE`

## Verification (snapshot, not unit tests)

- `manifest.json` parses, `cen` entry now `obj: res://assets/models/obj/ukr/buildings/cen.obj`, `bucket: ukr/buildings`
- `.mtl` check: `cen.mtl` → `..\..\..\tex\ukr\buildings\cen.png`
- Counts: `shared/buildings/*.obj` 126 → 46, `ukr/buildings/*.obj` 0 → 80
- Snapshot `cap_nationmove.png` (seed 20261113, default config donor backend): hall + houses render correctly, no missing-mesh proxy regression visible

## Remaining

- `rus/bav/pol/swe cen` stay nation-local (correct per AUDIT_BUILDING_NATIONS)
- `eur*` alias fix (mil/sto/mar/tow) still open — needs `extra_assets` rows, not a file move
- No parity claim. Donor parity UNVERIFIED.
