---
id: FCOL-02
ticket: "WAVE FIELD-COLOUR / FCOL-02"
title: "Donor truth — field/farm decal colour, brightness constants and summer/winter difference"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
scope: "One report written. No runner job, no Godot run, no code/asset/config/test/git edit. Donor read READ-ONLY by text/header reads and Pillow/Numpy pixel statistics; nothing copied into the repo, executed or rendered in-engine."
donor_root: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use)"
reference_root: "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3 (READ-ONLY screenshot samples)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
visual_parity_claim: false
---

# FCOL-02 — Donor truth: field colour and brightness

## 0. Mandate and evidence discipline

Owner directive: **"mill fields are too dark."** This ticket establishes **donor truth only** for
field/farm decal **colour and brightness**. It does not propose the port fix, does not audit the
port render beyond the PNG bytes needed to locate where the darkness can and cannot live, and makes
**no donor-parity claim** — no donor GPU A/B frame exists (CHARTER.md:55-69, 122-131;
WAVE_G_CHARTER.md:11-13). No runner job was submitted; G04 remains the sole Godot owner.

Labels are literal:

- **OBSERVED** — a donor/repo file line or a decoded pixel value was read here this session.
- **DERIVED** — deterministic arithmetic or byte comparison over OBSERVED values.
- **INFERRED** — plausible reading, explicitly not proven from readable text.
- **UNVERIFIED** — cannot be proven from readable donor text; do not promote.

Path convention: **`D:` = `C:\Games\Cossacks 3\data\`**, **`R:` = `C:\Users\Maxym.Oboyshev\Downloads\c3\`**,
repo paths relative to the workspace root. All line numbers are 1-based as read this session.
Pixel work used Pillow 12.1.1 / NumPy 2.4.3; probe scripts and crop PNGs lived **only** in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.

---

## 1. Sources

### 1.1 Donor text read directly (READ-ONLY)

| Role | Donor path:lines |
|---|---|
| Decal descriptor (season pair, footprint) | `D:terrain\decals\decals.lib:1-36` (template), `:37-44` (`envfieldd`) |
| Decal material + blend/alpha/brightness defaults | `D:terrain\decals\decals.mat:1-40` (default section), `:110-115` (`envfieldd`/`envfielddw`) |
| Decal preload | `D:scripts\lib\miscext2.script:772` |
| Decal pixel payloads | `D:terrain\decals\env\envfieldd.dds`, `D:terrain\decals\env\envfielddw.dds` (headers + Pillow decode) |
| Decal fragment/vertex shader | `D:shaders\obj\dec.pvl.smx3.frag:1-46`; `D:shaders\obj\dec.pvl.sm.vert:1-37`; `D:shaders\shaders.lib:131-155` (`Decal` family) |
| Default object shader (crop mesh) | `D:shaders\obj\def.pvl.sm.vert:1-46`; `D:shaders\obj\def.pvl.smx3.frag:1-48`; `D:shaders\shaders.lib:53-78` |
| `texscalefix` (the only field scale constant) | `D:scripts\lib\misc.script:4284-4306` (`_misc_PlaceFieldDecal`) |
| Crop-mesh material + season selection | `D:objects\env\field.prop:30-39,41-129,139-157`; `D:materials\env\env.mat:49-149` (summer), `:864-973` (winter); `D:materials\ref\refbase.mat:1-109` |
| Crop-mesh textures (the other field art) | `D:materials\env\field*.dds` (headers + Pillow decode) |

### 1.2 Repo files read (secondary, all OBSERVED as repo text)

`docs/terrain_swarm_2026-11-25/CHARTER.md`, `WAVE_G_CHARTER.md`,
`docs/terrain_swarm_2026-11-25/reports/F2_02_donor_fields_mines.md` (claims F1–F3, §3.1–3.2),
`docs/coord_swarm_2026-11-25/reports/DTRN_06_donor_grass_decals.md` (C18–C21, Q8),
`docs/audit/PIECES/field_crops.md` (§1.1–1.4, §5),
`variant3d/assets/terrain/deco_png/envfieldd.png{,.import}`, `envfielddw.png`,
`app/assets/terrain/deco_png/envfieldd.png`, `envfielddw.png`,
`variant3d/scripts/world.gd:2523-2614` (render-time tint context — **PORT**, not donor truth).

### 1.3 Online (corroboration only; not primary donor truth)

- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/assets/game-icons/units/field.png`
  — downloaded to temp and decoded this session: 46×46 opaque wheat-sheaf icon, mean RGB
  `(131.7, 95.7, 24.6)` = `#846019`, golden-pixel mean `#9A6E15`, L 113.2 (OBSERVED; icon,
  not a gameplay frame). Corroborates that "field" is canonically **golden**, not olive.
