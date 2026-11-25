---
id: G06
ticket: TERRAIN-SWARM-2026-11-25 / G06 (WAVE G, read-only evaluation)
title: "Evaluate A07 colour-correction options against the current (B01+B02+B03+B04) tree"
owner: G06 (read-only)
status: DELIVERED__NO_CODE_EDIT__NO_RUNNER
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
code_files_edited: 0
godot_jobs_run: 0
reports_written: 1
---

# G06 — colour correction evaluation (current tree)

## 0. Scope, method, labels

**Mandate (as dispatched).** Read `WAVE_G_CHARTER.md`, `CHARTER.md`, A07 and A11 first;
evaluate A07's three correction options against the **current** tree and B01's
already-applied changes; recommend **ONE** minimal, reversible, labelled PORT APPROX
change with an exact diff for COORD to apply **after G04's capture**; flag which option
risks breaking the donor-constant citations. **Read-only: one report, no code edit, no
runner, no Godot.**

**Inputs opened read-only:** the four charter/analysis docs named above; `B01_shader_impl.md`,
`B02_atlas_impl.md`, `B03_diversity_impl.md`, `A10_regression_constraints.md`; the live
`variant3d/shaders/terrain_tileindex.gdshader`, `variant3d/scripts/world3d_terrain.gd`,
`variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` and the atlas PNG itself.

**Method [PORT APPROX].** Python 3.14 + Pillow 12.1.1 + numpy 2.4.3 in session temp only
(`g06_atlas_probe.py`, `g06_tint_probe.py`); no repo file written except this report. Same
sRGB→linear→`v_packed`→×1.45→sRGB replay and Rec.709/Lab conventions as A07 §2.3/§1, so the
numbers below are directly comparable to A07. Atlas full-cell means are computed from
`tile_index_atlas.png` level 0, which B02 leaves byte-identical.

**Labels.** `[O]` observed from files/pixels; `[D]` derived arithmetic; `[I]` inferred;
`[U]` UNVERIFIED (no donor GPU A/B exists — CHARTER §3). Every constant introduced here
that is not tagged `[DONOR]` with a donor path:line is **PORT APPROX**. **No donor parity
is claimed.** No G04 capture existed when this report was written (no `G*.md` in the
reports directory and no new P0 PNG in session temp), so every statement about the
post-G04 frame is a prediction `[D]/[I]`, not an observation.

---

## 1. Current-tree findings that change the A07 premise

### 1.1 A07's line numbers have drifted in `world3d_terrain.gd` [O]

A07 was written against a pre-Wave-B snapshot. The anchors it names are **not** at those
lines in the current tree:

| A07 citation | Current location | Still present? |
|---|---|---|
| `world3d_terrain.gd:698-699` ambient/diffuse bindings | **`:730-731`** | yes, unchanged text |
| `:700` specular binding | **`:732`** | yes, unchanged text |
| `:137-151` EXPOSURE/AMBIENT_ENERGY/SUN_ENERGY | **`:169-171`** (`EXPOSURE=1.45`) | yes |
| `:1114-1143` `_make_environment()` / tonemap | **`:1213-1219`** (`TONE_MAPPER_LINEAR`, `tonemap_exposure=EXPOSURE`) | yes |
| shader `:150-158`, `:294-306`, `:392`, `:427` | **unchanged** (B01 kept all anchors line-neutral) | yes |

Consequence: a COORD diff must use the **current** lines, or bind by uniform name. The
shader anchors are stable (B01 report §6: 502 lines before and after; `:235`, `:365-378`,
`:392`, `:427`, `:475`, `:476`, `:478-502` byte-identical).

### 1.2 B01's landed changes do **not** invalidate A07's hue model [O]+[D]

- Shader is still `render_mode blend_mix, unshaded, cull_disabled` (`:43`); only the
  built-in Blinn-Phong and WorldEnvironment tonemap can reach the colour.
- `:427` is byte-identical: `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;`
  Only the *value* of `a` changed: A02-P4 at `:419` now maps non-sentinel masks into
  `[0.675, 1.0]` and sentinel ids bypass to `1.0` (B01 §3 hunk 3).
- Because `a` multiplies **all three channels equally**, the mask change alters luma but
  **cannot alter B/G or b\***. The A07 albedo attribution survives.
