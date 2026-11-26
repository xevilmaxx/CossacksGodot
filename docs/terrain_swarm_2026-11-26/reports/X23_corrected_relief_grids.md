---
id: X23
ticket: "TERRAIN-SWARM-2026-11-26 / X23 (DONOR-FIRST verification, 30-agent swarm)"
title: "X23 — independent byte-level verification of F01's five corrected 8x10 relief grids; stale claim register and exact replacements for Z04 Part B / X13"
agent: "worker X23 (verification subagent), reporting to COORD"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__DONOR_READ_ONLY__NO_REPO_SOURCE_NO_GIT_NO_GODOT
scope: "Exactly one repo file written: this report. Canonical JSON tables written only to C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\relief_grids\\ (outside the repo). Donor at C:\\Games\\Cossacks 3 opened read-only ('rb'); no donor binary executed or copied; no source/asset/config/test/shader/queue/git edit; no Godot job."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Every grid is derived numeric data; a port that stamps from it is PORT APPROXIMATION. No donor parity claim."
sources_read:
  - "docs/terrain_swarm_2026-11-26/CHARTER.md"
  - "docs/terrain_swarm_2026-11-26/SWARM_BOARD.md"
  - "docs/terrain_swarm_2026-11-26/reports/F01_pattern_format.md (corrected 8x10 tables §4.10)"
  - "docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md (actual path under docs/.../spec/)"
  - "docs/terrain_swarm_2026-11-26/reports/X13_blend_test_vectors.md + its temp JSON"
  - "docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md (§3 offsets, Appendix A)"
  - "docs/terrain_swarm_2026-11-25/reports/Z04_height_only_design.md (Part B §3.2)"
  - "docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md (§3.2, Tier 1)"
outputs_outside_repo:
  - "relief_grids_canonical.json sha256=1895f20abaf506f117deca8eb2ac38771cf364cad93c014778a912c97ef2112c"
  - "x23_full_results.json sha256=e10053e096c58097213d6bf41710fe4db968d420f8af28fbf34593c2a2fbdcc4"
  - "x23_pass2_results.json sha256=c287c051555fd67fe78e24f44e5ef9513311d27f2b18b05666150c86c9a77480"
  - "x23_pass3_results.json sha256=e1a00b9bbeea826e39b4c5d134ad483aa8f5c98a22d2a1444676754ebe1ac0cb"
  - "x23_pass4_results.json sha256=477814fac1c28c5705c34de4012db5f468b783eca917c91d22c690a18854c1e3"
verdict: "F01_CONFIRMED_5_OF_5__OLD_DPATTERN_TABLES_REPRODUCED_AT_SHIFTED_WINDOWS__X13_19_OF_19_VECTORS_STALE__NO_PARITY_CLAIM"
---

# X23 — corrected relief grids, independently verified

## 0. Mandate and label key

Verify F01's five corrected 8×10 relief tables against raw donor bytes by manual
`struct` unpack, emit canonical JSON, quantify the old-vs-new shift, and hand
COORD exact replacement text for every now-stale §04/Z04/X13 claim. Multiple
passes were run on every mismatch (§3); no grid value was guessed.

Labels: **[O]** observed literal byte/line, **[D]** derived arithmetic, **[I]**
inference, **[U]** UNVERIFIED. Any port use is **PORT APPROXIMATION**.
**No donor parity claim.**

---

## 1. Executive summary

1. **[O]+[D] F01 is confirmed, not refuted.** All five corrected 8×10 tables in
   F01 §4.10 reproduce bit-for-bit at 3 dp from independent `struct.unpack_from`
   decoding at `G = 8 + (w−1)*(h−1)`. 5/5 file sha256s and 5/5 `pattern.lib`
   `HeightFieldMin/Max` float32-bit-exact matches are pinned (§4).
2. **[D] The one apparent mismatch was resolved in F01's favour after four
   passes.** `hil1` cell `(j=4,i=0)`: F01 prints `0.220`, a Python-double
   accumulator gives `0.221`. Re-running with `numpy.mean(dtype='<f4')` (the
   accumulator F01 §3 declares) returns `0.220499992371…` → `0.220` and
   reproduces **all 400 published cells** across the five tables. Exact mean is
   `0.220500004292…`. This is accumulator rounding, **not** a grid-value error.
3. **[D] The old DPATTERN-01 tables are exact block means of shifted windows.**
   Decoding at the old offsets `2866 / 2266 / 1000 / 1912 / 8225` reproduces
   DPATTERN Appendix A1–A4 with zero deviation. Shifts are +68/+44/+32/+48/+0 B
   (= +17/+11/+8/+12/+0 float32 columns). Mean absolute cell error old-vs-new
   is 1.154 / 1.044 / 0.754 / 0.521 / 0.000; 63–73 of 80 cells differ >0.05 (§5).
4. **[D] X13's 19 blend vectors are all stale.** Every published `g_bits`
   equals the value at the *shifted* offset (19/19) and none equals the value at
   the corrected offset. Replacement `g` bits and recomputed D05-d / D05-f /
   task-literal outputs are given in §6 S5, with a harness self-check that
   reproduces all 19 published outputs exactly from published bits + donor flags
   before recomputing. The `AXIS` transposition discriminator is degenerate at
   the true offset (both 0x00000000) and is replaced in §6 S6; the four smooth
   snapshots are replaced in §6 S7.