- `https://github.com/anyalink99/cossacks-3-almanac` — repository tree read via GitHub API this
  session; no field-*colour/lighting* evidence doc was found in the browsed paths, so no online
  claim is made about donor brightness constants.

---

## 2. Claim table

| # | Claim | Evidence | Label | Caveat |
|---|---|---|---|---|
| FC1 | `envfieldd`/`envfielddw` are 512² DXT5 decals with 10 mips; opaque means summer `(77.2,68.4,46.1)`=`#4D442E`, winter `(116.7,111.1,97.1)`=`#756F61` | DDS headers + Pillow stats; `decals.mat:110-115` | OBSERVED | Pillow DXT5 decode; independently matches `field_crops.md:38` |
| FC2 | Decal **RGB art is olive/brown (summer) and neutral grey (winter), not golden** | same pixels | OBSERVED | Gold in screenshots is render-time — INFERRED here, as in `field_crops.md:46-47` |
| FC3 | Decal material: `BlendingMode=bmTransparency`, `imagealpha=tiaDefault`, `texturemode=tmModulate`, `maLinear`/`miLinearMipmapLinear`, `moIgnoreFog=True`, **`imagebrightness=1`, `ImageGamma=1`** — no brightness gain | `decals.mat:1-37`; envfieldd section `:110-112` overrides only Name+image | OBSERVED | Inheritance from the `default` section; no per-decal override exists |
| FC4 | Decal fragment: `color = tex0*(ambient+diffuse)+specular`; `color.a = tex0.a*gl_FrontMaterial.diffuse.a` — RGB modulated by lighting, alpha is coverage | `dec.pvl.smx3.frag:10-14`; `dec.pvl.sm.vert:16-26` | OBSERVED | Diffuse alpha = 1 by default (`refbase.mat:63,91`) ⇒ alpha = `tex0.a` |
| FC5 | **`texscalefix = 1.3` is a geometry/UV scale, NOT brightness**: `w=h=scale*goScale*1.3`, `texscale0/1 *=1.3`, `texOff0/1=-(1.3-1)/2=-0.15` | `misc.script:4298-4305` | OBSERVED | No colour/brightness term in this routine |
| FC6 | No `gamma`/`brightness` token in donor decal material or the scanned shader/game-text paths | `decals.mat:25-26`; targeted scan of `D:shaders\obj` and `D:game` returned 0 hits | OBSERVED (scan) | Unread compiled binary/renderer is UNVERIFIED |
| FC7 | Season binding is explicit: `SummerLibMaterialName=envfieldd`, `WinterLibMaterialName=envfielddw`; alpha is **byte-identical** between seasons, only RGB changes | `decals.lib:40-41`; alpha stats mean 148.12 / bbox (17,19)-(493,493) both files | OBSERVED / DERIVED | Matches DTRN-06 C20, F2-02 F1 |
| FC8 | Winter decal is ~**43.5 L brighter** and desaturated vs summer (meanL 110.83 vs 67.38) | Pillow stats; `L=0.299R+0.587G+0.114B` | DERIVED | Arithmetic over OBSERVED pixels |
| FC9 | Crop mesh also switches season materials: summer `field1..4`/`field`, winter `field1w..4w`/`fieldw` (`UseSeasonMaterial=True`) | `field.prop:58-76,87-126` | OBSERVED | Which random variant is drawn per node UNVERIFIED |
| FC10 | Crop-mesh materials are **unlit/emissive**: Ambient=0, Diffuse=0; `field`/`fieldw` Emission `(0.9098,0.8549,0.7647)` (warm), `field1..4`/`field1w..4w` Emission `0.78125` neutral | `env.mat:50-149,864-973`; `refbase.mat:52-106` | OBSERVED | These are the **only** numeric field brightness/tint constants found in donor text |
| FC11 | Crop-mesh textures are also dark pre-lighting (summer L 46–70, winter L 94–114), winter ~+36…+43 L brighter per variant | Pillow decode of 16 `field*.dds` | OBSERVED / DERIVED | See §4.3 table |
| FC12 | Reference c3 fields are **golden**: clean crops mean `#93752B` (L 117.8) and `#937024` (L 113.9), H 41.4–42.6°, S 0.734–0.764, V 0.549–0.578 | `R:523480776.jpg` `(520,25,700,205)`; `R:Cossacks3AttackingVillage.webp` `(1580,180,1930,530)`; own Pillow/HSV measurement | OBSERVED / DERIVED | These are post-lighting JPEGs, not donor GPU frames |
| FC13 | Raw summer decal → reference field gap is ~**+45…+51 L** | DERIVED: 112–118 (FC12) − 67.4 (FC1) | DERIVED | Cause (lighting/gamma/tint) INFERRED / UNVERIFIED; **not** a donor constant |
| FC14 | Port PNGs `variant3d/.../envfieldd.png` + `envfielddw.png` are **byte-identical** to donor DDS-decoded RGBA (MAD 0.0, all 256 alpha levels, a==255 fraction 0.2585) | own Numpy equality vs donor decode; `.import` `:16-40` | OBSERVED / DERIVED | Corrects the older "alpha flattened" state recorded in `DTRN_06` C26 / `field_crops.md:66-72,185` |
| FC15 | The port's gold lift is a **PORT APPROX**, not donor: ripe summer decal drawn with modulate `Color(3.3,2.5,1.0, 0.42+0.28g)` | `variant3d/scripts/world.gd:2592-2605` | OBSERVED (port) | Stated only to locate the render-time stage; no fix proposed |

