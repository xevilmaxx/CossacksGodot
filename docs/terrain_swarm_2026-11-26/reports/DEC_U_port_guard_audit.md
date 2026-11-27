---
id: DEC-U-PORT-GUARD-AUDIT-2026-11-26
title: "AUDIT-PORT-GUARDS — static port-guard / preserve-mod audit of the current working tree"
agent: AUDIT-PORT-GUARDS (read-only subagent, task #24 of PORT1TO1_PLAN.md)
created: 2026-11-26
scope: "CURRENT working tree only — read-only `git status --porcelain`, `git diff --no-color` (full + per-file), and source reads. No code/Godot/git-write/donor-execution."
role: "Static guard audit: (1) new approximations/invented literals/silent fallbacks vs [U]/[I] labels + capture experiments; (2) parity claim strings vs UNVERIFIED; (3) preserve-only owner mods; (4) backups per worker edit."
parity: UNVERIFIED
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists and none is invented here. This audit certifies neither donor fidelity nor a gate pass."
required_reviewer_line: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repo file written: docs/terrain_swarm_2026-11-26/reports/DEC_U_port_guard_audit.md."
---

# AUDIT-PORT-GUARDS — port-guard / preserve-mod audit (2026-11-26)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

## 0. Method and evidence base

Read-only operations only: `git status --porcelain=v1`, `git diff --stat`, `git diff --unified=0` captured to a scratch file *outside* the repo (`%TEMP%`), per-file `git diff --unified=4/6`, and direct source reads. No file in `variant3d/`, `inbox/`, `docs/` or `app/` was edited; no Godot job, gate, donor binary or git mutation was performed. All line numbers below are **current working-tree** line numbers unless explicitly marked `diff:` (line within the captured diff).

Tree shape (from `git diff --stat`): **82 tracked files changed, 7,486 insertions / 1,390 deletions** — 66 regenerated single-line skin JSONs plus 16 code/shader/test/tool files. Untracked additions include the swarm reports, `inbox/backup/*.bak-*`, `inbox/qa/captures/*`, new acceptance tools and `.bak-*` files colocated in `variant3d/`. No tracked file was deleted (`git status` shows only `M` and `??`, no `D`).

---

## 1. Audit area (1) — new approximations / invented literals / silent fallbacks

### 1.1 Result: PASS, with 3 MINOR labelling gaps (no parity claim, no invented donor constant introduced)

The dominant change volume is **regenerated skin JSONs** (66 files). Each carries `"label":"PORT APPROXIMATION — NOT DONOR PARITY"`, `"visual":"UNVERIFIED"`, per-sid donor `.oss`/`.aaf` citations and a cited `skin_math`; e.g. `variant3d/assets/models/skin/rus/land_units/pearus.json:1`, `variant3d/assets/models/skin/index.json:1`. No cross-sid frame range is copied: `convert_skins.py:81-113` expands only the *name union* and `convert_skins.py:397-413` keeps each file in the manifest's own `bucket` ("no location is invented here"). This is compliant.

Newly introduced code literals are **donor-cited or explicitly labelled with a named experiment**. Representative evidence:

| File:line (current) | New content | Label / experiment |
|---|---|---|
| `variant3d/scripts/camera.gd:9-20` | `donor_camera_pins_mirror()` returns 58/20/-32/400 | `camera.cfg:6-10,32-35,44-45` cited; FOV 17.27 `PORT APPROXIMATION / UNVERIFIED` with `V1-SENSOR`; interleave/framing `[U] O1/R1`; "NO PARITY CLAIM" |
| `variant3d/scripts/camera3d.gd:59-76` | `DONOR_PITCH_DEG=-32`, `DONOR_DYNFOG_*`, `ATLAS` n/a | `[O]` with `camera.cfg` file:line; unresolved `V1-SENSOR`, `V2-PROJ`, `R1` named at `:72-74` |
| `variant3d/scripts/config.gd:69-74,106-111,458-460,511` | `fov_deg` 17.27 retained; `camera.focal=400` added | `PORT APPROXIMATION / UNVERIFIED (DEC-U §2.2-V1, RV-CAM-01)`; 400 cited `camera.cfg:44-45` |
| `variant3d/scripts/data.gd:181-198` | queue cap / score limit / dt clamp | `[U] U13/U5/U12/U1` with X09/§14 decomp plans |
| `variant3d/scripts/game.gd:2058 (diff)`, `:2462 (diff)`, `:2524 (diff)`, `:2779 (diff)`, `:3016` | identity reseed, `TICK_ORDER v1`, splash 0.5×, progress telemetry | `[U]-G1` (X21 vectors), `[U] U1`/`[U]-O1` (DEC §4 item 13), `[U]-U3` (`miscext2.script:240-256`), `[U]-O1` in returned string |
| `variant3d/scripts/hud.gd:684-689 (diff)` | marquee inside predicate | `[U] V2-BOX/V2-PROJ`, named capture V2-BOX |
| `variant3d/scripts/terrain_donor_gen.gd:872,895,1336,2136,2393` | shared RandomExt stream, `_grid_w-1` clamp, 7-way conifer draw, pre-placement border fill | `[O]` cited to X21/§A.5, D2:626, GEN1TO1 §F.4/§F.6; old values removed as labelled PORT APPROX |
| `variant3d/scripts/terrain_donor_inputs.gd:4599-4603 (diff)` | `GenerateMapRandKey`, generator-state, minx/miny | `[U] U5/P5 ±1 probe §2.4.2`, `[U] U4 breakpoint probe`, `[U] U7 §4 probe`; "no silent fallback" |
| `variant3d/scripts/world3d_fog.gd:36-57,67-72,340-347` | vision 20/4, tag 109, floor() reveal | `[O]` cited `unit.script:11563-11614`, `dmscript.global:1439`; `[U] F1-GRID/F1-MINI` named |
| `variant3d/scripts/world3d_entities.gd:283,295,299,306` | yaw rate, AAF fallback order, building death, explosion | `[U] U1`, `[U] U2`, `[U]-BURN E-U14`, `[U]-EX` with citations |
| `variant3d/scripts/world.gd:1008-1011` | water plane 1.0 retained | added `[U] U18 / W-2` with "second instrument (Ghidra + GL trace)" plan |
| `variant3d/tests/t_mcp_host.gd:23-31` | MCP protocol constants | protocol constants, not donor approximations; explicit "No silent fallback to an unsupported value" |

**No new forbidden constructs found.** A filtered scan of `+` lines for `noise|dither|synthetic|fBm|random` found only donor-grounded taps (`water3d.gdshader` `wave_noise = diffusewaves0.png` with donor coefficients 0.6/0.25/0.1666 and `[U]` fBm note at `:269`) and donor RNG draws (`rng.randf() * C1RAND_TO_RANDOM` in `game.gd`, cited and `[U]-G1`-labelled). No new `HEIGHT_SCALE`, `mix64`, 6-pass smoothing, `rgb *= a`, food-rect, synthetic dither/noise or invented donor constant was introduced; `game.gd:2058` explicitly *deletes* `seed + si*1000003 + ver*10007`.

### 1.2 MINOR gaps — precise remedial edits (NOT applied)

- **G1 — `variant3d/shaders/terrain_donor_shader.gdshader:80`**
  `uniform vec2 atlas_grid = vec2(16.0, 8.0);  // FALLBACK 16x8 packing, PORT APPROX`
  This newly introduced fallback packing literal is labelled `PORT APPROX` but has **no `[U]`/`[I]` tag and no capture experiment on the line**. The value itself is manifest-derived (`terrain_donor_mesh.gd:94` `ATLAS_GRID_EXPECTED := Vector2(16.0,8.0)  # V7-85 manifest:23-26; spec/06:19`) so it is not fabricated, but the *fallback* is a port approximation.
  **Remedial edit:** replace the trailing comment with
  `// [U] U-10/atlas-packing (PORT APPROX): FALLBACK 16x8 packing; same grid as terrain_donor_mesh.gd:94 (V7-85 manifest:23-26, spec/06:19). Capture experiment RV-ATLAS-01 (pinned-candidate A/B of 16x8 vs declared manifest grid) required before any parity use; not a donor-claimed layout. visual_parity_claim=false.`

- **G2 — `variant3d/shaders/terrain_donor_shader.gdshader:65`**
  `// false = 2D atlas fallback (PORT APPROXIMATION; not donor layout).`
  Newly introduced branch-default description with `PORT APPROXIMATION` but no `[U]`/`[I]` tag and no experiment.
  **Remedial edit:** `// [U] U-10/atlas-fallback (PORT APPROXIMATION): false = 2D atlas fallback; not donor layout; RV-ATLAS-01 A/B pinned before any use. true = one 1024^2 donor-derived block per id at baked uv0.` (Keep line 66 unchanged.)

- **G3 — `variant3d/scripts/terrain_donor_inputs.gd:772-773`**
  `"mask_selection_label": ("PORT APPROX: deterministic asset index; the donor D2:190 " + "floor(RandomExt*count) draw is issued by I07 on the inherited stream")`
  The governing report sanctions the *label* (`DEC_U_gen_seed.md:176`: "Until the draw moves, label :625 as PORT APPROXIMATION (already labelled at :749-750 — keep)") and names a runtime probe (`DEC_U_gen_seed.md:113,167`), but the emitted token itself carries neither `[U]`/`[I]` nor an inline experiment reference. A related comparison-only hook at `terrain_donor_inputs.gd:701-704` (`"label": "PORT APPROXIMATION — comparison hook only; donor sampler is nearest"`) has the same gap.
  **Remedial edit:** change `:772` to prefix `"[U]-G1 PORT APPROX: deterministic asset index — experiment DEC_U_gen_seed.md §2.4 (D2:190 draw-move probe) ..."` and change `:704` to `"[U]-G1 PORT APPROX — bilinear comparison hook only; donor sampler nearest (D2:409-411); no parity use"`. Do **not** change the runtime behaviour or remove the hooks.

G1–G3 are labelling/telemetry-only defects; none asserts donor fidelity, none changes simulation or rendering values, and none requires a rollback. They are MINOR because the governing reports already carry the experiments; the gap is that the tags are not visible at the emit site.

---

## 2. Audit area (2) — parity claim strings inconsistent with UNVERIFIED

### 2.1 Result: PASS

- A repo-wide grep for `RESULT IS GOOD|parity=true|parity = true|"parity": true|visual_parity_claim": true|parity_claim": true|parity_claimed": true` found **no `true` parity flag and no unqualified `RESULT IS GOOD` introduced by a worker edit**.
- Every added parity-bearing line in the diff is `false`/`UNVERIFIED`/`"no parity claim"`. Examples: `terrain_donor_mesh.gd (diff:5256) "parity_claim": false`, `water3d.gd (diff:6499) "visual_parity_claimed": false`, `world3d_fx.gd:3 "PORT APPROXIMATION — no donor visual parity claim"`, `terrain_donor_shader.gdshader:18 "visual_parity_claim:false. No donor GPU A/B frame exists"`, `world3d_fog.gd:57 "NO PARITY CLAIM"`, `camera.gd:20 "NO PARITY CLAIM"`.
- Newly written acceptance artefacts are consistent: `inbox/qa/captures/contact_acceptance_smoke.json:4 "parity=UNVERIFIED"`, `variant3d/tools/acceptance/capture_sequence.py:373 "parity=UNVERIFIED (a capture is evidence, never a donor-parity claim)"`.
- Pre-existing `RESULT IS GOOD` strings carry the UNVERIFIED qualifier explicitly: `docs/terrain_swarm_2026-11-26/reports/W08_visual_acceptance_criteria.md:196` reads `RESULT IS GOOD — DONOR-GROUNDED STRUCTURE VERIFIED + SELF-CONSISTENT VISUAL; donor parity UNVERIFIED (declared, accepted).` and is guarded at `:199-202` (`parity.claim=NONE`, `parity.status=UNVERIFIED`). `X39_ab_feasibility.md:236` is explicitly conditional ("provided no blocking QA item is missing") and is already flagged as MINOR defect D14 in `V67_owner_answer_check.md:128` with a remedial edit to state `RESULT IS NOT GOOD` today. Neither is a newly introduced worker edit in `variant3d/`.

**Verdict:** no worker-introduced parity claim string contradicts `UNVERIFIED`. `parity=UNVERIFIED` is the only honest output of this audit.

---

## 3. Audit area (3) — preservation of owner mods

### 3.1 Result: PASS (all listed owner mods present and un-reverted)

The three owner-mod files named in the charter are **not in `git diff` at all** (`git status` shows no `M` for them), i.e. byte-preserved in the working tree:

| Owner mod | Evidence (current tree) | State |
|---|---|---|
| `variant3d/config.json` donor backend + `color_unify` | `:15` `features.terrain.backend: "donor"` comment; `:29` `"backend": "donor"`; `:18` `color_unify` comment; `:31` `"color_unify": true` | PRESENT, unmodified |
| `variant3d/config_donor_capture.json` demo-mill | `:31` `"backend": "donor"`; `:32` `"demo_mill": true` | PRESENT, unmodified |
| `variant3d/assets/models/manifest.json` nation move / EUR aliases / field changes | `:1880-2033` `"bucket": "ukr/buildings"` (cen/hou/bar/sta/bla/aca/art/dip); `:2040,2065,2090,2115,2164,2188` `commoneur/eur*.osm` aliases; `:2581-2602` sid `field` → `field1.osm` and `shared/terrain/field` | PRESENT, unmodified |

Preservation inside modified files:

| Owner mod | Evidence | State |
|---|---|---|
| I11 seam `main.gd` | `:125` `terrain_backend := "legacy"`; `:189-191` `features.terrain.backend`, non-`donor` coerced to `legacy`; `:593-594`, `:1112-1113` guard calls before both `make_world3d()` sites | PRESENT (`main.gd` unmodified) |
| I11 seam `world3d.gd` | `:111` legacy `TERRAIN_SCRIPT`; `:121` `TERRAIN_DONOR_SCRIPT`; `:147` `terrain_backend := "legacy"`; `:148` `_terrain_locked`; `:223-227` `set_terrain_backend` late-switch refusal; `:627` ternary; `:648` lock; `:709-710` stats keys | PRESENT; its only diff is a 3-line `[U] U16/U17` comment at `:19-24` (decomp plan, no behaviour change) |
| demo-mill / fields / builder stands | `game.gd:3570` `_demo_mill_enabled()`; `:2959,:3091,:3218` mill-sow calls; `:2978-3076` donor + legacy field rings; `:5670-5680` `BUILDER-STANDS` / `_build_stand_slot`; `:3984-3989` stand-ground commands; header `:12,:15` explicitly "NOT reverted" | PRESENT |
| v5 save keys | `game.gd:7097-7125` `save_v5` `"version": 5`, additive-only (`:7122` "no existing v5 key removed, renamed or version-bumped"); `:7193` `>= 5` restore; `:7111-7112,:7385-7386` `bstandground/standtime/...` keys | PRESENT |
| Shader/mesh opt-ins and fixes | `terrain_donor_shader.gdshader:122` `scene_color = vec3(0.2)` `[O] DEC_U_scenecolor_glstate U-1 CLOSED`; `:62` `sampler2DArray tile_array` (array/hires atlas); `:72` `tile_map` retained binding; `:138` `color_unify_gain = vec3(1.0)` neutral default; `:114,:116` specular zero; `terrain_donor_mesh.gd:94,1454-1456` atlas grid from loader/manifest; `:293,494-496,613` pre-existing labelled `_tag_fallback_from_tex` path | PRESENT. The old in-shader `eye_plane`/`textureGrad` texgen form (`HANDOFF.md:212-215`) is replaced by CPU-baked `uv0/uv1` in the RENDER1TO1 rewrite, explicitly documented at `terrain_donor_shader.gdshader:23-36` ("all selectors are resolved on the CPU, exactly as the donor display list does"); no parity is claimed for that change and it is not a silent removal. |

Note on `world3d_terrain.gd` (legacy renderer) and `app/**`: neither appears in `git diff`; the freeze set is intact.

---

## 4. Audit area (4) — backups for worker edits

### 4.1 Result: PASS for all code/shader/test/tool edits; MINOR gap for regenerated skin JSONs

A basename scan of every modified file against all `*.bak*` files under `inbox/backup/` and `variant3d/` found a backup for **every modified `.gd`, `.gdshader`, `.py` and doc-with-code-semantics** file. Examples:

- `anim3d.gd` → `inbox/backup/anim3d.gd.bak-ENT1TO1`, `variant3d/scripts/anim3d.gd.bak-AAFART`, `.bak-AAFTRIG`
- `camera.gd` → `variant3d/scripts/camera.gd.bak-FOGPATCH`; `camera3d.gd` → `.bak-FOGHUD`
- `config.gd` → `variant3d/scripts/config.gd.bak-FOGPATCH`
- `data.gd` → `inbox/backup/data.gd.bak-SKIRMISH1TO1`, `variant3d/scripts/data.gd.bak-COLLCALL/.bak-FOGPATCH/.bak-SKIRMISHLAWS/.bak-SKIRMISHROWS`
- `game.gd` → `inbox/backup/game.gd.bak-SKIRMISH1TO1`, `.bak-FIELDS`, `.bak-SPAWN`, `.bak-BUILDERSTANDS`, `.bak-MILLSOW`, `.bak-COLLCALL`, `variant3d/scripts/game.gd.bak-{COLLCALL,SKIRMISHLAWS,SKIRMISHROWS}`
- `hud.gd` / `input_controller.gd` → `.bak-SKIRMISH1TO1` (inbox) + `.bak-FOGHUD` (variant3d)
- `picking3d.gd` → `variant3d/scripts/picking3d.gd.bak-COLLCALL`, `.bak-FOGPATCH`
- `terrain_donor_gen.gd` → `inbox/backup/terrain_donor_gen.gd.bak-GEN1TO1`, `.bak-GENSEED`
- `terrain_donor_inputs.gd` → `.bak-GEN1TO1`, `.bak-GENSEED`
- `terrain_donor_mesh.gd` / `terrain_donor_shader.gdshader` → `.bak-GLSTATE`, `.bak-RENDER1TO1` (inbox) + `.bak-COLORSEAM/.bak-LIGHTMATCH/.bak-SUBCELLS`
- `water3d.gd` → `inbox/backup/water3d.gd.bak-WATER1TO1`, `variant3d/scripts/water3d.gd.bak-WATER1TO1B`, `.bak-WATERCOMPILE`; `water3d.gdshader` → `.bak-WATER1TO1B`, `.bak-WATERCOMPILE`, `.bak-P13`
- `world.gd` / `world3d.gd` → `inbox/backup/{world,world3d}.gd.bak-SKIRMISH1TO1` (+ `main.gd.bak-COORD-I11`, `world3d.gd.bak-COORD-I11` for the I11 seam)
- `world3d_entities.gd` → `inbox/backup/world3d_entities.gd.bak-ENT1TO1`, `.bak-AAFART`, `.bak-BLDDEATH`; `world3d_fog.gd` → `.bak-FOGHUD`; `world3d_fx.gd` → `.bak-ENT1TO1`, `.bak-FXART`
- `t_mcp_host.gd` → `inbox/backup/t_mcp_host.gd.bak-MCPPROTO`
- `convert_skins.py` → `variant3d/tools/convert_skins.py.bak-AAFART`, `inbox/backup/convert_skins.py.bak-{BUILDSKIN01,C01ASSET}`

### 4.2 MINOR gap

- The **65 per-sid skin JSONs** regenerated by the AAF-art worker have no per-file `.bak-*`; only the manifest `variant3d/assets/models/skin/index.json.bak-AAFART` exists. (`HANDOFF.md` is a documentation file and is outside the source/config/asset/test backup rule.)
  **Remedial edit (if a file-level rollback is required):** before any further regeneration, snapshot the 65 current JSONs to `inbox/backup/<sid>.json.bak-AAFART` (one file per sid, named on the `index.json` entry list) and record their SHA-256 in the AAF-art report. This is a rollback-readiness improvement only; the files are deterministic outputs of `convert_skins.py` from read-only donor `.oss`/`.aaf` and are regenerable, so no source edit is needed to restore them.

---

## 5. Consolidated remedial-edit list (precise, NOT applied)

| ID | File:line | Precise edit | Severity |
|---|---|---|---|
| G1 | `variant3d/shaders/terrain_donor_shader.gdshader:80` | Replace comment with `// [U] U-10/atlas-packing (PORT APPROX): FALLBACK 16x8 packing; same grid as terrain_donor_mesh.gd:94 (V7-85 manifest:23-26, spec/06:19). Capture experiment RV-ATLAS-01 (pinned-candidate A/B) required before any parity use; not a donor-claimed layout. visual_parity_claim=false.` | MINOR |
| G2 | `variant3d/shaders/terrain_donor_shader.gdshader:65` | Prefix `// [U] U-10/atlas-fallback (PORT APPROXIMATION)` and append `RV-ATLAS-01` reference; keep line 66. | MINOR |
| G3a | `variant3d/scripts/terrain_donor_inputs.gd:772` | Prefix emitted label with `[U]-G1` and inline `experiment DEC_U_gen_seed.md §2.4 (D2:190 draw-move probe)`; no behaviour change. | MINOR |
| G3b | `variant3d/scripts/terrain_donor_inputs.gd:704` | Change label to `[U]-G1 PORT APPROX — bilinear comparison hook only; donor sampler nearest (D2:409-411); no parity use`. | MINOR |
| G4 | `inbox/backup/<sid>.json.bak-AAFART` (65 new files) | Snapshot the regenerated skin JSONs named in `variant3d/assets/models/skin/index.json:1` and record SHA-256 in `DEC_U_aaf_art_audit.md`. | MINOR (readiness) |

No code, Godot, git, donor, config, asset, test or backup file was changed to implement any of the above. No rollback is triggered: none of G1–G4 asserts donor fidelity, changes a simulation value, lowers a test or removes an owner mod.

---

## 6. Audit verdict

| Audit area | Verdict |
|---|---|
| (1) New approximation / invented literal / silent fallback without `[U]`/`[I]` + experiment | **PASS with 3 MINOR labelling gaps (G1–G3)** — no unlabelled donor claim, no synthetic noise/dither, no new invented donor constant |
| (2) Parity claim strings inconsistent with UNVERIFIED | **PASS** — no `parity=true` / `visual_parity_claim=true` / unqualified `RESULT IS GOOD` introduced by a worker |
| (3) Preserve-only owner mods | **PASS** — config.json donor backend/color_unify, config_donor_capture demo_mill, manifest nation move/EUR aliases/field changes, I11 seam, demo-mill/fields/builder stands, v5 save keys and shader/mesh fixes all present |
| (4) Backups for worker edits | **PASS for all code/shader/test/tool edits; MINOR readiness gap for 65 regenerated skin JSONs** |

**parity=UNVERIFIED.** No donor GPU A/B frame exists; this is a static, read-only audit of the current working tree, not a gate result and not a donor-fidelity statement. Per `PORT1TO1_PLAN.md:36`, the honest owner verdict remains `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty; this audit does not change that.

*End of AUDIT-PORT-GUARDS report. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/DEC_U_port_guard_audit.md`). No source, config, asset, test or backup file edited; no Godot job, gate, git mutation or donor execution. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.*