5. **[U] Nothing here is a parity claim.** The grid boundary `G=8+N` is now
   structurally derived (710/710 size closure, F01 E4) but no loader struct/RTTI
   names the fields; row-sign flip, engine blend, x87 precision and post-pass
   update order remain UNVERIFIED (§8).

---

## 2. Evidence table

| # | Donor path : offset / line | Class | What it establishes |
|---:|---|---|---|
| E1 | `data\pattern\<name>.pattern:0x0000-0x0007` | [O] | `struct.unpack_from('<2i')` gives `(w,h)`: `k_ravine_1` 46×63, `plt2` 42×55, `hil1` 25×41, `g_hil4` 33×59, `k_ravine_big_stone_1` 84×100. |
| E2 | same files, `0x0008 .. 0x0008+N−1` | [O]+[D] | Mask is `N=(w−1)(h−1)` bytes; `G=8+N` = 2798 / 2222 / 968 / 1864 / 8225. `filesize = 8+4wh+54N` closes exactly for all five (162260/128804/55948/108020/477326 B). |
| E3 | `data\pattern\<name>.pattern:G .. G+4wh−1` | [O] | `struct.unpack_from('<%df')` and a separate `raw[G:G+4wh]` slice decode are bit-identical for all `wh` floats (2898/2310/1025/1947/8400). |
| E4 | `pattern.lib:549585-549586` (bytes 14,196,248 / 14,196,285) | [O] | `k_ravine_1` Min `−2.963627576828` / Max `3.13982009887695` = `0xC03DAC13`/`0x4048F2D0`; grid extrema match bit-exactly. |
| E5 | `pattern.lib:6805-6806` (bytes 173,669 / 173,710) | [O] | `plt2` Min `−0.0732548981904984` / Max `3.61341166496277` = `0xBD9606AA`/`0x40674223`; bit-exact. |
| E6 | `pattern.lib:33111-33112` (bytes 854,933 / 854,956) | [O] | `hil1` Min `0` / Max `3.86130237579346` = `0x00000000`/`0x40771F94`; bit-exact. |
| E7 | `pattern.lib:366499-366500` (bytes 9,458,861 / 9,458,904) | [O] | `g_hil4` Min `−4.32127315701247E-13` / Max `1.91698789596558` = `0xAAF3441C`/`0x3FF55FDC`; bit-exact. |
| E8 | `pattern.lib:730045-730046` (bytes 18,877,479 / 18,877,518) | [O] | `k_ravine_big_stone_1` Min `−2.96362733840942` / Max `0.173864871263504` = `0xC03DAC12`/`0x3E3209A2`; bit-exact. |
| E9 | `docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md:602-652` (Appendix A1–A4) | [D] | Published old tables reproduce with **zero** deviation at the old offsets; F01 corrected tables reproduce with **zero** deviation at `G=8+N` using a float32 accumulator (§3 P6/P9, P-A). |
| E10 | same donor files, `±320 B` scan around `G` | [D] | Min/max alone admit 147 / 161 / 161 / 108 / 83 matching byte starts respectively — including every old DPATTERN offset. This is *why* the old tables are shifted; it is not evidence for a different grid. |
| E11 | `C:\...\Temp\opencode\blend_vectors\x13_blend_vectors.json`, `grid_byte` fields | [D] | X13 used `G=1000 / 1912 / 2866`; 19/19 published `g_bits` match those shifted windows, 19/19 differ at the corrected offsets. |
| E12 | `hil1.pattern:968+4*(4*w+0) .. +40 B` | [D] | `hil1` cell `(4,0)` exact mean `0.220500004292…`; float32 accumulator → `0.220` (F01), double → `0.221`. Verified with `math.fsum`, reversed sum and `numpy` f32/f64. |

---

## 3. Method — multiple passes on every anomaly

