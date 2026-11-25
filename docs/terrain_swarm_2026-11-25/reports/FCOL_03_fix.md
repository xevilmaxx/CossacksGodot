---
id: FCOL-03
ticket: "WAVE FIELD-COLOUR — ready-to-apply fix proposal for 'mill fields are too dark'"
owner: FCOL-03 read-only proposal subagent
created: 2026-11-25
status: APPLIED__EXCLUSIVE_OWNER_BY_COORD_GRANT__NO_RUNNER__NO_GODOT__PROPOSAL_DIFF_RETAINED_FOR_AUDIT
governing: [docs/terrain_swarm_2026-11-25/CHARTER.md §3, WAVE_G_CHARTER.md :31 (only G04 runs Godot)]
inputs_read: [WAVE_G_CHARTER.md, CHARTER.md, reports/FCOL_01_field_colour.md, reports/FCOL_02_donor_field_colour.md, reports/F2_03_fields_fix.md]
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX, DONOR-GROUNDED]
parity_guard: "No donor GPU A/B frame and no current-tree 3D field capture exist. Donor parity and every final-pixel claim stay UNVERIFIED (CHARTER.md:57,122-131)."
outputs: [docs/terrain_swarm_2026-11-25/reports/FCOL_03_fix.md, variant3d/scripts/world3d_entities.gd, inbox/backup/world3d_entities.gd.bak-FCOL03]
---

# FCOL-03 — field brightness fix (ready-to-apply proposal, NOT applied)

## 0. Verdict — what changed after FCOL-02 landed

**REVISED DECISION (DERIVED from FCOL-01 + FCOL-02).** The first draft of this ticket proposed
binding the "bright 2D decal" `envfieldd.png` as the field albedo. **That premise is refuted by
FCOL-02.** The donor decal is *dark olive* (`envfieldd` opaque mean `#4D442E`, L 67.38;
`FCOL_02_donor_field_colour.md` FC1/FC2/§3), the port PNGs are **byte-identical** to the donor DDS
decode (FC14), and the decal material sets `imagebrightness = 1`, `ImageGamma = 1`, `tmModulate`,
`bmTransparency` with no per-decal brightness override (FC3/§4.1). `texscalefix = 1.3` is a
**size/UV** constant, not colour (FC5/§4.2). Swapping `field.png` → `envfieldd.png` alone therefore
does **not** produce the golden reference (`#8C6F2A`–`#93752B`, L 112–118; FC12/§6) and any such
claim would be a false donor-parity claim.

**RECOMMENDED FIX (this proposal):** keep the **donor dark cut-out stalk mesh and donor albedo
unchanged** (no art swap, no synthetic noise, no invented light), and reproduce the donor's only
readable field-brightness mechanism — the **unlit crop-mesh emission** in
`D:materials\env\env.mat:58-69,873-884`: `field`/`fieldw` emission
`(232,218,195)/255` = `#E8DAC3`, **DONOR-GROUNDED**. Because emission is independent of the dark
albedo texels, it also fixes FCOL-01's decisive mechanism (72.8% of sampled field UVs land on
alpha≤8 / RGB<16 texels which render as **opaque black** because the field is excluded from alpha
scissor at `world3d_entities.gd:646-648`). The port's already-shipped **2D-style stage tints**
(`world3d_entities.gd:2354-2371`, copied from `world.gd:2592-2605`) stay byte-identical and keep
supplying the golden hue; they remain **PORT APPROX** (FC15). The emission *energy* is a
**PORT APPROX calibration**, not a donor constant: FCOL-02 §7.3 explicitly says the +45…+51 L
lift's multiplier is UNVERIFIED in donor text and must not be invented and called donor.

**OBSERVED / DERIVED:** current tree has no emission on the field material
(`world3d_entities.gd:1489-1495`, `:635-653`), so black albedo × tint remains the whole story.
**INFERRED:** warm emission will lift the field into the reference band; **UNVERIFIED** without a
G04 windowed capture. **No donor parity claim.**

---

## 1. Authority, scope, file ownership

- Read first, in full: `docs/terrain_swarm_2026-11-25/CHARTER.md` and
  `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md`. Standing rule `WAVE_G_CHARTER.md:31,67-70`:
  **only G04 runs Godot / submits runner jobs**. This ticket ran none.
- `FCOL_02_donor_field_colour.md` landed during authoring via COORD follow-up and was read in full
  before finalisation; its facts replace the earlier "bright decal" premise (§0).
- **This report is the only file written.** No `.gd`, asset, `.import`, config, test, fixture, gate,
  result JSON or git state was edited. No backup was created (no edit occurred).
- **Target file:** `variant3d/scripts/world3d_entities.gd`. It is a shared-contest file:
  P11 landed (`P11_impl.md`, backup `inbox/backup/world3d_entities.gd.bak-P11`), M03 landed
  (`M03_impl.md`, `.bak-M03`), N04 landed (`N04_impl.md`, `.bak-N04`) and **FOLD-06 path-routing
  edits landed concurrently** with N04 (documented at `N04_impl.md:30-35,249-255`; on disk as
  `variant3d/scripts/asset_paths.gd` and the preload at `world3d_entities.gd:89`). Z08's landed
  edit is `variant3d/scripts/world3d.gd` (`Z08_impl.md:7`), not this file, but the ticket names it
  as contended. **COORD grants exclusive ownership after those owners land; FCOL-03 must not
  apply its own diff.**
