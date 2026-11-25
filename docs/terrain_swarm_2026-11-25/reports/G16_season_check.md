---
id: G16-SEASON-CHECK
title: "G16 — season atlas/manifest consistency after B02's mipmap + .import change"
ticket: G16 (TERRAIN-SWARM-WAVE-G)
owner: G16 read-only consistency subagent
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDITS__NO_GODOT_JOBS__NO_RUNNER_JOBS
scope: "Read-only audit of B02's landed diff across every atlas transport and season path. Exactly one file written: this report. No code, config, test, asset, import file or manifest was edited. No Godot process, runner job or reimport was invoked."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md
  - docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md
parity_guard: "No donor GPU A/B frame exists. No donor-parity claim is made; all conclusions are internal tree consistency only."
---

# G16 — season atlas / manifest consistency after B02

## 0. Verdict in brief

**OBSERVED.** B02's landed change is exactly the three hunks printed in `B02_atlas_impl.md §3`:
`mipmaps/generate=false → true` in the Summer and Winter atlas `.import` sidecars, one new
`_prepare_atlas_image()` helper, and its use in `_load_single()` and `_load_split()`.
No PNG byte, split part, manifest, alias/remap JSON, mask import or shader sampler hint was
touched by B02.

**DERIVED.** The change is *consistent across all audited surfaces*: both single atlases get
the same CPU mip chain, split reassembly gets the same chain, array mode is deliberately
untouched because its `Texture2DArray` is not a shader sampler, and both season manifests keep
the same 16×8 / 1024² / 124-entry index contract. Winter and desert index-preserving swaps are
**unaffected**: they flow through the same prepared path and neither selection table nor remap
data changed. No mask — `alpha.png` / `alphavert.png` in either `atlas/` or `atlas_parts/` —
acquired mipmaps.

**No regression attributable to B02 was found in the audited files.** Two out-of-scope,
pre-existing season-transport gaps are flagged in §7 with exact paths, explicitly labelled as
**not** introduced by B02. Visual consequences of adding mips (atlas bleed at coarse levels,
VRAM/CPU cost) remain **UNVERIFIED** — no Godot run was permitted by the ticket.

---

## 1. Method and evidence boundary (OBSERVED)

All facts below come from direct file reads plus read-only git/PowerShell inspection of the
current working tree at `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`:

| Technique | What it proved |
|---|---|
| `git status --short -- <atlas + loader + shader + renderer paths>` | Only 5 relevant files are modified in the whole tree; only 3 belong to B02 |
| `git diff -- <3 B02 files>` | Exact hunk-by-hunk equality with `B02_atlas_impl.md §3`; no extra edits |
| `git cat-file -s HEAD:<import>` vs on-disk length | Each `.import` shrank by exactly 1 byte — the `false`→`true` character delta |
| `git hash-object <file>` vs `git rev-parse HEAD:<file>` | Every PNG, split part and manifest is byte-identical to HEAD |
| `Get-FileHash -Algorithm SHA256` + `Get-Item.Length` | Absolute hashes/sizes for §6; cross-checked against `split_manifest.json` and `SP_04_winter_atlas.md` |
| Full-tree `Select-String 'mipmaps/generate=true'` over all `.import` files | Exactly two hits — the Summer and Winter atlas sidecars |
| Direct reads of both manifests, `winter_aliases.json`, `desert_remap.json`, shader, renderer, loader | Index contract, sampler hints, season selection and mask paths |

**No Godot process was started, no runner job was submitted, no file was reimported, no donor
file was opened.** Anything requiring a GPU frame is labelled UNVERIFIED in §8.

---

## 2. The landed B02 diff is exactly what the report claims (OBSERVED)

`git status --short` over the audited paths reports:

```
 M variant3d/assets/terrain/atlas/tile_index_atlas.png.import
 M variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import
 M variant3d/scripts/tile_atlas_loader.gd
 M variant3d/scripts/world3d_terrain.gd          <- B04 relief promotion, not B02
 M variant3d/shaders/terrain_tileindex.gdshader  <- B01 filter hint + A06 shader work, not B02
```

`git diff` of B02's three owned files reproduces `B02_atlas_impl.md §3` verbatim:

