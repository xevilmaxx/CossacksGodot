---
id: V7-91
task: TERRAIN2-06 follow-up — dual-mode atlas transport (lossless split parts + Texture2DArray)
title: "Split parts + dual-mode runtime loader for the 180 MB donor tile atlas"
owner: V7-91 (exclusive: one new tool, atlas_parts/ assets, one new .gd, one report)
scope: "ASSET + TOOL + ONE NEW LOADER. No edit to the V7-85 build tool, the V7-86 shader, any other .gd, app/, config, tests or git. No git operations."
date: 2026-11-24
status: DELIVERED__MEASURED__BOTH_MODES_VERIFIED_28of28__NO_VISUAL_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
governing_rule: "docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-15; docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:3-4,6-16,26-37"
owned_outputs:
  - "variant3d/tools/pack_tile_atlas_split.py"
  - "variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000"
  - "variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001"
  - "variant3d/assets/terrain/atlas_parts/split_manifest.json"
  - "variant3d/assets/terrain/atlas_parts/alpha.png"
  - "variant3d/assets/terrain/atlas_parts/alphavert.png"
  - "variant3d/scripts/tile_atlas_loader.gd"
  - "docs/coord_swarm_2026-11-24/reports/V791_dual_mode_atlas.md"
labels: [DONOR_INDEX_VIA_V785_MANIFEST, LOSSLESS_BYTE_SPLIT, REASSEMBLY_SHA256_VERIFIED, APPROX_ATLAS_PACKING, APPROX_SAND_UPSCALE, NO_VISUAL_PARITY_CLAIM]
visual_parity_claim: false
---

# V7-91 — split parts + dual-mode atlas loader

## 0. Scope and reading order

Read first, as instructed: `reports/V785_tile_atlas.md` and
`reports/TERRAIN2_06_tileindex_architecture.md`.

Labels: **MEASURED** = produced by this atom's tool or a real probe; **OBS** =
literal donor / shipped-file evidence; **APPROX** = port substitution inherited
from V7-85; **UNVERIFIED** = not provable from readable data. No visual parity
is claimed; no GPU A/B was run. The single 180 MB PNG was **deleted after** the
clean dual-mode probe passed (see §5/§6).

## 1. Why ZIP was rejected — MEASURED zip-vs-split numbers

The dispatch's measured fact was independently reproduced by
`pack_tile_atlas_split.py --measure-zip` (temp archive discarded):

| Transport | Bytes | Ratio vs raw | Fits GitHub ~100 MB/file? |
|---|---:|---:|---|
| raw `tile_index_atlas.png` | 179,912,941 | 1.000 | NO |
| single ZIP, `ZIP_DEFLATED`, level 9 | **179,553,069** | **0.998** | **NO** |
| 2 split parts, max 90,000,000 B each | 90,000,000 + 89,912,941 | 1.000 (lossless) | **YES** |

PNG is already deflated; a single ZIP saves only 359,872 bytes (0.2%) and still
exceeds the per-file ceiling. Splitting is the change that actually makes the
commit possible. The parts are raw byte slices, so reassembly is exact, not a
re-encode.

## 2. Split manifest (MEASURED)

Source: `variant3d/assets/terrain/atlas/tile_index_atlas.png`, 179,912,941 bytes,
sha256 `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd`
(identical to V7-85 §2 — confirms atom-for-atom identity).

| Order | Part | Bytes | sha256 |
|---:|---|---:|---|
| 0 | `tile_index_atlas.part000` | 90,000,000 | `019f0f9d7ea1430131189881db58e3f3fa138eb76209d643d53e698b73dd525f` |
| 1 | `tile_index_atlas.part001` | 89,912,941 | `295a527ce8c402d8c8c80775538a6a0c0e6859fa94a758194cc096db0faba1be` |

Reassembly contract in `split_manifest.json`: concatenate in `reassembly.order`,
sha256 must equal `source.sha256`. Verified twice (build + `--check`) by writing
the concatenation to a temp file and hashing the real bytes:
`179,912,941` bytes and `a1f123…dcfbd`, `matches: true`. Both part files' own
sizes and hashes were re-verified on `--check`.

Masks were **not** split. They stay small separate files, copied into
`atlas_parts/` so the bundle is self-contained (the originals in `atlas/` are
untouched):

| Mask | Bytes | sha256 | Donor evidence |
|---|---:|---|---|
| `alpha.png` | 55,242 | `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7` | `reftilealpha.mat:30-37` (512×256, tfAlpha) |
| `alphavert.png` | 167,954 | `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245` | `reftilealpha.mat:139-146` (1024×512, tfAlpha) |

