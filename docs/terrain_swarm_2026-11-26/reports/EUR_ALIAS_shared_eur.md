# EUR-ALIAS — shared European building aliases

Date: 2026-11-26
Scope: `variant3d/assets/models/manifest.json` `extra_assets` only. No art conversion, no code.

## Change

Added 4 alias rows (zero new binaries):

- `eurmil → shared/buildings/mil.obj + mil.png`
- `eursto → shared/buildings/sto.obj + sto.png`
- `eurmar → shared/buildings/mar.obj + mar.png`
- `eurtow → shared/buildings/tow.obj + tow.png`

Rationale (AUDIT_BUILDING_NATIONS §2/§5, AUDIT_MISSING_PARTS G12): donor `eur<sid>.osm` art was converted under generic sids; runtime probes donor-correct `eur*` stems and could never hit. Aliases make `exact=true` reachable for bav/pol/swe/etc. without new art. `rus*/tur*` variants still correctly BLOCKED until converted.

Backup: `inbox/backup/manifest.json.bak-EURALIAS`
No parity claim.
