---
id: X37-GOLDEN-BLEND-VECTORS-V2
title: "X37 — golden relief-blend vectors regenerated at F01 grid offsets with X26's authoritative formula (25 exact-f32 vectors)"
agent: "worker X37 (verification wave, donor-first terrain swarm 2026-11-26)"
date: 2026-11-26
status: LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3\\data\\pattern\\{pattern.lib,hil1.pattern,g_hil4.pattern,k_ravine_1.pattern} — read-only 'rb' only; no donor binary executed, copied or committed"
rules: "READ-ONLY donor/repo; no code, shader, config, asset, test, git or Godot edit. Exactly ONE repo file written (this report). Golden vectors + scripts only in %TEMP%\\opencode\\blend_vectors_v2\\. No donor-parity claim."
verdict: "GOLDEN_V2_EMITTED__25_VECTORS__19_19_OLD_OUTPUTS_CHANGED_BY_STALE_G_ONLY__0_BY_X13_FORMULA_ERROR__TASK_LITERAL_STILL_REFUTED__IN_PLACE_POSTPASS__NO_PARITY_CLAIM"
parity_claim: false
---

# X37 — Golden blend test vectors v2 (F01 offsets + X26 formula)

## Executive summary

1. **[D]** 25 golden vectors were emitted outside the repo only, in
   `%TEMP%\opencode\blend_vectors_v2\`: 21 per-cell blend vectors (all three
   donor paths, min/max/first/last/centre boundaries, row/column transposition)
   and 4 in-place smooth-post-pass snapshots. JSON sha256
   `6425c17ba70d578481d90aed8cf3a9d1a15fcf6681c1412a26debd4f819e58b1`, CSV
   sha256 `7c5fe0f893196f8ccc8514446286186cfe3065241216565bc8cf8bd5e3e402ee`;
   both hashes are recorded in `x37_golden_blend_vectors.sha256`. No repo file
   other than this report was written.
2. **[O]** `g` inputs are now decoded from the F01-correct plane starts
   `G = 8 + (w−1)(h−1)` = **968 / 1864 / 2798** (`hil1`, `g_hil4`,
   `k_ravine_1`), *not* X13's stale 1000 / 1912 / 2866 (shift +8 / +12 / +17
   floats). Exact size closure holds 3/3 (`8+4wh+54(w−1)(h−1)` = 55,948 /
   108,020 / 162,260 B) and grid min/max are bit-exact against
   `pattern.lib` 3/3, exactly as F01 §4.1–§4.4 and X26 §Grid cross-check require.
3. **[D]** The golden column uses X26's authoritative branches verbatim:
   `ReplaceForWater: h = g*Scale + Offset`;
   `Replace: h = base_h + ((g−Min)*Scale + Min) + Offset`;
   Smooth: two `getHeight` reads with the `(g−Min)*Scale+Min` pivot; `Max`
   unused, no `[Min,Max]` clamp. Post-pass is **in-place read-after-write**
   with the hardcoded divisor `4.0` and `Factor` iterations (X26 E8).
4. **[D]** Fresh-implementation verification: a second, independent
   `numpy.float32` implementation reproduced **21/21** blend bits, **21/21**
   donor grid bits, **4/4** post-pass centre bits and full-grid hashes, and
   **19/19** X13 old expected bits when fed X13's stale `g`. Verdict PASS
   (`x37_verify_results.json`). Every generator self-check passed 3/3 passes
   after two implementation defects were found and fixed (§Method).
5. **[O]/[D]** **Old-vs-new:** all **19/19** X13-comparable blend outputs changed,
   and all **19/19** are attributable **solely to stale `g` inputs** — 0
   attributable to an error in X13's *expected* column, which already used D05
   F4. Four post-pass snapshots changed solely because their synthetic world
   patch was the shifted `g_hil4` plane. The stale **task/spec literal**
   (`Replace = base_h+g+Offset`, single-`h` Smooth) is still wrong: at the
   corrected inputs it disagrees with the golden result on 3/3 discriminator
   vectors. **No donor GPU A/B frame exists; no parity claim is made.**

---

## Evidence table

| # | Donor path:offset / evidence id | Class | Establishes |
|---:|---|---|---|
| E1 | `data\pattern\hil1.pattern:0x0000..0x0007` (`w=25,h=41`), float plane `0x03C8` = **968**; 55,948 B; sha256 `a55ea48086c9103a70e4f7c0635131b31ea6a56b76daaa830f221d5b699c9b19` | [O] | F01 `G=8+(w−1)(h−1)`; grid min `0x00000000`, max `0x40771F94` bit-exact vs config. |
| E2 | `data\pattern\g_hil4.pattern:0x0000..0x0007` (`w=33,h=59`), plane `0x0748` = **1864**; 108,020 B; sha256 `88a62740780631a18a75c7e48f175e963d6cf1e103a42762aea5d1045b5bf7ca` | [O] | Same closure; min `0xAAF3441C`, max `0x3FF55FDC`; mask bytes 0/1 only. |
| E3 | `data\pattern\k_ravine_1.pattern:0x0000..0x0007` (`w=46,h=63`), plane `0x0AEE` = **2798**; 162,260 B; sha256 `9a806a0595992c9acb9f780db038a4563d88b3bcd3ed0de0662c5626e4e1c841` | [O] | Same closure; min `0xC03DAC13`, max `0x4048F2D0`. |
| E4 | `data\pattern\pattern.lib` sha256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`; sections at byte 854,149 (`hil1`, lines 33081–34745), 9,458,091 (`g_hil4`, 366469–369365), 14,195,473 (`k_ravine_1`, 549555–555363) | [O] | Re-parsed this pass; 1-based line numbers and byte offsets for all cited flags are in the JSON `pattern_lib_citations` block. |
| E5 | `pattern.lib:854343` line 33090 (`hil1` `HeightFieldReplaceForWater=True`); `:854472` line 33094 (`HeightFieldScale=0.649999976158142` = `0x3F266666`); `:854933/854956` (`Min=0`, `Max=3.86130237579346`) | [O] | Donor flags/constants used by the regenerated vectors; `Replace=False` at `:854312`, `Smooth=False` at `:854577`. |
| E6 | `pattern.lib:9458287` line 366478 (`g_hil4` `ReplaceForWater=True`), `:9458416` (`Scale=1`), `:9458861/9458904` (`Min=-4.3213e-13`, `Max=1.91699`), `:9458505/9458534/9458566/9458598` (`Smooth=True`, radius 3, factor 4, offset 2) | [O] | Post-pass is active on the **ReplaceForWater** blend branch (gated by `Stand && Smooth`, not by blend path). |
| E7 | `pattern.lib:14195673` line 549564 (`k_ravine_1` `ReplaceForWater=True`), `:14195802` (`Scale=1`), `:14196248/14196285` (`Min=-2.963627576828`, `Max=3.139820098877`), `:14196323` (`Offset=0`) | [O] | Negative `Min` pivot / cancellation vectors; `Min/Max` still bit-exact at F01 G. |
| E8 | X26 `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237` (Deep pseudocode, lines 297–303 pivot, 306–330 branches) + `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5` (6,751 instructions) | [O]+[D] | Authoritative `g2=(g−Min)*Scale+Min` at VA `0x756607/60d/610/616/619`; final RFW `0x756651`, Replace `0x756674/677/67d`, Smooth `0x7566a5/6ab/6ae/6b4`, `fstp tbyte 0x7566b7`. |
| E9 | X26 `ev_aba9f17d8893279af422551fb642b74fdeb4d08d06092fe05cf191a59cb33253` + `ev_2e5b179ca47a7a27c660da5af73e52fcae37089f43300ae1d5317d8adc126efe` (`sub_755db4`, 117 instructions) | [O] | Four live `getHeight` reads `0x755e6a/7a/8a/9a`, `fdiv [0x755ee4]` at `0x755eaf`, one `setHeight` at `0x755ec2` on the same field → **in-place** post-pass, divisor 4.0. |
| E10 | X26 E13/E14 + F01 §4.1/§4.2/§4.4 (`reports/F01_pattern_format.md:43-52,123-168,195-235`) | [O]+[D] | `G=8+N` closure 710/710; X13's `1000/1912/2866` are shifted; min/max cannot discriminate because of long zero borders. |
| E11 | `%TEMP%\opencode\blend_vectors\x13_blend_vectors.json`, sha256 `82945e4ac7602b5a67a2b62e232dc4ae5cbf3ee8237532c5002a01f7053bcb8a` (matches X13 E1) | [O] | Read-only source of the 19 old vectors, declared `(z,x)` cells, flag/input bits and old expected bits. |
| E12 | `%TEMP%\opencode\blend_vectors_v2\x37_generate.py`, `x37_verify.py`, `x37_golden_blend_vectors.{json,csv,sha256}`, `x37_verify_results.json`, `x37_task_diff.py`, `x37_debug_post.py` | [D] | Temp-only scripts/outputs; no repo artefact except this report. |

