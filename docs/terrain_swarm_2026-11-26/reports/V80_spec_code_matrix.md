---
id: V80
ticket: "TERRAIN-SWARM-2026-11-26 / V80 — FINAL SPEC→CODE coverage matrix (donor-first terrain swarm)"
agent: "V80 (read-only verification worker; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_RUNNER_JOB__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V80_spec_code_matrix.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V80_spec_code_matrix.md]
files_edited: []
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT_APPROXIMATION]
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/spec/00_EVIDENCE_INDEX.md (index), spec/02..spec/10 (read in full; 09 = 09_EDITOR_PARAMETERS.md)
  - docs/terrain_swarm_2026-11-26/reports/V58_i07_audit.md
  - docs/terrain_swarm_2026-11-26/reports/V59_i09_audit.md
  - docs/terrain_swarm_2026-11-26/reports/V60_i04_audit.md
  - docs/terrain_swarm_2026-11-26/reports/V61_composer_api_audit.md
  - docs/terrain_swarm_2026-11-26/reports/V65_patch_verification.md
snapshot: "HEAD=e234ac9b; tree is VOLATILE — V80 re-read every cited implementation file; hashes below are the bytes actually audited."
parity_claim: false
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, gate, runner, capture or git mutation was used by V80. A 'PASS'/IMPLEMENTED verdict below means donor-faithful STRUCTURE at file:line only — NOT donor visual parity. Parity stays UNVERIFIED (CHARTER.md:43-44,122-135)."
scope_guard: "Only file reads, grep/Select-String, python read-only JSON counts, Get-FileHash and git read commands were used. No source/shader/asset/config/test/manifest/queue/app byte or git state changed."
---

# V80 — FINAL SPEC→CODE coverage matrix

## 0. Method, snapshot, legend

**Every verdict in this matrix was re-derived from the CURRENT implementation bytes**, not inherited from the priors. The tree drifted during the V-wave: `terrain_donor_gen.gd` was modified after V58/V61/V65 (its hash is `29F5C72761B7D8A5…` at V80 vs `0F6DB181…` at V65), so V58's three FAILs and the two "Additional" defects are **re-adjudicated in §2** — all five are now fixed in current bytes. Every claim below was confirmed in **≥2 passes** (a full/targeted `read` plus a `grep`/`Select-String`/JSON-count command).

**SHA-256 (first 16 hex) of the bytes audited by V80** — `HEAD=e234ac9b`:

| File | Hash | Note |
|---|---|---|
| `variant3d/scripts/terrain_donor_gen.gd` | `29F5C72761B7D8A5` | drifted again; re-read in full at key sites |
| `variant3d/scripts/terrain_donor_props.gd` | `C990F604F17B650E` | = V59/V61/V65 snapshot |
| `variant3d/scripts/terrain_donor_data.gd` | `77D7BFA1CF59578C` | unchanged |
| `variant3d/scripts/terrain_donor_mesh.gd` | `6AB8453AC9791B13` | unchanged |
| `variant3d/scripts/terrain_donor_world.gd` | `C98F34FE881B13E1` | V48 patches present |
| `variant3d/shaders/terrain_donor_shader.gdshader` | `BB31B1EB03829B23` | canonical path |
| `variant3d/shaders/water3d.gdshader` | present (15,809 B) | not hashed, read by grep |
| `variant3d/tests/t_terrain_donor.gd` | `3BF7E5FBE95B8E48` | patch (d) present |
| `variant3d/assets/terrain_new/cfg/manifest.json`, `atlas/tile_index_atlas.manifest.json` | read-only JSON counts | C06 / atlas checks |

**Status legend.** `IMPLEMENTED` = donor-grounded code/decoder at the cited line, second-read confirmed. `STUBBED` = hook/constant/label present but the authoritative donor path is not executed (labelled skip, metadata-only, empty runtime feed). `MISSING` = no code/asset at all. `WRONG` = contradicts the spec. `[U]`/`PORT APPROX` qualifiers are carried from the spec/priors; they are not parity claims.

---

## 1. Master SPEC→CODE matrix

### spec/02 — Seed and RNG

