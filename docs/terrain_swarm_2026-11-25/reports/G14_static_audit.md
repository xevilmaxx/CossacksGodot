---
id: G14-STATIC-AUDIT
title: "G14 — static parse/runtime hazard audit of the six edited source files + the test fix"
owner: G14 (read-only audit, Wave G)
date: 2026-11-25
status: READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_RUNNER_JOB
scope: "Static source/API/anchor audit only. Files read (read-only): variant3d/shaders/terrain_tileindex.gdshader; variant3d/scripts/{tile_atlas_loader,game,world3d_terrain,input_controller,world3d_fx}.gd; variant3d/tests/t_select_rect.gd; the six inbox/backup/*.bak-B0x files; the B01-B06 + A10/WAVE_G/CHARTER reports; variant3d/project.godot; presets_summer.json; pattern_gen.gd; world3d_entities.gd. Godot 4.4 official shading-language / built-in-function / @GlobalScope docs fetched read-only. One scratch bracket-balance script written OUTSIDE the repo (C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g14_balance.py). No source, test, config, fixture, gate, result JSON or app/** file edited. No Godot process, no runner job, no git state change."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — no donor GPU A/B exists (CHARTER §3). No donor parity is claimed or implied anywhere in this report."
---

# G14 — static shader / GDScript / invariant audit

## 0. Verdict (one line)

**Observed:** no parse-blocking or compile-blocking hazard was found in any of the seven edited files; every A10 §4 DO-NOT-TOUCH item checked is intact. **Derived:** several NON-blocking runtime/visual coverage gaps remain (§5) and must be settled by G04's runner gates, not by static reading. All visual statements stay PORT APPROX / UNVERIFIED — this audit cannot establish donor parity or gate-greenness.

---

## 1. Method

1. Read `WAVE_G_CHARTER.md`, `CHARTER.md`, `A10_regression_constraints.md` and B01–B06 in full.
2. `git diff` for each edited file against `HEAD` and exact `Get-Content` anchor comparison of shader + backup (`:235`, `:365-378`, `:392`, `:427`, `:475`, `:476`, `:478-502`, uniform roster).
3. API-signature checks against Godot **4.4** docs (project `config/features=PackedStringArray("4.4", "GL Compatibility")`, `variant3d/project.godot:9`).
4. Static symbol/scope/type cross-references (grep) and a string/comment-aware bracket-balance script over all six GDScript files (run outside the repo).

Labels: OBSERVED = literal file/API fact; DERIVED = consequence of those facts; INFERRED = risk/mechanism prediction; UNVERIFIED = needs a live gate or a donor A/B (never available here).

---

## 2. Shader GLSL — `variant3d/shaders/terrain_tileindex.gdshader` (B01)

All line numbers are current (file is 502 lines).

### 2.1 `textureGrad` / `textureSize` / `dFdx` / `dFdy` — OBSERVED valid for this project's Godot version

| Construct | file:line | Godot 4.4 reference | Finding |
|---|---|---|---|
| `textureGrad(tile_atlas, (cell+uv)/atlas_grid, dFdx(v_st*uv_repeat)/atlas_grid, dFdy(v_st*uv_repeat)/atlas_grid)` | `:337` | `textureGrad(gsampler2D s, vec2 p, vec2 dPdx, vec2 dPdy)` — shader_functions page, table + description at :1950/:2232 | **OK.** Correct 4-arg signature; all three gradients are `vec2` (`v_st` varying `vec2` × `uv_repeat` uniform `vec2`, `/ atlas_grid` `vec2` → component-wise `vec2`). |
| `vec2(textureSize(tile_atlas, 0))` | `:335` | `ivec2 textureSize(gsampler2D s, int lod)` — :1942/:1966 | **OK.** `textureSize` returns `ivec2`; explicit `vec2(...)` constructor cast is a legal GLSL ES 3.0 conversion. `lod = 0` is a valid `int` literal. |
| `dFdx(...)`, `dFdy(...)` | `:337` | `vec_type dFdx/dFdy(vec_type p)` — :1954/:1957 | **OK.** Automatic-granularity derivatives are available in the **Compatibility** renderer; only `dFdxCoarse/dFdyCoarse/dFdxFine/dFdyFine` are marked "Not available when using the Compatibility renderer" (:1955-1959). Project is GL Compatibility, so the chosen functions are the correct ones. |
| Half-texel inset `0.5 / max(vec2(textureSize(tile_atlas,0)) / max(atlas_grid, vec2(1.0)), vec2(1.0))` | `:335` | `max(vec2,vec2)`, scalar/vector `/` component-wise | **OK, no divide-by-zero.** Inner `max(atlas_grid, vec2(1.0))` guards an unset grid; outer `max(..., vec2(1.0))` guards a zero cell size. `mix(inset, 1.0-inset, fract(...))` at `:336` is `mix(vec2,vec2,vec2)` — valid. |

