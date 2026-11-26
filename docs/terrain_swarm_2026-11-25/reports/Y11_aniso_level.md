---
id: Y11
ticket: "WAVE Y / Y11 — raise Godot's anisotropic filtering level from the implicit default to 16x"
title: "Y11 — project.godot anisotropic_filtering_level key validated from source, set to 16x (enum index 4), applied, capture pending"
owner: Y11 (EXCLUSIVE owner of variant3d/project.godot)
created: 2026-11-25
status: APPLIED_NOT_CAPTURED__KEY_SOURCE_VALIDATED__ALL_INVARIANTS_VERIFIED__PARITY_UNVERIFIED
scope: "Exactly three repo files touched: variant3d/project.godot (one inserted line), its new backup, and this report. NO runner job, NO Godot process, no queue/lock/counter mutation, no shader/game.gd/asset/test/tool/donor/git edit. C01 invoked read-only on the existing y10 PNG; scratch scripts/JSON live only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y11\\."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
prereads:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/Y10_anisotropic.md
  - docs/terrain_swarm_2026-11-25/reports/Y10_capture_log.md
backup: inbox/backup/project.godot.bak-Y11
backup_sha256: 6FFB4CDC3FA7040371FDAF414729C0CA5EDF3154953951F4A3A4E098F1248AFA
post_sha256: FA2E4F5C26E1CED3A3B73F8CEE43C065EFAC845368C609543DE1DBC702B022D8
---

# Y11 — raise the engine anisotropy level so the Y10 hint is no longer nearly inert

> **Labels.** **OBSERVED** = literal file/source/docs output or a measurement made on the named
> PNG with the named tool. **DERIVED** = arithmetic/control-flow consequence. **INFERRED** =
> attribution with its caveat stated. **UNVERIFIED** = not proven (above all, donor parity).
> No Godot was run and no runner job was submitted. **No donor parity claim.**

---

## 0. Mandate and answer in one paragraph

COORD: Y10's `filter_linear_mipmap_anisotropic` sampler hint compiled and helped slightly, but
the engine anisotropy level is the implicit default (low), so the hint is nearly inert. Raise the
project anisotropy level to 16x via the correct ProjectSettings key, verify the exact key name
against Godot 4.4/4.7 source or docs, keep every other setting byte-identical, do **not** enable
MSAA/FXAA, back up with SHA, and report an exact diff, key-validation evidence, an expected cost
note, and matched-camera capture acceptance vs y10.

**Answer:** two source-backed corrections were necessary before the one-line edit. **(1) Key
path:** the ticket's guessed `rendering/textures/anisotropic_filtering_level` does **not** exist;
the real key is `rendering/textures/default_filters/anisotropic_filtering_level` (§2). **(2)
Value:** the key is a `PROPERTY_HINT_ENUM` **selector 0..4**, not a sample count — `Viewport`'s
enum is `ANISOTROPY_DISABLED, _2X, _4X, _8X, _16X` (§2.4), so **16x is encoded as `4`**, and a
literal `16` would be out of range. The engine's effective default was already **4x** (selector
`2`), not 2x; Y10's "default level 2" was the raw setting value. The applied line, inside the
existing `[rendering]` section, is
`textures/default_filters/anisotropic_filtering_level=4` (§3). All other bytes are unchanged
(§5), no AA key was added (§5), and the visual effect is **UNVERIFIED** until G04 runs the
matched-camera capture (§7).

---