## 3. Runtime loader — stable API for V7-86

`variant3d/scripts/tile_atlas_loader.gd` (`extends RefCounted`,
`class_name TileAtlasLoader`). Mode is selected by ctor, config dictionary,
`ProjectSettings` key `terrain/tile_atlas_mode` (read-only), or explicit
`load(mode)`; default `"split"`.

| Method | Contract |
|---|---|
| `load(mode := "") -> bool` | Reassemble-or-decode (`split`) or build array (`array`). Alias `load_atlas()`. |
| `get_atlas_texture() -> Texture2D` | `split` only: one 16384×8192 RGBA `ImageTexture` sampler. `null` in `array`. |
| `get_tile_array() -> Texture2DArray` | `array` only: 121 layers, one per filled V7-85 cell. `null` in `split`. |
| `get_index_to_slot() / get_slot_to_index() -> Dictionary` | `array` only: donor preset index ↔ layer. |
| `tile_uv(index: int) -> Vector2` | `split`: cell bottom-left UV `(index%cols/cols, index/cols/rows)`, cols/rows from V7-85 manifest; shader adds local `fract(s,t)`. `array`: `Vector2.ZERO` (each layer is a whole tile). |
| `tile_layer(index: int) -> int` | `array`: layer slot or `-1`; `split`: `-1`. |
| `get_mask_textures() -> Array[Texture2D]` | `[alpha, alphavert]` in V7-86 sampler order. |
| `atlas_grid() -> Vector2`, `get_mode()`, `get_reassembly_info()`, `get_last_error()`, `is_loaded()`, `set_mode()` | Introspection / binding helpers. |

**No invented indices.** All indices are V7-85 `layout[index]` values, i.e.
`presets_summer.json:2-125` ↔ `terrain.presets:2-6`. Face cells reuse base PNGs
per `tiles.mat:142-148,206-220`. The three EMPTY cells (`alpha0a/b/c`) have no
layer. `sand1/sand2` 256²→1024² NEAREST upscale is the inherited
APPROX_SAND_UPSCALE (`tiles.lib:53-63`). Grid 16×8 is APPROX packing
(`reftile.lib:3-12`). `split` writes **only** to `user://tile_atlas_cache/`,
never into `res://`.

`split` streams 1 MiB chunks into the cache and hashes while writing (no 180 MB
RAM buffer); on hash/size mismatch the cache is deleted and `load()` returns
false. `array` loads the 85 unique shipped block PNGs referenced by 121 filled
cells and converts them to 1024² RGBA8 layers.

## 4. Fixes applied after job 239 (all confirmed by job 245)

These were applied to the owned loader/probe only, after reading the captured
stderr; items 1-5 were applied while the queue was paused, item 6 after job 244:

1. `load_atlas()` used bare `load(...)`, which Godot resolved to the global
   `load()` returning `Resource` → parse error. Now `self.load(...)`.
2. `Image.resize()` returns `void` in Godot 4.7 → removed the `Error` assignment.
3. `Texture2DArray.create_from_images()` is an instance method returning
   `Error` in Godot 4.7 → `var ta := Texture2DArray.new(); ta.create_from_images(...)`.
4. `_init()` accepted only `String` as first arg → now `Variant`, so
   `new({"tile_atlas_mode": "array"})` works as documented.
5. Explicit `String(variant)` casts in JSON-field reads replaced with `str()`;
   block/mask image loads now try `res://` paths directly before a
   `globalize_path()` fallback (the project root contains a space,
   "Craft Anything").
6. **Root cause of the array-mode failure:** V7-85 writes `source_png: null` for
   the three EMPTY cells, and GDScript `str(null)` is the literal `"<null>"`,
   not an empty string. Job 244 therefore tried to open
   `res://assets/terrain/blocks/<null>` after index 85. The loader now checks
   `raw_src == null` **before** `str()` and skips those cells. Job 245: 121
   layers, map size 121, empty indices 86/110/123 unmapped.

## 5. Verification jobs (runner is the only legal Godot door)

