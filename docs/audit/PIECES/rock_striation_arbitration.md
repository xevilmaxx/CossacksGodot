# rock_striation_arbitration.md — authoritative measurement of `rock1..9` vertical striation

Scope: **RESEARCH / ARBITRATION only.** This is the single file written by this agent.
No code edits, no Godot run, no donor binary or texture copied into the repo. All
Pillow work was done read-only from the donor install and wrote **only** to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (scripts + PNGs listed in
§4). Donor paths were opened read-only; port PNGs were read, never written.

Purpose: settle the conflict between `ravine_face.md` (rock8 = correctly fluted, right
art) and `shore_rock.md` (rock1 = most striated 1.41; rock8 = near-uniform 0.91)
**before any build ticket** is written.

---

## 1. Method — precise, repeatable metric

### 1.1 Inputs and preprocessing

- Port tiles: `app/assets/terrain/blocks/rock1.png … rock9.png`, all **1024×1024 RGB**.
- Donor originals (read-only): `C:\Games\Cossacks 3\data\terrain\tiles\textures\rock1.dds … rock9.dds`, all **1024×1024 RGBA, 699,192 B**.
- Donor reference JPEG (read-only): `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (1280×720).
- Every tile is converted to luminance `L` (ITU-R 601-2 luma, Pillow `convert("L")`), then
  downsampled with **LANCZOS to a fixed 256×256** so all nine are compared on one grid.
  A native-1024² pass was also run to check scale stability (§2.3).

### 1.2 Primary metric — Vertical Striation Index (VSI), gradient-energy ratio

Let `S = GaussianBlur(L, radius=1)`. Let centered differences on the same grid be

```
gx(x,y) = ∂S/∂x   (column direction)
gy(x,y) = ∂S/∂y   (row direction)
Ex = mean(gx²)    Ey = mean(gy²)
VSI = Ex / Ey
```

A **vertical** flute (elongated along y, intensity varying along x) gives large `gx`,
small `gy` → **VSI > 1**. Isotropic/diagonal → VSI ≈ 1. Horizontal striation → VSI < 1.
This is the same physical quantity as `ravine_face.md`'s dx/dy, but computed as
squared-gradient energy with a centered difference (more stable than a single ±1 px
forward difference).

### 1.3 Secondary metrics (cross-checks, each answers a different question)

| Metric | Formula | What it senses |
|--------|---------|----------------|
| **AGR** | `mean(|gx|) / mean(|gy|)` on `S` | Fine-scale abs-gradient ratio — directly reproducible with `ravine_face.md`'s `ImageChops.difference` ±1 px method |
| **BA** | `pstdev(L.mean(axis=0)) / pstdev(L.mean(axis=1))` = colSD/rowSD | **Coarse** left↔right banding vs top↔bottom banding — the `shore_rock.md` method (also computed at 4-px stride, `BA4`) |
| **coh / θ** | structure tensor `J=[[Ex,Jxy],[Jxy,Ey]]`, `coh=√((Ex−Ey)²+4Jxy²)/(Ex+Ey)`, `θ=½ atan2(2Jxy, Ex−Ey)` | Orientation purity and dominant gradient direction (θ≈0° = vertical flutes; θ≈±90° = horizontal; θ≈±45° = diagonal) |

**Why three metrics:** VSI/AGR are *high-frequency* (local flutes); BA is a *low-frequency*
(whole-column) statistic. A tile can carry fine vertical flutes yet be coarse-uniform —
exactly the rock8 case — so a single metric cannot settle this conflict. Agreement across
all three = **High** confidence; agreement across two or large magnitude = **Medium**;
disagreement or near-1 values = **Low**.

### 1.4 Reproduction

```
python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rock_striation_measure.py
python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rock_striation_donor_face.py
```
Environment: Python 3, Pillow 12.1.1, NumPy 2.4.3. All thresholds above are fixed; no randomness.

---

## 2. Measurements

### 2.1 Pixel identity — port PNG vs donor DDS (native 1024², RGB channels)

| tile | mean abs diff (RGB) | fraction exact pixels | DDS alpha |
|------|--------------------|-----------------------|-----------|
| rock1 … rock9 | **0.0000** (all nine) | **1.0000** (all nine) | 255..255 (opaque) |

**Observed:** every port `rockN.png` is a byte-exact RGB copy of its donor `rockN.dds`.
Therefore both conflicting docs measured **the same underlying pixels** — the disagreement
cannot be a conversion/asset drift and must be metric or interpretation. This is the
single most important fact of the arbitration.

### 2.2 All nine port rocks — 256² LANCZOS (primary table)

| rock id | VSI (Ex/Ey) | AGR (\|gx\|/\|gy\|) | BA (colSD/rowSD) | BA4 | coh | θ (deg) | confidence | visual class |
|---------|-------------|---------------------|------------------|-----|-----|---------|------------|--------------|
| **rock1** | **4.289** | 2.087 | **1.418** | 1.398 | 0.622 | 0.7 | **High** | strong vertical flutes, all scales |
| rock2 | 0.231 | 0.475 | 0.705 | 0.698 | 0.625 | −89.3 | High | horizontal striations |
| rock3 | 0.231 | 0.475 | 0.705 | 0.709 | 0.625 | +89.3 | High | horizontal striations (mirror of rock2) |
| rock4 | 1.460 | 1.185 | 0.568 | 0.584 | 0.187 | −1.1 | Medium | weak fine-vertical, coarse-horizontal, low purity |
| rock5 | 0.481 | 0.685 | 0.809 | 0.811 | 0.365 | −81.9 | High | pebbly / horizontal-mossy |
| rock6 | 0.979 | 0.997 | 1.070 | 1.067 | 0.675 | +45.5 | Low | strong **diagonal** (equal x/y energy) |
| rock7 | 0.979 | 0.997 | 1.070 | 1.073 | 0.675 | −45.5 | Low | strong **diagonal** (equal x/y energy) |
| **rock8** | **1.661** | 1.294 | **0.877** | 0.916 | 0.250 | 3.5 | Medium | fine vertical flutes, coarse-uniform olive fill |
| rock9 | 1.165 | 1.064 | 0.658 | 0.691 | 0.096 | 18.7 | Medium | weak/mixed, low purity |

Read: only **rock1** is unambiguously, strongly vertical at *every* scale (VSI 4.29 **and**
BA 1.42, θ≈0°, high purity). **rock8** is the interesting split case: its *fine* flutes are
vertical (VSI 1.66 at 256², AGR 1.29) but its *coarse* structure is essentially uniform
(BA 0.88, coh 0.25) — it is an olive fill with a faint vertical grain, not a boldly
striated skin. rock2/3/5 are horizontal; rock6/7 are diagonal (their VSI≈1 is not
"neutral" — the coherence/θ columns show a strong single diagonal orientation).

### 2.3 Scale stability (native 1024² vs 256²)

| tile | VSI @1024² | VSI @256² |
|------|-----------|-----------|
| rock1 | 2.885 | 4.289 |
| rock8 | 1.329 | 1.661 |
| rock4 | 1.503 | 1.460 |

Downsampling raises fine-flute energy (the 256² pass suppresses sub-pixel noise and
emphasizes the 2–8 px flutes), but **preserves the ranking** rock1 > rock4 ≈ rock8 and the
sign (all >1). `ravine_face.md`'s quoted dx/dy **1.24–1.28 for rock8 matches my native-1024
VSI 1.329 / AGR 1.29** — their measurement is reproducible.

### 2.4 Donor ravine target — primary JPEG `cossacks-3-v1-498085.jpg`

Explicit comparison target, box **(560,150,1000,560)** = 440×410, sampled as instructed:

| region (source px) | VSI | AGR | BA | coh | θ | confidence | note |
|--------------------|-----|-----|----|-----|---|------------|------|
| **primary full box (560,150,1000,560)** | **1.218** | 1.045 | 1.010 | 0.135 | −21.6 | Medium | whole crop; only ~18% is rock face, rest grass/trees/shadow → diluted |
| same box, 256² LANCZOS | 1.386 | 1.097 | 1.010 | 0.196 | −17.1 | Medium | consistent with above |
| face within primary, right wall (900,360,1000,540) | 1.529 | 1.266 | 0.765 | 0.336 | −25.8 | Medium | actual striated wall |
| face within primary, lower-right (860,420,1000,560) | 1.455 | 1.230 | 1.287 | 0.354 | −29.2 | High | actual striated wall |
| tight lit face (948,385,1012,450), `shore_rock.md` box | 2.900 | 1.825 | 6.354 | 0.577 | −16.2 | High | clean crest-only target |

**Interpretation:** the *rendered* donor face's own texture anisotropy is modest
(VSI ≈ **1.45–1.53** over face sub-boxes), rising to ≈2.9 only on the clean sunlit crest;
the full primary box reads ≈1.2 because grass plateau dominates. The flutes are amplified
in the final image by wall geometry + intrinsic lit/shadow shading (as `ravine_face.md`
already noted: intrinsic 1.24 → rendered 1.69). This matches **rock8's native range
(1.33)** very closely; rock1 (2.9–4.3) overshoots the *average* face but matches the
*crest* sub-box.

---

## 3. Contact-sheet evidence (visual confirmation)

Files (temp dir only):

- `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rock_striation_contact_sheet.png` — 3×3 grid of all nine tiles (256² each), labelled with VSI and BA.
- `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rock_striation_donor_crop.png` — the primary donor crop (560,150,1000,560).

Inspection result (eyes agree with numbers):

- **rock1** — unmistakable near-vertical wavy flutes, strongest of the nine. ✓ VSI 4.29.
- **rock2 / rock3** — flutes run **horizontally**, mirror-symmetric. ✓ VSI 0.23.
- **rock4** — faint, mottled, no bold direction; coarse bands are horizontal. ✓ VSI 1.46 / BA 0.57 / coh 0.19.
- **rock5** — mossy pebbles, horizontal-leaning. ✓ VSI 0.48.
- **rock6 / rock7** — pronounced **diagonal** ridges (~45°/135°), not vertical. ✓ VSI ≈0.98 but coh 0.675, θ ±45°.
- **rock8** — olive/olive-yellow, near-uniform at a glance, with a *faint* vertical grain on close look. ✓ VSI 1.66 fine, BA 0.88 coarse.
- **rock9** — muted olive pebbles, weak. ✓ VSI 1.16, coh 0.096.
- **Donor crop** — near-vertical wall on the right/lower-right with fine vertical flutes and abrupt grass rim; the plateau occupies most of the frame, explaining the low whole-box VSI.

No contradiction between the numeric ranking and the visual sheet.

---

## 4. Verdict

1. **Most vertically striated tile — rock1.** It is the only tile strong at both frequency
   bands (fine VSI 4.29, coarse BA 1.42, θ≈0°, high coherence). If the build ticket asks
   "which art supplies vertical striations," the answer is **rock1**. This confirms
   `shore_rock.md`'s ranking.

2. **Best single tile for the donor ravine *face as rendered* — rock8.** Its native
   anisotropy (VSI 1.33) sits essentially on top of the donor face sub-boxes (VSI
   1.45–1.53), it carries genuine fine vertical flutes (AGR 1.29), it is the donor's
   actual `abs(h)>2.7` high-face tile, and its olive palette matches the donor face.
   Its weakness is coarse uniformity (BA 0.88), so it will not read as striated at a
   distance without geometry/shading. This confirms `ravine_face.md`'s "right art" claim.

3. **Recommended combination (unblocks the ticket):** use **rock8 as the high-face fill**
   (palette + donor role + matching moderate anisotropy) and layer/stretch **rock1 flutes**
   — or geometry-driven lit/shadow shading — to supply pronounced striations. This is a
   synthesis, not a compromise: both source docs' recipes already converge on
   "rock8 block + accent/stretch" (`ravine_face.md` §2.4 stretch×2; `shore_rock.md` §1.3 /
   JSON `rock8` + `rock_stones1` accent).

4. **Unsuitable as a vertical face skin:** rock2, rock3, rock5 (horizontal, VSI 0.23–0.48);
   rock6, rock7 (diagonal, θ≈±45°, no vertical preference); rock9 (weak, incoherent).
   rock4 is marginal (low coherence) and should not be relied on for striation.

---

## 5. Reconciliation of the two conflicting claims (explicit)

| Question | `ravine_face.md` | `shore_rock.md` | This arbitration | Who is right? |
|----------|------------------|-----------------|------------------|---------------|
| Are the measured pixels the same? | port PNG vs donor DDS | donor DDS | byte-identical, all 9 (MAD 0, exact 1.0) | **Both** — same pixels |
| rock8 fine vertical flutes | dx/dy ≈ **1.24–1.28** | (not measured at fine scale) | AGR **1.294** @256², VSI **1.329** @1024² | **ravine_face confirmed** — rock8 does have real fine flutes |
| rock8 coarse striation | "correct vertical flutes" | BA **0.91** = near-uniform yellow | BA **0.877** (BA4 0.916) @256² | **shore_rock confirmed** — rock8 is coarse-uniform |
| rock1 ranking | "strongest flutes" (dx/dy 1.98) | **1.41** = most striated | VSI **4.29**, AGR 2.09, BA **1.418** | **Both** — rock1 is strongest; its BA 1.418 reproduces 1.41 exactly |

Root cause of the conflict — three independent reasons, in order:

1. **Different frequency bands / metrics.** `ravine_face.md` used a *local blurred
   abs-gradient ratio* (fine flutes, ~1–2 px); `shore_rock.md` used a *whole-column vs
   whole-row luminance stddev* (coarse, full-tile banding, 4-px stride). rock8 is
   high-fine/low-coarse; rock1 is high on both. The two numbers 1.28 and 0.91 are not
   contradictory — they describe different scales of the same tile.
2. **Different crop / target.** `ravine_face.md` reasoned from the *rendered fluted face*
   (geometry + shading amplify texture anisotropy to 1.69); `shore_rock.md` measured the
   *raw texture block* and a tight lit-face sub-box (BA 6.35). The whole primary box
   (560,150,1000,560) is only VSI 1.22 because ~82% of it is not face.
3. **Different meaning of "right art."** `ravine_face.md` meant "the donor's designated
   high-face fill, already available" (a *role/fill* claim); `shore_rock.md` meant "the
   tile with the strongest striation character" (an *art-property* claim). rock8 wins the
   first, rock1 wins the second. They were answering different questions.

**Bottom line:** there is no factual error in either doc — both sets of numbers reproduce
exactly. The build ticket must stop treating "rock8 vs rock1" as an either/or: use rock8
for the face fill (role + palette + donor-matched anisotropy) and rock1 (or shading) for
the striation signal.

---

## 6. Claim table (labels: observed / derived / inferred)

| # | Claim | Evidence | Method | Label |
|---|-------|----------|--------|-------|
| 1 | All 9 port `rockN.png` are RGB-identical to donor `rockN.dds` | §2.1: MAD 0.0000, exact 1.0000, alpha 255 | Pixel diff @1024² | **observed** |
| 2 | rock1 VSI 4.289 / AGR 2.087 / BA 1.418 — strongest vertical striation | §2.2 | Three metrics @256² | **derived** |
| 3 | rock8 VSI 1.661@256² / 1.329@1024², AGR 1.294, BA 0.877 — fine-vertical, coarse-uniform | §2.2–2.3 | Three metrics + scale check | **derived** |
| 4 | `ravine_face.md` dx/dy 1.24–1.28 for rock8 is reproducible | §2.3 native VSI 1.329 / AGR 1.294 | Same blurred-gradient family | **derived** |
| 5 | `shore_rock.md` BA 1.41 (rock1) and 0.91 (rock8) are reproducible | §2.2 BA 1.418 / 0.877 (BA4 0.916) | Same colSD/rowSD family | **derived** |
| 6 | rock2/3/5 horizontal; rock6/7 diagonal; rock9 weak | §2.2 θ ±89° / ±45°, VSI 0.23–0.98, coh | Structure tensor + sheet | **observed** (sheet), **derived** (θ) |
| 7 | Donor primary box VSI 1.218; face sub-boxes 1.45–1.53; lit crest 2.90 | §2.4 | Same metrics on JPEG | **derived** |
| 8 | Donor rock area is ~18% of primary box → whole-box metric diluted | `ravine_face.md` §1.3 (17.9%) + §2.4 | Prior strict classifier | **derived** (from prior) |
| 9 | Geometry/shading amplify rock8's 1.33 to rendered ~1.5–1.69 | §2.4 vs §2.3 | Donor render vs texture comparison | **inferred** (plausible; not isolated by a controlled render) |
| 10 | rock8 = best single *fill*; rock1 = best *striation source*; combination recommended | §4 | Synthesis of 2–9 + donor role | **inferred** (design recommendation) |
| 11 | Both docs' numbers are correct; conflict is metric/crop/semantic | §5 | Reproduction of both methods | **derived** |

Open / out of scope: no Godot render was produced, so the final on-screen striation of any
composited piece remains **UNVERIFIED** (same caveat as `shore_rock.md` C12). Palette
match (rock8 olive vs rock1 brown) was judged from the contact sheet and the docs' hex
anchors, not re-measured here.

**End.**
