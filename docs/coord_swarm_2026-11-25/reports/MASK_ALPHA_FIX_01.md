---
id: MASK-ALPHA-FIX-01
title: "Stop rendered sky bleeding through terrain alpha-mask patches — make ground opaque, fold the donor mask into RGB"
agent: "MASK-ALPHA-FIX-01 (implementation builder), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__ONE_SHADER_EDITED__SMOKE_GREEN__REAL_MAP_CAPTURE_MEASURED__NO_DONOR_EXECUTED
scope: "Exactly two owned files edited/created: variant3d/shaders/terrain_tileindex.gdshader (3 hunks) and this report. Required backup in inbox/backup/. NO other file edited, reverted, or re-submitted: no tests, game.gd, other shaders, config, app/**. Donor READ-ONLY (not opened, executed or copied this task)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: "variant3d/shaders/terrain_tileindex.gdshader"
backup: "inbox/backup/terrain_tileindex.gdshader.bak-MASKALPHAFIX"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
jobs:
  smoke: {id: maskalpha01-smoke, ticket: 556, status: ok, exit: 0, stderr_bytes: 0, script_errors: 0, atom_result: "T_TERRAIN3D RESULT: PASS 6/6"}
  realmap: {id: maskalpha01-realmap, ticket: 563, status: ok, exit: 0, script_errors: 0, artifact: "maskalpha_after.png (2,436,001 B, 1280x720)"}
parity_claim: false
---

# MASK ALPHA FIX 01 — opaque ground, mask modulation carried in RGB

## 0. Mandate and boundary

Stop the rendered sky bleeding through terrain alpha-mask patches, by keeping terrain
opaque while preserving the donor mask's visual modulation through RGB shading. The
brief fixes the mechanism (framebuffer ALPHA written from the donor mask in one
`blend_mix` pass) and forbids chasing tile albedo, adding an invented second base pass,
or weakening any donor-grounded line. Validation is via the variant runner only; no
retry loops, no queue mutation (no reset/ack/cancel of any job), no direct `godot`.

Labels: **observed** = literal bytes/source line/tool output/direct image read;
**derived** = arithmetic/control-flow consequence; **inferred** = attribution without a
pixel-aligned donor A/B; **UNVERIFIED** = not established by anything read here.
**No donor parity claim** — no donor GPU A/B frame exists.

---

## 1. Evidence read (all before editing)