- B02 supplies real mips to the runtime `ImageTexture` and B01 switched the hint to
  `filter_linear_mipmap` (`:60`); level-0 atlas bytes are unchanged, so full-cell albedo
  means are unchanged.
- B04 changed face promotion only; A07/P0 uses flat face mode 0 and tile id 0 in the
  captured fixture. No hue impact.

### 1.3 B03's dominant-id redirect does **not** fix — or change — the blue deficit [O]+[D]

The ticket's hypothesis ("B03 redirected dominant ids to grass9/test8/test7, which may
change albedo") is **tested and rejected**. Measured full-cell atlas albedo means and
the A07-model prediction under the current (no-tint) product:

| Cell | idx | atlas mean sRGB | byte B/G | linear B/G | predicted frame RGB | pred B/G | pred b* |
|---|---:|---|---:|---:|---|---:|---:|
| grass1 (old P0 id 0) | 0 | 76.01, 82.46, 30.39 | 0.369 | 0.155 | 89.2, 94.6, 32.7 | 0.346 | 33.70 |
| **grass9** (new) | 8 | 76.96, 79.36, 29.38 | 0.370 | 0.159 | 90.3, 91.1, 31.7 | 0.348 | 33.16 |
| **test8** (new) | 79 | 73.02, 77.90, 27.87 | 0.358 | 0.152 | 85.8, 89.5, 30.1 | 0.336 | 32.81 |
| **test7** (new) | 78 | 74.18, 78.75, 28.23 | 0.359 | 0.152 | 87.1, 90.4, 30.5 | 0.337 | 33.12 |

`v_packed = (0.958083, 0.916869, 0.780981)`, `G/R=0.95698`, `B/R=0.81515` — the same
warm 14 % blue attenuation A07 derived. My no-tint grass1 replay `(89.2,94.6,32.7)` is
within 0.8 byte of A07's `(89.92,95.43,33.04)`, confirming the pipeline.

**G06-E1 [O]+[D].** All four B03 ids are blue-deficient to essentially the same degree
(linear B/G 0.152–0.159 vs required ≈0.290). B03 changes *which* cell is sampled and
therefore the spatial field, **not** the hue. A07's rank-1 attribution stands unchanged:
atlas albedo is the cause; the donor light is only a ~14 % amplifier.

---

## 2. Option-by-option evaluation against the current tree

### Option 1 — shader albedo blue tint (A07 §4 Option 1) — **RECOMMENDED**

**What it does now.** A linear-space multiplier on RGB **before** the mask fold at `:427`.
It therefore applies identically to both `mask_to_alpha` A/B endpoints (both go through
`:392 → :427`), leaves all three samplers, `atlas_grid`, `shadow_enabled`, tile-id
decoding and face logic intact — A10 §4 classifies this as **SAFE TO CHANGE** ("changing
how a within-cell colour is computed without changing which cell is sampled").

**Predicted effect [D]** on the four dominant ids, using A07's conservative
`vec3(1.0, 1.0, 1.5)`:

| Cell | B/G before → after | b* before → after | S before → after | Y' before → after |
|---|---:|---:|---:|---:|
| grass1 | 0.346 → **0.437** | 33.7 → **29.4** | 0.654 → 0.563 | 89.0 → 89.6 |
| grass9 | 0.348 → **0.440** | 33.2 → **28.9** | 0.652 → 0.560 | 86.7 → 87.3 |
| test8 | 0.336 → **0.427** | 32.8 → **28.7** | 0.664 → 0.573 | 84.4 → 85.0 |
| test7 | 0.337 → **0.428** | 33.1 → **29.0** | 0.663 → 0.572 | 85.4 → 86.0 |

Against A07's donor bands (`B/G 0.410–0.615`, `b* 14.9–27.1`, `S 0.457–0.591`,
luma `64.7–93.6`): conservative tint lands **inside** the B/G band, inside S, inside
luma, and moves b* from ≈33 to ≈29 (still slightly above the donor top of 27, but most
of the gap closed). A07's full tint `(1.164,1.032,2.214)` would reach b* ≈25.1–25.6 but
pushes B/G to 0.522–0.536 (top edge/over) and S to 0.47–0.49 (below the donor band).