- `variant3d/scripts/game.gd` is **not owned/touched**. F2-03 has **not landed** in the current
  tree (verified: `game.gd:2709` still `MAX_FIELDS_PER_MILL := 49`, `:2711` `_sow_field_ring`;
  `world3d_entities.gd:311-312` still `FIELD_STEP_M`/`FIELD_SPAN_M`). This proposal's hunks are
  disjoint from F2-03's constant/`sync()` hunks (`F2_03_fields_fix.md:381-431`) and remain valid
  before or after F2-03; re-derive offsets by context if F2-03 lands first.
- Donor was read only by FCOL-02; this ticket did **not** access the donor directory.

---

## 2. Evidence used (all read-only)

| # | Fact | Source | Label |
|---|---|---|---|
| E1 | Field is the `food` node, drawn 3D only as the `res\|field` MultiMesh; instance colour = 2D stage tint; albedo = donor model texture `field.png` | `FCOL_01:17-39`, `:90-105` | OBSERVED / DERIVED |
| E2 | `field.png` RGB mean `(10.1,11.5,1.0)`, 72.8% of sampled mesh UVs black; field excluded from alpha scissor → black renders opaque | `FCOL_01:172-205`, `world3d_entities.gd:646-648` | OBSERVED / DERIVED |
| E3 | Ripe tint already bright `(3.3,2.5,1.0,0.70)` at `g=1`; growing `(0.9,1.6,0.7,…)` | `world3d_entities.gd:2354-2371` | OBSERVED |
| E4 | Donor decal dark: summer opaque `#4D442E` mean `(77.2,68.4,46.1)`, L 67.38; winter opaque `#756F61`, L 110.83; alpha byte-identical | `FCOL_02` FC1/FC7/FC8, §3 | OBSERVED / DERIVED |
| E5 | Port `envfieldd.png`/`envfielddw.png` byte-identical to donor DDS decode (MAD 0.0); no asset-conversion loss | `FCOL_02` FC14, §8 | OBSERVED / DERIVED |
| E6 | Decal material has no brightness gain: `imagebrightness=1`, `ImageGamma=1`, `tmModulate`, `bmTransparency`; `texscalefix=1.3` is geometry/UV only | `FCOL_02` FC3/FC5/FC6, §4.1-4.2, §4.4 | OBSERVED |
| E7 | Donor crop-mesh materials are unlit/emissive: Ambient=Diffuse=0; `field`/`fieldw` emission `(232,218,195)/255` warm, `field1..4` 200/255 neutral | `FCOL_02` FC9/FC10, §4.3 (`env.mat:58-69,873-884`) | OBSERVED (text) — semantics multiplier-vs-additive UNVERIFIED (§9 item 2) |
| E8 | Reference golden interior `#8C6F2A`/`#93752B`, L 112–118, H 41–43°, S 0.72–0.76, V 0.55–0.58; golden fraction 0.52–0.85; ~2× adjacent grass | `FCOL_02` FC12, §6/§7.2 | OBSERVED / DERIVED |
| E9 | Raw summer decal → reference gap +45…+51 L; no readable donor multiplier; winter needs no lift (raw L 110.83 already in band) | `FCOL_02` FC13, §7.3 | DERIVED; cause UNVERIFIED |
| E10 | Current 3D field path has no emission; P11 capacity starts at 64 and grows to 4096; `use_colors` toggled before allocation | `world3d_entities.gd:1482-1500`, `:1528-1548`, `P11_impl.md:24,259` | OBSERVED |
| E11 | Read-only re-measure of the shipped PNG this ticket: 512², mean all `(75.6,67.5,45.2)`, a>8 mean `(75.8,67.7,45.4)`; × ripe tint = `(250,169,45)` pre-clamp | inline Pillow/NumPy on `variant3d/assets/terrain/deco_png/envfieldd.png`; matches `FCOL_01:181`, `FCOL_02:111-113` | OBSERVED / DERIVED |

