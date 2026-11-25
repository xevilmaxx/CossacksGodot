---
id: RV-TRN-01
task: "Third-pass independent re-verification of donor terrain values DTRN-01 labelled UNVERIFIED"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_EXECUTED__NO_DONOR_COPIED
scope: "One report file only. No code, asset, config, test, git or runner change. No donor binary was executed, copied or modified."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY. Python bytes/latin-1, struct, pixel decode; Craft Anything read-only byte/string finders.)"
output: "docs/coord_swarm_2026-11-25/reports/RV_TRN_01_texgen_mask_reverify.md"
labels: [observed, derived, inferred, UNVERIFIED]
prior_report: "docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md"
impact_report: "docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md"
verdicts: {eye_plane_values: CONFIRMED_UNVERIFIED, alpha_subrect: PARTIAL, face_tilt_path: PARTIAL, blend_pass_count: CONFIRMED_UNVERIFIED}
craft_anything_findings: [fnd_7, fnd_8, fnd_9]
visual_parity_claim: false
---

# RV-TRN-01 — Texgen / alpha-mask / face-path third-pass re-verification

## 0. Goal

Independently re-verify — using **methods not used by DTRN-01** — the four donor terrain
items DTRN-01 (two passes: V1 numbered line dumps, V2 header reads + filename search)
left **UNVERIFIED**:

1. runtime `gl_EyePlaneS[0]` / `gl_EyePlaneT[0]` / `gl_TextureMatrix[0]` values that drive
   ground texgen (`hf.pvl.sm.vert:30-32`);
2. cell→alpha sub-rect mapping under `tsDouble` / `ttExtended`
   (`reftile.lib:7-12` commented values);
3. face-promotion rule + `rockNvf AngleX=0 AngleZ=25` / `rockNs AngleX=25 AngleZ=0`
   engine path (`tiles.lib:119-207`);
4. donor fixed-function `bmTransparency` pass count.

Donor truth is primary. Nothing is invented; every number below is tagged **observed**
(literal byte/pixel), **derived** (arithmetic or pixel measurement on observed bytes),
**inferred** (interpretation with caveat) or **UNVERIFIED**.

---

## 1. DTRN-01 claims under review

| # | DTRN-01 label | Where DTRN-01 left it | RV-TRN-01 question |
|---|---|---|---|
| A | M2 / §8 Q2 | UNVERIFIED — eye-plane & texture-matrix values are engine-bound | Are concrete values recoverable anywhere else? |
| B | M4 / §8 Q4 | UNVERIFIED — cell→alpha sub-rect mapping; `reftile.lib` values all commented | Can the mapping be reconstructed from bitmap pixels + overrides? |
| C | M3 / §8 Q? | UNVERIFIED — face promotion rule and how `AngleX/AngleZ=25` enter the engine | Are the literals and bindings readable, and is the promotion rule? |
| D | M7 / §8 Q8 | UNVERIFIED — `bmTransparency` pass count | Is a pass count stored in any readable donor source? |

---

## 2. Methods used (deliberately different from DTRN-01)

DTRN-01 used (a) `dread.py` → `decode('latin-1').split('\n')` numbered line dumps and
(b) `struct.unpack_from` header reads + `glob` filename search. **None of the following
was used by DTRN-01:**

- **M1 — PE raw-byte signature scan.** `python` 3.14, `open(p,'rb').read()`, then bytes
  `find()` for ASCII **and** UTF-16LE **and** UTF-16BE encodings of 24 keys across
  `cossacks.exe`, `cossacks.cdx`, `codex.dll`, `config.exe`, `config.cdx`, `editor.exe`,
  `editor.cdx`, `modman.exe`, `modman.cdx`, `steam_api.dll/.cdx`, `steamwrap.dll`,
  `steamclient.dll`. Exact file offsets and ±48-byte hex windows recorded. No string
  decoding of whole files; no line numbering.