| File | Hunks | Detail |
|---|---|---|
| `variant3d/assets/terrain/atlas/tile_index_atlas.png.import` | 1 | `:26` `mipmaps/generate=false` → `true` only |
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import` | 1 | `:26` `mipmaps/generate=false` → `true` only |
| `variant3d/scripts/tile_atlas_loader.gd` | 3 | `_load_single` create_from_image wrap; new `_prepare_atlas_image()` at `:350-356`; `_load_split` create_from_image wrap |

Size deltas confirm the import edits are single-character:
`tile_index_atlas.png.import` 972 B (HEAD) → 971 B (WT);
`tile_index_atlas_winter.png.import` 993 B (HEAD) → 992 B (WT).
`mipmaps/limit=-1` is unchanged and **no `flags/*` key was added** to either file (checked on all
six atlas/mask sidecars — `flags` count = 0).

Backup integrity: `inbox/backup/tile_atlas_loader.gd.bak-B02` (SHA-256
`9B82A48D…C5F23978`, 17,986 B) has git blob hash `c15d0a7a…`, **identical to
`git rev-parse HEAD:variant3d/scripts/tile_atlas_loader.gd`** — the backup is the true pre-edit
file, and the working loader contains no edits beyond the reported three hunks.

---

## 3. Per-variant consistency matrix (OBSERVED + DERIVED)

| Surface | Exact path | B02 effect | Consistent? |
|---|---|---|---|
| Summer single PNG | `variant3d/assets/terrain/atlas/tile_index_atlas.png` | none — git blob == HEAD; 179,912,941 B | YES |
| Summer single import | `variant3d/assets/terrain/atlas/tile_index_atlas.png.import` | `mipmaps/generate=true`; only line 26 changed | YES |
| Winter single PNG | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` | none — git blob == HEAD; 124,463,306 B | YES |
| Winter single import | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import` | `mipmaps/generate=true`; only line 26 changed | YES |
| Split parts | `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000`, `.part001` | none — git blobs == HEAD; per-part SHA-256/size match `split_manifest.json:22-37` | YES |
| Split manifest | `variant3d/assets/terrain/atlas_parts/split_manifest.json` | untouched; still points to Summer source (`:13-18`) and verifies `matches: true` (`:64-70`) | YES |
| Split runtime | `variant3d/scripts/tile_atlas_loader.gd:359-421` `_load_split()` | `:416` wraps `create_from_image` with `_prepare_atlas_image(img)` | YES |
| Single runtime | `variant3d/scripts/tile_atlas_loader.gd:280-290` `_load_single()` | `:285` wraps `create_from_image` with `_prepare_atlas_image(img)` | YES |
| Helper | `variant3d/scripts/tile_atlas_loader.gd:350-356` `_prepare_atlas_image()` | `has_mipmaps()` short-circuit; `generate_mipmaps(false)`; warn-only on error | YES |
| Array mode | `variant3d/scripts/tile_atlas_loader.gd:427-479` `_load_array()` | **untouched** — no mips added to `Texture2DArray` | YES (see note) |
| Summer manifest | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | untouched; git-clean; `grid [16,8]`, cell 1024², 124 named / 121 filled | YES |
| Winter manifest | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json` | untouched; git-clean; same `grid [16,8]`, cell 1024², 124 entries, index 0 = grass1 (`:42-55`) | YES |
| Winter dictionary | `variant3d/assets/terrain/atlas/winter_aliases.json` | untouched; `index_preserving: true` (`:30-31`) | YES |
| Desert remap | `variant3d/assets/terrain/atlas/desert_remap.json` | untouched | YES |
| Mask runtime | `variant3d/scripts/tile_atlas_loader.gd:482-494` `_load_masks()` | **no** `_prepare_atlas_image()`; plain `create_from_image(img)` | YES |

**Array-mode note (DERIVED).** `_load_array()` intentionally does not call `_prepare_atlas_image()`.
This is not an inconsistency: repo-wide grep finds no consumer of `get_tile_array()` /
`tile_layer()` in a shader or render path (`variant3d/scripts/world3d_terrain.gd` only mentions
array mode in comments/`stats`). The shader's `tile_atlas` sampler2D is always fed by a
`_load_single()`/`_load_split()` texture — including `world3d_terrain.gd:682-687`, which builds a
split-mode fallback loader when the selected transport yields no 2D texture. That fallback does
receive B02's mips. Array block PNG imports (`variant3d/assets/terrain/blocks/winterN.png.import`
etc.) all remain `mipmaps/generate=false`.

---

## 4. No mask acquired mipmaps (OBSERVED)

Six atlas/mask `.import` sidecars were read in full; global grep over every `.import` in the
repository found only two `mipmaps/generate=true` lines, both atlas colour maps:

| Sidecar | `mipmaps/generate` | Expected |
|---|---|---|
| `variant3d/assets/terrain/atlas/tile_index_atlas.png.import` | `true` | atlas colour — correct |
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import` | `true` | atlas colour — correct |
| `variant3d/assets/terrain/atlas/alpha.png.import` | `false` | mask — correct |
| `variant3d/assets/terrain/atlas/alphavert.png.import` | `false` | mask — correct |
| `variant3d/assets/terrain/atlas_parts/alpha.png.import` | `false` | mask copy — correct |
| `variant3d/assets/terrain/atlas_parts/alphavert.png.import` | `false` | mask copy — correct |

Reinforcing evidence:

- Shader `variant3d/shaders/terrain_tileindex.gdshader:60` `tile_atlas :
  filter_linear_mipmap, repeat_enable` (B01); `:66` `alpha_atlas : filter_nearest, repeat_enable`;
  `:72` `alphavert_atlas : filter_nearest, repeat_enable`. Mask samplers carry no mip hint.
- `tile_atlas_loader.gd:489-491` loads masks and calls `ImageTexture.create_from_image(img)`
  **without** B02's helper.
- `world3d_terrain.gd:694-707` `_repack_mask_alpha()` also calls `create_from_image(img)`
  directly; repacked masks stay base-level.

**Conclusion (DERIVED):** the "no mipmaps on masks" contract in `B02_atlas_impl.md §4/§6` holds in
the landed tree.

---

## 5. Winter / desert index-preserving swaps are unaffected (OBSERVED + DERIVED)

1. `variant3d/scripts/world3d_terrain.gd:311-318` `SEASON_ATLAS` is unchanged:
   summer → V785 manifest+PNG, winter → `tile_index_atlas_winter.manifest.json` +
   `tile_index_atlas_winter.png`, desert → **Summer pair** plus SP-3 name remap. No second atlas
   is accumulated.
2. `_load_atlas()` `:612-648` passes `manifest_path` and `single_atlas_path` as SP-5 overrides to
   the loader for winter; `:640-648` keeps the no-override constructor for summer/desert. B02 did
   not edit this file, and the overrides land in `_load_single()`'s `single_atlas_path` — the
   exact call site now wrapped by `_prepare_atlas_image()` (`:282-285`). DERIVED: whichever season
   PNG is selected receives the identical mip preparation; level-0 bytes are untouched, so
   tile-id→cell appearance and the index contract are unchanged.
3. Both manifests are git-clean and structurally aligned: same `grid [16,8]`, same
   `cell_size [1024,1024]`, 128 slots / 124 named / 121 filled / 3 empty, 124-entry index
   dictionaries, and index 0 = `grass1` in both. Winter's `index_dictionary` is
   `winter_aliases.json` (`:34-39`) with `index_preserving: true`; desert stays on the Summer
   manifest and consumes `desert_remap.json` before UV2.x.
4. `winter_aliases.json`, `desert_remap.json`, both manifests and both PNGs all have git blob
   hashes equal to HEAD. No season data file changed in this wave.

**Conclusion:** B02 alters no selection table, no remap, no index mapping and no manifest. The
season swap semantics documented in `A12_config_knobs.md §2.1 / §3` (season via legacy
`gameplay.season`/`biome`, index-preserving set swap) remain intact.

---

## 6. File sizes and hashes — unchanged except import flags (OBSERVED)

All values measured on the working tree; `HEAD match` means `git hash-object` == 
`git rev-parse HEAD:<path>`.

| File | Bytes | SHA-256 | HEAD match |
|---|---:|---|---|
| `.../atlas/tile_index_atlas.png` | 179,912,941 | `A1F123A1072E07EB28F416A9D8541AAE5FFD23891A1836904B3CB05EB84DCFBD` | YES |
| `.../atlas/tile_index_atlas_winter.png` | 124,463,306 | `5D0DD8F3042EC13D6989B357FFBC007DBD439237B8E7CFFFE7BB98F18E3CBADB` | YES |
| `.../atlas/alpha.png` | 55,242 | `DFAF78D0C285920CD2009F74476A8D4647F3666EFB7C6DCF0BFD1B44487B8EF7` | YES |
| `.../atlas/alphavert.png` | 167,954 | `C916EA98DDB7F8CCC9A4898F324540335D4D74EE5250F4774B9769C762AFD245` | YES |
| `.../atlas_parts/tile_index_atlas.part000` | 90,000,000 | `019F0F9D7EA1430131189881DB58E3F3FA138EB76209D643D53E698B73DD525F` | YES |
| `.../atlas_parts/tile_index_atlas.part001` | 89,912,941 | `295A527CE8C402D8C8C80775538A6A0C0E6859FA94A758194CC096DB0FABA1BE` | YES |
| `.../atlas_parts/alpha.png` | 55,242 | `DFAF78D0…B44487B8EF7` | YES |
| `.../atlas_parts/alphavert.png` | 167,954 | `C916EA98…C762AFD245` | YES |

Cross-checks: the Summer PNG hash/bytes equal `split_manifest.json:14-15`; both part
hash/size pairs equal `split_manifest.json:22-37`; the mask pairs equal `split_manifest.json:46-62`;
the Winter PNG hash/bytes equal the SP-4 inventory in
`docs/coord_swarm_2026-11-25/reports/SP_04_winter_atlas.md:105`.

Manifest/sidecar sizes (all git-clean unless noted):
`tile_index_atlas.manifest.json` 60,677 B; `tile_index_atlas_winter.manifest.json` 79,837 B;
`winter_aliases.json` 81,335 B; `desert_remap.json` 19,098 B; `split_manifest.json` 3,061 B;
`tile_index_atlas.png.import` 971 B (HEAD 972, **B02 change**);
`tile_index_atlas_winter.png.import` 992 B (HEAD 993, **B02 change**);
mask sidecars 940/952 B (`atlas/`) and 946/958 B (`atlas_parts/`), all unchanged.

---

## 7. Regressions flagged with exact paths

### 7a. Regression caused by B02 — NONE FOUND (OBSERVED/DERIVED)

Every file touched by B02 is accounted for in §2-§6, and each change is either the intended
`mipmaps/generate` flag or the intended mip helper wiring. No PNG, part, manifest, mask, alias,
remap, shader hint or season table was altered by B02. `tile_atlas_loader.gd`'s backup matches
HEAD exactly, so no hidden edit is present.

### 7b. Pre-existing season-transport gaps — flagged, NOT B02 regressions (OBSERVED)

These are recorded because the ticket asks for season consistency; both exist verbatim in HEAD
and B02 did not touch the relevant lines. B02's mip preparation applies uniformly to whichever
image these paths actually load.

1. **`variant3d/scripts/tile_atlas_loader.gd:359-365` `_load_split()`** always reads
   `SPLIT_MANIFEST` (the Summer byte parts) and never consults `single_atlas_path`, while
   `_load_grid()` at `:363` honours the season `manifest_path`. DERIVED consequence: a
   `season=winter` + `atlas_mode=split` run would reassemble **Summer** pixels while using the
   Winter grid. Pre-existing SP-5/SP-6 asymmetry; out of G16/B02 ownership. Flag for season QA.
2. **`variant3d/scripts/world3d_terrain.gd:682-687`** split fallback for the `tile_atlas`
   sampler2D constructs `loader_script.new(ATLAS_MODE_SPLIT)` with **no** season overrides, so
   when the selected transport yields no 2D texture (array mode) the shader sampler receives the
   Summer atlas even in Winter. Pre-existing; B02 only adds mips to the texture that path produces.

### 7c. Non-regression risks requiring a GPU check — UNVERIFIED

- Coarse mip levels of a hand-indexed atlas can mix neighbouring cells; `fract()` at 2 m
  boundaries spikes UV derivatives. Possible thin seam bands — exactly the risk B02 §6 item 2
  already records. Not measurable without a runner, which G16 must not submit.
- `Image.generate_mipmaps(false)` on 16384×8192 is a one-time CPU cost and ~33 % extra VRAM
  (B02 §6 item 3, INFERRED). Failure is warn-only, so the worst case is a silent fall back to
  base-level-only sampling, not a crash.
- `.import` edits take effect only after a Godot editor reimport; none was run. At runtime the
  loader bypasses `.import` entirely (`Image.load()`), so this is inert for the current render
  path and cannot introduce a visual delta by itself.

---

## 8. UNVERIFIED / open questions

1. No Godot run was permitted, so the actual GPU mip chain, `textureGrad` behaviour at seams and
   `full_width_dark_rows == 0` / `dark_cols == 0` remain unmeasured. G04/G05 QA owns that evidence.
2. Whether `Image.generate_mipmaps()` succeeds for the decoded PNG format on this Godot build
   was not executed; the code degrades with a `push_warning` if it does not.
3. Seasonal *visual* art correctness (Winter aliases, Desert remap) was not re-captured; only
   file/index consistency was audited. Donor runtime season activity stays UNVERIFIED.
4. No donor GPU A/B exists — no donor-parity statement is made anywhere in this report.

---

## 9. Summary

- B02 diff = 2 one-line import flag flips + 1 helper + 2 call-site wraps; nothing else. ✔
- Summer and Winter single PNGs, their `.import` sidecars, split parts, split manifest, both
  manifests, both data dictionaries and the array mode are mutually consistent. ✔
- `_prepare_atlas_image()` is present in both `_load_single()` (`:285`) and `_load_split()`
  (`:416`); array mode intentionally excluded because its `Texture2DArray` is not a shader
  sampler. ✔
- Winter/desert index-preserving swaps unaffected; no season table, manifest or index data
  changed. ✔
- No alpha/alphavert mask got mipmaps — four mask sidecars stay `false`, mask samplers stay
  `filter_nearest`, and neither mask load path calls the helper. ✔
- All PNG/part sizes and hashes unchanged; the only byte deltas are the two `.import` files
  (−1 byte each, `false`→`true`). ✔
- **No B02 regression found.** Two pre-existing season-transport gaps are flagged in §7b with
  exact paths and explicitly excluded from B02 ownership; visual consequences remain UNVERIFIED
  pending G04/G05 captures.

*End of G16 report.*
