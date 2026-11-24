---
id: COMP-03 / COMPLETENESS_03_donor_fidelity
owner: COMP-03
date: 2026-11-24
scope: "DONOR-FIDELITY COMPLETENESS of the variant3d/ 3D port — synthesise 9 AUDIT3D + 6 TERRAIN2 + 10 DEEPDEC + V7-60..92 into a subsystem-by-subsystem verdict, verifying every implementation claim in CURRENT source."
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTION__NO_GIT__NO_EDIT_OUTSIDE_THIS_REPORT
governing_rules:
  - "COMPLETENESS_CHARTER.md:7-15 — every claim needs path:line or job/report id; earlier claims UNDONE until verified in current source; no visual parity claim without donor A/B (none exists)."
  - "READ-ONLY: no source/asset/config/test/git edits; no Godot jobs launched (existing result JSONs/reports only)."
parity_guard: "No donor GPU A/B frame exists. All visual-parity statements are UNVERIFIED by charter."
---

# COMPLETENESS-03 — donor-fidelity completeness of `variant3d/`

## 0. Method and evidence discipline

- Read all 9 `AUDIT3D_0*_*.md`, all 6 `TERRAIN2_0*.md`, all 10 `DEEPDEC_0*.md`, and the
  implementation reports V7-60..92 (focus: V760/V761/V762/V764/V765/V770/V771/V774/V782/V783/V784/V785/V786/V790/V792).
- **Every implementation claim was re-verified in CURRENT source** (`variant3d/scripts/*.gd`,
  `variant3d/shaders/*.gdshader`, `variant3d/assets/**`, `variant3d/data/*.json`,
  `variant3d/config.json`). Report-only claims are explicitly labelled as such; where a
  report and current source disagree, **current source wins**.
- Simple file/hash/JSON-count measurements: read-only shell commands; no Godot launch, no git.
- Verdict vocabulary: **TRANSLATED** = donor data/equations are present in current source;
  **APPROXIMATED** = labelled port approximation (donor-grounded input, port mechanism);
  **PORT-ONLY** = no donor counterpart; **MISSING/UNVERIFIED** = absent or no readable proof.
- RAG: **Green** = translated in current source; **Amber** = approximation/port extension with
  donor grounding; **Red** = missing/unverified with no donor-parity evidence. Mixed subsystems
  carry a split verdict.

### 0.1 The five strict checks (asked for explicitly) — all answered from current source