**Not promoted:** exact on-screen donor brightness multiplier, whether the emission constant is a
multiplier or an additive term inside `gl_FrontLightModelProduct.sceneColor` (INFERRED from fixed-function
GL semantics, not observable in readable donor text), which field-material variant is selected at
runtime, and any donor GPU A/B parity — all UNVERIFIED.

---

## 3. The `envfieldd` texture(s) — DDS mean RGB (FC1, FC2, FC7, FC8)

Headers (OBSERVED): `DDS ` magic, hsize 124, **DXT5**, **512×512**, **10 mips**,
file size 349,680 B for **both** files. Pillow decodes to RGBA.

| Statistic (Pillow, 512²) | `envfieldd` (summer) | `envfielddw` (winter) | Label |
|---|---|---|---|
| All-pixel mean RGB | `(75.57, 67.52, 45.24)` = `#4C442D` | `(115.94, 110.92, 96.96)` = `#746F61` | OBSERVED |
| Opaque (a>250) mean RGB | `(77.22, 68.39, 46.08)` = **`#4D442E`** | `(116.65, 111.14, 97.13)` = **`#756F61`** | OBSERVED |
| Covered (a>8) mean RGB | `(75.85, 67.73, 45.43)` = `#4C442D` | `(117.41, 112.43, 98.72)` = `#757063` | OBSERVED |
| Median RGB (covered) | `(73, 65, 43)` | `(115, 112, 98)` | OBSERVED |
| Mean luminance L (covered) | **67.38** | **110.83** | DERIVED |
| L p10 / p50 / p90 (covered) | 43.3 / 65.0 / 94.9 | 77.7 / 112.6 / 145.9 | DERIVED |
| Std L (all pixels) | 20.01 | 27.15 | DERIVED |
| Alpha min/max/mean | 0 / 255 / 148.12 | identical | OBSERVED |
| Alpha bbox (a>8) | `(17,19)`–`(493,493)` = 477×475 | identical | OBSERVED |
| Opaque (a==255) fraction | 0.2585 | 0.2585 | OBSERVED |

Cross-check: the a>250 means reproduce `docs/audit/PIECES/field_crops.md:38` exactly
(`#4D442E` / `#756F61`), and the alpha bbox reproduces `F2_02_donor_fields_mines.md:95,130`.

**Derivation (FC8):** `ΔL = 110.83 − 67.38 = +43.45`. The same season pair preserves coverage
byte-for-byte and changes only the RGB fill — so the donor's summer→winter field change is a
**desaturating brightening**, not a geometry or alpha change.

---

## 4. Blend, alpha and every brightness-related constant in the donor field path

### 4.1 Decal material + shader (FC3, FC4)

- `D:decals.mat:1-37` (`default` section) sets: `BlendingMode = bmTransparency` (`:17`),
  `moIgnoreFog = True` (`:20`), `moNoLighting = False` (`:21`), `imagebrightness = 1` (`:25`),
  `ImageGamma = 1` (`:26`), `imagealpha = tiaDefault` (`:31`), `magfilter = maLinear` (`:32`),
  `minfilter = miLinearMipmapLinear` (`:33`), `texturemode = tmModulate` (`:36`).