All prototype scripts and outputs are in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\relief_grids\` only.
Scripts: `verify.py`, `passes2.py`, `passes3.py`, `passes4.py`, `finalize.py`,
`debug.py`; aggregate log `pass_log.txt` (sha256
`c0e135a23f64fc169966a4d428dc7ffd79473f16cc0e9195e346b56fba61e59c`).

| Pass | Instrument | Contradiction / result | Acceptance |
|---|---|---|---|
| P1 | `struct.unpack_from('<%df', raw, G)` after manual `<2i` header read | None — 5/5 dims, sizes, sha256s, min/max | Accepted [O] |
| P2 | Independent `struct.unpack('<%df', raw[G:G+4wh])` slice | None — bit-identical to P1 on 100% of floats | Accepted [O]+[D] |
| P3 | Bit-pattern comparison P1 vs P2 | None — 0 differing bits | Accepted [D] |
| P4 | `pattern.lib` 3-space-indented section parse → float32 bits vs grid bits | None — 5/5 bit-exact | Accepted [O]+[D] |
| P5 | ±320 B min/max candidate scan (`only if P4 failed`) | Not triggered (P4 passed for all five); run separately in pass B to quantify ambiguity | Accepted as context [D] |
| P6 | Recompute 8×10 block means (integer-floor bands, arithmetic mean) at `G=8+N` | **Mismatch:** `hil1 (4,0)` F01 `0.220` vs double `0.221` (max dev 0.001); other 399 cells 0 | Escalated, not declared an F01 error |
| P7 | Print every differing cell and re-derive value list | One cell only; exact mean `0.220500004292…` | Escalated |
| P8 | Decode at old DPATTERN offsets and recompute 8×10 | Old A1–A4 reproduced with **zero** deviation → old tables are shifted windows | Accepted [D] |
| P9 | `numpy.mean(dtype='<f4')` and `dtype='<f8'` for all 400 cells (passes4) | Float32 accumulator reproduces **all five F01 tables exactly**; float64 differs only at `hil1 (4,0)` | F01 **confirmed**; mismatch classified as accumulator rounding |
| P-A | `math.fsum`, reversed summation, `numpy` f32/f64 for the disputed cell | Same exact mean from all summation orders; only the *accumulator dtype* flips the 3 dp digit | Accepted [D] |
| P-B | ±320 B min/max candidate scan for all five | 83–161 candidate starts; all five old offsets are in their candidate sets | Accepted [D] — explains DPATTERN's scan method failure |
| P-C | Recompute X13 semantic selectors (`first/centre/min/max/last`) at old vs true G | All five selector positions shift; e.g. `k_ravine_1` min moves `(z=13,x=4)` → `(z=13,x=21)`, max `(48,1)` → `(48,18)` | Accepted [D]; replacement in §6 S5 |
| P-D0 | **Self-check bug found in own harness:** a bit-pattern→float helper byte-swapped `Min/Scale/Offset` (e.g. `0xC03DAC13` → `4.35e−27`). Recomputed outputs disagreed with X13's published columns. | Fixed to `struct.unpack('<f', struct.pack('<I', int(hex,16)))`; re-ran. All **19/19** published vectors now reproduce exactly from published bits + donor flags | Accepted after fix; the corrected true-G columns are trustworthy only because P-D0 passes |
| P-D | Recompute all 19 vectors at corrected offsets with unchanged `(z,x)` and unchanged flags/inputs | 19/19 `g_bits` differ; 12/19 output columns change; discriminator vectors `REP-hil1-01`, `REP-kr1-02`, `SMB-kr1-02` still disagree D05-vs-task | Accepted [D] |
| P-E | Reproduce smooth snapshots at old G (cell `(x=17,z=29)`) | 8/8 published snapshot bits reproduced → same kernel; at true G all 8 differ | Accepted [D] |
| P-F | Search transposition discriminators at true G | Original `AXIS` pair collapses to `0x00000000`/`0x00000000`; alternative pairs exist | Accepted [D] |

**Owner directive satisfied:** the only F01 mismatch got four independent
instruments (P6, P7, P9, P-A) before a verdict; the only mismatch in my own
output got a full self-check pass (P-D0) before publication. No value was guessed.

---

## 4. Five verified tables

All tables are 8 rows × 10 columns, row-major `j` = file-row band
`[j*h/8,(j+1)*h/8)`, `i` = file-column band `[i*w/10,(i+1)*w/10)`, integer
floor, arithmetic mean. Printed at 3 dp using the **float32 accumulator**
(F01's declared method). Full-precision `float32` grids, both 3 dp variants,
sha256s and bit-level metadata are in
`relief_grids_canonical.json` (`schema X23_RELIEF_GRID_VERIFICATION/1`).
**Derived numeric data / PORT APPROXIMATION as debug aids — stamp from full grids.**

### 4.1 `k_ravine_1` — [O]+[D]

- `w=46, h=63, wh=2898, N=2790`; source `data\pattern\k_ravine_1.pattern`,
  exact byte offset **`G=2798` (`0x0AEE`)**; file sha256
  `9a806a0595992c9acb9f780db038a4563d88b3bcd3ed0de0662c5626e4e1c841`.
- `pattern.lib:549585-549586` Min `−2.963627576828` / Max `3.13982009887695`
  (`0xC03DAC13` / `0x4048F2D0`), bit-exact vs decoded grid.

```
 0.000 -0.000 -0.000 -0.002 -0.156 -0.320 -0.194 -0.018 -0.345 -1.454
-0.000 -0.003 -0.864 -2.062 -2.146 -2.164 -1.648 -0.114 -0.017 -0.184
-0.000 -0.138 -1.517 -2.680 -2.957 -2.928 -2.846 -0.873 -0.002 -0.000
 0.000  0.442 -0.074 -2.506 -2.885 -2.075 -1.888 -0.508 -0.001 -0.000
 0.000  0.742  2.421  0.198  0.132  2.101  0.266  0.002  0.000  0.000
 0.000  0.163  1.986  2.924  2.904  2.551  1.281  0.021  0.000  0.000
 0.000  0.000  0.104  0.947  0.891  0.283  0.051  0.000  0.000  0.000
 0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000  0.000
```

### 4.2 `plt2` — [O]+[D]

- `w=42, h=55, wh=2310, N=2214`; source `data\pattern\plt2.pattern`,
  exact byte offset **`G=2222` (`0x08AE`)**; file sha256
  `262695928dab839bb08ff29b2903870a474b04b12c44e0e701ab9053ae9f39b1`.
- `pattern.lib:6805-6806` Min `−0.0732548981904984` / Max `3.61341166496277`
  (`0xBD9606AA` / `0x40674223`), bit-exact.

```
-0.000 -0.003 -0.003  0.056  0.055  0.053  0.011 -0.003 -0.002 -0.000
-0.001 -0.004  0.374  1.731  2.508  1.932  0.826  0.365  0.115  0.012
 0.002  0.091  1.340  3.145  3.248  2.897  2.265  0.933  0.148  0.018
 0.004  0.077  0.400  1.726  3.336  3.403  3.174  1.035  0.088  0.001