| Source | What was taken |
|---|---|
| `WHITE_MARKS_PIX_01.md` §2, §5 | 44,381 near-white px = 4.8156 % of 921,600; exact cyan `(181,234,255)`×21,750 + `(182,233,255)`×17,819 = **39,569 = 89.16 %**; **11,738** isolated cyan components below the sky strip; zero exact occurrences in all 112 block PNGs. Rank-1 mechanism = sky through alpha-mask gaps on grid-stepped transition cells (**observation CONFIRMED, mechanism INFERRED**). |
| `QA_WHITE_PIX_02.md` §3, §4 | Independent cross-check reproduces the numbers and **refutes** the tile-albedo attribution for the dominant pixels (97.28 % nearest `winter0` at ΔE76≈17, only 0.95 % any summer block, 7 px `rock4`). |
| `V3D_02_terrain_render_audit.md` **P7** (line 92) | `mask_to_alpha=1.0` re-applies the donor mask as framebuffer ALPHA **with no second base-tile pass**; removing it dropped luma 42.735 → 38.425 because the bright port sky is behind the semi-transparent ground; shipped knob was deliberately kept. Citation `terrain_tileindex.gdshader:24-37,202-211,373-375`. |
| `DALPHA_01_alpha_subrect.md` §3.2, §5, §6 | 8 cols × 4 rows × 64² patch grid **RESOLVED**; four constant sentinels `(0,0)/(4,0)=255`, `(3,3)/(7,3)=0`; graded complements only approximate (best MAD 9.77). Exact `tile_id + boundary_direction → patch` rule **CONFIRMED_UNVERIFIED** (§5 item 5; 17,237-file scan, packed `.bind`, UV from `gl_MultiTexCoord1`). §6 forces an APPROX label and a retained diagnostic knob. |
| `DALPHA_02_patch_mapping.md` §3 | The 64² `alpha_patch_uv()` sampler and the tile-id-decomposition patch selection currently in the shader; preserved byte-identically here. |
| `DTRN_01_donor_terrain_pipeline.md` **C17** (line 131) | Alpha modulation is `bmTransparency` + `Texture2Name=alpha`; fragment reads RGB from `texUnit0`, alpha from `texUnit1`, then `color.rgb*TexCoord[4]+TexCoord[5]`. **One Godot `blend_mix` pass is an approximation of donor fixed-function multi-pass blending (O10 §2.8).** |
| `PALE_TILES_DEEP_01.md` §2.2–2.5, §3.5, §4.3–4.5, §5, §8 | All 112 donor summer DDS are mid-tone (family means L 65.99–118.52, `minRGB>180` = 0 %; `rock8.dds` L = 64.68); only `winter*` is near-white and the capture is a summer map (`data.gd:230`, `game.gd:2033-2037`), with 0 of ~745k band pixels matching winter-white. The 44,381 near-white px are dominated by exact sky colour `(181,234,255)`; only **31** exceed `minRGB>200`; pale bands fit an olive→sky mix at α≈0.267–0.306 vs olive control 0.026. Port binds mask as framebuffer ALPHA at shader `:469`; replaying the APPROX patch map sends flat-land `test9` (id 80) to constant-0 patch `(7,3)` (mean α 0.0) and `test7` (id 78) to `(0,1)` (mean α 56.5); a same-seed dump has **786 / 3,413** such flat cells. Best-supported hypothesis H5; donor patch rule UNVERIFIED; no parity claim. |

### Mechanism confirmation (step 1 of the task)

**Observed (source):** shader `:43` `render_mode blend_mix, unshaded, cull_disabled`; `:235` `mask_to_alpha = 1.0`;
pre-edit `:469` `ALPHA = mix(1.0, a, mask_to_alpha)` ⇒ with the shipped knob `ALPHA == a`.
`a` is the donor mask intensity sampled from the 8×4 sub-rect (`:363-376`, `:417`).

**Derived:** under `blend_mix`, `framebuffer = src.rgb·src.a + dst.rgb·(1−src.a)`. For a
low-`a` transition cell, `dst.rgb` is the bright port sky `(181,234,255)`, so the cell
renders as an olive→sky mix; for a constant-0 patch it renders exactly the sky colour.
This is a *port* one-pass blend defect, not donor albedo (PALE_TILES_DEEP_01 §4.6/H5).
It matches the observed 11,738 isolated cyan components and the α≈0.27–0.31 olive→sky
fit. So mask alpha **is** written to framebuffer ALPHA in a single pass and **does**
expose the clear colour — CONFIRMED as source-level observation; attribution of the
visible bands to this mechanism remains INFERRED (no pixel-aligned donor A/B).

---

## 2. Backup (taken before the first edit)

| Item | Value |
|---|---|
| Path | `inbox/backup/terrain_tileindex.gdshader.bak-MASKALPHAFIX` |
| Pre-edit shader SHA-256 | `736C20BE8E0D74DFF52F52DFC4BB7E98A51A6ADAB668753E8D6201B8E1A39722` |
| Pre-edit shader size | 27,438 B |
| Backup SHA-256 | identical (`736C20BE…39722`) — verified by hash after copy |
| Post-edit shader SHA-256 | `F9456E4F769EC7CF3527E16D1C05F59754852C6E76F56E2090406C150C9535F0` |
| Post-edit shader size | 27,920 B |

---

## 3. The fix (minimal, 3 hunks)