- `D:decals.mat:110-112` defines `envfieldd` (and `:113-115` `envfielddw`) with **only**
  `Material.Name` and `Material.Texture.image` — so every default above is inherited. There is
  **no decal-side brightness, gamma or tint gain** (OBSERVED).
- `D:dec.pvl.smx3.frag:10-14`:
  `vec4 tex0 = texture2D(texUnit0, gl_TexCoord[0].xy);`
  `vec4 color = tex0*gl_TexCoord[4]+gl_TexCoord[5];`
  `color.a = tex0.a*gl_FrontMaterial.diffuse.a;`
  `gl_TexCoord[4]=ambient+diffuse`, `gl_TexCoord[5]=specular` (`dec.pvl.sm.vert:16-26`).
  With default diffuse alpha 1 (`D:materials\ref\refbase.mat:63,91`), **alpha = DXT5 coverage**,
  applied by `bmTransparency` as ordinary src-alpha blending. RGB is *modulated* by lighting,
  never replaced. Shadow 3-tap PCF and fog follow at `:17-42` (fog off for decals by `moIgnoreFog`).
  This agrees with DTRN-06 C18/C19.

### 4.2 `texscalefix` is NOT brightness (FC5)

`D:scripts\lib\misc.script:4286-4306` (`_misc_PlaceFieldDecal`):

```
4288:  const decalname = 'envfieldd';
4293:  var goScale := GetGameObjectScaleXByHandle(goHnd);
4295:  var decHnd := AddNewDecalByLibName(goHnd, x, z, rollangle, lib, name);
4298:  const texscalefix = 1.3;
4299:  w := scale*goScale*texscalefix;
4300:  h := scale*goScale*texscalefix;
4301:  texscale0 := texscale0*texscalefix;
4302:  texscale1 := texscale1*texscalefix;
4303:  texOff0 := -(texscalefix-1)/2;     // = -0.15
4304:  texOff1 := -(texscalefix-1)/2;     // = -0.15
4305:  SetDecalDataByHandle(...);
```

Every use of `1.3` changes **size/UV**, not RGB or alpha. The descriptor footprint is 2×2
(`decals.lib:42-43`), template `texscale=1/1`, `epsilon=0.01` (`decals.lib:24-29`). No colour
constant appears in this routine. Preload is `D:scripts\lib\miscext2.script:772`.

### 4.3 The other field art: crop-mesh materials (FC9, FC10, FC11)

`D:objects\env\field.prop:31-38` binds meshes `field1/2/3.mesh`; `:58-76` and `:87-126` set
`UseSeasonMaterial = True` with summer `field1..4`/`field` and winter `field1w..4w`/`fieldw`.
`D:materials\env\env.mat` registers these (`:50-149`, `:864-973`) with **Ambient=0, Diffuse=0,
Emission** set:

| Material | Emission (R,G,B) | Hex | Lines |
|---|---|---|---|
| `field`, `fieldw` | `(0.909804, 0.854902, 0.764706)` = (232,218,195)/255 — warm | `#E8DAC3` | `env.mat:58-69`, `:873-884` |
| `field1..4`, `field1w..4w` | `(0.78125, 0.78125, 0.78125)` = 200/255 — neutral | `#C8C8C8` | `env.mat:80-91`, `:102-113`, `:124-135`, `:146-157`, `:895-906`, `:917-928`, `:939-950`, `:961-972` |

`D:materials\ref\refbase.mat:52-106` shows the inherited defaults (Ambient 0.25, Diffuse 0.78125,
Emission 0); the field sections deliberately **zero ambient/diffuse and set emission**, i.e. an
unlit self-tinted crop. In the donor's default shader, `ambient = sceneColor + lightProduct.ambient`
(`def.pvl.sm.vert:19`), `gl_TexCoord[4]=ambient+diffuse` (`:34`), and `color=tex0*gl_TexCoord[4]+gl_TexCoord[5]`
(`def.pvl.smx3.frag:13`) — so emission reaches the fragment through `sceneColor`. **INFERRED**
(GL fixed-function semantics; the compiled renderer is UNVERIFIED): the crop is texture multiplied
by the emission tint, with no diffuse sun response.