- DERIVED: `tile_rgb()` is called exactly once, unconditionally, at `:392` before any `if`, so the texture-gradient read at `:337` is **not** in non-uniform control flow — no implicit-derivative hazard.
- DERIVED: gradient magnitude is computed from the **unwrapped** varying `v_st*uv_repeat` (`:316`, `:337`); the mirror/warp (`f`, `warp` at `:332-334`) is applied only to the sampled coordinate at `:336`. Consistent with A06-F2's stated design; magnitude selection of the mip level is preserved PORT APPROX.

### 2.2 Uniform count / sampler names / filter hint

- OBSERVED: `uniform` declarations are **31 → 31** (current file and `inbox/backup/terrain_tileindex.gdshader.bak-B01`), same order and names. The only textual change in the uniform set is the hint at `:60` `filter_nearest_mipmap` → `filter_linear_mipmap`.
- OBSERVED: `filter_linear_mipmap` is a valid hint (`filter[_nearest|_linear][_mipmap][_anisotropic]`, shading_language page "Uniform hints" table). Sampler identifiers `tile_atlas` (`:60`), `alpha_atlas` (`:66`), `alphavert_atlas` (`:72`), `shadow_map` (`:83`) unchanged.
- OBSERVED: no new uniform added; no uniform removed/renamed. Uniform byte count is far below the 4096-vec4 limit (31 declarations).

### 2.3 Protected anchors / A-B contract — all byte-identical

Exact `Get-Content` comparison (whitespace-normalised) of current vs B01 backup at every cited anchor returned **no differences**: `:235` (`mask_to_alpha = 1.0`), `:365-378` (`alpha_patch_uv` body), `:392` (albedo call), `:427` (`rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;`), `:475` (`ALPHA = 1.0;`), `:476`, and the full `:478-502` A/B comment block including `:492`/`:495` endpoint definitions and `:498`. Declared length **502 → 502**.

- OBSERVED: `mask_to_alpha` binding name at `:484-486` still exactly `"mask_to_alpha"`; both A/B endpoints remain values of the same compiled program; no branch/variant introduced. A/B contract **intact**.
- OBSERVED: new logic is confined to `:265` (comment), `:315-316`, `:328-338`, `:409-419`. Sentinel guard math at `:412-419` uses `step(2.5, scol)*step(2.5, srow)` on the same id decomposition as `alpha_patch_uv` (`:366-374`) — no parse issue; DERIVED: detects patches `(3,3)`/`(7,3)` as intended because `scol∈[0,7]`, `srow∈[0,3]`.
- OBSERVED: no dither/noise/hash/beauty field added (CHARTER §3 S-25-09 respected); no donor-parity sentence added.

---

## 3. GDScript parse / runtime-symbol audit (B02–B06 + COORD fixes + test fix)

String/comment-aware bracket-balance scan: `game.gd`, `input_controller.gd`, `tile_atlas_loader.gd`, `world3d_fx.gd`, `world3d_terrain.gd`, `t_select_rect.gd` → **all `unclosed=[] mismatch=[]`**. This is a syntax sanity check, **not** a Godot parse; final authority is G04's gate.

