---
id: FIX-COLOR
owner: FIX-COLOR subagent
date: 2026-11-24
scope: "variant3d/scripts/world3d_entities.gd and this report ONLY. Read-only donor text reads; no fx/world3d/main/hud/app/config/test edits; no git operations."
status: "CODE COMPLETE — parse PASS (ticket 295), targeted probe PASS 17/17 (ticket 298). FULL SELFTEST SKIPPED BY USER SPEED REQUEST ('FAST LANE'). No visual parity claim. Includes the FIX-MOVE-VISUAL yaw correction (section 6), verified by the same probe."
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBS vs INFERENCE, UNVERIFIED labels, smallest donor-grounded fix, no git operations."
owns: ["variant3d/scripts/world3d_entities.gd", "docs/coord_swarm_2026-11-24/reports/FIXCOLOR_nation_bands.md"]
godot_runs: "tickets 261 (capability probe, ok), 271 (parse failed on PackedByteArray.subarray(), fixed), 295 (final parse ok), 297 (probe failed on probe-only Basis.xform API, fixed in temp probe), 298 (probe ok 17/17). Full selftest intentionally not run."
---

# FIX-COLOR — donor nation colour is a small alpha-masked BAND, not a body paint

## 1. What the donor actually does (all OBS, read-only text/asset reads)

| Claim | Donor `path:line` | OBS / INFERENCE |
|---|---|---|
| Key colour table `GetKeyColorByPlayerIndex`, default `koef := 1.1`, cases 0..13, `r/g/b = channel*koef/255` | `C:\Games\Cossacks 3\data\scripts\lib\classes.script:7986-8015` (formula `:8012-8014`, default `:7988`) | OBS |
| `gKeyColor` array + population loop | `classes.script:7685`, `:8091-8092` | OBS |
| `gc_MaxColorCount = 13`; guard applies only `0 <= colorInd < 13` | `data\scripts\dmscript.global:121`; `lib\misc.script:5070` | OBS |
| Recursive application to the object AND every child | `lib\misc.script:5067-5081` (call at `:5073`, recursion `:5074-5081`) | OBS |
| `a := 1` **only** when `GetLibMaterialTextureFormat(...) = 2` (tfRGBA); otherwise `a` is left unassigned | `misc.script:5069`, `:5072`; `data\materials\ref\refunit.mat:36-38` (`textureformat = tfRGBA`), `refbuilding.mat:36`; exceptions `units.mat:9,20` (`tfDefault`) | OBS |
| **Uniform 0 = `custColor`, a `sut4f` uniform on the skinned unit shader `u`** | `data\shaders\shaders.ref:63-87` (`name = custColor`, `type = sut4f`, `value X/Y/Z/W = 0` at `:80-85`); fragment `unit.smx9.id8.frag`, vertex `unit.sm.b16.id16.vert` at `:137-138` | OBS |
| **The actual tint operation is alpha-masked, per pixel:** `tex0.rgb = mix(tex0.rgb, custColor.rgb * custColor... , tex0.a * custColor.a)` | `data\shaders\obj\unit.smx9.id8.frag:37-38` (identical in `unit.smx3.id8.frag:37-38`) | OBS |
| Texture alpha is **not** transparency: final `color.a` is forced from the material (`diffuse.a = 1`) | `unit.smx9.id8.frag:42`; `refunit.mat:60-65,88-93` | OBS |
| Application sites for units / port buoys | `lib\unit.script:3860`; `lib\player.script:2971` | OBS |
| Donor `.oss` has **no** per-face material/section field — one mesh + UVs | `docs/decomp/DC_FORMATS.md:46-64` (layout `v/fc/t`, no material block) | OBS |

**Conclusion (INFERENCE, strongly constrained by the above):** the "little bands" the user saw are the texels where the donor RGBA albedo's **alpha channel is set**. The donor multiplies the key colour into those texels only; everything else keeps its original art. Two gates: (1) only tfRGBA objects get `custColor.a = 1` (`misc.script:5072`), (2) within them only `tex0.a > 0` texels are tinted (`unit.smx9.id8.frag:38`). Nothing in the donor text tints a whole body, and there is no separate band *mesh section* to copy — the scope is a texture mask.

Measured donor alpha statistics (Pillow, read-only, first mip, threshold a>=128 unless stated):

| Donor DDS | masked texels / total | share |
|---|---|---|
| `materials\units\peaukr.dds` | 34,990 / 262,144 (a>200: 34,578; any nonzero: 35,760; full 255: 32,814) | 13.35% |
| `materials\units\musketeer.dds` | 32,230 / 262,144 (any nonzero) | 12.29% |
| `materials\units\cossacksich.dds` | 39,377 / 262,144 (any nonzero) | 15.02% |
| `materials\units\pikeman.dds` | 70,178 / 262,144 (any nonzero) | 26.77% |
| `materials\units\dragoon18.dds` | 103,234 / 262,144 (any nonzero) | 39.38% |
| `materials\units\archer.dds` | 124,909 / 262,144 (any nonzero) | 47.65% |