**G06-E2 [D].** The conservative 1.5× blue is the better **first** step: it is the only
arm that improves b* while keeping *every* measured channel-ratio band simultaneously.
Escalate to the full tint only if G05's G04-frame measurement still finds b* >27 and
B/G <0.53.

**Risk [I].** Blue-heavy sand/rock cells would look cold. Mitigation: keep the factor
small (1.5, not 2.2), keep it as a one-line edit that can be reverted, and measure with
the C01 tool on the real-map capture as well as P0. The A07 risk of "bluish bright cells"
scaled to grass ids only is not achievable without a per-id branch; a single global
1.5× factor is the minimal trade.

**Donor-citation impact [O]+[I].** **None on donor constants.** No `[DONOR]` literal
(`ambient_rgb`, `diffuse_rgb`, `specular_rgb`, `donor_sun_position`, light.cfg colours,
reftile.mat constants) is touched. The one nuance is a *contract-comment* sentence, not
a donor citation: the published A/B block at `:498` says "Default, albedo (:392) …
remain untouched". The tint changes the albedo **value** at `:392` while leaving the
sampling call shape intact. See §4 for a comment-only in-place wording fix.

### Option 2 — neutralise the warm light blue at `world3d_terrain.gd` (A07 Option 2) — **REJECT**

A07 proposed raising ambient blue `0.129411771893501 → 0.26530` or diffuse blue
`0.694117665290833 → 0.83891` (or the shader defaults at `:154`/`:157`). Do **not** do
this. Reasons:

1. **It is the option that breaks donor-constant citations** (see §5). Both literals are
   tagged `[DONOR]` and echoed in `DONOR_AMBIENT` (`:159`), `DONOR_DIFFUSE` (`:160`), the
   shader defaults (`:154`, `:157`), the bindings (`:730`, `:731`), the WorldEnvironment
   (`env.ambient_light_color = DONOR_AMBIENT` at `:1218`), the sun
   (`sun.light_color = DONOR_DIFFUSE` at `:1231`), and the `stats` dump (`:1736-1737`).
   Changing any of them makes at least six verbatim-donor claims false at once.
2. **Wrong scope [D].** The light term is only a 14 % amplifier; equalising `B/R` to
   `G/R` yields `B/G ≈0.36` (A07 §4 Option 2), which does **not** reach the donor band
   0.410–0.615. It cannot solve the rank-1 cause.
3. **Collateral [D]/[I].** It shifts every lighted atlas cell (rock/sand/cliff), not just
   grass, and touches the same constants the `DirectionalLight3D` rig reads.

### Option 3 — specular zero A/B (A07 Option 3) — **defer, low value**