### 3.1 B02 — `variant3d/scripts/tile_atlas_loader.gd`

- OBSERVED: `_prepare_atlas_image(img: Image) -> Image` at current `:335-345` uses `img.has_mipmaps()` (const), `img.generate_mipmaps(false) -> Error`, `err != OK`, `push_warning("..." % err)` — all valid Godot 4.x `Image`/global APIs.
- OBSERVED: called at `:285` (`_load_single`) and `:416` (`_load_split`); both wraps are `ImageTexture.create_from_image(_prepare_atlas_image(img))`. `_load_array()` (`:427`, `Texture2DArray.create_from_images`) untouched.
- OBSERVED: `.import` edits are exactly `mipmaps/generate=false` → `true` in both atlas files (`tile_index_atlas.png.import:26`, `tile_index_atlas_winter.png.import:26`); no `flags/*` key added. DERIVED: no parse hazard.

### 3.2 B03 — `variant3d/scripts/game.gd`

- OBSERVED: `_apply_detail_pass(brng: RandomNumberGenerator)` at `:1913`; the only call is `_apply_detail_pass(brng)` at `:2039`, inside `func _assign_tileblocks()` (`:1957`) where `brng := RandomNumberGenerator.new()` is declared at `:1969`. **In scope, 1:1 arity.**
- OBSERVED: `_tb_pick(2, 5, brng)` / `_tb_pick(1, 4, brng)` at `:1937`/`:1941` match `func _tb_pick(li: int, gi: int, brng: RandomNumberGenerator) -> int` at `:2166`.
- OBSERVED: P2 loop at `:2051-2063` reads `pst.kind`, `pst.x`, `pst.y`, `pst.cells` — all fields exist in `pattern_gen.gd:66-73` `class Stamp` (`kind:String`, `x:int`, `y:int`, `cells:Array[Vector2i]`). `(pst.cells as Array)` then `var pcc: Vector2i = pc` is legal typed assignment. `_blk("ground1")` etc. resolve: all redirected/picked names (`grass9`, `test8`, `test7`, `ground1`, `test6`, `grass8`, `grass1`, `grass2`, `grass_ground1/2/3`) exist as strings in `variant3d/assets/terrain/structs/presets_summer.json`. `_blk` signature `(String)->int` at `:1954`.
- DERIVED: no parse/runtime-name error. Determinism note (not a parse bug): P1 adds `brng.randf()` draws, so tileblock bytes change for a seed — expected per B03/TRN-DATA; `same_seed_byte_identical` holds by construction because both calls re-seed.

### 3.3 B04 — `variant3d/scripts/world3d_terrain.gd`

- OBSERVED: `_relief_face_at(height: PackedFloat32Array, w: int, h: int, x: int, z: int, relief_span: float) -> int` at `:812-855` uses only valid Godot 4 globals `clampf`, `absf`, `maxi`, `mini`; index expressions are guarded by `maxi/mini`, and the `relief_span <= 0.0` early return at `:813` precedes all reads.
- OBSERVED: scope verified — `var hmin/hmax` declared at `:1318-1319` in `build()` (`:1301`); used at `:1424` and in the stats ledger at `:1683`/`:1685`, all within `build()`. `var relief_path_used: bool = false` at `:1421`, set at `:1427`, read at `:1484` — same per-cell loop body (loop starts before `:1405`, `mesh.add_surface_from_arrays` at `:1528` ends it).
- OBSERVED: the added `b04_relief_promotion` dict at `:1670-1691` is a well-formed nested Dictionary literal inside the existing `stats` dict; constants `DONOR_CDIFF1/2`, `DONOR_ROCK4_H/8_H` all exist (`:181-210` region).
- DERIVED: no parse error. Flat-grid guard is preserved structurally: `_face_mode_at()` (`:788`) is byte-identical and `_relief_face_at()` returns 0 before reading height on `span<=0`, so a flat grid (including uniformly elevated) promotes 0 through the new path.