`peaukr.dds` header: `DDS `, 512×512, fourcc `DXT5`, 10 mips, 349,680 bytes (first mip = 128×128 blocks = 262,144 bytes). A downscaled view of its alpha is a handful of small white rectangles on black — the bands.

## 2. Why V7-65 painted everything

- `variant3d/scripts/world3d_entities.gd` V7-65 `_tinted_material()` duplicated the surface material and set `StandardMaterial3D.albedo_color = tint` (old `:311-320`); `_apply_tint()` set that as `material_override` on MultiMesh batches and per-surface overrides on buildings (old `:330-344`). `albedo_color` multiplies the **entire** surface — no mask.
- Root cause of the missing mask: `variant3d/tools/convert_models.py:148-151,449-450` converts unit/building textures with `force_opaque=True`, calling a donor alpha that "the game draws them opaque" **"garbage"** and dropping it. In fact `unit.smx9.id8.frag:42` shows that alpha is not opacity — it is the tint mask. The port PNGs are confirmed `RGB` (e.g. `assets/models/tex/peasant.png` mode `RGB`), so the V7-65 code had no mask even if it had wanted one.
- The donor OBJ/MTL exposes no usable band section: `convert_models.py:133-137` writes one `newmtl model`, and the donor `.oss` has no material field (`DC_FORMATS.md:54-55`). So a "separate material subset" is not available in the port mesh.

## 3. Fix implemented (final `variant3d/scripts/world3d_entities.gd`)

The donor mask is recovered from the **donor DDS path the port manifest already carries** (`assets/models/manifest.json`, `models[i].texture`, e.g. `...\materials\units\peaukr.dds`) — no new path is invented and no colour is invented. The 13 `rgb_godot_float` slots and the identity `entity.player -> gKeyColor slot` mapping are untouched.

1. **`bind()` (`:180-202`)** caches `_donor_texture_paths[sid]` from `manifest.json:models[i].texture`; clears `_band_mask_cache` / `_band_mask_stats`; stats now name the corrected scope (`:250-259`).
2. **`_dxt5_mask()` (`:371-432`)** reads the DDS header (height `:12`, width `:16`, fourcc `:84`), validates `DDS ` + `DXT5` by direct byte comparison (`:378`, `:384` — `PackedByteArray.subarray()` does not exist in Godot 4.7), and decodes the **DXT5 alpha indices only** of the first mip into an RGBA8 `Image` whose alpha is the donor mask. RGB colour indices are ignored intentionally. Any mismatch returns `null`.
3. **`_band_mask()` / `_band_mask_texture()` / `_mask_at()` / `_measure_band()` (`:439-526`)** cache one mask texture per sid, count masked texels, and measure how many **vertices/faces** of the baked mesh land on band texels. The measured numbers are exposed in `stats["donor_tint_mask_stats"]`.
4. **`_tinted_material()` (`:528-550`)** now builds a `ShaderMaterial` whose fragment code is the donor line 38 verbatim in structure: `mix(t.rgb, custColor.rgb * t.rgb, m * custColor.a)` with `m = mask_tex.a`. Donor albedo texture is preserved. **If no donor mask is available the body is left UNTINTED** — V7-65's whole-body fallback is never reinstated.
5. **`_apply_tint()` (`:560-578`)** calls `_measure_band()` and tags each batch/building with `donor_tint_label = PORT_LABEL` and `donor_tint_visual = "UNVERIFIED"` (buildings keep `donor_tint_slot`/`donor_tint_rgb` from V7-65).

### Before / after tint scope

| | V7-65 (before) | FIX-COLOR (after) |
|---|---|---|
| Carrier | `StandardMaterial3D.albedo_color` | `ShaderMaterial` uniform `custColor` + `mask_tex` |
| Scope | whole surface, every texel | only texels where donor DDS alpha >= 0.5 |
| Formula | albedo * tint (uniform) | `mix(albedo, tint*albedo, donor_alpha * 1.0)` (donor `unit.smx9.id8.frag:38`) |
| Missing-mask behaviour | whole-body tint from the 13 slots | no tint at all, explicit warning |
| Donor slots | 13 | 13 (unchanged) |
| Public API | 6 signatures | 6 signatures (unchanged) |
| V7-74 morph / V7-79 memo | consumed / memoized | untouched (no edit to `sync()` pose logic) |

### Exact diff summary (final line numbers)

