# PORT1TO1 Wave Synthesis — read-only static decomp interim (2026-11-26 wave)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

- Scope: READ-ONLY synthesis of 11 landed static reports. No code/Godot/git/donor execution; no edits to any other file. Parity UNVERIFIED, no parity claim, no approximation.
- `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; chain **0/6 CLOSED**; `blocking_unverified` non-empty ⇒ **`RESULT IS NOT GOOD`**.
- Governing counts confirmed unchanged: **71 open [U] rows (A42/B14/C5/D10)**, **nine P0 rows OPEN**, chain **0/6**, **no donor GPU A/B**, **no matched camera**, **no COORD ruling**.
- Classification verdict: **all 11 items are static narrowings only; none genuinely changed a port value (answer: none).**
- No static fact in this wave retires a P0 row or closes a class-A value/behaviour item.

## 1. Landed-report table — byte-proven [D] vs surviving [U]

| # | Report | Byte-proven [D] facts (evidence id / address / path:line) | Surviving [U] residual |
|---|---|---|---|
| 1 | `DEC_U_b1_glcopy_callers.md` | `glCopyTexImage2D` slot `0x907d7c` + `glCopyTexSubImage2D` slot `0x907d78`, both `used_by: []` (`ev_5d168221…`, `ev_90859ec9…`); `0x4afb3c` resolves only to container `sub_4aff8c` @`0x4aff8c` with 0 callers + 1 DATA ref `0x4b0385←sub_4b0304` (`ev_322cefb2…`); chain `sub_6760a0→sub_7744cc→(data)sub_7715f4→(call @0x771b50)sub_4ed28c→glTexImage2D@thunk @0x771b80`, no copy call (`ev_78b7e0e9…`, `ev_db7bd0ec…`, `ev_16ab8d2e…`); `glBindTexture@thunk` @`0x4afb0c` sole user `sub_88f8a8` @`0x88f8c0`, 23 sites / 7 callers (`ev_dd740c62…`, `ev_cbb26573…`); copy-chain vs bind-chain address sets disjoint | B1-COPY-THUNK, B1-COPY-HEAD, U12-A, U3-TEX, U3-NUM, U-B1-FRAME — reflection identity, scalar tuple, frame timing; all `[U]` with ≥2-frame + camera-move zero-mismatch termination |
| 2 | `DEC_U_b2_ureg_callers.md` | `sub_739bf8` @`0x739bf8` = 7-insn getter returning `[obj+0xb4]`, 42 sites / 8 callers (`ev_11e60953…`); getter→field-store chain `+8/+0xc/+0x10` in `sub_710380` (`ev_404ef074…` @`0x7104b7–0x7109bc`); three incompatible `+0x50` semantics separated (object-ptr @`0x7104b4`, byte flag @`0x73a242`, string field @`0x73a52a/0x73a581/0x7397c3`); zero `+0x200` writes; `glUniform1i/1f` 0 hits (`ev_dff42170…`, `ev_27094eb6…`); no direct gate/GL-thunk reachability; `0x82f060/0x82f114/0x82f86c` `function_not_found` | U3-TEX, U3-NUM, B2-U-REG-CALL — live `(target,name,w,h)`, live 4-tuple, undiscovered bodies/callers; all `[U]` |
| 3 | `DEC_U_b3_callback_sweep.md` | L1/L2 Delphi LCG `s=(s·0x8088405+1) mod 2^32` + QPC/GTC seeder to `0x8f2008` (`ev_6b798f50…` VA `0x4033bc`, `ev_3e940d03…` VA `0x403a0f`); 15 `Random` call sites enumerated (`ev_3e940d03…`); shared registrar host `sub_706880`→`sub_608238` @`0x70691d` and →`sub_69a70c` @`0x70692b` (`ev_d60c7ec9…`, `ev_7ff62a20…`); global slots `+0x108/+0x10c` via `sub_6ac2e0` (`ev_42f7f31c…`); indirect renderer `call [ebx+0x40]` @`0x81ac68` → `sub_812e34` 0 callers + 2 data refs (`ev_77f7eec8…`, `ev_9a66277a…`); live text `data/scripts/lib/map.script:322`, `data/gui/menu.inc/donewgame.inc:16,33-35,37`, `initmapsettings.inc:8` | U-INVOKE, U-KEY-LIVE, U-KEY2, U-MAP, U-SS, U-ONLY, U-TIME, U-RANDOM-ATTRIB, U-RESEED-COUNT, U-SCRIPT-ACTIVATION, U-COPY-VALUES, U-SHIPPED-MAP-BYTES — all live timing/value `[U]` |
| 4 | `DEC_U_b4_smooth_native.md` | `SmoothTerrain` 0/0/0/0 (`ev_45b47090…`); `smooth`→`XTileSmooth` @`0x959416` (`ev_b6125ada…`); `mb` 31 generic hits (`ev_6de32500…`); `MapGenerator`→`XMapGenerator` @`0x959430` (`ev_164c70a3…`); S0 VAs `0x6a395a/0x6a394e` `function_not_found`; `sub_608238` @`0x608238` = 1 block / 1559 insns / 331 indirect registrar calls, 0 strings, ends `al=1` (`ev_7e20303d…`, `ev_10c9525c…`); `sub_706880` @`0x706880` = 76-insn init chain (`ev_788f11b1…`) | U-S0-KERNEL, U-S0-SCOPE, U-S0-RADIUSFLOAT, U-MB3, U-S0-VM — kernel VA, loop bounds, `mb=3`, radiusFloat; all `[U]` |
| 5 | `DEC_U_b5_ver_residual.md` | 17 version/envelope literals all 0 hits §1.1 (`ev_b96ee727…` … `ev_161b083f…`); indexed version surfaces are RTTI + PE file-version only (`ev_9b1bdf76…`, `ev_ffe922c8…`); envelope `0x710be0` = data-as-code, 2 DATA refs @`0x7103d4/0x71069b` via `sub_405454/405400` (`ev_7443cdc5…`, `ev_eec6cf7e…`); settings table `0x71c0b4` = 922-insn data-as-code, 0 callers, 30 DATA refs → dynarray helper `sub_406ba4` (`ev_85467957…`, `ev_61f9b115…`); 3115-insn immediate scan: zero standalone `0x35/0x5C/0x140/0x180` | U-TVER-SELECTOR, U-TVER-NATIVE-VALUE, U-B5-NATIVE-CONSUMER, U-LIVENESS — selector, defaults, 53-vs-92 binding; all `[U]` |
| 6 | `DEC_U_b8_coll_los.md` | Literal inventory 17 queries (`ev_0af219e6…` … `ev_dcfd60f5…`); helpers `sub_755168`/`sub_764e04`/`sub_7550f8`/`sub_75505c` + NEW `sub_7d9694` @`0x7d9694` with `+0x65` gate + `[eax+0x1c]` traffic (`ev_059c599f…`, `ev_c9de8811…`, `ev_e2041ddb…`); text `objects/buildings/*.prop` 369 (354+15), `objects/units/*.prop` 140/0 masks; 0 `Rotate/Reflect/tmoRotate` overrides, defaults `objects/ref/refbuilding.prop:44,46,48-49,52-53`; 18 `objprop.radius` overrides `scripts/lib/unit.script:1323…2036`; 4 ctpo consumers `serial.script:247`, `squad.script:730,735`, `nothing.inc:162`; 12-float LOS `scripts/misc/projectile.inc/nothing.inc:52,56,59-63` | U-B8-LIVE-RADIUS, U-B8-LIVE-MASK, U-B8-FOOTPRINT-SEM, U-B8-CTPO-SEM, U-B8-LOS-MATH, U-B8-FOW-EDGE, U-B8-INERTIA-SOLVER, U-B8-RAYCAST-TOGGLE — all live values/semantics `[U]` |
| 7 | `DEC_U_b13_dsp_code_sweep.md` | Scheduler names 0 hits (6 ids `ev_f3fa9312…` … `ev_e6571b34…`); `sub_690048` @`0x690048` data-as-code 8128 insns (`ev_cff37940…`); tables `sub_68b7d8`/`sub_69a70c`/`sub_686cbc` 1-block registration pointers only (`ev_891f7ad8…`, `ev_c70c7d3f…`); fixed call-order `sub_706880` 26 calls incl `0x686cbc @0x706916→0x68b7d8 @0x706924→0x69a70c @0x70692b` (`ev_788f11b1…`); loop `sub_6a94e0` byte-increments are zeroing loop (`ev_02acb9f5…`) | U-DSP, U-S1, U-THR, U-S3 — dispatch loop bound/stride/stage order; all `[U]` with 3600-frame × 3-seed termination |
| 8 | `DEC_U_b14_fow_native.md` | `UpdateFOW/victorystate/GetFOWLOSData/FOWBuildFull` 0/0/0/0 (`ev_bca8d8a1…`, `ev_ea2f5c36…`, `ev_be8575b2…`, `ev_82b2ed6d…`); `XFOWRender` @`0x958d0d` sole 1-hit, `references: []` (`ev_6a94cc5c…`); 9 `LOS` hits = `Close*` thunks, dossier `0x4012e8` `jmp [0x9072e4]` (`ev_6b92caf5…`, `ev_5609cc74…`); discovery incomplete 18918 fns / 6M-stop / 1238 unresolved (`ev_60b49743…`); carried C1–C11 (FOWEnable ×3, binding block `0x2a74b2–0x2a79d3`, RTTI offsets) quoted not re-lifted | F-GRID-a…e, F1-NUM-a…g, F1-MINI-TINT, U-F1…U-F8 — cell size, combine, occlusion, persistence, domain, layouts, knobs, tint, ordering; all `[U]` |
| 9 | `DEC_U_dsp_stage_order.md` | Entry `0x8f1a08` 18 blocks / 166 insns / 34 callees, init-shaped (`ev_deb2a847…`); per-iteration `sub_47c884→sub_47c6e0→(sub_47c630 pump\|sub_47d080 idle)` with `sub_47d080` ordered sequence `47d008→47d5d8→47af00→488c1c→47d240→[ebx+0x100]→47cfa4→42dc50` (`ev_66dcb709…` + depth-2 ids); 26-call order re-verified (`ev_8377e5b8…`); D-2 ∩ D-3 = empty at studied depth; roots `sub_706550`/`sub_7069e0` 0 callers | U-DSP, U-S1, U-S3, U-THR — per-frame stage order unlinked; all `[U]` |
| 10 | `DEC_U_cam_derive.md` | Text-only: def `control.script:616-618`; 9 sites C1–C9 (`doprogress.inc:41`, `onshortcut.inc:1000`, `docreate.inc:297`, `control.script:684`, `scenario.script:1849`, `onmousedown.inc:122,141`, `onmousewheel.inc:310,316`); wrapper `control.script:619-664` (`time→SmoothingTime/Change`, `True→maxHeight`, `ArcTan` offset); config `camera.cfg:6-7,9-10,32-35,44-45`; `0.75` sweep: zero donor counterpart (only `camerascreenshot.cfg:7` min-height) | CAM-derive, CAM-0 — final target/height, `time=0` smoothing, zoom; all `[U]` with matched-camera zero-mismatch termination |
| 11 | `PORT1TO1_video_internal_review.md` | Port-internal numbers only: `lastcheck_20261127` f0 1024153 B `a776159f…`, f1 1027048 B `167764bf…`, 1280×720, 99.05% changed f0→f1, mean-abs-diff ~(3.61,4.97,5.18); repeat SHA match TRUE; 9 two-frame sets share one SHA per index; `fullport6_seq2` 0.49%/0.46% inter-frame; blue-dominant 0.000% everywhere; defects D1–D5 + expected E1–E3 | Not parity evidence (see §2) |

## 2. Static-narrowing vs port-value classification

- Static narrowings only (11/11): every `[D]` above narrows structure — import `used_by`, caller censuses, DATA-vs-call separation, index-vs-CODE splits, disjoint call sets, text censuses, config-key reads — and closes no behavioural `[U]`.
- Genuinely changed a port value (0/11): **none**. No water/radius/mask/grid/knob/camera/tick/stage value was wired, no substitute label removed, no gate flipped.
- Governing discipline holds: structural closure is not value closure; class-B static closure never back-doors a class-A item.

## 3. Port-internal video review — numbers are not parity evidence

- Computed numbers: §1 row 11 (sizes, SHA-256, means/stds, changed-%, green-band 92.56%/68.27%, blue-dominant 0.000%).
- Status: `byte_identical=TRUE` = port-internal repeatability only (chain condition 6 PARTIAL, not CLOSED); cross-set hash identity = coverage collapse, not coverage; D2 changed-pixel 99.05% is metric hygiene, not motion; D3 single-camera corpus = coverage gap.
- Explicit negatives carried: no donor A/B frame compared, no matched-camera pair, no COORD ruling, no donor video measured. Nothing here promotes parity or closes any chain condition.

## 4. P0 / class-A impact

- None of the wave's static facts retires a P0 row: nine P0 rows stay OPEN.
- None closes a class-A value/behaviour item: A42/B14/C5/D10 open counts unchanged; chain 0/6 unchanged.

## 5. Pending follow-ups (absence of artifact — results not invented)

1. `DEC-U-D4-FLOATS` — PENDING (no artifact landed; nothing synthesized).
2. `DEC-U-B6-G0` — PENDING (no artifact landed; nothing synthesized).
3. `DEC-U-SPEED` — PENDING (no artifact landed; nothing synthesized).

## 6. Canonical verdict

`port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus tails); six-condition chain **0/6 CLOSED**. **No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. `RESULT IS NOT GOOD`.**

*End of PORT1TO1_wave_synth. Read-only synthesis; exactly one repository file written; no parity claim; no approximations.*
