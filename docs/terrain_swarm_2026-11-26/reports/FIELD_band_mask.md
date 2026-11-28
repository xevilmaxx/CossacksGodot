# FIELD band-mask probe — eurmil/eurmar UNTINTED warnings

- worker: BAND-MASK (read-only probe; no code/Godot/git/donor-execution; no other edits)
- date: 2026-11-26; swarm: terrain_swarm_2026-11-26
- chain: 0/6. Parity: UNVERIFIED. No parity claim. RESULT IS NOT GOOD.
- scope: (1) exact band-mask lookup law `world3d_entities.gd:1880-1960`,
  (2) whether donor-derived masks for `eurmil`/`eurmar` exist anywhere in-repo,
  (3) byte-proven reason these two sids miss while others hit,
  (4) UNTINTED-as-safe vs fixable gap. No tint/mask/texture invented or declared.

## 1. Exact lookup law (`variant3d/scripts/world3d_entities.gd`)

Call chain (byte-verified line numbers in the live file):
`add_building:3140` → `_apply_tint:1950` (MeshInstance3D surface-override branch;
`2909` is the MultiMesh batch branch) → `_tinted_material:1894` →
`_band_mask_texture:1826` → `_band_mask:1804` → `_dxt5_mask:1736`.

Key/lookup rules, in order:

1. Store population — `bind():866-878`: `_donor_texture_paths[sid] =
   str(m.get("texture", ""))` for each `manifest.json:models[i]` with non-empty
   `sid`+`texture`. Keys are therefore **manifest `sid` strings verbatim**
   (port base sids: `mil`, `mar`, `hou`, `peaukr`, …). The comment at `:873-875`
   confirms `texture` is the DONOR DDS absolute path.
2. Query key — `_band_mask(sid:1804)`: `img := _dxt5_mask(str(
   _donor_texture_paths.get(sid, "")))` (`:1809`). The `sid` passed down from
   `add_building:3117-3122` is the **nation-resolved mesh sid**
   (`ns["sid"]`), not the sim base sid. Unknown key → `""`.
3. Decode — `_dxt5_mask(path:1736)`: `""` or `!FileAccess.file_exists` →
   `null` immediately (`:1737-1738`, no disk touch on `""`). Else: 128 B header
   (`DDS_HEADER_SIZE:137`); magic bytes `68,68,83,32` (`:1745`); height/width
   LE at `:12`/`:16` (`:1749-1750`); fourcc `68,88,84,53` (DXT5) at `:84`
   (`:1751`); first-mip 4×4 blocks, 16 B each (`DXT5_BLOCK_BYTES:138`), DXT5
   **alpha endpoints + 48-bit indices only, colour ignored** (`:1764-1795`,
   donor rationale `unit.smx9.id8.frag:37-38,42` cited `:1732`); RGBA8 image,
   alpha replicated to RGB (`:1792-1795`).
4. Threshold/count — texels with `alpha >= TINT_MASK_THRESHOLD (0.5, :139)`
   counted (`:1816-1818`); cached per sid with `ImageTexture` (`:1819`) plus
   `_band_mask_stats[sid]` = `{source, texels, mask_texels, verts,
   tinted_verts, faces, tinted_faces, label, visual}` (`:1820-1822`).
5. Tint — `_tinted_material(base,tint,sid,kind:1893)`: `mask == null` →
   `push_warning("…no donor band mask for "+sid+" — left UNTINTED, no
   whole-body fallback")` (`:1896`) and returns `base.duplicate()` (`:1897`);
   the old V7-65 whole-body `albedo_color` paint is deliberately never
   reinstated (`:1890-1892`). Else masked `ShaderMaterial`
   (`TINT_SHADER_CODE:136`, `mix(t.rgb, custColor.rgb*t.rgb, m*custColor.a)`,
   `m = mask_tex.a`), albedo from surface-0 material or
   `AssetPaths.existing(sid,"tex")` (`:1907-1912`), cache key includes base
   material instance id (`:1903-1904`).
6. Sampling — `_mask_at(:1834)`: clamped `uv*w/h`, `alpha >= 0.5`; measured
   per mesh by `_measure_band(:1845)`. Formats: mask strictly **donor DDS
   DXT5 first-mip alpha**; port PNGs are albedo-only (`force_opaque=True`
   conversion dropped donor alpha — FIXCOLOR §root cause; port `tex/*.png`
   are RGB).

## 2. Do donor-derived masks for eurmil/eurmar exist anywhere in-repo?

No — under those keys, nowhere. Byte-proven absences:

- `variant3d/assets/models/manifest.json`: `"sid": "eurmil"` / `"sid":
  "eurmar"` — zero hits (only `"sid": "mil"` `:2063`, `"sid": "mar"` `:2088`,
  plus stage stems `mil1-4/mar1-4`). Same in `app/assets/models/manifest.json`
  (`mil` `:328`, `mar` `:347`). Donor stems occur only in **value** fields.
