---
id: P13
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P13 (ready-to-apply water shader fix proposal, READ-ONLY)
date: 2026-11-25
status: APPLIED__P13_IMPL__PENDING_G04_GATES
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P13_water_fix_proposal.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
target_file: variant3d/shaders/water3d.gdshader
parity_guard: "No donor GPU A/B frame, capture, frame-time or profiler evidence exists. Every saving below is a static fetch/ALU count from OBSERVED source plus an INFERRED cost reading; all pixel equality on this GLES3 translator and every FPS/frame-time outcome are UNVERIFIED. These are PORT APPROX output-identical fast paths, not donor-parity claims."
---

# P13 — ready-to-apply diff for P05's three PORT APPROX-safe water wins

## 0. Scope and authority (read before applying)

- **This ticket is read-only.** Exactly one file was created (this report). No shader, script,
  test, config or asset in the repo was edited; no Godot process was started and no runner job
  was submitted (`WAVE_G_CHARTER.md:31`, `:67-70`; `CHARTER.md:55-69`).
- **DO NOT APPLY YET — ownership gate.** `variant3d/shaders/water3d.gdshader` is **not** owned by
  P13. Per the ticket, **COORD must grant exclusive ownership of this file AFTER G04 finishes**
  (same mechanism as the M03/P11 contest at `WAVE_G_CHARTER.md:102-104`). G04 is currently
  capturing; P13 must not touch the file or submit a job while G04 holds the runner.
- **Backup is mandatory before the edit** (`CHARTER.md:66`; `WAVE_G_CHARTER.md:87`). See §4.
- **Source of the three wins:** `reports/P05_shader_cost.md` §6.2 (`:255-270`), §6.3 (`:272-284`),
  §6.4 (`:286-299`); headline counts at `:45-54`, ledger at `:125-155`, gate table at `:339-352`.
  The 68-fetch / ~50-sin figure and the 13-fetch + 10-sin pre-discard bound are **P05 static
  counts, INFERRED** — they are not measurements and are not reproduced as measured facts here.

Label convention inherited from P05 (`:32-35`): `[O]` literal code with file:line; `[D]` arithmetic
deduction from `[O]`; `[I]` analytical cost reading, unmeasured; `[U]` needs a run/capture — UNVERIFIED.

---

## 1. Why these three, and only these three

| Win | P05 site | Static saving `[D]` | Contract status |
|---|---|---|---|
| W1 — gate foam `nautic()`/`particles()` | `water3d.gdshader:238-239` | **6 fetches + 2 `pow` + 3 `smoothstep`** skipped when the band is 0 (deep water and waterline) | output-identical; no water A/B block exists (P05 §7/:349) |
| W2 — drop redundant `fract()` in `noise()` | `water3d.gdshader:74` | **up to 66 `fract`** skipped per fragment (5×12 + 3 + 3 call sites) | `wave_noise` has `repeat_enable` (`:49`); moves *closer* to donor cite `:72` |
| W3 — gated early dry discard | between `:169` and `:170` | **12 fetches + 10 `sin`** skipped per dry fragment (worst-case bound of P05 §3.3) | safe **only** with the `waveheight <= 0.0` gate; protects the sanctioned A/B surface-Y case |

Everything P05 lists as *not safe* (§6.7/:325-335) is left untouched: mirror/warp, `textureGrad`,
inset, fragment-stage mask wrap, sentinel/P4 and `mask_to_alpha` in `terrain_tileindex.gdshader`
are not in this diff. Terrain-side hoists (P05 §6.1) and fog quad compaction (§6.5) belong to other
tickets and are excluded.

---

## 2. Ready-to-apply unified diff

Applies to the current 261-line `variant3d/shaders/water3d.gdshader` (`git status` at proposal time:
file clean, no competing edit). Net effect **+18 lines** → 279 lines; no line is deleted except the
two foam lines and the one `noise()` return line, each replaced in place. Hunk headers were checked
with `git apply --check` against an untouched copy in a temp directory (see §6).

