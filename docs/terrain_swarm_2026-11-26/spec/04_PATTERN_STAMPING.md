# 04 — Pattern stamping (from F02 + A02; F01/D05 pending)

**PORT APPROXIMATION on engine-side use; no donor parity claim.** F02 read donor
bytes read-only; A02 cited prior-wave DScript evidence.

## 1. `pattern.lib` is plaintext [O] — F02

- 30,309,138 B, `section.begin`/`section.end` sections, CRLF, 1,172,417 lines,
  **680 top-level sections**, 205,571 `struct.begin`/`struct.end` pairs
  (`pattern.lib:1-39`, full-file scan). **No binary header/index/string table.**
- Fixed **37-field prologue** in identical order for 680/680 sections;
  `HeightFieldMin` at +30, `HeightFieldMax` at +31 relative to section start.
- All prior `pattern.lib:N` "offsets" are **1-based line numbers**, not byte
  offsets. Byte starts for five cited pairs: 18,877,479 (k_ravine_big_stone_1),
  854,933 (hil1), 9,458,861 (g_hil4), 173,669 (plt2), 14,196,248 (k_ravine_1).
- 680/680 names map to `.pattern` files; donor has **710** `.pattern` files;
  30 files have no section.
- Nested blocks: `Objects` → `[*]` → `RaceName`, `BaseName`, `Position`,
  `Direction`, `Up`, `Scaling` (X,Y,Z,W) (`pattern.lib:359-387`); `Waters` →
  `[*]` → `Name=x25y32`, `Width/Height/Position` (`:638257-638286`); `Decals`.
  **39,780 object records, 235 distinct `BaseName`.**
- 12 float-grid cross-checks against `.pattern` bytes reproduce
  `HeightFieldMin/Max` bit-exactly as float32; `Width/Height` equals binary
  `int32 w,h` for 679/680 (one mismatch: `m_swamp_12_old` lib 17×20 vs binary
  18×23 — investigate with multiple passes).

## 2. Families live in `generator.cfg`, not `pattern.lib` [O] — F02

- `Patterns : struct.begin` tree: **64 `Name =` family groups, 493
  `Pattern =`/`Freq =` refs** (`generator.cfg:67-154, :69, :98, :127`).
  452 exact-name matches, 489/493 after normalisation; 217 sections outside any
  family (editor brushes, `i_mnt_*`, `j_big_plt_*`, `fb_*`, `n_small_frt_*`).
- **"Mines" are not a named family**: `mng/mni/mnc` sections embed object props
  `minegold`/`mineiron`/`minecoal` (`pattern.lib:713410, :715244, :716910`
  etc.). Interpretation as gold/iron/coal is `[I]`.
- Mountain props: `BaseName = terrainmesh4` at `pattern.lib:338482` (`g_mnt_1`).

## 3. Stamp algorithm [O]/[U] — A02

- Unit = `.pattern` with height grid + object list + footprint; **rejection
  sampling** against occupancy via `_misc_CheckStandPattern(Ext)`
  (D9:3384–3521). Base placement grid is a strict **25-unit grid** (D1:1330–1359).
- Attempt budget `needed=floor(W*H*freq)`, `trycount=256*(320²)/(W*H)`
  (D9:3686–3704); `Freq` damping ×0.2, floor 1e-4 (D9:3588–3630).
- Relief frequency table for `relieftype 0–4` (D1:1625–1649, :1757–1765).
- Blend flags: `HeightFieldStand/Scale/Min/Max/Replace/ReplaceForWater/Smooth` occur in `pattern.lib` with no plaintext consumer in the donor text files; engine math is nevertheless **decoded [O]** from the native stamp `cossacks.exe:0x755f30` (D05 §F2–F6; independently accepted by X12 claims 3–5 and exercised by X13 vectors; `editor.exe` cross-checked). Counts: `Replace=False` 680/680, `ReplaceForWater=True` 85/680, `Smooth=True` 41/680. **Superseded:** the A02/port additive-clamp placeholder `h = clamp(h_base + grid*Scale, Min, Max)` (A02 §4 Stage 4b) must not be implemented; see §6 for the three authoritative paths. Read all flags from decoded data (`pattern.lib:549563-549575`); carry row-sign flip and the global setter clamp as `[U]`/`PORT APPROXIMATION`. *(V26 C1)*
- Height amplitudes: plateau 2.964, hill 1.31733…, ravine −2.964, water −1.1,
  R multiplier 3.5 (D2:4–7, :567–574).

## 4. Implementation consequences [D]

