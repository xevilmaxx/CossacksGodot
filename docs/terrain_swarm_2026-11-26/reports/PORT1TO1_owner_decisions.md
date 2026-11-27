---
id: PORT1TO1-OWNER-DECISIONS-2026-11-26
title: "Definitive owner-decision register — full 1:1 Cossacks 3 donor port (P0/P1 blockers + preserve-only choices)"
worker: OWNER-DECISIONS (read-only subagent)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md]
files_edited: []
scope_guard: "Repo file/line reads only. No source, shader, config, asset, test, manifest, queue, result JSON, backup or git mutation; no Godot job, no gate, no capture, no donor binary executed/copied/patched; no donor target opened by this worker. Exactly one repository file written: this report."
labels: [O, D, I, U, "PORT APPROXIMATION", "PRESERVE-ONLY", "NO_PARITY_CLAIM"]
parity_status: UNVERIFIED
parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
canonical_sources:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md (P0-1…P0-8, §§1–6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§6 blocking table, §7 preserve checks, §9 verdict template)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_water_capture.md / _runtime.md / _fbo.md / _mesh_uv.md / _scalar_select.md / DEC_U_hmap_identity.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_grid.md / _persist.md / _tint.md / _knobs.md / DEC_U_fog_camera_hud.md / _fog_territory.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tick_order.md / _tick_driver.md / DEC_U_skirmish_tables.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_op.md / _aaf_triggers.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md / _float.md / _bits.md / _tobj.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_rng_ledger.md + X21_rng_vectors.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_selection.md / _camera_projection.md / _gl_perspective.md / _collision_full.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_capture_state.md / _capture_state2.md / _capture_flush.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_port_guard_audit.md §3 / V102_final_blockers.md / V109_owner_answer_final.md
---

# PORT1TO1 — definitive owner-decision register (2026-11-26)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Bottom line (do not quote selectively)

- **Every decision below is an owner/COORD decision, not a worker decision.** A worker may run a cited `STATIC` read; the `RUNTIME` and paired-save/hash batteries are forbidden to workers under the 2026-11-26 charter (donor read-only, never executed; no GPU frame; no Godot/gate by analysis workers).
- **No item is settled by a port fallback, a "close" value, a still, a metric, or a green-looking test.** Each item terminates only on its named **zero-mismatch** criterion (identical bytes/ticks/pixels/cells, 0 differing elements, with the minimum repeats stated).
- **No port change in this register has been applied by this worker.** The "outcome → port change" column is a conditional instruction for owner/COORD, to be fired only by its own zero-mismatch capture. Unresolved items keep their current labelled hard-fail / provisional / PORT APPROXIMATION behaviour.
- **Parity stays `UNVERIFIED`, `parity.claim = NONE`.** No donor GPU A/B frame exists; no donor binary was executed. `blocking_unverified` is non-empty (no D1/D3 dump, no admissible capture, stale gate JSONs, dirty runner) ⇒ conservative owner verdict **`RESULT IS NOT GOOD`** (`PORT1TO1_PLAN.md:36`, `V15 §2`, `V21 D-6`, `V57`, `V81`, `V105`, `V109 §1/§6`, `PORT1TO1_acceptance_plan.md §9`). Even if every gate went green, the best honest outcome would be "gates green / internal consistency PASS / donor parity UNVERIFIED". Tails are explicitly NOT blocking and must never be promoted to close a P0.
- **This register does not advance any tier.** V15 three tiers only: tier 1 DONOR-GROUNDED STRUCTURE VERIFIED (needs D3 dump integrity), tier 2 SELF-CONSISTENT VISUAL / PORT APPROXIMATION (needs admissible windowed capture), tier 3 UNVERIFIED. Tier 2 never implies tier 1; no tier above 2 exists.

**Settle class used below:** `STATIC` = closable by text/byte re-read, no donor execution; `RUNTIME` = owner-authorised donor GPU/runtime session or fixed-seed/paired-save harness; `OWNER POLICY` = cannot be closed by any capture (manifest/config/file-presence decision).

---

## 1. Water — P0-1 (U12), P0-1b (U4*), P0-2 (U1/U3/U5/U6)

All water rows are `RUNTIME`. Zero-mismatch rule throughout: identical tuple across **≥2 water-visible frames + 1 camera move (level → pitched)**, all tagged with the same Phase-1 PATH; a mismatch, a missing dump or PATH mixing leaves the item `[U]` and the port hard-fail intact. Full pinned VA/breakpoint table: `DEC_U_water_capture.md §2`; one-session ordered plan: `§3`; sentinels: `§4`; termination: `§5`; outcome→port matrix: `§6`; hard-fail matrix: `§7`.

### W-U12-A — reflection provenance
- **Exact question:** Is the live `reflectionMap` texture an FBO colour attachment, a post-main-scene framebuffer copy, or a static upload? Which GL target/name, and is it the same object as `DiffuseWaves2`?
- **Evidence id:** `DEC_U_water_capture.md` §2 U12-BIND/U12-PROV, §3 Phase 2 steps 9–10, §5; `DEC_U_water_fbo.md §5/§8`; FBO names `ev_c380…`, copy thunk `ev_8096…`; register `DEC_U_final_register.md` W-U12-A.
- **Precise experiment:** Break the reflection gate in `FUN_00856530` and binder bit 7c.01 in `FUN_00854054`; hook `glUniform1i(reflectionMap)` → record unit `u = C+0xf8`; trace `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture(target,name)`; record texture object `C+0x4c` and GL id `[C+0x4c+8]`. Whole-frame API trace: every `glGen/Bind/FramebufferTexture2D/CheckStatusEXT` with texture-name args; every `glCopyTexImage2D`/`SubImage2D` (thunk `0x4afb3c`, call `0x4ed44c`, hits `0x581444/0x582b56/0x5db443/0x81e66d`) with dst name + src rect; every `glTexImage2D` upload; `GL_FRAMEBUFFER_BINDING` at bind; `wglMakeCurrent/wglCreatePbufferARB/wglBindTexImageARB` sweep.
- **Termination:** `name` seen as FBO attachment ⇒ class (b); as copy dst after main scene ⇒ (a); upload-only ⇒ (c). Unanimous class across 2 frames + camera move.
- **Outcome → port change:** (b) after `bind_height_grid` success in `_make_water3d` (`world3d_terrain.gd:1099`) call `bind_reflection_map(<captured Texture2D>)` at captured `(w,h)`/unit/matrix; extend `_finalize_water_node` (`water3d.gd:520-527`) to require texture+unit+matrix; replace `water3d.gdshader:290-293,362-378` screen-`gl_FragCoord` scaffolding with the projective path. (a) same but Texture2D wraps the captured copy-dst updated after the main scene (captured src rect + pre/post FBO binding). (c) bind the captured uploaded texture by `(name→art, w, h, unit)`; U12-S decides shared vs separate sampler; no per-frame refresh.
- **Why read-only cannot settle it:** provenance is a runtime GL object history. The donor scripts are `;`-prefixed intent (`X27 §4`, 972 excerpts) and contain no FBO/copy/upload resolution; the shader-side transcription (`X11 §4`) proves equations, not binding source. Only a debugger + GPU trace inside an owner-launched donor process can classify `name`. No such trace was taken; capturing one is forbidden to workers.