```diff
diff --git a/variant3d/shaders/water3d.gdshader b/variant3d/shaders/water3d.gdshader
--- a/variant3d/shaders/water3d.gdshader
+++ b/variant3d/shaders/water3d.gdshader
@@ -71,7 +71,7 @@
 
 // donor noise(p) = texture2D(waveMap, p*(1./256.)).x — water.dev.frag:65-68
 float noise(vec2 p) {
-	return texture(wave_noise, fract(p * (1.0 / 256.0))).r;
+	return texture(wave_noise, p * (1.0 / 256.0)).r; // fract dropped: wave_noise repeat_enable wraps (water.dev.frag:65-68)
 }
 
 // donor height_map(): hmapMin + v.w*(hmapMax-hmapMin) — water.dev.frag:70-75.
@@ -166,8 +166,18 @@
 	// coarse swell term (:95) stays at zero — a derived donor consequence
 	// (DTRN-03 C16), not a retune to the 2D app's 1.0. A labelled A/B surface
 	// Y > 0.8333 restores it; never presented as recovered donor truth.
 	float waveheight = clamp(WATER_LEVEL * 3.0 - 1.5, 0.0, 1.0); // (:174)
+	// T-WATER-FAST (PORT APPROX, uniform-gated early dry discard): with
+	// waveheight==0 the swell term (:95) is 0 and the 9-loop f <= 0 (:104),
+	// so level <= WATER_LEVEL. A dry cell hits the existing :171 discard
+	// anyway — skip its 12-fetch water_map. The waveheight<=0.0 gate is
+	// MANDATORY: a labelled A/B surface Y > 0.8333 makes waveheight > 0,
+	// when level may exceed WATER_LEVEL and shallow water must survive.
+	// No early-Z claim is made (P05 §3.3).
+	if (waveheight <= 0.0 && height > WATER_LEVEL) {
+		discard;                                          // donor fragColor=vec4(0.0) (:176-182)
+	}
 	float level = WATER_LEVEL + 0.2 * water_map(v_height_uv * 15.0 + vec2(time * 0.1), waveheight); // (:175)
 	if (height > level) {
 		discard;                                          // donor fragColor=vec4(0.0) (:176-182)
 	}
@@ -235,8 +235,16 @@
 	// (DTRN-03 §3.3). No foam texture and no new term is introduced; shore_height
 	// (-0.1, texturemap.inc:31) is a classification literal the donor fragment
 	// never reads, so it is not used here (retained as an inert uniform below).
-	watercolor += watershade * coastfade * (1.0 - coastfade2)
-		* (vec3(0.5, 0.6, 0.7) * nautic(uv) + vec3(particles(uv)));
+	// T-WATER-FAST precedent (water_overlay.gdshader:261-269): nautic()/particles()
+	// are 6 noise taps feeding only this band-multiplied foam add. Gate them so
+	// deep water (band == 0) skips the work — output unchanged. PORT APPROX
+	// fast path, not donor parity. watershade is the literal 1.0 at :225, so
+	// the factored product is bit-identical to the original expression.
+	float foam_band = watershade * coastfade * (1.0 - coastfade2);
+	if (foam_band > 0.0) {
+		watercolor += foam_band
+			* (vec3(0.5, 0.6, 0.7) * nautic(uv) + vec3(particles(uv))); // water.dev.frag:227
+	}
 
 	rescolor = mix(rescolor, watercolor, coastfade);      // (:229)
 	// donor resalpha = coastfade2 (:230) — exact ramp: alpha 0 at the waterline,
```

### 2.1 Hunk-by-hunk derivation and flags

**Hunk 1 — W2, `noise()` `:74` (line-neutral).** `[O]` `:49` declares
`wave_noise : repeat_enable, filter_linear`; `[D]` GL_REPEAT wraps `p*(1/256)` exactly as
`fract()` does, so the fetch is unchanged and one `fract` per call disappears; the donor equation
cite at `:72` is kept *and strengthened* — the new line is literally
`texture(wave_noise, p*(1.0/256.0)).r`, matching `water.dev.frag:65-68`. Do **not** apply the same
change to `terrain_tileindex.gdshader:392` (the 2 m repeat contract, P05 §6.3/:282-283) or to
`terrain_map`'s own `fract` at `water3d.gdshader:146` (out of ticket scope). `[U]` seam equality on
this GLES3 translator with `filter_linear` needs a capture; no test reads `fract` in this shader
(`t_terrain_shore.gd:926-936` reads only `shore_prox`).