- `decode_donor_pattern.py` (I02) must decode the `.pattern` float grid at the **corrected byte offset `G = 8 + (w-1)*(h-1)`** (`filesize = 8 + 4*w*h + 54*(w-1)*(h-1)`, 710/710 closure, F01 §4.1–§4.2 / E4 / E8–E11) and the object tail; X13's `G=1000/1912/2866` bit vectors come from shifted DPATTERN windows and are **superseded for grid addressing**, their bit-exact `HeightFieldMin/Max` agreement being a coincidence of overlapping extrema only. *(V37 §4; X23 report not landed at this read)*
- Do **not** use `donor_gen.py` as a compiler: it stops at the `w*h` occupancy
  prefix (`donor_gen.py:74-85`) and synthesises objects/constants (P04 F1/F2).
- Keep the one anomalous record (`m_swamp_12_old`) labelled UNVERIFIED until
  F01/D05 resolve it.

## 5. Cross-check queue

F01 (exact `.pattern` byte layout), D05 (blend math from binary), F08 (flora /
mineral family contents), D07 (placement function verification), X05 (decoder
validation).

## 6. Native stamp function and blend math (from D05 + X12) [O] — governs the fresh module's stamp stage

`sub_755f30` (`cossacks.exe` VA `0x755f30`–`0x75c187`; DScript `StandPattern` signature at `0x6a3474` → `0x6b28d8` → `0x75c228` → `sub_755f30` @`0x75c240`; `0x6b2878`/`0x6b2b60` are sibling natives that call the stamp directly — X12 claim 2 rejects D05's intermediate hop). Config-field→offset map in `sub_75c314`: `Replace=+0x3a`, `ReplaceForWater=+0x3b`, `Scale=+0x48`, `Smooth=+0x4c`, `Min=+0x5c`, `Max=+0x60`, `Offset=+0x64`, `TerrainScale=+0x68`.

Three blend paths, `[O]` from raw x87 opcodes at `0x7563e8`–`0x7566e9` (X13 vectors):

| Path | Formula |
|---|---|
| `ReplaceForWater=true` | `new = g*Scale + HeightFieldOffset` (no base height, no current-height read) |
| `Replace=true` | `new = base_h + (g−Min)*Scale + Min + HeightFieldOffset` |
| default `Smooth` | `new = h1 + (base_h−h0)*TerrainScale + (g−Min)*Scale + Min + HeightFieldOffset` (two `getHeight` reads; collapsing to one is `PORT APPROXIMATION`) |

**`Min` is the scale pivot, `HeightFieldMax` is never read in this function (zero `+0x60` operands in 6,751 instructions), `HeightFieldOffset` is additive. There is no `[Min,Max]` clamp in the stamp.** Negative `Scale` (e.g. `-0.925`) inverts the grid/pivot, not world height. The smooth post-pass is ordered after the blend: interior-only, 8-neighbour mask test, radial remap `(Radius−Offset)/d`, `Factor` repetitions of a 4-neighbour mean divided by hardcoded `4.0` (`cossacks.exe:0x755ee4`). `globalparams.cfg` has no `HeightField*` keys.

Still `[U]`/`PORT APPROXIMATION`: file-row sign, global `setHeight` clamp (`sub_0059b934`, D05 U2/X12 U2), rotated sub-cell rounding, `.pattern` float-plane byte boundary, `HeightFieldMax` consumers outside this function. The DScript class×R amplitude formula (`generatemap.inc:4-7,567-574`) is a **different stage** (mask→height, spec §03 §2 / §10 §2) and does not govern stamping. No donor visual parity claim. *(V26 C1)*

## 7. Cross-check queue (updated)

F01 (exact `.pattern` byte layout); D05/X12/X13 ✓ (stamp math); F08; D07; X05 ✓; V01 ✓ (16-item resolution). Row-flip/global-clamp owners remain a COORD dispatch decision — do not cite a non-existent X12 for them. *(V26 C1)*

## 8. Cross-check queue (updated)

F01 ✓ (size law `8+4wh+54(w−1)(h−1)` on 710/710; five regions; record/weight/tail
semantics `[U]`), X12 ✓ (native verification; chain
`StandPattern → 0x6b28d8 → 0x75c228 → 0x755f30`), X26 (formula verdict), F08 ✓,
D07 ✓, X05 ✓, V01 ✓.

---
*Integrated by COORD from F02 + A02 + D05 + F01 + X12 + X13.*


---
*Integrated by COORD from F02 + A02 + D05.*