## 1. What Y10 established (OBSERVED, cited)

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | `Y10_capture_log.md:41-49`: job `y10-realmap` ticket 606, `exit=0`, `status=ok`, `run=47.2022 s`, PNG `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y10\realmap.png` 1,351,399 B, 1280×720. |
| E02 | OBSERVED | Same log `:51-77`: `non_black_fraction=1.0`, `mean_luma=77.166`, `full_width_dark_rows=0`, `script_error_lines=0`; literal stderr grep for `SCRIPT ERROR\|shader\|compile\|anisotropic` returned no lines — the Y10 hint compiled. Three exit-time cleanup `ERROR:` lines were recorded, not claimed harmless. |
| E03 | OBSERVED | Same log `:84`: capture camera `camera_pos=(145.7892, 58.0, -86.89378)`, `target=(385.7892, 60.28682)`, seed `20261113`, `--screenshot-frames 10`, windowed. This is the pose Y11 must match (the older `g04`/`y07`/`y08` pose `(144.1104, 58.0, -88.57262)` is **not** the right reference). |
| E04 | OBSERVED | `Y10_anisotropic.md:62,190-192`: project had no anisotropy override; the ticket's own caveat names the default `2` and says raising it is a `project.godot` edit outside Y10's shader scope. |
| E05 | OBSERVED | `Y10_anisotropic.md:62`: project uses `gl_compatibility`; anisotropy works there via `EXT_texture_filter_anisotropic` but needs a mip chain plus an `_anisotropic` sampler hint. `Y10_capture_log.md:78-80` proves that hint is present and compiling. |
| E06 | OBSERVED | `A08_donor_truth_local.md` / `A06 §4` as cited by `Y10_anisotropic.md:64`: donor is `filteringquality=tfIsotropic` (`reftile.mat:24-49`). Anisotropy is a **PORT APPROX**, never a donor value. |

### 1.1 Immediate C01 baseline — measured on the y10 frame (OBSERVED, new this ticket)

The C01 tool was run **read-only** on the existing y10 PNG with the identical commands
`python variant3d\tools\terrain_ab_metric.py <PNG> --crop <crop> --json`; raw JSON is under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y11\y10_{meadow,g05crop,full}.json`. These
are the correct immediate A/B baselines for Y11; the y08c numbers in `Y10_anisotropic.md:226-248`
use a **different camera** (E03) and must not be mixed in.

| `candidate.metrics.*` | y10 meadow `1000,600,270,100` | y10 G05 `120,60,1040,580` | y10 full frame |
|---|---:|---:|---:|
| `directional_gradient.coherence` | **0.861959** | 0.332241 | 0.381009 |
| `directional_gradient.streak_angle_deg` | 0.621671 | 178.890166 | 179.665292 |
| `directional_gradient.gradient_angle_deg` | −89.378329 | 88.890166 | 89.665292 |
| `directional_gradient.band_peak_deg` | 90 | 90 | 90 |
| `directional_gradient.band_anisotropy` | 0.985681 | 0.729541 | 0.765136 |
| `directional_gradient.band_peak_to_second` | 3.842767 | 1.132422 | 1.424316 |
| `directional_gradient.axis_gradient_energy` | 39.90372 | 107.897083 | 101.782185 |
| `seam_repetition.row_periodicity` | **0.313302** | **0.360410** | **0.391524** |
| `seam_repetition.tile_repeat` | **0.623813** | **0.800575** | **0.830111** |
| `seam_repetition.tile_period_px` / driver | 7 / `tile_repeat` | 45 / `tile_repeat` | 45 / `tile_repeat` |
| `block_variance[32].between_block_var` (BV32) | 37.396755 | 112.299065 | 96.062981 |
| `color.std_luma` | 12.456518 | 18.912785 | 17.959549 |

---

## 2. Key validation evidence (OBSERVED — decisive)

### 2.1 The ticket's guessed key does not exist

The key `rendering/textures/anisotropic_filtering_level` appears nowhere in the Godot 4.4
`ProjectSettings` property list or in the 4.4/4.7 engine sources consulted below. Using it would
create an inert custom setting and the anisotropy level would stay at the default.

### 2.2 Godot 4.4 docs — exact key, default and meaning

Fetched `https://docs.godotengine.org/en/4.4/classes/class_projectsettings.html` (served as
"Godot Engine 4.4 documentation in English"). Verbatim property table row and description:

> `[int] rendering/textures/default_filters/anisotropic_filtering_level` = `2`

