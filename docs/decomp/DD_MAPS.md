# Decompilation note: donor DLC `.map` / `.aix` formats (worker DD, §5a)

Prepared 2026-11-21 by decompiler agent **DD**. Companion to `docs/DLC_INVENTORY.md`
(worker AD) and the 8-ticket map-geometry estimate from worker RD.

**Scope / compliance.** Read-only inspection of the locally installed donor at
`C:\Games\Cossacks 3\dlcs\`. No donor file was copied, converted or committed into
this repository; no donor executable was run; no Godot or game code was touched.
Donor files are **PRIVATE USE ONLY — never redistribute**. Only Craft Anything
read tools, read-only Python byte inspection and `core_finding_record` were used
in the shared session; no brief/plan/handoff write.

## 1. Evidence ids

| id | what it establishes |
|---|---|
| `ev_157a40d6bda3ffbdd8e925ee1ee5a254e8c08c6732ada2f33eda4d67afa54536` | `core_archive_show` of `dlcs\`: 67 files, 49 `.map`, 18 `.aix`, 3,089,187,248 B hashed, per-file sizes and sha256 |
| `ev_c8184e3b5711fe5ede34006c4169e281a9fca41d67fdf548a9728e91de25e3b9` | triage: `scemis8.map` is an unrecognised binary (not a known container/archive) |
| `ev_43b589eb7a9399b6087f9b1acbab29499f6778193ce4b8919b65214df27fa8fe`, `ev_b39facc658be74a3bc482100a7bebee9027676fc3c562c14da260c4d5850f282` | triage: `.aix` files are text, not compiled blobs |
| `ev_1945338e30b07a3c7407e25237c2ebecb0c4ec84b28c4150361266d8d5e5ffd3`, `ev_04b61c03e16a53c9d67d07cedbc8812f6f3f33796dcf4e00367492af48693326`, `ev_ce4ab47c501375838060ac04b7c248bec377e82daf7a5f681c06152b02cd52e5` | full text of 393 B stub, `netmis4.aix`, `turmis1.aix` |
| `ev_440b9c16a0fc4f231b070b255d6b2c5f127615839f01b9bad5916315b08d2f3b` | `35 00 00 00 4F 53 57 4D 61 70 31 33` at file offset 0 (`scemis8.map`) |
| `ev_726ac2a5f99b790c2284ad16377e409d558acc4a2514abde819a7b04c8633ee5` | `OSWMap13.Map.Ver` at offset 4 |
| `ev_d3600c5c1e4770f93dd3d3e4c625349fe4fa0cd159b19b5e6f43bc55fdf04a48` | `GameMapEnd` at offset 39,667,692 (last 10 B of file) |
| `ev_dad5bcfba0d6e855afd3153aec66c17c196fabc0403225c8f161ccfd87eae6a6`, `ev_3e7c86bd8241a8aa5553f75a6fef0a25d059a462ebfb526823d976b1de852112` | `Terrain` ×2 / `Resource` ×2 in `scemis8.map` |
| `ev_0a9f0a9f852919ab43e10c45d7bc6db4cc2f381009fd8556e6dacc2b91fd6226` | `app/tools/extract_map.py` full source |
| `ev_d0796165851e64a57451b428c6072007b2aba0d7c28ebbba459812ced952eb2e` | `app/tools/gen_variant_maps.py` source (first 400 lines) |

Findings recorded in the shared session: **`fnd_4`** (inventory), **`fnd_10`**
(header framing), **`fnd_11`** (`.aix` = text scripts), **`fnd_5`** (reader limit /
opaque grid, inferred).

## 2. Format table

| Family | Count | Extension | Size range | Kind | Decodability |
|---|---:|---|---|---|---|
| 7 DLC families (`dlc1`–`dlc4`, `exp1`, `summer`, `winter`) | 49 | `.map` | 39,667,702 B (`dlc2/scemis8`) – 142,754,495 B (`dlc4/netmis1`) | Closed binary, `OSWMap13` save | Header, UID, markers and ASCII object names readable; numeric grid opaque |
| Same | 18 | `.aix` | 393 – 833 B | **Plain UTF-8 text** mission trigger script | Fully readable; needs hand-translation into mission config |

`.aix` distribution: 12 files are byte-identical 393 B stubs (sha256
`e16db4eb…ae6`) — `polmis1–5`, `scemis1–5`, `celmis1`, `celmis2`. Six are unique
(`spamis2` 595 B, `turmis1` 712 B, `turmis2` 466 B, `turmis3` 595 B, `netmis4`
833 B, `scemis12` 596 B). Only **18 of 49** maps have a companion `.aix`; the
other 31 have none.

**Correction to worker AD's inventory:** `.aix` files are *not* "compiled AI
blobs". They are plain-text scripts (`ev_1945338e…`, `ev_04b61c03…`).

## 3. Byte-level notes

All offsets below are from the smallest map, `dlc2/data/maps/missions/scemis8.map`
(39,667,702 B), read first/last 4 KiB plus a read-only full-file structural walk.
The same 53-byte header pattern was confirmed on `polmis1.map` (build 2843) and
`netmis1.map` (build 2843); `scemis8` is build 2844.

### 3.1 `.map` header is a length-prefixed record stream (first 173 bytes)

| Offset | Bytes | Value / meaning |
|---:|---:|---|
| 0 | 4 | `35 00 00 00` = LE u32 **53** = length of the following string |
| 4 | 53 | `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2844]Core.Ver[1] ` (trailing space included) |
| 57 | 4 | `20 00 00 00` = **32** (block length) |
| 61 | 32 | `UID833805365357200` + zero padding to 32 B |
| 93 | 4 | `14 00 00 00` = **20** |
| 97 | 20 | `GameMapSnapShotBegin` |
| 117 | 4 | `00 00 00 00` (empty record) |
| 121 | 4 | `12 00 00 00` = **18** |
| 125 | 18 | `GameMapSnapShotEnd` |
| 143 | 4 | `12 00 00 00` = **18** |
| 147 | 18 | `GameMapRecordBegin` |
| 165 | 4 | `00 00 00 00` (empty record) |
| 169 | 4 | `00 01 00 00` = **256** |
| 173 | 256 | numeric sub-header (ends at 429) |

After offset 429 the framing **stops being length-prefixed**: raw binary
arrays follow directly. A plain TLV walk therefore succeeds for the 8 header
records and breaks at offset 429 (next u32 reads `0x4B40004C`, i.e. array data).
This is the exact point where `extract_map.py` stops understanding the file.

Other observations (Python, read-only):

- The sub-header at 173 contains per-map varying fields (offsets 4, 8, 12, 120,
  124, 128, 152–176, 180–252) and repeated constants: offsets 20/24 =
  `50176 / 17408` (`0xC400 / 0x4400`), offset 132 = `78643200`, offset 144 =
  `134939392` in all three sampled maps. Values at 184–204 are byte-rotated
  float32 patterns (`0x4B40004C`-style), not obviously integers.
- From ~320 B onward there are long arrays of the repeating 4-byte pattern
  `00 40 4B 4C` (LE float32 ≈ 12.56637 = 4π) with `00 7F` interleaved — numeric
  grid-like data, but **no dimension, stride or endianness is confirmed**.
- 1 MiB chunk scan: offsets ~6–15 MiB and ~20–25 MiB are 98–100 % zero bytes
  (sparse/zero-filled region); from ~25.8 MiB onward printable ASCII rises to
  13–20 % as object records begin.
- Marker counts in the smallest map: `Resource` ×2 (25,811,529 / 25,813,279),
  `Terrain` ×2 (25,813,294 / 31,878,121), `Object` ×15,287,
  `GameObjectBegin` ×7,641, `Player` ×57, single `GameMapSnapShotBegin/End`,
  `GameMapRecordBegin`, `PlayersEnd`, `GameMapEnd`. These are the markers
  `extract_map.py` already searches for.
- Trailer: `01 00 00 00 05 00 00 00 EXT.0 01 00 00 00 0A 00 00 00 GameMapEnd`.
- No gzip (`1F 8B`), ZIP (`PK\x03\x04`), zstd (`28 B5 2F FD`), bzip2 or XZ
  marker in first/last 4 KiB; high zero ratio suggests uncompressed sparse
  arrays rather than a compressed payload. This is **not** proof of absence
  deeper in the file.

### 3.2 `.aix` text structure

Example (`netmis4.aix`, 833 B, `ev_04b61c03…`):

```
section.begin
   Name = netmis4
   UsedFileName =
   Code : struct.begin
      [*] = ;const cPlPlayer = 0;
      [*] = ;const cPlfra1 = 3;
      [*] = ;const cPlayerFarm = 4000;
      [*] = ;gPlayer[cPlPlayer].farm := cPlayerFarm;
   struct.end