- **M2 — Craft Anything read-only cross-check.** `core_target_open` on `cossacks.exe`
  (PE32 x86, stripped, Delphi/C++Builder hints, `.bind` section entropy **7.96 bits/byte
  → packed**); `native_bytes_find` (deterministic raw-byte search with PE virtual
  addresses + section names), `native_strings_find`, `core_feature_find`,
  `core_target_triage`. Findings recorded as `fnd_7`, `fnd_8`, `fnd_9`.
- **M3 — Recursive bytes search over all donor text.** `os.walk` over **16,564 files**,
  binary guard (`MZ`/`BM`/`DDS `/NUL-in-first-512), case-insensitive `bytes.lower().find()`
  for the same keys plus `EyePlaneS`, `EyePlaneT`, `TextureCoord`, `TexGen`. This tests
  *absence*, not just the files DTRN-01 happened to open.
- **M4 — Alpha bitmap **pixel** decode + seam measurement.** Full 8-bit palette (254
  BGRA entries) and 24-bit row decode of `alpha.bmp`, `alphavert.bmp`, `alphanull.bmp`;
  per-64×64-patch min/mean/max/distinct-count; mean absolute intensity delta measured
  at x=32,63,64,65,96,127,128,… and y=32,63,64,65,96,127,128,191,192,193.
  DTRN-01 read only the headers.
- **M5 — Regex enumeration of engine config.** Count and print every `AngleX/AngleZ`,
  `TileSize/Rows/Cols` override in `tiles.lib` with its owning `TileBlockName`, and every
  `refkey=` binding in `tiles.mat`; recursive regex for `rock\d+(vf|vs|nf|ns)` names.

Tool disagreement note: Craft Anything's **string indexer** (`core_feature_find`,
`native_strings_find`) returned **0** matches for `AlphaRows`/`EyePlane`, while raw-byte
finders (`native_bytes_find`, Python) found them. The string indexer only covers
null-terminated data-section strings; these live in **CODE/RTTI blobs**. Per DTRN-01's
rule, the raw byte read wins.

---

## 3. Evidence table

`label` = observed / derived / inferred / UNVERIFIED. Offsets are **decimal file
offsets** unless stated; Craft Anything VAs are given where available.