-0.000  0.086  1.470  2.922  3.216  3.007  1.957  0.662  0.081  0.004
 0.011  0.172  0.793  1.824  2.895  3.063  1.148  0.199  0.035  0.000
 0.002  0.023  0.099  0.436  1.320  1.313  0.353  0.102  0.004  0.000
 0.000 -0.000 -0.000  0.011  0.019  0.035  0.018  0.006  0.000  0.000
```

### 4.3 `hil1` — [O]+[D]

- `w=25, h=41, wh=1025, N=960`; source `data\pattern\hil1.pattern`,
  exact byte offset **`G=968` (`0x03C8`)**; file sha256
  `a55ea48086c9103a70e4f7c0635131b31ea6a56b76daaa830f221d5b699c9b19`.
- `pattern.lib:33111-33112` Min `0` / Max `3.86130237579346`
  (`0x00000000` / `0x40771F94`), bit-exact.
- **[D] Rounding caveat:** cell `(4,0)` prints `0.220` with float32
  accumulator (F01) and `0.221` with double; exact mean
  `0.220500004292…`. Both come from the same donor bytes (§3 P9/P-A).

```
 0.000  0.000  0.052  0.250  0.206  0.029  0.000  0.000  0.000  0.000
 0.000  0.005  0.057  0.450  0.740  0.527  0.183  0.047  0.000  0.000
 0.018  0.092  0.198  1.006  1.546  1.131  0.659  0.255  0.000  0.000
 0.133  0.581  1.501  2.461  2.891  2.121  1.591  0.717  0.055  0.000
 0.220  0.796  1.880  3.133  3.283  2.362  1.796  0.725  0.067  0.000
 0.025  0.331  0.775  1.630  1.675  1.164  0.711  0.293  0.005  0.000
 0.000  0.174  0.421  0.959  0.823  0.307  0.028  0.000  0.000  0.000
 0.000  0.014  0.100  0.236  0.101  0.014  0.000  0.000  0.000  0.000
```

### 4.4 `g_hil4` — [O]+[D]

- `w=33, h=59, wh=1947, N=1856`; source `data\pattern\g_hil4.pattern`,
  exact byte offset **`G=1864` (`0x0748`)**; file sha256
  `88a62740780631a18a75c7e48f175e963d6cf1e103a42762aea5d1045b5bf7ca`.
- `pattern.lib:366499-366500` Min `−4.32127315701247E-13` / Max
  `1.91698789596558` (`0xAAF3441C` / `0x3FF55FDC`), bit-exact.

```
 0.000  0.000  0.001  0.030  0.152  0.126  0.007  0.000  0.000  0.000
 0.000  0.004  0.192  0.487  0.773  0.433  0.119  0.074  0.054  0.012
 0.000  0.370  0.998  1.262  1.188  0.478  0.326  0.292  0.212  0.073
 0.000  0.393  0.341  0.957  1.780  1.360  0.565  0.349  0.216  0.071
 0.000  0.002  0.046  0.274  1.175  1.616  1.279  0.802  0.359  0.048
 0.000  0.000  0.027  0.276  1.033  1.151  0.780  0.496  0.201  0.033
 0.000  0.000  0.041  0.289  0.837  0.645  0.520  0.403  0.235  0.055
-0.000 -0.000  0.024  0.171  0.301  0.345  0.336  0.265  0.166  0.052
```

### 4.5 `k_ravine_big_stone_1` — [O]+[D]

- `w=84, h=100, wh=8400, N=8217`; source
  `data\pattern\k_ravine_big_stone_1.pattern`, exact byte offset
  **`G=8225` (`0x2021`)**; file sha256
  `47004fe30ca7fcf97e578011535aab06b503ca3cb6dd1ebae125121d1fb0996b`.
- `pattern.lib:730045-730046` Min `−2.96362733840942` / Max `0.173864871263504`
  (`0xC03DAC12` / `0x3E3209A2`), bit-exact.
- **[D]** DPATTERN-01 never published an Appendix A table for this pattern
  (G07 §3.3 called it a Tier-1 prerequisite). Its §3 offset was already correct;
  the table below satisfies that prerequisite but remains a **derived 8×10
  block-mean debug aid**, not a donor engine blend.

```
 0.000  0.000 -0.000 -0.000 -0.000 -0.000 -0.020 -0.095 -0.002 -0.559
 0.000 -0.000 -0.000 -0.000 -0.000 -0.000 -1.448 -1.844 -0.296 -0.653
 0.000 -0.000 -0.000 -0.000 -0.008 -0.411 -2.649 -2.530 -0.217 -0.000
 0.000 -0.000 -0.000 -0.000 -1.563 -2.832 -2.953 -2.959 -2.027 -0.086
 0.000 -0.000 -0.057 -0.133 -1.644 -2.944 -2.711 -1.576 -0.960 -0.018
 0.000 -0.017 -2.275 -2.798 -2.948 -2.463 -0.846 -0.000 -0.000 -0.568
 0.000 -0.002 -0.682 -1.776 -2.741 -2.043 -0.103 -0.000 -0.079 -2.006
 0.000  0.000 -0.006 -0.113 -0.306 -0.126 -0.000 -0.000 -0.022 -0.494