### 3.4 B05 — `variant3d/scripts/input_controller.gd` (including COORD's two parse fixes)

- OBSERVED: COORD fix #1 present at **`:621`** — `var dst: Viewport = camera.get_viewport()`. `Viewport` is a valid built-in type; `camera` is declared untyped `var camera = null` at `:15` and is guarded by `camera == null or not is_instance_valid(camera)` at `:618`, so the dynamic call is legal after the guard.
- OBSERVED: COORD fix #2 present at **`:876`** — `var ctrl_held := Input.is_key_pressed(KEY_CTRL)`. Verified against Godot 4.4 `@GlobalScope.Key`: **`KEY_CTRL = 4194326`** is a real constant ("Control key"). (`KEY_CONTROL` — the pre-fix spelling — is not declared in 4.4 and would be a parse error; the fix is correct.) `KEY_SHIFT` used alongside at `:875` is likewise valid.
- OBSERVED: other new symbols all resolve — `Transform2D.affine_inverse()/basis_xform()` at `:216-217` (valid `Transform2D` methods); `is_finite()` at `:626`, `:662`, `:992` (valid 4.4 global taking float); `get_selected()` at `:332`, `selected_ids` at `:28`; `game.units_of(0)` exists at `game.gd:2971`; `hud.build_ghost_sid` at `hud.gd:102`; `_pick_screen`, `_drag_current`, `_rect_ground_anchor` declared at top of file.
- OBSERVED: the UTF-8 BOM at byte 0 (`EF BB BF`) is **pre-existing** — the B05 backup has the identical BOM. Not introduced by this edit; Godot reads BOM-prefixed UTF-8 GDScript. No new parse hazard.
- OBSERVED: `Rect2(drag_start, _drag_cur_px - drag_start).abs()` at `:1523` — `Vector2 - Vector2` → `Vector2` size; correct `Rect2(position, size)` usage (root-cause fix).

### 3.5 B06 — `variant3d/scripts/world3d_fx.gd`

- OBSERVED: `_ghost_resolve_mesh()` new step 1 at `:657-662` calls `provider.call("_mesh_info", sid, "building")` — matches `func _mesh_info(sid: String, kind: String) -> Dictionary` at `world3d_entities.gd:1110` (2 args). Result is checked with `.is_empty()` and `base_info.get("mesh") is Mesh` before use.
- OBSERVED: step 2 at `:667-672` calls `provider.call("_stage_mesh_info", sid, "4", false)` — matches `func _stage_mesh_info(sid: String, suffix: String, scaffold: bool) -> Dictionary` at `world3d_entities.gd:1819` (3 args).
- OBSERVED: step 3 loop at `:679-681` uses a 3-element string array literal with `ResourceLoader.exists(path)` / `load(path)` — valid.
- OBSERVED: node rename at `:922` to `"GhostBuildingFinished"`. Repo grep: the only remaining literal `"GhostBuildingStage0"` in a live test is `variant3d/tests/t_ghost_final_stage.gd:409`, which explicitly asserts the **old** name must NOT survive — consistent with the rename, not a broken consumer. No production code reads the old name.
- DERIVED: no parse error or arity mismatch.

### 3.6 Test fix — `variant3d/tests/t_select_rect.gd:525`

- OBSERVED: `var expected := Rect2(_p0, _p1 - _p0).abs()` — `_p0`/`_p1` are `Vector2` (`:75-76`), subtraction yields a `Vector2` size; `.abs()` valid. This matches the game's corrected `Rect2(position, size)` semantics.
- OBSERVED: the `expected_pre_fix_failure=true` marker is **still passed** at `:543` (`check(label, ok, "...", true)`), and the `check()` signature at `:178` still defaults it to `false`. **Not flipped, not deleted** (A10 §3/§4).
- OBSERVED: the recorded-only/hard-gate structure of the test is otherwise untouched by the diff (only `:525-529` comment + expectation changed).