Decoded crop textures (`D:materials\env\field*.dds`, 512×256 DXT5, 10 mips; covered a>8 means):

| Texture | mean RGB | hex | L | Winter counterpart | L | ΔL |
|---|---|---|---|---|---|---|
| `field.dds` | (80.4,62.8,15.6) | `#503F10` | 62.7 | `fieldw.dds` (114.2,106.3,85.9) `#726A56` | 106.3 | +43.6 |
| `field1.dds` | (62.8,71.1,6.0) | `#3F4706` | 61.2 | `field1w.dds` (114.5,119.9,85.0) `#737855` | 114.3 | +53.1 |
| `field2.dds` | (55.5,62.2,10.6) | `#373E0B` | 54.3 | `field2w.dds` (94.7,99.7,66.4) `#5F6442` | 94.4 | +40.1 |
| `field3.dds` | (77.0,76.4,9.2) | `#4D4C09` | 68.9 | `field3w.dds` (116.7,117.0,75.1) `#75754B` | 112.2 | +43.3 |
| `field4.dds` | (83.7,74.8,13.1) | `#544B0D` | 70.4 | `field4w.dds` (115.1,109.6,68.3) `#736E44` | 106.6 | +36.2 |

(also decoded: `field5/6/7` + `w` variants, L 46–60 summer / 96–102 winter; not referenced by `field.prop`.)
**The crop textures are dark, yellow-green, not golden** (OBSERVED), consistent with FC2.

### 4.4 Scan result (FC6)

Targeted case-insensitive grep for `gamma|brightness` over `D:shaders\obj` and `D:game` returned
**0 matches**; `D:decals.mat` has exactly two brightness-related keys, both `= 1` (`:25-26`).
Therefore **no donor brightness constant exists in the readable field decal/blend path**. The
only field-related numeric "brightness" constants are the crop-mesh emission values in §4.3.
The unread compiled renderer / GPU state is **UNVERIFIED**.

---

## 5. Summer vs winter — explicit difference (FC7, FC8, FC9, FC11)

1. **Selection:** `D:decals.lib:40` summer = `envfieldd`, `:41` winter = `envfielddw`, on the same
   2×2 descriptor (`:42-43`). Crop mesh: `D:field.prop:58-76` summer/winter material lists.
2. **Coverage:** decal alpha is **byte-identical** between the two DDS files (mean 148.12, 256 levels,
   bbox (17,19)-(493,493), opaque fraction 0.2585) — one footprint, two fills.
3. **Colour:** summer olive `#4D442E` → winter desaturated grey `#756F61`; L 67.38 → 110.83
   (**+43.45 L**, DERIVED). Crop textures brighten by +36…+53 L across variants (§4.3).
4. **Tint:** the crop-mesh emission tint stays in its season variant — warm `#E8DAC3` on
   `field`/`fieldw`, neutral `#C8C8C8` on `field1..4`/w (OBSERVED). No separate winter brightness
   multiplier was found.
5. **Interpretation (INFERRED):** winter fields read as bare/dormant stubble rather than gold; the
   warmer `field` material is present in both seasons, so season is carried by the RGB fill, not
   by the emission constant.

---

## 6. Reference samples — field appearance (FC12, FC13)

Measured with my own Pillow/HSV probe on the two clean wheat crops used by
`docs/audit/PIECES/field_crops.md` (golden mask `R>G>B` and `R−B>45`; L = ITU-R 601-2):

| Sample | Box (src px) | Golden frac | Golden mean RGB / hex | L | H° | S | V |
|---|---|---:|---|---:|---:|---:|---:|
| `R:523480776.jpg` clean | `(520,25,700,205)` | 0.848 | `(147.5,117.1,43.0)` = `#93752B` | 117.8 | 42.6 | 0.734 | 0.578 |
| `R:523480776.jpg` big | `(200,0,720,300)` | 0.522 | `(140.0,111.1,42.3)` = `#8C6F2A` | 111.9 | 42.0 | 0.723 | 0.549 |
| `R:Cossacks3AttackingVillage.webp` clean | `(1580,180,1930,530)` | 0.548 | `(146.7,112.3,35.9)` = `#937024` | 113.9 | 41.4 | 0.764 | 0.575 |
| `R:cossacks-3-v1-498085.jpg` (CHARTER sample A, whole frame) | `(0,0,1280,720)` | 0.160 | `(104.6,92.1,48.3)` = `#695C30` | 90.8 | 48.0 | 0.560 | 0.410 |