```

---

## 5. Old-vs-new diff — [D]

Old table = 8×10 means at DPATTERN §3 offset; new = 8×10 means at `G=8+N`.
Errors computed over all 80 cells at 3 dp. Metrics in
`x23_full_results.json:diffs`.

| Pattern | Old G | True G | Shift | = cols | MAE | RMSE | Max abs diff (cell j,i) | Cells >0.05 | Argmax old → new | Old A table reproduced |
|---|---:|---:|---:|---:|---:|---:|---|---:|---|---|
| `k_ravine_1` | 2866 | 2798 | +68 B | +17 | 1.15355 | 1.55986 | 2.947 (2,0) | 67/80 | (5,0) 2.937 → (5,3) 2.924 | zero dev (A1) |
| `plt2` | 2266 | 2222 | +44 B | +11 | 1.04389 | 1.49833 | 3.215 (3,5) | 63/80 | (3,2) 3.437 → (3,5) 3.403 | zero dev (A2) |
| `hil1` | 1000 | 968 | +32 B | +8 | 0.75441 | 1.07714 | 3.181 (4,0) | 69/80 | (4,0) 3.402 → (4,4) 3.283 | zero dev (A3) |
| `g_hil4` | 1912 | 1864 | +48 B | +12 | 0.52081 | 0.67820 | 1.705 (3,0) | 73/80 | (3,0) 1.705 → (3,4) 1.780 | zero dev (A4) |
| `k_ravine_big_stone_1` | 8225 | 8225 | 0 | 0 | 0.000 | 0.000 | 0.000 | 0/80 | (0,0) 0.000 → (0,0) 0.000 | no published table |

**[D] Mechanism.** Every shift is a positive multiple of 4 and smaller than
`w`, so the old window is the true float grid advanced by `k` columns with
wrap at each row end. The shape is therefore not merely translated: the last
`k` columns of each old row are borrowed from the start of the next true row.
That is why block means near left/right edges differ by up to 2.9–3.2 donor
height units, while `pattern.lib` Min/Max still match (zero border runs).
This is a **PORT APPROXIMATION** shape correction; no statement about rendered
parity follows.

---

## 6. Stale-claim register — exact replacement text for COORD

### S1 — Z04 Part B / G07 §3.2 / `variant3d/scripts/game.gd` `RELIEF_GRID_*` tables [D]

**Stale:** Z04 §3.2 (lines 231–253) transcribes `RELIEF_GRID_HIL1` and
`RELIEF_GRID_G_HIL4` "verbatim from DPATTERN_01 Appendix A3/A4"; the same
Appendix A1/A2 tables are already live as `RELIEF_GRID_K_RAVINE_1` /
`RELIEF_GRID_PLT2`. All four are shifted-window means. `k_ravine_big_stone_1`
has no table at all.

**Exact replacement — use the §4 blocks verbatim**, with this provenance line
substituted for Z04's "transcriptions of DPATTERN_01 Appendix A3/A4":

```gdscript
# X23/F01 §4.10 — corrected 8x10 block means, decoded from donor bytes at
# G = 8 + (w-1)*(h-1): hil1 968, g_hil4 1864, k_ravine_1 2798, plt2 2222,
# k_ravine_big_stone_1 8225. Verified bit-exact vs pattern.lib Min/Max and
# reproduced with a float32 accumulator. Derived numeric data only;
# PORT APPROXIMATION debug/preview aid — stamp from the full w*h float32 grid.
```

**Exact replacement for `RELIEF_GRID_META` offsets** (Z04 §3.2 lines 256–265):

```gdscript
"k_ravine_1":            {"scale": 1.0,  "min": -2.963627576828003,  "max": 3.139820098876953,  "w": 46, "h": 63,  "offset": 2798, "lib": "pattern.lib:549585-549586"},
"plt2":                  {"scale": 1.0,  "min": -0.07325489819049835, "max": 3.6134116649627686, "w": 42, "h": 55,  "offset": 2222, "lib": "pattern.lib:6805-6806"},
"hil1":                  {"scale": 0.65, "min": 0.0,                  "max": 3.861302375793457,  "w": 25, "h": 41,  "offset": 968,  "lib": "pattern.lib:33111-33112"},
"g_hil4":                {"scale": 1.0,  "min": -4.321273157012473e-13, "max": 1.9169878959655762, "w": 33, "h": 59, "offset": 1864, "lib": "pattern.lib:366499-366500"},
"k_ravine_big_stone_1":  {"scale": 1.0,  "min": -2.963627338409424,  "max": 0.17386487126350403, "w": 84, "h": 100, "offset": 8225, "lib": "pattern.lib:730045-730046"},
```

`hil1.scale = 0.65` remains a donor literal (`pattern.lib:33094`, byte 854,472),
not a tuning knob. `k_ravine_1` stays BLOCKED under RELIEF-02; adding a table
does not authorise a stamp. `k_ravine_big_stone_1` is donor-ACTIVE
(`dogenerate.inc:1761`) but still needs a named owner before any code lands.

### S2 — `docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md` §4 'verified offsets' [D]

**Stale text (lines 55–57):**
> `decode_donor_pattern.py` (I02) must decode the `.pattern` float grid at the
> verified offsets and the object tail; `decode_pattern_lib.py` (I03) is a
> plaintext section parser (37 fields + nested structs), not a binary reader.

**Exact replacement:**
> `decode_donor_pattern.py` (I02) must decode the `.pattern` float grid at
> `G = 8 + (w−1)*(h−1)` — the header `<2i w,h` at `data\pattern\<name>.pattern:0x00`,
> followed by an `N`-byte u8 mask at `0x08` and `w*h` LE float32 at `G` — derived
> from the verified closure `filesize = 8 + 4*w*h + 54*N` (710/710, F01 E4).
> Never scan for min/max to find the plane: 83–161 byte starts within ±320 B of
> `G` reproduce the same extrema, and all five DPATTERN-01 offsets are such
> false positives (X23 E10). Gate on bit-exact `pattern.lib`
> `HeightFieldMin/Max`. `decode_pattern_lib.py` (I03) is a plaintext section
> parser (37 fields + nested structs), not a binary reader.

### S3 — spec §4 'm_swamp_12_old UNVERIFIED until F01/D05 resolve it' [D]

**Stale text (lines 60–61):** "Keep the one anomalous record (`m_swamp_12_old`)
labelled UNVERIFIED until F01/D05 resolve it."

**Exact replacement:**
> F01 §4.9 resolved `m_swamp_12_old`: `pattern.lib:905524-905525` says 17×20
> while the binary header says 18×23 — a stale config, not an undecoded record.
> Use the binary header as truth and log the config mismatch; do not hold the
> decoder on this case.

### S4 — X13 executive summary item 2 and evidence E4/E5/E6 [D]

**Stale text:** "Real float grids were decoded … at the F02/X05 line-offset-derived
byte starts `G=1000 / 1912 / 2866`"; E4/E5/E6 `grid_byte` fields.

**Exact replacement:**
> Real float grids are decoded at the F01 structural offsets
> `G = 8 + (w−1)*(h−1)` = **968 (`hil1`) / 1864 (`g_hil4`) / 2798
> (`k_ravine_1`)**. The offsets `1000 / 1912 / 2866` used here are
> DPATTERN-01's shifted windows (+32 / +48 / +68 B = +8 / +12 / +17 float32
> columns). They reproduce `pattern.lib HeightFieldMin/Max` bit-exactly because
> of zero-border runs, but their per-cell samples and all 8×10 block means are
> spatially shifted. File sha256s (`a55ea480…c9b19`, `88a62740…f7ca`,
> `9a806a05…e841`) and the bit-exact min/max cross-checks are unchanged.

E4/E5/E6 rows become: `hil1.pattern:0-7, G=968, w*h=25*41`;
`g_hil4.pattern:0-7, G=1864, w*h=33*59`;
`k_ravine_1.pattern:0-7, G=2798, w*h=46*63`.

### S5 — X13's 19 test vectors: all `g_bits` and all computed outputs [D]

**Stale:** every `g_bits` value in `x13_blend_vectors.json` and in the report's
19-row table; 12/19 output columns change. **Exact replacement table** (same
`(z,x)` cells, same donor/synthetic flags and same `base_h/h0/h1`; recomputed
with the D05 F4 models after P-D0 self-check):

| ID | z,x | TRUE g bits | D05-d | D05-f | T | d=f | d=T |
|---|---|---|---|---|---|---|---|
| RVW-hil1-01 | 0,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |
| RVW-hil1-02 | 22,1 | `0x3E8F5C29` | `0x3E3A5E35` | `0x3E3A5E35` | `0x3E3A5E35` | y | y |
| RVW-hil1-03 | 40,24 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |
| RVW-g_hil4-01 | 28,4 | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | y | y |
| RVW-g_hil4-02 | 29,16 | `0x3FEECCDE` | `0x3FEECCDE` | `0x3FEECCDE` | `0x3FEECCDE` | y | y |
| RVW-k_ravine_1-01 | 13,4 | `0xB1A736BB` | `0xB1A736BB` | `0xB1A736BB` | `0xB1A736BB` | y | y |
| RVW-k_ravine_1-02 | 48,1 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |
| RVW-k_ravine_1-03 | 0,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |
| REP-hil1-01 | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` | `0x3FBFEA0C` | `0x3FCC754F` | y | **NO** |
| REP-kr1-01 | 13,4 | `0xB1A736BB` | `0x403DB22D` | `0x403DB22D` | `0x403DB22D` | y | y |
| REP-kr1-02 | 48,1 | `0x00000000` | `0x3FF69F19` | `0x3FF69F19` | `0x403DB22D` | y | **NO** |
| REP-kr1-03 | 31,23 | `0xBF79F586` | `0x404F34CC` | `0x404F34CC` | `0x404F34CC` | y | y |
| SMB-hil1-01 | 22,1 | `0x3E8F5C29` | `0x3FBFEA0C` | `0x3FBFEA0C` | `0x3FBFEA0C` | y | y |
| SMB-kr1-01 | 13,4 | `0xB1A736BB` | `0x403DB22D` | `0x403DB22D` | `0x403DB22D` | y | y |
| SMB-ghil4-01 | 28,4 | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | `0x3D53C32A` | y | y |
| SMB-kr1-02 | 31,23 | `0xBF79F586` | `0x3FB8704F` | `0x3FB8704F` | `0x3EAE8E08` | y | **NO** |
| SMB-kr1-03 | 48,1 | `0x00000000` | `0x3F6E978D` | `0x3F6E978E` | `0x3F6E978D` | **NO** | y |
| AXIS-kr1-z1x0 | 1,0 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |
| AXIS-kr1-z0x1 | 0,1 | `0x00000000` | `0x00000000` | `0x00000000` | `0x00000000` | y | y |