---

## Method — multiple passes, no silent skip

All donor reads used Python `open(...,'rb')` / `struct` / `numpy` only. The
generator never imported X13's `build_vectors.py`; X13's JSON was read only as
the comparison baseline. Precision contract: **f32 at each donor store**
(X26's `f32step` model, I07 action 3), with a parallel double-intermediate
column emitted for the unresolved x87 80-bit path.

| Pass | Instrument | Result / contradiction | Acceptance |
|---|---|---|---|
| P1 | Re-parse `pattern.lib` sections by CRLF byte offsets; decode `.pattern` at F01 G | 3/3 size closure, 3/3 min/max bit-exact, mask bytes 0/1 | **Accepted**: grid addressing now donor-faithful. |
| P2 | Replay each of the 17 distinct declared X13 cells at stale G | **17/17** X13 `g_bits` reproduce in the shifted window | **Accepted**: proves old-vs-new diff is a pure input shift, not a different cell. |
| P3 | Fresh Python formula, all 19 X13 vectors fed their own stale `g` bits | **19/19** X13 `d05_f32step_bits` reproduced | **Accepted**: X13's *expected* column contains no formula error. |
| P4 | Same formula at F01-correct cells; all flags/base_h/h0/h1 held bit-identical to X13 | 19/19 outputs changed; every one explained by `replay_old_g == old_expected` | **Accepted**: cause attribution = stale g only. |
| P5 | First post-pass implementation stored mutable `H` by reference in `snaps[it]` | **Mismatch**: all four old-grid snapshots came out as iteration 4 (`0x3E1EB7C7`) | **Rejected and fixed**: copy each snapshot (`[list(r) for r in H]`); re-run gave 4/4 X13 in-place bits at stale G. |
| P6 | Independent `numpy.float32` verifier on post-pass (f32 sum after each add) | **Mismatch**: iter1 `0x3FE40CFF` vs golden `0x3FE40CFE`, all 4 snapshot hashes differed | **Rejected and fixed**: donor kernel adds in extended registers and stores once at `setHeight`; verifier now accumulates in double then stores f32 → **4/4 bits + 4/4 hashes PASS**. Residual 1-ULP f32-sum variant recorded, not averaged. |
| P7 | Independent verifier over all emitted vectors | 21/21 blend, 21/21 grid, 4/4 post-pass, 19/19 old replay; 1 vector (`SMB-kr1-03`) f32step vs double differ by 1 ULP | **Accepted PASS**; ULP difference registered as unresolved x87, not a bug. |
| P8 | Task/spec literal formula at corrected inputs, 3 discriminator vectors | Golden vs literal: `0x3FBFEA0C`/`0x3FCC754F`, `0x3FF69F19`/`0x403DB22D`, `0x3FB8704F`/`0x3EAE8E08` | **Accepted**: literal still refuted independently of the stale grid. |
| P9 | Spatial discriminator at X13's original cells `(1,0)`/`(0,1)` | Both are `0x00000000` at F01 G — degenerate | **Rejected as a gate**; added `AXIS2-kr1-z1x0 (34,13)` / `AXIS2-kr1-z0x1 (33,14)` with unequal nonzero values `0x401E3A86` / `0xBFBD063A`. |

Three ordinary script defects (`frombits` accepting int, two CSV column keys)
were also corrected and the full generation re-run; no donor interpretation
changed. **No parity claim at any pass.**

---

## Golden vector table

All values are 8-hex-digit IEEE-754 float32 bit patterns. `D` = donor flags,
`S` = synthetic flag override (`PORT APPROXIMATION`: no donor pattern exercises
that branch — all three patterns have `Replace=False`). Golden = `f32step`.
`Double` = double-intermediate column (informational). "Old" = X13 expected
`d05_f32step` for the same ID and declared cell.

| ID | Path | Src | (z,x) | `g` bits (v2) | **Golden f32step** | Double | X13 old expected | Cause |
|---|---|---|---|---|---|---|---|---|
| RVW-hil1-01 | RFW | D | 0,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0x3B11D573` | stale g |
| RVW-hil1-02 | RFW | D | 22,1 | `0x3E8F5C29` | `0x3E3A5E35` | `0x3E3A5E35` | `0x4020A153` | stale g |
| RVW-hil1-03 | RFW | D | 40,24 | `0x00000000` | `0x00000000` | `0x00000000` | `0x0000008E` | stale g |
| RVW-g_hil4-01 | RFW | D | 28,4 | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | `0x3FF55FDC` | stale g |
| RVW-g_hil4-02 | RFW | D | 29,16 | `0x3FEECCDE` | `0x3FEECCDE` | `0x3FEECCDE` | `0x3E61587D` | stale g |
| RVW-k_ravine_1-01 | RFW | D | 13,4 | `0xB1A736BB` | `0xB1A736BB` | `0xB1A736BB` | `0xC03DAC13` | stale g |
| RVW-k_ravine_1-02 | RFW | D | 48,1 | `0x00000000` | `0x00000000` | `0x00000000` | `0x4048F2D0` | stale g |
| RVW-k_ravine_1-03 | RFW | D | 0,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0xB9CE03CB` | stale g |
| REP-hil1-01 | Replace | S | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` | `0x3FBFEA0C` | `0x4074F076` | stale g |
| REP-kr1-01 | Replace | S | 13,4 | `0xB1A736BB` | `0x403DB22D` | `0x403DB22D` | `0x39C34000` | stale g |
| REP-kr1-02 | Replace | S | 48,1 | `0x00000000` | `0x3FF69F19` | `0x3FF69F19` | `0x407DED61` | stale g |
| REP-kr1-03 | Replace | S | 31,23 | `0xBF79F586` | `0x404F34CC` | `0x404F34CC` | `0x4086D916` | stale g |
| SMB-hil1-01 | SmoothBlend | S | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` | `0x3FBFEA0C` | `0x4074F076` | stale g |
| SMB-kr1-01 | SmoothBlend | S | 13,4 | `0xB1A736BB` | `0x403DB22D` | `0x403DB22D` | `0x39C34000` | stale g |
| SMB-ghil4-01 | SmoothBlend | S | 28,4 | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | `0x3FF55FDC` | stale g |
| SMB-kr1-02 | SmoothBlend | S | 31,23 | `0xBF79F586` | `0x3FB8704F` | `0x3FB8704F` | `0x401AB589` | stale g |
| SMB-kr1-03 | SmoothBlend | S | 48,1 | `0x00000000` | `0x3F6E978E` | `0x3F6E978D` | `0x40824C5B` | stale g (+1 ULP precision) |
| AXIS-kr1-z1x0 | RFW | D | 1,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0xBAAC7432` | stale g (cell now degenerate) |
| AXIS-kr1-z0x1 | RFW | D | 0,1 | `0x00000000` | `0x00000000` | `0x00000000` | `0xBA9D9F10` | stale g (cell now degenerate) |
| AXIS2-kr1-z1x0 | RFW | D | 34,13 | `0x401E3A86` | `0x401E3A86` | `0x401E3A86` | — | new discriminator |
| AXIS2-kr1-z0x1 | RFW | D | 33,14 | `0xBFBD063A` | `0xBFBD063A` | `0xBFBD063A` | — | new discriminator |

Synthetic inputs are bit-identical to X13: `base_h` hill `0x3FA89E45`, plateau
`0x403DB22D`; water bed `h0/h1` `0xBF8CCCCD`; synthetic `Offset=1.25`
(`0x3FA00000`) on `REP-kr1-03`, `Scale=0.65` on `REP-kr1-02`,
`TerrainScale=0.5` on `SMB-kr1-03`. Per X26's caveat all were decoded from
their **stored bit patterns**, not decimal literals.

### Smooth post-pass snapshots [D]

Centre `(x=16,z=29)`, radius 3, `SmoothOffset=2` → remap `(tx,tz)=(17,29)`;
`Factor=4`; divisor hardcoded `4.0f` (`cossacks.exe` VA `0x755ee4`). Patch is
the F01-correct `g_hil4` grid used as a **synthetic** world-height field
(donor world field UNVERIFIED). Golden = in-place read-after-write; the
double-buffer column is shown only to demonstrate that update order matters.

| ID | Iter | **Golden in-place bits** | Full-grid snapshot sha256 | f32-sum variant | Double-buffer (comparison) | X13 old in-place |
|---|---:|---|---|---|---|---|
| SMOOTH-PASS-ghil4-iter1 | 1 | `0x3FE40CFE` | `18ad717d4c46a4129817209c000955e88649cf248d6a56e8da3e06b1b04afac2` | `0x3FE40CFF` | `0x3FE82B6D` | `0x3E0E900E` |
| SMOOTH-PASS-ghil4-iter2 | 2 | `0x3FDE3920` | `55621dbb6c3c6ac421907cfa85427f93231a8172fa843a975e9076b28661398c` | `0x3FDE3920` | `0x3FE4F7F1` | `0x3E1691C8` |
| SMOOTH-PASS-ghil4-iter3 | 3 | `0x3FD8DCD2` | `39bdf96dbf6729bba2152b018a5787a495e5c59e2a0f60dbf3766a7357f6c6bc` | `0x3FD8DCD2` | `0x3FE13DCF` | `0x3E1AE70E` |
| SMOOTH-PASS-ghil4-iter4 | 4 | `0x3FD464FE` | `158ea768c5b5e454000e61ee16b721d401843074c2e4b6b91b034355dce05289` | `0x3FD464FE` | `0x3FDDE998` | `0x3E1EB7C7` |

The JSON also stores a 5×5 bit neighbourhood around `(17,29)` per iteration,
so a transposed or off-by-one kernel is detectable without the full grid.

---

## Old-vs-new diff — quantified attribution

| Category | Count | Evidence / reasoning |
|---|---:|---|
| X13-comparable blend vectors | 19 | Same IDs, same declared `(z,x)`, same flags and `base_h/h0/h1` bits (P2). |
| Outputs changed | **19/19** | Every `g_old_bits` differs from `g_new_bits`; every golden bit differs from X13 expected. |
| Caused by **stale g input only** | **19/19** | For each vector, `blend(old_g)` reproduced X13's expected f32step bits exactly (P3). Zero residual discrepancies. |
| Caused by formula error in X13's expected column | **0/19** | X13's expected column already implemented D05 F4; the formula defect lives in the *circulated task/spec literal*, not in X13's golden numbers. |
| Post-pass snapshots changed | **4/4** | Re-running our implementation at stale G reproduced X13's in-place column 4/4 (P5); the new values come from the corrected `g_hil4` patch only. |
| New spatial discriminators | 2 | `AXIS2-*`; old AXIS cells `(1,0)`/`(0,1)` are both zero at F01 G and can no longer gate transposition. |
| f32step vs double-intermediate divergence | 1/21 | `SMB-kr1-03`: `0x3F6E978E` vs `0x3F6E978D` (1 ULP, cancellation); X13 recorded the same 1-ULP class on its old input. |
| Stale task literal still wrong at **corrected** inputs | 3/3 discriminators | `REP-hil1-01` golden `0x3FBFEA0C` vs literal `0x3FCC754F`; `REP-kr1-02` `0x3FF69F19` vs `0x403DB22D`; `SMB-kr1-02` `0x3FB8704F` vs `0x3EAE8E08`. |

Selected comparisons (independent confirmation of X26 §Vector verification
corrected-expected column): `RVW-hil1-02` → `0x3E3A5E35`,
`RVW-g_hil4-01` → `0x3D53C32A`, `RVW-k_ravine_1-02` → `0x00000000`,
`REP-hil1-01` → `0x3FBFEA0C`, `REP-kr1-02` → `0x3FF69F19` — all five match
X26's regenerated values bit-for-bit, obtained here by a separate script.

**Conclusion for COORD:** retire X13's JSON as a *spatial* gate; keep it only
as a historical formula harness. No reported change requires a formula
revision beyond what X26 already published.

---

## Paste-ready replacement text for `spec/04_PATTERN_STAMPING.md` §7

Replace the current §7 block (lines 80–82, the duplicate "Cross-check queue
(updated)") with the following. §8 already retains that queue, so nothing is
lost. §6's third row should additionally be corrected to the two-read Smooth
form shown here (X26 "Implications" table).

```markdown
## 7. Golden relief-blend vectors (X37 v2) — I07/I07-QA contract

**PORT APPROXIMATION / no donor parity claim.** These are numeric
input→output contracts decoded from donor bytes and donor CODE; no donor GPU
A/B frame exists.

### 7.1 Grid addressing [O]

Decode the height plane at `G = 8 + (w−1)*(h−1)` (F01 §4.1–§4.4, 710/710 size
closure). For the three vector patterns: `hil1` G=968, `g_hil4` G=1864,
`k_ravine_1` G=2798. X13's 1000/1912/2866 are shifted by +8/+12/+17 floats
and are **superseded**; min/max agreement alone cannot discriminate.

### 7.2 Authoritative stamp branches [O] (X26 E2/E3/E5/E6)

| Path | Formula (f32 at each store) |
|---|---|
| `ReplaceForWater=true` | `h_new = (g*Scale) + Offset` — `0x75661f..625`, `0x756651`, setter `0x756664` |
| `Replace=true` (RFW false) | `h_new = base_h + ((g−Min)*Scale + Min) + Offset` — pivot `0x756607..619`, combine `0x756674/677/67d`, setter `0x756690` |
| Smooth blend (RFW false, Replace false) | `h0=getHeight(c,r)` `0x7566a0`; `t=(base_h−h0)*TerrainScale + ((g−Min)*Scale+Min) + Offset` `0x7566a5/6ab/6ae/6b4` (80-bit spill `0x7566b7`); `h1=getHeight(c,r)` `0x7566c7`; `h_new=t+h1` `0x7566d2`, setter `0x7566e4` |
| all paths | `if (occupancy[z][x] != 0) skip` (`0x756638`); **no `[Min,Max]` clamp**; `Max` (+`0x60`) is never read (0/6,751 operands) |

`Min` is a scale pivot, not a bound. Collapsing Smooth to a single `h` read
is `PORT APPROXIMATION`. All three target patterns have `ReplaceForWater=True`,
`Replace=False`; only `g_hil4` has `Smooth=True`.

### 7.3 Post-pass [O] (X26 E8/E9)

Gated by `Stand && Smooth` **independent of the blend branch** (so `g_hil4`
gets it on the RFW branch): 8-neighbour mask test, radial remap
`(Radius−Offset)/d`, `Factor` iterations of the 4-neighbour mean divided by
hardcoded `4.0f` (`0x755ee4`). Update is **in-place read-after-write** on the
same world field (`getHeight` ×4 at `0x755e6a/7a/8a/9a`, one `setHeight` at
`0x755ec2`); double-buffering is `PORT APPROXIMATION`.

### 7.4 Golden vectors (exact f32 bits, `f32step` contract)

Full JSON/CSV + sha256: `%TEMP%\opencode\blend_vectors_v2\`
(`x37_golden_blend_vectors.json` sha256
`6425c17ba70d578481d90aed8cf3a9d1a15fcf6681c1412a26debd4f819e58b1`).
Replace/smooth-branch vectors use synthetic flag overrides — `PORT
APPROXIMATION`, not donor incidence.

| ID | Path | (z,x) | `g` bits | Golden bits |
|---|---|---|---|---|
| RVW-hil1-01 | RFW | 0,0 | `0x00000000` | `0x00000000` |
| RVW-hil1-02 | RFW | 22,1 | `0x3E8F5C29` | `0x3E3A5E35` |
| RVW-hil1-03 | RFW | 40,24 | `0x00000000` | `0x00000000` |
| RVW-g_hil4-01 | RFW | 28,4 | `0x3D53C32A` | `0x3D53C32A` |
| RVW-g_hil4-02 | RFW | 29,16 | `0x3FEECCDE` | `0x3FEECCDE` |
| RVW-k_ravine_1-01 | RFW | 13,4 | `0xB1A736BB` | `0xB1A736BB` |
| RVW-k_ravine_1-02 | RFW | 48,1 | `0x00000000` | `0x00000000` |
| RVW-k_ravine_1-03 | RFW | 0,0 | `0x00000000` | `0x00000000` |
| AXIS-kr1-z1x0 | RFW | 1,0 | `0x00000000` | `0x00000000` |
| AXIS-kr1-z0x1 | RFW | 0,1 | `0x00000000` | `0x00000000` |
| AXIS2-kr1-z1x0 | RFW | 34,13 | `0x401E3A86` | `0x401E3A86` |
| AXIS2-kr1-z0x1 | RFW | 33,14 | `0xBFBD063A` | `0xBFBD063A` |
| REP-hil1-01 | Replace | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` |
| REP-kr1-01 | Replace | 13,4 | `0xB1A736BB` | `0x403DB22D` |
| REP-kr1-02 | Replace | 48,1 | `0x00000000` | `0x3FF69F19` |
| REP-kr1-03 | Replace | 31,23 | `0xBF79F586` | `0x404F34CC` |
| SMB-hil1-01 | SmoothBlend | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` |
| SMB-kr1-01 | SmoothBlend | 13,4 | `0xB1A736BB` | `0x403DB22D` |
| SMB-ghil4-01 | SmoothBlend | 28,4 | `0x3D53C32A` | `0x3D53C32A` |
| SMB-kr1-02 | SmoothBlend | 31,23 | `0xBF79F586` | `0x3FB8704F` |
| SMB-kr1-03 | SmoothBlend | 48,1 | `0x00000000` | `0x3F6E978E` |

### 7.5 I12 assertions

- **Hard Class-A bit-exact:** the 12 donor-flag RFW vectors (first ten rows
  above plus both `AXIS2-*`) through a zero-argument debug hook taking
  `(g_bits, flags, base_h_bits, h0_bits, h1_bits)` and returning the output f32
  bits. This locks all three grid offsets and the row-major spatial map.
- **Advisory, bit-exact when the hook advertises the branch:** the 9 synthetic
  `REP-*`/`SMB-*` rows. Record mismatches; do not turn the atom red for a
  branch with 0/680 donor incidence until such a pattern is found.
- **Hard structural:** post-pass is in-place, uses divisor `4.0`, runs
  `Factor=4` times, gates on `Stand && Smooth`, and applies the 8-neighbour
  mask test. The four snapshot bit patterns are advisory because the world
  patch is synthetic.
- Keep `parity.status = "UNVERIFIED"`; no threshold lowered, no gate deleted.
```

---

## Vectors I12 should assert (direct instruction)

Owner file for this ticket is `variant3d/tests/t_terrain_donor.gd`
(`IMPLEMENTATION_PLAN.md:20`, V11 E3/N15). At the current read the atom only
*probes* hooks at `:89-90,603-640,907-926` and records them
`ADVISORY_UNVERIFIED`; **no bit vector is asserted today**. Recommended
assertions, in priority order:

1. **Decoder pre-condition (Class A):** emitted grid start equals
   968 / 1864 / 2798 for `hil1` / `g_hil4` / `k_ravine_1`, and grid min/max
   equal the bit patterns in E1–E3. This is the exact failure X13's vectors
   hid.
2. **Hook contract (Class A):** a zero-argument `blend_vectors` hook (names
   already in `VECTOR_HOOK_NAMES`, `t_terrain_donor.gd:89-90`) that replays
   `(g_bits, flags, base_h_bits, h0_bits, h1_bits)` → f32 output bits. Without
   it the atom must keep reporting `HOOK_MISSING`, never PASS.
3. **Hard bit-exact (Class A):** the 12 donor-flag rows listed in §7.5,
   compared against the JSON `f32step_bits` column. Use the `AXIS2` pair as
   the spatial gate; the original `AXIS-*` pair is degenerate at the correct
   offset.
4. **Advisory bit-exact (Class B):** the 9 synthetic-branch rows; a mismatch
   is recorded with label `PORT APPROXIMATION`, not promoted to a donor-parity
   finding.
5. **Structural post-pass (Class A) + advisory snapshots (Class B):** in-place
   update, divisor 4.0, Factor 4, 8-neighbour gate; snapshot bits and hashes
   advisory only (synthetic world patch).
6. **Do not assert** the `double_intermediate_bits` column as golden; it is a
   comparison model. A 1-ULP miss (`SMB-kr1-03`) is unresolved x87, not a bug.
   Keep `parity.status = "UNVERIFIED"`, `selftest 29/29`, `uitest 17/17`,
   `t_render_mode`, `assert_clean CLEAN`, `app/**` byte-identical.

No test file was edited by X37.

---

## UNVERIFIED register

| ID | Claim | Status / passes attempted |
|---|---|---|
| U1 | True x87 80-bit result (Smooth `t` spilled `tbyte` at `0x7566b7`) | **[U]** P6/P7: double-accumulate verifier agrees 21/21 on the chosen golden column, but one vector diverges 1 ULP between f32step and double; no 80-bit emulator attempted. |
| U2 | World height field / `base_h`, `h0`, `h1` | **[U]** `sub_810498` call site known (X26 E4); actual world field not recovered. All such inputs are constructed test values decoded from X13 bit patterns. |
| U3 | Row-sign flip (file row → centred world y) | **[U]** inherited D05 U1 / X26 U1; row-major `grid[z][x]` is confirmed, sign is not. `PORT APPROXIMATION`. |
| U4 | Global `setHeight` clamp (`sub_0059b934`) | **[U]** zero `+0x60` reads inside `sub_755f30` (X26 E7) do not exclude a setter clamp. |
| U5 | Rotation rounding / jitter | **[U]** all vectors use donor `RotationAngle=0`; rotated block `0x75646e..0x7565d5` not exercised. |
| U6 | Post-pass full radial remap + 8-neighbour gate at runtime | **[U]** kernel order settled (X26 E8/E9), but snapshots use one remapped window on a synthetic patch; gate read from opcodes, not runtime-exercised. |
| U7 | Donor incidence of `Replace=true`, `TerrainScale≠1`, `Offset≠0` | **[U]** 0/680 donor patterns with `Replace=true` (F02/X05), so 9 vectors use synthetic flags — labelled `PORT APPROXIMATION`. |
| U8 | Occupancy mask semantics at `0x756638` | **[U]** gate confirmed; which mask bits are donor-meaningful remains open (F01 §9). |
| U9 | Which stamp call site serves skirmish generation | **[U]** inherited X12/X26; not attributed to a game phase. |
| U10 | Visual parity with donor | **[U]** no donor GPU A/B frame. **No parity claim.** |

---

## Open questions

1. Will COORD promote the 12 donor-flag rows to hard I12 assertions, or keep
   every vector advisory until the debug hook exists? X37 recommends the
   split in §7.5.
2. Can an x87 80-bit emulator settle `SMB-kr1-03`'s 1-ULP difference and the
   Smooth `tbyte` spill, so the golden column can be upgraded from f32step?
3. Is any donor pattern outside the 680 audited sections `Replace=true` or
   `Offset≠0`, so the 9 synthetic rows can be replaced with donor-flag ones?
4. Should the decoder expose its computed `G` in telemetry so I12 can assert
   the spatial pre-condition without a source-level constant?
5. Once the corrected `AXIS2` pair is wired, can `AXIS-*` be retired entirely,
   or kept only as a historical zero/zero boundary case?
6. Does the post-pass gate apply its 8-neighbour mask test before or after the
   radial remap when rotation is nonzero (X26 open question 6)?

---

## Five-line summary

1. Emitted 25 golden vectors (21 blend + 4 post-pass) at F01 offsets 968/1864/2798 with X26's authoritative formula; JSON and CSV sha256 recorded in temp only.
2. Independent numpy.float32 replay passed 21/21 blend bits, 21/21 grid bits, 4/4 post-pass snapshots/hashes and 19/19 old-vector replays.
3. All 19/19 X13-comparable outputs changed solely from stale `g`; 0 from an error in X13's expected column; the stale spec/task literal remains refuted at corrected inputs (3/3).
4. Post-pass is in-place with divisor 4.0; double-buffer and f32-sum variants are comparison-only, and X13's original AXIS cells are degenerate at the true offset.
5. Paste-ready §04 §7 text and the exact I12 assertion split are supplied; donor read-only, one repo file written, no Godot job, no donor parity claim.

*End of X37 report. Exactly one repository file written. Donor bytes read only; no donor binary executed/copied; no source, shader, config, asset, test, git or Godot change; artifacts and scripts in `%TEMP%\opencode\blend_vectors_v2\` only; no donor visual parity claimed.*