---

## 4. A10 §4 DO-NOT-TOUCH checklist — item-by-item

| A10 §4 item | Current-tree evidence (file:line) | Verdict |
|---|---|---|
| Mesh topology: 1 surface, **4096** verts, **7938** tris, **4096** UV2 | `world3d_terrain.gd:1370` `ntris=(w-1)*(h-1)*2`; resizes `:1375/:1378/:1380`; single `mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)` at `:1528`; `stats["mesh_surfaces"]` at `:1635` | **INTACT.** B04 adds an `int` helper; no vertex/index/surface write changed. |
| UV2 semantics: `UV2.x` integral tile id `[0,123]`, `UV2.y∈{0,1,2}`, `face_hist_sum==4096`, `tile_index.cells==4096` | `uvs2[i] = Vector2(float(tid), float(face))` at `:1507` (byte-identical); out-of-atlas guard `:1409`; `_relief_face_at` returns only 0/1/2 at `:813/:855` | **INTACT.** tid still from existing name/manifest lookup; new path writes only `face`. |
| `flat_grid_promoted==0` / `flat_face_zero==0` — do not alter `_face_mode_at` thresholds | `_face_mode_at` `:788` byte-identical (diff shows no hunk touching it); `DONOR_CDIFF1/2` unchanged; `_relief_face_at` early-return `:813` on `span<=0` | **INTACT** structurally. Runtime zero must be confirmed by G04's six flat-grid atoms. |
| `atlas_grid==[16,8]` in stats/shader/manifest; three-sampler binding; `named_cells=124` | shader `atlas_grid` `uniform vec2` at `:91` unchanged; `mat.set_shader_parameter("atlas_grid", _atlas_grid)` at `:724`; three sampler names in shader `:60/:66/:72` unchanged; loader grid/manifest path untouched by B02 | **INTACT.** |
| `shadow_enabled==0`, `DonorSun.shadow_enabled==false`, `mi.cast_shadow==OFF` | shader `shadow_enabled = 0.0` `:180`; `mat.set_shader_parameter("shadow_enabled", 0.0)` `:741`; `sun.shadow_enabled = false` `:1240`; ghost `cast_shadow = OFF` in world3d_fx unchanged by B06 | **INTACT.** No shadow source changed in any of the six files. |
| `WATER_LEVEL=-0.25`, `BLK_WATER=255`, single height-aware water plane, WaterPlane hidden in P0 | `WATER_LEVEL: float = -0.25` `:152`; `blk_water_sentinel: 255` `:1727`; shore/water branch at `:1407/:1461` precedes the new relief path (`if face==0 and not shore_gate` at `:1422`) | **INTACT.** Literals and ordering unchanged. |
| Donor sun/ambient/diffuse/specular literals | shader `:150/:154/:157/:160` byte-identical to backup; fog/eye-plane uniforms untouched | **INTACT.** |
| `mask_to_alpha` A/B contract + `:476`/`:478-502` 502-line anchor block | §2.3 above: all anchors byte-identical; 502→502 lines; uniform binding name exactly `mask_to_alpha` | **INTACT.** |
| Season index preservation (tileblock bytes, summer/winter UV2.x identical, desert 38+1 remap) | B03 changes tileblock *generation* deterministically per seed (TRN-DATA precedent) but no season hook; B04 reads height only and runs before the desert remap; B02 changes only mip levels, not level-0 pixels | **Structurally INTACT**; runtime byte-equality across season variants is a G04 gate item. |
| `expected_pre_fix_failure`, P0 `RECORDED_NOT_APPLICABLE`, luma floors, donor-parity `UNVERIFIED` | `t_select_rect.gd:543` marker still `true`; no threshold/assertion deleted in any diff; no "parity PASS" sentence added | **INTACT.** No weakening observed. |
| `app/**` untouched; no synthetic dither/noise | `git status` shows no `app/**` modification; no `dither/noise/hash` introduced in shader math (§2.3) | **INTACT.** |

