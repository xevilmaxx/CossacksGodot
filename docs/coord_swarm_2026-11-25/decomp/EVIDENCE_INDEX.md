---
title: EVIDENCE INDEX — donor decompilation (2026-11-25)
area: donor decompilation
owner: COORD
updated: 2026-11-25
refreshed_with: late deep dives (Batch I) — new ids/paths in §"Late deep-dive evidence"
corrections_authority: ../CORRECTIONS.md (57 rows) — authoritative for reversals
status: living — refreshed 2026-11-25 with late deep dives
---

# 🗂️ Evidence index — donor decompilation lane

COORD maintains this index as DEC reports land. Each row: evidence id or exact
`path:offset`, what it proves, and the report that first recorded it. Workers should
cite the id/path here plus their own report. Every row carries its source label
`observed` / `derived` / `inferred` / `UNVERIFIED` / `CONFIRMED_INFEASIBLE`; no row grants a
donor visual-parity claim. Reversals are authoritative in `../CORRECTIONS.md` (57 rows) —
the stale `frame 0 ≠ bind pose` phrasing in the first table below is corrected by the DANIM-01
row in the late-dive table.

## Prior evidence carried forward (from `docs/decomp/*`, `investigation.cany/*`, wave-7 reports)

| Evidence | Proves | Source | Carried into |
|---|---|---|---|
| `ev_392885a6…` | `.oss` layout (skin payload) | `V72_mesh_conversion_feasibility.md` §1.1 | DEC-04 |
| `ev_0bbb20c1…` | `.osm` IDP2 structure | `V72_...md` §1.1 | DEC-04 / DEC-05 |
| `ev_6a6b0380…` | `.aaf` action ranges | `V72_...md` §1.1 | DEC-04 |
| `ev_e5ad6408…` | ACL playback semantics | `V72_...md` §1.1 | DEC-04 |
| `ev_030dff8c…`, `ev_10f78080…`, `ev_cc0ee18b…` | main view perspective projection | `G31_donor_3d_truth.md` §1–2a | DEC-07 / DSEL-02 |
| `fnd_22`, `fnd_23`, `fnd_24`, `fnd_26` (DB lane) | formations 149/46 nonzero; hotkeys 243; stage reseeding; envscales | `docs/decomp/DB_SCRIPTS.md` | DEC-03 |
| `.bind` section entropy 7.96 | packed/stripped 32-bit PE | `docs/decomp/DA_PE.md`, `docs/audit/DECOMP.md` | DEC-01 |

## New evidence from today's reports (COORD index)

| ID / path | Report | Donor path:offset | Claim | Verified by (2nd method/agent) |
|---|---|---|---|---|
| `fnd_1..fnd_6`, 14 evidence ids | `DEC_04_anim_formats.md` | `.oss` 24-B header; `.osm` IDP2 v8; `.aaf` AAF magic | anim/audio binary layouts (**frame-0 claim refuted — see DANIM-01 row in late-dive table**) | two-way checks; Craft Anything `fnd_1..fnd_6` |
| `fnd_7..fnd_9` | `RV_TRN_01_texgen_mask_reverify.md` | raw-byte finds in packed CODE; alpha seam deltas | 8×4×64 patch grid confirmed; eye planes UNVERIFIED | raw bytes vs Craft Anything `native_strings_find` (returned 0 — unsafe for packed binary) |
| `0x128` (3 bytes) | `DEC_01_binaries_rtti.md` | every `.cdx` vs `.exe` | `.cdx` = `.exe` with entry redirected into `.bind` (+0x310); `cossacks.exe` entry is in `CODE` | double-verified byte diff |
| `0x1fe0ef`, `0x1fe168` | `DSEL_02_donor_pick_math.md` | `cossacks.exe` | FOV API `GetCameraFieldOfViewByFocalLength(focal, viewportdimension)` + inverse exists | byte census; corrects "no FOV token" |
| `0x29F744`, `0x29F7F0`, `0x29F788`, `0x111248`, `0x11123D` | `DSEL_01_donor_selection_rectangle.md` | `cossacks.exe` | `GameManagerStartSelection` / `BeginSelection` / `CancelSelection`, `spmAdd`/`spmRunTime` enum strings | script + EXE signatures |
| `dmscript.global:171` | `DEC_05_terrain_formats.md` | `gc_meters_to_tile = 2` | port `TILE_M=2.0` IS donor-grounded | DEC-05 2-way; corrects DTRN-01 C6 |
| `.map` `TerrainMapBegin` | `DEC_05_terrain_formats.md` | 37-byte × 102,400 records | donor `.map` contains a per-cell terrain grid | 4 maps; semantics UNVERIFIED |
| `water.mat:86-106` | `RV_TRN_03_water_bindings.md` | all 21 lines commented; 0 binary hits | `heightmapwaves0.tga` is NOT `hmapTex` | line read + byte scans; DEC-05 alpha=255 |
| `0x453F00-0x454E1F` | `RV_TRN_03_water_bindings.md` | `cossacks.exe` | legacy `.bak` water shader has live Fresnel | byte scan |
| `resource.lib:47`, `brushes/selection.cfg:2-14` | `DSEL_01_donor_selection_rectangle.md` | donor text | yellow 1 px solid selection brush | full read + EXE tokens |
| `onmousemove.inc:32-34,152` | `DSEL_01`, `RV-SEL-01` (pending) | donor text | drag epsilon 0.005 world m (0.25 attack/guard) | 4 passes; `.inc` live-code convention under re-verification |

