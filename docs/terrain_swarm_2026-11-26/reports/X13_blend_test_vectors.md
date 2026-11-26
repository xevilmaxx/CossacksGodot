---
id: X13-BLEND-TEST-VECTORS
title: "X13 — numeric verification harness for the D05 relief-blend formulas (19 blend vectors + 4 smooth-postpass snapshots)"
agent: "worker X13 (donor-first terrain swarm, 2026-11-26)"
date: 2026-11-26
status: REPORT LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3\\data\\pattern\\{pattern.lib,hil1.pattern,g_hil4.pattern,k_ravine_1.pattern} — READ ONLY, opened 'rb' only; no donor binary executed/copied"
verdict: "DONOR_GRIDS_BIT_EXACT_3_3__TASK_REPLACE_FORMULA_INCOMPLETE__D05_F4_ACCEPTED_AS_AUTHORITATIVE__NO_PARITY_CLAIM"
---

# X13 — Blend test vectors for the fresh Godot module (I07)

## Executive summary

1. **[D]** A deterministic numeric harness was built entirely **outside the repo**
   (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\blend_vectors\`): 19 blend
   vectors + 4 smooth-postpass snapshots, each with **exact IEEE-754 float32 bit
   patterns**, two precision models and two formula models. Vector file
   `x13_blend_vectors.json` sha256 =
   `82945e4ac7602b5a67a2b62e232dc4ae5cbf3ee8237532c5002a01f7053bcb8a`; CSV sha256 =
   `11943010b798f611f8cc1599dc7145c91a865e0aaddd025f320832de1d9d024b`.
   No repo file other than this report was written.
2. **[O]** Real float grids were decoded from the three named donor `.pattern`
   files at the F02/X05 line-offset-derived byte starts `G=1000 / 1912 / 2866`.
   For all 3/3 patterns, decoded grid min and max reproduce `pattern.lib`
   `HeightFieldMin/Max` **bit-exactly as float32** (§Evidence E4–E6). All three
   sections carry `ReplaceForWater=True`, `Replace=False`; therefore only the
   ReplaceForWater path is observable with **real donor flags**. Replace and
   Smooth-blend vectors necessarily use **synthetic flag overrides** — labelled
   `PORT APPROXIMATION`, not claimed as donor incidence.
3. **[D] The task brief's `Replace` formula is incomplete.** `base_h+g+Offset`
   omits both the `Scale` multiplication and the `(g-Min)*Scale+Min` pivot that
   D05 recovered from raw x87 opcodes at `0x756607..0x756619`. With donor
   `hil1 Scale=0.65`, expected bits are `0x4074F076` (D05) vs `0x40A5B75B`
   (task literal) — a large, not 1-ULP, divergence. Multiple passes (§Method P4)
   resolved this in favour of **D05 F4**; the task literal is retained in the
   vectors only as an explicitly labelled comparison model.
4. **[D]** Row-major `grid[z][x]` is confirmed by a transposition discriminator:
   `grid[1][0] = 0xBAAC7432` vs `grid[0][1] = 0xBA9D9F10`. The smooth post-pass
   divisor is the hardcoded `4.0f` (`cossacks.exe` VA `0x755ee4`) and
   `HeightFieldSmoothFactor=4` is the **iteration count** (D05 F5), not the
   divisor. In-place vs double-buffer update order diverges at all 4 iterations
   → **[U] UNVERIFIED**; I07 must choose and document one.
5. **[U]** The row-sign flip, rotation rounding, global setter clamp, true x87
   80-bit precision, exact on-disk plane boundary and smooth-mask gating remain
   unverified and are registered below. **No donor parity is claimed**: these are
   numeric input→output contracts for a fresh module, not a rendered A/B.

---

## Evidence table

| # | Donor path : line / byte / VA | Class | What it establishes |
|---|---|---|---|
| E1 | `data\pattern\pattern.lib:33081-34745` (section start byte `854,149`) | [O] | `hil1` 37-field prologue: `ReplaceForWater` at `+9` = line 33090; `Scale` at `+13` = 33094 = `0.649999976158142` (`0x3F266666`); `Min`/`Max` at 33111/33112 = `0x00000000` / `0x40771F94` (`pattern.lib:33111` byte 854,933, F02 E5/X05 E5) |
| E2 | `data\pattern\pattern.lib:366469-369365` (byte `9,458,091`) | [O] | `g_hil4`: `ReplaceForWater=True`, `Smooth=True`, `Scale=1.0` (`0x3F800000`), `SmoothRadius=3`, `SmoothFactor=4`, `SmoothOffset=2`, `Min=0xAAF3441C`, `Max=0x3FF55FDC`, `Offset=0` (`pattern.lib:366499/366500` bytes 9,458,861/9,458,904, F02 E6) |
| E3 | `data\pattern\pattern.lib:549555-555363` (byte `14,195,473`) | [O] | `k_ravine_1`: `ReplaceForWater=True`, `Replace=False`, `Scale=1.0`, `TerrainScale=1.0`, `Min=0xC03DAC13` (`−2.963627576828003`), `Max=0x4048F2D0`, `Offset=0` (`pattern.lib:549585/549586` bytes 14,196,248/14,196,285, F02 E7) |
| E4 | `data\pattern\hil1.pattern:0-7`, `G=1000`, `w*h=25*41` | [O]/[D] | Header `19 00 00 00 29 00 00 00`; decoded grid min `0x00000000`, max `0x40771F94` — bit-exact vs E1; file sha256 `a55ea480…c9b19` |
| E5 | `data\pattern\g_hil4.pattern:0-7`, `G=1912`, `w*h=33*59` | [O]/[D] | Header `21 00 00 00 3b 00 00 00`; min `0xAAF3441C`, max `0x3FF55FDC` — bit-exact vs E2; file sha256 `88a62740…f7ca` |
| E6 | `data\pattern\k_ravine_1.pattern:0-7`, `G=2866`, `w*h=46*63` | [O]/[D] | Header `2e 00 00 00 3f 00 00 00`; min `0xC03DAC13`, max `0x4048F2D0` — bit-exact vs E3; file sha256 `9a806a05…e841` |
| E7 | F02 §5.8 table + X05 V4 (`reports/X05_pattern_lib_validation.md:144-163`) | [O] | `G` offsets independently derived by two workers; accepted here after three local passes (§Method P2/P3) |
| E8 | `cossacks.exe` VA `0x756441-0x7566e9` (file `0x355841-0x355ae9`), D05 F4 / E8/E9 | [O] | `sub_755f30` height loop: `fsub [p+0x5c]`, `fmul`, `fadd [p+0x5c]` at `0x756607..0x756619`; `ReplaceForWater` setter `0x75664b..0x756664`; `Replace` setter `0x756674..0x756690`; `Smooth` reads `getHeight` twice at `0x7566a0` and `0x7566c7`, setter `0x7566e4` |
| E9 | `cossacks.exe` VA `0x755db4` kernel, divisor const @`0x755ee4`, D05 F5/E10 | [O]/[D] | 4-neighbour mean `÷4.0f`; `HeightFieldSmoothFactor` (+`0x54`) is the **iteration count**; radial remap `(Radius−Offset)/d` |
| E10 | D05 F2 offset map, `sub_75c314` VA `0x75c314-0x75c6a0`; `editor.exe` VA `0x8cc7ae-0x8cc91f` | [O] | `Replace=+0x3a`, `ReplaceForWater=+0x3b`, `Scale=+0x48`, `Smooth=+0x4c`, `Min=+0x5c`, `Max=+0x60` (never read in stamp), `Offset=+0x64`, `TerrainScale=+0x68` |
| E11 | `spec/04_PATTERN_STAMPING.md:80-90` §6 + task brief | [O]/[D] | Three published formulas; source of the contradiction resolved in P4 below |
| E12 | `docs/.../spec/12_QA_AND_INTEGRATION.md:96-125` §12.6, `:90-94` §12.5 | [O] | QA layers and non-negotiable gates; this harness is input to layers 1/2, **not** a new gate |

---

## Method — multiple passes on every contradiction (owner directive)

All prototype scripts and outputs live only in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\blend_vectors\`:
`pass1_probe.py`, `pass2_grid_extent.py`, `pass3_plane_anchor.py`,
`build_vectors.py`, `x13_blend_vectors.json`, `x13_blend_vectors.csv`,
`x13_blend_vectors.sha256`.

| Pass | Instrument | Contradiction / result | Acceptance |
|---|---|---|---|
| P1 | Read `pattern.lib` as CRLF-split bytes; 37-key prologue; read three `.pattern` headers and decode `w*h` f32 at F02 `G` | None — all three sections found, all 37 keys in order; min/max bit-exact 3/3 | Accepted [O] |
| P2 | Compare candidate plane starts `G` vs `8+w*h` vs `8+(w+1)*(h+1)` | **Contradiction:** `8+w*h` = 1033/1955/2906, while F02 `G` = 1000/1912/2866 (differences 33/43/40 B). D05 F1 says loader allocates `(w+1)*(h+1)` floats, whereas F02 decoded `w*h` | Rejected `8+w*h`: garbage min/max for `hil1`/`g_hil4`. Decoding `(w+1)*(h+1)` at `G` yields garbage max for `g_hil4`/`k_ravine_1` → **on-disk plane is `w*h` floats**. Loader over-allocation is a border/buffer detail, not on-disk extent [D]. Grid start remains [U] per F02 U-F02-1 |
| P3 | Spatial-smoothness scan over candidate offsets; byte-context dump around `G` | Smoothness metric inconclusive (many zero-shifted windows score similarly: 513/118 candidates). But at byte `G` exactly, the first float equals the F02-decoded `grid[0]` and is preceded by a long zero run | Accepted F02/X05 `G` [D] by **three independent instruments** (two workers + local byte check); not by a single pass |
| P4 | Compute task-literal and D05-exact formulas side by side; add discriminator vectors | **Contradiction:** task `Replace` omits Scale/pivot; task `Smooth` uses one `h` read and D05 uses `h0`,`h1`. 3 vectors disagree (`REP-hil1-01`, `REP-kr1-02`, `SMB-kr1-02`) | Accepted **D05 F4** as authoritative [O]; task literal kept as labelled comparison model only. No averaging, no silent choice |
| P5 | Two precision models: `double → f32 at store` (primary) vs `f32 after each op` (secondary) | 5/19 vectors differ by 1 ULP, all with nonzero `Min` pivot/cancellation; all 8 donor-flag ReplaceForWater vectors agree bit-exactly | Accepted: both columns reported; x87 80-bit exactness marked [U] |
| P6 | Smooth post-pass with in-place read-after-write vs double-buffer read-from-snapshot | All 4 iterations diverge (e.g. iteration 1 `0x3E0E900E` vs `0x3E0C9E9F`) | **[U]**: D05 F5's one-line pseudocode does not settle update order; both snapshots emitted |

Self-checks (all PASS): identity `RFW(Scale=1,Offset=0)→g`; identity
`Smooth(base=h0=h1=0,Scale=1,Min=0,Offset=0)→g`; transposition separates
`grid[z][x]`; divisor is hardcoded `4.0f`; Factor=4 emits 4 snapshots;
in-place≠double-buffer; all three donor `Replace=False`; both formula
discriminators actually disagree.

---

## Formulas implemented

All operands are float32 as stored in `pattern.lib` / `.pattern`; `g` is the raw
grid sample; `base_h` is the bilinear world-height sample at the stamp centre
(D05 F4). Paths are selected by **two booleans**, not an enum
(`ReplaceForWater` dominates `Replace`).

**D05 F4 — authoritative [O] (`sub_755f30`, VA `0x756441-0x7566e9`):**

```text
if ReplaceForWater:  g2 = g * Scale                       # 0x75661f..0x756625
else:                g2 = (g - Min) * Scale + Min         # 0x756607..0x756619
                                                          # Min is a PIVOT, not a clamp
if ReplaceForWater:  h_new = g2 + Offset                  # 0x75664b..0x756664
elif Replace:        h_new = base_h + g2 + Offset         # 0x756674..0x756690
else:  # "Smooth" blend
    h0 = getHeight(c,r)                                   # 0x7566a0
    t  = (base_h - h0) * TerrainScale + g2 + Offset       # 0x7566a5..0x7566b4
    h1 = getHeight(c,r)                                   # 0x7566c7
    h_new = t + h1                                        # 0x7566d2, setter 0x7566e4
```

**Task-brief / spec §6 literal [D] — comparison only, NOT implemented as port truth:**

```text
ReplaceForWater:  g*Scale + Offset                         # matches D05
Replace:          base_h + g + Offset                      # MISSING Scale and Min pivot
Smooth:           h += (base_h-h)*TerrainScale
                      + (g-Min)*Scale + Min + Offset       # matches D05 only if h0==h1
```

`HeightFieldMax` is **never read** in the stamp (D05 E15: no `[+0x60]` access) —
there is no clamp to `[Min,Max]` in this stage. The port's additive-clamp model
stays refuted for the stamp; any map-wide ceiling belongs to the unstudied global
setter (UNVERIFIED U3).

**Smooth post-pass [O] (`sub_755db4`, D05 F5; gated only by `Stand && Smooth`):**

```text
d  = sqrt((x-cx)^2 + (z-cz)^2)
tx = round(cx + (x-cx)*(Radius - Offset)/d)
tz = round(cz + (z-cz)*(Radius - Offset)/d)
repeat HeightFieldSmoothFactor times:                      # 4 for all 680 sections
    for (u,v) inside (u-tx)^2 + (v-tz)^2 < Radius^2:
        h[v][u] = (h[v][u-1] + h[v][u+1] + h[v-1][u] + h[v+1][u]) / 4.0f
```

Grid indexing is row-major `grid[z][x]` (`z` = row = world y/z, `x` = column);
loader pointer `+0x28`, float stride 4, occupancy mask at `+0x24` gating the loop
(`0x756638`). Harness cells use `flat = z*w + x`.

---

## Test-vector table

`D` = donor flags; `S` = synthetic flag override (`PORT APPROXIMATION`, used only
because no donor pattern exercises that branch). `D05-d` = primary double→f32
model; `D05-f` = secondary f32-after-each-op model; `T` = task literal. All values
are 8-hex-digit float32 bit patterns. Full JSON carries `g_float`, decimal
outputs, all flag bits, `base_h/h0/h1` bits and notes.

| ID | Path | Src | z,x | g bits | base_h bits | D05-d | D05-f | T | D05=T | d=f |
|---|---|---|---|---|---|---|---|---|---|---|
| RVW-hil1-01 | ReplaceForWater | D | 0,0 | `0x3B605C14` | `0x00000000` | `0x3B11D573` | `0x3B11D573` | `0x3B11D573` | yes | yes |
| RVW-hil1-02 | ReplaceForWater | D | 22,1 | `0x40771F94` | `0x00000000` | `0x4020A153` | `0x4020A153` | `0x4020A153` | yes | yes |
| RVW-hil1-03 | ReplaceForWater | D | 40,24 | `0x000000DB` | `0x00000000` | `0x0000008E` | `0x0000008E` | `0x0000008E` | yes | yes |
| RVW-g_hil4-01 | ReplaceForWater | D | 28,4 | `0x3FF55FDC` | `0x00000000` | `0x3FF55FDC` | `0x3FF55FDC` | `0x3FF55FDC` | yes | yes |
| RVW-g_hil4-02 | ReplaceForWater | D | 29,16 | `0x3E61587D` | `0x00000000` | `0x3E61587D` | `0x3E61587D` | `0x3E61587D` | yes | yes |
| RVW-k_ravine_1-01 | ReplaceForWater | D | 13,4 | `0xC03DAC13` | `0x00000000` | `0xC03DAC13` | `0xC03DAC13` | `0xC03DAC13` | yes | yes |
| RVW-k_ravine_1-02 | ReplaceForWater | D | 48,1 | `0x4048F2D0` | `0x00000000` | `0x4048F2D0` | `0x4048F2D0` | `0x4048F2D0` | yes | yes |
| RVW-k_ravine_1-03 | ReplaceForWater | D | 0,0 | `0xB9CE03CB` | `0x00000000` | `0xB9CE03CB` | `0xB9CE03CB` | `0xB9CE03CB` | yes | yes |
| REP-hil1-01 | Replace | S | 22,1 | `0x40771F94` | `0x3FA89E45` | `0x4074F076` | `0x4074F076` | `0x40A5B75B` | **NO** | yes |
| REP-kr1-01 | Replace | S | 13,4 | `0xC03DAC13` | `0x403DB22D` | `0x39C341CB` | `0x39C34000` | `0x39C341CB` | yes | **NO** |
| REP-kr1-02 | Replace | S | 48,1 | `0x4048F2D0` | `0x403DB22D` | `0x407DED60` | `0x407DED61` | `0x40C3527F` | **NO** | **NO** |
| REP-kr1-03 | Replace | S | 31,23 | `0x2FB9E537` | `0x403DB22D` | `0x4086D917` | `0x4086D916` | `0x4086D917` | yes | **NO** |
| SMB-hil1-01 | SmoothBlend | S | 22,1 | `0x40771F94` | `0x3FA89E45` | `0x4074F076` | `0x4074F076` | `0x4074F076` | yes | yes |
| SMB-kr1-01 | SmoothBlend | S | 13,4 | `0xC03DAC13` | `0x403DB22D` | `0x39C341CB` | `0x39C34000` | `0x39C341CB` | yes | **NO** |
| SMB-ghil4-01 | SmoothBlend | S | 28,4 | `0x3FF55FDC` | `0x00000000` | `0x3FF55FDC` | `0x3FF55FDC` | `0x3FF55FDC` | yes | yes |
| SMB-kr1-02 | SmoothBlend | S | 31,23 | `0x2FB9E537` | `0x3FA89E45` | `0x401AB589` | `0x401AB589` | `0x3FA89E45` | **NO** | yes |
| SMB-kr1-03 | SmoothBlend | S | 48,1 | `0x4048F2D0` | `0x403DB22D` | `0x40824C5A` | `0x40824C5B` | `0x40824C5A` | yes | **NO** |
| AXIS-kr1-z1x0 | ReplaceForWater | D | 1,0 | `0xBAAC7432` | `0x00000000` | `0xBAAC7432` | `0xBAAC7432` | `0xBAAC7432` | yes | yes |
| AXIS-kr1-z0x1 | ReplaceForWater | D | 0,1 | `0xBA9D9F10` | `0x00000000` | `0xBA9D9F10` | `0xBA9D9F10` | `0xBA9D9F10` | yes | yes |

`base_h` inputs: `0x3FA89E45` = hill `1.31733`; `0x403DB22D` = plateau `2.964`
(both from `spec/04_PATTERN_STAMPING.md:50-51`, donor-derived constants used as
**synthetic test inputs**, not observed world-cell values). `h0/h1` values are in
the JSON (mostly `0.0`; `SMB-kr1-02` uses `h0 = −1.1` water bed, `h1 = 0`,
`SMB-kr1-03` uses `h0 = h1 = −1.1`). Synthetic overrides are itemised per vector:
`REP-kr1-02` uses `Scale=0.649999976158142` (borrowed from `hil1`);
`REP-kr1-03` uses `Offset=1.25`; `SMB-kr1-03` uses `TerrainScale=0.5`.

### Smooth post-pass snapshots [D] (g_hil4 real flags; synthetic world patch)

Centre `(x=16,z=29)`, `Radius=3`, `SmoothOffset=2` → remapped `(tx,tz)=(17,29)`;
factor 4; divisor hardcoded `4.0f`. The world-height patch is the donor `g_hil4`
grid used as a deterministic input (donor world heights not recovered by X13).

| ID | Iteration | In-place bits | Double-buffer bits | Agree |
|---|---|---|---|---|
| SMOOTH-PASS-ghil4-iter1 | 1 | `0x3E0E900E` | `0x3E0C9E9F` | NO |
| SMOOTH-PASS-ghil4-iter2 | 2 | `0x3E1691C8` | `0x3E0AF67A` | NO |
| SMOOTH-PASS-ghil4-iter3 | 3 | `0x3E1AE70E` | `0x3E1608D5` | NO |
| SMOOTH-PASS-ghil4-iter4 | 4 | `0x3E1EB7C7` | `0x3E159A3B` | NO |

---

## Implications for spec §04 and §12 QA

1. **§04 §6 correction [D]:** publish the D05 F4 `Replace` branch in full —
   `h = base_h + ((g-Min)*Scale+Min) + Offset`. The currently circulated
   `base_h+g+Offset` is wrong whenever `Scale≠1` (vector `REP-hil1-01`), and even
   with `Scale=1` the pivot can shift 1 ULP for negative `Min`
   (`REP-kr1-01`). Do not "fix" this by clamping to `Min/Max`.
2. **§04 §3/§7 flag census [O]:** all three target relief patterns are
   `ReplaceForWater=True`; `g_hil4` additionally has `Smooth=True`, so its
   smooth **post-pass runs even on the ReplaceForWater blend branch** (D05 F5
   gates only on `Stand && Smooth`). An implementation that ties the post-pass to
   the Smooth *blend* branch would silently omit it for `g_hil4`.
3. **§12.6 layer 1 (hard determinism) [D]:** add a stamp-cell replay check — I07
   should expose a debug entry taking `(g_bits, flags, base_h_bits, h0_bits,
   h1_bits)` and returning output f32 bits, and match all **8 donor-flag vectors
   bit-exactly** before any visual gate. Synthetic-flag vectors (11) are
   *advisory* until a donor pattern with those branches is found.
4. **§12.6 layer 2 (structural) [D]:** use `AXIS-*` vectors to lock row-major
   `grid[z][x]`; a transposed loader is detectable before rendering. Do not fold
   these into a relaxed threshold.
5. **§12.5 gates [O]:** no gate weakening. `selftest 29/29`, `uitest 17/17`,
   `t_render_mode`, `assert_clean CLEAN`, `app/**` byte-identical remain in force.
   The harness is **input data only**; it does not itself certify the module and
   produces no visual evidence.
6. **§12.6 schema [O]:** keep `parity.status = "UNVERIFIED"` in
   `terrain_qa_report/1`. These vectors establish donor-*formula* agreement only;
   they cannot establish donor pixel parity without a real A/B frame.
7. **[I] No new port constants:** `base_h = 1.31733/2.964`, `Offset = 1.25`,
   `TerrainScale = 0.5`, `h0 = −1.1` are **test inputs**. Unless independently
   recovered, they must never be promoted into the generator.

---

## Risks

- **R1 [U] x87 precision.** The stamp computes in 80-bit extended x87 and stores
  f32 at `setHeight`. Neither Python double nor f32-per-op reproduces it exactly;
  5/19 vectors differ by 1 ULP between the two local models. A Godot/GDScript
  double implementation should use the `D05-d` column, but a 1-ULP mismatch must
  not be auto-labelled a bug until x87 is emulated.
- **R2 [U] Grid start boundary.** F02 U-F02-1 stands: many byte offsets produce
  the same min/max. `G=1000/1912/2866` was accepted from two independent workers
  plus local byte context, not proved from the loader alone.
- **R3 [U] Synthetic branch coverage.** 11/19 vectors change flag bits that were
  never observed true/false in these sections. They test the *formulas*, not donor
  incidence; `Replace=True` has 0/680 incidence (F02/X05).
- **R4 [U] `base_h` unverified.** D05 F4 shows a bilinear world-height sample
  (`sub_810498`) but X13 did not recover the world height field; all `base_h/h0/h1`
  values are constructed inputs.
- **R5 [U] Post-pass update order and mask gating.** In-place vs double-buffer
  diverge at all four iterations; the 8-neighbour occupancy test and radial remap
  over all stamp cells are not exercised by the single-window snapshots.
- **R6 [U] Loader allocation vs on-disk extent.** D05 F1's `(w+1)*(h+1)` allocation
  conflicts with the bit-exact `w*h` on-disk decode; border cells are undefined.
- **R7 [U] No donor frame.** Static bytes and arithmetic only. No donor-parity
  claim, consistent with the charter's guardrail.

---

## UNVERIFIED register

| ID | Claim | Status / passes attempted |
|---|---|---|
| U1 | File row `v` → sign of centred world y (row-sign flip) | **[U]** D05 U1; P1–P3 bind row→`z` and row-major indexing, not file-row sign. Keep `PORT APPROXIMATION` |
| U2 | Exact rounding of rotated sub-cell coordinates | **[U]** D05 U3; X13 performed no rotation arithmetic (all vectors use `RotationAngle=0` from donor). No guess |
| U3 | Global `setHeight` clamp / map-wide ceiling | **[U]** D05 U2/R4; `sub_0059b934` not studied by X13. The stamp itself has no `[+0x60]` read (D05 E15) |
| U4 | True x87 80-bit float result | **[U]** P5 ran double and f32 models only; 1-ULP differences remain unresolved. No 80-bit emulator attempted |
| U5 | Exact on-disk float-plane start byte | **[U]** P2/P3: `G` accepted from F02+X05 and byte context; min/max alone admit many starts (F02 U-F02-1) |
| U6 | Post-pass in-place vs double-buffer update order | **[U]** P6: 4/4 iterations diverge; D05 F5 pseudocode does not settle it |
| U7 | HeightFieldSmooth mask gating / full radial remap | **[U]** D05 F5; harness uses one remapped window and a synthetic patch, not the 8-neighbour occupancy test |
| U8 | `HeightFieldMax` unused by *all* engine paths | **[U]** D05 E15 proves only its absence inside `sub_755f30`; editor/brush paths not checked |
| U9 | Donor incidence of `Replace=true`, `TerrainScale≠1`, `Offset≠0` | **[U]** F02/X05 census shows 0/680 for `Replace` and 680/680 `TerrainScale=1`, `Offset=0`; synthetic overrides are labelled |
| U10 | Visual parity with donor | **[U]** no donor GPU A/B frame. **No parity claim** |

---

## Open questions

1. Will I07 expose the debug entry point needed to replay these bit patterns, or
   must QA drive the stamp through a dumped height stream?
2. Can X12's independent native verification (or a second pass on `sub_755db4`
   assembly) settle the in-place vs double-buffer post-pass order?
3. Does `sub_0059b934` clamp world heights after the setter, and would that
   explain the baked −2.964 ceiling noted in D05's Q1?
4. Which `(w+1)*(h+1)` border cells does the loader actually stamp, and are they
   zero-initialised? (D05 F1 vs F02 `w*h` decode.)
5. Is there any donor pattern outside the three studied here with `Replace=true`
   or a nonzero `HeightFieldOffset`, so the synthetic vectors can be replaced by
   donor-flag ones?
6. Should the smooth post-pass gate be tied to `HeightFieldSmooth` alone or to
   the blend branch as well? D05 F5 says alone; `g_hil4` is the discriminator.

---

*End of X13 report. Exactly one repo file written. Donor read-only; prototype and
vectors in the temp directory only. No source/asset/config/test/git/Godot change.
No donor parity claimed.*