---

## 5. Non-blocking hazards / coverage gaps (DERIVED / INFERRED / UNVERIFIED)

These are **not** parse errors; each needs a live gate or a second reader. They are recorded so they are not lost behind "static OK".

1. **INFERRED — atlas mip coverage in `MODE_ARRAY`.** `_prepare_atlas_image()` is wired only into `_load_single()` (`tile_atlas_loader.gd:285`) and `_load_split()` (`:416`). `_load_array()` (`:427-479`) uses `Texture2DArray.create_from_images(images)` with no mip generation. DERIVED: the shipped default is `MODE_SINGLE` (loader `:80`, `CONFIG_SETTING` `:74`), so the active path is covered; but an array-mode run would still present a level-0-only transport to a mip-filter sampler. Not a parse bug — flag for G16/G17 and any array-mode capture.
2. **INFERRED — fixture appearance under B04.** On small-span synthetic fields the span-scaled gate can promote many cells (B04 §6 numeric replica: ~1361 non-shore cells on a `--no-shore` sinusoid of span ≈1.06 m). Structural invariants hold, but luma/dark-row/season visual gates may move. UNVERIFIED until G04 re-runs `t_combo_all` (±`--no-shore`), `t_terrain_only`, `t_season_overlay`.
3. **INFERRED — mask phase change at shader `:417`.** `alpha_patch_uv(v_tile, fract(v_alpha_uv))` now wraps in the fragment stage (A06-F2), restoring intra-cell mask variation while `tile_rgb` uses unwrapped derivatives. The half-texel clamp at `:376` still bounds the patch. DERIVED: no syntax issue; visual effect on `non_black_fraction`, `ground_mean_luma`, `ground_max_luma`, dark rows/cols is UNVERIFIED (A10 §4 NEEDS-CARE).
4. **INFERRED — B05 live selection per frame.** `_process()` at `:1528` calls `_apply_rect_selection(_drag_rect_sim)` each frame with an id-set dedupe guard; at 1280×720 the new event→camera and canvas maps are identity. UNVERIFIED that no HUD/selection-cue timing regression appears in `t_select_rect` 23/23 and uitest.
5. **INFERRED — B03 tile-id re-roll.** Extra `brng` draws shift smoothing draws; the A03 redirect changes which art `grass_ground*` draws select. No test asserts those specific ids (B03 R4), but the tile histogram/luma gates must be re-measured (G15).
6. **UNVERIFIED — static-only nature.** A bracket balance and API-signature review cannot catch Godot-parser-specific diagnostics (e.g. a shadowed variable, an inference error in an untyped seam) or GPU compile diagnostics. The first full selftest re-run (G04) is authoritative; this report makes no PASS claim.

---

## 6. Observed / derived / UNVERIFIED

- **Observed:** every `file:line` citation; 31→31 uniforms; 502→502 lines; byte-identical anchors; `KEY_CTRL=4194326` and the four shader function signatures in Godot 4.4 docs; valid Stamp fields; valid `_mesh_info`/`_stage_mesh_info` arities; the COORD fixes at `input_controller.gd:621`/`:876`; the test fix at `t_select_rect.gd:525` with marker still `true` at `:543`; zero bracket mismatches in all six GDScript files.
- **Derived:** no parse-blocking hazard; DO-NOT-TOUCH invariants preserved; the coverage gaps in §5.
- **UNVERIFIED:** shader GPU compilation on the actual Compatibility renderer; all gate outcomes (selftest 29/29, uitest 17/17, `t_render_mode`, `t_terrain_only`, `t_combo_all`, `t_season_overlay`, `t_select_rect`, `assert_clean CLEAN`); donor parity (no GPU A/B exists).

*End of G14. Read-only; one report; no source edit; no Godot or runner job; no donor-parity claim.*