| Fact (spec §) | Implementing file:line (current) | Status | Evidence (second read) |
|---|---|---|---|
| Two 32-bit keys `randkey0/randkey1`; `SetRandomExtKey64` high=key0/low=key1; `GetRandomKey` returns key1 (§1) | `terrain_donor_gen.gd:461-464` (reads keys from `p`), `:347-353` (`reseed_from_key64`) | IMPLEMENTED | `_rng0=int(p.get("randkey0",0))`, `_rng1=int(p.get("randkey1",0))`; `reseed_from_key64` stores `key0=k0` ledger-only and seeds `s=k1&U32`. Key derivation itself is `[U]` in spec and is **not** faked. |
| Core LCG `s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, `RandomExt=f32(s/2^32)` (§2) | `terrain_donor_gen.gd:95-98`, `:355-363`, `:371-377` | IMPLEMENTED | Constants `LCG_MUL=0xFC0D`, `LCG_ADD=0x3C6EF35F`, `LCG_U32=0xFFFFFFFF`, `LCG_DIV=4294967296.0`; `next_f()` applies recurrence then `_f32(float(s)/LCG_DIV)` with explicit binary32 round-trip. |
| No `RandomInt/RandomFloat`; wrappers `floor(RandomExt*n)` / `min+floor(RandomExt*(max-min+1))` (§2) | `terrain_donor_gen.gd:365-369` | IMPLEMENTED | `next_int`, `next_range` implement the two DScript wrappers verbatim. |
| 11 `SetRandomKey` + 3 `SetRandomExtKey64` re-seed sites, same key verbatim, no mix64 (§4–§5) | `terrain_donor_gen.gd:112-116` (tables), issued at `:748,:750,:803,:823,:828,:1430,:2101` etc.; ledger `:544-546` | IMPLEMENTED | `RESEED_SITES` = `D3:99,D3:146,D1:1100,D1:1161,D1:1177,D1:1213,D1:1538,D1:1616,D1:1772,D1:1909,D1:1927`; `EXT_KEY_SITES=D2:216/:513/:774`. All issued via `_stage_begin`, not merely listed. |
| Three independent streams + separate Delphi LCG (§3) | `terrain_donor_gen.gd:382-388`, constants `:99-100` | IMPLEMENTED | `_rng/_rng_map/_rng_world/_rng_delphi`; `DELPHI_LCG_MUL=0x8088405`, `ADD=1`. |
| Fixed draws: `foreststype` one draw forced 0; `minesdensity` before `:1616`; `relieftype` after (§4) | `terrain_donor_gen.gd:751-756`, `:808-812` | IMPLEMENTED | `_active_rng.next_int(3); foreststype=0`; `minerdensity>2` draw in `_stage_settings` (before D1:1616 reseed at `:1430`). |
| key0 is a NO-OP mod 2^32 (X21, folded into §5) | `terrain_donor_gen.gd:242-249`, `:347-353`, `:538` | IMPLEMENTED | `key_state_hook` covers only the still-`[U]` signed-product edge; normal path discards key0; telemetry `key0_semantics="DISCARDED mod 2^32"`. |

### spec/03 — Mask→height

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| `h=-1.1*B/255`; B≥58 ⇔ `h<-0.25`; no sign flip (§1, §5) | `terrain_donor_gen.gd:122`, `:137-139`, `:903-911`, `:917`; decoder `decode_donor_masks.py:57-59`, `:210-213` | IMPLEMENTED | `hwater=C_WATER_HEIGHT*(fb*(1+fr*C_R_MULT))` then `set_height(i,hwater+hterrain)`; spec/03 §2's "wrong-sign relief()" is explicitly recorded as STALE/REFUTED at `:62-69`. Decoder: `WATER_DEEP_B=58`, `H_SCALE=-1.1`. |
| Three distinct thresholds: `B==255` class / bed / `B>0 ∧ h<-0.25` tag (§1, §5) | `terrain_donor_gen.gd:137`, `:899`, `:157-158`, `:1092-1094` | IMPLEMENTED | `_mask_water[i]=1 if ib==C_BCOLOR_WATER`; water/shore flags use mask B + height; `C_WATER_BYTE=58` is a documented dead literal (`:138-139`, noted V58 item 2). |
| R/G class decode is donor intent, INERT on shipped masks; never map R→height (§1–§2) | `terrain_donor_gen.gd:124-136`, `:877-896`, header `:62-69` | IMPLEMENTED | R/G codes decode into `tclass`/`fdens` side arrays only; `hterrain` uses class×R donor-intent amplitudes but R=0 on shipped masks, so `h=-1.1*B/255` stands. No side-array read-back into height. |
| Coastal smoothing gate = mask B + height band, NOT height-only (§3, §5) | `terrain_donor_gen.gd:986-991`, `_has_water_5x5 :1006-1012` | IMPLEMENTED | `_smooth_custom(..., coastal_gate=true)` skips cells without a `cBWater` (B==255 class) cell in 5×5, then applies the `[-100,-0.01]` band at `:990-991`. |
| 3-pass chain: bsmooth r3; land `4/0.5/[0.01,100]`; 3× coastal `0.35/0.5/[-100,-0.01]` (§3) | `terrain_donor_gen.gd:142-152`, `_smooth_chain :956-978`, `_smooth_custom :980-1003` | IMPLEMENTED (constants) / STUBBED (r3 kernel) | All constants verbatim; the native `SmoothTerrain(radius 3)` kernel is `[U]` (D03 U3) and skipped behind `bsmooth_kernel: Callable = Callable()` (`:282`, `:964-969`) with a telemetry note — an explicitly labelled skip permitted by the charter. |
| Port decoder bugs not repeated: `B>=58` (not `B>58`), starts excluded from water fraction (§5) | `decode_donor_masks.py:57-58`, `:205-213`, `:243-247`; V60 live `--check` 18/18 | IMPLEMENTED | `water_count = count_nonzero(b_ns >= WATER_DEEP_B)` with starts removed from numerator and denominator; `water_all` is a separate labelled diagnostic. V60 (read this pass) reports 9/9 PASS and deterministic 4,466-mask dry-runs. |

### spec/04 — Pattern stamping

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| Three blend paths: `ReplaceForWater` `g*Scale+Offset`; `Replace` `base_h+(g−Min)*Scale+Min+Offset`; Smooth `h1+(base_h−h0)*TerrainScale+(g−Min)*Scale+Min+Offset` (§6) | `terrain_donor_gen.gd:1778-1784`, `:1805-1814` | IMPLEMENTED | `g` pivoted with `Min` for Replace/Smooth, `g*Scale` for RFW; branches at `:1806` RFW `stamped=g+hoff`, `:1808` Replace `base_h+g+hoff`, `:1810-1814` Smooth with **two distinct height reads** `h0`/`h1`. Decoder `decode_donor_pattern.py:44-49` documents the same three branches. |
| `Min` is the pivot; `HeightFieldMax` never read; no `[Min,Max]` clamp (§6) | `terrain_donor_gen.gd:1778-1779` (comment), `:1763-1767` (field reads), `:1815-1818` | IMPLEMENTED | Only `min (+0x5c)`, `offset (+0x64)`, `terrain_scale (+0x68)`, `replace/replace_for_water` are read; no `+0x60` operand; the only clamp is the `[U]` `global_setter_clamp_hook` (`:267`, default `Callable()`). |
| In-place smooth post-pass: interior-only, 8-neighbour clear, radial remap, `Factor` repeats, mean/4.0 (§6) | `terrain_donor_gen.gd:1857-1911`, default `:255` | IMPLEMENTED | `stamp_smooth_buffer_mode="in_place"` (donor-grounded per X26); `src = snap if double_buffer else data.height` at `:1908`, 8-neighbour test `:1882-1887`, `(radius-offset)/d` `:1889-1895`, `factor` loop `:1896`, `/C_STAMP_SMOOTH_DIV(=4.0)` `:1909-1910`. |
| Five exact F01 grid offsets 968/1864/2798/2222/8225 (§4, §6/X23) | `terrain_donor_gen.gd:227-235`, decoder `:578-606` | IMPLEMENTED | `F01_GRID_OFFSETS` has all five including `plt2:2222` and `k_ravine_big_stone_1:8225`; `decode_pattern_grid` uses them and refuses stale X13 offsets (`:592-594`). Decoder `decode_donor_pattern.py:16,:19,:26-33` implements `G=8+(w-1)*(h-1)` size law. **This closes V58 item 3d.** |
| f32-step precision is the authoritative contract (X26) | `terrain_donor_gen.gd:257-260`, `_pf :1832-1838` | IMPLEMENTED | Default `stamp_precision_model="f32_each_op"` (was `"double_store_f32"` at V58); `_pf` round-trips every op through binary32 when selected. |
| Placement: 256 tries, strict 25-unit grid, `Freq` damping ×0.2 floor 1e-4 (§3) | `terrain_donor_gen.gd:184-186`, `:187`, `:201-202`, `:774-796`, `:1917-1931` | IMPLEMENTED | `C_TILE_GRID_SIZE=25`, `C_TRYCOUNT_MINES=256`, `C_FREQ_DAMP=0.2`, `C_FREQ_FLOOR=0.0001`; base-tile loop inclusive; `_roulette_name` consumes the donor name draw even on an empty family. |

### spec/05 — Water and shore

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| Four distinct water levels −1.1 / −0.5 / −0.25 / −0.1 (§1) | `terrain_donor_gen.gd:122`, `:156-158`; `terrain_donor_shader.gdshader:174-182`; `water3d.gdshader:35-36` | IMPLEMENTED | Separate constants, no value reused; shader declares `water_height_basin/water_field_offset_y/water_height_classify/water_shore_height`. `water3d` fade constants are cited in comments as uniforms needing binding (residual `[U]`). |
| Shore tiles `sandsea1/5/6` on `mask.b>0 ∧ (h<−0.25 ∨ h<−0.1)` + 8×45° sector table, unguarded `bRT` else (§4) | `terrain_donor_gen.gd:168-181`, `:1092-1094`, `:1204-1229` | IMPLEMENTED | `_shore_tile_name` uses **literal if/else windows** on `post=pre+180`, `sname="bRT"` unguarded default; `bB/bT→sandsea1`, `bLB/bRT→sandsea5`, rest→sandsea6. **This closes V58 Additional C.** |
| Cliff asymmetric 6-branch table, `\|h\|>2.7→rock8`, `>2.4→rock4`, `<0.1→none`, no `+180` (§4) | `terrain_donor_gen.gd:1246-1292` | IMPLEMENTED | `_cliff_tile_name` does six FIRST-MATCH `pre` windows with `face`→rock{7,1,3,4} then live `\|h\|` overrides; `pre` is NOT offset by 180 (`:1251`). **This closes V58 Additional B.** |
| `hmapTex` is a parameter key, not a texture (§3) | `terrain_donor_shader.gdshader:76-84`; `water3d.gdshader:53` | IMPLEMENTED | Terrain shader declares `hmapTex` sampler but never samples/binds it (`:77` explicit); water shader documents the donor binding as `[U]`. |
| `bmTransparency` blend; mask enters ALPHA only, no albedo multiply (§7) | `terrain_donor_shader.gdshader:30-50`, `:296-307` | IMPLEMENTED (pass count `[U]`) | `render_mode blend_mix, unshaded, cull_disabled` at `:50`; `blend_pass_count=0` UNSET sentinel (`:140-143`); `rgb = rgb*v_packed + v_specular` (`:299`) with an explicit "NO mask multiply" note (`:297-298`); `ALBEDO=rgb; ALPHA=a` (`:305-306`). |
| Water shader constants (fade 0.57/1.07, exponents 170/120, mat2, foam 0.535), Fresnel/DeepColor commented out (§5) | `water3d.gdshader:35-43`, `:53`, `:70`, `:244`, `:10-14` | IMPLEMENTED (donor-faithful comments; runtime `[U]`) | Constants present with donor `water.dev.frag` citations; shipped-fragment Fresnel/DeepColor noted as commented out; no river-current grid invented. |

### spec/06 — Tile ids and atlas

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| 124 tile ids per season; no index remapping; one-for-one winter rename (§1, §4) | atlas `tile_index_atlas.manifest.json` `index_dictionary.count=124`, `lines 2-125`, `mapping="index i -> cell (i%16, i//16); NO index remapping"`; `terrain_donor_gen.gd:1102-1106` | IMPLEMENTED | JSON count read this pass = 124; `named_cells=124`; `winter` appends `_winter` to the base summer name preserving the numeric id (`:1104-1106`). |
| 16×8 atlas packing (PORT APPROX, labelled) (§2) | `terrain_donor_shader.gdshader:87-92` (`atlas_grid=vec2(16,8)`); atlas manifest `atlas.grid=[16,8]`, `slots=128` | IMPLEMENTED (labelled PORT APPROX) | Cell lookup `cell=(mod(idx,16), floor(idx/16))` at shader `:232-242`; manifest flags `APPROX_ATLAS_PACKING`. |
| 36 identity face cells / 3 EMPTY alpha holes; alphanull binds 86/110/123 (§2, §5) | atlas manifest `empty_sentinel_cells={count:3, indices:[86,110,123]}`; shader `:286-293` | IMPLEMENTED (labelled PORT APPROX) | Manifest marks the 3 holes UNVERIFIED/PORT APPROX; shader zeroes alpha on exactly 86/110/123 and samples the donor alpha atlas elsewhere. |
| 22 tile-smooth chains / 3 H-then-V passes, not 6, not 3×3 (§/spec/09 §4) | decoder `cfg/manifest.json` C06 `expected=22, pass1=22, pass2=22, pass3=22, result=PASS`; `terrain_donor_gen.gd:166`, `_smooth_tiles :1295-1330` | IMPLEMENTED (decoder + algorithm) / STUBBED (runtime feed) | `TILE_SMOOTH_PASSES=3` (cfg's 6 preserved as contradiction); per iteration horizontal `:1304-1315` then vertical `:1316-1329`, in place, one snapshot `:1299-1302`, no face promotion. Runtime chains arrive from `p.get("tile_smooth_chains", [])` (`:1073`); composer currently passes `gen_params={}` → smoothing is skipped with a labelled note (§3). |

### spec/07 — Resource placement

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| Mine rings in CELLS; 256 angle tries/ore/ring; rounds 3/4/5 by minesdensity (§1) | `terrain_donor_gen.gd:56-58`, `:741`, `:187`, `_setup_mines :1473-1519` | IMPLEMENTED | Radii written as plain cell numbers; telemetry `"MAP CELLS 1:1 (V08:155-190) — no DONOR_UNITS scaling"`; `for i in rings`, `for j in 3`, `for k in range(256)`, first-success break. |
| Ring bands `14+8R / 32+10R / 70+12R / 22+16R` shared by all three ores (§1) | `terrain_donor_gen.gd:1566-1572` (v≥80,big), `:1617-1636` (`_apply_band`) | IMPLEMENTED | `_band_id` returns band ids; `_apply_band` yields `14+8R`,`32+10R`,`70+12R`,`22+16R`, etc. in cells. |
| Missing `case i=2` reproduced: zero-init `dst`, trace flag, no silent fix (§1, §7) | `terrain_donor_gen.gd:1482-1495`, `:1512-1514`, `:1602` | IMPLEMENTED | `var dst:=0.0`; `band==-2` sets `gap_reproduced`; note `"REPRODUCED donor missing case i=2: dst=0, trace flag set, NO fix"`. |
| Three ellipses 5×7/12×15/22×18 centred `(start.x,start.y+2)` (§2) | `terrain_donor_gen.gd:190-196`, `:1424-1426`, `:1648-1699`, `_fill_ellipse :1447-1459` | IMPLEMENTED | Ellipse constants unscaled; C1 before near mines; centre adds `C_ELLIPSE_CENTRE_DY=2`; **`_fill_ellipse` no longer adds W/2 a second time** (`:1454-1457`, V58 centre bug fixed). |
| `SetupStartingResources` places six stone/forest attempts, ZERO food rects (§1–§2) | `terrain_donor_gen.gd:1648-1699`, note `:1699`, `sow_field` NOT called from `generate` (`:494-507`, `:549-571`) | IMPLEMENTED | `:1699` `"No food rects in SetupStartingResources (X22 X-C6)"`; field sowing is a separate hook (spec/08). |
| `FillOwnerMap` 160² 4-neighbour BFS, late (§3) | `terrain_donor_gen.gd:2109-2160` (called at `:505`) | IMPLEMENTED | `g=C_SCANGRID_SIZE=160`, implicit `dcur` zero-init `[U]`, 4-neighbour wavefront; `_to_scan :2163-2174` uses cell/4 with **no second W/2** (V58 owner-seed bug fixed). |
| `mng/mni/mnc` families, 6 members ΣFreq 5; stoneforest/stones patterns (§5) | `terrain_donor_gen.gd:1484-1486` (family names from `p.families`), F02-derived decoder assets | IMPLEMENTED (consumed as caller data) / STUBBED (empty at runtime) | Ore family names are correct; actual membership/Freq comes from decoded `p.families`, which the composer does not currently supply (§3). |
| No finite deposit amount is set; starting stock is a different system (§4) | `terrain_donor_gen.gd` — no deposit-amount constant; `[U]` labels only | IMPLEMENTED (no invention) | No amount constant was invented; the spec's `[U]` status is preserved. |
| `TILE_M=2.0` donor-grounded horizontally (§8) | `terrain_donor_props.gd:28`, `:89`, `:476`, `:639-640` | IMPLEMENTED | `const TILE_M: float = 2.0` cited to `dmscript.global:170-173`; used only for world placement `(cell+0.5−dim/2)*TILE_M`. |
| `DONOR_UNITS=160` / "1 unit = 2 cells" REFUTED (§8) | `terrain_donor_gen.gd:56-58`, `:741`; `terrain_donor_props.gd:24`, `:88`, `:467` | IMPLEMENTED | The constant appears only in negative string/comment contexts ("no multiplier"); no numeric `DONOR_UNITS` assignment and no `W/160` expression exists (second-read greps). |
| Props are instanced from `pattern.lib` `Objects` transforms (spec/08 §3, linked here) | `terrain_donor_props.gd:59-60`, `:532-547`, `:550-606` | STUBBED — **blocks parity** | `FEED_LIB_INDEX` file absent; `FEED_FAMILY_INDEX` exists but `families` is a **list**, while `_try_feed` only reads it as a `Dictionary` (`:561`), so `source_map` stays empty and every object falls back to `UNVERIFIED:<class>`. Forest/stone/mine/swamp/lake props produce **zero instances** (V59 item 3, unchanged at hash C990F604). Four stale UNVERIFIED labels (`:153,:154,:167,:172`) still state the false cause. See §3. |

### spec/08 — Fields and props

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| Mill fields are SCRIPT-SOWN: 7×7=49 nodes, step 1.6981 cells, 45°, `√2·size` snap, 5 gold, no tile id (§8) | `terrain_donor_gen.gd:549-571`, `field_sowing_hook_info :609-621`; `terrain_donor_props.gd:105-112`, `:343-376` | IMPLEMENTED (hook/lattice) / STUBBED (runtime trigger) | Hook info: `grid=7, step_cells=1.6981, rotation_deg=45, snap_cells=2.401476, gold_per_field=5, rng_draws_in_sow=0, tile_id=null`; I09 `mill_field_hook` computes the 49-node lattice closed-form and returns `hook_only:true`. Deliberately **not** called from `generate()` — correct per spec. No mill-trigger caller is wired in the repo, and I09's rotation sign differs from X22 by 90° (`[U]` donor `VectorRotateY` sign, V59 P6). |
| Three independent channels: float height / pattern `Objects` props / tile-decal art; no baked silhouette (§1) | `terrain_donor_gen.gd` (height), `terrain_donor_props.gd:220-290` (render-only batches), shader (art) | IMPLEMENTED (channel separation) / STUBBED (props feed) | I09 reads container height (`:933-941` per V59) and writes no height/collision; the Objects feed gap (§3) means silhouette props are not yet realised. |
| 19 forest / 5 stone / 6 mine families; pass rates 0.0009/0.0009/0.00054, `foreststype=0` (§7) | `terrain_donor_props.gd:93-98`, `:135-143`, `:456-463`; `terrain_donor_gen.gd:216-220`, `:751-756` | IMPLEMENTED (constants/metadata) / STUBBED (placement) | Rates and family names are cited and stored; I09 performs no roulette/Freq×0.2 placement and consumes no Objects records (V59 item 2 caveat); roulette belongs to I07, which implements it at `:1917-1931`. |
| `terrainmesh1..4` converted; 112 relief records; MultiMesh consumer never QA-run (§3) | `terrain_donor_props.gd:90-92`, `:130-132`; on-disk `mountain_props.json` (112 records) | IMPLEMENTED (data/consumer) / UNRUN | V59 P5 re-counted 112 records; no gate/capture was run by V80, consistent with A04's "never QA-run" finding. 23 desert records have no converted sid (`skipped_unknown_sid`, `[U]`). |
| Mill fields are decals, not tile ids; `envfieldd`/`envfielddw` per field (§4, §8) | `terrain_donor_props.gd:66-70`, `:116`, `:489-490`; `terrain_donor_gen.gd:561` (`tile_id=null`); shader has no field id | IMPLEMENTED | Decal paths present; `FIELD_OBJ`, decals, mine meshes exist on disk (V59 P4). No field/water tile id invented. |

### spec/09 — Editor parameterization (file `09_EDITOR_PARAMETERS.md`)

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| 19 active `globalparams.cfg` keys; no invented 20th key (§1–§2) | `decode_donor_cfg.py:51` (lines 22), `cfg/manifest.json` count checks C04/C05; `constants.json` | IMPLEMENTED | V37/V20 correction carried: 19 active flat keys, line 21 `section.end`, line 22 empty; decoder emits literal keys with donor path:line. |
| Two contradictions preserved: `TileSmoothPasses=6` vs script `3`; `tilesmooth.cfg` vs `tilesmooth_scripts.cfg` (§4) | `terrain_donor_gen.gd:166` (`TILE_SMOOTH_PASSES=3`, comment cites spec/09 §4); `decode_donor_cfg.py:24`, `:620` | IMPLEMENTED | Script behaviour followed for skirmish, cfg literal kept as provenance; decoder `port_rule` records "runtime loads tilesmooth_scripts.cfg". |
| 22 chains / 130 groups / 310 entries / 86 names / ΣProb=174.0168 from `tilesmooth_scripts.cfg` (§1) | `cfg/manifest.json` count checks C06–C12 | IMPLEMENTED (decoder) | C06=22 (3 passes PASS), C07=130, C08=118 active, C09=310, C10=282 active, C11=86, C12=174.0168; summary `count_checks_pass=19/19`, `hash_checks_pass=7/7`. |
| No seed/RNG/height/water/mine-count constants in the cfg files (§5) | `decode_donor_cfg.py` / `constants.json` | IMPLEMENTED | None were mined from these files; those constants live in spec/02, /05, /07 as required. |

### spec/10 — Stage order

| Fact (spec §) | Implementing file:line | Status | Evidence |
|---|---|---|---|
| Canonical 12-stage `DoGenerate` order (§1) | `terrain_donor_gen.gd:494-507` | IMPLEMENTED | `_stage_init → clear → base_tiles → settings → generate_map → shore_exclusion → starts → relief → forest_stone → units_scale → owner_map → finalize`, exactly §1 items 1–12. |
| Determinism via per-stage re-seeding, not one continuous stream (§2) | `terrain_donor_gen.gd:112-116`, `_stage_begin` calls throughout (`:748,:750,:803,:823,:828,:1430,:2101` etc.) | IMPLEMENTED | Same `randkey1` verbatim at every stage; no `mix64` derivation. |
| Donor-grounded height amplitudes / blend math / water / coastal gate (§2 table) | `terrain_donor_gen.gd:119-123`, `:1778-1814`, `:122/:156-158`, `:986-991` | IMPLEMENTED | All rows of the §2 table are present at the cited lines (see spec/03, /04, /05 rows above). |
| Keep-clear ellipses / mine rings-by-round / script-sown fields / tile smoothing 3 passes (§2) | `terrain_donor_gen.gd:190-196`, `:1473-1519`, `:609-621`, `:1295-1330` | IMPLEMENTED | See spec/07 and /06 rows. |
| Forbidden constructs rejected: no dither/noise, no face promotion, no `HEIGHT_SCALE`, no heightmap-as-albedo, no lowered gates, no invented constants (§3) | `terrain_donor_gen.gd:4-72`, `:444`, `:459`, `:831`, `:1140-1141` (per V58); `props.gd:435,:480`; shader `:42-45` | IMPLEMENTED | PostProcess Gaussian/noise explicitly skipped (`:831`); no `HEIGHT_SCALE` multiplier (`:459`); parity string `"UNVERIFIED"` at `:444/:519`; no 3×3 kernel or face promotion in `_smooth_tiles`; shader declares no shadow/AO/dither. |
| Five donor contradictions preserved (A1–A5, §5) | `terrain_donor_gen.gd:1473-1519` (A1 single-attempt patterns via family roulette), `:1602` (A3 lake_big literal zero via `C_LAKE_ZERO :221`), `:823-831` (A4 editor-only postprocess skipped), `:1815-1818` vs `:1003` (A5 stage-specific clamp hooks) | IMPLEMENTED (labelled) | Each contradiction is preserved as donor-literal code or a labelled `[U]` hook, not "fixed". |
| Composer/seam integration (V36/V61/V65, outside §10 but load-bearing for execution) | `terrain_donor_world.gd:215-223` (`generate(_data, Dictionary)`), `:235-241` (`to_live()`→I08 `bind`), `:250-253` (`build(_data, stamps, {terrain:_mesh})`); `main.gd:125`, `:593`, `:1112`; `world3d.gd:118,:144,:624,:645` | IMPLEMENTED (static) / UNRUN | All six V61 API pairs PASS at final read; seam default `"legacy"` with both `make_world3d` sites guarded. No Godot parse/gate/run was performed by V80. `gen_params={}` (`:220`) supplies **no decoded donor inputs** — a data-completeness caveat, not an API break. |

---

## 2. Re-adjudication of the V58 FAILs / cliff stub / shore catch-all (current bytes)

The task asks specifically to highlight V58's 3 FAILs, the cliff stub and the shore catch-all. **All five are now IMPLEMENTED in the current tree**; none remains WRONG/STUBBED. This is a change of state since V58, and the current bytes (hash `29F5C727…`) were re-read twice each:

| V58 finding | V58 verdict | Current state (file:line, second-read) | Current status |
|---|---|---|---|
| **Item 3d** — `F01_GRID_OFFSETS` omitted `plt2=2222` / `k_ravine_big_stone_1=8225`, so `decode_pattern_grid("plt2")` always errored | FAIL | `terrain_donor_gen.gd:229-235` contains all five offsets; `:578-606` decodes them | IMPLEMENTED |
| **Item 7** — centre double-conversion: `_fill_ellipse` added `W/2` again; owner seeds double-added `+320` | FAIL | `_fill_ellipse :1454-1457` uses `cx0+xx` directly ("no second W/2"); `_to_scan :2168-2174` divides cells by 4 with no `+320` | IMPLEMENTED |
| **Item 9** — zero collision writes; I06 contract unmet | FAIL | `_collision_pass :1130-1170` called from `:1112`; `set_collision(i,0,tag)` at `:1164`, tag 87 on water cells `:1157`; metadata + telemetry `:1165-1170` | IMPLEMENTED (cliff tag remains `[U]` hook, deliberately not invented) |
| **Additional B** — `_cliff_tile_name` stubbed to hardcoded `"rock4"` | STUBBED | `_cliff_tile_name :1246-1292` implements six first-match `pre` windows + live `\|h\|` overrides; `:1260-1281` maps rock7/1/3/4/8 | IMPLEMENTED |
| **Additional C** — `_shore_tile_name` `%8` wrap lost the `bRT` catch-all (X28 vector 9) | WRONG | `_shore_tile_name :1204-1229` uses literal if/else windows with `sname="bRT"` unguarded (`:1221`) and `bLB,bRT→sandsea5` (`:1240`) | IMPLEMENTED |
| (bonus) **Item 3 precision caveat** — default `double_store_f32` not bit-exact | caveat | `:257-260` default `f32_each_op`; `_pf :1832-1838` rounds each op | IMPLEMENTED |

V58's 6 PASS items (RNG, mask height, smoothing constants, water levels, tile 3-pass, forbidden constructs) remain PASS at current lines: `:95-116/:355-377`, `:903-911/:1092-1094`, `:142-152/:956-1003`, `:122/:156-158`, `:166/:1295-1330`, `:444/:459/:831`.

---

## 3. Remaining WRONG / STUBBED / MISSING that still block parity

No `WRONG` fact was found in the current bytes for the spec/02–§10 load-bearing list. The following `STUBBED`/`MISSING` items are the **actual** remaining blockers; none is a parity claim:

1. **HIGH — I09 Objects feed not wired** (`terrain_donor_props.gd:59-60`, `:532-606`). `FEED_LIB_INDEX` is absent on disk; `FEED_FAMILY_INDEX` is a 55 MB metadata file whose top-level `families` is a **list**, but `_try_feed` reads it only when it is a `Dictionary` (`:561`). Result: no forest/stone/mine/swamp/lake transforms reach the instancer; only the Z08 mountain fallback can map (22/45 sid mappings). The real donor `Objects[]` arrays now on disk under `assets/terrain_new/patterns/families/*.json` have no loader. Four stale UNVERIFIED labels (`:153,:154,:167,:172`) assert causes that are now false. **This is the single change most needed to turn props from zero to donor-record-driven** (V59 items 3/4, high handoffs 1–2).
2. **HIGH — decoded donor inputs not passed to I07** (`terrain_donor_world.gd:220` `gen_params={}`; I07 `:443-446` notes PORT placeholder keys). Decoder outputs exist (`constants.json`, `cfg/manifest.json` 19/19 + 7/7 checks, atlas manifest 124 ids, 22 chains) but the composer does not pin `randkey0/1`, `mapsize`, `families`, `patterns`, `tile_name_to_id`, `tile_smooth_chains`, or starts into the Dictionary. Consequently tile smoothing is skipped at runtime (`:1076-1077`), mines have no `families` (`:1919-1922`), and starts are absent (`:1419-1420`). Static API PASS ≠ data completeness (V61 Q1, V65 §9 item 2).
3. **HIGH — no donor GPU A/B frame exists.** Every verdict here is a structural/source audit. The whole charter's parity gate (CHARTER.md:43-44,122-135) remains open; nothing in this matrix certifies visual parity.
4. **MED — bsmooth radius-3 native kernel** (`terrain_donor_gen.gd:282`, `:964-969`) is a labelled `[U]` skip (D03 U3). Constants are correct; the kernel itself is STUBBED, permitted but still a gap in the smoothing chain.
5. **MED — I09 rotation convention for the 49-node field lattice** (`terrain_donor_props.gd:356-357`) is a 90° mirror of X22's `rotate_y_45`; donor `VectorRotateY` sign is `[U]` (V59 P6, handoff 4).
6. **MED — `[U]` hooks still unresolved** (I07 `:249` key-state edge XU5, `:265-267` row sign / rotation rounding / global setter clamp, `:298` cliff collision tag, `:304` non-640 scan-grid mapping). Each is a labelled hook with no invented value — no `WRONG`, but parity cannot be asserted until resolved.
7. **LOW — runtime-not-wired field sowing / mill triggers.** The sow hook (`gen.gd:549-571`, `:609-621`, props `:343-376`) is correct as `UNIT/BUILDING EFFECT — NOT A GENERATION STAGE`, but no mill-trigger caller is wired; four stale UNVERIFIED labels in I09 (`:158-163`) legitimately mark missing converted assets (rus/tur mills, winter crops, pumps, `.oss/.aaf`).
8. **LOW — `water3d.gdshader` fade constants** (`water3d.gdshader:35-43`) are declared as undefaulted uniforms with donor values only in comments; runtime binding is `[U]`. Blend-pass count is a `0` UNSET sentinel in the terrain shader (`:140-143`).

**No parity claim.** `IMPLEMENTED` in this report means "the donor-grounded fact is present at the cited file:line and survived a second read" — nothing more.

---

## 4. Summary

- Spec/02–§10 load-bearing facts audited: **56 rows** across 10 spec sections (7/6/6/6/4/11/5/4/7 for §02–§10).
- Status distribution (matrix rows, not files): **IMPLEMENTED 47** (several carry explicit `[U]`/`PORT APPROX`/`UNRUN` qualifier text but no STUBBED sub-part) · **IMPLEMENTED with a STUBBED sub-part 6** (bsmooth r3 kernel; runtime chain/families feed; field-sow trigger; I09 Objects feed; placement metadata-only) · **IMPLEMENTED-static/UNRUN 2** · **STUBBED (blocks parity) 1** (I09 Objects feed as a standalone row) · **MISSING 0 · WRONG 0**. No stub is an invented constant or a silent spec violation.
- V58's 3 FAILs + cliff stub + shore catch-all: **all five IMPLEMENTED in current bytes** (§2); the precision caveat is also closed.
- Principal parity blockers are integration/data-wiring (§3 items 1–3), not algorithmic divergence in the generation core.

*End of V80. Exactly one repository file written. Read-only; no code, shader, asset, config, test, manifest, queue, app byte, git state, Godot job, runner job or donor binary touched. NO DONOR PARITY CLAIM — parity remains UNVERIFIED.*
