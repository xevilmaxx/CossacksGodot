# FIELD-ART — read-only art-gap probe: FIX-FIELD-DONOR SKIP (15 sids)

Date: 2026-11-26
Worker: FIELD-ART (read-only probe; no code, no Godot, no git, no donor execution)
Scope: exactly one file written (this report). No parity claim. Parity UNVERIFIED. Chain 0/6. **RESULT IS NOT GOOD.**

Owner symptom: run log shows
`world3d_entities: FIX-FIELD-DONOR SKIP missing converted crop art for fieldw, field1, field1w, field2, field2w, field3, field3w, field4, field4w, field5, field5w, field6, field6w, field7, field7w; existing field1 art is an explicitly labelled fallback, never synthesized gold art`
at `variant3d/scripts/world3d_entities.gd:894`.

## 1. Where the skip is emitted and what paths are expected

- Preflight: `world3d_entities.gd:880-894`. `bind()` builds 16 material names (`field`, `field1..7`, each + `w` twin), calls `_field_texture_path()` per name (`:889`), collects failures into `field_skipped`, and emits the single `push_warning` at `:894`.
- Loader: `_field_texture_path()` (`world3d_entities.gd:1187-1211`). Per name: `candidate = AssetPaths.existing(material_name, "tex")`; if `candidate != ""` **and** `ResourceLoader.exists(candidate)` → `DONOR_CONVERTED`. Else the only fallback is the converted `field1.png` (explicitly labelled PORT APPROXIMATION, never mature `field.png`, never invented gold art); if even that fails `ResourceLoader.exists`, status is `SKIP <name>: converted donor texture absent; no crop texture fallback` with empty path.
- Expected paths (via `asset_paths.gd:70-93` `res_for`/`existing`, mapped bucket first, legacy flat fallback):
  - `field` → `res://assets/models/tex/shared/terrain/field.png` (from `manifest.json` `models[]` sid `field`, `:2581-2604`; donor texture recorded as `data/materials/env/field.dds`).
  - The other 15 (`field1..7`, `fieldw`, `field1w..7w`) → `res://assets/models/tex/shared/terrain/<name>.png` (from `manifest.json` `extra_assets`, `:8620-8667`; `field2`/`field3` entries additionally map `obj`).
  - Legacy fallback `res://assets/models/tex/<name>.png` does not exist on disk for any field name (no flat `tex/field*.png` files observed) — the bucket path is the only live candidate.

## 2. Donor-derived law governing field1..7/fieldw art

Governing law is DEC-VIS-03 (`DEC_VIS_03_fields.md` §§3-6), which explicitly refutes the older F07/X22 readings:

- Growth: `nothing.inc:38-57` — 87.5 s (`4 × 21.875`), `stage = floor(progress*4)` → `visual_stage_0..3` → materials `field1..4` (+`w` winter twins); maturity → `field`/`fieldw` (`ontagstates.inc:107-123,126-139`). F07 §4.1/X22 §6/§8 "no time-based stages" is refuted (DEC-VIS-03 §9.2).
- Harvest bands (`nothing.inc:59-90`, HP/25000): `hp ≥ 13000` → `field`; `5000 ≤ hp < 13000` → `field5`; `hp < 5000` → `field6`.
- Depletion/regrowth (`nothing.inc:29-34,63-69`, `ontagstates.inc:82-105`): first depletion → `field7`, 21.875 s rest, one regrowth through `field1..4`→`field`; second depletion → destroy after `gc_unit_deathtime_3 = 4` s. F07 "field5/6/7 unreferenced / deliberately out of scope" is refuted (DEC-VIS-03 §§3.3-3.4, 9.2).
- Material state (all crop mats inherit `refbase.mat`): `bmAlphaTest50` (= GL_BLEND off, `glAlphaFunc(GL_GREATER, 0.5)`), `fcNoCull`, wrap both, linear/linear-mipmap; `env.mat` Emission warm `(232,218,195)/255` for `field`/`fieldw`, neutral `200/255` for `field1..7` + winter twins; Ambient = Diffuse = 0; no emission-energy scalar exists (port `0.22`/albedo-multiplier energies are PORT APPROXIMATION).
- Second layer: ground decal `envfieldd`/`envfielddw`, angle 45/225, size ×1.3, UV scale 1.3 / offset −0.15, epsilon 0.01.
- Meshes: `field.prop` — 3 usable meshes (`field1/2/3.osm`), `RandomMeshName = True`, `RandomMaterialName = False`, `UseSeasonMaterial = True`, scale `0.03605085`, roll 45°.