Notes for COORD [D]:
- All 8 donor-flag `ReplaceForWater` vectors still agree bit-exactly across
  precision models — X13's precision conclusion survives the offset fix.
- The D05-vs-task-literal **discriminators survive** in `REP-hil1-01`,
  `REP-kr1-02`, `SMB-kr1-02` (values changed, disagreement preserved).
- `REP-kr1-03` and `REP-kr1-01` now *agree* with the task literal; do not use
  them as discriminators.
- `SMB-kr1-03` acquires a 1-ULP double/f32-step split (`0x3F6E978D` vs
  `0x3F6E978E`): **[U]** x87 precision, as X13 R1 already warned.
- Semantic selector coordinates move (P-C): e.g. `k_ravine_1` min
  `(13,4)→(13,21)`, max `(48,1)→(48,18)`; `hil1` min `(1,0)→(0,0)`, max
  `(22,1)→(22,9)`; `g_hil4` max `(28,4)→(28,16)`, min `(26,57)→(5,58)`.
  The table above deliberately keeps the **published `(z,x)` cells** so vector
  identities stay stable; re-anchoring selectors is an open question (§9 Q3).

### S6 — X13 `AXIS` transposition discriminator [D]

**Stale:** `AXIS-kr1-z1x0` (`0xBAAC7432`) vs `AXIS-kr1-z0x1` (`0xBA9D9F10`)
both become `0x00000000` at the corrected offset — the discriminator is dead.