| # | Strict question | Answer (OBSERVED in current source) |
|---|---|---|
| S1 | Do **live tile indices actually reach the shader**? | **YES.** `world3d_terrain.gd:392-418` decodes `game.tileblock` (live `PackedByteArray`, `game.gd:53` / `:1610-1689`, dumped at `main.gd:741`) into `_tile_indices`; `:628-631` writes `uvs2[i] = Vector2(float(tid),0.0)` (with a port clamp at `:629-630`); `:649` attaches `ARRAY_TEX_UV2`; `:658-659` binds the V7-86 `ShaderMaterial`; `terrain_tileindex.gdshader:258` reads `v_tile = UV2.x` and `:267-271` samples the donor atlas cell. Verified E1/E2 below. (V792 probe 251 measured 102,400 UV2 entries, 0 mismatches — report claim, not re-run.) |
| S2 | Does **water use donor textures/literals**? | **YES — now it does.** `water3d.gd:81` binds `res://assets/terrain/water_png/diffusewaves0.png` (donor `diffusewaves0.bmp`, 256², `tfLuminance`); `:148-165` sets `-0.25 / -0.1 / 2.96` (`texturemap.inc:29-31`), `0.57/1.07`, `170/120/30`, donor colours; `water3d.gdshader:24-26,41-44,66-75,138` uses them in transcribed donor equations. Old constant `Color(0.19,0.245,0.255,0.45)` quad at `world3d_terrain.gd:431-462` is now **fallback-only** (`:679-681`). This **closes** AUDIT3D-02 G5 / AUDIT3D-03 P1-2 / TERRAIN2-03 P0-1 as a data-level fix. |
| S3 | Are **donor player colours applied**? | **PARTIALLY — yes on 3D entities/buildings and the FX pennant; not in the minimap, and always slot 0 for the rally.** `world3d_entities.gd:68` loads `res://data/donor_key_colors.json` (13 slots, measured); `:293-296` identity player→slot; `:311-320` sets `StandardMaterial3D.albedo_color = tint` **over the donor albedo texture** (uniform-0 analogue); `:330-344` per-batch/per-surface override. `world3d_fx.gd` loads the same JSON for `_player_color`. BUT `world3d.gd:502` calls `fx.draw_rally(rp, 0)` — hard-coded player 0 — and `hud.gd:144-151,1577` still uses the port-invented 12-colour `MM_PLAYER_COLORS`. This closes AUDIT3D-02 G1/G2 at data level but leaves G3/G7 partially open (honesty labels at `world3d_entities.gd:203-204`: uniform-0 operation, alpha, >1.0 clamp UNVERIFIED). |
| S4 | Is **flat-root animation mathematically donor-equivalent but visually UNVERIFIED**? | **YES — exactly that.** DEEPDEC-06 (`DEEPDEC_06_models_anim.md:18-38,92-140,162-214`) PROVES `.oss` bone tracks are **absolute deltas from a bind frame**, parent chain pre-folded, identity inverse-bind: the flat-root skin `Σ w_i (R_i v + p_i)` IS the donor deformation equation. Current source: `anim3d.gd:32,63,104,178-179,200-201,524-525` retains `PORT APPROXIMATION — NOT DONOR PARITY`, `rig=BLOCKED_RIG`, `visual="UNVERIFIED"`, `verified=false`; `skin_vertices` at `:410-434`, `pose_for` at `:489-525`. 55 shipped skins auto-register (`anim3d.gd:112,742-765` + `assets/models/skin/index.json`, measured 55 entries), and `world3d_entities.gd:980-995` consumes `pose_for`. So it is **mathematically donor-equivalent, active in shipped runtime, but frame-decimated and visually UNVERIFIED** — label correctly retained. |
| S5 | **Which fog is active?** | **Only the port fog-of-war overlay, and it is OFF by default.** `world3d/config.json` → `"fog_of_war": false`; the active mechanic is per-tile fog-of-war quads in `world3d_fog.gd:3-44,110-141` (port 0.78/0.30/0.00 alpha ladder, `FOG_Y_OFFSET=0.03`, explicitly not donor depth fog). Donor LINEAR/EXP/EXP2 **view-depth** fog equations are present but **gated off**: `terrain_tileindex.gdshader:169,342-351` `fog_mode=0.0`; `water3d.gdshader:55,225-228` + `water3d.gd:164-165` `fog_enabled=0`. DEEPDEC-04 (`DEEPDEC_04_fog_light_sky.md:90-105,122-135`) shows donor scene fog IS active in the donor (`colors.lib` FogStart 390/FogEnd 490/FogMode 0), camera `DynFogDepth=False`, and the port FOW↔shader binding is UNVERIFIED. **The port's active fog is a different mechanic; no donor view-depth fog is rendered.** |

## 1. Evidence table — current source (path:line) + governing report