> "Sets the maximum number of samples to take when using anisotropic filtering on textures (as a
> power of two). A higher sample count will result in sharper textures at oblique angles, but is
> more expensive to compute. A value of `0` forcibly disables anisotropic filtering, even on
> materials where it is enabled."

> "**Note:** This property is only read when the project starts. To change the anisotropic
> filtering level at runtime, set `Viewport.anisotropic_filtering_level` on the root `Viewport`
> instead."

A second docs row (`rendering/textures/decals/filter`) and the light-projector row cross-reference
the same full path, so the `default_filters` segment is not a typo.

### 2.3 Engine registration — it is an enum selector

Fetched `https://raw.githubusercontent.com/godotengine/godot/4.7/servers/rendering/rendering_server.cpp`
(verbatim, line 3719 of that file):

```cpp
GLOBAL_DEF(PropertyInfo(Variant::INT, "rendering/textures/default_filters/anisotropic_filtering_level", PROPERTY_HINT_ENUM, String::utf8("Disabled (Fastest),2× (Faster),4× (Fast),8× (Average),16× (Slow)")), 2);
```

`PROPERTY_HINT_ENUM` with five labels means the stored value is an **index 0..4**, not a sample
count. (For 4.4 the same full path is independently confirmed by the 4.4 docs in §2.2 and by the
4.4 `GLOBAL_GET` in §2.5; a direct 4.4 `GLOBAL_DEF` line was not located — the 4.4 path
`servers/rendering/rendering_server.cpp` returns 404. This is stated rather than guessed.)

### 2.4 Value semantics — 16x is `4`, not `16`

Fetched `https://raw.githubusercontent.com/godotengine/godot/4.4/scene/main/viewport.h`
(verbatim):

```cpp
enum AnisotropicFiltering {
    ANISOTROPY_DISABLED,   // 0
    ANISOTROPY_2X,         // 1
    ANISOTROPY_4X,         // 2
    ANISOTROPY_8X,         // 3
    ANISOTROPY_16X,        // 4
    ANISOTROPY_MAX
};
...
AnisotropicFiltering anisotropic_filtering_level = ANISOTROPY_4X;
```

Fetched `https://raw.githubusercontent.com/godotengine/godot/4.7/scene/main/viewport.cpp`: the
bound runtime property uses the same five-label hint
`"Disabled (Fastest),2× (Faster),4× (Fast),8× (Average),16× (Slow)"`. The 4.4 file has the same
enum hint with a `16x` spelling. Together with §2.3:

| Stored value | Enum | Effective samples |
|---:|---|---:|
| 0 | `ANISOTROPY_DISABLED` | off |
| 1 | `ANISOTROPY_2X` | 2x |
| **2 (engine default)** | **`ANISOTROPY_4X`** | **4x** |
| 3 | `ANISOTROPY_8X` | 8x |
| **4 (applied by Y11)** | **`ANISOTROPY_16X`** | **16x** |
| 16 | *out of range* (`ANISOTROPY_MAX` = 5) | invalid |

**DERIVED:** the effective pre-Y11 level was already 4x, so Y11 raises 4x → 16x (4× the samples).
Writing the literal `16`, as the ticket's phrasing might be read, would be past the enum's end and
is therefore **not** what was applied. If COORD explicitly wants the literal `16` despite this,
I can change it on request and will flag it as out-of-range in the report.

### 2.5 The value is consumed at startup

Fetched 4.4 and 4.7 `scene/main/viewport.cpp`; both contain the same constructor line (4.4 line
5167, 4.7 line 5582):

```cpp
set_anisotropic_filtering_level((Viewport::AnisotropicFiltering)(int)GLOBAL_GET("rendering/textures/default_filters/anisotropic_filtering_level"));
```