| Claim | Method | Path:offset | Short excerpt (hex or string) | Label |
|---|---|---|---|---|
| A | M1/M2 | `cossacks.exe:818348` (VA 0x4c88ac) | `45 79 65 50 6c 61 6e 65` = `EyePlane` inside `fdEyePlane` (scene field) | observed |
| A | M1/M2 | `cossacks.exe:946295`, `:952547` | `EyePlane` inside `tmmEyePlane` (texture-matrix-mode RTTI enum) | observed |
| A | M1/M2 | all 12 binaries | **no** `gl_EyePlaneS`, `gl_EyePlaneT`, `EyePlaneS`, `EyePlaneT` byte sequence; case-insensitive ASCII + UTF-16LE + UTF-16BE | observed (absence) |
| A | M1/M2 | `cossacks.exe:4539490` (VA 0x855062, section CODE) | `67 6c 5f 54 65 78 74 75 72 65 4d 61 74 72 69 78 5b 30 5d` = `gl_TextureMatrix[0]` inside a **full embedded water vertex shader** (`gl_TexCoord[0] = gl_TextureMatrix[0]*P;` … `gl_TexCoord[1] = P*texScaleS+time*0.02;`) | observed |
| A | M3 | `data\shaders\obj\hf.pvl.sm.vert:921` / `:976` (byte offsets) | only file in 16,564 with `gl_EyePlaneS[0]` / `gl_EyePlaneT[0]`; no assignment anywhere | observed (absence) |
| A | M1 | `cossacks.exe:5241444`, editor/modman/config analogous | `glTexGeniv`, `glTexGeni`, `glTexGenfv`, `glTexGenf`, `glLoadMatrixf` imported → values are runtime GL state | observed + inferred |
| A | M2 | `cossacks.exe` `.bind` section | entropy 7.96 bits/byte, stripped symbols → engine code cannot be statically decoded for constants | inferred |
| A | M5/M4 | `reftile.mat:34,38-48` | ground `normal` material uses `mappingmode = tmmUser`, `mappingscoordinates=(1,0,0,0)`, `mappingtcoordinates=(1,0,0,0)`, `TextureScale.X/Y/Z=1`; **no** explicit ground eye-plane assignment | observed |
| B | M3 | `reftile.lib:3,4,10,11,12` (bytes @52,76,189,209,229) | `TileScheme = tsDouble`, `TileType = ttExtended`, `//AlphaRows = 8`, `//AlphaCols = 4`, `//AlphaTileSize = 64` — only occurrence in all donor text | observed |
| B | M4 | `alpha.bmp` pixel array @1070 (512×256, 8bpp, 254-entry BGRA palette) | seam strength mean \|ΔI\| at x=64 **126.70**, 128 64.33, 192 183.19, 256 184.83, 320 126.94, 384 64.27, 448 183.09; at x=63 0.42, 65 0.35. y=64 **123.34**, 128 121.77, 192 192.56; y=63 0.43, 193 0.00 | derived |
| B | M4 | `alpha.bmp` 8×4 patches | all 32 patches distinct in intensity stats; patch (col0,row0) and (col4,row0) are constant **255**; (col3,row3) and (col7,row3) constant **0**; others span 0..255 with means 45–216 | derived |
| B | M5 | `tiles.lib:54-56,60-62,66-68,72-74` and `:477-479,483-485,489-491,495-497` | `sand1..sand4` **and** `sand1_winter..sand4_winter`: `TileSize=64, Rows=2, Cols=2` (8 blocks) | observed |
| B | M5 | `tiles.lib:330-332,336-338` | `test10`: 128/16/16; `test11`: 128/32/32 | observed |
| B | M5 | `tiles.lib` regex counts | `TileSize=64` ×8, `TileSize=128` ×2, no other overrides | derived |
| C | M5 | `tiles.lib:119-121,124-126` | `rock1vf {AngleX=0, AngleZ=25}`; `rock1vs {AngleX=25, AngleZ=0}` | observed |
| C | M5 | `tiles.lib` regex counts | `AngleX=0`×36, `AngleX=25`×36, `AngleZ=25`×36, `AngleZ=0`×36 → 36 vf + 36 vs face blocks | derived |
| C | M5 | `tiles.mat:142,146,…,210` | `rockNvf` blocks bind `refkey=verticalfront`; `rockNvs` bind `refkey=verticalside`; some sand blocks bind `refkey=normalside` | observed |
| C | M5 | `reftile.mat:120-142,146-169` | `verticalfront`: `Texture2Name=alphavert`, `TextureScale=0.125`, `mappingmode=tmmEyeLinear`, **S=(1,0,0,0), T=(0,0,1,0)**; `verticalside`: **S=(0,1,0,0), T=(0,0,1,0)** | observed |
| C | M5 | recursive regex over all donor | `rock1vf`/`rock1vs` etc. appear in **exactly 3 files** — `terrain.presets`, `tiles.lib`, `tiles.mat`; **zero** scripts assign them | observed (absence) |
| C | M1/M2 | `cossacks.exe` | `rockNvf` string: 0 matches → face block names are data-only | observed (absence) |
| D | M1/M2 | `cossacks.exe:949234` (VA 0x4e87f2), `:953108`, `:4711020` | `62 6d 54 72 61 6e 73 70 61 72 65 6e 63 79` = `bmTransparency` (RTTI enum, 3 copies) | observed |
| D | M3 | 16,564-file scan | 46 `bmTransparency` hits, all `BlendingMode = …` or enum-name declarations; **no pass count, no blend-equation/factor table** tied to it | observed (absence) |
| D | M1 | `cossacks.exe:765759…771370` | `GL_ARB_blend_func_extended`, `GL_EXT_blend_equation_separate` etc. are merely advertised extension strings | observed / inferred |

