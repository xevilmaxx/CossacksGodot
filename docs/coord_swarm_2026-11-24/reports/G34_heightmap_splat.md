---
title: "G3-4 — Deterministic donor-block splat/albedo for the heightmap mesh"
agent: G3-4
date: 2026-11-24
status: TOOL_DELIVERED__G32_DUMP_MISSING__OUTPUT_FROM_STANDIN_DUMP
verdict: UNVERIFIED_AGAINST_G32_DUMP
claim_under_test: "one RGBA texture can carry donor block albedo + height data for G3-2's full-map heightfield"
owner_files:
  - app/tools/heightmap_splat.py
  - app/assets/terrain/heightmap/splat_albedo.png
  - app/assets/terrain/heightmap/splat_albedo.manifest.json
  - docs/coord_swarm_2026-11-24/reports/G34_heightmap_splat.md
---

# G3-4 — Heightmap splat/albedo tool

## 1. Status in one paragraph

The tool is delivered and exercised. **`app/shots/g32_dump.json` does not exist**
(no G3-2 dump has landed at the time of writing), so the default invocation
fails honestly with exit 2 and an explanatory hint. To prove parsing and
block-name mapping, I used an existing **stand-in** map dump
`app/shots/t6t90_dumps/dump_20261113_a.json` (seed 20261113, 320×320) and did a
dry run plus a real generation. The delivered PNG was built from that stand-in
dump, and its sidecar manifest names that input + sha256. **No claim is made
about pixel content for G3-2's future dump**; regenerate with
`--dump app/shots/g32_dump.json` when it exists.

## 2. Donor / block evidence (read-only)

Read (never modified, no donor binaries opened):

- `docs/coord_swarm_2026-11-24/WAVE6_3D_CHARTER.md` — G3-4 owns the splat tool
  and `app/assets/terrain/heightmap/**`; G3-2 is told to generate
  `app/shots/g32_dump.json` with runner id `g32-dump`, seed 20261113.
- `app/assets/terrain/structs/presets_summer.json` — **124** block names,
  indices 0..123. `game.gd:1409-1416` builds `tbl_names`/`tbl_idx` from this
  exact file, and `game.gd:1607-1608` (`_blk`) maps names to indices.
- `app/assets/terrain/blocks/*.png` — **112** PNG files, all **1024×1024 RGB**
  (port-only, donor-derived art). **39 preset names have no PNG**: all
  `sand*f/s`, `rock*vf/vs` transition variants and `alpha0a/alpha0b/alpha0c`.
  None of those ids occur in the stand-in dump's used set.
- `app/scripts/game.gd:1610-1698` (`_assign_tileblocks`) — base `grass1` for
  terrain 0; terrain 1 dirt (`ground1`/`test2`/`test3`), 2 meadow
  (`grass_ground1..3`), 3 water, 4 sand, 5 rock; mine apron overrides to
  `ground1`; then shore/cliff, 3 smooth passes, detail bitmaps and forest
  borders. `BLK_WATER := 255` (`game.gd:52`). `Data.TILE_M := 2.0`
  (`data.gd:23`) — the mesh's cell size in metres.
- `app/scripts/main.gd:688-695` — canonical dump schema: `height` and all
  grids are `Marshalls.raw_to_base64`, row-major `y * map_w + x`.
- `app/scripts/world3d.gd:40-45,184-202` — the old block renderer resolves
  `tileblock` ids through `presets_summer.json` and decodes `height` as
  base64 float32, confirming the mapping used here.