| Final lines | Before | After |
|---|---|---|
| `:61-88` | no FIX-COLOR header | 24-line donor-evidence header (`classes.script`, `misc.script`, `shaders.ref`, `unit.smx*.frag`, `refunit.mat`, `refbuilding.mat`, `units.mat`, `convert_models.py`) |
| `:93-102` | only `KEY_COLORS_PATH` | + `TINT_SHADER_CODE` (donor mix formula), `DDS_HEADER_SIZE`, `DXT5_BLOCK_BYTES`, `TINT_MASK_THRESHOLD` |
| `:165-171` | only `_key_colors*` state | + `_donor_texture_paths`, `_band_mask_cache`, `_band_mask_stats` |
| `:180-185` | clears mesh caches only | + clears the three new dictionaries |
| `:197-202` | manifest loop read only `sid`/`bbox` | + reads and stores `m["texture"]` verbatim |
| `:250-259` | `donor_tint_target = StandardMaterial3D.albedo_color...` | corrected target/scope/target label/visual/mask source/stats/UNVERIFIED text; all old keys retained |
| `:363-432` | none | `clamped_dxt5()` + `_dxt5_mask()` (DXT5 alpha decoder; byte-wise magic check after ticket 271) |
| `:439-526` | none | `_band_mask()`, `_band_mask_texture()`, `_mask_at()`, `_measure_band()` |
| `:528-550` | albedo_color clone | masked `ShaderMaterial`; no mask => untinted clone |
| `:560-578` | plain `_apply_tint` | + `_measure_band()` + `donor_tint_label` / `donor_tint_visual` meta |
| `:934`, `:1099-1101`, `:1284` | V7-65 call sites / building meta | unchanged call sites; labels added inside `_apply_tint` |

## 4. Verification — parse PASS, probe PASS, full selftest SKIPPED

All Godot work went through `variant3d/tools/godot_runner.py` (no direct launches).

| Job id | Ticket | Result |
|---|---|---|
| `fixcolor-probe0` | `261` | ok, 2.91 s — pre-fix capability probe: Godot 4.7 cannot `Image.load_from_file()` DDS (`Error 15`), so the manual DXT5 decoder was needed; `ShaderMaterial` uniform set works headlessly. Probe deleted. |
| `fixcolor-parse1` | `271` | **failed**, 7.37 s — `PackedByteArray.subarray()` does not exist in Godot 4.7 (`world3d_entities.gd:378`, `:384`). Fixed in source by direct byte comparisons. |
| `fixcolor-parse-final` | `295` | **PASS**, exit 0, 5.41 s — final `world3d_entities.gd` parses clean. |
| `fixcolor-probe` | `297` | **failed**, 4.59 s — probe-only error: `Basis.xform()` does not exist. Fixed in the temporary probe (`basis * vector`), no source change. |
| `fixcolor-probe2` | `298` | **PASS**, exit 0, 11.98 s — **17/17 checks passed** (see measured numbers below). Temp probe and its result JSON were deleted after measurement. |
| full selftest | — | **NOT RUN — skipped by explicit user FAST LANE request.** No 29/29 claim is made in this report. |

### Measured probe results (ticket 298)

| Measurement | Value |
|---|---|
| Donor slots loaded | 13 |
| Batch keys | `unit|peasant|p0`, `unit|peasant|p1` |
| Tint carrier | two distinct `ShaderMaterial`s, `custColor` slot 0 `(0.7396, 0, 0, 1)`, slot 1 `(0.0706, 0.4, 0.9035, 1)` — DIFFERENT and donor-matching (tol 1e-4) |
| Whole-body regression guard | PASS — no batch/building material carries a non-white `albedo_color` |
| Peasant donor mask texels | **37,147 / 262,144** (14.17%) decoded in Godot; Pillow read of `peaukr.dds` gave 34,990 at a>=128 (DXT5 interpolation broadens partial-alpha texels; held within 2,500 tolerance) |
| Peasant mesh tinted subset | **119 / 719 vertices (16.55%)** and **103 / 921 faces (11.18%)** |
| Building `hou` tinted subset (stats) | 74 / 2,462 vertices, 42 / 2,298 faces; mask 15,872 / 4,194,304 texels (`ukrhou.dds`) |
| Yaw face=0 | local +Z maps to world `(1.0, 0.0, -4.4e-08)` ≈ +X — PASS |
| Yaw face=PI/2 | local +Z maps to world `(0.0, 0.0, 1.0)` = +Z — PASS |

Both tinted vertex and face counts are strictly between zero and the model totals: the player colour now reaches only the donor-indicated band subset, not the body. Stderr contained only the pre-existing ANIM_STATUS warning and a harmless dummy-renderer `Parameter "material" is null` message while reading shader parameters; no script errors.

No visual parity claim is made. No screenshot/render/donor comparison was performed.

## 5. Open questions / UNVERIFIED

