---
id: DEC-U-RELIEF-STAMPS-2026-11-26
title: "DEC_U_relief_stamps — native relief stamping (sub_755f30): height-field formula, scale/offset/min/max, angle gating, S0 kernel, Objects[]"
agent: "DEC-U-RELIEF (READ-ONLY subagent; no code/Godot/git edits; donor read-only, never executed)"
date: 2026-11-26
target_pinned: "t_87f0f3c130b0 (C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c)"
scope: "Static read-only decomp of native relief stamping; exactly one repo file written (this report)"
labels_used: [O, D, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists. No formula or byte-dump below certifies donor visual parity. IMPL-PLACEMENT hooks stay NULL until probes terminate."
---

# DEC_U_relief_stamps — native relief stamping

## 0. Result in one paragraph

The native relief stamp is `sub_755f30` (`0x755f30`–`0x75c187`, 234 blocks / 6,751 insns / 662 callees / 5 callers, `ev_ed57855c…` / `ev_13f00ea1…`).
Its height-field application formula is **byte-proven [O]** at opcode level
(`0x756601`–`0x7566e9`, `ev_a92017af…`; Deep pseudocode lines 244–330,
`ev_c176cc81…`): `Min (+0x5c)` is the **scale pivot**, `Max (+0x60)` is
**never read in this function (0/6,751)**, `Offset (+0x64)` is additive,
`TerrainScale (+0x68)` multiplies only `(base_h−h0)`, and the default Smooth
branch issues **two** `getHeight` reads with an 80-bit spill. Shipped
`pattern.lib` incidence is `Replace=False 680/680`, `ReplaceForWater=True`
85/680, `Smooth=True` 41/680, `TerrainScale=1.0` 680/680, `Offset=0` 680/680
(spec §04 §§3/6; F02 census; X13 E1–E3). Everything not in that sentence —
per-pattern `Scale/Min/Max/Offset/TerrainScale` concretes beyond the three
X13-audited sections, `minangle/maxangle` offsets and WithAngle arg use,
the `S0 SmoothTerrain(x,−y,False,3)` kernel bytes, the `.pattern` 24-byte
tail semantics, and `Objects[]`→mesh binding — stays **[U]** with a
fixed-seed zero-mismatch probe each (§6). The port's
`terrain_donor_gen.gd:_stamp_pattern` already implements the authoritative
X26 formula; §7 lists only label/probe/file-line corrections, **no code
edit made here**.

## 1. Method, discipline, multi-pass ledger

- Donor binary never executed/copied/committed. No repo code/shader/config/
  asset/test/git/Godot edit. This worker wrote only this report.
- All addresses/bytes below are re-citations from pinned evidence ids on
  `t_87f0f3c130b0`, re-read in full this pass (no new native bytes claimed):
  `DEC_DEEP_placement_755f30.md` §§1–5/8, `X12_stamp_verification.md`
  claims 1–5, `X13_blend_test_vectors.md` §§Formulas/Vectors,
  `X26_blend_formula_verification.md` §§Authoritative/Vector/Stale,
  `spec/04_PATTERN_STAMPING.md` §6, `spec/03_MASK_TO_HEIGHT.md` §§1–3,
  `F01_pattern_format.md` §§4.1–4.2/4.9, `DEC_U_placement.md` §§2/5–7,
  `PORT1TO1_terrain_renderer.md` §§3–4, `DEC_U_atlas_layout.md` §§2–3,
  `variant3d/scripts/terrain_donor_gen.gd:300-419,2693-3008`,
  `variant3d/scripts/terrain_donor_mesh.gd:75-96,262-337,743-772`.
- Starting-document conflict resolved by multiple passes (owner rule);
  nothing silently skipped.

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4 | Verdict |
|---|---|---|---|---|---|
| stamp bounds/callers | `ev_13f00ea1…` + `ev_ed57855c…` counts | X12 E5/E6 caller list | DEC_DEEP §1 wrapper `0x75c228` (`ev_370b6b…`, `0x42b40000`=90.0f) + `sub_723748` `+0x41` fork | — | [O] bounds/callers/chain correction stand |
| blend opcodes | X12 P4 `0x7563e8`–`0x7566e9` | X26 E4–E6 re-filter + `+0x60` negative scan (0/6,751) | Deep lines 297–303/306–330 | X26 P6 19/19 `f32step` replay | [O] X26 table authoritative; task literal refuted |
| post-pass order | X13 U6 in-place≠double-buffer | X26 E8 `sub_755db4` 4×`getHeight` + 1×`setHeight`, no snapshot | gate `Stand&&Smooth`, branch-independent (`g_hil4` discriminator) | — | [O] in-place; snapshots synthetic-only |
| grid offset | X13 `G=1000/1912/2866` min/max bit-exact 3/3 | F01 `8+4wh+54N` 710/710 + `G=8+N` | X26 P7 19/19 shifted vs 0/19 true; shifts +8/+12/+17 floats | — | [O] F01 `G` governs; X13 offsets STALE for addressing |
| angle/WithAngle | `sub_723748` `+0x41` fork (`ev_370b6b…`) | DEC_DEEP §4–5 `0.0/90.0/2.0/0.5/4.0` + tbyte UNVERIFIED | fnd_46 carried angle-filter shape | no re-type of `minangle/maxangle` offsets | [U] offsets/use stay open (§6 U-ANG) |
| `.pattern` tail | F01 five regions + 550,908-record invariants | `Objects[]` counts vs binary N mismatch | — | — | [O] structure; [U] semantics |
| port hooks | gen `:300-419` hooks + `:2693-3008` stamp body | mesh height-clean (`HEIGHT_SCALE=1.0`, no stamp) | `STAMP_SMOOTH_PARAMS` 41-entry census | — | keep + label-only changes (§7) |

## 2. Authoritative height-field formula [O]

`p` = parsed pattern object. `g` = `p.heightGrid[row][col]` (`+0x28`,
float32 stride 4, row-major `grid[z][x]`). `base_h` = bilinear world sample
at stamp centre (`call 0x810498 @0x756435`, f32 `@[ebp-0x10]`).
`Scale` = `+0x48` (or `rand(+0x40,+0x44)` iff `UseRndScale +0x3c`).
`Min/Offset/TerrainScale` = `+0x5c/+0x64/+0x68`. `Max +0x60` = written by
parser, **zero struct reads in stamp** (X12 P4/P5; X26 E7 stricter scan).

| Path / selector | `g2` transform | Final combine + store | Donor opcode evidence | Deep lines | Vector confirmation |
|---|---|---|---|---|---|
| `ReplaceForWater=true` (`cmp [p+0x3b] @0x756601`, taken) | `g2 = g*Scale` (`0x75661f/622/625`) | `h_new = g2+Offset` (`fld g 0x75664b`, `fadd [p+0x64] 0x756651 d8 40 64`, setter `call 0x7551a8 @0x756664`) | X12 E5 / X26 E6 | 297,301–302,327–328 | X13 8/8 donor-flag RVW/AXIS bit-exact both precision models |
| `Replace=true` (`+0x3b` not taken; `cmp [p+0x3a] @0x75666e` not taken) | `g2 = (g−Min)*Scale+Min` (`fld 0x756607`, `fsub [p+0x5c] 0x75660d d8 60 5c`, `fmul [ebp-0x20] 0x756610`, `fadd [p+0x5c] 0x756616 d8 40 5c`, `fstp 0x756619`) | `h_new = base_h+g2+Offset` (`fld [ebp-0x10] 0x756674`, `fadd 0x756677`, `fadd [p+0x64] 0x75667d`, setter `@0x756690`) | X12 E5 / X26 E5–E6 | 297–299,321–323 | X26 4/4 synthetic `f32step` bit-exact; task literal fails `REP-hil1-01` (`0x4074F076` vs `0x40A5B75B`), `REP-kr1-02` (`0x407DED61` vs `0x40C3527F`) |
| default Smooth (`+0x3b=false,+0x3a=false`) | same pivot as Replace | `h0=getHeight @0x7566a0`; `t=(base_h−h0)*TerrainScale+g2+Offset` (`fsubr 0x7566a5`, `fmul [p+0x68] 0x7566ab`, `fadd 0x7566ae`, `fadd [p+0x64] 0x7566b4`); 80-bit spill `fstp tbyte [ebp-0x154] 0x7566b7`; `h1=getHeight @0x7566c7`; `h_new=t+h1` (`fld tbyte 0x7566cc`, `faddp 0x7566d2`, setter `@0x7566e4`) | X12 E5 / X26 E6 | 306–319 | X26 5/5 synthetic `f32step` bit-exact; single-read literal fails `SMB-kr1-02` (`0x401AB589` vs `0x3FA89E45`) |
| occupancy gate (all paths) | — | `if (mask[row][col]!=0) skip` (`cmp byte [eax+edx],0 @0x756638`, `jne 0x7566e9`) | X13 E8 / X26 table | 305 | [U] flag semantics (U-OCC) |

Algebraic note [D]: with shipped `TerrainScale=1`, `h1≈h0`, Smooth
reduces *in shape* to `base_h+g2+Offset`, but the two reads and the
`tbyte` spill must be preserved. The circulated
`Replace=base_h+g+Offset` and single-`h` Smooth rows are **STALE/REFUTED**
(X26 S1/S2). No `[Min,Max]` clamp exists in the stamp.

Parser map [O] (`sub_75c314 0x75c314`–`0x75c6a1`, `ev_938f5d4…`/`ev_e2e21ff…`;
editor `0x8cc7ae` cross-check X12 E17): `Stand=+0x39`,
`Replace=+0x3a`, `ReplaceForWater=+0x3b`, `UseRndScale=+0x3c`,
`MinScale/MaxScale=+0x40/+0x44`, `Scale=+0x48`, `Smooth=+0x4c`,
`Radius/Factor/Offset=+0x50/+0x54/+0x58` (Offset default 2),
`Min/Max/Offset=+0x5c/+0x60/+0x64`, `TerrainScale=+0x68`,
`OffsetX/Z=+0x74/+0x78`. `globalparams.cfg` carries no `HeightField*`
keys (D05 E12).

Shipped-pattern incidence [O] (F02 census via spec §04): `Replace=False`
680/680; `ReplaceForWater=True` 85/680; `Smooth=True` 41/680;
`TerrainScale=1.0` and `Offset=0` on all three X13-audited sections
(X13 E1–E3: `hil1 Scale=0x3F266666/Min=0/Max=0x40771F94`;
`g_hil4 Scale=1.0/Min=0xAAF3441C/Max=0x3FF55FDC/Smooth=True/R=3/F=4/O=2`;
`k_ravine_1 Scale=1.0/Min=0xC03DAC13/Max=0x4048F2D0/TerrainScale=1.0`).
Do not promote `base_h∈{1.31733,2.964}`, `Offset=1.25`,
`TerrainScale=0.5`, `h0=−1.1` test inputs into the generator (X13 §I7).

Smooth post-pass [O] (`sub_755db4`, divisor `4.0 @0x755ee4`,
`ev_ae9a80…`; 8-neighbour gate `0x757077`–`0x757161`, `Factor [p+0x54]`
iteration count, `(Radius−Offset)/d` from `[p+0x50]/[p+0x58]`,
`fsqrt 0x757199`): gated by `Stand && Smooth` **independent of the blend
branch** (`g_hil4` is `ReplaceForWater=true` yet smoothed); interior-only;
**in-place** read-after-write on the live world field (X26 E8:
four `getHeight 0x755e6a/7a/8a/9a`, sum, `fdiv [0x755ee4] @0x755eaf`,
one `setHeight 0x755ec2`). X13 double-buffer snapshots are comparison-only.

## 3. `.pattern` file layout + 24-byte tail [O structure / U semantics]

F01 closure [O/D] (`F01_pattern_format.md:43-50`): 710/710 files satisfy
`filesize = 8 + 4·w·h + 54·N`, `N=(w−1)(h−1)`, zero residual.
Five regions in order:

1. `int32 w,h` (8 B).
2. `u8 mask[N]` at `0x08` — values 0/1 only in all 710 files (F01 E6).
3. `float32 height[w·h]` at **`G = 8+N`** (F01 E8–E11; X26 E13/E14) —
   678/680 `pattern.lib` Min/Max bit-exact; X13 `G=1000/1912/2866` are
   shifted +8/+12/+17 floats and must not be used for addressing.
4. `u8[4] PRE` + `N × 24 B` records: `u8 id` (0…255 over 550,908 records),
   four `1.0f` (`0x3F800000` exact, no violation), 4-byte tail
   (`00000000` in `fb_1`; semantics [U]).
5. `int32[4N−1]` weight block (`16N−4` B; values `{0,99,100,101,200}` +
   float-looking ≈2.8e7 in 4 files; semantics [U]) → `N × 13 B` tail
   records (`u8[10]=0` in 100%; `i16∈{−1 (547,967), 255 (2,941)}`;
   `u8∈{0 (494,076), 1 (56,832)}`; semantics [U]).

Loader allocation vs on-disk extent [D] (D05 F1; X13 P2; X26 §Grid):
loader reserves `(w+1)(h+1)` floats; on-disk plane is `w·h` floats.
Border-cell contents are [U]. `pattern.lib Objects[]` (e.g. `hil1` 58
records vs binary `N=960`) is **not** the same population as the binary
24 B stream (F01 E20) — never equate them.

## 4. `pattern.lib` descriptor tail [O structure]

- 30,309,138 B, CRLF, 1,172,417 lines, **680 top-level sections**,
  205,571 `struct.begin/end` pairs (spec §04 §1).
- Fixed **37-field prologue** in identical order for 680/680 sections;
  `HeightFieldMin` at +30, `HeightFieldMax` at +31 relative to section
  start; `Width/Height` int32 equals binary `w,h` for 679/680
  (`m_swamp_12_old` 17×20 lib vs 18×23 binary stays [U]).
- 680/680 section names map to `.pattern` files; donor ships 710
  `.pattern` files (30 orphans + 1 case-only `k_ravine_2/K_ravine_2`).
- `Objects[] → [*] → RaceName/BaseName/Position/Direction/Up/Scaling`
  (e.g. `pattern.lib:359-387`); 39,780 object records, 235 distinct
  `BaseName`; `Waters → [*] → Name/Width/Height/Position`
  (`:638257-638286`); `Decals`. Concrete mesh filenames/materials live
  here and in actor tables, not in CODE strings (0 hits, DEC_DEEP §1).
- `STAMP_SMOOTH_PARAMS` census in the port (`terrain_donor_gen.gd:314-343`)
  covers the full 41/680 `Smooth=True` set (`brush_plt_*×5 [1,4,1]`,
  `d_plt1/g_mnt_1..7/g_hil1..9/i_mnt_big_1..5/gift1..5 [3,4,2]`,
  `k_ravine_big_1 [3,4,2]`, `k_ravine_big_stone_1..8 [3,4,0]`) — keep as
  transcribed census, never as invented floats.

## 5. Angle gating + WithAngle [U — not recovered]

- Fork [O]: `sub_723748` branches on pattern `+0x41`
  (`ev_370b6b…`): `+0x41==0 → sub_75c228(0x42b40000=90.0f,0,…)` then
  `sub_755f30 @0x75c240`; `+0x41!=0 → sub_755f30(*(esi+0x38),*(esi+0x34),…)`
  directly. Corrected chain [O/D] (X12 claim 2):
  `StandPattern(0x6a3474)→0x6b28d8→0x75c228→0x755f30`;
  `StandPatternWithAngle(0x6a33dc)→0x6b2878→0x755f30`;
  `StandPatternWithAngleAdv(0x6a35bc)→0x6b2b60→0x755f30` (+2 more direct
  callers `0x723bf9/0x723cbc`, `0x75c28e`).
- Normalization constants [O]: `0.0 @0x755c58/0x755da0/0x755d08`,
  `90.0 @0x755c68/0x755db0/0x755d18`, `2.0 @0x75c1a4` (252 xrefs),
  `0.5 @0x75c1a8`, `4.0 @0x755ee4`, `75.0/2.0 @0x723e34/44` generator
  scale/divide. Extended `tbyte` constants
  (`0x75c198/0x755c5c/0x75da4/…`, raw `21 68 C2 35…`, `ev_db56bc…`) are
  **UNVERIFIED — never hard-code as PI**.
- Carried [D] (DEC-VIS-02 fnd_46, consistent with `sub_755bc8/755d1c/755c6c`
  `fcomp 0.0 + fadd TBX + fdiv 90.0` + corner-byte permute): object loop
  visits every record in order with **no RNG** (662-callee list
  `ev_4a342…` contains no `RandomExt`/Delphi draw); per-instance variation
  is authored, not rolled. `minangle<=0 and maxangle>=90` bypass is carried
  shape only — exact `minangle/maxangle` field offsets inside 24 B/16 B
  records and the `+0x34/+0x38` arg use were **not re-isolated** in the
  6,751-insn pass. WithAngle arg semantics stay [U] (probe U-ANG).

## 6. Still-[U] register — fixed-seed probes, zero-mismatch rule

Common harness (never invent): pin `t_87f0f3c130b0`;
`randkey0=0, randkey1∈{1,12345}`; `W=H=320` (repeat 256/640 once);
`shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`,
`b_random_map=true`; fixed families/patterns bundle. Run port `generate()`
twice; diff named arrays/counts. **Terminate an item only on zero
mismatches across stated repeats; otherwise it stays [U].**

| ID | Item | Donor [O] | Why [U] | Fixed-seed comparison + termination |
|---|---|---|---|---|
| U-HF | per-pattern `HeightFieldScale/Min/Max/Offset/TerrainScale` concretes | offsets/defaults [O] §2; 3-section floats [O] X13 E1–E3 | remaining 677-section floats never byte-dumped here | Dump `pattern.lib` floats for all 680 sections; replay X26 19-vector harness at true `G=8+N` on `g_mnt_1/g_hil4` + `hil1/k_ravine_1`; **terminate when 19/19 `f32step` bits reproduce** (X26 §Vector). Never invent a Scale. |
| U-ANG | `minangle/maxangle` offsets + WithAngle `+0x34/+0x38` arg use | fork + 90.0/0.0 constants [O]; fnd_46 filter shape [D carried] | offsets/arg use not re-typed | Per-pattern record export + `+0x41==0/!=0` branch dump on fixed seed; **terminate when dumped angle floats reproduce accept/skip on `g_mnt_1` with zero mismatches**. Port keeps `minangle<=0 & maxangle>=90 → accept else accept-with-warning` stub. |
| U-S0 | `SmoothTerrain(x,−y,False,3)` kernel on bsmooth cells | call shape [O] (`generatemap.inc:591`) | kernel body native, undiscovered high VA | Keep `bsmooth_kernel=NULL/SKIP` + `bsmooth_pass=SKIPPED` telemetry (`terrain_donor_gen.gd:396-400,1320-1326`). **Terminate only on a byte-proven kernel dump reproducing the hook signature**; never substitute a blur. Comparison: `bsmooth_pass==SKIPPED` on all fixed seeds. |
| U-RND | `UseRndScale/MinScale/MaxScale` feed | `cmp [p+0x3c] @0x7563eb`, LCG `call 0x403a28 @0x7563fd` [O] | draw stream unmapped | Keep `random_scale_hook=NULL` + fixed-Scale fallback with `UseRndScale…TODO(D05/X01)` note (`:2760-2764`). **Terminate on an authorised-trace draw dump** showing the exact `rand(MinScale,MaxScale)` value per pattern. |
| U-ROW | file-row sign / rotated sub-cell rounding | row→`z`, row-major [O] (AXIS discriminator) | sign/rounding unproven | Keep `row_sign_hook`/`rotation_rounding_hook=NULL` = donor floor (`:2788-2798,2893-2914`). **Terminate when dumped `(tx,tz)` reproduce X26 vectors at true `G` with zero mismatches**. |
| U-CLAMP | global `setHeight` clamp (`sub_0059b934` → `sub_7551a8`) | stamp has no clamp [O] | setter unstudied | Keep `global_setter_clamp_hook=NULL` = no clamp (`:2822-2825`). **Terminate on a setter byte-dump** proving a ceiling/floor; until then never clamp to `[Min,Max]`. |
| U-X87 | true x87 80-bit result | `fstp tbyte [ebp-0x154] @0x7566b7` [O] | no 80-bit emulator | Port default `stamp_precision_model="f32_each_op"` (X26 contract) vs comparison `double_store_f32` (`:2837-2845`). **Terminate on an 80-bit replay** resolving the 1-ULP `REP-kr1-01/SMB-kr1-01` pair; 1-ULP diffs are not bugs until then. |
| U-TAIL | `.pattern` 24 B tail + weight + 13 B tail semantics | structure/invariants [O] §3 | no field proof | Keep tails unparsed (occupancy + height only). **Terminate on a typed field dump** (id/model/scale/pos) with zero mismatches; never map `id`→mesh. |
| U-OBJ | `pattern.lib Objects[]`→mesh index binding | 8-way `+0xa8…+0xc4` dispatch + `+0x83`-gated `sub_755578` fixups [O structure]; mesh names only in data [O] | binding engine-side | Keep `objects_missing` telemetry + opaque `mesh_key` (`:651-652,3101-3116`). **Terminate on a per-pattern `Objects[]` export diff** (counts/positions/scales) with zero mismatches. Instancer stays missing by design. |
| U-SMP | smooth post-pass mask gating + radial remap over all cells | gate window + `(Radius−Offset)/d` [O] | full-field run never runtime-exercised | Keep in-place `Factor` loop + 8-neighbour boundary as coded (`:2943-3008`). **Terminate when dumped `(tx,tz,radius,factor)` reproduce a fixed-seed height dump** with zero mismatches. |
| U-OCC | `PatternMask*` → occupancy byte at `0x756638` | gate [O] | flag semantics [U] | Keep WxH vertex-mask construction (`:2864-2890`, last row/column blocked per `0x7561d0-0x756220`). **Terminate on a both-masks bundle diff** with zero mismatches. |
| U-MAX | `HeightFieldMax` consumers outside stamp | 0/6,751 in stamp [O] | editor/brush paths unchecked | No port use of `Max` except decode/census. **Terminate on a named outside-stamp consumer cite**. |

## 7. File/line port change list — `terrain_donor_gen.gd` / `terrain_donor_mesh.gd` (NOT applied)

All line numbers as read. Additive/label-only except where marked KEEP.
No parity claim attaches to any row.

| # | File:line | Precise change (spec only) | Why / authority |
|---|---|---|---|
| R-1 | `terrain_donor_gen.gd:2803-2821` | **KEEP.** Preserve pivot `g=(g−Min)*Scale+Min` for `!rep_water`, `g*Scale` for `rep_water`; three setters `g+Offset` / `base_h+g+Offset` / `(base_h−h0)*TerrainScale+g+Offset; +h1` with two `getHeight` reads. | X26 authoritative table §2; X12 E5. |
| R-2 | `terrain_donor_gen.gd:344-352` | **KEEP** `F01_GRID_OFFSETS` (`hil1 968`, `g_hil4 1864`, `k_ravine_1 2798`, `plt2 2222`, `k_ravine_big_stone_1 8225`). Add comment: X13 `1000/1912/2866` are STALE (+8/+12/+17). | F01 §4.1; X26 E13/E14. |
| R-3 | `terrain_donor_gen.gd:314-343` | **KEEP** `STAMP_SMOOTH_PARAMS` 41-entry census as transcribed census. Never derive Radius/Factor/Offset by formula. | F02 census; X26 §Spec additions. |
| R-4 | `terrain_donor_gen.gd:396-400,1320-1326` | **KEEP** `bsmooth_kernel=NULL/SKIP` + `bsmooth_pass=SKIPPED` telemetry. Do not insert a blur. | U-S0 probe. |
| R-5 | `terrain_donor_gen.gd:402-405,2760-2764` | **KEEP** `random_scale_hook=NULL` + fixed-Scale fallback note. Never synthesise `rand(MinScale,MaxScale)`. | U-RND probe. |
| R-6 | `terrain_donor_gen.gd:379-394` | **KEEP** `row_sign_hook`/`rotation_rounding_hook`/`global_setter_clamp_hook=NULL`, `stamp_precision_model="f32_each_op"`, `stamp_smooth_buffer_mode="in_place"`. Double-buffer stays comparison-only. | U-ROW/U-CLAMP/U-X87; X26 P5/E8. |
| R-7 | `terrain_donor_gen.gd:2830-2834,2943-3008` | **KEEP** post-pass gated on `Stand && Smooth` independent of blend branch; in-place loop; hardcoded `/4.0 (@0x755ee4)`; 8-neighbour boundary (preserve observed right-double/left-omitted list `:2935-2936` as-is with cite). | X13 implication 2; X26 E8/E9. |
| R-8 | `terrain_donor_gen.gd:328` (comment) + `:784-792` telemetry | Extend `U-HF` note to name `g_mnt_1/g_hil4` 19/19 `f32step` termination (this report §6). No logic change. | Makes IMPL-PLACEMENT probe explicit. |
| R-9 | `terrain_donor_gen.gd:3232-3238`-area (object-scale note per DEC_U_placement P-PLACE-13) + `:3101-3116` | **KEEP** opaque stamp record + `objects_missing` flag; add winter-`leaftree`-delete branch name to the TODO so a future hook implements all three branches together. No synthesis. | U-OBJ probe; F08 §7.1. |
| R-10 | `terrain_donor_mesh.gd:84,262-337,743-772,1632-1648` | **NO STAMP CHANGE.** Keep `HEIGHT_SCALE=1.0`, corner-height mean labelled PORT SUBSTITUTE (`:1858`), `bind_height_grid` read-only contract. Relief amplitude comes only from `terrain_donor_gen.gd` height field; mesh must not apply `Scale/Min/Offset/TerrainScale` a second time. | Prevents double-application of §2 formula. |
| R-11 | everywhere else | **NO OTHER EDIT.** In particular: no `[Min,Max]` clamp in the stamp; no `Max` read; no tbyte→PI constant; no `G→grid` shift; no `Objects[]` synthesised members; no `fa/broad` invention. | X26 S1/S2/S6; U-MAX/U-TAIL/U-OBJ. |

## 8. Bottom line + open registers

- Blend math is **closed [O]** (§2 table); grid addressing is **closed [O]**
  at `G=8+N`; post-pass order is **closed [O]** as in-place.
- Open by design: U-HF (677-section floats), U-ANG (angle offsets/use),
  U-S0 (S0 kernel bytes), U-RND/U-ROW/U-CLAMP/U-X87 (feeds/precision),
  U-TAIL/U-OBJ (record/mesh semantics), U-SMP/U-OCC/U-MAX (gating/scope).
  Each has a fixed-seed zero-mismatch probe in §6; none may be filled with
  an invented scale, kernel, clamp, or mesh key.
- **No donor parity is claimed.** No donor frame, trace, or A/B exists;
  no code/shader/config/asset/test/git/Godot edit was performed.

*End of DEC_U_relief_stamps. Exactly one repo file written (this report).
Donor read-only; no binary executed/copied/committed. No parity claimed.*