Craft Anything evidence ids used: `ev_7e547da5…` (AlphaRows bytes), `ev_1034f519…`
(AngleX bytes), `ev_b385144c…` (bmTransparency bytes), `ev_9ba04e96…` (embedded
`gl_TextureMatrix[0]`), `ev_50d6c755…` (3 `EyePlane` hits), `ev_c719ba6b…` (0 indexed
`EyePlane` strings), `ev_31960c6f…` (packing triage). Findings `fnd_7`–`fnd_9`.

---

## 4. Numeric reconstruction (step 3 of the task)

### 4.1 Alpha atlas geometry — **derived, not invented**

`alpha.bmp` is 512×256, 8 bpp with a 254-entry BGRA palette (data offset 1070). Measured
mean absolute intensity change across candidate column boundaries:

```
x= 63: 0.42     x= 64: 126.70    x= 65: 0.35
x=127: 0.40     x=128:  64.33    x=129: 0.42
x=191: 0.43     x=192: 183.19    x=193: 0.39
x=255: 0.32     x=256: 184.83    x=257: 0.30
x=319: 0.31     x=320: 126.94    x=321: 0.24
x=383: 0.51     x=384:  64.27    x=385: 0.33
x=447: 0.42     x=448: 183.09    x=449: 0.34
y= 63: 0.43     y= 64: 123.34    y= 65: 2.12
y=127: 0.38     y=128: 121.77    y=129: 1.15
y=191: 0.51     y=192: 192.56    y=193: 0.00
```

Discontinuities occur **only** at multiples of 64 in both axes. This is direct pixel
evidence that the alpha atlas is an **8 columns × 4 rows grid of 64×64 patches**, matching
the commented `AlphaRows=8, AlphaCols=4, AlphaTileSize=64`. The grid geometry is therefore
**derived/confirmed** even though the config lines are commented.

Patch means (row-major, col0…col7):

```
row0: 255  52  50 132 | 255  77  72 154
row1:  56 136 157 213 |  58 157 180 206
row2:  45 153 134 210 |  82 174 143 199
row3: 136 210 216   0 | 152 196 203   0
```

- Two patches are constant 255 (row0 col0, row0 col4) → plausible "no feather" masks.
- Two are constant 0 (row3 col3, row3 col7) → plausible "full cut" masks.
- The other 28 are distinct graded ramps. **Which patch a given tile id uses is not
  encoded in any readable file** → still UNVERIFIED. (The sentinel interpretation is
  **inferred**, not asserted.)

`alphanull.bmp`: 512×256, BITMAPCOREHEADER, all 131,072 pixels have palette index 0
(black) → a genuinely null alpha map. `alphavert.bmp`: 1024×512×24, projected cliff mask
(left half largely 255, right half graded) consistent with the two eye-linear face
projections below.

### 4.2 Tile override arithmetic — **observed**

| Block family | TileSize | Rows | Cols | Coverage | Source |
|---|---:|---:|---:|---|---|
| default (commented) | 64 | 16 | 16 | 1024² = 16×16×64 | `reftile.lib:7-9` |
| default alpha (commented) | 64 | 8 | 4 | 512×256 = 8×4×64 | `reftile.lib:10-12` |
| `sand1..4` + `sand1_winter..4_winter` | 64 | 2 | 2 | 256² = 2×2×64 (matches the 256² DDS) | `tiles.lib:54-74,477-497` |
| `test10` | 128 | 16 | 16 | 2048² virtual atlas | `tiles.lib:330-332` |
| `test11` | 128 | 32 | 32 | 4096² virtual atlas | `tiles.lib:336-338` |

`sand3`/`sand4` are **not** ambiguous: they carry the same 64/2/2 override as `sand1/2`
(this corrects DTRN-01 §3.1). Note the winter copies are also overridden.

### 4.3 Face path arithmetic — **observed / derived**

- 36 `vf` blocks with `AngleX=0, AngleZ=25`; 36 `vs` blocks with `AngleX=25, AngleZ=0`.
- `tiles.mat` binds every `vf` → `refkey=verticalfront`, every `vs` → `refkey=verticalside`
  (and a `normalside` variant for some blocks) — all pointing at `reftile.mat`.
