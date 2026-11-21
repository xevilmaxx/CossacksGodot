# DC — Donor format inventory, binary layouts, and the `.osm` offset verdict

**Lane:** §5a Decompilation (agent DC). **Donor:** `C:\Games\Cossacks 3` (PRIVATE USE ONLY — never copy donor files into the repo, never run donor executables). **Scope:** read-only inventory + byte inspection. No tool, game code, or Godot file was changed by this agent.

Evidence ids below are from the shared Craft Anything session (target `t_5096dee60379`). Counts were cross-checked with a read-only recursive extension census over all 17,237 donor files and with `core_archive_show` over `data/` (17,258 entries, complete listing: `ev_79424d3a...`).

## 1. Family table

| ext | count | role | decodable? | evidence id |
|---|---:|---|---|---|
| `.oss` | 335 | Skinned animated mesh: units, attachable tools, cannons, ship crews | **Yes** — full reader in `bake_sprites.read_oss` / `convert_models.read_oss`; layout decoded and size-closed | `ev_392885a6...` |
| `.osm` | 3897 | Static mesh: buildings (bulk), environment, ship hulls, stages/rubble | **Yes (first frame)** — `read_osm_first` / `read_osm_hull`; section layout decoded and size-closed | `ev_0bbb20c1...` |
| `.aaf` | 246 | ASCII action ranges: `"name",start,end,morph` | **Yes** — `bake_sprites.read_aaf` | `ev_6a6b0380...` |
| `.acl` | 30 | Animation-clip metadata (`section.begin` config dialect, `refkey`/`AnimationName`) | **Partial** — text parses; clip→playback semantics not yet mapped | `ev_e5ad6408...` |
| `.dds` | 1469 | Textures (units, buildings, terrain, decals, water) | **Yes** — standard `DDS ` header; Pillow reads natively (`dds_to_png`) | `ev_e6d0e8ed...` |
| `.pattern` | 710 | Terrain brush footprints: `int32 w,h` + occupancy mask + objects | **Partial** — `donor_gen.py` reads w/h + mask; trailing object list unused | `ev_8a85c8fd...` |
| `.tga` | 4510 | Terrain masks, HDR flare textures | **Yes** — standard uncompressed TGA; masks imported by `import_donor_masks.py` | `ev_e193827a...` |
| `.lib` | 62 | Actor/ACL library manifests (config dialect, `refurl` include) | **Partial** — text parses; include graph not fully resolved | `ev_2a22f2c2...` |
| `.mat` | 35 | Material definitions (config dialect) | **Partial** — text parses; shader params not mapped to Godot | `ev_a5250a00...` |
| `.pfx` | 1 | Particle-system source (config dialect) | **Partial** — text parses; particle semantics unmapped | `ev_f83c1680...` |
| `.map` | 87 | Missions (44 MB each for `ausmis1.map`): binary + `OSWMap13` version strings | **Low** — `extract_map.py` recovers fragments; full layout closed | `ev_16c59dcb...` |
| `.aix` | 65 | Map/GUI companion scripts (config dialect, `section.begin`) | **Partial** — text parses; binding to `.map` not mapped | `ev_ec56dfb7...` |
| `.prop` / `.actor` | 1285 / 976 | Prop and actor registrations (adjacent families) | Not inspected in this pass | inventory `ev_79424d3a...` |

Adjacent census (context, not decoded here): `.lng` 1093, `.txt` 1086, `.inc` 455, `.ogg` 325, `.bmp` 264, `.cfg` 74, `.frag` 58, `.vert` 47, `.script` 29.

Evidence ids in full:
`ev_79424d3a59928f76f0f2bdc4b50777f5831c2b3cba358db49a59b2f9e588eab0` (inventory),
`ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` (oss),
`ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` (osm),
`ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` (aaf),
`ev_e5ad6408513ec3e68c34d45050fb1767652d6ec5719e683f4c4bea9235d4e401` (acl),
`ev_e6d0e8ed6fb17e7938852a8b41caafa7b4490ebb3a7712c138992552af18d37c` (dds),
`ev_8a85c8fda7e27db24f770d1cd39cd942d47e6d4022b0cc31f307f481c0b9a5dd` (pattern),
`ev_e193827ab6f814f11354185ab565650f043a9753171c817b36aa71874b6f26f2` (tga),
`ev_2a22f2c26a504184317be4b4bcb2d13431a88c4855f866e159d7a94e711bbdcf` (lib),
`ev_a5250a007160d6f82705af3103157ab7c95e78dd79ee816983c8492b31347e54` (mat),
`ev_f83c16806d851021c8bdad2286ca258d4b3d0b123045f8f6681f30794ba9789a` (pfx),
`ev_16c59dcb88b1270140084e9862fff432e8d559c9aaccde75c2183ad88193333a` (map),
`ev_ec56dfb728186b791291413eeba9e87fc94f2495546ee01558db2bee11c58405` (aix).

