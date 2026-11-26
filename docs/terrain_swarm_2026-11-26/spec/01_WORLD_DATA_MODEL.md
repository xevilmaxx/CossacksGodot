# 01 — Donor-faithful world data model (from A01)

Source: `reports/A01_data_model.md`. **PORT APPROXIMATION for all port-side
representation choices; no donor parity claim.** A01 was written before the
D/F-wave reports landed — items marked `[U]` are queued for cross-check (D04
especially).

## 1. Mandatory core — donor-confirmed [O]

```
TMapTerrainDataTile   data/scripts/dmscript.global:2026-2030
  height    : Float        ; 4-byte float32 per height cell
  tex       : Integer      ; one discrete tile id per cell
  collision : Integer[4]   ; 4 tags per cell; collision grid = 2× height grid
```

Evidence: A01 E1 `dmscript.global:2026-2030` (via `DEC_05_terrain_formats.md:411`,
`DTRN_02:191`, `DTRN_01:115`); E2 `dmscript.global:80,134-135`,
`texturemap.inc:133-134` (`gc_terraindata_collision=4`,
`gc_MaxColMapWidth=2*640`).

The new module **must** be a structure-of-arrays holding these three, not a
splat map or vertex-colour field. Field *order* and struct stride remain `[U]`
(A01 E22 — known only from RTTI/text metadata).

## 2. Grid and coordinates [O]+[D]

| Item | Value | Evidence |
|---|---|---|
| Allowed `W=H` | 256, 320, 480, 640 (cap 640); 160 = port debug alias | A01 E3 `miscext2.script:19-26`, `dmscript.global:132-133` |
| Flat index | `i = y*W + x` | `game.gd:521`, `world3d_terrain.gd:1309-1310` |
| Cell centre | `((x+0.5)-W/2)*TILE_M`, `((y+0.5)-H/2)*TILE_M` | `TERRAIN2_01:136-138`, `world3d_terrain.gd:1310-1312` |
| Cell Y | `height[i] * HEIGHT_SCALE(1.0)` | `world3d_terrain.gd:131,1311` — scale is PORT APPROX |
| UV2 | `(float(tex[i]), float(face))`, face ∈ {0,1,2} | `world3d_terrain.gd:1315-1318,1407` — PORT APPROX |
| Row sign | **UNVERIFIED** | A01 E5 / Z04:98,454 |
| Metres per cell | `TILE_M=2.0` is port-only, **UNVERIFIED** | A01 §3 |

`W,H` live in the container, never read from `Data.MAP_W`; 160² and 640² dumps
can coexist in one process.

## 3. Side arrays (explicitly NOT donor-confirmed per-cell fields)

`terrain_class` (source bitmap R), `water` (derived from height thresholds),
`owner` `[U]`, `fog` (donor is a global shader/palette — per-cell is PORT APPROX),
`forest_density`/`stone_density` (mask G), `resource_id` `[U]`, `prop_index`
(pattern-instantiated `terrainmesh*.osm`, A01 E15), `relief_mask` (port
provenance), `mask_r/g/b` (`gMapMask`, A01 E7). Keep them labelled side arrays;
never let the renderer mistake them for `TMapTerrainDataTile` members.

Donor-confirmed **schema intent** (`generatemap.inc:413-490`, A01 E6): R=terrain class, G=forest/stone, B=water weight, `fa`→road — `[O]` text only. On shipped `_gauss` masks R/G are start-only (F04/X18/X19), so the `terrain_class`/`forest_density`/`mask_r`/`mask_g` side arrays are inert on those inputs (`PORT APPROXIMATION` until a mask carrying those codes is cited). Water `-0.25`/shore `-0.1` (`texturemap.inc:29-31`, E12) and "relief props are 3D objects, not height bumps" (`pattern.lib:338482` etc., E15) stand unchanged. *(V26 C3)*

## 4. Dump contract (additive only)

Today: `map_w`, `map_h`, `height` (base64 f32-LE), `tileblock` (base64 u8)
(`world3d_terrain.gd:926-963`, `:1229-1243`, A01 E18). `relief_mask` already
coexists (E19). Rule: never retype/remove an existing key; new fields go under
one optional `fields` dictionary; old `build()` ignores it; new `build()` falls
back per key. Short arrays → zeros. `version` mismatch ignored. Atoms stay
byte-identical.

Zero-copy is only possible for the live sim→renderer handoff with typed arrays;
the base64 snapshot necessarily copies once (A01 §0.6). UV2 must still be
materialised as `PackedVector2Array` (PORT APPROX — donor has no such attribute).

## 5. Outstanding cross-checks (D/F wave)

- **D04 (LANDED):** save `sub_739d3c`, load `sub_73a0b8`; height/tile I/O
  `FUN_008305a0`/`FUN_008302b0`. Layout: `u32 W,H,u8 sub=4,u32` → `(2W)²` u32
  grid → 41 B gap → heights → `W×W` **37-byte records (24+13 split)**. Tile ids
  at `+8..11`, four `1.0f` weights at `+16..31`, `FFFF` marker at `+5..6`;
  invariants hold for 102,400 / 147,456 records. Height count `(W+1)²−2` vs
  binary loop `(W+1)²` remains `[U]`. Field order/owner still not recovered.
- D02: seed key semantics feeding the RNG ledger (spec §02).
- F04/F03: mask channels — F04 measured R/G=0 except starts, B=−1.1·B/255;
  A02's R=terrain-class semantics remain `[U]` for vanilla `_gauss` masks.

---
*Integrated by COORD from A01.*