The last row is **mostly non-field grass/scenery** (16% golden pixels) and is **not** a field
target — it is listed to show why sample A must not be used to calibrate wheat colour.

Visual check (OBSERVED, temp crops): the two clean crops show a dense vertical-stalk mass of
bright golden wheat with a hard diagonal edge over grey-brown worked soil; the mill clearing is a
square hole. Geometry (edge 2–8 px at 720p, stalk period ~3 px) is established in
`field_crops.md:90-103`; this ticket owns only colour/brightness.

**Key derived contrast (FC13):** reference field L ≈ 112–118 vs raw summer decal L 67.38 ⇒
**+45…+51 L** post-lighting lift; vs raw winter decal L 110.83 ⇒ only **+1…+7 L**. The donor
decal bytes therefore cannot by themselves explain the reference's golden brightness. This
matches `field_crops.md:46-47,193` ("gold is a render-time colour — inferred") and DTRN-06 Q8
("reference crops are post-lighting JPEG; a sun lift is a review decision, not a donor fact").

---

## 7. Numeric target ranges (donor/reference-derived, not a fix)

All ranges below are **donor or reference measurements**, offered as targets for the follow-up
colour ticket. None is a donor-parity claim.

### 7.1 Raw art targets (OBSERVED/DERIVED from donor bytes)

| Quantity | Target band | Source |
|---|---|---|
| Summer `envfieldd` opaque mean RGB | **R 76–78, G 67–69, B 45–47** (`#4D442E` ±1) | §3 |
| Summer covered L | **65–68** (p10 43, p90 95) | §3 |
| Winter `envfielddw` opaque mean RGB | **R 116–117, G 110–112, B 96–98** (`#756F61` ±1) | §3 |
| Winter covered L | **110–113** (p10 78, p90 146) | §3 |
| Winter−summer ΔL | **+43…+44 L** | §3 |
| Decal alpha | mean **148**, bbox **477×475**, opaque fraction **0.2585**; preserve byte-for-byte | §3 |
| Crop-mesh summer texture L | **46–70**; winter **94–114** (per-variant ΔL **+36…+53**) | §4.3 |
| Crop-mesh emission tint | warm `(232,218,195)/255` or neutral `200/255` | §4.3 |
| Decal brightness/gamma | **1 / 1** (no gain) | §4.1 |
| `texscalefix` | **1.3** geometry/UV; offset **−0.15** — *not* a colour knob | §4.2 |

### 7.2 On-screen field appearance targets (OBSERVED/DERIVED from c3 samples)

| Quantity | Tight target | Accepted band | Source |
|---|---|---|---|
| Golden interior mean RGB | R **140–148**, G **111–117**, B **36–43** | hex inside `#8E6F29`–`#B18A33` | §6; `field_crops.md:165` |
| Golden interior L | **112–118** | 105–125 | §6 |
| Golden hue H | **41–43°** | **39–45°** | §6; `field_crops.md:165` |
| Golden saturation S | **0.72–0.76** | 0.65–0.80 | §6 |
| Golden value V | **0.55–0.58** | 0.50–0.65 | §6 |
| R−G / G−B | **29–34 / 69–76** | ≈30 / ≈72 | §6 |
| Golden fraction in a clean field crop | **0.52–0.85** | >0.45 for a ripe field | §6 |
| Field vs surrounding grass | field **~20° yellower** and **~2× brighter** (grass H 62.6°, V 0.276 in `523480776.jpg`) | hard edge, no soft feather | `field_crops.md:87-88,94` |

### 7.3 The brightness gap, stated honestly (DERIVED / INFERRED)

- Summer decal raw L 67.38 → reference field L 112–118: **+45…+51 L must appear at render time**
  (DERIVED arithmetic). The donor decal bytes do **not** contain that lift (FC2/FC3/FC6).
- The donor *does* provide a render-time stage — `bmTransparency` alpha-blend of a lit decal
  (§4.1) and an emissive crop mesh (§4.3) — but **no readable donor constant quantifies the lift**.
  The multiplier is **UNVERIFIED**; do not invent one and call it donor.
- Winter needs no lift: its raw decal L 110.83 already sits in the reference band (DERIVED),
  which is a donor-grounded reason for the port's winter/summer split to be treated differently.

---

## 8. Where the port PNGs stand (FC14, FC15 — context, not a port fix)