### Before (shipped)
```glsl
uniform float mask_to_alpha = 1.0;
...
rgb = rgb * v_packed + v_specular;          // donor hf.pvl.smx3.frag:17
...
ALPHA = mix(1.0, a, mask_to_alpha);         // ALPHA == a  -> sky bleeds through
```

### After
```glsl
uniform float mask_to_alpha = 1.0;
// MASK-ALPHA-FIX-01 — DIAGNOSTIC KNOB, SHIPPED VALUE KEPT AT 1.0.
// ... one blend_mix pass; PORT APPROXIMATION of donor multi-pass (ENGINE/UNVERIFIED) ...
...
rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;
...
ALPHA = 1.0;                                // opaque: no sky bleed
```

**What changed:** the *same* sampled mask intensity `a` is folded into the donor combine
term as an albedo shading factor, and the framebuffer ALPHA is pinned to 1.0. Low-mask
cells now shade darker terrain instead of becoming transparent windows onto the sky.
The stepped/banded mask modulation is preserved in RGB; the sky-coloured gaps are gone.
No invented second base pass. The code comment states verbatim that this is a
**PORT APPROXIMATION of the donor multi-pass blend (ENGINE/UNVERIFIED, DTRN-01 C17)**
and that the exact donor mask semantics are UNVERIFIED.

**Byte-identical (verified by `git diff --no-index` against the backup):** world-XZ
texgen (`eye_plane_s/t`, `texture_matrix`, `v_st`, `uv_repeat=0.5`), donor sun mapping
(`donor_sun_position`, `ambient_rgb`, `diffuse_rgb`, `specular_rgb`, `shininess`,
`lsParallel` handling), all 64² patch sampling (`alpha_patch_uv()` selection and
`((c+u)/8,(r+v)/4)` inset), face planes and `face_scale`, shadow/fog equations, all
samplers/uniforms, `render_mode`, and every other line. The diff is confined to the
`mask_to_alpha` comment, the one combine line, and the final ALPHA line. No new sampler,
asset, art, noise, shadow or physical constant was added.

---

## 4. Validation — variant runner only

### 4.1 Headless smoke

```
python variant3d\tools\godot_runner.py run --id maskalpha01-smoke --timeout 180 -- ^
  --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Field | Result |
|---|---|
| Job id / ticket | `maskalpha01-smoke` / **556** |
| Status / exit | `ok` / **0** |
| Wait / run | 1,229.25 s / 11.16 s |
| stdout | `T_TERRAIN3D RESULT: PASS 6/6` (`module_load_and_api`, `build_ok`, `surface_count`, `vertex_count`, `has_chunk_or_fallback`, `height_at_world_samples`) |
| stderr | 3 benign "Loaded resource as image file" warnings; **`script_error_lines = 0`** (`smallmap_capture.py scan-stderr`) ⇒ `SCRIPT ERROR = 0` |

Smoke proves shader parse/build/geometry health only, not visual parity.

### 4.2 Windowed real-map capture

Same seed (20261113), same 64² fixture, same camera path, 1280×720, 10 frames:

```
python variant3d\tools\godot_runner.py run --id maskalpha01-realmap --timeout 300 -- ^
  --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/maskalpha01/maskalpha_after.png" ^
  --screenshot-frames 10 ^
  --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" ^
  --timeout 120
