---
id: Y10
ticket: "WAVE Y / Y10 — one-line anisotropic sampler A/B against the y08c horizontal striping"
title: "Y10 — tile_atlas filter hint -> filter_linear_mipmap_anisotropic (closest VALID Godot token), applied, not yet captured"
owner: Y10 (EXCLUSIVE owner of variant3d/shaders/terrain_tileindex.gdshader)
created: 2026-11-25
status: APPLIED_NOT_CAPTURED__ONE_LINE__ALL_INVARIANTSVERIFIED__PARITY_UNVERIFIED
scope: "Exactly three repo files touched: the shader (one line), its new backup, and this report. NO runner job, NO Godot process, no queue/lock/counter mutation, no game.gd/asset/config/test/tool/donor/git edit. Scratch Python + tool JSON live only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y10\\."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
prereads:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/Y08b_capture_log.md
  - docs/terrain_swarm_2026-11-25/reports/Y08_checkerboard.md
  - docs/terrain_swarm_2026-11-25/reports/A06_filtering_aliasing.md
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/Y08c_capture_log.md
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md
baseline_capture: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y08c\\realmap.png"
backup: inbox/backup/terrain_tileindex.gdshader.bak-Y10
backup_sha256: E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3
post_sha256: F528612524165C618BB785B186535D0B023560D725C6783AF422E2623C05FEEC
---

# Y10 — anisotropic-sampler A/B on `tile_atlas`

> **Labels.** **OBSERVED** = literal file/source output or a measurement made on the named PNG
> with the named tool. **DERIVED** = arithmetic/control-flow consequence. **INFERRED** =
> attribution with its caveat stated. **UNVERIFIED** = not proven (above all, donor parity).
> No Godot was run and no runner job was submitted. **No donor parity claim.**

---

## 0. Mandate and answer in one paragraph