## 3. On-disk state under variant3d/assets (files present vs import-absent)

All 16 crop PNGs exist **as files** (FIX-FIELD-ASSETS conversion, 2026-11-26):

- `variant3d/assets/models/tex/shared/terrain/field.png`, `field1.png` … `field7.png`, `fieldw.png`, `field1w.png` … `field7w.png` — 16/16 present. Per `field_conversion.manifest.json`, each is a direct 512×256 RGBA decode→re-encode of the same-named donor `data/materials/env/<name>.dds` (DXT5, 10 mips) with `pixels_equal: true`, `alpha_equal: true`, full source/output SHA-256 recorded; no retouch, no synthesis.
- Meshes as files: `obj/shared/terrain/field.obj` (donor `field1.osm`, unchanged), `field2.obj`, `field3.obj` (+ `.mtl`) — present.

What is **truly absent** — Godot import sidecars, i.e. runtime visibility:

- `tex/shared/terrain/*.import` contains `field.png.import` but **no** `.import` for any of `field1..7.png` / `fieldw..7w.png` (15 missing).
- `obj/shared/terrain/` contains `field.obj.import` but **no** `.import` for `field2.obj` / `field3.obj`.
- The conversion manifest states this itself (`field_conversion.manifest.json` limitations): "Only field.png has an existing .import sidecar. The 15 new PNGs and two new OBJs have no .import sidecars yet and require a normal Godot import before ResourceLoader.exists/load can be relied on." PNGs also carry base level only (donor DDS mip chains not preserved); `FIELD_TEXTURE_IMPORT_STATUS` records the import block (mipmaps off) as asset-import-owner work.

Consequence: at runtime `ResourceLoader.exists("res://assets/models/tex/shared/terrain/<name>.png")` is false for exactly the 15 un-imported names, so `_field_texture_path()` marks all 15 `skipped: true` and `bind()` emits the 15-sid SKIP warning. `field` (mature) resolves because its `.import` exists. Nothing on this list is missing donor bytes — the gap is import/registration, not conversion.

## 4. Byte-proven convertible donor asset remaining: none

- Every donor source named by the stage law (`field.dds`, `field1..7.dds`, `fieldw.dds`, `field1w..7w.dds`, `field2.osm`, `field3.osm`) is already converted with recorded pixel/topology equality (`field_conversion.manifest.json` textures/meshes tables + `manifest_resolution` 18/18 `exists: true` as files).
- No further donor read/conversion can close this gap without inventing art, which is forbidden (code and manifest both prohibit synthesized gold art; `visual_parity_claim: false`).
- Mesh-variant wiring (`RandomMeshName` across field1/2/3; port renders field1 mesh for all stages) and decal rendering remain separate labelled work, out of scope for this probe.

## 5. Exact zero-mismatch / owner condition

RESULT IS NOT GOOD until ALL of the following hold (verified by re-run + capture, no parity claimed until then):

1. Asset-import owner runs a normal Godot import covering the 15 PNGs (`field1..7`, `fieldw`, `field1w..7w`) — and `field2/3.obj` if mesh-variant wiring lands — producing `.import` sidecars with the requested `miLinearMipmapLinear` chain (currently BLOCKED per `FIELD_TEXTURE_IMPORT_STATUS`).
2. Re-run shows `field_skipped` empty: no `FIX-FIELD-DONOR SKIP` warning, and `_field_asset_status` reports `DONOR_CONVERTED` with `skipped: false` for all 16 names (`field` + 15).
3. A same-camera capture confirms each growth/harvest/depletion state and the winter suffix binds its own art (no stage silently rendering `field1` fallback), recorded per-state, not as a single aggregate screenshot.

Until then: all 15 sids render under the explicitly labelled `field1` fallback (or no crop texture where even the fallback is unresolvable at runtime); stage/winter visuals are PORT APPROXIMATION; no donor gold art has been or may be fabricated. Parity UNVERIFIED. Chain 0/6.