The cast is direct — further proof the stored integer is the enum index. Fetched 4.4
`servers/rendering/renderer_viewport.cpp`: `viewport_set_anisotropic_filtering_level()` stores the
value and calls `_configure_3d_render_buffers()`, which passes it through
`rb_config.set_anisotropic_filtering_level(...)` into the 3D render buffers. Consistent with the
docs' "only read when the project starts" note: **a fresh Godot run is required; no runtime
toggle exists from this setting.**

### 2.6 Verdict

**Validated:** full key `rendering/textures/default_filters/anisotropic_filtering_level`; written
inside `[rendering]` as `textures/default_filters/anisotropic_filtering_level=4`; expected
effective level 16x. The ticket's guessed key path was rejected on source evidence.

---

## 3. Exact applied diff

```diff
diff --git a/inbox/backup/project.godot.bak-Y11 b/variant3d/project.godot
index ff538805..c495c4d0 100644
--- a/inbox/backup/project.godot.bak-Y11
+++ b/variant3d/project.godot
@@ -25,4 +25,5 @@ window/stretch/aspect="expand"
 renderer/rendering_method="gl_compatibility"
 renderer/rendering_method.mobile="gl_compatibility"
 textures/canvas_textures/default_texture_filter=1
+textures/default_filters/anisotropic_filtering_level=4
 environment/defaults/default_clear_color=Color(0.09, 0.11, 0.08, 1)
```