section.end

section.begin
   Name = ach
   Code : struct.begin
      [*] = ;_misc_SetCampaignAch(StringRegister0);
   struct.end
section.end

section.begin
   CurrentState =
   SaveVariables = False
section.end
```

The `[*] = ;…` lines store the game's own script statements verbatim as text.
Readable payload: player index constants, per-player farm/resource amounts,
achievement hook, `SaveVariables` flag. The 393 B files are the same skeleton
with `Name = Initial`, a `Log('mission trigger Initial state')` stub and the
`ach` hook — no mission-specific logic.

## 4. Decodable vs closed

**Decodable today (cheap):**
- version/build strings, `Map.Ver`/`Core.Ver`, UID, file size, build variance
  (2843 vs 2844) — useful as a per-map seed;
- all section markers and their byte offsets, including `Terrain`/`Resource`
  block positions;
- ASCII placement names (buildings/units/props) and nation prefixes already
  extracted by `extract_map.py`;
- all `.aix` trigger logic (hand-translate to mission config).

**Structurally visible but opaque (expensive):**
- the 256-byte numeric sub-header and the raw float-like arrays after offset 429;
- the ~19 MiB sparse region — could be unwritten tiles, padding or a different
  array, no evidence either way;
- heightmap/terrain tile grid, placement **coordinates** and orientation. No
  public spec, dimensions unknown; exact geometry is **CLOSED** without binary
  reverse engineering.

**`app/tools/extract_map.py` status** (`ev_0a9f0a9f…`): `HEADER_RE` and `UID_RE`
search only `data[:512]`; `MARKERS` uses `data.find()`; `PLACEMENT_RE` scans the
whole file for nation/building-shaped ASCII. Output JSON stores
`header, uid, markers, placements_total, nations, top_placements,
terrain_block_offset, resource_block_offset, note`. It never parses the
256-byte sub-header, the arrays, or placement positions. Two practical limits
for DLC rollout: it hard-codes the base `data/maps/missions` path (not `dlcs/`),
and despite its "streams the file" docstring `parse_map()` calls
`path.read_bytes()` — the whole up-to-142 MiB file is loaded at once.

`app/tools/gen_variant_maps.py` (`ev_d0796165…`) already provides the other
half: `MapModel` with `height/type/depth/coast` arrays, fbm noise, lakes, hills,
forests, resources and donor-textured PNG output. It is a *preview generator*,
not a scene emitter, but it proves the procedural stack exists.

## 5. Options, worker-ticket estimate and risk

| Option | What it delivers | Tickets | Risk | Notes |
|---|---|---:|---|---|
| **A. Procedural mimic (recommended)** | Batch `extract_map.py` over all 7 DLC dirs → 49 JSONs (fix path + streaming, use UID as seed); feed nation match-up / symmetric starts into the existing procedural generator; hand-translate the 6 unique `.aix` scripts + the shared stub into mission config | **3** (runner/JSON; scene generation + QA; `.aix` config) | **LOW–MEDIUM** | Terrain is *mimicked*, not identical; QA must stop 49 maps looking cloned. No donor bytes committed — derived JSON/PNG and hand-written constants only |
| **B. Extended reader / format RE** | Recover grid dimensions/stride from the 256-byte sub-header, decode the numeric arrays, emit real heightmaps | **6–8** (matches RD) | **HIGH** | Closed format, no spec; likely needs disassembly of the donor loader (private-use only), validation against base maps, and may still fail. Uncertain payoff |
| **C. Formal waiver** | Close the 7 DLC families as non-playable/closed-format in `WAIVERS.md`; keep the 4 existing maps | **0–1** | **LOW** effort / **HIGH** content gap | 49 missions dropped; currently UNKNOWN, never waived. Decision belongs to the coordinator (DD may not edit `WAIVERS.md`) |
| **D. Hybrid: timeboxed spike, then A** | 1 bounded RE ticket to test heightmap recoverability; proceed to B only on a positive result, otherwise fall back to A | **1 + 3 = 4** | **MEDIUM** | Bounded downside; converts RD's 8-ticket risk into a go/no-go decision |

**Recommendation:** **A** (or **D** if the coordinator wants one bounded attempt
at exact terrain). **B** should not be funded as an open-ended lane. **C** is a
scope decision, not a decompilation task.

## 6. Worker-ticket summary

- A: 3 tickets, low–medium risk — **port coverage, approximate fidelity**.
- B: 6–8 tickets, high risk — **exact fidelity, may be impossible**.
- C: 0–1 tickets, low effort — **no coverage**.
- D: 4 tickets, medium risk — **recommended if fidelity must be tested**.

## 7. Compliance (DD)

No donor file copied into the repo; no donor executable run; read-only Python
inspected first/last 4 KiB (plus bounded structural scans) of three maps only.
Only `docs/decomp/DD_MAPS.md` was written. Donor data remains private use only.