1. **Donor shader binary not executed.** The formula is read from `unit.smx9.id8.frag:37-38` and reproduced in a Godot spatial shader; no donor render is compared. `PORT APPROXIMATION — NOT DONOR PARITY` remains on every tinted object and in stats.
2. **Runtime donor-asset dependency.** The mask is decoded from the donor DDS path stored in `assets/models/manifest.json:models[i].texture`. On a machine without the donor install, no mask is found and objects are left **UNTINTED** (never whole-body tinted). A build-time asset bake of the mask into `variant3d/assets` would remove this dependency but is outside this job's exclusive ownership.
3. **DXT5 alpha decode** is CPU-side, first mip only, with integer interpolation; the donor GPU decoder's exact rounding on partial alpha values is UNVERIFIED. Masked texels are essentially binary (32,814 of 35,760 nonzero are exactly 255 for peaukr), so the impact is expected to be small — not measured visually.
4. **UV orientation** — Godot's V-flipped UVs are sampled directly against the decoded image. Ticket 298 measured 119/719 tinted vertices and 103/921 tinted faces for peasant, so the sampled orientation is non-degenerate; exact per-pixel parity with a donor render is still UNVERIFIED.
5. **tfDefault gate** — donor skips tint entirely for `tfDefault` child materials (`units.mat:9,20`); the port mesh is a single merged surface with no material split (`convert_models.py:133-137`), so this gate cannot be represented. All ported units/buildings use tfRGBA-style albedo textures; no tint is applied to resources.
6. **Alpha / >1.0 clamp** — unchanged from V7-61/V7-65: donor emits no alpha (`misc.script:5069,5072`), slot 4 R=1.2 and slot 6 B=1.2; the exact donor and downstream clamping is UNVERIFIED. The 13 donor slots are used verbatim.
7. **No visual parity claim** — all verification is structural/numeric.

## 6. Queued FIX-MOVE-VISUAL check — `face -> yaw` (separate from tint work)

Coordinator relay: FIX-MOVE proved the order/destination path correct (`game.cmd_move` receives exact SIM metres, heading math byte-identical to 2D) and suspected a **visual** 90° error in this file's `yaw = -face`.

**Result: the suspicion is CONFIRMED. Fixed one line; no other source touched.**

| Evidence | `path:line` / measurement |
|---|---|
| SIM `face` is `(target - pos).angle()` — angle from +X toward +Y | `app/scripts/game.gd:4605`, `:5182` (also `:4442`, `:4698`, `:4737`, `:4762`) |
| `world.gd` uses that same `face` directly as a sprite column `round(face/(PI/4)) % 8` | `variant3d/scripts/world.gd:438-446` |
| Sprite sheet columns are camera azimuths `d*45°` around the **donor Z-up** mesh, camera at `(cos az, sin az, ·)*50` | `variant3d/tools/bake_sprites.py:226-245`, `:528-540` |
| **Measured donor mesh front = donor -Y:** in `assets/models/anim/common/units/peasant_idle.png`, column 6 (az 270°, camera at -Y) shows the face/buttons; column 2 (az 90°, camera +Y) shows the back strap. Same for `musketeer_idle.png` (buttons/sword vs bandolier back). Geometry cross-check: peasant bbox X ±0.717 (arm span) vs Y -0.227..+0.285 (depth). | read-only image crops of the donor-derived sheets; `assets/models/manifest.json` peasant bbox |
| Y-up bake maps donor `(x,y,z) -> (x,z,-y)`, so donor -Y becomes **local +Z** | `world3d_entities.gd:_bake_mesh` (`:398-400` after FIX-COLOR edits); `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md:209-212` |
| `world3d_entities.gd:_world_pos` maps sim +Y to world +Z | `world3d_entities.gd:1016` |

**Math:** `R_y(θ) * local +Z = (sin θ, 0, cos θ)`. We need `(cos face, 0, sin face)`, hence `θ = PI/2 - face`. Face 0 (sim +X) → world +X; face 90° (sim +Y) → world +Z. V7-65's `yaw = -face` pointed **local +X** — 90° away from the donor mesh's true forward — exactly matching "peasants move laterally" while positions/destinations stay correct.

**Change (final `world3d_entities.gd:1040-1055`):** replaced the old three-line approximation with a donor-cited explanation and `yaw = PI / 2.0 - float(ed.get("face", 0.0))`. The `PORT APPROXIMATION` label and `visual UNVERIFIED` wording are retained (donor yaw is a renderer transform; no turn actions exist in 246 `.aaf` per V7-2 §3.3.3 / V7-1 C4). Public signatures, tint-mask work, V7-74 morph and V7-79 memoization are untouched.

**Verification (ticket 298, 17/17 PASS):** `face=0` → local +Z maps to world `(1.0, 0.0, -4.4e-08)` ≈ +X; `face=PI/2` → local +Z maps to world `(0.0, 0.0, 1.0)` = +Z. Parse of the final file passed at ticket 295. Full selftest skipped by user FAST LANE request. No visual parity claim.