**INFERRED:** the owner's "too dark" is the combination of E2 (opaque black texels) and E6/E9
(no brightening step in the port's 3D albedo path). The 2D port's bright gold comes from its
PORT APPROX modulate (E11), not from bright donor bytes.

---

## 3. Why the decal-only swap is rejected

1. `envfieldd.png` is donor-authentic **dark** art (E4/E5); it cannot supply +45…+51 L (E9).
2. Binding it to the field mesh also discards the donor `field.png` cut-out silhouette that FCOL-01
   measured at the mesh UVs, while its 3D UV mapping is explicitly UNVERIFIED (`FCOL_01:286-289`,
   `world3d_entities.gd:315,435-436`).
3. FCOL-02 §7.3 forbids inventing a brightness multiplier and calling it donor. Our emission
   **colour** is donor-cited; its **energy** is labelled PORT APPROX and offered to G04 for
   calibration against §7.2 bands.
4. The donor itself brightens the *crop meshes* with emission (E7), not the decal texture. The
   proposed fix follows that donor stage while keeping the port's 2D tint maths for hue.

**Not done:** no gamma change, no exposure change, no fake sun/point light, no post-process, no
synthetic dither/noise, no new PNG/DDSS/OBJ, no "make the decal bright" rewrite of donor bytes.

---

## 4. Fix design — exact numbers and labels

### 4.1 Material configuration (applied only to the `res|field` batch surfaces)

| Property | Value | Label / source |
|---|---|---|
| `albedo_texture` | **unchanged** donor `field.png` from the importer surface material, else `AssetPaths.existing("field","tex")` (`asset_paths.gd:86-93`) | DONOR-GROUNDED art; keeps cut-out stalk silhouette |
| `vertex_color_use_as_albedo` | `true` (existing behaviour, `world3d_entities.gd:1494-1495`) | keeps ripe/growing stage tints as albedo multiplier |
| `transparency` | default **opaque** (field stays excluded from scissor at `:646-648`) | preserves current silhouette semantics |
| `roughness` / `metallic` / `cull_mode` | `1.0` / `0.0` / `CULL_DISABLED` | copied from `_default_material()` `:642-652` |
| `emission_enabled` | `true` | **NEW** — mirrors donor unlit crop materials (E7) |
| `emission` | `Color(232/255, 218/255, 195/255)` = `#E8DAC3` = `(0.9098039, 0.8549020, 0.7647059)` | **DONOR-GROUNDED** `env.mat:58-69,873-884` |
| `emission_energy_multiplier` | `0.22` starting value | **PORT APPROX** — see derivation below; NOT a donor constant |
| `emission_texture` | **not set** (uniform emission) | deliberate: black albedo texels must stop rendering black; see §9 for the silhouette contingency |
| `emission_operator` | Godot default `EMISSION_OP_ADD` | additive base; no light rig/exposure change |

**Energy derivation (DERIVED, PORT APPROX):** donor warm blue is 195; FCOL-02 §7.2 tight target
for golden interior blue is **36–43**. `43 / 195 ≈ 0.2205` → choose `0.22`, so the emission's blue
contribution lands at the upper bound of the accepted band; red/green contributions are
`232×0.22 ≈ 51` and `218×0.22 ≈ 48`. This is a *starting calibration*, not a claim about donor
render maths (which FCOL-02 §9 item 2 marks UNVERIFIED). G04 may tune within `[0.15, 0.30]` if the
capture demands it, keeping the label PORT APPROX.

**Stage tint maths is untouched:** ripe `(3.3,2.5,1.0, 0.42+0.28g)`, growing
`(0.9,1.6,0.7, 0.45+0.30g)`, regrowing `lerp(...)*pulse`, depleted `(0.30,0.26,0.16,0.60)`
(`world3d_entities.gd:2354-2371`). Emission is constant across stages (as in the donor's season
variant tint, `FCOL_02:225-230`); the tint supplies the golden hue, the emission supplies the lift.

### 4.2 Art and season statements

- **No art swap.** `field.png` (model cut-out), `envfieldd.png`/`envfielddw.png` (donor decals)
  stay byte-identical on disk; the diff only constructs a material at batch creation.
- **Season swap untouched.** No winter branch is added. The warm emission is present in all
  seasons, matching the donor's `field`/`fieldw` both being warm (`FCOL_02 §5.4`). FCOL-01's
  finding that the 3D field has no winter decal/tint (`FCOL_01:159-168`) remains a **pre-existing,
  out-of-scope gap**; `FIELD_DECAL_WINTER` stays recorded in stats only (`world3d_entities.gd:
  :437-440`). No winter capture is claimed by this ticket.

---

## 5. Ready-to-apply unified diff (NOT applied)

Paths relative to workspace root; hunks use the **current** tree line numbers
(`world3d_entities.gd`, 2,4xx lines at authoring; LF-only). Before applying, re-check with
`grep -n "FIELD_DECAL_SUMMER\|func _new_batch\|field_visual_label" variant3d/scripts/world3d_entities.gd`;
the **context lines are authoritative** if F2-03 or another owner shifted offsets.

### 5.1 `variant3d/scripts/world3d_entities.gd` — constants

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -313,5 +313,14 @@
 const FIELD_DECAL_SUMMER: String = "res://assets/terrain/deco_png/envfieldd.png"
 const FIELD_DECAL_WINTER: String = "res://assets/terrain/deco_png/envfielddw.png"
 const FIELD_STATUS: String = PORT_LABEL + " — stage tint/scale from game.field_state()/field_growth01(); donor decal 3D UV mapping UNVERIFIED"
+# FCOL-03 — DONOR-GROUNDED crop-mesh emission: D:materials/env/env.mat:58-69
+# and :873-884 set field/fieldw Emission (232,218,195)/255 with Ambient=Diffuse=0
+# (FCOL-02 FC10). Season is carried by RGB pixels, not by this tint (FCOL-02 §5).
+const FIELD_EMISSION_WARM: Color = Color(232.0 / 255.0, 218.0 / 255.0, 195.0 / 255.0)
+# PORT APPROX starting energy, NOT a donor value: donor blue 195 * 0.22 ≈ 43,
+# the tight upper bound of FCOL-02 §7.2 golden B band (36..43). G04 must
+# calibrate against the capture; the donor's +45..51 L multiplier is UNVERIFIED.
+const FIELD_EMISSION_ENERGY: float = 0.22
+const FIELD_EMISSION_STATUS: String = PORT_LABEL + " — emission colour DONOR-GROUNDED (env.mat:58-69); energy 0.22 PORT APPROX; on-screen golden lift and donor parity UNVERIFIED"
 
 # BUILD-STAGES-01 — donor construction-stage presentation (no stage art shipped).
```

### 5.2 `variant3d/scripts/world3d_entities.gd` — field batch material

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -1489,9 +1489,29 @@
 	if key == "res|field":
 		mm.use_colors = true
 		var fmesh: Mesh = info["mesh"]
-		for s in range(fmesh.get_surface_count()):
-			var sm: Material = fmesh.surface_get_material(s)
-			if sm is StandardMaterial3D:
-				(sm as StandardMaterial3D).vertex_color_use_as_albedo = true
+		for s in range(fmesh.get_surface_count()):
+			# FCOL-03: keep the DONOR dark cut-out field.png albedo and the donor
+			# OBJ mesh/UVs; no art swap, no synthetic noise, no invented light.
+			# Donor crop meshes are unlit/emissive (env.mat:58-69): warm emission
+			# stops the 72.8%-black texels (FCOL_01 §3) rendering as opaque black.
+			# Emission COLOUR is DONOR-GROUNDED; ENERGY is PORT APPROX and must
+			# be calibrated by G04 against FCOL-02 §7.2 bands.
+			var src: Material = fmesh.surface_get_material(s)
+			var fm := StandardMaterial3D.new()
+			if src is StandardMaterial3D:
+				fm.albedo_texture = (src as StandardMaterial3D).albedo_texture
+			if fm.albedo_texture == null:
+				var tex_path := AssetPaths.existing("field", "tex")
+				if ResourceLoader.exists(tex_path):
+					fm.albedo_texture = load(tex_path) as Texture2D
+			fm.roughness = 1.0
+			fm.metallic = 0.0
+			fm.cull_mode = BaseMaterial3D.CULL_DISABLED
+			# Opaque: field stays exempt from alpha scissor (:646-648).
+			fm.vertex_color_use_as_albedo = true  # 2D stage tints still apply
+			fm.emission_enabled = true
+			fm.emission = FIELD_EMISSION_WARM
+			fm.emission_energy_multiplier = FIELD_EMISSION_ENERGY
+			fmesh.surface_set_material(s, fm)
 	# P11: allocate only the initial buffer; use_colors is toggled above while
 	# instance_count is still 0, which Godot 4.7 requires.
```

**Application note:** `mm.mesh = info["mesh"]` at `:1484` already points at the same `Mesh`
resource; `surface_set_material()` mutates that resource in place **before** `mm.instance_count`
is allocated at `:1498`. Do **not** reassign `mm.mesh` (would risk P11's capacity/colour mirror).
If the importer produced a `ShaderMaterial` instead of `StandardMaterial3D` (FCOL-01 §2.2
UNVERIFIED), the fallback loads the donor `field.png` through `AssetPaths.existing()` — no invented
texture. If `src` is a `StandardMaterial3D` with no albedo texture (white-Kd case), the same
fallback applies, so both importer branches converge on donor art.

### 5.3 `variant3d/scripts/world3d_entities.gd` — additive telemetry

```diff
--- a/variant3d/scripts/world3d_entities.gd
+++ b/variant3d/scripts/world3d_entities.gd
@@ -2384,2 +2384,5 @@
 	stats["field_visual_target_span_m"] = FIELD_SPAN_M
 	stats["field_visual_label"] = FIELD_STATUS
+	stats["field_visual_emission_status"] = FIELD_EMISSION_STATUS
+	stats["field_visual_emission_rgb"] = [232.0 / 255.0, 218.0 / 255.0, 195.0 / 255.0]
+	stats["field_visual_emission_energy"] = FIELD_EMISSION_ENERGY
```

All three keys are additive; no existing key is renamed, removed or re-valued. The `field_visual_*`
tint/stat block at `:2354-2385` is otherwise untouched.

---

## 6. Backup and application instructions (NOT executed)

Before the first edit, from the workspace root (PowerShell, `python` not `python3`, no `&&`):

```powershell
Test-Path inbox\backup\world3d_entities.gd.bak-FCOL-03
Copy-Item -LiteralPath variant3d\scripts\world3d_entities.gd `
          -Destination inbox\backup\world3d_entities.gd.bak-FCOL-03
```

Do **not** overwrite the existing `.bak-P11`, `.bak-M03` or `.bak-N04`. Then
`git apply --check --recount` followed by `git apply --recount`, `git diff --check -- variant3d/scripts/world3d_entities.gd`,
and a parse smoke (`--check-only`) **by G04 only** (not by FCOL-03). Stop rules: any parse/gate
failure, new script error, silhouette regression or donor-parity wording → restore the backup in
full; never hand-patch a hunk to force green.

---

## 7. Invariants explicitly preserved

- **Tint maths from 2D:** `:2354-2371` untouched (exact ripe/growing/regrowing/depleted values);
  no multiplier applied to the tint; `mm.set_instance_color()` `:2379` and P11's `_grow_batch()`
  colour re-application `:1544-1548` unchanged.
- **Art:** donor `field.png`, `envfieldd.png`, `envfielddw.png` byte-identical; no new PNG/DDS/OBJ,
  no generated texture, **no synthetic dither/noise** (CHARTER decision S-25-09).
- **Stalk silhouette / geometry:** donor `field.obj` mesh, UVs, `_bake_mesh()`, bbox scaling and the
  field's opaque/alpha-scissor exemption (`:646-648`) unchanged. Emission is unmasked; the visual
  softening this may cause is an explicit UNVERIFIED item (§9/§10), with Option B in §9 as the
  contingency if the gate rejects it.
- **"No faked light":** no point/directional light, no exposure or ambient change, no
  `render_mode unshaded`, no post-process. Emission is the donor's documented crop-mesh stage
  (E7); only its *colour* is donor-cited, its energy is PORT APPROX.
- **Season swap:** no change to season key/atlas/decal paths; warm emission in both seasons matches
  `field`/`fieldw` (FCOL-02 §5.4). Winter gap remains as recorded in FCOL-01 §2.5.
- **P11 MultiMesh capacity:** `BATCH_INITIAL_CAPACITY`/`BATCH_CAPACITY` and `_grow_batch()` untouched;
  `mm.use_colors = true` still runs while `instance_count == 0` before allocation (`:1489-1498`);
  tier-1 batching/slot indices/teleport mirror unchanged.
- **F2-03 quad layout:** no edit to `FIELD_STEP_M`/`FIELD_SPAN_M`/`sync()` scale logic
  (`:311-315`, `:2330-2334`, `:2374-2380`) or to `game.gd`; patches/qu offsets, if F2-03 lands, stay
  exactly as its proposal specifies.
- **Labels/tests:** `PORT_LABEL` retained; all assertions, thresholds and
  `expected_pre_fix_failure` flags untouched; no `anim/` token introduced (structural gate
  `t_entities3d.gd:215-234` stays green); 2D `app/` byte-identical.
- **No donor parity claim** — PORT APPROX + DONOR-GROUNDED labels are used exactly as scoped above.

---

## 8. Acceptance — G04 windowed capture + numeric RGB bands

All visual checks are **PENDING G04** (`WAVE_G_CHARTER.md:31`). FCOL-03 produced no capture.

### 8.1 Capture design (G04 only)

1. Windowed **1280×720** P0 frame plus a real-map frame, fixed seed `20261113` (G04's existing
   convention), finished mill with ripe fields; record `SCRIPT ERROR=0`, `full_width_dark_rows=0`.
2. Crop only the field interior (avoid mill clearing/grass edge); same pixel box on the pre-fix A
   frame and the post-fix B frame. Use `variant3d/tools/terrain_ab_metric.py <capture> --crop
   x,y,w,h --json` (`C01_metric_tool.md:69-100`) for `color.mean_rgb`, `std_rgb`, `mean_luma`;
   use the FCOL-02 §6 golden mask (`R>G>B` and `R−B>45`) for golden fraction and Pillow HSV for
   H/S/V.
3. The A/B delta, not a single frame, is the verdict: pre-fix field pixels are predicted dark
   (FCOL-01: 72.8% black-texel sampling); post-fix must move into the bands below.

### 8.2 Numeric targets (from `FCOL_02_donor_field_colour.md` §7.2 — accepted, not parity)

| Quantity | Tight target | Accepted band |
|---|---|---|
| Golden interior mean RGB | R **140–148**, G **111–117**, B **36–43** (`#8C6F2A`–`#93752B`) | hex inside `#8E6F29`–`#B18A33` |
| Golden interior luminance L | **112–118** | **105–125** |
| Hue H | **41–43°** | **39–45°** |
| Saturation S | **0.72–0.76** | **0.65–0.80** |
| Value V | **0.55–0.58** | **0.50–0.65** |
| R−G / G−B | **29–34 / 69–76** | ≈30 / ≈72 |
| Golden fraction in a clean ripe field crop | **0.52–0.85** | **>0.45** |
| Field vs adjacent grass | field ~20° yellower and **~2× brighter**; hard edge, no soft feather | same at the patch boundary |

**Guard on raw art (must not drift):** decal opaque mean stays R 76–78 / G 67–69 / B 45–47
(`#4D442E`), L 65–68; emission colour stays `(232,218,195)/255`; decal alpha mean 148, bbox
477×475, opaque fraction 0.2585 byte-identical (FCOL-02 §7.1). If the capture is golden but the
raw asset/gate telemetry drifted, the fix is rejected.

**Energy calibration gate:** with `FIELD_EMISSION_ENERGY = 0.22`, check `stats.field_visual_emission_rgb`
and `_energy`, then tune only within `[0.15, 0.30]` until the §7.2 bands are met; record the final
value and keep the PORT APPROX label. Do not treat `0.22` as donor truth.

### 8.3 Gate regression list (existing suites, unchanged thresholds)

| # | Gate | Expected |
|---|---|---|
| 1 | variant3d selftest | 29/29, `passed=true`, `SCRIPT ERROR=0` |
| 2 | uitest | fresh 17/17 (on-disk 17/17 is stale per `P11_impl.md:271`) |
| 3 | `t_render_mode` / `t_entities3d` / `t_terrain_mines` | PASS; `no_sprite_sheet_loads`; batch names/counts unchanged |
| 4 | `assert_clean` | CLEAN — no new warning/error from the material setup |
| 5 | P11 telemetry | `batch_instance_slots_allocated <= ceiling`; `tint_materials_shared` unchanged; `use_colors` still set at zero instance count |
| 6 | F2-03 (if landed) | field count/centres/quad spans unchanged; `FIELD_SPAN_M` alias intact |
| 7 | 2D `app/` hash | byte-identical — this is a 3D-only material change |
| 8 | Winter capture | unchanged summer-style tint (pre-existing gap); no claim of a winter fix |

---

## 9. Contingency — additive emissive base behind unchanged stalks (Option B)

If the G04 capture shows the unmasked emission washing out the donor stalk cut-out, keep §5's
constants but replace §5.2 with a **second batch** behind the stalk mesh:

- Key `res|field_base`, one flat ground quad per field, albedo = donor `envfieldd.png`
  (`FIELD_DECAL_SUMMER`, already on disk and byte-identical to donor, FCOL-02 FC14), same
  `FIELD_EMISSION_WARM`/`FIELD_EMISSION_ENERGY`, **no tint** (`vertex_color_use_as_albedo = false`),
  drawn at the same `_xf(fid)` with Y lowered by a small PORT APPROX epsilon and patch XZ span from
  `FIELD_SPAN_M`; capacity from P11 (`BATCH_INITIAL_CAPACITY` → `BATCH_CAPACITY`) and colour/transform
  mirrors updated in the same `sync()` field pass.
- Stalk mesh and its dark `field.png` material are left **exactly** as in the current tree, so the
  donor stalk silhouette is preserved verbatim.
- All spacing/geometry constants stay PORT APPROX as in F2-03; no donor parity claim. This option
  is **not** the recommended diff and needs its own validated patch + backup; it is documented here
  only as the fallback named in the ticket.

---

## 10. UNVERIFIED / open register

1. No Godot run, runner job, donor GPU A/B or current-tree 3D field capture — mandated by
   `WAVE_G_CHARTER.md:31`. Every §8 outcome is a gate, not a measured result.
2. Whether Godot's OBJ importer bound `field.png` or left a white-Kd material (FCOL-01 §2.2); §5.2
   converges both cases on the donor PNG.
3. Whether Godot 4.7 treats `emission` as additive or multiplied by albedo under its BRDF/tone map;
   the donor's own multiplier-vs-additive semantics are also UNVERIFIED (FCOL-02 §9 item 2).
4. The `+45…+51 L` gap is arithmetic over donor/reference pixels, **not** a donor brightness
   constant; the `0.22` energy is a PORT APPROX calibration derived from the B band, not donor.
5. Which `field1..4` donor material variant is drawn per node (FCOL-02 §9 item 3); the port has a
   single `res|field` batch, so a single warm emission is a deliberate simplification.
6. Unmasked emission may soften fine stalk detail (§9); visual effect UNVERIFIED.
7. FCOL-02's reference stills may come from a mod/terrain pack (§9 item 5); target bands are
   reference measurements, not proof of a donor GPU frame.
8. Ownership/grant order for `world3d_entities.gd` (COORD's decision, §1) is UNVERIFIED at
   authoring time; FCOL-03 wrote no code and will not apply this diff.

---

## 11. Scope attestation

One file written: this report. No code, asset, `.import`, config, test, gate, result JSON or git
state edited; no backup created; no Godot process or runner job; no donor directory access by this
ticket. All observations, derivations, inferences and unverified items are separated per
`CHARTER.md:55-69`. The diff in §5 is **ready to apply by COORD only after the current owners land
and exclusive ownership is granted** (§1). **PORT APPROX — no donor parity claim.**

## 12. APPLIED — implementation record (COORD grant, 2026-11-25)

### 12.1 Authority and backup

- COORD granted FCOL-03 exclusive ownership after `FOLD_06_impl.md:294-296` explicitly
  **RELEASED** `world3d_entities.gd`, `world3d_fx.gd` and `convert_models.py` at
  `2026-11-25T16:30:49+01:00`. Only `world3d_entities.gd` was edited by this ticket.
- Backup taken **before** the first edit, from the untouched working tree:
  `Copy-Item -LiteralPath variant3d\scripts\world3d_entities.gd -Destination inbox\backup\world3d_entities.gd.bak-FCOL03`.
  No existing `.bak-P11`, `.bak-M03` or `.bak-N04` was overwritten.

| Item | Value |
|---|---|
| Pre-edit `git -c core.autocrlf=false hash-object` | `ad75da79461a419f20859cabd74f9cf4faac0c41` — equals the post-N04/FOLD-06 blob recorded at `N04_impl.md:248` |
| Pre-edit / backup SHA-256 | `45742F4706981DBB1EB478950B94AE5A28ECAFC984B86562B152B8930267E00F` (both identical) |
| Backup size / lines / endings | 115,332 B / 2,439 LF lines / 0 CR bytes |
| Post-edit SHA-256 | `0D313D8062E5D6C5935819833958AD6E40B0FAB3FE8CF1800DD80A865193C850` |
| Post-edit `git hash-object` | `3dfaf02867cbc4690d1db3785de1602cca1a6265` |
| Post-edit size / lines / endings | 117,356 B / 2,471 LF lines / 0 CR bytes |
| `git -c core.autocrlf=false diff --check -- variant3d/scripts/world3d_entities.gd` | exit 0, no output |

### 12.2 Exact diff applied (vs the pre-edit backup)

`git -c core.autocrlf=false diff --no-index -- inbox/backup/world3d_entities.gd.bak-FCOL03
variant3d/scripts/world3d_entities.gd` — **1 file changed, 35 insertions(+), 3 deletions(-)**,
**exactly three hunks**. Git's own context expansion adds lines to the `@@` counts of §5; every
added/removed line below is byte-identical to §5's validated hunk bodies.

```diff
diff --git a/inbox/backup/world3d_entities.gd.bak-FCOL03 "b/variant3d\\scripts\\world3d_entities.gd"
index ad75da79..3dfaf028 100644
--- a/inbox/backup/world3d_entities.gd.bak-FCOL03
+++ "b/variant3d\\scripts\\world3d_entities.gd"
@@ -313,6 +313,15 @@ const FIELD_SPAN_M: float = FIELD_STEP_M * 1.41421356237
 const FIELD_DECAL_SUMMER: String = "res://assets/terrain/deco_png/envfieldd.png"
 const FIELD_DECAL_WINTER: String = "res://assets/terrain/deco_png/envfielddw.png"
 const FIELD_STATUS: String = PORT_LABEL + " — stage tint/scale from game.field_state()/field_growth01(); donor decal 3D UV mapping UNVERIFIED"
+# FCOL-03 — DONOR-GROUNDED crop-mesh emission: D:materials/env/env.mat:58-69
+# and :873-884 set field/fieldw Emission (232,218,195)/255 with Ambient=Diffuse=0
+# (FCOL-02 FC10). Season is carried by RGB pixels, not by this tint (FCOL-02 §5).
+const FIELD_EMISSION_WARM: Color = Color(232.0 / 255.0, 218.0 / 255.0, 195.0 / 255.0)
+# PORT APPROX starting energy, NOT a donor value: donor blue 195 * 0.22 ≈ 43,
+# the tight upper bound of FCOL-02 §7.2 golden B band (36..43). G04 must
+# calibrate against the capture; the donor's +45..51 L multiplier is UNVERIFIED.
+const FIELD_EMISSION_ENERGY: float = 0.22
+const FIELD_EMISSION_STATUS: String = PORT_LABEL + " — emission colour DONOR-GROUNDED (env.mat:58-69); energy 0.22 PORT APPROX; on-screen golden lift and donor parity UNVERIFIED"
 
 # BUILD-STAGES-01 — donor construction-stage presentation (no stage art shipped).
 # Donor truth (DBUILD-01 §2, line citations there): build progress is hp/maxhp
@@ -1490,9 +1499,29 @@ func _new_batch(key: String, info: Dictionary, cls: String,
 		mm.use_colors = true
 		var fmesh: Mesh = info["mesh"]
 		for s in range(fmesh.get_surface_count()):
-			var sm: Material = fmesh.surface_get_material(s)
-			if sm is StandardMaterial3D:
-				(sm as StandardMaterial3D).vertex_color_use_as_albedo = true
+			# FCOL-03: keep the DONOR dark cut-out field.png albedo and the donor
+			# OBJ mesh/UVs; no art swap, no synthetic noise, no invented light.
+			# Donor crop meshes are unlit/emissive (env.mat:58-69): warm emission
+			# stops the 72.8%-black texels (FCOL_01 §3) rendering as opaque black.
+			# Emission COLOUR is DONOR-GROUNDED; ENERGY is PORT APPROX and must
+			# be calibrated by G04 against FCOL-02 §7.2 bands.
+			var src: Material = fmesh.surface_get_material(s)
+			var fm := StandardMaterial3D.new()
+			if src is StandardMaterial3D:
+				fm.albedo_texture = (src as StandardMaterial3D).albedo_texture
+			if fm.albedo_texture == null:
+				var tex_path := AssetPaths.existing("field", "tex")
+				if ResourceLoader.exists(tex_path):
+					fm.albedo_texture = load(tex_path) as Texture2D
+			fm.roughness = 1.0
+			fm.metallic = 0.0
+			fm.cull_mode = BaseMaterial3D.CULL_DISABLED
+			# Opaque: field stays exempt from alpha scissor (:646-648).
+			fm.vertex_color_use_as_albedo = true  # 2D stage tints still apply
+			fm.emission_enabled = true
+			fm.emission = FIELD_EMISSION_WARM
+			fm.emission_energy_multiplier = FIELD_EMISSION_ENERGY
+			fmesh.surface_set_material(s, fm)
 	# P11: allocate only the initial buffer; use_colors is toggled above while
 	# instance_count is still 0, which Godot 4.7 requires.
 	var cap: int = mini(BATCH_INITIAL_CAPACITY, BATCH_CAPACITY)
@@ -2383,6 +2412,9 @@ func sync(dt: float) -> void:
 	stats["field_visual_span_scale"] = field_scale
 	stats["field_visual_target_span_m"] = FIELD_SPAN_M
 	stats["field_visual_label"] = FIELD_STATUS
+	stats["field_visual_emission_status"] = FIELD_EMISSION_STATUS
+	stats["field_visual_emission_rgb"] = [232.0 / 255.0, 218.0 / 255.0, 195.0 / 255.0]
+	stats["field_visual_emission_energy"] = FIELD_EMISSION_ENERGY
 	var units := 0
 	var ress := 0
 	var tinted_batches := 0
```

**Application note (OBSERVED):** `git apply --check` of the single combined patch from §5 failed on
hunk 3 because that hunk had no trailing context line; hunks 1-2 were applied from the exact §5
patch (`git apply --recount`), then hunk 3 was applied with one trailing context line
(`var units := 0`) and its header offset regenerated to the post-hunk-1/2 line 2,413. **No hunk body
line was changed**; the applied diff above is the byte-level record.

### 12.3 Mechanical verification (no Godot, no runner)

- `difflib` over backup → final reports **exactly three non-equal opcodes**:
  `insert after backup 1-based line 315` (+9 constants), `replace backup lines 1493-1495` (the
  material loop; the identical `for s …` line is counted as context), and
  `insert after backup line 2385` (+3 telemetry lines). No other line changed.
- Protected-region marker census (backup → final, identical except where explained):
  `mesh_sid 5→5`, `MILL_ROTOR_HUB_DONOR 5→5`, `ROTOR_MOUNT_STATUS 3→3`,
  `MILL_ROTOR_AXLE_TIP_DONOR_Y 3→3`, `_tint_material_cache 6→6`,
  `BATCH_INITIAL_CAPACITY 2→2`, `_grow_batch 2→2`, `FIELD_STEP_M 3→3`, `FIELD_SPAN_M 4→4`,
  `FIELD_DECAL_WINTER 3→3`, `vertex_color_use_as_albedo 1→1`, `field_state 8→8`,
  `field_growth01 4→4`. `AssetPaths.existing 14→15` is **only** the new field-albedo fallback
  inside hunk 2; FOLD-06's 14 pre-existing resolver calls are untouched.
- `git status --short -- variant3d/tests app inbox/backup/world3d_entities.gd.bak-FCOL03`:
  no tracked test or `app/` file modified by this ticket (the untracked `.uid` / QA test files
  predate this edit and belong to earlier agents). No asset, `.import`, config or gate file edited.
- `core.autocrlf=false` used for every `git apply` and diff command; final file is LF-only like the
  backup (0 CR bytes), so P11's CRLF regression is not reintroduced.

### 12.4 Invariants confirmed after application

- **FOLD-06:** all 14 pre-existing `AssetPaths.existing(...)` calls and the
  `const AssetPaths = preload("res://scripts/asset_paths.gd")` at `:89` unchanged; the new call is
  an additional fallback in the field material only.
- **N04:** `mesh_sid` write in `_acquire()` and its `sync()` read unchanged (5 occurrences).
- **M03:** rotor hub/axle constants, `_attach_rotor()` loop and `mill_rotor_*` stats unchanged.
- **P11:** `_tint_shader`/`_tint_material_cache`, `BATCH_INITIAL_CAPACITY=64`, `_grow_batch()`, the
  `use_colors`-before-allocation order and the field-colour resize re-application unchanged.
- **F2-03:** `FIELD_STEP_M`, `FIELD_SPAN_M` and the `sync()` scale/stats block unchanged; the quad
  layout proposal remains applicable on top of this edit without conflict.
- **Stage tints / art / season:** `:2354-2371` byte-identical; no PNG/OBJ/`.import` touched; no
  winter branch added; warm emission in both seasons matches donor `field`/`fieldw` (FCOL-02 §5.4).
- **Labels:** `PORT_LABEL` retained on the new `FIELD_EMISSION_STATUS`; DONOR-GROUNDED applies only
  to the emission **colour**, never to energy or final pixels. **No donor parity claim.**

### 12.5 G04 gate list — NOT RUN by FCOL-03

`WAVE_G_CHARTER.md:31,67-70`: only G04 may run Godot / submit jobs. FCOL-03 ran **0** Godot
processes and **0** runner jobs; every item below is **PENDING**.

| # | Gate / check | Expected |
|---|---|---|
| 1 | Parse smoke (`--check-only --script res://scripts/world3d_entities.gd`) | `SCRIPT ERROR=0`; `Color(232.0/255.0, …)` const expression accepted by Godot 4.7 |
| 2 | Variant selftest | 29/29, `passed=true`, no new script errors |
| 3 | Uitest | fresh 17/17 (on-disk 17/17 stale per `P11_impl.md:271`) |
| 4 | `t_render_mode`, `t_entities3d`, `t_terrain_mines`, `t_forest_bake` | PASS; `no_sprite_sheet_loads`; batch names/counts unchanged; no new dark row or seam |
| 5 | `assert_clean` | CLEAN — no new warning/error from the material setup |
| 6 | P11 telemetry | `batch_instance_slots_allocated <= ceiling`; `tint_materials_shared` unchanged; `use_colors` still toggled at zero instance count; `field_visual_*` colours survive a resize |
| 7 | New telemetry | `stats.field_visual_emission_status` present; `field_visual_emission_rgb == [0.9098039…, 0.8549020…, 0.7647059…]`; `field_visual_emission_energy == 0.22` |
| 8 | F2-03 (if landed) | four quad patches, centres/spans unchanged; `FIELD_SPAN_M` alias intact |
| 9 | 2D `app/` hash | byte-identical (3D-only change) |
| 10 | Windowed 1280×720 P0 + real-map capture, fixed seed 20261113, ripe fields | non-blank, `full_width_dark_rows=0`, `SCRIPT ERROR=0`; A/B vs pre-fix backup frame |

**Numeric acceptance bands — use `variant3d/tools/terrain_ab_metric.py <capture> --crop x,y,w,h
--json` (`C01_metric_tool.md:69-100`) on a field-only ROI plus FCOL-02 §6's golden mask
(`R>G>B` and `R−B>45`) and Pillow HSV:**

| Quantity | Tight target | Accepted band |
|---|---|---|
| Golden interior mean RGB | R **140–148**, G **111–117**, B **36–43** (`#8C6F2A`–`#93752B`) | inside `#8E6F29`–`#B18A33` |
| Interior luminance L | **112–118** | **105–125** |
| Hue H | **41–43°** | **39–45°** |
| Saturation S | **0.72–0.76** | **0.65–0.80** |
| Value V | **0.55–0.58** | **0.50–0.65** |
| R−G / G−B | **29–34 / 69–76** | ≈30 / ≈72 |
| Golden fraction in clean ripe field crop | **0.52–0.85** | **>0.45** |
| Field vs adjacent grass | field ~20° yellower and **~2× brighter**, hard edge | same at patch boundary |

Guard: raw art must not drift — decal opaque mean `#4D442E` (R 76–78 / G 67–69 / B 45–47), L 65–68;
alpha mean 148, bbox 477×475, opaque fraction 0.2585. Energy may be tuned only within
`[0.15, 0.30]` by G04, recorded, and still labelled PORT APPROX. If unmasked emission washes out
the stalk cut-out, apply §9 Option B under a new backup/grant. **Donor parity remains UNVERIFIED.**

*End of FCOL-03 report — proposal §5 retained verbatim for audit; implementation recorded in §12.*