## 2. Binary layout notes

All integers little-endian; all floats IEEE-754 float32. Paths are relative to the donor root.

### 2.1 `.oss` — skinned animation (fully decoded)

24-byte header, six `int32`:

```
<6i  k, fps, b, v, fc, t
```

- `k` = frames per bone (311 in `yacht.oss`, 483 in `peaukr.oss`), `fps` = 30, `b` = bones (20), `v` = vertices, `fc` = triangles, `t` = UVs.
- Followed sequentially by: `v × <3f>` vertices; `fc × <3i>` face indices; `t × <2f>` UVs; `fc × <3i>` UV-index triples; then `v` weight lists, each an `int32` count followed by that many `<i f>` (bone index, weight) pairs; then `b × k × <7f>` bone tracks = position `xyz` + quaternion `xyzw` per bone per frame.

Exact-size closure (strongest check that the layout is complete, no trailing unknown blocks):

| file | k | b | v | fc | t | geom bytes | anim bytes | weight bytes | total |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `yacht.oss` | 311 | 20 | 584 | 947 | 793 | 36,104 | 174,160 | 7,080 (593 pairs) | **217,344** = on-disk size |
| `peaukr.oss` | 483 | 20 | 577 | 921 | 733 | 34,916 | 270,480 | 6,980 (584 pairs) | **312,376** = on-disk size |

Donor rotations are applied **transposed** (row-vector convention) by `bake_sprites.qmat`; this is an established port fact, not a new finding here.

### 2.2 `.osm` — static mesh (first frame decoded)

68-byte header, 17 `int32` (`IDP2` / MD2-style). Field indices (0-based long index):

| idx | name | `yacht.osm` | `algcen.osm` | meaning |
|---:|---|---:|---:|---|
| 0 | magic | `0x32504449` = `"IDP2"` | same | signature |
| 1 | version | 8 | 8 | — |
| 2–3 | sw, sh | 256, 256 | 256, 256 | skin dimensions |
| 4 | fs | 149,840 | 78,432 | section size hint |
| 5 | ns | 1 | 1 | count of `[11]` records |
| 6–8 | nv, nu, nt | 9364, 11490, 7731 | 4901, 5256, 4325 | counts |
| 9–10 | ng, nf | 0, 1 | 0, 1 | gl-command/frame flags |
| 11 | `os` | 68 | 68 | `ns × 64`-byte section (header ends here) |
| **12** | **`ou`** | **132** | **132** | UV offset |
| **13** | **`ot`** | **92,052** | **42,180** | triangle offset |
| **14** | **`of`** | **277,596** | **145,980** | vertex-frame offset |
| 15–16 | `og`, `oe` | 427,436 / 427,436 | 224,412 / 224,412 | end = file size |

Section bodies: UVs `nu × <2f>`; triangles `nt × <6i>` = three vertex indices + three UV indices, consumed with the winding swap `(0,2,1)` for both triples; vertices start **16 bytes past `h[14]`** (a frame/name header, read and discarded) then `nv × <3f I>` (xyz + one uint32 normal/attribute word).

Arithmetic closure on both samples:

```
yacht.osm:   132 + 11490*8 = 92052;  92052 + 7731*24 = 277596;  277596 + 16 + 9364*16 = 427436 = filesize
algcen.osm:  132 +  5256*8 = 42180;  42180 + 4325*24 = 145980;  145980 + 16 +  4901*16 = 224412 = filesize
```

Only the first vertex frame is read by the port; `ng = 0` and both end offsets equal the file size in the samples, consistent with these being single-frame static meshes.

### 2.3 `.aaf`, `.acl`, and the config dialect (text)

`yacht.aaf` is exactly:

```
AAF
4
"idle",1,280,morph
"walk",1,280,morph
"death",1,280,morph
"attack0",1,280,morph
```

Line 2 is the action count; subsequent lines are `"name",start,end,morph` with **inclusive** frame bounds. `bake_sprites.sample` keeps every frame for short actions, otherwise decimates.

`.acl`, `.aix`, `.lib`, `.mat`, `.pfx` all begin with `section.begin` and share `{refurl=...; refkey=...}`, `struct.begin/end`, `Name =`, `From =`, `items[n].AnimationName =` statements — one common "OSW config" dialect. `.map` begins with `int32 53` then the ASCII marker `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0`; the rest is closed binary. `.pattern` begins `int32 w, int32 h` (14, 14 in `brush_plt_11x11_2.pattern`) followed by 0/1 occupancy bytes — matching `donor_gen.py`'s documented reader.