### W-U12-B/C — size, mips, sampler state, unit
- **Exact question:** What `(w, h, internal_format, min/mag_filter, wrap_s/t, mip_state, unit u, C+0x4c↔name)` does the live reflection sampler use?
- **Evidence id:** `DEC_U_water_capture.md` §3 step 11, §5; `DEC_U_final_register.md` W-U12-B/C.
- **Precise experiment:** At the U12 bind break, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})`; read `GL_GENERATE_MIPMAP`/`glGenerateMipmapEXT`, `MIN/MAG_FILTER`, `WRAP_S/T`; hook `glUniform1i(reflectionMap)` for unit `u = C+0xf8`; check `C+0x4c/[C+0x4c+8]` agreement with `name`.
- **Termination:** captured tuple identical, **0 mismatches**, 2 frames + camera move; no assumed `0/1/2` sampler alias.
- **Outcome → port change:** import the captured target, size, format, filter/wrap, mip state and unit into the binder; any earlier assumed unit is retired. `water3d.gdshader` sampler declaration follows the captured `target` (e.g. rectangle vs `GL_TEXTURE_2D` changes sampler type).
- **Why read-only cannot settle it:** ctor defaults (`C+0xd8 = 0xde1`, `C+0xf8/+0xfc/+0xdc` units) are readable as static `[O]` but their **live** values and the texture identity are GL runtime state; `X17`/`X11` never observed a compiled path consuming them.

### W-U12-T — projective matrix + viewport
- **Exact question:** What 4×4 reflection matrix (from `FUN_004cdd9c(...,0x60,...)`, applied by `FUN_0085756c`) and what `glViewport/glScissor`/FBO binding accompany it, level vs pitched?
- **Evidence id:** `DEC_U_water_capture.md` §2 U12-MAT, §3 step 12, §5; `DEC_U_final_register.md` W-U12-T; `ev_2b51…`, `ev_0348…`.
- **Precise experiment:** Exec-break `FUN_0085756c` entry/exit + `FUN_004cdd9c`/`FUN_004cdbdc`; dump the 4×4 at caller `+0x60`; trace `glViewport/glScissor` and `GL_FRAMEBUFFER_BINDING` immediately before/after; repeat level-camera and pitched-camera; cross-check `glUniformMatrix4fv` if also uploaded. **Do not** reuse `cameraModel` (shadow-gated 0x8542d2) as the reflection matrix.
- **Termination:** self-identical per pose, 2 frames per pose + pose change; **no `*0.5+0.5` bias invented**.
- **Outcome → port change:** replace the screen-UV bias in `water3d.gdshader` with the captured projective matrix + viewport; carry per-pose values, not an averaged matrix.
- **Why read-only cannot settle it:** the matrix is computed and uploaded at draw time; decomp localizes the call but cannot yield the numeric 4×4 or viewport without executing the donor frame.

### W-U12-S/P — waves alias / pbuffer path
- **Exact question:** Is `DiffuseWaves2` the same texture as the reflection map, and is any pbuffer/`wglMakeCurrent` path used?
- **Evidence id:** `DEC_U_water_capture.md` §3 step 13, §5; `DEC_U_final_register.md` W-U12-S/P; FBO/pbuffer name sweeps already logged as negatives by workers.
- **Precise experiment:** correlate the bound reflection `name` against every `DiffuseWaves0/2` upload name; sweep `wgl*`/`pbuffer*` for one frame.
- **Termination:** distinct-vs-identical verdict; a null pbuffer result retires the hypothesis.
- **Outcome → port change:** one shared sampler vs separate samplers in the water shader; no pbuffer emulation code if the sweep is null.
- **Why read-only cannot settle it:** texture-name correlation exists only in a live upload list; the static name tables (`ev_6eec…/ev_711e…/ev_c380…`) give names, not binding identity.

### W-U4* — construction scalars (P0-1b)
- **Exact question:** Are the live water scalars (`C+0x88..+0xc4`, Speed `+0xc4=1.0`) the ctor defaults or the `water.lib` layer values, and is the selection a single layer-pointer branch or a per-scalar mix?
- **Evidence id:** `DEC_U_water_capture.md` §2 U1-INIT, §3 step 22, §5; `DEC_U_water_runtime.md §5`; `DEC_U_water_scalar_select.md`; `PORT1TO1_acceptance_plan.md §6 P0-1b`; `ev_67a5…`/`ev_513e…`/`ev_5aae…`.
- **Precise experiment:** break `FUN_00851bdc` (`0x851bdc`) entry; record `param_2` layer pointer (**0 ⇒ ctor path `FUN_00856080`; nonzero ⇒ copy path `FUN_00852f5c`**); at `0x852f5c`/ctor exit dump `C+0x184/+0x188/+0x190/+0x191/+0x1a8`, `C+0x68..+0xc4`, `C+0xc4` (Speed). Ctor tuple `0.4/0.3/4/.1/.5/1/.05/2/.01/.4/.825`, `+0xc4=1.0`; layer tuple `1/1/1/1/1/0/0/1/1/0.1/0.01`.
- **Termination:** `(param_2 == 0 ?, C+0x88..+0xc4)` matches **exactly one** of the two tuples; single branch, no per-scalar mixing; 1 construction + 1 draw.
- **Outcome → port change:** pin the scalar table to the observed path and **assert it in `t_water.gd`** instead of silently supporting both; keep the `[U4*]` gate (`cap_fullport7`) until then. Wrong source ⇒ wrong water colour/phase; until captured, no water may be scored.
- **Why read-only cannot settle it:** both tuples are readable `[O]`, but which one the shipped map actually consumes is a live layer-pointer branch; no donor run observed it. Choosing either would be an invented constant selection.

### W-U1 — live shader path
- **Exact question:** DEV file pair vs BUILTIN embedded pair vs FIXED legacy: which program is compiled and bound, and under which globals (`C+0x184`, `[0x8fc6b8]`, `FUN_00855fe8` globals `0x8fcdb0/0x8fbd28/0x8fc748`)?
- **Evidence id:** `DEC_U_water_capture.md` §2 U1-SEL/U1-COMP, §3 Phase 1 steps 4–8, §5; `DEC_U_water_runtime.md §4`; `ev_8218b0f1…`, `ev_a66a956…`, `ev_5dc9…`, `ev_ce22…`.
- **Precise experiment:** break `FUN_00851bdc` (layer ptr), `FUN_00855b38` entry/exit (program `P=C+0x50`, link via `FUN_004c0eb4`), `FUN_00856530` (single-step the two-flag test at `0x856530`, arms CUSTOM `0x8565d2` / BUILTIN `0x856897` / FIXED `0x856846`). Hook `glShaderSource` and dump both source texts; `hmapTex` ⇒ DEV, `alphaDepth`+`deepColor` without `hmapTex` ⇒ BUILTIN, neither ⇒ FIXED. Hook `glGetUniformLocation` for the 30 queried keys (mask `0x3FFFFFFF`).
- **Termination:** `(PATH, C+0x184, [0x8fc6b8], P, source hash)` identical 2 draws + camera move; all later dumps carry this PATH.
- **Outcome → port change:** BUILTIN ⇒ keep `water3d.gd:163` + `water3d.gdshader:102` as `[D]`, keep DEV/LEGACY selectable but unreachable, proceed to U12/U3/U6 under BUILTIN. DEV ⇒ flip default only with captured `(P, source hash)`, wire `hmapW/H/Min/Max + hmapTex + cameraModel(textureMatrix[3]·cameraModel·modelView)` per `water.dev.vert:14-17`; U3/U6 become draw-load-bearing. FIXED ⇒ retire both variants, implement legacy `glMatrixMode/glLight` only, mark U3/U12 N/A with reason.
- **Why read-only cannot settle it:** the selector is native CODE and the shipped config predicts `C+0x184=0`, but a predicted sentinel is not an observation; only a breakpoint + shader-source hook yields the live program and path tag.

### W-U3-NUM — hmap numerics
- **Exact question:** What are the live `(hmapW, hmapH, hmapMin, hmapMax)` and gate values (`C+0xe0`, `[C+0xe0+8]`) at the binder rows 7e.10–7f.1?
- **Evidence id:** `DEC_U_water_capture.md` §2 U3-NUM, §3 Phase 4 step 18, §5; `DEC_U_water_runtime.md §6`; `DEC_U_water_mesh_uv.md §5`; `ev_ada1…`, `ev_ab75…`.
- **Precise experiment:** break at each hmap row push; record `C+0xd0`(W), `C+0xd4`(H), `C+0xe4`(Min), `C+0xe8`(Max), gate `C+0xe0`/`[C+0xe0+8]`; walk one level `h=FUN_00739bf8(layer)`, `C+0xe0=FUN_0082f86c(*(h+0x200))`, Min/Max via `FUN_0082f060/0082f114` and record pointers.
- **Termination:** same 4-tuple, **0 differing bits**, 2 frames + camera move; a closed gate voids the frame.
- **Outcome → port change:** replace `map_size/±2.96` (`water3d.gd:489-511`, shader `:77,126-129,168-171`) with captured `(W,H,Min,Max)` as required explicit params; delete the `map_size/128` divisor-basis note.
- **Why read-only cannot settle it:** the numeric values are engine state computed at runtime from the height object; no donor text prints them, and the port's `±2.96` is a labelled approximation (`DEC_U_hmap_identity.md`), not a donor claim.

### W-U3-TEX — hmap texture identity
- **Exact question:** What is the live `(target, name, w, h, provenance)` of `hmapTex`, and what unit (`C+0xdc`) / target (`C+0xd8`) bind it?
- **Evidence id:** `DEC_U_water_capture.md` §2 U3-TEX, §3 step 19, §5; `DEC_U_hmap_identity.md` (preserve BUILTIN default + U12 hard-fail); `ev_5aae…`/`ev_ada1…`.
- **Precise experiment:** `glActiveTexture(GL_TEXTURE0+C+0xdc)` + `glBindTexture` + `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})`; classify `name` as FBO attachment vs copy dst vs upload exactly as Phase 2.
- **Termination:** `(target,name,w,h)` 0-differing + unanimous provenance, 2 frames.
- **Outcome → port change:** replace the decoded-grid `height_tex`/`hmapTex` alias with the captured `(target,name)` import; retire the LEGACY-only alias unless U1=DEV/LEGACY. **Do not** call any `bind_engine_hmap()` with a non-captured texture, and **do not** flip the BUILTIN default or U12 hard-fail to "make hmap appear" (`DEC_U_hmap_identity.md §5`).
- **Why read-only cannot settle it:** texture identity is a live GL object; the port currently aliases a decoded grid, which the hmap-identity report explicitly labels as a stand-in.

### W-U5 — `time` writer
- **Exact question:** Who writes the double at `C+0xc8`, and is the live `time` uniform constant zero or animated? Formula `time = (float)(double[C+0xc8]*double[C+0xc4])` is proven; the writer is not.
- **Evidence id:** `DEC_U_water_capture.md` §2 U5-TIME, §3 Phase 5 step 21, §5; `DEC_U_water_runtime.md §5.3`; `DEC_U_water_mesh_uv.md §6`; `ev_84eb…`.
- **Precise experiment:** hook `glUniform1f(time)` over ≥3 frames spanning ≥2 s; if non-constant, set an 8-byte HW write-watchpoint on `C+0xc8` and record firing EIP/disassembly → nearest symbol; verify formula reproduces the uniform with **0 ULP error** and `C+0xc4 = 1.0` (Speed).
- **Termination:** (a) all samples `0.0` + watchpoint silent over a 10 s window; or (b) one writer EIP every frame, 0 missed frames, formula 0 ULP.
- **Outcome → port change:** (a) freeze `time = 0.0` in `water3d.gd:229/250-251`; (b) replace `_time += delta` with the captured writer; keep `time = float(double[+0xc8]*double[+0xc4])` in comment + the uniform name (`shader:78,177,248`). `_time += delta` / wall-clock / frame-count may never be presented as donor.
- **Why read-only cannot settle it:** a writer is a runtime memory event; static re-reads found the formula and the ctor zero but no writer. A write-watchpoint requires an executed donor process.

### W-U6-UV / W-U6-WIND — mesh UV dividend and winding/cull
- **Exact question:** Per-vertex dividend behind `MultiTexCoord0/(hmapW,H) − 0.5`, and the exact index order / diagonal / `GL_CULL_FACE`/`GL_FRONT_FACE` state of the water grid.
- **Evidence id:** `DEC_U_water_capture.md` §2 U6-MESH, §3 Phase 3 steps 15–17, §5; `DEC_U_water_mesh_uv.md §4/§4.3`; `ev_0510…`, `ev_74d8…`, `ev_f2c0…`, `ev_31d8…`.
- **Precise experiment:** break vtable `+0x98` from `FUN_00826b30` for one 2×2 field; dump `MultiTexCoord0` (4 float32 verts), element/index array (6 indices) or `glDrawArrays` first/count, `hmapW/H` uniforms from the same frame, and `glGetIntegerv(GL_CULL_FACE/GL_FRONT_FACE)` + `glFrontFace/glCullFace` trace. Compute `uv_pred = attr/(W,H) − 0.5` (donor-verbatim `-0.5`, `water.dev.vert:14`) and compare to VS `gl_TexCoord[1].xy`; compare index order to port `0,3,1 / 1,3,2` (`water3d.gd:475-480`).
- **Termination:** `max|uv_pred − uv_actual| == 0.0` bit-exact on all verts, ≥2 fields + move; index sequence 0-differing elements, cull state identical 2 frames.
- **Outcome → port change:** set the dividend domain (`water3d.gd:432-438/466-480`) to the captured domain with verbatim `/(hmapW,hmapH) − 0.5`, divisor from captured U3-NUM **never** `map_size`; set indices (`water3d.gd:475-480`) and `render_mode` (`water3d.gdshader:37`) to the captured order/cull; record the diagonal.
- **Why read-only cannot settle it:** the vtable call site is static `[O]`, but the attribute/index arrays and GL cull state exist only in a live draw; `fract(world*0.5)`, `(x+0.5)/w`, grid-derived dividend and invented index order are on the hard-fail forbidden-substitute list (`§7`).

### W-R1 — renderer residual (P1, feeds water/terrain pixels)
- **Exact question:** Live terrain material floats, light position + modelview, alpha arithmetic/fog/`glCallList` count at GL upload. Slot→enum maps are `[O]` (U4 enum `tiaAlphaFromIntensity=1`, U6 ENABLED, U9 one-list-per-cell, U10 `0x48→0x50`); arithmetic and uploads are `[U]`.
- **Evidence id:** `DEC_U_final_register.md` W-R1; `DEC_U_renderer_residual.md §§3–7`; `DEC_U_scenecolor_glstate.md`; `DEC_U_alpha_pass_quad.md` (U4b upload probe §3.3); `X17_blendfunc_verification.md`.
- **Precise experiment:** probes P-MAT/P-LIGHT + the U4 GL-upload byte dump (dump the uploaded texture bytes; closed form or byte-exact 256-entry LUT, four sentinels) + `glCallList` dispatch count per cell.
- **Termination:** zero-mismatch byte dumps; residual tails stay `[U]`.
- **Outcome → port change:** import captured upload floats/enums; the port's `rgb *= mask` remains a labelled PORT APPROXIMATION until the alpha-converter probe closes (`X17` confirmed `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)` but not pass count).
- **Why read-only cannot settle it:** upload values and pass counts are GL runtime events; text-side `bmTransparency` semantics do not reveal how many passes were issued.

---

## 2. FOW — P0-3 (grid a–e, occlusion, persistence, tints)

### F-GRID-a — cell size
- **Exact question:** How many FOW cells per map tile / how many world metres per FOW cell, i.e. what is the scale `k` from `_unit_GetVision`'s scalar `res` to world distance?
- **Evidence id:** `DEC_U_fow_grid.md §4/§5 E-GRID-a`; engine entry points `ev_ae7d0838…` (`FOWEnable`, 3 CODE hits) and `ev_4f7e8d64…` (`GetFOWLOSData`, 1 hit); negatives `ev_be8575b2…`, `ev_f476d160…`, `ev_d8078025…`; `DEC_U_final_register.md` F-GRID-a.
- **Precise experiment:** one peasant, `vision` 0/3/8 (predict `res` 20/32/52) plus `map_revealZone` radii 10/20/30 (predict `floor(dx)`); dump `GetFOWLOSData(x,z)` on two perpendicular 1.0-unit transects, then a 0.25-unit fine transect across the predicted edge.
- **Termination:** all six radii fit one linear scale `k` with **0 mismatching cells**; fine pass shows a single stable step width equal to the cell size, 0 off-step cells.
- **Outcome → port change:** replace `_vision_radius_m` (`world3d_fog.gd:480-486`) `return float(res)` with `float(res)*GRID_K`, add `DONOR_FOW_METRES_PER_RES := <k>` / `DONOR_FOW_CELL_M := <step>` with experiment id; mirror the scale into reveal-site loops `:327-337/:361-370`. If `res` is in map tiles, convert via `Data.TILE_M`. Never hard-code 1.0/2.0/`53.333`.
- **Why read-only cannot settle it:** no readable file quantises world→grid (`§3`), and the port's `1 res = 1 metre` is an explicitly labelled provisional; `gc_pixels_to_tile=53.333` is a render/tile constant, never cited as FOW grid.

### F-GRID-b — multi-viewer combine
- **Exact question:** max / Boolean-OR vs sum-then-threshold vs per-team channels?
- **Evidence id:** `DEC_U_fow_grid.md §4/§5 E-GRID-b`; `DEC_U_final_register.md` F-GRID-b.
- **Precise experiment:** overlapping-disc transect through two identical peasants; three co-located viewers removed one at a time with `FOWBuildFull` between removals; ally vs enemy viewer split for player 0's `GetFOWLOSData`.
- **Termination:** union-shape match + removal sequence (Boolean-OR or stated threshold N) + ally/enemy split, **0 mismatching cells** across all three sub-runs.
- **Outcome → port change:** OR/max ⇒ keep `fog_counts[i] > 0` (`:374`) and re-label the `[U]` comment as grounded-OR; threshold/per-team ⇒ replace the single `fog_counts` accumulation (`:339,355-359,361-370,374`) with the fitted operator, leaving `fog_explored` sticky logic untouched unless F-GRID-d says otherwise.
- **Why read-only cannot settle it:** `_unit_GetVision` returns one scalar per object; no accumulation operator exists in readable text — it lives behind engine VA `0x6a8412`.

### F-GRID-c — LOS occlusion
- **Exact question:** Pure radius disc, or height/forest/building/wall blocking with a slope/threshold; does fogreveal occlude too?
- **Evidence id:** `DEC_U_fow_grid.md §4/§5 E-GRID-c`; `unit.script:5519` `CheckVisibility` comment marks the consumer engine-side; `DEC_U_final_register.md` F-GRID-c.
- **Precise experiment:** fixed E-GRID-a geometry; interpose in turn (i) a hill ridge, (ii) a forest block, (iii) a built wall/building row; control run on the same seed; dump the same transect each time; map any shadow edge at 1.0-unit steps and fit the blocker rule; confirm on a **second rotated transect**.
- **Termination:** cell-identical to control ⇒ pure disc (close as `[O]`-by-experiment); otherwise fitted rule predicts the rotated transect with **0 mismatches**. Never write a slope without that confirmation.
- **Outcome → port change:** pure disc ⇒ add one negative-result comment at `:355-359`, no code change; blocking ⇒ insert the fitted blocker test in the viewer-disc loop (`:355-359`, and `:366-370` only if fogreveal also occludes), using the port height/blocker grid actually present; `los_at` (`:533-544`) must keep reading the same grid the reveal pass writes.
- **Why read-only cannot settle it:** no height/forest/wall test exists in `unit.script:11563-11614` or `misc.script:5883-5944`; occlusion is engine-side, not text-recoverable.

### F-GRID-d — persistence
- **Exact question:** Sticky-explored vs visible-only, per-player vs global, and what `FOWBuildFull` / `ClearFOWPlayers` / victory / balloon clear.
- **Evidence id:** `DEC_U_fow_grid.md §4/§5 E-GRID-d`; `DEC_U_fow_persist.md §§2–5`; `DEC_U_final_register.md` F-GRID-d.
- **Precise experiment:** reveal a far probe cell, then (i) walk away beyond `res` + margin + `FOWBuildFull`, (ii) `_control_SetPlayer` round-trip (`ClearFOWPlayers` path), (iii) toggle balloon/victory gate; separately check the same probe cell after switching viewer to ally vs enemy; repeat the full matrix.
- **Termination:** all (i)+(ii)+(iii)+ally/enemy cells identical on **two repeats**, 0 mismatches; any flapping keeps `[U]`.
- **Outcome → port change:** sticky confirmed ⇒ keep `:375-376` and document per-player-vs-global; visible-only / trigger clears ⇒ change `:375-376` and wire `rebuild_fow_full` (`:523-530`) / `rebuild_fow_enable` (`:411-429`) to the discovered triggers.
- **Why read-only cannot settle it:** script shows only recompute triggers; stored-cell lifetime is engine-hidden. The 2D port's `fog_explored[i]=1` (`world.gd:2242-2243`) is PORT law, not donor evidence.

### F-GRID-e — `GetFOWLOSData` sampling
- **Exact question:** Point-sample vs cell-area; return domain `{0,1}` vs count; quantisation/threshold (only `>0` is grounded).
- **Evidence id:** `DEC_U_fow_grid.md §4/§5 E-GRID-e`; `control.script:270-273`; `DEC_U_final_register.md` F-GRID-e.
- **Precise experiment:** 0.25-unit fine transect across the visibility edge; log **raw** returns (not just `>0`); repeated dumps same tick (stability), dumps just inside/outside `tile_of` borders, any value >1.
- **Termination:** domain enumerated with **0 out-of-domain values** over the full transect ×3 repeats; edge cell matches the stated point/area rule with 0 mismatches.
- **Outcome → port change:** keep `los_at` `>0` predicate (grounded) in all cases; if domain is counts, expose a second accessor `los_count_at` without changing the veto; document point-vs-cell-area at `:533-537`; if boolean, re-label the comment only.
- **Why read-only cannot settle it:** one CODE string hit with no readable signature; script call sites use only `>0`.

### F-TINT — minimap/terrain never-seen, seen-now, explored tint
- **Exact question:** The RGBA/threshold/blend separating never-seen, seen-now and explored-not-visible minimap terrain cells, and `.sel` RGB / `Interval=50` unit gating.
- **Evidence id:** `DEC_U_fow_tint.md §0/§2.6/§4/§5/§6`; `DEC_U_fow_knobs.md` (`FOWColor` engine-default-only, zero script writers); `DEC_U_minimap_tail.md`; `DEC_U_final_register.md §5`.
- **Precise experiment:** F1-MINI-TINT-TERRAIN — mark three cells (never-seen, seen-now, explored-not-visible after walking away beyond `res`+margin); capture the 240² panel at native resolution + dump `GetFOWLOSData` at each cell centre; 3 fresh-seed runs at both DPI arms (viewer height above/below 1535). S2-UNIT-TAIL — separate fixed-camera capture for `.sel` name-swap and `Interval=50` gating (`.sel` RGB is baked inside `primitives.bmp`, never decoded to text here).
- **Termination:** three pixel sets pairwise disjoint, 0 misclassified samples across 3 runs × both DPI arms, per-cell reads match `>0` on every sample; report exact RGBA per set + separating threshold, or keep `[U]`.
- **Outcome → port change:** only after the capture, replace `hud.gd:2216-2218 ×0.25` never-seen dim and `minimap_fog_base/minimap_fog_rev` cache, and `world3d_fog.gd:118-120` alpha ladder `0.78/0.30/0.00` + shader `:240-258`, with the measured RGBA/threshold 1:1. Never port `FOWColor`/`FOWTextured`/`FOWSmooth`/`FOWLerpFactor`/`FOWDateTime` as grid law; never extend the `0.5` resource blend to units/terrain without F1-MINI-TINT-TERRAIN.
- **Why read-only cannot settle it:** full-file reads (P-B1…P-B7) found **zero** tint/threshold/blend literals for minimap terrain; `colors.lib` contains scene lighting fog only, `DynFogDepth=False` is visual depth fog, and the native render records (`TOSWFOWRender`/`XFOWRender`) expose no layout or colour. The port values are labelled PORT APPROXIMATION.

---

## 3. Native tick interleave — P0-4

### S-TICK-O1 — plInd rotation / firing rate / stage interleave
- **Exact question:** In what order does the engine visit players per firing (`plInd` rotation), at what rate, and how are global / per-player / unit / projectile blocks interleaved (including mod-cohort alignment and section micro-order)?
- **Evidence id:** `DEC_U_tick_order.md` U-O1a–g (EV-T1…T9); `DEC_U_tick_driver.md` U-D1–D9 (EV-D1…D12); `DEC_U_skirmish_tables.md §7`; `DEC_U_final_register.md` S-TICK-O1/S-TICK-O2–O6; `progress.inc:37` / `progressai.inc:4` are the only two `GetPlayerCurrentPlHandle` reads, **0 writers**.
- **Precise experiment:** fixed-seed hash harness (headless fixed-`dt`; canonical JSON state hash per tick/firing; **12 mixed players, 3600 frames, 3 seeds + restarts**). U-D1 rotation census: candidates (i) 1-per-frame round-robin ascending, (ii) all-players-per-frame ascending, (iii) section-budget-driven; log `plind` per firing. U-D2 rate census: idle + battle load, firings/player/100 frames, `lastprogresstime`/`progresstick`. U-D3 boundary-permutation harness: freeze each internally-`[O]` block (economy / scenario / paths / sections / player-slice / projectiles / cleanup / market / victory / AI), permute **only** boundaries.
- **Termination:** byte-identical hash sequences, **0 mismatches**; a single surviving order with losers listed; until then `TICK_ORDER v1` stays PORT APPROXIMATION. No binary-side scheduler trace was run by workers — U-D1/U-D3 name that as a possible future pass, not performed.
- **Outcome → port change:** adopt only the surviving rotation/rate/interleave in `game.gd:5178-5238 tick()` / `:5470-5475 _tick_players_slice` / `ai.gd`; append the U-D3 pointer to the comment block (`:5127-5177`) now, but **do not move** `_tick_players_slice` relative to entities/projectiles/market/victory until U-D3 settles a winner.
- **Why read-only cannot settle it:** internal stage orders are readable `[O]`, but the mutual order and the native driver are CODE-side with no script writer; the port's all-players-per-frame behaviour is a labelled substitute. Only a deterministic hash battery (owner/headless, no donor binary needed but a Godot/gate run forbidden to workers) can discriminate.

### S-TICK-O2–O6 — cadence edges
- **Exact question:** `floor` bank edge, capture jitter anchor, `not res` current-value read, `CheckProgress…` float-equality veto reachability, AI Econ-vs-War split (body order `[U]-A1`).
- **Evidence id:** `DEC_U_tick_order.md §3–§4`; `DEC_U_tick_driver.md §3 U-D4…U-D9`; `DEC_U_final_register.md` S-TICK-O2–O6.
- **Precise experiment:** fixed-`dt` sweeps + 200-capturer + shortfall-tick + phase-crafting batteries; U-D9: 1 AI vs 1 idle human, 600 s, log Econ/War entry per `lastprogressaitime` firing, assert the 2.4 s gate + adviser-only branch.
- **Termination:** 0 mismatches per battery; body internals stay `[U]-A1`.
- **Outcome → port change:** wire only the reproduced branch/order; never default to a plausible cadence.
- **Why read-only cannot settle it:** gate *expressions* are text-readable; branch reachability and A/B body order require executing the fixed-seed simulation.

---

## 4. Animation blend / completion — P0-5

### E-B1 — blend weight curve / support
- **Exact question:** `w(t)` over the blend window, its unit (frames/ticks/seconds), and per-channel application; `(minBlend,maxBlend) = (6,8)` installs vs forced `(0,0)` bypass.
- **Evidence id:** `DEC_U_blend_op.md §2 [U]-B1`, §6 R-B1; `DEC_U_aaf_triggers.md §6 [U]-B`; `DEC_U_final_register.md` E-B1; literals at `initial.inc:17-19`, `ontagstates.inc:351/355`.
- **Precise experiment:** peaukr `walk 1..20 → idle 64..113` seam stepped 1 tick/frame; log screen-space ankle-joint track or full-pose vertex hash for ticks `[-2,+10]` under `(6,8)` vs debug-forced `(0,0)`, varying only the tail pair.
- **Termination:** step-response length in frames + per-tick displacement table byte-identical **3/3** trials under each setting, **and** `(0,0)` trace equals the unsmoothed single-tick hard cut. Success bounds the **support only**, never names `w(t)`.
- **Outcome → port change:** only after R-B1 lands may interpolation be introduced in `anim3d.gd` (currently `requested_blend`/`blend_bypass` are intent-only with **no lerp/mix/slerp** on the pose path — keep that until then); the weight curve must still be a bounded, cited result.
- **Why read-only cannot settle it:** the operator is native engine code; only the literals and install/bypass sites are readable. A frame-index/vertex-hash trace requires a fixed-camera donor session.

### E-B2 / E-B3 / E-B4 — frame fetch, arg polarity, movie window
- **Exact question:** Which exported frames co-occur during a blend; meaning of `a3/a5/a6`, `CyclesList`, `acoSkipActions`; whether movie `0..5` applies to units.
- **Evidence id:** `DEC_U_blend_op.md §3/§5/§6` (R-B2/R-B3/R-B4); `DEC_U_final_register.md` E-B2/E-B3/E-B4.
- **Precise experiment:** R-B2 log `GetGameObjectFrameAnimationName/Data(sf,ef)` + displayed frame index per tick on the same seam; R-B3 differential sim-path (`a3=False`) vs aix-idle-shaped (`a3=True`); R-B4 `_movie_UnitPlayAnimation` with bBlend true/false.
- **Termination:** displayed-frame sequence byte-identical 3/3 (one divergent trial fails); identical-or-different verdict 3/3 with **no semantic name assigned** to `a3/a5/a6`; differ-or-identical verdict 3/3 for `"0,5"`.
- **Outcome → port change:** port fetches exactly **one nearest frame** until R-B2 lands; add a third `requested_blend` value `"0,5"` only if R-B4 says so (today only `"0,0"`/`"6,8"` exist).
- **Why read-only cannot settle it:** exported-frame co-occurrence and mode polarity are runtime values behind engine calls; no readable line names them.

### E-C1 / E-C2 — completion and handler timing
- **Exact question:** At the last frame under `acmPlayOnce`, does the pose hold, snap to idle, or freeze mid-blend; and when do damage/PFX/sound fire relative to `Attack` vs `AttackEnd` handlers? The `AttackEnd` **body is recovered** (`onaclanimationreachedattackend.inc:2-14`: `_unit_TryAttack` retrigger + `SwitchTo('Nothing')`); its firing tick is not.
- **Evidence id:** `DEC_U_blend_op.md §5/§6 R-C1/R-C2`; `DEC_U_aaf_triggers.md §6 R-C1/R-C2`; `DEC_U_final_register.md` E-C1/E-C2; `unit.script:10811-10815` four `''` clears (no armed completion handler).
- **Precise experiment:** R-C1 musketeer `attack1 [99,124]` single shot and peasant `death [115,149]`, 30 Hz trace `t0..t0+span+10`, record hold-at-last vs snap-to-`idle1 [256,305]` with tick numbers + vertex hash at last 3 ticks; R-C2 cannon `attack0/attack1 [301,337]`, log muzzle-flash PFX frame, damage tick, sound tick relative to the handler ticks.
- **Termination:** hold-vs-return verdict with tick numbers, 0 mismatch 3/3 per sid; effect-to-handler offsets 3/3, or absence logged.
- **Outcome → port change:** keep `anim3d.gd:726-739/746-760` clamp-at-last with `AAF_LOOP_STATUS [U]` and the **empty** completion hook (`:267`, `:1493` probe) until R-C1/R-C2 land; wire the hook ONLY then. Update the two status strings (`:175/:179`) to cite the recovered re-attack body + `[U]-C2` timing.
- **Why read-only cannot settle it:** completion action is engine-side (no non-empty handler in text); effect ticks are runtime events.

### E-W/W2/S/A/R — trigger gaps
- **Exact question:** `iWeapon`⇔`attack1/2` gating; `death0/1/2` by weapon; sticky animation-name readback (T18–T20); `prepare/trans/walkprepare` triggers; orphan `reaction` token (no constant, no site).
- **Evidence id:** `DEC_U_aaf_triggers.md §6 R-W/R-W2/R-S/R-A/R-R`; `DEC_U_final_register.md` E-W/W2/S/A/R; 59 `gc_anim_*` constants with **no** `gc_anim_reaction`.
- **Precise experiment:** fixed-camera batteries on musketeer/grenadier/peasant: log `iWeapon` (tag dump), `selected_anim`, frame index `0..span+2`; 90-tick name log for sticky dwell; stance/formation/mount order exercises for prepare tokens; full raid/death/combat/construct/idle-long-tail stimulus battery for `reaction`.
- **Termination:** `attack1 iff iWeapon=1` ≥3/3 per sid; `attack2before→after` on grenade order or logged absence; sticky name with dwell count or 3 clean seams; ≥1 reproducible trigger per family or explicit absence log. Absence is a **bounded** `[U]`, not an invented trigger.
- **Outcome → port change:** add/retire animation tokens and gating only from the observed verdict; `reaction` remains export-only if absence is logged.
- **Why read-only cannot settle it:** no `anim :=` site and no constant exist for these tokens; a trigger law cannot be recovered from text.

---

## 5. Save container / transform — P0-6

### S-SAVE-R1a…g — container, primitive widths, codepage, transform, victorystate, trailer
- **Exact question:** `.sav` outer container magic/lengths (`.map` `OSWMap13` wrapper is `[O]`); Single-vs-Double floats and Boolean `0/1`; string codepage/length unit; engine transform placement; `victorystate` int table + `TWall/Cluster/Cell`, `TGrid/ResGrid`, `TInterface`, `TScenario`, `TProj` tails; checksum/trailer.
- **Evidence id:** `DEC_U_save_contract.md §8 (E-R1a §1, E-R1b/§2, E-R1c §2, E-R1e §5)`, §9; `DEC_U_save_float.md §R1`; `DEC_U_save_bits.md §R1` (Boolean 1 B `[D]`, `.map` envelope `[D]`, TProj order `[O]`); `DEC_U_save_tobj.md`; `DEC_U_final_register.md` S-SAVE-R1.
- **Precise experiment:** owner paired-save batteries — (a) two saves differing only in `gfloat_peacetime`, hexdump first 256 B, assert first Int32 = current `gDataVersion` (92), identical tag bytes, first divergence at the field; (b) unit with `rallyx=1.0, rallyy=2.0`: assert `00 00 80 3F / 00 00 00 40` (4 B singles) vs 8 B doubles, Boolean `01/00`; (c) `fGroupName="Test"` vs `"Testé"`: byte-count vs char-count prefix and E9 vs C3 A9; (d) fresh / one-player-eliminated / battle-win: 3 distinct `victorystate` ints, stable mapping; identical-state re-save bit-compare for every case.
- **Termination:** single-field divergence asserted at the expected offset; **re-save byte-identical**; until then the contract is key-order parity + round-trip determinism only, never byte parity. **v5 wire unchanged.**
- **Outcome → port change:** additive-only keys in `game.gd:7097-7125` stay (no existing v5 key removed/renamed/version-bumped; restore `>= 5` at `:7193`); add `save_donor_version:92`, `save_framing:"serialized-set §1 order, JSON keys (NOT byte-parity)"`, `save_contract:"PORT EXTENSION, no byte-parity claim [U]-R1a..g"`; wire exact widths/transform/value tables **only** from paired-save results. Never invent a byte pattern.
- **Why read-only cannot settle it:** field *order* is readable from `write*.inc/read*.inc`, but widths, codepage, trailer and value tables require actual save files from an executed donor session; no donor binary was run and no paired saves exist.

---

## 6. RNG stream split — P0-7

### S-RNG-G1 — round(), S-vs-G streams, per-site counts, uniqrnd
- **Exact question:** Does the binary use Delphi `round()` Bankers; which draws come from the `RandomExt` S-stream vs the Delphi `Random` G-stream; what are the per-site draw counts; `uniqrnd`/`frnd` order; f32-vs-f64 promotion; signed-`key0` edge; AI/capture/economy attribution?
- **Evidence id:** `DEC_U_rng_ledger.md §3/§4/§5 G1a–g`; `X21_rng_vectors.md` 20-vector oracle; `DEC_U_final_register.md` S-RNG-G1; `ev_5dd2579d…`/`ev_ee039a9f…`/`ev_33572f0d…` (LCG bytes `0x60f64c–0x60f696`); `ev_54ac1f0c…` (5 instances).
- **Settled (do not re-open):** LCG `s←s·0xFC0D+0x3C6EF35F mod 2³²`, output `f32(s/2³²)`; `key0` discarded; `donor_round` is half-to-even (`data.gd:1206-1214`); per-site **order** `[O]`; `uniqrnd` spawn site `unit.script:2726`; X21 states `0x3C6FEF6C…0xA2C21855`.
- **Precise experiment:** fixed fixture seed `(key0=0x44A108F9, key1=0x00000001)` (synthetic, **not** a donor seed), `rng_model.py` + `test_vectors.json` as oracle, headless fixed-`dt`, canonical JSON state hash (players, entities, projectiles, stream counters, per-player deadlines, banks, `uniqrnd`, `lasttimecheckcapture`). Series **R20** (round ties), **L20** (20 S draws with `bits LE` + `floor(r×{3,5,10,256})`; G values count-only), **C300/U50/F1M/K0/A600**.
- **Termination:** full series run; **any single mismatch** keeps the item `[U]` and forbids wiring; 0 mismatches across the full series closes it. Exact S sequence must be `3C6FEF6C…A2C21855`; G **values** mismatch is not a failure (counts only); signed `key0` cases asserted without claiming donor behaviour (no donor run).
- **Outcome → port change:** keep `donor_round` and identity reseeds (`game.gd:310/319-321`) but drop the `[U]-G1` tag only on green; extend `data.gd:1636-1644` with per-row `stream` tags (S: `GetRandom/GetRandomRange/slow_death/guard_sampler`; G: `RandomInt`, `damage_headshot` gate; stored: `floor(uniqrnd*500)`) + cited consts; rewire `_misc_random_int` (`game.gd:5406`) from sim `rng` to the Delphi G stream when item 4 lands; add an S-wrapper `floorf(f32(rng.randf())*n)` for §4-S sites, never bare double. Port `rng`/`gen_rng` are Godot `RandomNumberGenerator`, **not** these recurrences — label PORT APPROXIMATION until wrapped.
- **Why read-only cannot settle it:** the LCG arithmetic is fully decoded, but *cross-stream attribution and live draw counts* need a deterministic replay; the headless harness is a Godot/gate run, forbidden to workers, and no donor run ever attributed a draw.

---

## 7. Selection / projection — P0-8

### E-U13-pick — distance units, sort order, engine AABB, FOW veto
- **Exact question:** Units/frame of the `(1+dist)/prio` metric (`dist` = XZ `VectorDistance` of `mpos` vs entity `pos`), the `SortRayCastList` key, exact-tie behaviour, engine AABB inside-test, and winner-only FOW veto.
- **Evidence id:** `DEC_U_selection.md §1/§2`, E-U13-pick capture (§2.2), port change R-SEL-1…10 (§5); `ev_2bf9d42c…` (`GameObjectSortRayCastList` 1 hit `0x69e4be`); `DEC_U_final_register.md` E-VIS/SEL, F-V1/V2.
- **Precise experiment:** fixed rig 58 m / −32° / focal 400, FOW off; place own peasant (prio 1), wood node (2), unbuilt building (6), attackable enemy (7) on one view ray within 1–2 px; log `GetCurrentMouseWorldCoord`, per-handle `_unit_GetGameObjectPos`, `GetGameObjectRayCastCount` + order after `SortRayCastList`, prio branch, computed `(1+dist)/prio`, returned `nearestHnd`; repeat FOW on with one zero-LOS winner; construct an exact tie (equal to 1e-6) and a seed-`0.5` probe.
- **Termination:** predicted winner matches the returned handle on **every** probe incl. exact-tie and FOW-veto, **0 mismatches**, before any unit/weighting/tie-break literal is written as donor fact.
- **Outcome → port change:** keep the `(1+dist)/prio` shape and `_closer` min-wins; change the `d` source from screen-px `sd` (`picking3d.gd:370`, `input_controller.gd:800-808`) to donor XZ metres after the capture; thread the `0.5` seed through nil arms (`R-SEL-1/6`); replace the 8-corner AABB approximation with the fitted inside-test (`:287-305`); conform per-candidate FOW veto to winner-only only if the capture changes membership — **never weaken to no-veto**; keep `BODY_LIFT_M/TIE_PX/FALLBACK` labelled PORT APPROXIMATION (`:45-51`) until then.
- **Why read-only cannot settle it:** the weighting *shape* is text `[O]`; `dist` units, `SortList` key and AABB predicate are engine-side (CODE-string-table placement only, explicitly **not** parsed as a call graph), so no read-only pass may invent them.

### V1-SENSOR / V2-PROJ / V2-DRAG / V2-BOX / V2-MINI — projection and marquee
- **Exact question:** Sensor width→FOV (port `17.27°` is APPROX); near/far/aspect (port `0.1/4096` APPROX); drag anchor (press-point vs first-move); marquee inside-test; minimap affine + frustum quad.
- **Evidence id:** `DEC_U_camera_projection.md §1–§5` experiments V1-SENSOR/V2-PROJ/V2-PROJ-DRAG/V2-BOX/V2-MINI, port change §6; `DEC_U_selection.md §3/§4`; `DEC_U_fog_camera_hud.md`; `DEC_U_final_register.md` F-V1/V2.
- **Precise experiment:** fixed 58/−32/400 rig; ≥5 surveyed ground markers at known separations/depths → solve projection and cross-check at focal-100 debug camera; push marker to 1199/1201 to test `DepthOfView=1200` clip; scripted LMB press + 1–3 px steps across the epsilon boundary in four directions; grid of peasants with rects inset/outset 1–3 px (both drag directions); minimap world corners + frustum quad at two camera poses.
- **Termination:** ≥5 surveyed points reproject to **0 px** mismatch and clip boundary exact; rect membership including 1-px edges **0 mismatches**; minimap affine/frustum 0 px on ≥5 corners.
- **Outcome → port change:** only after termination, replace `camera3d.gd:109` `FOV_DEG_ASSUMED=17.27` + `:112-113` `NEAR_M/FAR_M` and the mirrored `config.gd:75/464` defaults in the **same two files**; collapse the dual drag anchor in `input_controller.gd:693-705` only; swap the inside rule in `:711-742` only (all other camera pins 58/20/−32/400 are `[O]` and stay). No sensor width (216/36/121.4) may be written as donor fact — those are shadows derived from the port claim.
- **Why read-only cannot settle it:** the key and entry points are consumed in CODE (P5–P8 negatives + P9/P10/P16 positives) but their numeric law is absent from text; a pixel solve needs a real captured frame. `cull_disabled`, `nearest-single`, depth tie-break and screen-UV bias remain scaffolding.

---

## 8. Capture / garrison residuals — P1 (feed P0 behavioural reads)

### CS-VETO / CS-LEDGER / CS-GARRISON / CS-HIDE / CS-FOW / CS-RALLY
- **Exact question:** Does a live guard order block capture (donor: guard is a combat-assist order, never a capture predicate); any-protector veto + AI-artillery table; exact counter/score/grid deltas; mine-insider transfer vs port tower/centre garrison; birth/hide gates + order-strip skip; vision attribution + minimap/selection/highlight; rally retention.
- **Evidence id:** `DEC_U_capture_state.md §4–§7`; `DEC_U_capture_state2.md §2–§7 (CS-*)`, EV-S2-PORT/HIDE; `DEC_U_capture_flush.md §130` (Q-FLUSH-SEM); `DEC_U_final_register.md §3` domain E.
- **Settled text `[O]` (do not re-open):** absorber only peasants→mines and transports (`unit.script:10048-10056`); `DoHideInside` = `AddInside` + `FullClearOrders` + `visual_hide[+birth]` + scangrid/minimap remove (`:3087-3099`, `ontagstates.inc:851-901`); asymmetric score `5/3/2/1`; cadences 1.875/0.475 s; radii 214/160/426 px.
- **Port residuals (labelled, must NOT be donor-cited or deleted):** `guard-block`, `captured_nations`, tower/centre garrison (cap 10, `hidden`, `2×` fire, `2.0/s` heal, capture-halving, dies-with-building), `1×` score, `_default_rally` re-arm, `capture_t` rate law (`peas*1.0+sols*0.25`, `need=5+maxhp/2500`, decay). `DoHideInside` mine effects and the flush call with old-owner handle are not yet implemented (`Q-FLUSH-SEM` `[U]`).
- **Precise experiment:** fixed-seed (Seed S) traces ×3 runs — CS-VETO (guard live/no-protector, protector present, AI-artillery threshold table with `random>0.5` gate); CS-LEDGER (capture built mine with 3 insiders + barracks with queued produce×2/upgrade, dump full ledger tick-before→after + 3 ticks later); CS-GARRISON (3 peasants `DoHideInside` a mine then capture; separately `OrderGoInside` peasant→tower and `UnitsCanGoInside` tower, expect refusal with `file:line`); CS-HIDE (birth/hide gate cases, editor-only hidden-building strip-skip); CS-FOW (vision `20+4V`, scangrid, minimap, selection/ctrlgroup, key-colour, highlights); CS-RALLY (`STO/bRally/rallyX/Y` before/after).
- **Termination:** 3 runs identical per case with the divergent dump **quoted, not averaged**; insider `pl` = winner, `STO` = mine, `resincome` delta = `13×3` gold; tower case refusal quoted.
- **Outcome → port change:** gate `cmd_enter` (`game.gd:4305-4336`) on `_unit_CanGoInside` verbatim; keep tower garrison as `PORT_GARRISON (no donor counterpart; CS-GARRISON open)`; add missing per-insider `ScanGridRemoveUnit`+STO re-point only as `[U]-CS-GARRISON` (port has no STO/resincome field — state only the entity-list flip, **never invent STO**); add TODO block for unported ledger (`resconsume[6]`, `farmused+food 30`, `built/all/total`, `resincome ± produce×insideCount`, `artlimit/artcount`, `produced/killed` suppression). Keep `visual_parity_claim=false`.
- **Why read-only cannot settle it:** donor laws are text `[O]`, but the *live* state transitions, payees and engine repaint require a fixed-seed trace; no such trace was run by workers, and the port's garrison loop is a playtested invention that must stay labelled until CS-GARRISON passes.

### E-COLL / E-DMG/FF / E-WPN — non-P0 parity-invalidating `[U]` (no promotion by fallback)
- **Exact question:** per-sid radius/mask census + footprint rotation; LOS ray rule; ballistic integration/victim pick/FF gates/`PredictShot` (port currently fires where donor `stand` → no projectile + 1 s penalty — a known mismatch); shield/mount rows in live sim.
- **Evidence id:** `DEC_U_collision_full.md §1.4/§2.4/§9`; `DEC_U_damage_height.md U1–U8`; `DEC_U_ff_predict.md F4–F7`; `DEC_U_weapon_tail.md §5`; `DEC_U_final_register.md` E-COLL/E-DMG/FF/E-WPN/SHIELD.
- **Precise experiment:** STATIC census (`objprop.radius` overrides, 369-file `(nation,sid)→(w,h,rows)` dump, `Rotate/Reflect/tmoRotate` grep) + RUNTIME LOS ray battery on a rotated second transect; Series F1–F7 flat map 50–360 shots/cell fixed seeds; per-sid shield damage probe `dealt=max(1,indamage-shield-prot…)`.
- **Termination:** citation complete + ray rule predicts 2nd transect 0 mismatches; zero mismatches across the FULL shot series per item; 0 mismatches built-vs-unbuilt, never copy a neighbour sid.
- **Outcome → port change:** carry sampled bitmaps + explicit gap list until the full census lands (never a resized stand-in); wire shield/mount rows only from live probes; keep `PredictShot` mismatch labelled, not "fixed" by a guess.
- **Why read-only cannot settle it:** mask bitmaps and live ray/ballistic outcomes are runtime/coverage facts; the mechanical greps are STATIC-settleable but the Behaviour is not, and no donor run occurred.

---

## 9. Final determinism need (cross-cutting; gates every visual claim)

- **Exact question:** Are the port's replay and frozen baselines deterministic, and is there any admissible donor A/B frame at all?
- **Evidence id:** `PORT1TO1_determinism_audit.md`; `V15_acceptance_without_reference.md §2`; `V21_gate_register.md` D-0…D-6; `HANDOFF §4`; `V102_final_blockers.md`; `V109 §3/§6`.
- **Precise experiment (owner/COORD):** fresh runner result JSONs with mtime after job START; D1 determinism dumps (5 streams × 3 sizes 64²/240²/320², zero byte difference); D3 run integrity (status ∉ {timed-out,error,skipped}, `script_error_lines=0`, CLEAN); selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5, `scan_map ALL GREEN`, `assert_clean` CLEAN with **575/582/585 acknowledged with evidence-backed reasons** (never deleted, never `--ignore-history`), `app/**` byte-identical; admissible non-blank 1280×720 pinned-camera windowed capture; frozen baselines labelled by actual size. Then the six-condition chain of `V109 §6` / `V105 §78`: (1) genuine matched donor GPU frame, (2) admissible candidate capture, (3) matched/labelled inputs, (4) fresh green gates, (5) completed spec/toolchain with `blocking_unverified = []`, (6) demonstrated byte-identical geometry + pixel-identical frame ruled by COORD.
- **Termination:** `blocking_unverified = []`, no hard FAIL, no parity wording, three-tier verdicts with metric and visual fields separate, verbatim reviewer line. Without a donor frame the ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED".
- **Outcome → port change:** only then may COORD sign an owner report; the default `"donor"` backend flip remains a **separate deferred ticket** (`V109`, `V105`) and is not implied by any capture here.
- **Why read-only cannot settle it:** every runner/gate/dump/capture action is forbidden to analysis workers, and no donor frame exists or may be produced by them. Today all result JSONs are stale (2026-11-25), `assert_clean` was last read DIRTY with 575/582/585 unacked, `inbox/qa/**` holds only PENDING placeholders, and `blocking_unverified` is non-empty ⇒ `RESULT IS NOT GOOD`.

---

## 10. Preserve-only owner choices — MUST NOT be changed

Owner rule: all prior user modifications are preserve-only (`PORT1TO1_PLAN.md` header). `DEC_U_port_guard_audit.md §3` verdict **PASS**: the three owner-mod files are **not in `git diff` at all**; preservation inside modified files is verified. `PORT1TO1_acceptance_plan.md §7` requires SHA-256 recorded **before and after every capture**; `V102` requires re-verify at gate 0. No worker may flip, revert, overwrite, "repair" or re-apply any of these.

| # | Preserve-only choice | Exact must-not-change statement | Current evidence / hash |
|---|---|---|---|
| P-1 | `variant3d/config.json` — donor backend + `color_unify` | Keep `"backend": "donor"` (`:29`) and `"color_unify": true` (`:31`); do **not** flip backend to `legacy` to make a defect disappear. Preserve-only user mod. | `DEC_U_port_guard_audit.md §3.1`: PRESENT, unmodified, not in `git diff`; `PORT1TO1_acceptance_plan.md §7:301`. No per-file SHA recorded in the cited reports — **re-hash before/after capture** (plan §7). |
| P-2 | `variant3d/config_donor_capture.json` — `demo_mill` | Keep `"backend": "donor"` (`:31`) and `"demo_mill": true` (`:32`); `demo_mill` is an owner mod — do not remove. Water keys `alpha_confine=true`, `shore_prox=false` (`:34-37`) preserved. | **SHA-256 `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da`** recorded in `fullport6_seq2_20261113/manifest.json` (`PORT1TO1_acceptance_plan.md §7:310`); compare any new run's config hash to this before treating it as the same capture contract. |
| P-3 | `variant3d/assets/models/manifest.json` — nation move / EUR aliases / `field` fields | Keep `ukr/buildings` bucket (`:1880-2033`), `commoneur/eur*.osm` aliases (`:2040,2065,2090,2115,2164,2188`), sid `field` → `field1.osm`/`shared/terrain/field` (`:2581-2602`). Rollback is id-level removal only, never whole-file restore. | `DEC_U_port_guard_audit.md §3.1` + `PORT1TO1_acceptance_plan.md §7:307`: PRESENT, unmodified; `NATION_MOVE_ukr_buildings.md`, `EUR_ALIAS_shared_eur.md`. No per-file SHA in cited reports — re-hash if used in a capture. |
| P-4 | I11 seam (`main.gd` / `world3d.gd`) | Keep single-applied seam: `main.gd:125 terrain_backend := "legacy"`, `:189-191` config key `features.terrain.backend` (non-`donor` coerced to `legacy`), guards `:593-594`/`:1112-1113`; `world3d.gd:118/144/147/148/223-227/624/645/707-710`. **Never re-apply the seam or flip the default.** | `V102 §Seam` (two instruments): `main.gd.bak-COORD-I11` **SHA-256 `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8`**; `world3d.gd.bak-COORD-I11` **SHA-256 `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A`** — exact V11 E1/E2, V65 §8, V95 item 5, V76 baselines. HEAD `e234ac9b`, 0 staged, `app/` diff exit 0 (V102 P10). |
| P-5 | Shader/mesh fixes and opt-ins | Keep `scene_color = vec3(0.2)` (`[O]` `DEC_U_scenecolor_glstate U-1 CLOSED`), `sampler2DArray tile_array`, `tile_map` binding, `color_unify_gain = vec3(1.0)` neutral, specular zero, atlas grid from loader/manifest. The CPU-baked `uv0/uv1` rewrite of the old eye-plane/`textureGrad` texgen is documented at `terrain_donor_shader.gdshader:23-36` — do not silently remove or claim parity for it. | `DEC_U_port_guard_audit.md §3.1/§6`: PRESENT; `.bak-GLSTATE/.bak-RENDER1TO1/.bak-COLORSEAM/.bak-LIGHTMATCH/.bak-SUBCELLS` backups. Note the benign labelling gaps G1/G2 (`shader:80/65` 16×8 atlas fallback) are MINOR and need `[U]` tags, **not** value changes. |
| P-6 | v5 save keys | Keep `game.gd:7097-7125` `save_v5` `"version": 5`, **additive-only** (`:7122` "no existing v5 key removed, renamed or version-bumped"), restore `>= 5` (`:7193`), `bstandground/standtime/...` (`:7111-7112,:7385-7386`). | `DEC_U_port_guard_audit.md §3.1`: PRESENT; `DEC_U_save_contract.md §9` prescribes additive-only extension. No byte-parity claim — see P0-6. |
| P-7 | Stale ghost test / ghost assets | Keep `variant3d/tests/t_ghost_final_stage.gd:30` and the CAP-3 drag/ghost frames **as-is**: the `tests/results/*.json` / `shots/*` paths are runtime output paths created on demand; absence before a run is expected — **do not "repair", delete or point them at fabricated frames**. Ghost colour/blink is an explicit non-blocking TAIL: blink alpha law `[O]` (`unit.script:6674-6805`), tint `[U]` — never promote. | `V13_stale_qa_refs.md §2` ("Not stale but worth recording … absence before a run is expected"); `V21_gate_register.md GR-C04` CAP-3 drag/ghost frames "absent ⇒ UNVERIFIED, never PASS from terrain stills"; `DEC_U_ghost_blink.md §0/§3` (alpha-only, colour arms dead); `DEC_U_final_register.md §0 tails`. |
| P-8 | Preserved donor contradictions (do not "fix") | `TileSmoothPasses=6` (cfg) vs `SmoothTileMap(...,3)` (script): use **3** for skirmish, carry **6** as editor anomaly, runtime consumption `[U]`. `tilesmooth.cfg` vs `tilesmooth_scripts.cfg`: port weighted script table, keep plain table editor-only. `m_swamp_12_old` lib 17×20 vs binary 18×23: binary geometry authority, quarantine with warning, **never abort the 680-record parse**. Port 8 `id mod 64` zeros vs donor `alphanull` 86/110/123: keep sets distinct, port guard PORT APPROX. `specular_rgb` effective terrain product `vec3(0)` — preserve labelled contradiction. `lake_big := plain*2*0` must not be "repaired". Demo-mill / fields / builder stands (`game.gd`) stay (header `:12,:15` "NOT reverted"). | `PORT1TO1_acceptance_plan.md §7:309`; `V47_final_contradictions.md V47-02/03/04/05`, V47 §6 R1; `V16_contradiction_register.md §2`; `V72 §116` rollback trigger; `DEC_U_port_guard_audit.md §3.1` (demo-mill at `game.gd:3570,:2959,:3091,:3218,:5670-5680`). |
| P-9 | Tool hashes / frozen gate hygiene | Six Python tools keyed to final-pass hashes; COORD must independently re-run `py_compile` at A′-1 on the frozen tree; a landed report is not COORD's re-run. Never `reset`/`doctor`/`cancel`/`unwedge`, never delete result JSONs or hand-edit status, never `--ignore-history`. | `V102 P9`: SHA-256 prefixes **`ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77`** — exact match to V55 E10 / V90 §7 final hashes (per-tool mapping in those reports). Donor pin: `cossacks.exe` SHA-256 **`87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`** (`t_87f0f3c130b0`); read-only, never executed. |

---

## 11. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | Every P0/P1 row above carries its evidence/report id, exact experiment, zero-mismatch termination and conditional port-change instruction. | [D] this register, citing `DEC_U_final_register.md §§0–6` and `PORT1TO1_acceptance_plan.md §6` |
| 2 | All RUNTIME rows (water, FOW grid/tint, animation, capture traces, damage/FF, paired saves, projection) require an owner-authorised donor session or owner-run harness; workers are forbidden. | [D] `DEC_U_final_register.md §6`; CHARTER §4 |
| 3 | No donor binary was executed, no GPU frame captured, no port capture compared, no gate/capture/Godot job run by this worker. | [O] scope guard |
| 4 | No approximation is supplied for any `[U]`; every port change is conditional on its own zero-mismatch result; tails are never promoted. | [D] `DEC_U_final_register.md §0/§7`; `PORT1TO1_acceptance_plan.md §6` |
| 5 | Preserve-only items P-1…P-9 must remain byte-preserved; hashes above are point-in-time and must be re-verified by COORD before any capture. | [O]/[D] `DEC_U_port_guard_audit.md §3`; `V102`; `PORT1TO1_acceptance_plan.md §7` |
| 6 | **Parity is UNVERIFIED, `parity.claim = NONE`, no tier above 2 exists; `blocking_unverified` is non-empty ⇒ `RESULT IS NOT GOOD`.** | [D] `PORT1TO1_PLAN.md:36`; `V15 §2`; `V109 §1/§6`; HANDOFF §0/§5 |

---

*End of PORT1TO1_owner_decisions. Read-only: exactly one repository file written (this report). No source, shader, config, asset, test, manifest, queue, result JSON, backup, git or Godot state changed; no donor binary executed or copied; no gate, capture, frame or donor A/B produced. No parity claim; no approximation endorsed.*
