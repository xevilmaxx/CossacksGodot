# T2-ARB-ALPHA — decal alpha arbitration (`deco_png` RGB vs donor DXT5 alpha)

RESEARCH / ARBITRATION only. Exactly one output file written. No code edit, no Godot run, no
donor binary copied into the repo. This is an **asset-conversion ticket**, not a code change in
this lane (see §6). All pixel work used Pillow 12.1.1 + NumPy 2.4.3; probe scripts and decoded
previews live **only** in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`
(`t2_arb_alpha_probe.py`, `t2_arb_alpha_probe2.py`, `t2_probe_*.png`).

Conflict under review:

- `docs/audit/PIECES/donor_decals_and_masks.md` (esp. §4 row for `deco_png`, §6 claim 5): the
  checked-in port PNGs are **RGB, PNG IHDR colorType 2 — no alpha channel at all**.
- `docs/audit/PIECES/field_crops.md` (§1.1, §1.3, §3 JSON, §5): the donor `envfieldd/w.dds` are
  512² DXT5 with alpha bbox `(17,19,494,494)`, and the port PNGs are "donor texture flattened
  to **alpha=255**" / "512×512 RGBA but alpha is 255 at every pixel".

Tags follow `docs/audit/README.md` rule 3: `observed` (read / counted / measured here),
`derived` (computed from observed data), `inferred` (plausible but unproven), `UNVERIFIED`.

---

## 1. Method

- PNG: opened each file in binary, read bytes 16–28 with `struct.unpack(">IIBBBBB")` for
  width / height / bit depth / color type / compression / filter / interlace (`observed`).
  Independently opened with Pillow for `Image.mode`. Where an alpha band existed, decoded to
  RGBA with NumPy and counted alpha thresholds and bounding boxes (`derived`).
- DDS: read the 128-byte header (`DDS ` magic, FourCC at bytes 84–88, width/height, mip count,
  pitch; `observed`), then `Image.open(...).convert("RGBA")` for the decoded alpha channel
  (Pillow decodes DXT5 natively; `observed` header, `derived` pixel stats).
- Origin check: decoded donor RGBA and port RGB, compared RGB arrays element-wise (`derived`).
- Converter: read `app/tools/copy_assets.py` in full plus `git log -p --follow` / `git show` on
  the file and on `app/assets/terrain/deco_png/envfieldd.png` (`observed`).

Negative controls: 7/7 PNG and 7/7 DDS opened without error. No donor file was written or copied
into the repo; no `.dds` was emitted anywhere but `%LOCALAPPDATA%\Temp\opencode\`.

---

## 2. Measurement table — port PNG IHDR and alpha (`observed`)

| File (`app/assets/terrain/deco_png/`) | WxH | IHDR bit depth | IHDR color type | Pillow mode | Alpha channel? |
|---|---|---|---|---|---|
| `envfieldd.png` | 512×512 | 8 | **2 = RGB truecolor** | `RGB` | **No** |
| `envfielddw.png` | 512×512 | 8 | **2** | `RGB` | **No** |
| `groundexp0.png` | 512×512 | 8 | **2** | `RGB` | **No** |
| `groundexp1.png` | 512×512 | 8 | **2** | `RGB` | **No** |
| `groundexp2.png` | 512×512 | 8 | **2** | `RGB` | **No** |
| `groundexp3.png` | 512×512 | 8 | **2** | `RGB` | **No** |
| `christmastreed.png` | 1024×1024 | 8 | **2** | `RGB` | **No** |

All seven: IHDR length 13, compression 0, filter 0, interlace 0. **No alpha histogram exists to
measure — the alpha band is absent from the file format**, not "all 255" (`observed`). A PNG
containing an alpha channel would have colorType 6 (or 4); none of these do.

Control experiment (`observed`): re-encoding a donor DDS with `.convert("RGBA").save()` yields
IHDR colorType **6** (Pillow `RGBA`); re-encoding with `.convert("RGB").save()` yields colorType
**2**. The checked-in files match the latter exactly.

---

## 3. Donor DDS header and alpha (`observed` header, `derived` pixels)

All seven donor files: magic `DDS `, header size 124, FourCC **`DXT5`**, `rgbbits=0`, alpha mask
`0x0` (DXT5 stores alpha inside the 16-byte blocks, not in the DDPF mask fields). Pillow decodes
every one to mode `RGBA`.

| Donor file | Size | Mips | Alpha min/max/mean | a==255 | a==0 | a>0 | 0<a<255 | bbox a>0 | bbox a>8 | bbox a>250 | unique |
|---|---|---|---|---:|---:|---:|---:|---|---|---|---:|
| `env\envfieldd.dds` | 512² | 10 | 0 / 255 / 148.12 | 25.85% | 15.56% | 84.44% | 58.59% | (16,19,494,494) | **(17,19,494,494)** | (22,33,487,480) | 256 |
| `env\envfielddw.dds` | 512² | 10 | 0 / 255 / 148.12 | 25.85% | 15.56% | 84.44% | 58.59% | (16,19,494,494) | **(17,19,494,494)** | (22,33,487,480) | 256 |
| `pfx\groundexp0.dds` | 512² | 10 | 0 / 250 / 32.52 | 0% | 39.83% | 60.17% | 60.17% | (1,13,512,489) | (14,25,495,471) | none | 250 |
| `pfx\groundexp1.dds` | 512² | 10 | 0 / 236 / 24.47 | 0% | 42.39% | 57.61% | 57.61% | (0,10,512,499) | (64,38,484,465) | none | 232 |
| `pfx\groundexp2.dds` | 512² | 10 | 0 / 248 / 32.06 | 0% | 45.49% | 54.51% | 54.51% | (25,21,486,504) | (39,43,460,480) | none | 247 |
| `pfx\groundexp3.dds` | 512² | 10 | 0 / 243 / 31.36 | 0% | 43.52% | 56.48% | 56.48% | (17,20,501,509) | (27,40,474,474) | none | 244 |
| `env\christmastreed.dds` | 1024² | 11 | 0 / 255 / 98.38 | 20.32% | 51.42% | 48.58% | 28.26% | (75,41,984,972) | (75,41,983,972) | (103,63,941,933) | 256 |

`envfieldd` and `envfielddw` alpha arrays are byte-identical (all histogram cells and bboxes
equal); only RGB differs — consistent with both prior docs. The scorch plates never reach 255.
Reconciliation note (`derived`): `field_crops.md` §1.1 reports `envfieldd` "a>250 = 30.7%,
5<a≤250 = 50.4%" using different thresholds; my `a==255 = 25.85%` and `0<a<255 = 58.59%` use
strict equality / strict interior. The two threshold schemes are compatible; neither changes the
footprint bbox. Its `christmastreed` figures (mean 98.4, 48.6% >0, 51.4% at 0) match mine.

---

## 4. Donor DDS vs port PNG — what the conversion dropped (`derived`)

| Asset | Donor alpha bbox (a>8) | Port PNG alpha | Lost payload |
|---|---|---|---|
| `envfieldd` | (17,19,494,494) | none (colorType 2) | full 256-level coverage/feather mask |
| `envfielddw` | (17,19,494,494) | none (colorType 2) | same mask |
| `groundexp0` | (14,25,495,471) | none (colorType 2) | 250-level scorch alpha (max 250) |
| `groundexp1` | (64,38,484,465) | none (colorType 2) | 232-level scorch alpha (max 236) |
| `groundexp2` | (39,43,460,480) | none (colorType 2) | 247-level scorch alpha (max 248) |
| `groundexp3` | (27,40,474,474) | none (colorType 2) | 244-level scorch alpha (max 243) |
| `christmastreed` | (75,41,983,972) | none (colorType 2) | tree-outline cutout alpha |

**RGB origin check (`derived`):** for `envfieldd` and `envfielddw`, port PNG RGB is
**byte-for-byte identical to the donor DDS RGB over 100% of pixels** — mean absolute channel
difference `0.000`, max `0`, inside the footprint (`a>8`) and outside (`a==0`) alike. Port RGB
means: `envfieldd` (75.57, 67.52, 45.24), `envfielddw` (115.94, 110.92, 96.96) — exactly the
donor full-image RGB means.

So the conversion dropped **only the alpha channel**; RGB was preserved losslessly. This
corrects `field_crops.md` §1.3's "not byte-identical copies (max channel diff 255, mean diff
26.7)": that comparison used the donor **opaque-only** mean (77.2, 68.4, 46.1) against the port
**full-image** mean, which differ because the donor's transparent/feather pixels carry different
RGB. Against the donor's full-image RGB, the port PNG is an exact match.

---

## 5. Conversion-tool cause (`observed`)

`app/tools/copy_assets.py`:

- `dds_to_png()` at **`:44-57`**; line **`:53`** is `im = Image.open(src).convert("RGBA")` and
  line `:56` is `im.save(dst)`. This code path **preserves** DXT5 alpha and emits PNG colorType 6
  (control experiment, §2).
- The deco copy loop is at **`:121-127`**: `christmastreed`, `envfieldd`, `envfielddw` via
  `:123-124`; `groundexp0..3` via `:126-127`. All seven call `dds_to_png` — there is no
  `.convert("RGB")` on this path. (The only `.convert("RGB")` in the file is `:132` for water
  `diffusewaves*.bmp`, which writes to `water_png/`, not `deco_png/`.)

Git provenance (`observed`, `git log -p --follow` / `git show`):

- `dds_to_png` has used `.convert("RGBA")` since the initial commit `4b1404c`.
- The deco copy lines and the seven committed PNGs were both added in `b40dfcc` ("idk :(");
  no commit in the file's history changes `RGBA` to `RGB` on that path.

**Precise cause statement:** the checked-in `deco_png/*.png` files cannot have been produced by
the committed `copy_assets.py` code path — that path writes colorType 6, whereas the files are
colorType 2. They were produced by a different/older flatten step that performed the equivalent
of `Image.open(dds).convert("RGB").save(png)` (control experiment: colorType 2 with byte-identical
RGB, exactly the observed result). The identity of that producer is **UNVERIFIED** — no such code
exists in the current tree or its git history; the `donor_decals_and_masks.md` §6 "provenance
UNVERIFIED" item is upheld, but now bounded: *not* `copy_assets.py:53`.

---

## 6. Verdict — which doc is right, and the required fix

| Point | `donor_decals_and_masks.md` | `field_crops.md` | Arbitration (`observed`) |
|---|---|---|---|
| Port PNG alpha presence | RGB colorType 2, no alpha (§4, §6 claim 5) | "512×512 RGBA, alpha=255 at every pixel" (§1.3) | **`donor_decals_and_masks.md` RIGHT.** All 7 files IHDR colorType 2, Pillow `RGB`, no alpha band. `field_crops.md` §1.3 is **WRONG on file format**; "alpha=255" is a mis-description of an absent channel. |
| Operational conclusion: footprint lost | "alpha footprint discarded" | "alpha footprint flattened away" | **BOTH RIGHT.** The coverage mask is gone in the port PNGs regardless of description. |
| Donor alpha footprint exists | 512² DXT5, A = coverage, bbox a>8 = (17,19,494,494) implied likewise | DXT5 512², bbox (17,19,494,494), 12 px ramp | **BOTH RIGHT; no real conflict here.** Direct measurement reproduces `(17,19,494,494)` exactly and 256-level alpha. `field_crops.md`'s geometric claims are confirmed. |
| "flattened to alpha=255" | CONTRADICTED (RGB, no alpha) | asserted | **Corrected:** flattened to **no alpha channel** (colorType 2), RGB byte-identical to donor. |

**What the conversion must change (asset-conversion ticket, not a code edit in this lane):**
regenerate the seven `deco_png` PNGs from the donor DDS through the alpha-preserving path so the
output is PNG **colorType 6** carrying the donor DXT5 alpha byte-for-byte (target per U2 in
`donor_decals_and_masks.md`: alpha histogram within 1%/bin, alpha bbox equals donor `a>8` bbox,
outside-footprint alpha = 0). No source change is required in `copy_assets.py` itself — line
`:53` already uses `.convert("RGBA")`; the fix is to **re-run the committed converter** over
`app/tools/copy_assets.py:121-127` and replace the RGB files with its RGBA output, and to ensure
no downstream post-process flattens them back to RGB. The only present consumer,
`app/tools/gen_variant_maps.py:188-190`, then needs to honour the alpha (decal draw pass), but
that is a separate wiring ticket.

Target file:line for the fix — **`app/tools/copy_assets.py:44-57`** (keep `dds_to_png` on the
`.convert("RGBA")` path at `:53`; add an output IHDR colorType-6 check) and the deco invocation
sites **`app/tools/copy_assets.py:121-127`**. Consumer follow-up:
`app/tools/gen_variant_maps.py:188-190`.

---

## 7. Claim table

| # | Claim | Evidence / method | Label | Verdict / correction |
|---|---|---|---|---|
| 1 | All 7 `deco_png` files are IHDR colorType 2, 8-bit, no alpha | `struct` on PNG bytes 16–28 + Pillow mode | `observed` | CONFIRMED |
| 2 | Donor `envfieldd/w.dds` are 512² DXT5 with a 256-level alpha channel | 128-byte DDS header + Pillow RGBA decode | `observed` | CONFIRMED |
| 3 | Donor env alpha bbox a>8 = (17,19,494,494), identical for d/w | NumPy threshold on decoded alpha | `derived` | CONFIRMED — matches `field_crops.md` §1.1 exactly |
| 4 | Port PNG RGB is byte-identical to donor RGB (100% pixels, max diff 0) | element-wise array comparison | `derived` | CONFIRMED — conversion dropped alpha only |
| 5 | Port PNGs are "RGBA with alpha=255" | prior `field_crops.md` §1.3 | `observed` refutation | **CONTRADICTED** — there is no alpha channel |
| 6 | Port PNGs are "not byte-identical" to donor | prior `field_crops.md` §1.3 | `derived` refutation | **CONTRADICTED** under full-image RGB comparison; the prior diff came from opaque-only donor means |
| 7 | Current `copy_assets.py:53` would emit colorType 6 (alpha preserved) | control re-encode + source read | `observed` | CONFIRMED |
| 8 | The committed converter cannot have produced the RGB deco PNGs | comparison of §7.1 vs §2 + git history | `derived` | CONFIRMED |
| 9 | Provenance of the flatten step (which tool used `.convert("RGB")`) | git log/show search | `UNVERIFIED` | upheld but bounded: not the committed `dds_to_png` path |
| 10 | Scorch/christmas donor alphas are real coverage masks with the bboxes in §3 | NumPy stats | `derived` | CONFIRMED |
| 11 | Fix is an asset regeneration (colorType 6), not a code edit here | `app/tools/copy_assets.py:44-57,121-127` | `inferred` | Recommended ticket scope; wiring in `gen_variant_maps.py:188-190` is separate |

---

## 8. Files changed

- `docs/audit/PIECES/decal_alpha_arbitration.md` (new) — this report only. No source, asset,
  index, screenshot or status document modified. All probes and decoded previews live under
  `%LOCALAPPDATA%\Temp\opencode\` and are not part of the deliverable. No donor binary was
  copied into the repository. No Godot process was started.

End.