**Exact replacement:**
> `AXIS-kr1-z31x23`: `grid[z=31,x=23] = 0xBF79F586` at
> `k_ravine_1.pattern:2798+4*(31*46+23)`.
> `AXIS-kr1-z23x31`: `grid[z=23,x=31] = 0xC039FDB2` at
> `k_ravine_1.pattern:2798+4*(23*46+31)`.
> Both are nonzero and unequal; a transposed loader is still detectable
> before rendering. (Secondary zero-sample pair: `grid[0,17]=0xB9CE03CB` vs
> `grid[17,0]=0x00000000`.)

### S7 — X13 smooth-post-pass snapshots [D]

**Stale:** the four published in-place/double-buffer bits at cell `(x=17,z=29)`.
At the corrected offset all eight change. My kernel reproduces all 8 published
old-G bits exactly (P-E), so the replacement values are from the same code path:

| Iteration | In-place (old → true) | Double-buffer (old → true) |
|---:|---|---|
| 1 | `0x3E0E900E` → **`0x3FE40CFE`** | `0x3E0C9E9F` → **`0x3FE82B6D`** |
| 2 | `0x3E1691C8` → **`0x3FDE3920`** | `0x3E0AF67A` → **`0x3FE4F7F1`** |
| 3 | `0x3E1AE70E` → **`0x3FD8DCD2`** | `0x3E1608D5` → **`0x3FE13DCF`** |
| 4 | `0x3E1EB7C7` → **`0x3FD464FE`** | `0x3E159A3B` → **`0x3FDDE998`** |

Still **[U]**/`PORT APPROXIMATION`: the world patch is synthetic (the donor
grid reused as heights) and in-place vs double-buffer remains unsettled.

### S8 — X13 U5 / R2 'grid start boundary UNVERIFIED' [D]

**Stale wording:** "[U] Grid start boundary. F02 U-F02-1 stands … `G` accepted
from F02+X05 and byte context, not proved from the loader alone."

**Exact replacement:**
> **Partly resolved [D]/[U].** `G = 8 + (w−1)*(h−1)` is now *derived*, not
> chosen: F01's `filesize = 8 + 4wh + 54N` closes for 710/710 donor files with
> zero residual, and the region framing (mask `N`, float `wh`, PRE, `24N`,
> `16N−4`, `13N`) fixes the plane start. X23 independently reproduced 5/5
> bit-exact `pattern.lib` extrema at that offset and reproduced all old
> DPATTERN tables at the shifted offsets. The min/max-only ambiguity is real
> (83–161 candidate starts within ±320 B) and is the documented reason the
> earlier workers' scans landed wrong. **[U] retained** only for the *loader
> struct field names/semantics* (no RTTI/CODE proof yet, D01/D05 scope), not
> for the arithmetic value of `G`.

---

## 7. Implications for I02 and I07

**I02 — donor pattern decoder [D]:**
1. Decode at `G=8+N`, derived from the header; delete every scan-for-min/max
   offset heuristic. Pin `(w,h)`, `sha256`, `G`, `N`, `filesize` and the
   `pattern.lib` Min/Max bits in the emitted asset (the canonical JSON schema
   here is a usable template).
2. Export the **full `w*h` float32 grid**, not an 8×10 mean. The 8×10 tables are
   debug/preview aids only (DPATTERN `:595-600`); with `k` up to +17 columns of
   shift, block means demonstrably lose edge structure.
3. Gate: `bits(min(grid)) == bits(float32(HeightFieldMin))` and same for max;
   5/5 pass here. Two known stale config sections (`k_plain_mid_12`,
   `m_swamp_12_old`, F01 §4.9) must be logged, never silently "fixed" or used
   to move the plane.
4. Keep the case-insensitive filename lookup (`k_ravine_2` →
   `K_ravine_2.pattern`) and keep `mask`/`Rec24`/weights/`Tail13` fields under
   **[U]** labels — X23 verified no semantics for them (F01 §9).
5. Numeric round-trip: store full precision; if a 3 dp display is emitted,
   declare the accumulator dtype (`float32` → `hil1 (4,0)=0.220`, double →
   `0.221`).

**I07 — fresh Godot terrain module [D]/PORT APPROXIMATION:**
1. Replace any Z04/G07-derived 8×10 consts with §4 tables (S1) and the
   `RELIEF_GRID_META` offsets (S1). If the module instead consumes I02's full
   grid, the tables are unnecessary — prefer full grid where silhouette matters.