`git diff --no-index --numstat` → **1 insertion, 0 deletions**, one hunk. Exit 1 is the normal
"files differ" status of `--no-index`. `git diff --no-index --check` reported no whitespace error
(only the repository's pre-existing LF→CRLF warning on both files).

### 3.1 Backup (taken BEFORE the edit)

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\project.godot' -Destination 'inbox\backup\project.godot.bak-Y11' -Force`, guarded by `Test-Path` (was **False**, so nothing was overwritten). |
| Pre-edit file | **957 bytes**, SHA-256 `6FFB4CDC3FA7040371FDAF414729C0CA5EDF3154953951F4A3A4E098F1248AFA`. |
| New backup | **957 bytes**, SHA-256 identical to the above. No other existing backup was touched. |
| Post-edit file | **1,012 bytes**, SHA-256 `FA2E4F5C26E1CED3A3B73F8CEE43C065EFAC845368C609543DE1DBC702B022D8`. |
| Byte delta | **+55** = exactly `len("textures/default_filters/anisotropic_filtering_level=4\n")`; no other byte moved. |

---

## 4. Expected cost note (DERIVED / INFERRED — no benchmark run)

| ID | Label | Note |
|---|---|---|
| C01 | OBSERVED | Godot docs §2.2: higher sample count is "more expensive to compute"; the 4.7 enum label for 16x is literally `"16× (Slow)"`. |
| C02 | DERIVED | 4x → 16x is **4× the anisotropic samples per minified texel** on every texture whose sampler requests anisotropy. In this project that is the Y10 `tile_atlas` hint (`filter_linear_mipmap_anisotropic`); the other samplers (`alpha_atlas`, `alphavert_atlas`, `shadow_map`) remain `filter_nearest` and are not affected by this lever. Cost is texture-memory bandwidth/shader taps on the ground pass, **not** a new render target or extra geometry pass. |
| C03 | OBSERVED | No MSAA / FXAA / TAA key was added or enabled (§5). F04/S10's "AA is useless for the donor and may cost perf" constraint is honoured: this change is a sampler-quality knob, not antialiasing. |
| C04 | INFERRED | Worst case is a measurable frame-time regression on a weak/integrated GPU. G04 should record the runner `run` value beside y10's `47.2022 s` (E01), but **that number includes startup/import and is not a clean FPS measurement** — treat any difference as a smoke signal, not a perf gate. No perf threshold is asserted by this ticket. |
| C05 | INFERRED | The driver may clamp to the hardware `EXT_texture_filter_anisotropic` maximum; if the device supports less than 16x, the effective level is lower. This is a device property, not a project setting, and is UNVERIFIED here (no Godot run). |
| C06 | OBSERVED | **PORT APPROX:** donor is `tfIsotropic` (E06). This is an internal-consistency experiment only; **donor parity stays UNVERIFIED** and no donor GPU A/B frame exists. |

---

## 5. Invariant proof (all OBSERVED — verified after the edit, no Godot)

Scratch verifier `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y11\verify_y11.py` read both
files byte-for-byte. Verbatim results: `key_in_before = 0`, `key_in_after = 1`,
`BYTE_IDENTICAL_AFTER_SINGLE_INSERTION = True`, `byte_delta = 55`, `lines: 28 -> 29`,
`added lines = ['textures/default_filters/anisotropic_filtering_level=4']`,
`pre_lines_preserved_in_order = True (28/28)`.

| Invariant | Status | Evidence |
|---|---|---|
| Total length | **28 → 29 lines** | Exactly one new line; no anchor shifted. |
| All 28 pre-existing lines | byte-identical and in order | `pre_lines_preserved_in_order = True (28/28)`; only new line is the key. |
| Section placement | `[rendering]` | Inserted between `textures/canvas_textures/default_texture_filter=1` and `environment/defaults/default_clear_color=...`, so the full path resolves to §2's validated key. |
| MSAA | **absent** | case-insensitive scan of post bytes: `banned[msaa] present = False`. |
| FXAA | **absent** | `banned[fxaa] present = False`. |
| TAA / any `anti_aliasing` key | **absent** | `banned[use_taa] present = False`, `banned[anti_aliasing] present = False`. |
| Renderer unchanged | byte-identical | `renderer/rendering_method="gl_compatibility"` and `.mobile` line untouched. |
| 2D / `app/` | untouched | No file under `app/` read or written by this ticket. |
| Y10 shader / backup | untouched | This ticket did not edit `variant3d/shaders/terrain_tileindex.gdshader` or its `.bak-Y10`. |
| Process | honoured | No Godot process, runner job, queue/lock/counter, game.gd, asset, test or donor file touched; no git state change. |
| S-25-09 (no synthetic field) | honoured | No bitmap, hash, dither, noise, gain or luminance field added. |
| Donor parity | **none claimed** | Anisotropy is PORT APPROX vs donor `tfIsotropic`. |

---

## 6. Rollback (byte-exact, no other file)

```powershell
Copy-Item -LiteralPath 'inbox\backup\project.godot.bak-Y11' -Destination 'variant3d\project.godot' -Force
Get-FileHash -LiteralPath 'variant3d\project.godot','inbox\backup\project.godot.bak-Y11' -Algorithm SHA256
```

Both hashes must return
`6FFB4CDC3FA7040371FDAF414729C0CA5EDF3154953951F4A3A4E098F1248AFA` (957 bytes), the exact
pre-Y11 state. No other file needs rolling back (Y10's shader hint stays as-is).

---

## 7. Matched-camera capture acceptance vs y10 (for G04 — NOT run here)

### 7.1 Capture recipe (G04 owns the runner; query `status` before submitting)

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id y11-aniso16-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y11/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

Must match y10 on: **camera pose** `(145.7892, 58.0, -86.89378)` / target
`(385.7892, 60.28682)` (E03), seed `20261113`, `--screenshot-frames 10`, windowed (no
`--headless`), 1280×720 PNG, default atlas transport (no atlas-mode override — the `array`
transport has no mip chain, Y10 E08). If the camera diag differs, the A/B is **comparative only**,
not pixel-aligned — say so. The project setting is read at startup (§2.5), so the fresh run is
mandatory; an already-running process will not pick the change up.

### 7.2 Hard gate conditions (unchanged; no threshold weakened)

`exit=0`, `status=ok`, `script_error_lines == 0`, PNG 1280×720 non-blank,
`non_black_fraction=1.0`, `full_width_dark_rows=0`. Additionally grep stderr for
`project.godot|anisotropic|parse error` and report any line — a malformed setting must not pass
silently. Existing gates stay as in `Y08_checkerboard.md:562-573`: selftest 29/29, uitest 17/17,
`t_render_mode`, `t_map_variety` 5/5 incl. `same_seed_byte_identical`, `assert_clean CLEAN`, 2D
`app/` untouched. Concentric rings must stay absent; no new seam, black row or z-fighting.

### 7.3 C01 movement indicators — y10 baseline (§1.1) vs the Y11 frame

Measure **both** images with the identical command and crop:

```
python variant3d\tools\terrain_ab_metric.py <PNG> --crop 1000,600,270,100 --json
```

| Metric (`candidate.metrics.*`) | y10 baseline (§1.1, meadow) | Expected direction from 4x → 16x | Reading |
|---|---:|---|---|
| `directional_gradient.coherence` | **0.861959** | **down** | less one-orientation domination = less striping |
| `seam_repetition.row_periodicity` | **0.313302** | **down** (key indicator) | fewer repeated horizontal rows |
| `seam_repetition.tile_repeat` | **0.623813** | **down** / no new cadence | anisotropy must not invent a new 2 m rhythm |
| `directional_gradient.band_anisotropy` | 0.985681 | down | directional FFT peak less extreme |
| `directional_gradient.band_peak_to_second` | 3.842767 | down | no single dominant band |
| `block_variance[32].between_block_var` (BV32) | 37.396755 | **must NOT collapse**; up is better | 16x preserves detail; a fall means over-blur |
| `directional_gradient.axis_gradient_energy` | 39.90372 | no spike | no new high-frequency grain |
| `color.std_luma` | 12.456518 | no collapse | field does not flatten |

Corroboration on the wider G05 crop `--crop 120,60,1040,580`: y10 `coherence=0.332241`,
`row_periodicity=0.360410`, `tile_repeat=0.800575`, `BV32=112.299065`. Whole-frame y10:
`coherence=0.381009`, `row_periodicity=0.391524`, `tile_repeat=0.830111`, `BV32=96.062981`.

**Binding:** every entry is a **movement indicator, never a threshold and never donor parity**
(CHARTER §3/§5; C01 §5.4). A favourable A/B is *evidence for the mechanism*, not a gate pass and
not donor fidelity. Read coherence / row_periodicity / tile_repeat **beside, not instead of**, the
visual R1–R6 scan (C04:102, G21:137-142). If the three named metrics fall while BV32 holds and
gates stay green, record the result as a promising PORT APPROX and hand the visual read to a
second agent. If they do not move or BV32 collapses, record the null result (the hint may already
be saturated, or the striping may come from tile-id/patch data — `Y10_anisotropic.md §5`) and use
§6; do not stack further changes onto this A/B.

---

## 8. Scope and honesty statement

Repo files written/edited by this ticket: **`variant3d/project.godot` (one inserted line),
`inbox/backup/project.godot.bak-Y11`, and this report — exactly three.** No runner job, Godot
process, queue/lock/counter, shader, game.gd, atlas/asset, config other than `project.godot`,
test, tool, donor file or git state change. The C01 tool was invoked **read-only** on the existing
y10 PNG; scratch JSON/scripts are under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y11\`.

The applied key is **validated by Godot 4.4 docs and 4.4/4.7 source**, and the byte edit is
verified. Its **visual effect is UNVERIFIED** — no capture was taken and no runner job was
submitted. The value `4` encodes 16x because the setting is an enum selector; the literal `16`
was deliberately not used because it is out of range (§2.4). Concentric-ring removal belongs to
Y08b/Y08c, and the compiling anisotropic hint belongs to Y10 — neither is claimed here.
**Donor parity stays UNVERIFIED** (no donor GPU A/B frame exists). This agent stays available for
the follow-up capture review, a value change back to literal `16` if COORD insists, or rollback.

*End of Y11 report — one source-validated key added, 16x encoded as enum index 4, invariants verified, capture pending.*