- Those two `reftile.mat` sections give **exact** eye-linear alpha-mask projections:
  `TextureScale=0.125`, front `S=(1,0,0,0) T=(0,0,1,0)`, side `S=(0,1,0,0) T=(0,0,1,0)`,
  `mappingmode=tmmEyeLinear`. These are donor literals, not port guesses.
- **What is still missing**: no donor readable file ever *selects* a `vf`/`vs` block for a
  cell. The three files containing those names are a name dictionary and two bind tables.
  Therefore the promotion rule — and how `AngleX/AngleZ=25` is applied (geometry tilt vs
  texgen rotation vs atlas orientation) — remains **UNVERIFIED**.

---

## 5. Verdict table

| # | Claim | Verdict | Exact donor value recovered | Citation |
|---|---|---|---|---|
| A | Runtime `gl_EyePlaneS/T[0]` + `gl_TextureMatrix[0]` for **ground texgen** | **CONFIRMED_UNVERIFIED** | None. No assignment string in 12 binaries, no assignment in 16,564 text files, packed engine code. Authored neighbours: ground `mappingmode=tmmUser`, `TextureScale=1`, S/T=(1,0,0,0)/(1,0,0,0); face alpha S/T vectors (below) | `hf.pvl.sm.vert:921,976`; `reftile.mat:34,38-48`; `cossacks.exe:818348,946295,952547,4539490`; Craft Anything `fnd_7`, `fnd_9` |
| B | Cell→alpha sub-rect mapping under `tsDouble`/`ttExtended` | **PARTIAL** | **Geometry recovered**: 8×4 grid of 64×64 patches, empirically proven by seam deltas; overrides 64/2/2 ×8 and 128/16/16, 128/32/32 ×1 each. **Per-cell patch index still UNVERIFIED** | `reftile.lib:3-12`; `alpha.bmp` pixel array @1070; `tiles.lib:54-74,330-338,477-497` |
| C | Face promotion rule + `rockNvf`/`rockNvs` 25° path | **PARTIAL** | **Recovered**: `AngleX=0/AngleZ=25` (vf) and `AngleX=25/AngleZ=0` (vs), 36 each; exact block names; refkey bindings; face alpha S/T planes + 0.125 scale. **Promotion rule and engine application of 25° still UNVERIFIED** | `tiles.lib:119-296,543-719`; `tiles.mat:142-210`; `reftile.mat:120-170`; 3-file-only name occurrence |
| D | `bmTransparency` pass count | **CONFIRMED_UNVERIFIED** | None. Enum string only; no pass count / blend factor table in any readable source | `cossacks.exe:949234,953108,4711020`; 46 text hits, all enum/`BlendingMode =`; packed `.bind` |

No value was filled in by guessing. Where DTRN-01 was UNVERIFIED and this pass found
nothing readable, the verdict is explicitly CONFIRMED_UNVERIFIED rather than "resolved".

---

## 6. Corrections to DTRN-01