## 3. `.osm` offset bug — verdict: **REFUTED (as stated)**

The reported defect is "`bake_sprites.read_osm_first` reads offset longs **10/11/12**, correct is **12/13/14**" (per AC's docstring on `bake_naval.read_osm_hull`). Byte evidence:

1. **Correct indices are 12/13/14** (0-based) — confirmed in §2.2: longs 12/13/14 are 132 / 92,052 / 277,596 in `yacht.osm`, and all three section reads pass 2000/2000 sanity checks with exact file-size closure. Reading 10/11/12 instead gives UV = 1, face = 68, vert = 132: face records decode as ~1e9 floats and UV records start `(0.0, 0.0)` — unmistakable garbage. So the *correct-field* half of AC's claim is right.
2. **But `bake_sprites` already uses 12/13/14.** Its zip list is `[... "nf","os","ou","ot","of","og","oe"]`, so `h["ou"] = h[12]`, `h["ot"] = h[13]`, `h["of"] = h[14]`. `convert_models.read_osm` uses the same positions via `ofs_uv/ofs_tris/ofs_frames`. This is true in the working tree and in **every** commit in this repo's history (`4b1404c` … `edef9e8`) — the 10/11/12 reader does not exist here.
3. **The two readers are functionally identical.** Importing both modules in `--help` mode (no Blender needed) and running them on `yacht.osm` gives byte-identical `verts` (9364), `faces` (7731), `uvs` (11490), `uvf` (7731), and bbox `x -1.752..1.752, y -4.819..3.208, z -0.376..6.803` — exactly the bbox AC quotes in the "corrected" reader's own docstring.

**Conclusion:** no functional `.osm` offset bug exists in the current tree; AC's "corrected" local reader reproduces the shared reader byte-for-byte. The only real issue is the **misleading comment** in `app/tools/bake_naval.py:80-84` claiming the shared reader is wrong. That file is not owned by this agent; recommend a 10-minute comment-only ticket for AC. Do **not** "fix" `bake_sprites.read_osm_first` — changing 12/13/14 to 10/11/12 would break the building and hull bakes.

Session findings: `fnd_6` (OSM layout), `fnd_7` (bug verdict). Supporting: `fnd_3` (census), `fnd_8` (OSS layout), `fnd_9` (text/standard-raster families).

## 4. Worker-ticket estimate for remaining format work

| # | Ticket | Scope / acceptance | Est. |
|---:|---|---|---:|
| T-1 | Correct the stale `.osm` comment | `bake_naval.py:80-84` comment-only edit; note both readers are identical; no behavior change | 0.02 d |
| T-2 | Reader validation sweep | Run OSS/OSM/AAF readers over all 335 / 3897 / 246 files; produce a failure list (header magic, count/offset bounds, size closure). Reuse the closure equations in §2 | 0.5 d |
| T-3 | Generic OSW config-dialect parser | One parser for `section.begin`/`struct.begin`/`refurl`/`refkey` covering `.acl`, `.lib`, `.mat`, `.pfx`, `.aix` (163 files); export a flat key/value tree | 1 d |
| T-4 | ACL semantic mapping | Map `items[n].AnimationName` and `refkey` chains to the AAF action names actually used by the sprite sampler; validate on `yacht.acl` and 3 units | 1.5 d |
| T-5 | `.pattern` object-tail decoder | Beyond w/h + occupancy (already used by `donor_gen.py`); decode the trailing object references for 710 brushes | 1–2 d |
| T-6 | TGA/DDS coverage audit | Confirm Pillow reads all 4510 `.tga` / 1469 `.dds` variants (incl. HDR TGA and DX10 DDS); add a skip/warn list for unreadable ones | 0.5 d |
| T-7 | `.map` full decode — **high risk, recommended "won't fix"** | 87 × ~44 MB closed binary; `extract_map.py` already recovers fragments and `donor_gen.py`/`build_missions.py` generate replacements. Revisit only if mission fidelity is blocking | 3–5 d, optional |

**Remaining work excluding optional T-7: ≈ 5 worker-days.** Including a full `.map` decoder: ≈ 9–11 worker-days. The animation/mesh/texture pipeline needed for singleplayer is already fully decoded; no ticket should be opened for the alleged `.osm` offset bug.

---
*DC, §5a. Read-only pass: no donor file copied, no donor executable run, no repo file edited other than this document.*