- `variant3d/assets/terrain/deco_png/envfieldd.png` and `envfielddw.png` (and the `app/` copies)
  are 512×512 **RGBA** and **byte-identical** to my Pillow decode of the donor DXT5 files:
  exact array equality, MAD 0.0, max diff 0, 256 alpha levels, `a==255` fraction 0.2585 (OBSERVED/DERIVED).
  This **supersedes** the earlier "alpha flattened to 255" state recorded in DTRN-06 C26 and
  `field_crops.md:66-72,185` — those reports describe an older conversion. No donor pixel was copied
  into the repo by this ticket; these files pre-existed.
- `.import` (`:16-40`) shows `mipmaps/generate=false`, `process/fix_alpha_border=true`,
  `process/premult_alpha=false` — no brightness/colour processing flag (OBSERVED).
- Therefore the "too dark" symptom **cannot be an asset-conversion loss**: the PNG carries the
  donor's exact dark olive (L 67) bytes. The stage that converts them to the reference's golden
  L 112–118 is the render/blend step. In `variant3d/scripts/world.gd:2592-2605` the ripe summer
  field is drawn with a **PORT APPROX** modulate `Color(3.3,2.5,1.0, 0.42+0.28g)` and winter with
  `Color(1.0,1.0,1.06,0.78)` (`:2602-2603`) — these are port-authored, **not donor constants**, and
  this ticket does not judge or change them.
- Consequence for the follow-up owner (INFERRED, no fix proposed): "too dark" is most plausibly a
  render-time tint/alpha question, not a texture question. Any chosen lift must be calibrated
  against §7.2 and labelled PORT APPROX unless a donor GPU A/B is produced.

---

## 9. UNVERIFIED register — do not promote

1. Exact donor on-screen field brightness multiplier, gamma, or tone-map path (compiled renderer
   not inspected). The `+45…+51 L` is a *gap*, not a donor constant.
2. Whether `Emission` in the crop-mesh materials is applied as a multiplier or an additive term
   inside `gl_FrontLightModelProduct.sceneColor` (fixed-function GL semantics — INFERRED).
3. Which `field1..4` random material variant is active for a given field node, and whether
   `field`/`fieldw` (warm tint) is ever actually drawn — runtime selection UNVERIFIED.
4. Runtime activation of `;`-commented donor `.inc` scripts that place the decal (same caveat as
   DTRN-06 §1.4 / F2-02 §0); `misc.script` itself is active-looking text, not executed here.
5. Whether any donor screenshot was taken with a mod/terrain pack that changes field colour.
6. Exact source-image season of each c3 reference (fields may be summer by construction, but not
   proven from metadata).
7. Donor GPU A/B field frame — none exists; **no parity claim**.

---

## 10. Summary

- **Donor field art is dark, not golden.** `envfieldd`/`envfielddw` are 512² DXT5 decals with
  byte-identical coverage; opaque means `#4D442E` (L 67.4) and `#756F61` (L 110.8). The crop
  mesh textures `field*.dds` are likewise dark yellow-green (L 46–70 summer, 94–114 winter).
- **The donor has no brighten knob on the decal path.** `decals.mat` sets `imagebrightness=1`,
  `ImageGamma=1`, `bmTransparency`, `tmModulate`, and `dec.pvl.smx3.frag` modulates RGB by lighting
  with alpha = DXT5 coverage. `texscalefix=1.3` in `misc.script:4298-4305` is **size/UV only**.
  The only field brightness/tint constants are crop-mesh **emission** values: warm
  `(232,218,195)/255` (`field`/`fieldw`) and neutral `200/255` (`field1..4`/w).
- **Season difference is RGB-only:** summer olive → winter desaturated grey, **+43.45 L**, with
  identical alpha; crop textures brighten +36…+53 L.
- **Reference fields are golden and bright:** H 41–43°, S 0.72–0.76, V 0.55–0.58,
  `#8C6F2A`–`#93752B`, L 112–118 — ~20° yellower and ~2× the brightness of adjacent grass.
  That is **+45…+51 L above the raw summer decal**, a render-time gap whose multiplier is
  UNVERIFIED in donor text.
- **The port PNGs are byte-identical to the donor decode**, so the darkness is not an asset loss;
  the port's gold lift lives in `world.gd:2592-2605` and is explicitly PORT APPROX.

*End of FCOL-02. One report written. Donor truth only; no donor binary copied or executed, no code,
asset, config, test, git or Godot-runner state changed; no donor-parity claim.*