1. **`sand3`/`sand4` ambiguity resolved.** DTRN-01 §3.1: "sand3/4 also 64/2/2 metadata;
   ambiguous". `tiles.lib:64-74` shows `sand3` and `sand4` explicitly carry `TileSize=64,
   Rows=2, Cols=2`; additionally `sand1_winter..sand4_winter` carry the same override at
   `:476-497`. Total 8 such blocks. Not ambiguous.
2. **Face-block name typo.** DTRN-01 writes `rockNs`
   (§3.1, §5.2, §9). The shipped names are `rock1vf`/`rock1vs` … i.e. **`rockNvs`**
   (`tiles.lib:123-126`). Searching `rockNvf`/`rockNs` in the binaries returns 0 hits,
   because these are data-file names, not engine strings.
3. **Face block range understated.** DTRN-01 cites `tiles.lib:119-207` for the 25° blocks;
   the overrides actually run `:119-296` and `:543-719` (36 vf + 36 vs pairs).
4. **Omitted active field.** DTRN-01 §5.1 lists the commented atlas values but not the
   **active** `TileXOffset = 0.1` and `TileYOffset = 0.2` at `reftile.lib:5-6`. These are
   observed; their effect on texgen is **inferred/UNVERIFIED**, not a recovered eye plane.
5. **New source class not in DTRN-01's inventory.** The EXEs embed complete GLSL shader
   sources as raw strings (`cossacks.exe:4539490` water vertex shader;
   `editor.exe:6100761` same). DTRN-01 read only `data/shaders/**`. This adds a source
   class but does **not** change any verdict: the embedded shaders also use
   `gl_TextureMatrix[0]` and never assign eye planes.
6. **String-indexer caveat.** Craft Anything's string indexer finds 0 matches for
   `AlphaRows`/`EyePlane`; raw bytes find them. Any future "absence" claim based only on a
   string indexer is unsafe (the `.bind` section is packed, entropy 7.96).

Claims DTRN-01 got right and this pass independently confirms: filtered atlas values,
112 DDS + 3 BMP inventory shape, `bmTransparency` on both `reftile.mat` and
`reftilealpha.mat`, `tiaAlphaFromIntensity`, `miNearestMipmapLinear`/`maNearest`/
`tfIsotropic`, and the fragment equations in `hf.pvl.smx3.frag`.

---

## 7. Implications for our 3D terrain fix (vs V3D_02)

`V3D_02_terrain_render_audit.md` ranks the active 3D defects P1–P15 and proposes F0–F9.
This pass changes what may be called **donor-grounded** vs **APPROX**:

| V3D-02 item | RV-TRN-01 implication | Consequence for the fix |
|---|---|---|
| **P2 / F1** — neutral eye-plane UVs, "largest shader-side gap" | Ground texgen values still CONFIRMED_UNVERIFIED. New nuance: donor ground material is `tmmUser`, and the only explicit eye-linear planes in `reftile.mat` belong to the **face alpha mask**, not the ground tile. | Keep world-XZ projection as **PORT APPROX — NOT DONOR PARITY**. Do not cite a donor literal. Removing camera-swim is still the right visual goal (V3D-02 F1 acceptance), but no donor-value claim may be attached. |
| **P4 / F4** — atlas + alpha sub-rect APPROX | 8×4×64 patch geometry is now **derived/confirmed** from pixels. The two constant-255 and two constant-0 patches are candidate sentinels (**inferred**). Per-tile patch index still UNVERIFIED. | Implement a 64×64 sub-rect sampler grid rather than whole-mask sampling — this part is donor-grounded geometry. Label the **tile→patch index table** APPROX until an engine-side mapping is found. Do not assert specific tile→patch pairs. |
| **P5 / F5** — face promotion + 25° tilt | Exact `AngleX/AngleZ` literals, block names, refkey bindings and face alpha S/T planes are donor-grounded; the *selection rule* is not. | V3D-02's slope-based `cDiff1/cDiff2` promotion remains an approximation. A 25° tilt can now be added with the **cited literal** `tiles.lib:119-296,543-719`, but its engine application remains UNVERIFIED. The alphabet-mask projection can be made **donor-literal** (front S=(1,0,0,0)/T=(0,0,1,0); side S=(0,1,0,0)/T=(0,0,1,0); scale 0.125) — this is a genuine fidelity gain over V3D-02 P5's current "only switches the alpha mask". |
| **P7** — `mask_to_alpha=1.0` blend | `bmTransparency` pass count CONFIRMED_UNVERIFIED. | Keep the measured diagnostic knob; do not remove it blindly and do not claim one-pass parity. V3D-02's A/B (luma 42.735→38.425) remains the governing evidence. |
| **P1 / F3** — data diversity, **P3 / F2** — lighting, **P6 / F6** — water, **P8** — mesh relief | No new donor evidence from this pass. | Unchanged. V3D-02's ordering (F0 baseline → F1 UVs → F2 sun → F3 data → F4 atlas/mask → F5 faces) stands. |
| **F0** — donor A/B | The EXE is packed and donor was not executed; no static route to runtime texgen/blend state exists. | Visual parity remains blocked by the universal no-donor-frame rule. Every acceptance test in V3D-02 §"Piece-test ladder" must keep its APPROX label for the items above. |

Net: this pass **upgrades two things from "invented" to "donor-grounded geometry"**
(alpha patch grid, face alpha projection planes/scale) and **upgrades one from "literal
known but path unknown" to "literal + bindings known, selection rule unknown"** (face
tilt). It does **not** unlock a donor texgen literal or a blend pass count.

---

## 8. Open questions

1. What runtime values does the engine write into `gl_EyePlaneS/T[0]` and
   `gl_TextureMatrix[0]` for the ground `normal` refkey? Static read is exhausted
   (packed `.bind`, entropy 7.96); only a live GL trace could answer, and donor execution
   is out of scope. (A)
2. Which of the 32 alpha patches does each tile id select, and what exact arithmetic do
   `tsDouble`/`ttExtended` + `TileXOffset=0.1` / `TileYOffset=0.2` perform? Pixel geometry
   is known; selection is not. (B)
3. What promotes a base tile to `rockNvf`/`rockNvs`, and how are `AngleX/AngleZ=25`
   applied (geometry, texgen, or atlas orientation)? No script assigns the names. (C)
4. How many `bmTransparency` passes does the fixed-function renderer emit, with which
   blend factors? (D)
5. Does `mappingmode=tmmUser` on the ground mean the shader's `texGen==1` eye-plane
   branch receives engine-default planes, making the port's neutral values accidentally
   close? **Inferred only** — do not act on it without a GL trace. (A)
6. Are the constant-255 / constant-0 alpha patches actually used as "no blend"/"full
   blend" sentinels, or are they unused atlas slack? **Inferred**. (B)

---

## 9. Summary

DTRN-01's four UNVERIFIED items were re-attacked with raw PE byte scans (ASCII + UTF-16,
two independent tools), a 16,564-file recursive case-insensitive text search, full pixel
decoding of the three alpha bitmaps, and regex enumeration of config overrides.

- **Ground eye-plane/texture-matrix values: CONFIRMED_UNVERIFIED.** No assignment exists
  in any readable donor source; the engine is packed and unstripped values are runtime GL
  state. The embedded EXE shaders use `gl_TextureMatrix[0]` but never assign eye planes.
- **Cell→alpha sub-rect: PARTIAL.** The 8×4×64 patch grid is **empirically confirmed** by
  seam discontinuities exactly at x/y multiples of 64; all tile-size overrides are now
  enumerated. The tile-id→patch selection is still UNVERIFIED.
- **Face tilt path: PARTIAL.** `AngleX=0/AngleZ=25` and `AngleX=25/AngleZ=0`, 36 vf + 36
  vs block names, their `verticalfront`/`verticalside` refkey bindings and the exact
  eye-linear alpha planes (scale 0.125; front S=(1,0,0,0) T=(0,0,1,0); side
  S=(0,1,0,0) T=(0,0,1,0)) are all donor literals. The promotion rule that chooses them
  is UNVERIFIED — the names occur in only three data files, never in a script.
- **`bmTransparency` pass count: CONFIRMED_UNVERIFIED.** Enum string only, no pass data.

DTRN-01 needed three small corrections (sand3/4 override, `rockNs`→`rockNvs`, face range)
and two additions (active `TileXOffset/TileYOffset`, embedded GLSL source class). For the
3D fix per V3D_02, patch-grid geometry and face-alpha projection can now be called
donor-grounded; ground texgen, tile→patch selection, face promotion and blend pass count
must remain explicitly APPROX/UNVERIFIED. No donor binary was executed or copied; one
report written; no code, asset, config, test, git or runner state changed; visual parity
not claimed.

*End of RV-TRN-01.*