| # | Subsystem / claim | CURRENT source evidence (`path:line`) | Report basis | Verdict |
|---|---|---|---|---|
| E1 | Live tile index → shader | `variant3d/scripts/world3d_terrain.gd:392-429` (`_decode_tile_indices`), `:623-631` (`uvs2.x=tid`), `:649` (`ARRAY_TEX_UV2`), `:658-663` (tileindex material); `shaders/terrain_tileindex.gdshader:202-207,216,258-259,267-271` | V792 §2/§3; TERRAIN2-06 E01/E03; DEEPDEC-05 §3 | TRANSLATED (index + atlas + equations), faces MISSING |
| E2 | Tile atlas / masks from donor | `assets/terrain/atlas/tile_index_atlas.png` 16384×8192 + `.manifest.json` (124 names/121 filled — V785 §6); `alpha.png` 512×256, `alphavert.png` 1024×512; `world3d_terrain.gd:208-281` (loader/mask R→A repack) | V785; TERRAIN2-02 D18/D19; DEEPDEC-02 §3.3 | TRANSLATED art; APPROX packing/alpha mapping |
| E3 | Face mode / 25° cliff faces | `world3d_terrain.gd:623-624` comment "A5 face flags not landed"; `:631` always `UV2.y=0.0`; `terrain_tileindex.gdshader:196-207,259,303` consumes `UV2.y` but no face promotion; `V786` §2.2 | V792 §6.1; V786 §2/§6; TERRAIN2-01 E35-E38; DEEPDEC-02 §3.3/§6 #5 | MISSING (face promotion) / UNVERIFIED (eye planes) |
| E4 | Water donor texture + literals + equations | `water3d.gd:81,148-179,248-261`; `water3d.gdshader:24-26,41-45,66-75,138,149-232` | V784 §3/§7; DEEPDEC-03 §4; TERRAIN2-03 §2/§4 | TRANSLATED (equations/literals/texture); APPROX mechanism |
| E5 | Water reflection/shadow/hmapTex | `water3d.gd:163-168,178-179` reflection disabled (`reflection_enabled=0`), neutral height texture default; `water3d.gdshader:45,74-75,207-213` port substitutes; `bind_height_grid` at `:248-261` labelled substitute | V784 §3/§8; DEEPDEC-03 §6.4; TERRAIN2-03 UNV-1/2 | APPROXIMATED / UNVERIFIED |
| E6 | Donor light/sky rig wired | `world3d_terrain.gd:494-528` (`_make_environment`, `WorldEnvironment` + `DonorSun` at `:519`), called `:682`; `:57-64` donor sun constants | V760 §2/§4; AUDIT3D-03 P0-1 closed | TRANSLATED sun position; APPROX energies |
| E7 | Donor ambient/diffuse colours NOT consumed | `world3d_terrain.gd:59-60` declares `DONOR_AMBIENT`/`DONOR_DIFFUSE`; `:508-512` uses port-tuned `Color(0.86,0.88,0.82)` and energies 1.45/1.10/1.7 | V760 §3/§6.2 ("recorded but not consumed") | APPROXIMATED (donor values unused) |
| E8 | Port-tuned sky; no clouds | `world3d_terrain.gd:501-506` `ProceduralSkyMaterial` colours `(0.18,0.30,0.42)` etc.; no cloud node anywhere in `variant3d/scripts/**` | V760; DEEPDEC-04 T8/T10/T11; TERRAIN2-03 §2.2 | APPROXIMATED sky / MISSING clouds |
| E9 | Fog active (see S5) | `config.json:"fog_of_war":false`; `world3d_fog.gd:3-44,110-141`; `terrain_tileindex.gdshader:169,342`; `water3d.gd:165` | DEEPDEC-04 §2.1/§3; TERRAIN2-03 §2.3 | PORT-ONLY FOW; donor depth fog dormant |
| E10 | Models real donor geometry | `assets/models/obj/*.obj` (172 available — AUDIT3D_TRIAGE G3 closed 79/81); `world3d_entities.gd:52-55,293-317` loads manifest/OBJ/tex; bbox transform `:216-289`; entity feed `world3d.gd:311-321,550,596` | AUDIT3D-01; V762; V763; V772 | TRANSLATED (with cube fallback for unresolved sids) |
| E11 | Player tint applied | `world3d_entities.gd:68,258-296,311-344,832,866-870`; `data/donor_key_colors.json` 13 slots (measured); `world3d_fx.gd` same JSON; `world3d.gd:502` hard-codes rally player 0; `hud.gd:144-151,1577` port palette | V761; V765; AUDIT3D-02 §2/§4 | TRANSLATED at data level; partial render coverage |
| E12 | Animation active + labelled | `anim3d.gd:112,410-434,489-525,742-765`; `assets/models/skin/index.json` 55 entries (measured); `world3d_entities.gd:980-995` consumes `pose_for`; labels `:92-94,187-204` | DEEPDEC-06; V764; V774; V778; V779 | APPROXIMATED (donor-equivalent data, port policy, visual UNVERIFIED) |
| E13 | FX donor-literal grounding thin | `world3d_fx.gd` quote 3 `bullettrail` literals + port colours; `world3d.gd:477,502` now calls ghost/rally; donor 5-layer `shotmusket` composition absent | AUDIT3D-06 §3-4; DEEPDEC-07 §3-4; V773; V776 | APPROXIMATED (port primitives; only 3 donor literals) |
| E14 | Audio clips/events donor; culling port; no spatial | `audio.gd` differs from app (V771 3D-aware culling using port 16/60/20/0.15/12 literals, not donor 25/50/75/100); no `AudioStreamPlayer3D` anywhere | AUDIT3D-06 §5; V771; DEEPDEC-07 §5-7 | TRANSLATED clips/events; PORT-ONLY culling; MISSING spatial |
| E15 | Camera donor maths applied; FOV/minimap offset open | `camera3d.gd:54-59` `DONOR_FOCAL=400`, `FOV_DEG_ASSUMED=17.27`; `:169-170` donor bounds; `:238` pitch; `:393` one-arg `jump_to_world`; V790 height/wheel/pan landed | DEEPDEC-01 §3/§6; DEEPDEC-08 §2/§5; AUDIT3D-05; V790 | APPROXIMATED (FOV BLOCKED, donor ArcTan offset absent) |
| E16 | Minimap 3D branch + capture | `hud.gd:56-58,201-213,1406-1450` `_render_mode_3d`/`jump_to_world` branch; `main.gd:166,1191-1199,1810-1879` real `Screenshot3DViewport` capture | V766/V767/V770; AUDIT3D-09 G1 closed | TRANSLATED mechanics; donor frustum offset UNVERIFIED |
| E17 | Sim/AI/economy byte parity + divergences | hashes: `game.gd`, `ai.gd`, `world.gd`, `mapgen.gd`, `camera.gd`, `selftest.gd` **identical** to app; `audio.gd`/`data.gd`/`main.gd` diverge for 3D adapters. Divergences in `ai.gd` mine order / absolute `AI_ATTACK_FORCE` (report input, not re-simmed) | AUDIT3D-04 E01-E13; DEEPDEC-09 §4-5; TERRAIN2-05 RB-07 | TRANSLATED data; APPROXIMATED rules (measured wave fail RB-07) |
| E18 | Donor `.map` importer exists, not runtime | `variant3d/tools/import_donor_map.py` (measured present; v1.1.0 parses height/tiles/placements); runtime terrain still uses procedural dump (`world3d_terrain.gd:347-386`) | V783 §4/§8; DEEPDEC-05; AUDIT3D-08 row 16 | TRANSLATED tool; not integrated (UNVERIFIED semantics) |
| E19 | HUD ported subset | `hud.gd` resource/selection/minimap widgets ported; minimap 200² port rect vs donor 240² bottom-left (DEEPDEC-08 E22); port palette at `:144-151` | DEEPDEC-08 §3/§6; AUDIT3D-05 E10/E12 | APPROXIMATED |
| E20 | No donor A/B anywhere | V792 §5 and V782 §4 took windowed `Screenshot3DViewport` frames **outside the repo**; no donor frame was captured/compared. COMP charter forbids a parity claim. | DEEPDEC all; TERRAIN2-05 DF-01; AUDIT3D-09 §4 | MISSING/UNVERIFIED (universal) |