**Hunk 2 — W3, gated early dry discard (inserted after `:169`).** `[O]` `:161`
`WATER_LEVEL = water_surface_y`; `:169` `waveheight = clamp(WATER_LEVEL*3-1.5,0,1)`; `:170`
`level = WATER_LEVEL + 0.2*water_map(...)`; `:95-96` swell term is scaled by `hgt*hgt`; `:104`
`f -= amp*abs(sin(...))` with `amp>0` ⇒ `f <= 0` ⇒ `water_map <= 0` when `hgt==0`. `[D]` therefore
`level <= WATER_LEVEL`, so `height > WATER_LEVEL` implies `height > level` and the existing
`:171-173` discard would fire anyway; moving it earlier only avoids the 12-fetch `water_map`.
- **Gate is `waveheight <= 0.0`, non-negotiable.** `[O]` `:165-168` and `water3d.gd:165,179,215-218`:
  a labelled A/B surface Y > 0.8333 makes `waveheight > 0`, where `level` may exceed
  `WATER_LEVEL`; the early-out would then delete legitimate shallow water. The gate keeps the
  sanctioned A/B behaviour and the `EXPECTED_PRE_FIX_FAILURE` assertion at
  `t_terrain_shore.gd:915-924` semantically intact.
- **Why `WATER_LEVEL` and not P05's `water_level` (§6.4/:288):** the proof chain is against the
  *base of `level`*, which is `WATER_LEVEL`. Under shipped constants both are `-0.25`
  (`water3d.gd:19/:176` and `:165/:179`; test expects `-0.25` at `:876`), so the two forms are
  bit-identical today. Using `WATER_LEVEL` is strictly stronger for any A/B surface Y ≤ 0.5
  (where `waveheight` is still 0) and cannot discard a fragment that the `level` test would keep.
  Either way, cells above `water_level` already have `alpha = 0` via the water-cell guard at
  `:182`, so the visible result is unchanged. The seven added comment lines are documentation of
  the gate, not new logic.
- No early-Z claim is made: P05 §3.3/:157-166 leaves `discard`-vs-early-Z **UNVERIFIED**.

**Hunk 3 — W1, foam gate (`:238-239`).** `[O]` the add is
`watershade * coastfade * (1.0 - coastfade2) * (nautic/particles expression)`;
`watershade = 1.0` is a literal at `:225`. `[D]` `coastfade` and `coastfade2` are both clamped
to `[0,1]` (`:198-199`) and `coastfade2 <= coastfade` because `DEEP_FADE 1.07 > COAST_FADE 0.57`,
so `foam_band >= 0` always; `if (foam_band > 0.0)` skips only the exact-zero add. `[D]` factoring
with identical left-to-right association (`watershade * coastfade * (1.0-coastfade2)`) makes the
product **bit-identical**, not merely mathematically equal. The precedent is the project's own
`water_overlay.gdshader:261-269` `T-WATER-FAST`; the donor cite `water.dev.frag:227` is kept on the
surviving line. `[U]` branch divergence at the band boundary and pixel equality need a capture
(P05 §6.2/:266-269).

**Line-shift note `[D]`:** 0 (hunk 1) + 10 (hunk 2) + 8 (hunk 3: +10−2) = **+18 lines**;
the new foam block occupies new `:248-257`, old `:246` alpha becomes new `:264`, old `:260-261`
become new `:278-279`. P05's later water3d citations are prose comments (`water3d.gd:158-168`,
`t_terrain_shore.gd:923/:934`) rather than line-read assertions; the only shader-text read in the
test is `shader_text.contains("shore_prox")` (`:927-936`), which this diff never touches.

---

## 3. Preservation ledger — nothing donor-derived or test-asserted moves

No GDScript, test, config or asset file appears in the diff. All literals below remain the exact
values bound at `water3d.gd:176-210` and asserted by `t_terrain_shore.gd:866-905`:

