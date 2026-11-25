---
id: FIELD-WINTER-01
task: "Standalone winter field-decal module — authoring only, no integration"
date: 2026-11-25
status: AUTHORING_ONLY__NEW_FILES_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_PASS_CLAIM
owner: FIELD-WINTER-01 (authoring worker)
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owns:
  - "variant3d/scripts/winter_field_decal.gd"
  - "docs/coord_swarm_2026-11-25/reports/FIELD_WINTER_01.md"
reads:
  - "docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md"
  - "docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md"
  - "docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md"
  - "docs/audit/PIECES/field_crops.md"
  - "variant3d/scripts/world3d_entities.gd (READ-ONLY; BUILD-STAGES-01 owns it)"
  - "variant3d/scripts/data.gd (READ-ONLY)"
labels: [observed, derived, inferred, UNVERIFIED, INERT_DATA, PORT_APPROXIMATION, DISABLED_INTENT]
visual_parity_claim: false
donor_access: "none this task — donor facts are prior-read citations from DSEASON-01 / DEC-05 / field_crops.md"
---

# FIELD-WINTER-01 — standalone winter field-decal module

## 0. Scope guard

Exactly **two new files** were written: the helper `variant3d/scripts/winter_field_decal.gd`
and this report. No existing source, shader, asset, config, manifest, test, fixture,
gate file or git state was edited. No code integration was performed and no runner
job was requested. No Godot process was launched, no donor file was read, executed,
unpacked or copied this task, and **no PASS / no donor visual-parity claim** is made.
Windows `python` (3.14) was used for read-only Pillow probes, never `python3`.

The port files `world3d_entities.gd` (BUILD-STAGES-01-owned) and `data.gd` were
**read only**; the explicit integration ticket in §5 is handed to their owner.

---

## 1. Sources read (all read-only)

| # | Source | What was taken from it |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md` | §2.3 `:109-118` summer/winter decal pair, season binding, opaque means; §4 rank 4 `:175` "recorded, not drawn"; §3 activity labels; §6 Q8 gold tint; §7 summary `:226-227` |
| S2 | `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` | decal/primitive handling is **UI-only**: minimap 34 primitives from `primitives.bmp` (`:5.2`, `minimap.cfg:28-723,:724-759`) and brush materials (`:6.1`, `selection.cfg:2-14`). No field-decal consumer appears in DEC-08; its nearest-filtered atlas approach is not a terrain decal path |
| S3 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | §4.2 DDS header facts (`DDS ` / DXT5 / 512² class), §3.3 DDS census, §8 Q3 `;`-prefixed `.inc` activity UNVERIFIED; no terrain normal/height DDS |
| S4 | `docs/audit/PIECES/field_crops.md` | §1.1 donor alpha bbox `(17,19,494,494)`, opaque means `#4D442E` / `#756F61`, §1.2 registration in `decals.mat`, §1.3 port PNG note (corrected in §3), §2 port gap, §5 claim table |
| S5 | `variant3d/scripts/world3d_entities.gd` | `:244-245` path constants, `:246` "donor decal 3D UV mapping UNVERIFIED", `:265-266` mirrors, `:328-333` stats-only recording |
| S6 | `variant3d/scripts/data.gd` | `:217-241` SEASON_ENUM (summer 0 / winter 2 / desert 3), season 1 UNVERIFIED, legacy `TERRAIN_TINT` is explicitly **not** the donor mechanism |

---

## 2. Donor citations

All donor facts below are **prior-observed** (read by S1/S3/S4), re-cited here
verbatim; the donor was **not accessed** in this task and no donor bytes were copied.