## 2. Subsystem-by-subsystem verdict

| Subsystem | Verdict | What is actually donor-faithful in current source | Why not fully translated (strict residual) |
|---|---|---|---|
| **Terrain relief / mesh** | **APPROXIMATED** | Live `game.height[]` (±2.964 donor plateau/ravine constants); one 320² indexed mesh, central-difference normals; donor water level −0.25 | Donor `.map` relief unreadable (DEEPDEC-05); mesh topology/LOD/height→triangle connector UNVERIFIED; `TILE_M=2.0` port-only (TERRAIN2-01 §6 #1). |
| **Terrain tiles / UVs / faces** | **TRANSLATED** (index+atlas+equations) / **MISSING** (faces) | Live donor tile id → `UV2.x` → donor atlas + donor alpha masks + donor shader equations with donor literals (E1/E2) | `UV2.y=0` everywhere; 25° `vf/vs/f/s` promotion not landed; eye-plane/texture-matrix values engine-bound; atlas packing/alpha sub-rect mapping APPROX (E3). |
| **Water** | **TRANSLATED** (data/equations) + **APPROXIMATED** mechanism | `diffusewaves0.png` + all donor literals + fBm/depth/shore/foam/spec/fog equations, height-aware via `bind_height_grid` (E4) | `hmapTex`/reflection FBO/shadow binding UNVERIFIED; reflection disabled, 3-tap PCF omitted (`watershade=1`), fog LINEAR mode not ported; port `map_size`/height substitute (E5). |
| **Fog / lighting / sky / clouds** | **APPROXIMATED** (lighting) / **APPROXIMATED** (fog) / **MISSING** (sky fidelity, clouds) | Donor sun position/direction translated into a real `WorldEnvironment`+`DirectionalLight3D` (E6); donor fog equations present but dormant (E9) | Donor ambient/diffuse recorded but unused, port energies (E7); port-tuned sky, no clouds (E8); active fog is port FOW overlay only, off by default (S5/E9). |
| **Models** | **TRANSLATED** (with approximation fallback) | 116+ donor-derived OBJ from `.oss`/`.osm`, donor bbox/env scale, donor albedo PNG, real entities at runtime (E10) | Unresolved sids still fall back to invented cube (AUDIT3D-01 P0-2 residual); env cut-out alpha-scissor port approximation. |
| **Animation** | **APPROXIMATED** (donor-equivalent data, visually UNVERIFIED) | Flat-root skin is mathematically the donor equation (S4); 55 shipped skins auto-register and morph per donor AAF frame (E12) | Frame decimation, port action mapping (`dead→death/moving→walk/else idle`), generated normals, Godot UV V-flip, no donor A/B — label correctly retained. |
| **FX** | **APPROXIMATED** | Ghost/rally now reach runtime (E13); 3 donor `bullettrail` literals | Port primitive meshes/colours; donor 5-layer shot composition, PFX art/semantics and impact FX absent; rally pennant hard-coded player 0. |
| **Audio** | **TRANSLATED** (clips/events) + **MISSING** (spatial) | 325 donor `.ogg` + identical event dispatch; 3D-aware distance culling added (E14) | No `AudioStreamPlayer3D`/bus, culling uses port 20–60 m literals not donor 25/50/75/100; donor grid aggregation/emitter semantics not reproduced. |
| **Camera / input / minimap / hotkeys** | **APPROXIMATED** | Donor zoom bounds (20/58), −32° tilt, edge bands 8/24, additive wheel delta, zoom-independent pan (E15); minimap LMB jump wired (E16) | FOV assumed 17.27° (donor `FocalLength=400`, sensor BLOCKED); donor ArcTan offset/double-click jump not implemented; patrol P/Q, control-group semantics and selection rectangle are port-only/gaps. |
| **AI / economy / capture** | **APPROXIMATED** (sim data shared; rules diverge) | `game.gd`/`ai.gd` byte-identical to 2D; donor constants/ratios transcribed (E17) | Gold-mine ordering, absent +25/+300 AI reserve, absolute `AI_ATTACK_FORCE=120` port invention (measured wave stall RB-07), capture % vs donor binary flip, peasant/artillery capture inversion. |
| **Map data import** | **TRANSLATED** (tool) / **NOT INTEGRATED** | Read-only `.map` importer decodes donor height grid + tile histograms + placements (E18) | Importer output is a tool/dump input, not the runtime terrain source; tile-record/named-record semantics, row orientation, metres-per-cell UNVERIFIED. |
| **HUD** | **APPROXIMATED** | Resource/selection/unit-control/minimap widgets ported (E19) | 200² vs donor 240² minimap, port palette, donor frustum/box rotation and atlas primitives UNVERIFIED; no 3D drag-selection rectangle. |

## 3. RAG scorecard

| # | Subsystem | RAG | Verdict class | One-line reason (current-source evidence) |
|---|---|---|---|---|
| 1 | Terrain relief / mesh | 🟡 Amber | APPROXIMATED | Live donor height constants, port mesh topology; `.map` relief + cell-size UNVERIFIED. |
| 2 | Terrain tiles / UVs | 🟢 Green | TRANSLATED | Live `game.tileblock` → `UV2.x` → donor atlas + donor shader (`world3d_terrain.gd:631,649`; shader:258). |
| 2b | Terrain cliff faces / eye-plane UV | 🔴 Red | MISSING/UNVERIFIED | `UV2.y=0` always (`:631`); 25° promotion & eye planes not landed (V792 §6.1). |
| 3 | Water | 🟢 Green (data) / 🟡 Amber (mechanism) | TRANSLATED + APPROX | Donor `diffusewaves0.png` + literals + equations (`water3d.gd:81,148-165`); reflection/shadow/hmapTex substitutes. |
| 4 | Lighting | 🟡 Amber | APPROXIMATED | Donor sun rig wired (`world3d_terrain.gd:494-528`); donor ambient/diffuse recorded but unused (`:59-60,508-512`). |
| 5 | Fog | 🟡 Amber (port FOW) / 🔴 Red (donor depth fog) | PORT-ONLY / DORMANT | Only FOW overlay active, off by default; donor fog gated `fog_mode=0`/`fog_enabled=0` (shader:169; water3d.gd:165). |
| 6 | Sky / clouds | 🔴 Red | APPROXIMATED sky / MISSING clouds | Port-tuned `ProceduralSkyMaterial`; no cloud nodes (vs donor 12 billboards + wind). |
| 7 | Models | 🟡 Amber | TRANSLATED w/ fallback | Real donor OBJ + tint + feed; invented cube remains for unresolved sids. |
| 8 | Animation | 🟡 Amber | APPROXIMATED | Mathematically donor-equivalent flat-root, active, but decimated & visually UNVERIFIED (S4/E12). |
| 9 | FX | 🟡 Amber | APPROXIMATED | Port primitives + 3 donor literals; ghost/rally wired; rally colour hard-coded 0. |
| 10 | Audio | 🟡 Amber | TRANSLATED + MISSING spatial | Donor clips/events; port culling literals; no spatial audio. |
| 11 | Camera / input / minimap / hotkeys | 🟡 Amber | APPROXIMATED | Donor bounds/tilt/wheel/pan; FOV assumed, donor minimap offset absent. |
| 12 | AI / economy / capture | 🟡 Amber (rules 🔴) | APPROXIMATED | Sim data byte-identical; donor rules diverge; measured wave failure RB-07. |
| 13 | Map data import | 🟡 Amber | TRANSLATED tool / not integrated | Donor height/tile/placement importer present; runtime uses procedural dump; semantics UNVERIFIED. |
| 14 | HUD | 🟡 Amber | APPROXIMATED | Ported widget subset; minimap size/palette/frustum diverge. |
| 15 | Cross-cutting visual parity | 🔴 Red | MISSING/UNVERIFIED | No donor GPU A/B frame exists (charter forbids claim). |

**Tally:** Green 2 (tiles index, water data); Amber 10; Red 3 (faces, sky/clouds/donor fog, A/B). **No subsystem is fully TRANSLATED end-to-end** because every lane terminates in UNVERIFIED visual parity.

## 4. Top 5 donor-fidelity gaps (prioritised)

1. **No donor GPU A/B — visual parity UNVERIFIED for every subsystem (E20).** Real 3D pixels exist (`Screenshot3DViewport`, `main.gd:1191-1199`), but no donor frame was ever captured or compared; V782/V792 "before/after" frames are port-only and not pixel-aligned. Highest-leverage fix: build a repeatable donor A/B harness (TERRAIN2-05 DF-01; DEEPDEC-10 unknown #6). **Blocks acceptance of all fidelity claims.**

2. **Cliff/face tiles and the donor UV model are absent (E3).** Live indices and atlas art reach the shader, but `UV2.y=0` for all 102,400 cells (`world3d_terrain.gd:631`), so the donor `rockNvf/vs` 25° face variants, `alphavert` eye-linear projection, and eye-plane texgen (`hf.pvl.sm.vert:26-33`) are not reproduced; atlas packing, alpha sub-rect mapping and SM20/SM30 selection remain APPROX/UNVERIFIED (V792 §6.1-6.3, V786 §2/§6).

3. **Sky, clouds and donor lighting values are not consumed (E6-E9).** The rig uses port-tuned `Color(0.86,0.88,0.82)` and energies 1.45/1.10/1.7 while the donor `light.cfg` ambient/diffuse constants sit unused in `world3d_terrain.gd:59-60`; sky is a port-tuned `ProceduralSkyMaterial`; no cloud billboards exist; only the port FOW overlay is active (off by default) and the donor view-depth fog equations are gated off.

4. **Camera absolute FOV and minimap target math remain donor-BLOCKED/port-approx (E15-E16).** `FOV_DEG_ASSUMED=17.27` (`camera3d.gd:59`) vs donor `FocalLength=400` with no sensor/projection readable (DEEPDEC-01 §7; AUDIT3D-05 E3 ≈2.3× ground-width error); `jump_to_world` is one-arg (`camera3d.gd:393`) with the donor `ArcTan`/heading offset and double-click instant jump documented but not implemented (DEEPDEC-08 §2/§5).

5. **FX/audio semantics and AI rules are still port-authored (E13-E14, E17).** FX use port primitives/colours with only three `bullettrail` literals (donor 5-layer `shotmusket` composition absent); audio has no spatial emitter model and uses port culling literals instead of donor 25/50/75/100 radii; AI retains an absolute `AI_ATTACK_FORCE=120` port gate and missing gold-first mine/reserve logic — a measured wave-stall fail (TERRAIN2-05 RB-07; DEEPDEC-09 §5).

## 5. Honest limitations / open questions

- All verifications are static current-source reads plus pre-existing probe/result artefacts; **no Godot job was launched and no donor binary/text was re-read** by this agent (reports supply donor `path:line` and evidence ids).
- Report-vs-source drift checked where it mattered: V774's "no skin registered in shipped runtime" caveat is **superseded** by V7-78 auto-registration (`anim3d.gd:742-765`, 55 skins measured present); V760's "no light rig" P0 and AUDIT3D-09's "no 3D pixels" G1 are **closed in current source** (E6, E16).
- V7-92's windowed capture and V7-82's before/after frames are stored **outside the repo**; their qualitative readings were not re-verified visually.
- Counts measured read-only this pass: 55 skin entries, 13 donor key-colour slots, OBJ/atlas/tool file presence, file hashes (game/ai/world/mapgen/camera/selftest identical; audio/data/main intentionally diverged).
- No git operations; no source/asset/config/test edits; only this report file written.

---

*COMP-03 — donor-fidelity completeness. Verdict vocabulary and RAG applied per COMPLETENESS_CHARTER.md:17-21. Visual parity is not claimed anywhere; all such statements remain UNVERIFIED pending a donor A/B.*