COORD: the clean y08c capture has **no concentric rings** (Y08b's `game.gd` fix worked) but
**persistent horizontal striping across the meadow**; at −32° a 2 m cell minifies far more
vertically than horizontally while `filter_linear_mipmap` is isotropic. Test an anisotropic
sampler hint as a one-line A/B, verify the exact hint name in project docs/source, keep every
other shader byte identical, back up with SHA, and report acceptance criteria against y08c.

**Answer:** the requested token `filter_linear_anisotropic` **does not exist** in either the
project's Godot 4.4 or the ticket's Godot 4.7 shader lexer (§2). The *closest valid* token —
the one that preserves linear magnification **and** the mip chain and adds anisotropy — is
`filter_linear_mipmap_anisotropic`. That exact one-line substitution was applied at `:60`
(§3), with a byte proof that nothing else changed (§4). Whether it actually reduces the
striping is **UNVERIFIED** until G04 runs a matched-camera capture and the C01 deltas are read
(§6).

---

## 1. Why a sampler hint is the right lever (OBSERVED / DERIVED)

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | `Y08c_capture_log.md:38-77`: job `y08c-realmap` ticket 605, `exit=0`, PNG 1,200,060 B, 1280×720, `non_black_fraction=1.0`, `mean_luma=78.248`, `full_width_dark_rows=0`, `script_error_lines=0`. Concentric rings gone; striping remains. |
| E02 | OBSERVED | Same log `:81`: capture camera `camera_pos=(145.9536, 58.0, -86.72936)`, `target=(385.9536, 60.45124)`. This differs from the older `g04`/`y07`/`y08` pose `(144.1104, 58.0, -88.57262)` — so the A/B reference camera **must** be y08c's, not the older baseline. |
| E03 | OBSERVED | `A06_filtering_aliasing.md:61`: camera pitch **−32°**, height 20–58 m (`config.gd:108`, `data.gd:196-198`, `camera3d.gd:278-282`); shallow oblique ground plane, the minification regime anisotropy is designed for. |
| E04 | OBSERVED | `A06 §2`: one atlas cell = 1024 texels per 2 m → 512 texels/m; a cell projects to ~71–98 px → **10.4–14.4 atlas texels per screen pixel** at mid-screen, needing ≈3.7 mip levels. B02 supplies mips; B01 supplies `filter_linear_mipmap`. |
| E05 | OBSERVED | C01 `terrain_ab_metric.py` on y08c, clean meadow crop `--crop 1000,600,270,100` (same box Y08 §1/§8 used): `coherence=0.925775`, `streak_angle_deg=0.204653`, `gradient_angle_deg=-89.795347`, `band_peak_deg=90`, `band_anisotropy=0.993458`, `band_peak_to_second=3.493979`, `band_peak_to_mean=8.484959`, `row_periodicity=0.461511`, `BV32 between_block_var=8.696`, `std_luma=11.690`. Full frame: `coherence=0.428750`, `row_periodicity=0.364478`, `BV32=84.286`. |
| E06 | DERIVED | E05 is a quantitative horizontal-striping signature: gradient almost purely vertical (≈−90°) ⇒ streaks ≈0° (horizontal); FFT power peaks at 90° with 3.49× the second bin; coherence 0.926 means one orientation dominates. Anisotropic footprint selection is the one hint that can preferentially preserve detail along the shallow axis instead of applying one isotropic mip LOD. |
| E07 | OBSERVED | `A06 §1.5/§4`: project uses `gl_compatibility`; anisotropy works there via `EXT_texture_filter_anisotropic` **but requires a mip chain and an `_anisotropic` hint**. `project.godot` has no `anisotropic_filtering_level` override ⇒ engine default **2**. |
| E08 | OBSERVED | `world3d_terrain.gd:306` `atlas_mode = ATLAS_MODE_SINGLE` (default); `:649` binds `get_atlas_texture()` to `tile_atlas` (`:689`); `A06 §1.3`: B02's `_prepare_atlas_image()` calls `generate_mipmaps` on the single/split `ImageTexture`. **Precondition met for the default capture.** The `array` fallback (`_load_array`) still has no mips (A06 Fix 1), so the hint would be inert on that transport — out of this ticket's ownership. |
| E09 | OBSERVED | `A08_donor_truth_local.md:257` / `A06 §4`: donor is `filteringquality=tfIsotropic` (`reftile.mat:24-49`). Anisotropy is therefore a **PORT APPROX** substitution, never a donor value. |

---

## 2. Hint validation evidence (OBSERVED — the decisive part)

The ticket asked for `filter_linear_anisotropic` and said to verify the exact name in project
docs/source, using the closest valid one if unavailable. **The requested token is unavailable.**

1. **Docs grammar is ambiguous.** Godot 4.7 *Shading language → Uniform hints* table lists
   `filter[_nearest, _linear][_mipmap][_anisotropic]` — a schema a reader could expand into
   `filter_linear_anisotropic`. That expansion is **not** what the lexer accepts.
   (URL: `https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html`,
   served as "Godot Engine 4.7 documentation".)

2. **Godot 4.7 source — exact token list.** Fetched
   `https://raw.githubusercontent.com/godotengine/godot/4.7/servers/rendering/shader_language.cpp`:
   `keyword_list[]` and `get_texture_filter_name()` both enumerate exactly six filter tokens:

   ```
   filter_nearest
   filter_linear
   filter_nearest_mipmap
   filter_linear_mipmap
   filter_nearest_mipmap_anisotropic
   filter_linear_mipmap_anisotropic
   ```
   plus `repeat_enable` / `repeat_disable`. **`filter_linear_anisotropic` is absent**; an
   unrecognised hint in a `uniform` declaration is a shader parse error, so using it would
   have reproduced the Y08b `SCRIPT ERROR` class of gate failure.

3. **Godot 4.4 source — project's actual version.** `variant3d/project.godot` has
   `config/features=PackedStringArray("4.4", "GL Compatibility")`. Fetched
   `https://raw.githubusercontent.com/godotengine/godot/4.4/servers/rendering/shader_language.cpp`:
   the same six tokens, same absence of `filter_linear_anisotropic`. `G14_static_audit.md:50`
   independently records `filter_linear_mipmap` as valid under this grammar.

4. **Closest valid choice (DERIVED).** Current hint is `filter_linear_mipmap` (linear mag +
   mip min). To add anisotropy while preserving both existing properties, only
   `filter_linear_mipmap_anisotropic` qualifies. The other anisotropic token
   (`filter_nearest_mipmap_anisotropic`) would change magnification back to nearest — the
   exact regression B01 removed. Note `A06 §4 table` lists the non-existent
   `filter_linear_anisotropic`; `A06 §6 Fix 3` lists the correct
   `filter_linear_mipmap_anisotropic`. The source settles the disagreement in favour of Fix 3.

**Validity verdict:** `filter_linear_mipmap_anisotropic` is valid in both Godot 4.4 and 4.7;
it is the token applied.

---

## 3. Exact applied diff (one line, one hunk)

```diff
diff --git a/inbox/backup/terrain_tileindex.gdshader.bak-Y10 b/variant3d/shaders/terrain_tileindex.gdshader
index 4f4d00c6..9d6f2060 100644
--- a/inbox/backup/terrain_tileindex.gdshader.bak-Y10
+++ b/variant3d/shaders/terrain_tileindex.gdshader
@@ -57,7 +57,7 @@ render_mode blend_mix, unshaded, cull_disabled;
 // magnification of the repeating cell cannot band at shallow cameras. This is
 // NOT donor parity: donor maNearest/miNearestMipmapLinear stays the cited
 // intent (reftile.mat:29-37); no anisotropic claim (A08 §7 #4, reftile.mat:24).
-uniform sampler2D tile_atlas : filter_linear_mipmap, repeat_enable;
+uniform sampler2D tile_atlas : filter_linear_mipmap_anisotropic, repeat_enable;
 // V7-85 asset: donor block atlas, one preset per cell. Cell = preset index
 // (presets_summer.json:2-125), row-major from top-left, grid in `atlas_grid`.
 // RGB only: no normal map — donor tangentSpace=false (shaders.lib:19) and
```

`git diff --no-index --numstat` → **1 insertion, 1 deletion**, one hunk. Exit 1 is the normal
"files differ" status of `--no-index`; `--check` context shows no whitespace error.

### 3.1 Backup (taken BEFORE the edit)

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader' -Destination 'inbox\backup\terrain_tileindex.gdshader.bak-Y10' -Force` |
| Pre-edit shader | **30,133 bytes**, SHA-256 `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3` — equals the B01-released baseline cited in `Y08_checkerboard.md:381`, and byte-identical to `bak-B01b` (B01b was reverted; B01 released). |
| New backup | **30,133 bytes**, SHA-256 identical to the above; `Test-Path` was False, so no existing backup was overwritten (`bak-B01`, `bak-B01b`, `bak-BSHADER`, `bak-DALPHA02`, `bak-MASKALPHAFIX`, `bak-TERRAINDARKFIX*`, `bak-TRNSHADER` left intact). |
| Post-edit shader | **30,145 bytes**, SHA-256 `F528612524165C618BB785B186535D0B023560D725C6783AF422E2623C05FEEC`. |

### 3.2 Known, deliberate comment staleness (OBSERVED)

The comment block at `:52-59` still says "tile_atlas now uses `filter_linear_mipmap`" and
"no anisotropic claim (A08 §7 #4, reftile.mat:24)". Under the strict one-line mandate it was
left **byte-identical**. Reading it literally is now stale about the hint; the second clause
remains true in the sense that **no donor-parity anisotropic claim is made** — anisotropy here
is explicitly PORT APPROX (§5). A cosmetic comment sync is a separate non-A/B cleanup, not part
of this diff.

---

## 4. Invariant proof (all OBSERVED — verified after the edit, no Godot)

Byte-level check: taking the backup bytes, the old declaration occurs **exactly once**, the new
one occurs **zero** times; replacing the old token once reproduces the current file
**byte-for-byte** (`BYTE_IDENTICAL_AFTER_SINGLE_SUBSTITUTION = True`). Byte delta is **+12**,
exactly `len("_anisotropic")` — no other byte moved.

| Invariant | Status | Evidence |
|---|---|---|
| Total length | **502 → 502 lines** | `Get-Content` count on both files; no anchor shifted. |
| Uniform set | **31 → 31**, same order/names | Regex `^\s*uniform\s+` on both. Sampler identifier `tile_atlas` unchanged; only its filter hint differs. |
| `mask_to_alpha` contract | intact | `:235` `uniform float mask_to_alpha = 1.0;` byte-identical; both A/B endpoints still one compiled program. |
| Protected anchors | byte-identical | `:235`, `:365-378` (`alpha_patch_uv`), `:392` (`vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));`), `:412-419` (sentinel + P4), `:427` (`rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;`), `:475` (`ALPHA = 1.0;`), `:476`, `:478-502` A/B block — compared line-by-line. |
| Other samplers | untouched | `:66` `alpha_atlas : filter_nearest`, `:72` `alphavert_atlas : filter_nearest`, `:83` `shadow_map : filter_nearest` — all verbatim. |
| `textureGrad` / unwrapped gradients | intact | `textureGrad(` count 1 in both; gradients still from unwrapped `v_st*uv_repeat` inside `tile_rgb`. |
| A06 half-texel inset | intact | `inset = 0.5 /` count 1 in both; atlas-cell bleed guard unchanged. |
| A02-P1 sentinel + P4 compression | intact | `:419` `a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, step(2.5, scol) * step(2.5, srow));` byte-identical; `step(2.5,` count 2 in both. |
| `fract(v_st * uv_repeat)` at `:392` | intact | count 1 in both; world 2 m period unchanged. |
| `mask_to_alpha` token count | 5 → 5 | No added/removed branch. |
| S-25-09 (no synthetic field) | honoured | No bitmap, hash, dither, noise, gain or luminance field added. |
| Donor parity | **none claimed** | Anisotropy is PORT APPROX vs donor `tfIsotropic`. |
| Process | honoured | No Godot process, runner job, queue/lock/counter, game.gd, asset, config, test or donor file touched. |

---

## 5. Hypothesis and failure mode (INFERRED / DERIVED)

**[I]** Anisotropic minification should choose an elongated footprint aligned with the ground
plane, keeping more detail along the shallow axis and reducing the vertical averaging that
makes each 2 m row blur into horizontal bands. Predicted movement: lower `coherence`, lower
`band_anisotropy` / `band_peak_to_second`, lower `row_periodicity`, with `BV32` **not** dropping
(the hint should preserve, not remove, in-plane detail).

**[D] Two reasons this may be a no-op, both to be reported honestly rather than tuned around:**

1. Engine anisotropic level is the default **2** (`project.godot` has no override, E07). The
   hint alone may produce only a small movement. Raising `anisotropic_filtering_level` is a
   **project.godot** edit, explicitly outside this ticket's one-line shader A/B and not done.
2. If the capture runs the `array` atlas transport, its texture has no mip chain (E08), and an
   anisotropic hint is inert. The default `single` transport does have mips, so the matched
   capture should use the default (no atlas-mode override).

**[U]** Whether the striping is actually caused by isotropic minification versus by the
underlying tile-id/patch data (Y08 §4-§9) cannot be settled by a shader hint alone. If the C01
deltas (§6) do not move, record that anisotropy did not fix the striping and **revert** (§7);
do not stack further shader changes onto this A/B.

---

## 6. Matched-camera capture acceptance vs y08c (for G04 — NOT run here)

### 6.1 Capture recipe (G04 owns the runner; query `status` before submitting)

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id y10-aniso-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y10/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

Must match y08c: same **camera pose** `(145.9536, 58.0, -86.72936)` / target
`(385.9536, 60.45124)` (E02), same seed `20261113`, same `--screenshot-frames 10`, windowed
(no `--headless`), 1280×720 PNG. If the camera diag differs, the A/B is **comparative only**,
not pixel-aligned — say so.

### 6.2 Hard gate conditions (unchanged; no threshold weakened)

`exit=0`, `status=ok`, `script_error_lines == 0`, PNG 1280×720 non-blank,
`non_black_fraction=1.0`, `full_width_dark_rows=0`. Existing gates stay as in
`Y08_checkerboard.md:562-573`: selftest 29/29, uitest 17/17, `t_render_mode`,
`t_map_variety` 5/5 incl. `same_seed_byte_identical`, `assert_clean CLEAN`, 2D `app/` untouched.
Concentric rings must stay absent (Y08b/Y08c state); no new seam, black row or z-fighting.

### 6.3 C01 movement indicators — y08c baseline vs the Y10 frame

Measure **both** images with the identical command, same crop:

```
python variant3d\tools\terrain_ab_metric.py <PNG> --crop 1000,600,270,100 --json
```

| Metric (`candidate.metrics.*`) | y08c baseline (OBSERVED, E05) | Expected direction if anisotropy helps | Reading |
|---|---:|---|---|
| `directional_gradient.coherence` | **0.925775** | **down** | less single-orientation domination = less striping |
| `directional_gradient.streak_angle_deg` | **0.204653** (horizontal) | lose the narrow 0° lock | banding no longer axis-locked |
| `directional_gradient.band_peak_deg` | **90** | move off 90 and/or flatten | horizontal FFT peak weakens |
| `directional_gradient.band_anisotropy` | **0.993458** | **down** | directional peak less extreme |
| `directional_gradient.band_peak_to_second` | **3.493979** | **down** | no single dominant band |
| `seam_repetition.row_periodicity` | **0.461511** | **down** (key indicator) | fewer repeated horizontal rows |
| `block_variance[32].between_block_var` (BV32) | **8.696** | **must NOT collapse**; up is better | anisotropy preserves detail; a fall means over-blur |
| `directional_gradient.axis_gradient_energy` | **61.295** | no spike | no new high-frequency grain |
| `color.std_luma` | **11.690** | no collapse | field does not flatten |

Optional corroboration on the G05 crop `--crop 120,60,1040,580`: y08c `coherence=0.391106`,
`row_periodicity=0.403505`, `BV32=98.656`, `tile_repeat=0.789247` (OBSERVED). Whole-frame
y08c: `coherence=0.428750`, `row_periodicity=0.364478`, `BV32=84.286`.

**Binding:** every entry is a **movement indicator, never a threshold and never donor parity**
(CHARTER §3/§5; C01 §5.4). A favourable A/B is *evidence for the mechanism*, not a gate pass
and not donor fidelity. If `coherence`/`row_periodicity` fall while BV32 holds and gates stay
green, record the A/B as a promising PORT APPROX and hand the visual R1–R6 read to a second
agent. If metrics do not move or BV32 collapses, record the null result and use §7.

---

## 7. Rollback (byte-exact, no other file)

```powershell
Copy-Item -LiteralPath 'inbox\backup\terrain_tileindex.gdshader.bak-Y10' -Destination 'variant3d\shaders\terrain_tileindex.gdshader' -Force
Get-FileHash -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader','inbox\backup\terrain_tileindex.gdshader.bak-Y10' -Algorithm SHA256
```

Both hashes must return `E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3`
(30,133 bytes), the exact pre-Y10 / B01-released state. No other file needs rolling back.

---

## 8. Scope and honesty statement

Repo files written/edited by this ticket: **the shader (one line), `inbox/backup/terrain_tileindex.gdshader.bak-Y10`, and this report — exactly three.** No runner job, Godot process, queue/lock/counter, game.gd, atlas/asset, config, test, tool, donor file or git state change. The C01 tool was invoked **read-only** on the existing y08c PNG; scratch JSON/scripts are under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y10\`.

The applied hint is **validated by source** but its **visual effect is UNVERIFIED** — no
capture was taken. Concentric-ring removal belongs to Y08b/Y08c and is not claimed here.
**Donor parity stays UNVERIFIED** (no donor GPU A/B frame exists). This agent stays available
for a follow-up capture review or rollback.

*End of Y10 report — one valid one-line A/B applied, invariants verified, capture pending.*