| Claim | Citation | Label |
|---|---|---|
| Explicit season binding: `Decal.SummerLibMaterialName = envfieldd`, `Decal.WinterLibMaterialName = envfielddw` | `C:\Games\Cossacks 3\data\terrain\decals\decals.lib:37-44` (S1 `:114`, `:146`) | OBSERVED (prior) / **INERT_DATA** — native consumer engine-side |
| Registration `Material.Name = envfieldd → .\data\terrain\decals\env\envfieldd.dds` (and `envfielddw`) | `decals.mat:110-115` (S1 `:115`, corrects S4's byte-offset-only citation) | OBSERVED (prior) |
| Both decals DXT5, 512×512, **identical alpha footprint** bbox `(17,19,494,494)`; opaque means summer `#4D442E` (77.2,68.4,46.1), winter `#756F61` (116.7,111.1,97.1) | `terrain\decals\env\envfieldd.dds` / `envfielddw.dds`; S1 `:113`, S4 `:31-41` | OBSERVED / DERIVED (prior) |
| Single spring point `const decalname = 'envfieldd'` → `AddNewDecalByLibName`; winter resolves through the **decal library**, not a second script branch | `scripts\lib\misc.script:4284-4295`, `miscext2.script:772` (S1 `:116`) | OBSERVED (prior) |
| `//DefaultDecalName = envfieldd` in the field prop is disabled | `objects\env\field.prop:152-157` (S1 `:117`, `:150`) | **DISABLED_INTENT** — not a second binding |
| DDS format (magic, FourCC @`0x54`, no terrain normal/height DDS), format facts independent of script activity | DEC-05 §4.2 / §3.3 / §8 Q3 | OBSERVED (prior) |
| Port records paths but never draws them; 3D UV mapping UNVERIFIED | `world3d_entities.gd:244-245,328-333,430`; S1 `:175` (rank 4) | OBSERVED (port) |
| `;`-prefixed `.inc` season lines are live source encoding, but **native EXE execution UNVERIFIED** | S1 §3 C1, S1 `:152-155`; DEC-05 §8 Q3 | INFERRED source intent / **UNVERIFIED** runtime |

**Activity label carried forward:** the decal binding is real config bytes
(`INERT_DATA`) and the prop-side decal call is unprefixed `.script` text, but
whether the shipped EXE resolves `envfielddw` at runtime is **UNVERIFIED**. This
module encodes *donor-authored intent*, never a "donor runs this" claim.

---

## 3. Asset inventory (read-only, this task)

### 3.1 `decals_png/` — no field decals

`variant3d/assets/terrain/decals_png/` holds **924 entries = 462 `.png` + 462
`.import`** (e.g. `ausacad.png` / `ausacadw.png`, `ven...`, `ukr...`, `tur...`).
A case-insensitive name scan found **zero** files containing `field`: this
directory is nation/building decal art and is **not** the field-crop source.

### 3.2 Field-crop pair — `deco_png/`

| Path | Bytes | SHA-256 (first 16) | Pixels (read-only Pillow) |
|---|---:|---|---|
| `variant3d/assets/terrain/deco_png/envfieldd.png` | 615,507 | `3f944af89656fbb6` | 512×512 RGBA |
| `variant3d/assets/terrain/deco_png/envfielddw.png` | 659,209 | `dd41540a1bf350be` | 512×512 RGBA |
| `app/assets/terrain/deco_png/envfieldd.png` | 615,507 | `3f944af89656fbb6` | byte-identical to variant3d copy |
| `app/assets/terrain/deco_png/envfielddw.png` | 659,209 | `dd41540a1bf350be` | byte-identical to variant3d copy |
| `app/shots/deco/envfieldd.png` | 133,748 | `d8de9f1e4d66fb66` | shot/preview only, not an asset path |

Both field PNGs preserve the donor alpha footprint exactly (read-only Pillow
this task): alpha min/max `0/255`, mean `148.1`; `a>8` bbox `(17,19,494,494)`;
`a>250` bbox `(22,33,487,480)`; 30.7% fully opaque; opaque means
`(77.2,68.4,46.1)` and `(116.7,111.1,97.1)`. Both `.import` files resolve
`res://assets/terrain/deco_png/envfield*.png` and declare a `.ctex` in
`res://.godot/imported/` with `process/fix_alpha_border=true`.

**Correction to S4 §1.3 (stale):** `field_crops.md:66-72` describes these PNGs as
"alpha is 255 at every pixel / flattened away in conversion". The current
on-disk bytes in **both** `variant3d/` and `app/` have the donor alpha profile
above, not full opacity. The flattening diagnosis may describe an older
conversion; it is **not** what is on disk now. Whether the *imported texture*
preserves that alpha at render time is still UNVERIFIED (no Godot run).

**PORT APPROX:** no texture was generated, edited, copied or fabricated. The
helper uses only the two existing paths already hardcoded at
`world3d_entities.gd:244-245`.

---

## 4. API — `variant3d/scripts/winter_field_decal.gd`

`extends RefCounted`, no `class_name` (callers use `preload("res://scripts/winter_field_decal.gd")`,
matching the SP-08 "no class_name reliance" convention). All functions are
`static` and side-effect free: no load, no scene access, no runner hook.

| Member | Result | Basis / label |
|---|---|---|
| `winter_decal_path() -> String` | `res://assets/terrain/deco_png/envfielddw.png` | exact constant from `world3d_entities.gd:245`; existence probe stays at caller (`:331-332`) |
| `decal_path(season: int) -> String` | winter path for `season == 2`; summer path otherwise | donor binding `decals.lib:37-44`; non-winter fallback is PORT APPROX |
| `decal_color(season: int) -> Color` | `#4D442E` for summer / `#756F61` for winter; summer fallback for season 1 and 3 | DERIVED from donor opaque means (§2); render-time gold is **not** encoded |
| `should_draw(season: int) -> bool` | `true` for `0` and `2`; `false` for `1`, `3`, any other | only two seasons have a donor binding; season 1 UNVERIFIED, desert unbound |
| `SEASON_SUMMER/WINTER/DESERT`, `DONOR_*`, `*_DECAL_PATH`, `PORT_LABEL`, `STATUS` | data/label constants | mirror `data.gd:227` values; no BIOME re-declaration |

**Explicit PORT APPROX labels in the file:** `STATUS` states "donor binding is
INERT_DATA; native EXE activity UNVERIFIED; no donor GPU A/B; 3D UV mapping
UNVERIFIED". `decal_color` comments state the gold colour is a render-time
tint, not decal bytes; `decal_path`/`should_draw` state the non-winter fallback
and the desert gate are port decisions, not donor truth.

**Syntax validation method:** read-only inspection of the authored file against
the surrounding GDScript style (`tile_atlas_loader.gd:59-75`, `world3d_entities.gd:180-246`):
`extends RefCounted` before constants, typed constants, `static func` bodies,
`Color`/`String`/`bool` return types, literal-only colour arithmetic, no
forward references, no undeclared identifiers. **No Godot parse/run was
performed** — syntax is inspected, not machine-verified.

---

## 5. Integration ticket (hand-off, NOT executed)

### 5.1 File that must call it

**`variant3d/scripts/winter_field_decal.gd` is complete and standalone. The
caller must be `variant3d/scripts/world3d_entities.gd` — owned by
BUILD-STAGES-01, therefore untouched by this worker.** Requested change for
that owner:

1. `const WinterFieldDecal = preload("res://scripts/winter_field_decal.gd")`.
2. At `bind()` near `:328-333`, keep the `ResourceLoader.exists()` guard but
   source the winter path from `WinterFieldDecal.winter_decal_path()` and assert
   it equals the existing `FIELD_DECAL_WINTER` (`:245`) — drift is a FAIL, not a
   silent fallback.
3. At the field presentation site (`:430` and the `_field_visual` consumer,
   `:265`), read the season from the already-owned selector (`C3Data.BIOME` /
   `Data.SEASON_ENUM`, `data.gd:227`; config default `config.gd:127,546`). Gate
   with `should_draw(season)`, choose the asset with `decal_path(season)`, and
   apply `decal_color(season)` as a **PORT APPROX tint** over the existing donor
   field albedo — **do not** invent a decal-to-mesh UV mapping (`:246` says
   UNVERIFIED) and do not replace the mesh texture.
4. Record the chosen path, tint and `WinterFieldDecal.STATUS` in `stats` so a
   test can distinguish "path recorded" from "path drawn" (S1 rank 4).

No edit to `data.gd`, `t_season_overlay.gd`, any asset or any runner is part of
this ticket.

### 5.2 Assertion a 64² season test would need

The existing 64² three-variant atom is `variant3d/tests/t_season_overlay.gd`
(SP-08, `SP_08_season_test.md`, authoring-only, never run). **Adding a
field-decal check there is a separate TEST-owner ticket and was not done.**
When that owner integrates, required assertions for the same 64² fixture with
a deterministic food/resource node and variants summer (0) / winter (2) /
desert (3) are:

| # | Assertion | Fails today because |
|---|---|---|
| A1 | `should_draw(0) == true`, `should_draw(2) == true`, `should_draw(3) == false` (and `should_draw(1) == false` if probed) | no helper call exists |
| A2 | `winter_decal_path() == FIELD_DECAL_WINTER` and `ResourceLoader.exists(path) == true` | paths are only recorded in stats |
| A3 | `decal_path(2) != decal_path(0)` and equals the winter path; both paths resolve | no season→asset decision exists |
| A4 | `decal_color(0)` equals `#4D442E` (±1/255 per channel), `decal_color(2)` equals `#756F61` (±1/255), and they differ | no season→tint decision exists |
| A5 | **integration**: `stats` reports the chosen path *and* the renderer consumed it (draw call / bound texture), not merely `_field_decal_paths` | S1 `:175` rank 4 — stats-only recording |
| A6 | alpha footprint: PNG `a>8` bbox is `(17,19,494,494)`, so no full-tile olive square is drawn | current draw path uses per-instance tint; alpha behaviour at render time UNVERIFIED |
| A7 | season value comes from `Data.SEASON_ENUM` / `C3Data.BIOME`; no re-declared enum, no new texture file | helper mirrors but does not own the enum |

Keep SP-08's verdict rules unchanged: `SKIP_CAPTURE` in headless, `PENDING_DEP`
for missing deps, external stderr scan left pending, **never a fake PASS**. A
64² assertion proves the helper's decisions and the wiring, **not donor visual
parity**.

### 5.3 Explicitly UNVERIFIED (do not promote to PASS)

- **Donor GPU A/B:** no matched-camera donor frame and no port capture were
  produced; no visual comparison was run. This module encodes data only.
- **Runtime `;` script activity:** per S1 C1 and DEC-05 §8 Q3, `[*] = ;` lines
  are live *source* encoding, but native EXE execution is UNVERIFIED. The
  `decals.lib` binding is `INERT_DATA` (engine-side consumer unproven).
- **Donor 3D UV mapping** of the decal onto field-crop meshes (`world3d_entities.gd:246`,
  S4 §5 criterion 6): UNVERIFIED; no UV was invented here.
- **Render-time gold tint** in winter (`field_crops.md:44-47`, S1 §6 Q8): the
  helper returns the grey decal mean; whether gold survives is UNVERIFIED.
- **Desert field-decal binding:** none found; the summer fallback is a PORT
  APPROX decision, not donor truth.
- **Imported-texture alpha:** `.import` sets `process/fix_alpha_border=true` and
  a `.ctex` target; whether alpha survives import/draw is untested (no run).
- **No Godot validation:** the helper's syntax was inspected by reading, not
  parsed by Godot; every assertion in §5.2 is proposed, not executed.

---

## 6. Open questions

1. Should `should_draw(3)` stay `false` (no donor binding) or should the owner
   choose a summer fallback for desert? Currently `decal_path`/`decal_color`
   fall back but `should_draw` gates off — owner decision needed.
2. Is the intended port presentation a tinted overlay over the existing field
   albedo, or real decal geometry? The latter needs a UV mapping the donor does
   not expose in readable data.
3. Should the 64² assertion check disk PNG alpha (A6) or only `stats`? A6 is
   stronger but needs the renderer to preserve alpha end-to-end.
4. Who corrects the stale flattening claim in `field_crops.md §1.3` (§3 above)?
   Out of scope here; that file was read only.
5. Season value 1 remains UNVERIFIED (`data.gd:224-226`); the helper returns the
   summer fallback for it. Acceptable, or should it be `false`/`null`?
6. Does the donor engine actually resolve `envfielddw` from `decals.lib` at
   scene load, or is the binding vestigial? Needs runtime evidence, not code.

---

## 7. Summary

Two new files authored: `variant3d/scripts/winter_field_decal.gd` (a small,
side-effect-free `RefCounted` helper with `winter_decal_path()`, `decal_path()`,
`decal_color()` and `should_draw()`, all donor-cited and PORT APPROX-labelled)
and this report. The donor winter field decal `envfielddw` (`decals.lib:37-44`,
`#756F61`) and its summer pair `envfieldd` (`#4D442E`) exist on disk in
`deco_png/` with the donor alpha footprint intact; `decals_png/` contains no
field decals. The port currently records the paths in stats only
(`world3d_entities.gd:328-333`) and draws neither — wiring is explicitly left
to BUILD-STAGES-01, the owner of that file, via the §5 ticket.

**No existing file was edited. No code was integrated, no runner job was
requested, no Godot run occurred, no donor file was copied or executed, and
no PASS or donor visual-parity claim is made.**

*End of FIELD-WINTER-01.*