```

| Field | Result |
|---|---|
| Job id / ticket | `maskalpha01-realmap` / **563** |
| Status / exit | `ok` / **0** (unlike ticket 532, `_is_blank()` did not reject this frame; final PNG written) |
| Wait / run | 668.00 s / 24.29 s |
| stdout diag | `p00=(0.7137,0.9137,1.0,1.0)`, `pcenter=(0.3882,0.3843,0.1176,1.0)`, `camera_current=true`, 1280×720 `Screenshot3DViewport` |
| Artifacts | `maskalpha_after.png` and `...raw.png`, **2,436,001 B** each |
| stderr | benign exit-time RID/texture/ObjectDB leak warnings; **`script_error_lines = 0`** ⇒ `SCRIPT ERROR = 0` |

### 4.3 Near-white pixel count — before → after

Measurement: read-only Pillow/NumPy script under `%LOCALAPPDATA%\Temp\opencode\maskalpha01\`
(outside the repo), strict near-white = `min(R,G,B) > 180` — **the exact published metric**.

| Metric | BEFORE (`relief_on.png.raw.png`, ticket 532) | AFTER (`maskalpha_after.png`, ticket 563) |
|---|---:|---:|
| Near-white pixels (`minRGB>180`) | **44,381** | **6,989** |
| Near-white fraction of 921,600 | **4.8156 %** | **0.7584 %** |
| Exact cyan `(181,234,255)` + `(182,233,255)` | 39,569 | **6,571** |
| Exact cyan below sky strip (`y ≥ 12`) | ~32,744 | **0** |
| Near-white below sky strip (`y ≥ 12`) | 37,556 | **55** |
| Pixels with `minRGB>200` | 31 | 19 |
| Rec.709 luma min / max / mean | 0.000 / 253.845 / **115.039** | 0.000 / 253.628 / **79.256** |

**Derived:** near-white count fell by **37,392 px = 84.252 %**; exact sky cyan fell by
32,998 px = 83.39 %; **every exact sky-cyan pixel below the sky strip was eliminated**
(11,738 isolated bleed components → 0 exact-cyan components). Every one of the 6,571
remaining exact-cyan pixels lies in the sky strip `y<12` — i.e. the sky itself, not the
ground. The visual read of the after frame confirms the change: the pale cyan stepped
bands are replaced by dark olive/tan terrain-coloured steps (modulation preserved in RGB).

**A/B caveat (honest):** this is **not a pixel-registered A/B**. The after camera x is
23.33447 m vs the baseline 21.98215 m (same y=58, z=70.25505 and same target offset),
so only **frame-wide statistics** are compared, not per-pixel deltas. The baseline is a
raw GPU sidecar from a job marked `failed` by the old blank-detector; the after job
succeeded and wrote both PNG and sidecar. Both are real 1280×720 `Screenshot3DViewport`
GPU frames of the same seed/fixture.

---

## 5. No-weakening / no-parity statement

- **No donor-grounded behaviour was weakened.** Every donor equation, constant, sampler,
  UV/patch geometry, texgen transform and light mapping is byte-identical to the backup.
  The only change is *where the already-sampled mask `a` is applied* (framebuffer ALPHA →
  RGB albedo), which is the port's own substitute for a blend step the donor performs
  engine-side and which this project has always labelled UNVERIFIED.
- **No second base pass was invented** — one `blend_mix` pass remains; `render_mode`,
  sampler count and draw path are unchanged.
- **No donor visual parity is claimed.** The result is a PORT APPROXIMATION, internally
  consistent, with no donor GPU A/B frame. The oxide-free measurement above is a
  before/after of the *port*, not a match to the donor.
- **No other file edited.** Only the shader (3 hunks), the required backup, and this
  report were produced by this task. Other modified/untracked files seen in `git status`
  belong to concurrently working builders and were not touched, reverted or re-submitted.
  No config, test, `game.gd`, other shader, asset, `app/**`, queue action (other than my
  own two job submissions) or git state was changed. Donor was not opened, executed or
  copied in this task.

---

## 6. Remaining UNVERIFIED

1. **Engine blend** — donor `bmTransparency` multi-pass blend factors/compositing are
   **CONFIRMED_UNVERIFIED** (DTRN-01 C17; DALPHA-01 §8 Q6). Folding the mask into RGB is
   an approximation of that engine-side step; its visual closeness to the donor is
   UNVERIFIED.
2. **Exact donor mask semantics** — the `tile_id + boundary_direction → patch` rule is
   **CONFIRMED_UNVERIFIED** (DALPHA-01 §5 item 5); complement structure is only PARTIAL
   (best graded MAD 9.77); whether the donor engine ever selects the constant-0/255
   sentinels for flat-land `test7`/`test9` is unknown. The APPROX patch map is unchanged
   by this fix.
3. **Donor GPU A/B frame** — none exists anywhere in the project; universal blocker.
   No parity of hue, grain, band geometry or luma can be claimed.
4. Reserving the shipped `mask_to_alpha=1.0` was a deliberate no-weakening choice
   (V3D-02 P7 documented that zeroing it darkens the frame); the new RGB fold explains
   that darkening as removal of sky bleed, but the donor-faithful target luma is unknown.

---

## 7. Open questions

1. The full-cut sentinel patches (`(3,3)/(7,3)`, `a=0`) now render very dark
   (`rgb·0`) in the after frame — visible as dark stepped cells. Is that the closest
   one-pass stand-in for the donor's (unknown) base pass, or should a floor/base tone be
   introduced? Any floor would be an invented constant, so it was **not** added; needs a
   donor A/B (UNVERIFIED).
2. Does the `mask_to_alpha` knob still serve A/B use? Yes: 0.0 = flat opaque terrain,
   1.0 = shipped RGB mask modulation. No config setter exists today
   (PALE_TILES_DEEP_01 Q7); a flag-off A/B remains a future test owned elsewhere.
3. Are the residual 55 near-white pixels below the sky strip partial mask blend,
   anti-aliasing/tone mapping, or tile art? Not modelled.
4. Would a pixel-aligned capture (identical camera x) change the measured delta? The
   captures differ by 1.352 m in camera x; the comparison is frame-wide.
5. Does the water plane contribute any residual cyan below the sky? The after frame has
   **zero** exact sky-cyan pixels below `y=12`, so no exact contribution; partial blends
   remain UNVERIFIED (no depth buffer in the artifact).
6. Donor parity of the new RGB shading remains blocked on a donor GPU A/B frame.

---

## 8. Summary

Confirmed from source that the shipped shader wrote the donor mask intensity to
framebuffer ALPHA (`ALPHA = mix(1.0, a, 1.0) == a`) in a single `blend_mix` pass, so
low-mask transition cells blended with the bright port sky. Backed up the shader
(hash-verified), then applied a three-hunk minimal fix: fold the same mask into the
donor combine term as an albedo shading factor and pin `ALPHA = 1.0`. No invented
second base pass; the approximation is labelled **PORT APPROXIMATION — engine
UNVERIFIED** in code. World-XZ texgen, donor sun mapping, 64² patch sampling and every
other line are byte-identical to the backup.

Validation (variant runner only): smoke `maskalpha01-smoke` (ticket 556) exit 0,
PASS 6/6, `SCRIPT ERROR = 0`; real-map capture `maskalpha01-realmap` (ticket 563)
exit 0, `SCRIPT ERROR = 0`. Strict near-white pixels fell **44,381 → 6,989**
(**4.8156 % → 0.7584 %**, −84.252 %); exact sky cyan fell 39,569 → 6,571, with **zero**
exact sky-cyan pixels below the sky strip after the fix. The 11,738 isolated bleed
components are eliminated. Donor ground: all 112 summer DDS are mid-tone (PALE_TILES_DEEP_01
§2), only `winter*` is near-white and is not bound in this summer map; tile albedo is
refuted for the dominant pixels (QA_WHITE_PIX_02 §3). **No donor parity claimed**;
engine blend and exact donor patch semantics remain UNVERIFIED. Only the shader, the
required backup and this report were produced by this task; no other file edited.

---

*End of MASK ALPHA FIX 01. One shader edited (3 hunks); no donor access or parity claim; PORT APPROXIMATION throughout.*