Stand-in dump facts actually measured (not guessed):
`map_w=map_h=320`, `seed=20261113`, `height` decodes to 409600 bytes =
102400 little-endian float32 values, range **−2.964 .. +2.964 m**;
`tileblock`/`terrain`/`blocked` each decode to 102400 uint8 values. **31**
distinct tileblock ids are present (`0,1,4,6,7,8,9,10,14..25,72..74,77..80,82..85`),
all with PNGs; **no id 255** in that dump. Top ids: 14 `grass_ground1` (28558
cells), 0 `grass1` (16075), 16 `grass_ground3` (15929), 79 `test8` (7657),
25 `rock9` (4130). Sampled block mean RGBs: `grass1` (76,83,30),
`grass_ground1` (82,79,36), `ground1` (100,91,66), `rock4` (71,62,50),
`sandsea6` (125,116,86). A separate existing scan dump
`scans/t2gen/dump_7.json` **does** contain id 255, which is why the tool has an
explicit water sentinel path.

## 3. Tool design (`app/tools/heightmap_splat.py`, 18993 bytes)

Pure Python 3 + Pillow. **No Godot launch, no donor read, no randomness.**

1. **Parse** `--dump` JSON (default `app/shots/g32_dump.json`). Accepts the
   Godot base64 strings or flat numeric JSON arrays; decodes base64 with
   `validate=True`; infers square `map_w/map_h` when absent; validates lengths
   against `w*h`. `--schema` prints the documented input contract; `--help`
   prints it too.
2. **Map ids** — index → `presets_summer.json` name, exactly as `game.gd` does.
   Id 255 (`BLK_WATER`) is redirected to `--water-block` (default `sandsea6`)
   because no water PNG exists; missing PNGs for *used* ids are a hard error.
3. **Sample** each used block PNG once with Pillow `LANCZOS` to
   `texels_per_cell × texels_per_cell` RGB samples. Default is **1**, i.e. the
   full 1024² image is reduced to one deterministic mean colour per cell.
4. **Blend** in cell space: own cell weight 4; each neighbour in the
   Manhattan-radius (`--blend-radius`, default 1) contributes weight 1 only if
   it has the same block *family* (leading letters of the name, e.g. `grass`,
   `rock`, `test`) **or** its height differs by at most
   `--blend-height-eps` (default 0.25 m). This softens mosaic inside a family
   without smearing rock/sand boundaries. `--blend-radius 0` disables it.
5. **Write one RGBA PNG** (default
   `app/assets/terrain/heightmap/splat_albedo.png`):
   - **RGB** = blended donor-block albedo, sRGB bytes, no lighting applied;
   - **A** = `--alpha height` (default): `round_half_up(255*(h-hmin)/(hmax-hmin))`
     using the dump's own min/max; `--alpha roughness` writes a deterministic
     per-family proxy (grass 205, ground 215, rock 240, sandrock 235,
     sandsea 225, sand 220, desert 225, test 210, alpha 200, winter 215,
     default 210) — **not donor data, the donor has no roughness map**;
     `--alpha none` writes 255.
6. **Sidecar** `splat_albedo.manifest.json`: input path + sha256 + seed, grid,
   output size, all settings, height range, and the full used-id → block-name →
   mean-RGB → cell-count table. No timestamps and no RNG, so it is
   byte-stable across runs.

CLI flags: `--dump`, `--out`, `--presets`, `--blocks-dir`, `--alpha`,
`--blend-radius`, `--blend-height-eps`, `--texels-per-cell`, `--water-block`,
`--dry-run`, `--schema`.

## 4. What was actually produced / measured

| File | Bytes | sha256 |
|---|---:|---|
| `app/tools/heightmap_splat.py` | 18993 | `297aa8cee2d24b58867e0cc1469323b4831998cb8f5af68ab75e55d8c0e5b3e7` |
| `app/assets/terrain/heightmap/splat_albedo.png` | 81665 | `6d93d6cd89a1704f28d259927f6fc2496c83c5d26488ea3a193f365490a9514a` |
| `app/assets/terrain/heightmap/splat_albedo.manifest.json` | 8365 | `311f58176e8a13554a17aa55fa662086bcb315dbd4ce9ffc74aa611abea83795` |

Measured on the generated PNG: **320×320, mode RGBA**, alpha range **0..255**,
mean RGB ≈ (48.7, 48.5, 21.9). These numbers describe *the stand-in dump's*
texture only.