- Current `world3d_terrain.gd:732` binds `DONOR_SPECULAR` `(0.278,0.267,0.212)`
  `[DONOR light.cfg:20-23]`; shader default at `:160-163` is `vec3(0)` with donor
  `[DONOR reftile.mat:98-102/:70-74]` — both donor-grounded, so zeroing the binding is
  *not* an invented constant, but the comment at `:1228-1229` ("Donor specular … is bound
  to the shader's `specular_rgb`") would become false.
- A07 E6 already shows the observed frame matches the **no-specular** arm within 3.8
  byte; including the bound specular over-predicts blue by ≈+22 byte. The term is
  probably inert at capture. Expected visual change ≈0 `[I]`.
- **Verdict:** worth keeping as a future isolation experiment to close A07-E6, but it
  does not move B/G or b* if inert. It must **not** be bundled into the colour fix —
  A10 §5/T5 requires one axis at a time. Defer until after G04/G05 and the tint A/B.

### Option comparison summary

| Option | Moves B/G into band? | Donor-constant citation risk | Files/anchors touched | Reversible? | Verdict |
|---|---|---|---|---|---|
| 1, conservative `(1,1,1.5)` | **yes** (0.427–0.440) | **none** (contract-comment nuance only) | shader `:392` only, line-neutral | one-line revert | **apply** |
| 1, full `(1.164,1.032,2.214)` | yes, upper edge; S too low | none | same | one-line revert | second step only |
| 2, light blue lift | no (≈0.36) | **HIGH — breaks 6+ donor literals** | shader + GDScript, line-shifting | multi-site revert | reject |
| 3, specular zero | no if inert | low (comment drift only) | `world3d_terrain.gd:732` + comment | one-line revert | defer |

---

## 3. Recommendation (ONE change) — exact diff for COORD

**Apply after G04's capture, before G05's visual review**, so G04's frame is the
untreated baseline. Change: **A07 Option 1, conservative, as a line-count-neutral,
shader-only, one-line edit** — deliberately *not* the uniform variant A07 sketched.

Why this implementation over the uniform: adding a uniform plus a GDScript binding would
shift line numbers in **two** files, invalidating the `:427`/`:475`/`:476`/A-B-block
anchors and every downstream A07/A10 citation. A one-line literal keeps the file at
**502 lines**, preserves every anchor, needs no `world3d_terrain.gd` edit, and is
reverted by restoring one line (or `git checkout --` the single file). The trade-off is
no runtime toggle; the existing P0/C4/season captures are the A/B mechanism.

### Primary hunk (behavioural, `variant3d/shaders/terrain_tileindex.gdshader`, lines 391-392)

```diff
@@ -388,8 +388,8 @@
 	void fragment() {
 		// Donor hf.pvl.smx3.frag:13 — RGB from texUnit0 at gl_TexCoord[0].xy.
 		// TRN-SHADER: `v_st` is world-ground XZ; fract(v_st*0.5) repeats one
-		// atlas cell per 2 m (donor gc_meters_to_tile=2, dmscript.global:171).
-		vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));
+		// atlas cell per 2 m (donor gc_meters_to_tile=2, dmscript.global:171); G06 PORT APPROX tint (A07 §4 Opt 1).
+		vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat)) * vec3(1.0, 1.0, 1.5); // G06 PORT APPROX; revert factor to 1.0 to disable
 		// Donor hf.pvl.smx3.frag:14 — alpha from texUnit1 at gl_TexCoord[1].xy.
 		float a;
 		int face = int(v_face + 0.5);
```

Exact old line (tab-indented) for an `edit`-tool application:

```
	vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));
```
Exact new line:
```
	vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat)) * vec3(1.0, 1.0, 1.5); // G06 PORT APPROX; revert factor to 1.0 to disable
```

And append the label to the existing `:391` comment **without dropping the donor
citation**:

```
	// atlas cell per 2 m (donor gc_meters_to_tile=2, dmscript.global:171); G06 PORT APPROX tint (A07 §4 Opt 1).
```

**Invariants preserved [O] by construction:** the `tile_rgb(v_tile, fract(v_st * uv_repeat))`
call and its argument are byte-identical inside the line; the tint is applied to RGB
before `:427`, so `mask_to_alpha` 1.0 and 0.0 remain two endpoints of the *same* compiled
program differing only by the mask factor; `:427`, `:475`, `:476` and the full
`:478-502` A/B block keep their line numbers; donor literals at `:150/:154/:157/:160`
untouched; no new uniform, sampler, branch, noise or dither field (CHARTER §3 / S-25-09).

### Optional comment-only companion (no behaviour, no line shift)

If COORD wants the published A/B contract to stay literally accurate, amend **in place**:

```diff
@@ -498,1 +498,1 @@
-// Default, albedo (:392), patch decomposition (:365-378), unshaded rationale
+// Default, albedo sampling (:392), patch decomposition (:365-378), unshaded rationale
```

This is comment-only and line-neutral. It does **not** weaken any A/B assertion; it
simply records that the *sampling* is unchanged while the albedo colour is now tinted.

### Backups / ownership

Per CHARTER §3, take `inbox/backup/terrain_tileindex.gdshader.bak-G06` **before** the
edit. The shader's exclusive Wave-B owner was B01, whose work is landed; G06 does **not**
edit it. COORD applies. No other file is in scope.

---

## 4. Donor-citation risk — explicit flag

**Option 2 is the one that risks breaking the donor-constant citations.** Concretely:

- Raising ambient blue `0.129411771893501 → 0.26530` (A07 Option 2) corrupts the
  `[DONOR light.cfg:2-7]` literal in `terrain_tileindex.gdshader:154` **and**
  `world3d_terrain.gd:159` `DONOR_AMBIENT`, its binding at `:730`, `env.ambient_light_color`
  at `:1218`, and `stats["ambient"]` at `:1736`.
- Raising diffuse blue `0.694117665290833 → 0.83891` corrupts `[DONOR light.cfg:9-14]`
  at shader `:157`, `DONOR_DIFFUSE` at `:160`, binding `:731`, `sun.light_color` at `:1231`,
  and `stats["diffuse"]` at `:1737`.
- These are precisely the literals CHARTER §3 and A10 §5 require to stay verbatim; a
  "PORT APPROX" label on a *changed donor literal* does not repair the false citation —
  the correct pattern (which Option 1 follows) is to leave the donor value untouched and
  add a separate, clearly labelled port multiplier.

Secondary, lower-risk citation drift: **Option 3** would make the `:1228-1229` comment
("Donor specular … is bound to the shader's `specular_rgb`") false, though the
`DONOR_SPECULAR` constant itself and its donor `light.cfg:20-23` tag stay correct.

**Option 1 with the diff in §3 touches no donor constant at all.** Its only textual
interaction with a protected statement is the A/B block's word "albedo (:392)" at
`:498`, handled by the optional comment-only hunk.

---

## 5. Verification plan for COORD / G05 (after G04)

1. Apply the §3 primary hunk to a backed-up shader; confirm the file is still **502
   lines** and `:427`, `:475`, `:476`, `:478-502` are byte-identical to the backup.
2. Re-run G04's P0 and real-map captures with **new unique ids**; keep G04's pre-tint
   frame as the baseline.
3. G05 / C01 tool on the new P0 frame: target `B/G` **0.41–0.53**, `b*` **25–29**,
   `S` **0.50–0.59**, luma inside **64–94** `[D, PORT APPROX target band from A07 §1]`.
   Also check the real-map capture for cold-looking sand/rock cells.
4. Confirm all gates green (CHARTER §5): selftest 29/29, uitest 17/17, `t_render_mode`,
   `t_terrain_only` and C4 luma floors `>=40` / `>=100`, `non_black_fraction >0.9`,
   `full_width_dark_rows == 0` (strict in C4/season), `dark_cols == 0`, `assert_clean`
   CLEAN. No threshold may be lowered.
5. Do **not** expect this change to move A11's `BV32 n640` or `luma std` — that is the
   separate tile-data/relief problem (A07-F2). Palette only.

**Open questions [U].** (1) G04's fresh frame may already differ from A07's 10:41 UTC P0
because B01/B02/B03/B04 are now integrated — no such frame existed at report time, so
the §3 predictions are conditional on the albedo/mask model holding. (2) Whether
A02-P4's compressed `a` on the new ids lowers luma below the model; hue is unaffected
by construction. (3) No donor GPU A/B exists; hitting the numeric bands is **not** donor
parity (CHARTER §3, A11 §9).

---

## 6. Evidence index

| ID | Class | Statement |
|---|---|---|
| G06-E1 | [O]+[D] | B03's grass9/test8/test7 albedos are as blue-deficient as grass1 (linear B/G 0.152–0.159 vs required ≈0.290): the redirect does not change the hue diagnosis. |
| G06-E2 | [D] | Conservative `(1,1,1.5)` projects B/G 0.427–0.440, b* 28.7–29.4, S 0.56–0.57, Y' 85–87 — inside every donor band except b* marginally; full tint overshoots S. |
| G06-E3 | [O] | A07's `world3d_terrain.gd` anchors drifted by +32 lines (`:698-700` → `:730-732`); shader anchors unchanged. |
| G06-E4 | [O]+[D] | B01's A02-P4 mask compression changes luma only (multiplies all channels equally) → A07's albedo attribution survives. |
| G06-E5 | [O] | Option 2 edits `[DONOR light.cfg]` literals duplicated in ≥6 places; it is the donor-citation-breaking option. |
| G06-E6 | [O] | The §3 diff is line-count-neutral and preserves the `mask_to_alpha` A/B contract semantics. |

**Handoff.** COORD owns sequencing and application. G06 made no code edit and ran no
runner job. All newly introduced constants are **PORT APPROX**; no donor parity claim.
*End of report.*