| Job | Ticket | Result | Measured evidence |
|---|---:|---|---|
| `v791-dual-mode` | **230** | `timed-out` (600 s) | First run hit GDScript parse errors (§4 items 1-3); script did not instantiate, SceneTree stayed alive until the hard kill. |
| `v791-dual-mode` | **239** | `failed` (exit 1, 20/26 checks) | **split mode PASSED**: script loads; API complete; reassembly bytes 179,912,941 and sha `a1f123…dcfbd`; atlas 16384×8192; 2 masks; `tile_uv(17)=(0.0625,0.125)`; `tile_layer=-1`; grid (16,8). **array mode FAILED**: `String` constructor exception at `test14.png` after 86 images; map had 86 slots instead of 121; `array_texture_exists` false. Second failure: config-dict ctor rejected `Dictionary`→`String`. Probe's alarm reported `probe_finished` because `_run()` aborted before `_finish()`. |
| `v791-dual-mode` | **244** | `failed` (exit 1, 23/28 checks) | After the §4 items 1-5 fixes: split 13/13 still PASS, ctor/config/mode PASS. Array still failed at index 86: `cannot load image res://assets/terrain/blocks/<null> (err 12)` — diagnosed as `str(null)`; map 86 slots. |
| `v791-dual-mode` | **245** | **`ok` (exit 0, 28/28 checks, 16.38 s)** | **Both modes verified.** split: reassembly 179,912,941 B / sha `a1f123…dcfbd`, atlas (16384,8192), 2 masks, grid (16,8), UV/layer helpers. array: `Texture2DArray` **121 layers**, index→slot map **121 entries**, unique contiguous slots 0..120, all donor indices 0..123, EMPTY 86/110/123 unmapped, `tile_layer(53)>=0`, `tile_layer(86)==-1`, 2 masks. |

Result files: `variant3d/.godot_queue/results/00000230_v791-dual-mode/`,
`00000239_v791-dual-mode/`, `00000244_v791-dual-mode/`,
`00000245_v791-dual-mode/` (stdout/stderr retained by the runner). The temp
probe and its result JSON were deleted after job 245 passed.

## 6. Deletion status — DONE after job 245 passed

1. **Deleted** `variant3d/assets/terrain/atlas/tile_index_atlas.png` (180 MB).
   Confirmed absent: `atlas/` now holds only `alpha.png`, `alphavert.png` and
   `tile_index_atlas.manifest.json`.
2. **Deleted** the temp probe `variant3d/tests/_v791_dual_mode_probe.gd` and
   `variant3d/tests/results/_v791_dual_mode_probe.json`.
3. **Updated** `split_manifest.json` (and the tool source) `source.status` to
   `DELETED__REGENERABLE`; the recorded source hash is kept so `--check` still
   validates the parts with the source absent. Post-deletion
   `python variant3d/tools/pack_tile_atlas_split.py --check` passes.

The PNG is regenerable: `python variant3d/tools/build_tile_index_atlas.py`
(V7-85 tool, donor root read-only via `$COSSACKS3_DIR`) reproduces all four
original `atlas/` files. The V7-85 manifest and both small masks in `atlas/`
are retained; only the oversized atlas image goes away. Keeping the split parts
and manifest means the commit stays under GitHub's per-file limit.

## 7. Open questions

- Array layer count is **MEASURED at 121** (124 named cells − 3 EMPTY), confirmed
  by job 245; map size 121, unique contiguous slots 0..120. Resolved.
- Does 121 × 1024² RGBA8 (~508 MiB decoded) fit the target runtime's texture
  memory? No GPU staging/A-B was run. `split` mode retains the single-atlas
  alternative precisely for memory-constrained targets.
- Should `array` dedupe face-reuse layers from 121 to 85 unique blocks and keep
  only the index→slot map? That would cut GPU memory but change the layer-count
  contract; deferred to V7-86/A3 until a binding need is measured.
- The `user://` cache is written once and reused; cache invalidation on a
  manifest version bump is not implemented (hash check covers corruption only).
- Whether V7-86 wants `tile_uv()` offsets or a direct `atlas_grid()` uniform in
  `split` mode — both are exposed; no shader edit was made in this atom.

## 8. Bottom line

Delivered the split tool and lossless parts (2 parts, 90,000,000 +
89,912,941 bytes), a manifest whose reassembly hash matches V7-85 byte-for-byte,
small separate masks, and a dual-mode loader with a stable V7-86 API. **Both
modes are runtime-verified: job 245 PASS 28/28** — split reassembly hash/size,
16384×8192 atlas, and array 121 layers with a donor-grounded index→slot map.
The 180 MB single PNG and the temp probe were deleted after that pass; the
remaining parts are each under 90 MB, so the commit fits GitHub's per-file
limit. No visual parity claim, no git operation, no edit outside the owned
paths.