Proof commands and results:

- `python app/tools/heightmap_splat.py --help` → schema + all flags, exit 0.
- `python app/tools/heightmap_splat.py --schema` → input contract, exit 0.
- `python app/tools/heightmap_splat.py --dump app/shots/g32_dump.json --dry-run`
  → `ERROR: dump not found ... Hint: ...` exit 2. **This is the honest
  missing-input condition for the requested dump.**
- `python app/tools/heightmap_splat.py --dump app/shots/t6t90_dumps/dump_20261113_a.json --dry-run`
  → printed 31 id→name→mean-RGB lines (all 31 PNGs found, no missing), predicted
  output 320×320 RGBA, wrote nothing.
- Real generation with that stand-in dump → the two files above.
- Smoke variants (written to temporary owned-dir paths, then deleted):
  `--alpha roughness` alpha 205..240; `--alpha none` alpha 255;
  `--texels-per-cell 2` 640×640; `scans/t2gen/dump_7.json` (contains water id
  255) built successfully via the `sandsea6` sentinel.
- **Determinism:** regenerated to the same path; PNG sha256 unchanged
  (`6d93d6cd…9514a`). No seed, no RNG, fixed LANCZOS and half-up rounding.

## 5. Handoff to G3-2

- **Texture:** `res://assets/terrain/heightmap/splat_albedo.png`, 320×320 RGBA
  for a 320×320 height grid (matches `map_w × map_h` of the dump). Sidecar:
  `res://assets/terrain/heightmap/splat_albedo.manifest.json`.
- **Channel semantics:** `RGB` = donor block albedo (already sRGB, no lighting
  baked by this tool beyond what the donor art itself contains); `A` = height
  normalised over the dump's min/max (0 = lowest, 255 = highest). **A is DATA,
  NOT TRANSPARENCY** — use it in a shader as a scalar (e.g. wetness/rock blend),
  do not enable alpha blending on the terrain material.
- **UVs:** row-major north/west origin, same as `height[y*map_w + x]`.
  For vertices at cell centres: `u=(x+0.5)/map_w`, `v=(y+0.5)/map_h`.
  For a 321×321 corner grid: `u=x/map_w`, `v=y/map_h`, with `CLAMP_TO_EDGE`
  and nearest sampling (or add a half-texel offset) so texels stay aligned.
  Mesh vertex height remains `height[i] * 1.0` m with `TILE_M = 2.0` m spacing
  (`world3d.gd:12-14`); do not use the alpha value for geometry.
- **Regenerate for your own dump:**
  `python app/tools/heightmap_splat.py --dump app/shots/g32_dump.json`
  (optionally `--alpha roughness` or `--blend-radius 0`). Check the manifest's
  `input_dump_sha256`/`input_seed` to confirm you are using the right map.
- Example shader use: `vec4 s = texture(splat, uv); ALBEDO = s.rgb;`
  and `float hmask = s.a;` for any height-driven effect.

## 6. Open questions

1. Which seed/dump will G3-2 actually render? The delivered texture is from
   stand-in seed 20261113; it must be regenerated for `g32_dump.json`.
2. Is normalised height the best A payload, or would a roughness/terrain-class
   mask be more useful to the shader? Both modes are implemented.
3. Is 1 texel/cell enough, or should `--texels-per-cell 2/4` be used for
   visible in-cell donor detail? Default kept at 1 per the charter's
   "dimensions should match the height grid" note.
4. Water: `sandsea6` is an assumption (donor water is a separate plane in
   `world3d.gd`); confirm whether G3-2 draws its own water and wants a flat
   water-bed albedo instead.
5. Block PNGs carry donor-authored shading (means ≈70..125, not neutral
   albedo). Whether to linearise/de-light them for PBR lighting is a visual
   decision for G3-2/G3-3, not something this tool claims to solve.
6. Winter/desert presets: the tool intentionally reads only the summer table
   used by the current port default; biome variants would need a
   `--presets` argument and matching block names.