## Late deep-dive evidence (Batch I, added 2026-11-25)

Reports below are under `../reports/`. `DSEASON_01` / `DONAVAL_01` did not land and add no rows.
Labels are explicit; `UNVERIFIED` means exhaustive readable search found no value, none invented.
For reversals cite `../CORRECTIONS.md` (57 rows), not the superseded claim. No visual-parity claim.

| ID / path | Report | Donor path:offset | Claim (label) | Verified by (2nd method/agent) |
|---|---|---|---|---|
| `fnd_7..fnd_9` (Craft Anything) | `RV_TRN_01_texgen_mask_reverify.md`; reused by `DALPHA_01_alpha_subrect.md` | raw-byte finds in packed CODE; `alpha.bmp` seam deltas at ×64 | `[observed]` 8×4×64 alpha patch grid; eye planes remain UNVERIFIED | raw bytes vs `native_strings_find` (0 hits — unsafe on packed binary); two bitmap decoders |
| `alpha.bmp` pixel array @1070; `reftile.lib:10-12`; 245 `tiles.lib` sections | `DALPHA_01_alpha_subrect.md` §2–§5 | `tiles.lib:52-74,328-338,475-497`; `hf.pvl.sm.vert:34` | `[observed]` 32 patches (8×4×64²); full override inventory (8 × 64/2/2, 2 Summer-only 128, 235 defaults); `[derived, PARTIAL]` 4 sentinel complements, MAD 9.77, `(r,c)↔(3−r,3−c)`; tile→patch index `[CONFIRMED_UNVERIFIED]` | two independent decoders + 17,237-file / 11-binary byte scan |
| PFX layouts — `source.pfx`, `fx.tree`, `manager.lib`, `.mat`/`.ref`, DDS | `DFX_01_pfx_effects.md` §5, §13 | `source.pfx:30-64,102-178,1731-1803,2304-2339`; `fx.tree:4-63`; `env\pfx\particles.snow.cfg:2-158` | `[observed]` PFX is readable text (`section.begin`, no version): 44 sources, 24 effects (6 `refkey` children), 5 managers, 22 materials, 90 DDS + 6 BMP; smoke EndFrame 127 / PixelRatio 175 / AlphaTime 1.5; weather 70–100 (default 40 inactive). Numeric units `[UNVERIFIED]` | byte-offset census + script consumer (`pfx.script:12,43-85`); no rendered A/B |
| AAF catalog / bind-pose census | `DANIM_01_action_ranges.md` §3, §6 | 246 `.aaf`; `movie.script:857-858`; `bake_sprites.py:91-103,118-129` | `[observed]` 1,434 rows, 62 names, all `morph`, duration `(last−first+1)/30`; `[observed, 2 methods]` frame 0 bind in 335/335 `.oss` (max \|p\| 1.09e−6 m, peaukr f0 1.52e−7 m); DEC-04 refuted as indexing artifact. Engine skin form `[UNVERIFIED]` | sequential `read_oss` + quaternion check; bone-major offset-seek census; artifact reproduced (method C) |
| Relief pattern grids — `k_ravine_1` et al. | `DPATTERN_01_relief_grids.md` §3, §10 | `k_ravine_1` grid G=2866 / 11,592 B, −2.963627576828003 / +3.139820098876953 = `pattern.lib:549585-549586`; `generator.cfg:540-750` | `[observed, 2 passes]` 26 `w×h` float32 height windows; 680/680 `NativeSeason=Summer`/`Winter=True`; mountain grids all-zero + `terrainmeshN` props. Engine blend/flip `[UNVERIFIED]` | exact min/max match to `pattern.lib` + independent offset decode |
| `.bind` three-region layout | `DBIND_01_wus_bind.md` §3, §5, §8 | `cossacks.exe:0x55c600..0x55c8ff`, `:0x55c900..0x55f1ff`, `:0x55f200..0x58036f`; hash `0x488781ed` @`:0x55d804` | `[observed, 5 methods]` 768-B header + 11,264-B shared x86 loader + ~135 KB opaque payload; no container. Eye planes / FOV body / selection predicate `[CONFIRMED_INFEASIBLE]` | per-4K entropy profile + disassembly + `core_packed_files_list` refusal + codec sweep |
| `light.cfg` / camera offsets / light-space | `LIGHT_02_light_space.md` §2–§5 | `light.cfg:17,26-31` `(-0.344731152057648,+0.938701450824738,0,1)`, `lsParallel`; `light.ref:13-16` radius 20000 = `env.cfg:6`; `default.cameras` `UpY=1`; `water.dev.vert:22`; `hf.pvl.sm.vert:9,13,15,19` | `[derived, 4-way]` donor world Y-up, Y = elevation; `sun_world=normalize(P.xyz)` → flat-ground `dot=0.938701` at any tilt; water expression is local Z-up, not a world mapping. GL `w`/modelview `[UNVERIFIED]` | config byte read + light.ref magnitude + time-of-day patterns + `UpY=1`; rotation-invariance replay |
| Env configs / fog / sky / season | `DENV_01_environment.md` §2, §3, §6 | `colors.lib:23,34-43` via `env.cfg:16`; `skydome.cfg:8-9,11-20`; `time.cfg:5`; `clouds.weather:3`; `terrain.lib:12-15`; `particles.snow.cfg:2-158` | `[observed, twice]` scene fog `(60,100,150,1)` / 390–490, `FogMode=0` 0-based → GL_LINEAR (bridge UNVERIFIED); sky labels inverted, values correct; seasons are set swaps; 12 identical `.palette` files | two read passes + RTTI/binary crosswalk (`DEEPDEC-04` B3/B8/T14) |
| Morale constants | `DFORM_01_formations_morale.md` §Morale verdict | `dmscript.global:156,478,657`; `units/global.inc/progress.inc:5-35,174-175`; `lib/unit.script:7175-7238` | `[observed, twice]` no numeric morale: 373 code files 0 hits; disband `count<0.25×base` (human only); retreat = move mode 2; AI force retreat. Binary-only behaviour `[UNVERIFIED]` | whole-tree scan (2,559 files) + targeted reads; independent of DEC-02 corpus |
| Unit roster constants | `DUNIT_01_unit_roster.md` §6–§7 | `unit.script:493-501,5652-5689,571-581`; `G:180` (`gc_buildtime_modifier=10`); `C:2715` (highlander → England) | `[observed]` ~90 sids; F/W/St/G/I/C; `floor(base×(costpercent/100)^owned)`; build time frames÷32 s (buildings ×10). Population `[UNVERIFIED]` | fresh `path:line` reads + port parity matrix; braced values treated as history |
| Audio event / bank constants | `DAUDIO_01_sound_events.md` §3–§4, §8 | `sound.script:109-231`; `units.snd` 247 + `interface.snd` 51 + `ambient.snd` 27 = 325; `showunitcontrol.inc:1024-1027` | `[observed, twice]` 325/325 clips; 59 live indices; selection interface-bank **non-positional**; radii 25/50/75/100, UI 8000; order acks commented. Loudness units `[UNVERIFIED]` | basename set equality + `os.path.exists` + `cossacks.exe` raw-byte find |
| Map / skirmish constants | `DMAPGEN_01_skirmish_options.md` §2–§3 | `donewgame.inc:42-49,243-246`; `showcustomgame.inc:182-201`; `dmscript.global:236,238,240`; 11 reseed sites in `dogenerate.inc`/`initmapgen.inc` | `[observed, 2–3×]` sizes 256/320/480/640; 9 shapes + Random; 5 relief; seasons 0/2/3 (no selectable 1); 64-bit `randkey0/1` + version gates <53…<91. AI tag/id `[UNVERIFIED]` | three independent table reads + `dmscript.global` count cross-check |
| Building stage constants | `DBUILD_01_building_stages.md` §2–§5 | `floor(progress*4)` mesh suffix 1–4; 2 death stages 30+30 frames; `rallypoint.prop:19-21,25`; `interface.snd:80-121`; smoke onset ≈ 88.75 % HP | `[observed/derived]` 4 construction stages + scaffold; 2 death stages; rally scale 0.0525 / roll 45; no construction dust, finished-only damage smoke. Stage visual content `[UNVERIFIED]` | independent second-method smoke-chain read + fresh byte read of rally prop |
| LFS pointer / atlas transport | `ATLAS_01_transport.md`; `../CORRECTIONS.md` row 53 | 134-byte pointer in-tree; ~180 MB split parts; `Image.load()` fallback | `[RESOLVED]` big PNG is LFS-tracked but split parts are ordinary Git blobs → clone size unchanged; SHA-256 identity of concatenation vs single PNG verified twice | hash ×2 + file inventory (coordination evidence) |

---

**Related:** `SUMMARY.md` (§13 late dives, §9 reversals) · `../CORRECTIONS.md` (authoritative,
57 rows) · `DEC_0x_*.md` · `../reports/` · `investigation.cany/investigation/`.