2. Do **not** re-run the X13 bit gate until X13-B vectors (S5) land: 19/19
   published `g_bits` and 12/19 outputs are from shifted windows. Until then,
   a bit-exact PASS would certify agreement with the *wrong* window.
3. Blend formulas (D05 F4) and flag census are **not** stale; only the grid
   samples feeding them are. `g_hil4` still has `Smooth=True` with
   `ReplaceForWater=True`, so its post-pass still runs (X13 implication 2).
4. Replace the AXIS discriminator (S6) before using it as a structural gate;
   reissue smooth snapshots (S7). Row-major `grid[z][x]` is unchanged.
5. Gates stay green and unchanged (`selftest 29/29`, `uitest 17/17`,
   `t_render_mode`, `assert_clean CLEAN`, `app/**` byte-identical). No
   threshold lowered; `parity.status = "UNVERIFIED"` in
   `terrain_qa_report/1` remains mandatory.

---

## 8. UNVERIFIED register

| ID | Claim | Status / passes |
|---|---|---|
| U1 | Exact grid plane boundary from engine loader | **[U]** `G=8+N` is structurally derived (F01 710/710 closure + X23 5/5 bit-exact); loader field names/semantics not confirmed by RTTI/CODE. Min/max-only scan admits 83–161 starts (P-B). |
| U2 | File row `v` → centred world-y sign (`row_flip`) | **[U]** unchanged from F01 §9 / X13 U1. P-C binds row→`z` indexing, not the sign. |
| U3 | Engine blend, clamp, global setter, `HeightFieldMax` use outside `sub_755f30` | **[U]** D05 F4 accepted by X13 P4; x87 80-bit exactness, rotation rounding and global clamp remain unproven. |
| U4 | Smooth post-pass in-place vs double-buffer | **[U]** X13 P6 and X23 P-E: both models emitted; 4/4 iterations diverge under both old and true offsets. |
| U5 | 3 dp display digit at `hil1 (4,0)` | **[D] resolved** as accumulator precision: f32 `0.220`, double `0.221`, exact mean `0.220500004292…`; full-precision grid in canonical JSON. No donor value guessed. |
| U6 | Semantics of mask, `Rec24.id`, `tail4`, weights, `Tail13` flags | **[U]** F01 §9; X23 read bytes only and made no semantic claim. |
| U7 | Which precision column I07 must match | **[U]** X13 R1; 1-ULP split appears again at `SMB-kr1-03` under true G (P-D). |
| U8 | `k_ravine_big_stone_1` runtime incidence and owner | **[U]** donor-ACTIVE per `dogenerate.inc:1761`; no table existed in DPATTERN. F01 §4.10 supplies a derived one, but no stamp is authorised here. |
| U9 | Donor GPU visual parity | **[U]** no A/B frame exists. **No parity claim.** |

---

## 9. Open questions

1. Will COORD reissue X13 as a new `X13-B` vector set/JSON, or patch the landed
   report in place? X23 recommends a new file with a new sha256 so the stale
   `82945e4a…` artifact is not silently reused.
2. Should I07 gate on I02's full-grid replay rather than any 8×10 table? The
   block-mean path loses edge structure by up to 3.2 units here.
3. Should X13's semantic selectors (`min/max/first/last`) be re-anchored to the
   corrected grid coordinates (P-C), or should vector IDs keep their published
   `(z,x)` cells as in S5? X23 chose the latter to preserve identity; COORD decide.
4. Can D01's RTTI/CODE lift confirm the loader struct so U1's residual
   **[U]** can be closed?
5. Is there a donor pattern with `Replace=true` or nonzero `Offset` so the
   remaining synthetic-branch vectors can become donor-flag vectors (X13 Q5)?
6. Who owns the `k_ravine_big_stone_1` stamp (G07 Tier 1), now that its
   prerequisite table exists?

---

## 10. Five-line summary

1. **[O]+[D] F01 confirmed 5/5:** independent `struct` decodes at `G=8+N` = 2798 / 2222 / 968 / 1864 / 8225 reproduce all five corrected 8×10 tables, all five file sha256s and all five bit-exact `pattern.lib` Min/Max cross-checks.
2. **[D] The sole discrepancy was resolved in F01's favour after four passes:** `hil1 (4,0)` `0.220` (float32 accumulator) vs `0.221` (double), exact mean `0.220500004292…` — accumulator rounding, not a grid error.
3. **[D] Old DPATTERN tables are exact block means of shifted windows:** +68/+44/+32/+48/+0 B (+17/+11/+8/+12/+0 columns), MAE 1.154/1.044/0.754/0.521/0.000, 63–73 of 80 cells differ >0.05; DPATTERN's scan found false offsets because 83–161 byte starts share the same extrema.
4. **[D] X13 is stale:** 19/19 `g_bits` came from shifted windows, the AXIS discriminator collapses to two zeros and all smooth snapshots change; exact replacement tables, flags-preserving recomputed outputs and provenance text are supplied in §6.
5. **[U] PORT APPROXIMATION only** — loader field names, row-sign flip, blend/x87 precision, post-pass order and prop semantics remain UNVERIFIED; no donor GPU A/B frame exists, so **no parity claim**.

*End of X23. Exactly one repo file written. Donor read only; scripts and canonical JSON in the temp directory only. No repo source, asset, config, test, shader, queue, git or Godot state changed.*