| Donor literal / binding | Shader uniform | Bound at | Test assert | In diff? |
|---|---|---|---|---|
| water level `-0.25` (classification) | `:26` `water_level` | `water3d.gd:176` | `:876` `donor_literals_exact` | no |
| shore height `-0.1` | `:33` `shore_height` | `:180` | `:876` | no |
| max height `2.96` | `:34` `max_height` | `:181` | `:876` | no |
| COAST_FADE `0.57` | `:35` `coast_fade_depth` | `:182` | `:877` | no — reused, not changed |
| DEEP_FADE `1.07` (0.5+0.57) | `:36` `deep_fade_depth` | `:183` | `:877` | no — reused, not changed |
| tex scales `0.1` / `0.01` | `:37-38` | `:184-185` | `:878` | no |
| spec powers `170` / `120` | `:42-43` `spec_soft`/`spec_glossy` | `:187-188` | not asserted, literal intact | no — `:219-222` untouched |
| `particle_amount = 30` | `:44` | `:189` | `:899-905` `foam_not_added_by_test` | no — value untouched, call merely gated |
| shallow/deep/spec colours | `:39-41` | `:190-192` | stats | no |
| `diffusewaves0.png` (256²) binding | `:49-51` `wave_noise` | `:203-208` | `:894-897` `wave_texture_diffusewaves0` | no — same sampler, only its wrap relied upon |
| neutral `height_tex` | `:52-56` | `:210` | — | no |
| reflection off / fog off | `:60`, `:206-211`, `:251-257` | `:194-199` | — | no |
| A/B surface Y (`feature_water_surface_y`) | `:32`, `:161` `water_surface_y` | `:165`, `:179`, geometry `:215-218` | `:915-924` | no — gate preserves it |
| water-cell alpha guard / `alpha = coastfade2*water_cell` | `:182`, `:246` | — | `:643-647` `water_alpha_confined_to_cells` | no |

Also unchanged: `render_mode blend_mix, cull_disabled, unshaded` (`:21`), the 4-vertex plane
(`water3d.gd:212-237`), single-plane invariant (`t_terrain_shore.gd:766-774`), the original
`:171-173` discard, all four `water_map` normal samples `:189-192`, specular block `:213-229`,
`:241` `rescolor` mix and fog block `:251-257`.

---

## 4. Backup and apply procedure (for the future owner)

Preconditions: (a) COORD has granted exclusive ownership of `variant3d/shaders/water3d.gdshader`
after G04 finishes; (b) no runner job is in flight; (c) the file still matches the 261-line source
used for the diff (verify with `git diff -- variant3d/shaders/water3d.gdshader` — clean at proposal
time).

1. Backup first (`CHARTER.md:66`; `WAVE_G_CHARTER.md:87`). PowerShell, from the repo root:

   ```powershell
   Copy-Item -LiteralPath 'variant3d\shaders\water3d.gdshader' -Destination 'inbox\backup\water3d.gdshader.bak-P13' -ErrorAction Stop
   Get-Item -LiteralPath 'inbox\backup\water3d.gdshader.bak-P13' | Select-Object FullName,Length
   ```

   Confirm the backup exists and is non-empty **before** any edit. Existing precedent in that
   folder: `water3d.gdshader.bak-TRNWATER`, `water3d.gd.bak-TRNWATER`,
   `water3d.gd.bak-CONFIGWIREW`.