- `variant3d/assets/models/obj/**/eurmil.obj`, `**/eurmar.obj`: absent
  (only `shared/buildings/eurmilanim.obj` sail + `mil.obj`/`mar.obj`).
  `variant3d/assets/models/buildings/models/eurmil.obj` EXISTS but
  `AssetPaths` never resolves that directory (manifest-mapped bucket or
  legacy `obj/<sid>.obj` only — `asset_paths.gd:59-93`); no `eurmar.obj`
  exists anywhere in-repo.
- No pre-baked band-mask image files exist for any sid (masks are
  runtime-decoded; `terrain*/masks/**` PNGs are unrelated terrain-pattern
  masks). No report or spec carries a converted eurmil/eurmar band mask.
- What DOES exist (byte-proven donor source, wrong key): manifest `mil`
  entry `texture: …commoneur/eurmil.dds` (`:2066`); `mar` entry `texture:
  …commoneur/eurmar.dds` (`:2091`); stage entries `mil1-4`/`mar1-4` repeat
  the same two DDS paths (`:6979/:7005/:7031/:7057`, `:7213…`). Donor map
  `mil→eurmil / mar→eurmar` is independently byte-proven in
  `convert_models.py:291-292,376-377`, `data.gd:3148-3153`
  (`DONOR_COLL_BUILDING_GEOMETRY`), and `BLD_DEATH_STEMS`
  (`world3d_entities.gd:375`).

## 3. Why these two miss while others hit (byte-proven)

- Working sids (e.g. `hou`, `peaukr`) hit because **query key == manifest
  key**: `hou` manifest entry (`:1888`, texture `ukrhou.dds` `:1891`) is
  queried as `hou` whenever nation resolution falls back to base; FIXCOLOR
  measured `hou` 74/2462 verts on `ukrhou.dds` and peaukr 37,147/262,144
  texels (`docs/coord_swarm_2026-11-24/reports/PROGRESS.md:310`,
  `FIXCOLOR_nation_bands.md:109-111`).
- `eurmil`/`eurmar` miss at the **dictionary-get step, before any file I/O**:
  `_donor_texture_paths` has keys `mil`/`mar`, never `eurmil`/`eurmar`
  (manifest `sid` namespace is port base sids; donor `eur*` stems live only
  in `mesh`/`texture` values), so `.get("eurmil","")` → `""` →
  `_dxt5_mask("")` → `null` at the `:1737` guard. The donor DDS file's
  presence on the owner machine is irrelevant to this failure.
- Trigger shape: the warning sid is the nation-resolved mesh sid
  (`add_building:3122 → :3140`), and the mesh/bbox/store lookups all miss
  identically for donor-stem sids (`_bbox` has no `eurmil` → proxy-mesh
  default `:1987-1988`; `AssetPaths.existing("eurmil","obj")` → legacy
  `obj/eurmil.obj`, absent on disk). The mill/market are simply the first
  nation-resolved buildings observed in the owner's pattern-stage run; any
  donor-stem sid (`rusmil`, `turmil`, stage stems like `cen2` per
  QA_BUILD_ART_C_01 Q5/BUILD_ART_C_01 Q5) misses the same way.
- Consequence derived from code+manifest (runtime-unconfirmed): these two
  instances render from `donor_bbox_proxy` geometry (`_mesh_info`
  `:2036-2086` source accounting) with duplicated untinted base material —
  labelled `donor_tint_label`/`visual UNVERIFIED` (`:1939-1940`).

## 4. UNTINTED: correct labelled-safe behaviour, AND a fixable gap

- Leaving UNTINTED is the correct **labelled-safe interim**: it avoids
  reinstating the V7-65 whole-body defect, warns explicitly, and keeps
  `PORT LABEL` + `visual UNVERIFIED` metas. No whole-body fallback must be
  added. (observed behaviour; endorsed as safe-hold, not as fix)
- It is a **fixable gap with byte-proven data, not a missing-donor case**:
  the exact donor texture bytes the mask would decode (`eurmil.dds` /
  `eurmar.dds`) are already named by the `mil`/`mar` manifest entries
  (same-file paths also on `mil1-4`/`mar1-4`). A base-sid fallback on mask
  lookup (donor-stem → port base, consistent with `BLD_DEATH_STEMS:375`
  `mil→eurmil / mar→eurmar`) would decode **byte-identical donor alpha** —
  no invented band, no invented colour; UV-space validity would then be
  quantified by the existing `_measure_band` stats. NOT implemented here
  (read-only probe; owner/COORD decision; needs its own ticket + runner
  proof). No parity claimed; visual effect UNVERIFIED either way.
- Open (not decidable read-only): which spawner handed `ed["sid"] =
  "eurmil"/"eurmar"` vs a nation-resolved `mil`/`mar` (sim spawns base sids
  — `game.gd:3928`, `BUILDINGS_BASE data.gd:2516-2518`; resolution path
  `_donor_building_prefix:1601` + `_nation_mesh_on_disk:1588`), and the
  owner's runtime `stats["donor_tint_mask_stats"]` / `mesh_sources_loaded`
  counters. Those need the run log + a Godot run, both out of scope.