2. Save §2's `diff` block verbatim to a patch file outside the repo (e.g. under
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p13-water.patch`), then dry-run:

   ```powershell
   git apply --check 'C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p13-water.patch'
   ```

3. Apply with `git apply '<patch>'`; confirm the file is 279 lines and that a fresh
   `git diff -- variant3d/shaders/water3d.gdshader` shows only the three hunks.
4. Rollback if any gate fails:

   ```powershell
   Copy-Item -LiteralPath 'inbox\backup\water3d.gdshader.bak-P13' -Destination 'variant3d\shaders\water3d.gdshader' -Force
   ```

Do not hand-edit the shader to "fix" a hunk — restore and re-apply the exact patch.

---

## 5. Regression / gate list (run by G04 only, after ownership grant)

P13 submits **zero** jobs. The following must be green after the edit (`CHARTER.md:128-129`,
`:122-130`):

- **Static/compile:** shader compiles with no GLSL error; `assert_clean` CLEAN.
- **Variant gates:** selftest 29/29, uitest 17/17, `t_render_mode`.
- **`t_terrain_shore.gd` atom (the water contract):** `exactly_one_water_plane`,
  `water_cell_count`, `height_aware` (both stats), `donor_literals_exact`,
  `wave_texture_diffusewaves0`, `foam_not_added_by_test`, `no_port_art_shore_prox` (must stay
  absent), `no_water_cell_tile0_clamp`, `shore_ids_in_uv2_histogram`, `no_trees_no_mines`,
  `water_alpha_confined_to_cells` (**land_changed == 0**, water_changed > 0 — `:643-647`),
  `water_animation_delta` (A vs t+1 s — `:668-670`), `png_full_width_dark_rows`,
  `capture_image`, `capture_saved`, `ground_mean_luma`, `ground_max_luma`.
  `donor_coarse_swell_present` stays `EXPECTED_PRE_FIX_FAILURE` (`:915-924`) — W3's gate must
  not flip it; flipping it without the labelled A/B surface Y would violate the no-test-weakening
  rule (`CHARTER.md:59-60`).
- **Pixel equivalence:** fresh windowed 64² and real-map captures (A/B/C protocol at
  `t_terrain_shore.gd:569-671`) compared against the pre-edit frame at identical camera/time.
  Any land tint, shore-alpha shift or foam change ⇒ rollback. No donor-parity claim: donor GPU A/B
  does not exist (`CHARTER.md:57`, §3).
- **2D `app/` untouched** — none of the hunks touches `app/**`.

---

## 6. UNVERIFIED register (do not read as measured FPS)

1. **Measured FPS / frame-time impact: UNVERIFIED.** P13 ran no Godot, submitted no runner job
   and produced no capture. The 68 + 13 fetch counts and the savings in §1 are static source
   counts `[D]` with INFERRED cost readings `[I]`; any FPS number would be fabricated.
2. Pixel identity of W1/W2/W3 on this GLES3 translator — UNVERIFIED until the §5 captures.
3. `filter_linear` + `repeat_enable` wrapping equals `fract()` at negative/>1 coordinates —
   UNVERIFIED (P05 §8 #6/:371-372).
4. `discard`-vs-early-Z interaction for the full-map transparent plane — UNVERIFIED (P05 §3.3);
   W3 saves work only if those fragments are actually shaded.
5. Translator reassociation / branch divergence at the foam band boundary — UNVERIFIED; the
   W1 product is bit-identical *by association* `[D]`, but that is not a GPU measurement.
6. Effective cache-hit rate of the 256² `wave_noise` across the surviving fetches — UNVERIFIED
   (P05 §8 #4).
7. Donor parity — UNVERIFIED by construction; all three edits are labelled PORT APPROX fast
   paths, not recovered donor logic.

**Validation actually performed by P13 (not a performance claim):** the §2 patch text was checked
with `git apply --check` against an untouched copy of the shader in a temp directory (outside the
repo) and each hunk header's old/new line counts were verified against the source. 0 Godot jobs,
0 repo edits.

---

## 7. APPLIED — P13-IMPL handover (2026-11-25)

**Authority.** COORD granted P13 exclusive ownership of `variant3d/shaders/water3d.gdshader`
(P13-IMPL ticket). L04's integration plan staged W1+W2 (T1 step 1) and W3 (T2 step 6) as two
tranches separated by a capture review (`L04_perf_integration.md:223-250`); the **direct P13-IMPL
grant supersedes that staging for this handover** and ordered all three §2 hunks in one apply.
The W3 capture gate is therefore still outstanding — see §7.4. No Godot process was started and no
runner job was submitted by P13-IMPL (`WAVE_G_CHARTER.md:31`, `:67-70`).

### 7.1 Backup record (taken BEFORE the edit, hash-verified against HEAD)

| Item | Value |
|---|---|
| Backup path | `inbox/backup/water3d.gdshader.bak-P13` |
| File size | 14,388 bytes |
| Git blob SHA-1 (backup) | `e49fb434b5a6ea1cb43c47930fbc3b98c4560193` |
| Git blob SHA-1 (working file, pre-edit) | `e49fb434b5a6ea1cb43c47930fbc3b98c4560193` |
| Git blob SHA-1 (`HEAD:variant3d/shaders/water3d.gdshader`) | `e49fb434b5a6ea1cb43c47930fbc3b98c4560193` |
| Verification | backup == pre-edit working == HEAD; backup did not exist before creation; pre-edit file was clean (`git status` empty) and 261 lines |

Rollback (full-file restore only; never hand-patch a hunk to force a gate):

```powershell
Copy-Item -LiteralPath 'inbox\backup\water3d.gdshader.bak-P13' -Destination 'variant3d\shaders\water3d.gdshader' -Force
```

### 7.2 Apply record

The exact §2 diff was extracted from this report, dry-run with `git apply --check` (exit 0), then
applied with `git apply` (exit 0) from the repo root. **No other repo file was edited by P13-IMPL**;
the pre-existing modifications by other owners (Wave-B, G04 result JSONs, etc.) were left untouched.

| Item | Value |
|---|---|
| Post-edit blob SHA-1 | `8ca6d089df0d1bc368f6d3faf229abb19d8d84cb` |
| Post-edit line count | 279 (261 + 18, as predicted in §2) |
| Hunks applied | exactly 3: `noise()` `:74`; gated early discard after `:169`; foam band gate at old `:238-239` |
| `git diff --stat` | `1 file changed, 21 insertions(+), 3 deletions(-)` |

### 7.3 Exact diff as applied (`git diff -- variant3d/shaders/water3d.gdshader`)

```diff
diff --git a/variant3d/shaders/water3d.gdshader b/variant3d/shaders/water3d.gdshader
index e49fb434..8ca6d089 100644
--- a/variant3d/shaders/water3d.gdshader
+++ b/variant3d/shaders/water3d.gdshader
@@ -71,7 +71,7 @@ const mat2 M = mat2(vec2(0.72, -1.60), vec2(1.60, 0.72)); // water.dev.frag:83
 
 // donor noise(p) = texture2D(waveMap, p*(1./256.)).x — water.dev.frag:65-68
 float noise(vec2 p) {
-	return texture(wave_noise, fract(p * (1.0 / 256.0))).r;
+	return texture(wave_noise, p * (1.0 / 256.0)).r; // fract dropped: wave_noise repeat_enable wraps (water.dev.frag:65-68)
 }
 
 // donor height_map(): hmapMin + v.w*(hmapMax-hmapMin) — water.dev.frag:70-75.
@@ -167,6 +167,16 @@ void fragment() {
 	// (DTRN-03 C16), not a retune to the 2D app's 1.0. A labelled A/B surface
 	// Y > 0.8333 restores it; never presented as recovered donor truth.
 	float waveheight = clamp(WATER_LEVEL * 3.0 - 1.5, 0.0, 1.0); // (:174)
+	// T-WATER-FAST (PORT APPROX, uniform-gated early dry discard): with
+	// waveheight==0 the swell term (:95) is 0 and the 9-loop f <= 0 (:104),
+	// so level <= WATER_LEVEL. A dry cell hits the existing :171 discard
+	// anyway — skip its 12-fetch water_map. The waveheight<=0.0 gate is
+	// MANDATORY: a labelled A/B surface Y > 0.8333 makes waveheight > 0,
+	// when level may exceed WATER_LEVEL and shallow water must survive.
+	// No early-Z claim is made (P05 §3.3).
+	if (waveheight <= 0.0 && height > WATER_LEVEL) {
+		discard;                                          // donor fragColor=vec4(0.0) (:176-182)
+	}
 	float level = WATER_LEVEL + 0.2 * water_map(v_height_uv * 15.0 + vec2(time * 0.1), waveheight); // (:175)
 	if (height > level) {
 		discard;                                          // donor fragColor=vec4(0.0) (:176-182)
@@ -235,8 +245,16 @@ void fragment() {
 	// (DTRN-03 §3.3). No foam texture and no new term is introduced; shore_height
 	// (-0.1, texturemap.inc:31) is a classification literal the donor fragment
 	// never reads, so it is not used here (retained as an inert uniform below).
-	watercolor += watershade * coastfade * (1.0 - coastfade2)
-		* (vec3(0.5, 0.6, 0.7) * nautic(uv) + vec3(particles(uv)));
+	// T-WATER-FAST precedent (water_overlay.gdshader:261-269): nautic()/particles()
+	// are 6 noise taps feeding only this band-multiplied foam add. Gate them so
+	// deep water (band == 0) skips the work — output unchanged. PORT APPROX
+	// fast path, not donor parity. watershade is the literal 1.0 at :225, so
+	// the factored product is bit-identical to the original expression.
+	float foam_band = watershade * coastfade * (1.0 - coastfade2);
+	if (foam_band > 0.0) {
+		watercolor += foam_band
+			* (vec3(0.5, 0.6, 0.7) * nautic(uv) + vec3(particles(uv))); // water.dev.frag:227
+	}
 
 	rescolor = mix(rescolor, watercolor, coastfade);      // (:229)
 	// donor resalpha = coastfade2 (:230) — exact ramp: alpha 0 at the waterline,
```

### 7.4 Post-apply preservation verification (static, OBSERVED)

All checks passed against the applied file: `noise()` now uses the donor linear form with no
`fract`; `terrain_map`'s own `fract` at new `:146` is untouched; early gate is exactly
`waveheight <= 0.0 && height > WATER_LEVEL` and the original `if (height > level)` discard remains;
`foam_band` expression and positive-only guard intact; donor literals `-0.25`, `-0.1`, `2.96`,
`0.57`, `1.07`, `170`, `120`, `30` and the `diffusewaves0.png` binding in `water3d.gd` unchanged;
`water_cell` guard, `alpha = coastfade2 * water_cell`, `render_mode`, A/B surface Y line and
`water.dev.frag:227` cite all present. The token `shore_prox` occurs **once** in a pre-existing
prose comment before and after the patch (count 1 → 1), so `no_port_art_shore_prox` remains the
same `EXPECTED_PRE_FIX_FAILURE` assertion it was before this edit — no test was weakened, flipped
or edited (`t_terrain_shore.gd` blob `f8f8e9fa37c847fd625acc3903fd38995077452a`, untouched).

### 7.5 Gates STILL TO RUN — G04 only (P13-IMPL ran none)

1. Shader compiles with no GLSL error; `assert_clean` CLEAN; `SCRIPT ERROR=0`.
2. selftest **29/29**, `t_render_mode` PASS/`seam_missing=false`, and a **fresh** uitest verdict
   — note the standing staleness finding (`L04_perf_integration.md:62-70`): the on-disk
   `uitest.json` 17/17 predates both G04 jobs and is NOT fresh evidence.
3. `t_terrain_shore.gd` full atom: `exactly_one_water_plane`, `water_cell_count`, `height_aware`,
   `donor_literals_exact`, `wave_texture_diffusewaves0`, `foam_not_added_by_test`,
   `no_water_cell_tile0_clamp`, `shore_ids_in_uv2_histogram`, `no_trees_no_mines`,
   `water_alpha_confined_to_cells` (**land_changed == 0**, water_changed > 0),
   `water_animation_delta`, `png_full_width_dark_rows`, `capture_image`, `capture_saved`,
   `ground_mean_luma`, `ground_max_luma`. `donor_coarse_swell_present` must stay
   `EXPECTED_PRE_FIX_FAILURE`; `no_port_art_shore_prox` stays unchanged (§7.4). Any flip of an
   `expected_pre_fix_failure` without a landed fix is a stop condition (`L04 §5`).
4. **W3-specific capture requirement:** windowed 64² + real-map A/B/C frames at identical
   camera/time (protocol `t_terrain_shore.gd:569-671`, P09 §3-§7) reviewed before this change is
   accepted — this is the gate L04 deliberately held W3 back for (`:249-250`). Compare for land
   tint, shore-alpha shift or foam change; verify the `waveheight<=0` gate and the sanctioned
   A/B surface-Y behaviour (`>0.8333`) are not broken. Any regression ⇒ restore `.bak-P13`.
5. Full P09 `Δp50`/`Δp95` `wall_ms` protocol (`L04_perf_integration.md:80-85`) if a benefit claim
   is wanted. **Measured FPS / frame-time impact of this patch: UNVERIFIED** — P13-IMPL produced
   no capture and no run; the 6-fetch/66-fract/12-fetch savings are static INFERRED counts, not
   measurements. Donor parity stays UNVERIFIED regardless of gate results.

*End of P13 proposal + P13-IMPL applied record. No Godot job, no donor-parity claim, no measured FPS.*
