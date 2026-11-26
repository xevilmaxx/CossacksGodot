---
id: X67
ticket: "TERRAIN-SWARM-2026-11-26 / X67 — locate and decode envscales.cfg; decide terrain-shading relevance"
agent: "X67 (READ-ONLY worker, DONOR-FIRST terrain swarm; no code edits, no Godot jobs)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
owner_file: docs/terrain_swarm_2026-11-26/reports/X67_envscales_decode.md
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
labels_used: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
verdict: "DEFERRED for terrain shading / I10; DECODED in full as a non-terrain prop-instance scale table"
scope_guard: "Exactly one repo file written (this report). Donor walked/read via os.walk/open('rb') only; no donor file written/copied/executed; no source/shader/config/asset/test/git/Godot-runner state touched. Scratch only in %TEMP%\\opencode\\envscales\\."
sources_read: "CHARTER.md; reports/X33_donor_text_coverage.md; reports/X35_lighting_env_spec.md; spec/05_WATER_SHORE.md; spec/06_TILE_AND_ATLAS.md; reports/A04_landscape_props.md, F07_mill_fields.md, F08_flora_minerals.md, V07_relief_asset_readiness.md, V03_open_items_resolution.md, X57_env_objects_decode.md, spec/00_EVIDENCE_INDEX.md (cross-check); donor envscales.cfg, env.cfg, createenvironemttest.inc, editor.aix, field.prop, fir.prop, plantain3.prop, reftile.mat, pattern.lib, cossacks.exe/editor.exe byte scan; port terrain_donor_shader.gdshader, world3d_entities.gd, tile_atlas_loader.gd, terrain_donor_mesh.gd."
passes: "P1 os.walk locate; P2 byte/line/encoding census; P3 structural parser (26 groups/122 records); P4 name→prop/actor/DDS cross-reference; P5 consumer search (scripts + EXE byte strings); P6 pattern.lib Scaling cross-check with byte-offset vs line-number adjudication; P7 I10 uniform/atlas overlap check; P8 count/duplicate/balance verification; P9 independent reconciliation against landed X57 (field/prop mismatch, anisotropic plantain3 scale, editor.aix registry vs call site)."
---

# X67 — `envscales.cfg`: full decode and terrain-relevance verdict (2026-11-26)

## 0. Executive summary

1. **[O] Location premise corrected.** No env-scale config exists under `C:\Games\Cossacks 3\data\env\**` (92 files, 9588987 B) or `data\materials\env\**` (172 files, 240055724 B). The only file in the whole donor tree whose name contains `envscale` is **`C:\Games\Cossacks 3\data\game\var\envscales.cfg`** (25,612 B; 869 CRLF lines; sha256 `5c3ac8f935ea23d457eba42a89e63999cbf6f84a01a8ded0f3d42cae3332789f`). This matches X33 §4.2 E (`data\game\var\envscales.cfg`, 25,612 B) and closes X33's "NEEDS READ" item. §1 records the search.
2. **[O] Format decoded completely:** plain ASCII/latin-1 DScript parser text, one `generator` section, one `EnvGroups` struct, three `//` comments, **26 groups / 122 records**, each record exactly `name`, `scale`, `minscale`, `maxscale`. Balanced tokens: 1 `section.begin`, 175 `struct.begin`, 175 `struct.end`, 1 `section.end`. All 122 records carry all four keys; no missing fields. Full verbatim table with path:line in §2.3.
3. **[D] The `scale` is a per-object instance scale for environment *props*, not a terrain/material shading or texture-tiling value.** All 122 names resolve to a base `.prop` under `data\objects\env\`; the only readable consumer (`scripts\editor.inc\createenvironemttest.inc:19-57`) loads the file through the generic parser and calls `SetGameObjectScaleByHandle` on env-race game objects. `minscale`/`maxscale` are multiplicative jitter bounds applied to that object scale (`:48-57`). Cycle counts: 4 records `1/1` (field + 3 mines), 9 records `0.95/1.05` (grass families), 109 records `0.85/1.15`.
4. **[D]/[U] No active skirmish consumer was recovered.** The consumer script is entirely comment-prefixed (`[*] = ;`) and its `SetGameObjectScaleByHandle(goHnd, scale, scale, scale)` call is itself inside a `{…}` comment block (`:46-47`); neither `cossacks.exe` nor `editor.exe` contains the ASCII literals `envscales.cfg`, `EnvGroups`, `minscale` or `maxscale` (§5). The config is loaded, if at all, through generic DScript parser opcodes whose call site is not readable. Runtime application in shipped skirmish is **[U]**; the *semantics* are **[O]/[D]** from file structure + consumer + name→asset binding.
5. **[D] TERRAIN-SHADING VERDICT: NO EFFECT → DEFERRED.** I10's `atlas_grid`, `uv_repeat`, `face_scale`, lighting triple and water levels are all cited to *other* donor sources (`reftile.lib`, `dmscript.global:171`, `reftile.mat:124-126/150-152`, `light.cfg`, `generatemap.inc`/`texturemap.inc`), never to `envscales.cfg`. Numeric coincidences (`0.5` vs `uv_repeat=0.5`, `0.25` vs water level `−0.25`) are coincidences, not citations (§6 C5). `0.125` — the donor `alphavert` TextureScale — **does not occur anywhere in `envscales.cfg`**. §7 gives the full I10 comparison; §8 is the DEFERRED statement.
6. **[D] Donor-grounded values ARE available for the prop lane, and the port already carries them:** `world3d_entities.gd:128` `ENV_SCALE = {"mine":0.3152,"stone":0.329,"tree":0.5}` and `:166-170` jitter bands `none=1/1`, `tight=0.95/1.05`, `wide=0.85/1.15`. These are **not** I10 uniforms and must not be moved into the shader. No I10 value is replaced by this report.

**No donor visual parity claim is made. No donor GPU A/B frame exists and no donor binary was executed.**

## 1. Location — multiple passes (ticket premise vs donor reality)

| Pass | Instrument | Result | Label |
|---|---|---|---|
| P1a | `os.walk` over all of `C:\Games\Cossacks 3`, filename filter `envscale|scale` with env/cfg | **Exactly one hit**: `data\game\var\envscales.cfg`, 25,612 B | [O] |
| P1b | Full inventory of `data\env\**` | 92 files / 9,588,987 B: `env.cfg`, `time.cfg`, `lights\light.cfg|presets|ref`, `colors\*`, `clouds\*`, flares/skydome/pfx textures — **no scale config** | [O] |
| P1c | Full inventory of `data\materials\env\**` | 172 files / 240,055,724 B: `env.mat` + 171 DDS — **no scale config** | [O] |
| P1d | Byte scan of `cossacks.exe` (5,768,048 B) and `editor.exe` (7,874,416 B) for `envscales.cfg`/`EnvGroups`/`minscale`/`maxscale` | 0 hits in both (generic script-parser strings `SetGameObjectScaleByHandle`/`GetGameObjectScaleXByHandle` do exist: 1 hit each) | [O] |

**Accepted reading [O]:** the "actual env scale config" is `data\game\var\envscales.cfg`; the ticket's two candidate trees contain only the *assets* whose instance scales the file governs (`data\materials\env\**`) and the lighting/environment rig (`data\env\**`, decoded by X35). No value was invented to fill the ticket's expected location.

## 2. Format, counts and exact literals

### 2.1 Grammar [O]

```
generator : section.begin                         :1
   EnvGroups : struct.begin                       :2
      // CONSTANT SIZES                           :3
      [*] : struct.begin                          :4   <- one group
         group = <name>                           :5
         list : struct.begin                      :6
            [*] : struct.begin                    :7   <- one record
               name = <prop-name>                 :8
               scale = <float>                    :9
               minscale = <float>                 :10
               maxscale = <float>                 :11
            struct.end                            :12
         struct.end                               :13
      struct.end                                  :14
   ...
   // ENVIRONMENT                                 :38
   ...                                            :589 // DECORATIONS
   struct.end                                     :868
section.end                                       :869
```

- Encoding: ASCII text with CRLF; 869 `\r\n`, 869 `\n`, no BOM; `latin-1` read is lossless. `[*]` = array element, `group`/`list`/`name`/`scale`/`minscale`/`maxscale` = keys. Comments are `//` only; **no `[*] = ;` disabled lines** in the cfg (unlike the consumer script, §5).
- Literal header verbatim: `generator : section.begin` (`:1`), `EnvGroups : struct.begin` (`:2`), `// CONSTANT SIZES` (`:3`), `// ENVIRONMENT` (`:38`), `// DECORATIONS` (`:589`), `section.end` (`:869`).

### 2.2 Group census [O]

| # | group (line) | recs | scale literals (name-line → scale-line) | min/max |
|---:|---|---:|---|---|
| 1 | `field` @5 | 1 | `field` 8→9 `0.033` | 1/1 (:10-11) |
| 2 | `mines` @16 | 3 | `minecoal` 19→20 `0.3152`; `minegold` 25→26 `0.3152`; `mineiron` 31→32 `0.3152` | 1/1 (:21-22, :27-28, :33-34) |
| 3 | `stones` @40 | 11 | 43→44 `0.329`; 49→50 `0.329`; 55→56 `0.37`; 61→62 `0.4`; 67→68 `0.324`; 73→74 `0.313`; 79→80 `0.328`; 85→86 `0.25`; 91→92 `0.25`; 97→98 `0.25`; 103→104 `0.25` | 0.85/1.15 |
| 4 | `smallstones` @111 | 7 | 114→115 `0.25`; 120→121 `0.209`; 126→127 `0.209`; 132→133 `0.236`; 138→139 `0.25`; 144→145 `0.25`; 150→151 `0.25` | 0.85/1.15 |
| 5 | `fir` @158 | 5 | 161→162 `0.5`; 167→168 `0.5`; 173→174 `0.5`; 179→180 `0.5`; 185→186 `0.5` | 0.85/1.15 |
| 6 | `firsmall` @193 | 5 | 196→197 `0.5`; 202→203 `0.5`; 208→209 `0.5`; 214→215 `0.5`; 220→221 `0.5` | 0.85/1.15 |
| 7 | `pine1` @228 | 5 | 231→232 `0.475` and four more variants :237-255 | 0.85/1.15 |
| 8 | `pinesmall1` @263 | 5 | 266→267 `0.55`; 272→273 `0.535`; 278→279 `0.56`; 284→285 `0.61`; 290→291 `0.5` | 0.85/1.15 |
| 9 | `pinebroken1` @298 | 5 | 301→302 `0.64`; 307→308 `0.82`; 313→314 `0.69`; 319→320 `0.55`; 325→326 `0.5` | 0.85/1.15 |
| 10 | `pinebrokenmoss1` @333 | 5 | 336→337 `0.64`; 342→343 `0.63`; 348→349 `0.705`; 354→355 `0.742`; 360→361 `0.5` | 0.85/1.15 |
| 11 | `spruce1` @368 | 5 | 371→372 `0.5` and four variants :377-395 | 0.85/1.15 |
| 12 | `pinedry1` @403 | 5 | 406→407 `0.65`; 412→413 `0.618`; 418→419 `0.706`; 424→425 `0.76`; 430→431 `0.5` | 0.85/1.15 |
| 13 | `pinestump` @438 | 5 | 441→442 `0.91`; 447→448 `1`; 453→454 `0.817`; 459→460 `1.02`; 465→466 `0.817` | 0.85/1.15 |
| 14 | `leaftree` @473 | 5 | 476→477 `0.425` (×4); 500→501 `0.504` | 0.85/1.15 |
| 15 | `burch` @508 | 7 | 511→512 `0.38`; 517→518 `0.374`; 523→524 `0.366`; 529→530 `0.341`; 535→536 `0.415`; 541→542 `0.434`; 547→548 `0.354` | 0.85/1.15 |
| 16 | `burchstump` @555 | 5 | 558→559 `0.807`; 564→565 `0.915`; 570→571 `0.807`; 576→577 `0.807`; 582→583 `0.807` | 0.85/1.15 |
| 17 | `grass` @591 | 4 | 594→595 `0.27` (×4) | 0.95/1.05 (:596-597,…) |
| 18 | `grassforest` @620 | 4 | 623→624 `0.475` (×4) | 0.95/1.05 (:625-626,…) |
| 19 | `fern` @649 | 5 | 652→653 `0.43` (×5) | 0.85/1.15 |
| 20 | `drybushes` @684 | 5 | 687→688 `0.5` (×5) | 0.85/1.15 |
| 21 | `burdock` @719 | 4 | 722→723 `0.356` (×4) | 0.85/1.15 |
| 22 | `horseradish` @748 | 4 | 751→752 `0.369` (×4) | 0.85/1.15 |
| 23 | `chamomile` @777 | 3 | 780→781 `0.147` (×3) | 0.85/1.15 |
| 24 | `grasschamomile` @800 | 1 | 803→804 `0.3` | 0.95/1.05 (:805-806) |
| 25 | `plantain` @811 | 4 | 814→815 `0.412`; 820→821 `0.417`; 826→827 `0.436`; 832→833 `0.384` | 0.85/1.15 |
| 26 | `flowers` @840 | 4 | 843→844 `0.281`; 849→850 `0.263`; 855→856 `0.29`; 861→862 `0.29` | 0.85/1.15 |
| | **TOTAL** | **122** | **55 distinct `scale` literals** | 4 × 1/1, 9 × 0.95/1.05, 109 × 0.85/1.15 |

Sum check [O]: 1+3+11+7+5+5+5+5+5+5+5+5+5+5+7+5+4+4+5+5+4+4+3+1+4+4 = **122**.

### 2.3 Complete record table [O] — all literals with path:line

Path for every row: `C:\Games\Cossacks 3\data\game\var\envscales.cfg`. "name@line" is the `name =` line; the `scale` line is given in parentheses; min/max lines follow.

| Group (line) | Name | name@line | scale | min@line | max@line |
|---|---|---|---:|---|---|
| field @5 | `field` | 8 | 0.033 (@9) | 1@10 | 1@11 |
| mines @16 | `minecoal` | 19 | 0.3152 (@20) | 1@21 | 1@22 |
| mines @16 | `minegold` | 25 | 0.3152 (@26) | 1@27 | 1@28 |
| mines @16 | `mineiron` | 31 | 0.3152 (@32) | 1@33 | 1@34 |
| stones @40 | `stones` | 43 | 0.329 (@44) | 0.85@45 | 1.15@46 |
| stones @40 | `stones1` | 49 | 0.329 (@50) | 0.85@51 | 1.15@52 |
| stones @40 | `stones2` | 55 | 0.37 (@56) | 0.85@57 | 1.15@58 |
| stones @40 | `stones3` | 61 | 0.4 (@62) | 0.85@63 | 1.15@64 |
| stones @40 | `stones4` | 67 | 0.324 (@68) | 0.85@69 | 1.15@70 |
| stones @40 | `stones5` | 73 | 0.313 (@74) | 0.85@75 | 1.15@76 |
| stones @40 | `stones6` | 79 | 0.328 (@80) | 0.85@81 | 1.15@82 |
| stones @40 | `stones7` | 85 | 0.25 (@86) | 0.85@87 | 1.15@88 |
| stones @40 | `stones8` | 91 | 0.25 (@92) | 0.85@93 | 1.15@94 |
| stones @40 | `stones9` | 97 | 0.25 (@98) | 0.85@99 | 1.15@100 |
| stones @40 | `stones10` | 103 | 0.25 (@104) | 0.85@105 | 1.15@106 |
| smallstones @111 | `smallstones` | 114 | 0.25 (@115) | 0.85@116 | 1.15@117 |
| smallstones @111 | `smallstones.1` | 120 | 0.209 (@121) | 0.85@122 | 1.15@123 |
| smallstones @111 | `smallstones.2` | 126 | 0.209 (@127) | 0.85@128 | 1.15@129 |
| smallstones @111 | `smallstones.3` | 132 | 0.236 (@133) | 0.85@134 | 1.15@135 |
| smallstones @111 | `smallstones.4` | 138 | 0.25 (@139) | 0.85@140 | 1.15@141 |
| smallstones @111 | `smallstones.5` | 144 | 0.25 (@145) | 0.85@146 | 1.15@147 |
| smallstones @111 | `smallstones.6` | 150 | 0.25 (@151) | 0.85@152 | 1.15@153 |
| fir @158 | `fir` | 161 | 0.5 (@162) | 0.85@163 | 1.15@164 |
| fir @158 | `fir1.1` | 167 | 0.5 (@168) | 0.85@169 | 1.15@170 |
| fir @158 | `fir2.2` | 173 | 0.5 (@174) | 0.85@175 | 1.15@176 |
| fir @158 | `fir3.3` | 179 | 0.5 (@180) | 0.85@181 | 1.15@182 |
| fir @158 | `fir4.4` | 185 | 0.5 (@186) | 0.85@187 | 1.15@188 |
| firsmall @193 | `firsmall1` | 196 | 0.5 (@197) | 0.85@198 | 1.15@199 |
| firsmall @193 | `firsmall1.1` | 202 | 0.5 (@203) | 0.85@204 | 1.15@205 |
| firsmall @193 | `firsmall2.2` | 208 | 0.5 (@209) | 0.85@210 | 1.15@211 |
| firsmall @193 | `firsmall3.3` | 214 | 0.5 (@215) | 0.85@216 | 1.15@217 |
| firsmall @193 | `firsmall4.4` | 220 | 0.5 (@221) | 0.85@222 | 1.15@223 |
| pine1 @228 | `pine1` | 231 | 0.475 (@232) | 0.85@233 | 1.15@234 |
| pine1 @228 | `pine1.1` | 237 | 0.475 (@238) | 0.85@239 | 1.15@240 |
| pine1 @228 | `pine2.2` | 243 | 0.475 (@244) | 0.85@245 | 1.15@246 |
| pine1 @228 | `pine3.3` | 249 | 0.475 (@250) | 0.85@251 | 1.15@252 |
| pine1 @228 | `pine4.4` | 255 | 0.475 (@256) | 0.85@257 | 1.15@258 |
| pinesmall1 @263 | `pinesmall1` | 266 | 0.55 (@267) | 0.85@268 | 1.15@269 |
| pinesmall1 @263 | `pinesmall1.1` | 272 | 0.535 (@273) | 0.85@274 | 1.15@275 |
| pinesmall1 @263 | `pinesmall2.2` | 278 | 0.56 (@279) | 0.85@280 | 1.15@281 |
| pinesmall1 @263 | `pinesmall3.3` | 284 | 0.61 (@285) | 0.85@286 | 1.15@287 |
| pinesmall1 @263 | `pinesmall4.4` | 290 | 0.5 (@291) | 0.85@292 | 1.15@293 |
| pinebroken1 @298 | `pinebroken1` | 301 | 0.64 (@302) | 0.85@303 | 1.15@304 |
| pinebroken1 @298 | `pinebroken1.1` | 307 | 0.82 (@308) | 0.85@309 | 1.15@310 |
| pinebroken1 @298 | `pinebroken2.2` | 313 | 0.69 (@314) | 0.85@315 | 1.15@316 |
| pinebroken1 @298 | `pinebroken3.3` | 319 | 0.55 (@320) | 0.85@321 | 1.15@322 |
| pinebroken1 @298 | `pinebroken4.4` | 325 | 0.5 (@326) | 0.85@327 | 1.15@328 |
| pinebrokenmoss1 @333 | `pinebrokenmoss1` | 336 | 0.64 (@337) | 0.85@338 | 1.15@339 |
| pinebrokenmoss1 @333 | `pinebrokenmoss1.1` | 342 | 0.63 (@343) | 0.85@344 | 1.15@345 |
| pinebrokenmoss1 @333 | `pinebrokenmoss2.2` | 348 | 0.705 (@349) | 0.85@350 | 1.15@351 |
| pinebrokenmoss1 @333 | `pinebrokenmoss3.3` | 354 | 0.742 (@355) | 0.85@356 | 1.15@357 |
| pinebrokenmoss1 @333 | `pinebrokenmoss4.4` | 360 | 0.5 (@361) | 0.85@362 | 1.15@363 |
| spruce1 @368 | `spruce1` | 371 | 0.5 (@372) | 0.85@373 | 1.15@374 |
| spruce1 @368 | `spruce1.1` | 377 | 0.5 (@378) | 0.85@379 | 1.15@380 |
| spruce1 @368 | `spruce2.2` | 383 | 0.5 (@384) | 0.85@385 | 1.15@386 |
| spruce1 @368 | `spruce3.3` | 389 | 0.5 (@390) | 0.85@391 | 1.15@392 |
| spruce1 @368 | `spruce4.4` | 395 | 0.5 (@396) | 0.85@397 | 1.15@398 |
| pinedry1 @403 | `pinedry1` | 406 | 0.65 (@407) | 0.85@408 | 1.15@409 |
| pinedry1 @403 | `pinedry1.1` | 412 | 0.618 (@413) | 0.85@414 | 1.15@415 |
| pinedry1 @403 | `pinedry2.2` | 418 | 0.706 (@419) | 0.85@420 | 1.15@421 |
| pinedry1 @403 | `pinedry3.3` | 424 | 0.76 (@425) | 0.85@426 | 1.15@427 |
| pinedry1 @403 | `pinedry4.4` | 430 | 0.5 (@431) | 0.85@432 | 1.15@433 |
| pinestump @438 | `pinestump` | 441 | 0.91 (@442) | 0.85@443 | 1.15@444 |
| pinestump @438 | `pinestump.1` | 447 | 1 (@448) | 0.85@449 | 1.15@450 |
| pinestump @438 | `pinestump.2` | 453 | 0.817 (@454) | 0.85@455 | 1.15@456 |
| pinestump @438 | `pinestump.3` | 459 | 1.02 (@460) | 0.85@461 | 1.15@462 |
| pinestump @438 | `pinestump.4` | 465 | 0.817 (@466) | 0.85@467 | 1.15@468 |
| leaftree @473 | `leaftree` | 476 | 0.425 (@477) | 0.85@478 | 1.15@479 |
| leaftree @473 | `leaftree.1` | 482 | 0.425 (@483) | 0.85@484 | 1.15@485 |
| leaftree @473 | `leaftree.2` | 488 | 0.425 (@489) | 0.85@490 | 1.15@491 |
| leaftree @473 | `leaftree.3` | 494 | 0.425 (@495) | 0.85@496 | 1.15@497 |
| leaftree @473 | `leaftree.4` | 500 | 0.504 (@501) | 0.85@502 | 1.15@503 |
| burch @508 | `burch` | 511 | 0.38 (@512) | 0.85@513 | 1.15@514 |
| burch @508 | `burch.1` | 517 | 0.374 (@518) | 0.85@519 | 1.15@520 |
| burch @508 | `burch.2` | 523 | 0.366 (@524) | 0.85@525 | 1.15@526 |
| burch @508 | `burch.3` | 529 | 0.341 (@530) | 0.85@531 | 1.15@532 |
| burch @508 | `burch.4` | 535 | 0.415 (@536) | 0.85@537 | 1.15@538 |
| burch @508 | `burch.5` | 541 | 0.434 (@542) | 0.85@543 | 1.15@544 |
| burch @508 | `burch.6` | 547 | 0.354 (@548) | 0.85@549 | 1.15@550 |
| burchstump @555 | `burchstump` | 558 | 0.807 (@559) | 0.85@560 | 1.15@561 |
| burchstump @555 | `burchstump.1` | 564 | 0.915 (@565) | 0.85@566 | 1.15@567 |
| burchstump @555 | `burchstump.2` | 570 | 0.807 (@571) | 0.85@572 | 1.15@573 |
| burchstump @555 | `burchstump.3` | 576 | 0.807 (@577) | 0.85@578 | 1.15@579 |
| burchstump @555 | `burchstump.4` | 582 | 0.807 (@583) | 0.85@584 | 1.15@585 |
| grass @591 | `grass` | 594 | 0.27 (@595) | 0.95@596 | 1.05@597 |
| grass @591 | `grass.1` | 600 | 0.27 (@601) | 0.95@602 | 1.05@603 |
| grass @591 | `grass.2` | 606 | 0.27 (@607) | 0.95@608 | 1.05@609 |
| grass @591 | `grass.3` | 612 | 0.27 (@613) | 0.95@614 | 1.05@615 |
| grassforest @620 | `grassforest` | 623 | 0.475 (@624) | 0.95@625 | 1.05@626 |
| grassforest @620 | `grassforest.1` | 629 | 0.475 (@630) | 0.95@631 | 1.05@632 |
| grassforest @620 | `grassforest.2` | 635 | 0.475 (@636) | 0.95@637 | 1.05@638 |
| grassforest @620 | `grassforest.3` | 641 | 0.475 (@642) | 0.95@643 | 1.05@644 |
| fern @649 | `fern` | 652 | 0.43 (@653) | 0.85@654 | 1.15@655 |
| fern @649 | `fern.1` | 658 | 0.43 (@659) | 0.85@660 | 1.15@661 |
| fern @649 | `fern.2` | 664 | 0.43 (@665) | 0.85@666 | 1.15@667 |
| fern @649 | `fern.3` | 670 | 0.43 (@671) | 0.85@672 | 1.15@673 |
| fern @649 | `fern.4` | 676 | 0.43 (@677) | 0.85@678 | 1.15@679 |
| drybushes @684 | `drybushes` | 687 | 0.5 (@688) | 0.85@689 | 1.15@690 |
| drybushes @684 | `drybushes.1` | 693 | 0.5 (@694) | 0.85@695 | 1.15@696 |
| drybushes @684 | `drybushes.2` | 699 | 0.5 (@700) | 0.85@701 | 1.15@702 |
| drybushes @684 | `drybushes.3` | 705 | 0.5 (@706) | 0.85@707 | 1.15@708 |
| drybushes @684 | `drybushes.4` | 711 | 0.5 (@712) | 0.85@713 | 1.15@714 |
| burdock @719 | `burdock` | 722 | 0.356 (@723) | 0.85@724 | 1.15@725 |
| burdock @719 | `burdock.1` | 728 | 0.356 (@729) | 0.85@730 | 1.15@731 |
| burdock @719 | `burdock.2` | 734 | 0.356 (@735) | 0.85@736 | 1.15@737 |
| burdock @719 | `burdock.3` | 740 | 0.356 (@741) | 0.85@742 | 1.15@743 |
| horseradish @748 | `horseradish` | 751 | 0.369 (@752) | 0.85@753 | 1.15@754 |
| horseradish @748 | `horseradish.1` | 757 | 0.369 (@758) | 0.85@759 | 1.15@760 |
| horseradish @748 | `horseradish.1` | 763 | 0.369 (@764) | 0.85@765 | 1.15@766 |
| horseradish @748 | `horseradish.3` | 769 | 0.369 (@770) | 0.85@771 | 1.15@772 |
| chamomile @777 | `chamomile` | 780 | 0.147 (@781) | 0.85@782 | 1.15@783 |
| chamomile @777 | `chamomile.2` | 786 | 0.147 (@787) | 0.85@788 | 1.15@789 |
| chamomile @777 | `chamomile.3` | 792 | 0.147 (@793) | 0.85@794 | 1.15@795 |
| grasschamomile @800 | `grasschamomile` | 803 | 0.3 (@804) | 0.95@805 | 1.05@806 |
| plantain @811 | `plantain` | 814 | 0.412 (@815) | 0.85@816 | 1.15@817 |
| plantain @811 | `plantain.1` | 820 | 0.417 (@821) | 0.85@822 | 1.15@823 |
| plantain @811 | `plantain.2` | 826 | 0.436 (@827) | 0.85@828 | 1.15@829 |
| plantain @811 | `plantain.3` | 832 | 0.384 (@833) | 0.85@834 | 1.15@835 |
| flowers @840 | `flowers` | 843 | 0.281 (@844) | 0.85@845 | 1.15@846 |
| flowers @840 | `flowers.1` | 849 | 0.263 (@850) | 0.85@851 | 1.15@852 |
| flowers @840 | `flowers.2` | 855 | 0.29 (@856) | 0.85@857 | 1.15@858 |
| flowers @840 | `flowers.3` | 861 | 0.29 (@862) | 0.85@863 | 1.15@864 |

## 3. What the values mean — name → prop binding [O]/[D]

| Pass | Instrument | Result | Label |
|---|---|---|---|
| P4a | For each of 122 names, test `data\objects\env\<name>.prop` and `data\objects\env\<base>.prop` (base = stem before first `.`) | **122/122 resolve** (28 exact, 94 via base). Zero unresolved names | [O] |
| P4b | Same for `data\actors\env\*.actor` | 66/122 exact-or-base; the rest share the base `.prop` but have no matching `.actor` | [O] |
| P4c | Same for `data\materials\env\*.dds` | 61/122 exact-or-base | [O] |
| P4d | Read `scripts\editor.inc\createenvironemttest.inc:19-57` | Loader `ParserLoadFromFileByHandle(pEnvScales, '.\data\game\var\envscales.cfg')` (`:20`), `ParserSelectByHandleByKey(...,'EnvGroups')` (`:21`), per-record `name/scale/minscale/maxscale` (`:37-40`), `CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_env, name, ...)` (`:45`), `SetGameObjectScaleByHandle(goHnd, scale, scale, scale)` (`:47`, inside `{…}` comment), min/max copies at `:48-57` | [O] |

**[D] Accepted semantics:** `scale` = base instance scale of the named env *game object* (prop), `minscale`/`maxscale` = multiplicative jitter limits around that base. The `.N` suffixes are mesh/material variants of the same base prop, **not** separate props — consistent with F08 E12/E13 and F08 R4 (which marks that suffix inference as **[I]**; this report does not upgrade it). `field` is a ground-cover prop/decal (F07 E17, spec/06 §3 "mill fields are decals, not terrain tile ids"), not a terrain tile id.

**[U] Runtime caveat:** every line of the consumer is comment-prefixed (`[*] = ;`), the base-scale call is additionally brace-commented, and no engine literal names the file (§1 P1d). Therefore "the shipped skirmish reads these scales into props" is **not** established; the file is a readable scale *reference/default* table, and authored pattern records carry their own `Scaling` (§6 C3).

## 4. Does it affect terrain shading / texture tiling? [D] NO

Evidence chain (each item independently sufficient to reject the premise):

1. **Object, not material, target.** `:45-56` of the only consumer create/scale *game objects*; no texture, sampler, material or shader handle is touched. The keys are `name/scale/minscale/maxscale`; there is no `TextureScale`, UV, tiling, albedo, light or fog key anywhere in the 869 lines.
2. **Tile-space/material tiling lives in different files.** Donor `reftile.mat:12-16` `TextureScale XYZ = 1/1/1` (normal), `:123-126` and `:149-152` `TextureScale XYZ = 0.125/0.125/0.125` (alphavert front/side), `data\terrain\tiles\terrain.lib:5` has its own `TextureScale` struct. **The literal `0.125` does not occur in `envscales.cfg` at all** (verified byte search).
3. **No active consumer.** §1 P1d (zero EXE literals) + §3 [U] caveat. A config with no readable runtime binding cannot be asserted to change rendered pixels.
4. **I10's scale-like uniforms are cited elsewhere** (§7): `atlas_grid` → `data/terrain/ref/reftile.lib:3-12` + port packing (spec/06 §2); `uv_repeat` → `data/scripts/dmscript.global:171`; `face_scale` → `reftile.mat:124-126,150-152`; lighting → `light.cfg`; water levels → `generatemap.inc`/`texturemap.inc`. None cites `envscales.cfg`.
5. **Scope boundary from prior workers.** A04 E14/E23 and F08 E13 explicitly use envscales for *prop* scale (mines, stones, tree ladders); X35 §5/§6 attributes all I10 shading literals to `light.cfg`/`reftile.mat`/`colors.lib` and finds no scale-table input. No prior landed report routes `envscales.cfg` into the terrain fragment.

**[D] Conclusion:** `envscales.cfg` cannot account for terrain shading, ground-material scale or texture tiling. It governs the size of non-terrain env objects placed on the ground. Any "flat olive / diagonal vein" attribution to this file would be **UNVERIFIED** and is rejected here.

## 5. Donor-grounded values relevant to I10 (task item 2) — none; values belong to the prop lane

| Donor-grounded value | Literal + path:line | Relevant to I10 shader? | Where it is already used |
|---|---|---|---|
| mine scale, no jitter | `data\game\var\envscales.cfg:20,26,32` `scale = 0.3152`; `:21-22,27-28,33-34` `1/1` | **No** | `variant3d\scripts\world3d_entities.gd:128` `ENV_SCALE.mine = 0.3152`; `tests\t_terrain_mines.gd:55` expected constant |
| stone scale, wide jitter | `:44` `0.329`; `:45-46` `0.85/1.15` | **No** | `world3d_entities.gd:128` `ENV_SCALE.stone = 0.329`; `:166-170` wide band |
| generic tree fallback | `:162,197,372` `0.5` (fir/firsmall/spruce1) | **No** | `world3d_entities.gd:128` `ENV_SCALE.tree = 0.5`; per-sid ladder `:130-157` |
| field ground-cover prop | `:9` `0.033`; `:10-11` `1/1` | **No** | F07 E17; field decal path (not I10) |
| three jitter bands | `:10-11,21-22,27-28,33-34` `1/1`; `:596-597,625-626,805-806` `0.95/1.05`; 109 × `0.85/1.15` | **No** | `world3d_entities.gd:166-170` `none/tight/wide` |

**[D] Hand-off note (no code edit by X67):** the port's own citations at `world3d_entities.gd:160-163` point to `:8,19,25,31` for the "none" band and `:594-612` / `:623-641` / `:803` for "tight"; the exact `minscale`/`maxscale` lines are `:10-11,21-22,27-28,33-34` and `:596-597,602-603,608-609,614-615,625-626,631-632,637-638,643-644,805-806`. This is a citation refinement only; the numeric values agree exactly.

## 6. Multiple-pass contradiction ledger (owner directive, CHARTER.md:85-93)

| # | Contradiction / anomaly | Passes | Accepted reading | Label |
|---|---|---|---|---|
| C1 | Ticket expects the file under `data\env\**` / `data\materials\env\**`; it is under `data\game\var\` | P1a whole-tree filename search; P1b/P1c full inventory of both ticket trees; P1d both EXEs | **Ticket premise wrong.** Unique file = `data\game\var\envscales.cfg`. Keep X33's path verbatim | [O] |
| C2 | F08 E13 cites `pattern.lib:713429` for `minegold Scaling=0.3152`; a byte-offset read at 713429 shows `0.524999678134918` | P6a byte offset 713429 → mid-record with `Scaling X = 0.525`; P6b treat as **line number** → line 713429 is `Scaling : struct.begin`, X/Y/Z at `:713430-713432` = `0.315200001001358`; P6c 50 occurrences of `0.3152`, 9 `minegold` records all with that Scaling | **F08's citation is a LINE number, not a byte offset.** Both readings true under different conventions; line-number convention accepted for all `pattern.lib:N` citations | [O]/[D] |
| C3 | F08 E13 says "Ore scale 0.3152 fixed" for all mines, but per-record `pattern.lib` Scaling differs | P6d parse 42,731 `[*]` records with `BaseName`+`Scaling`; `minegold` = `0.315200001001358` **exact**, `mineiron` = `0.315187484025955` (≈), `minecoal` = `0.323067158460617` (≠); P6e 43/122 envscales names have digit-exact pattern Scaling, 48 mismatch, 31 have no pattern record | **Preserve both**: `envscales.cfg` is a default/reference ladder; authored `.pattern` records carry their own per-instance Scaling overrides. No harmonisation, no invented "true mine scale" | [O]/[U] |
| C4 | `horseradish.1` appears twice (`:757` and `:763`); `.2` never appears, though `.3` does | P8a parse duplicate names → 121 unique / 122 records; P8b re-read `:748-772` → both duplicates carry identical `0.369/0.85/1.15` | **Observed donor data anomaly.** Likely a mistyped `.2` **[I]**, but numerically inert; do not "fix" the donor file or invent a replacement | [O]/[I] |
| C5 | envscales `0.5` / `0.25` vs I10 `uv_repeat=0.5` / `water_height_classify=-0.25` | P7a enumerate all 19 I10 uniforms; P7b literal-overlap test → overlaps only at `uv_repeat` `0.5` (`:115`) and `water_height_classify` `0.25` (`:179`); P7c read each uniform's citation comment → `dmscript.global:171`, `texturemap.inc:29-30` respectively; P7d confirm `0.125` absent from envscales | **Numerical coincidence, not provenance.** No I10 uniform is sourced from envscales; reject any replacement | [D] |
| C6 | The only consumer script both writes `scale` and comments that write out | P5a script search; P5b full read `:19-57` → `:46-47` brace comment around `SetGameObjectScaleByHandle`; all lines `[*] = ;` | **Semantics [D] readable, runtime application [U].** Do not claim the shipped game applies these values | [O]/[U] |
| C7 | X33 marked this file NEEDS READ / partially read; this report claims full decode | P1/P2/P3/P8: 869/869 lines numbered to scratch, 26 groups, 122 records, balanced struct tokens, zero missing fields | **No contradiction**: X33's coverage snapshot is dated; this pass closes it. X33's byte count 25,612 and citation `:16-36`/`:161-255` both confirmed (`:16-36` = mines group; `:161-255` = fir/firsmall/pine1 groups) | [O] |
| C8 | Port `world3d_entities.gd:160-163` cites `envscales.cfg:8,19,25,31` as "none" jitter lines | P8c re-read → those are `name =` lines; actual `minscale`/`maxscale` at `:10-11,21-22,27-28,33-34` (and "wide" range ends at `:165`, not `:164`) | **Values correct, line citations off by 1-2.** Report exact lines in §5; no numeric change | [O] |

### 6.1 P9 — independent reconciliation with landed X57 (`X57_env_objects_decode.md`)

X57 decoded the same config independently (same SHA-256, 26 groups / 122 records, same consumer). Three extra claims were re-run here; none changes the DEFERRED verdict, and all are preserved rather than harmonised.

| # | X57 claim | P9 verification | Accepted reading | Label |
|---|---|---|---|---|
| C9 | `field` scale is `0.033` in cfg but `0.03605085` in `field.prop` | Re-read `data\objects\env\field.prop:139-146`: `scaleproperty`, `DefaultScale X/Y/Z = 0.03605085` (`:141-143`), `RandomScale = False` (`:145`) vs `envscales.cfg:9 scale = 0.033` | **Both true in different files.** envscales is a reference table; the prop's own `DefaultScale` differs by ≈9%. No single "field scale" is claimed | [O] |
| C10 | A second consumer exists at `scripts\editor.aix:419-423` | Read `editor.aix:419-423`: `Name = CreateEnvironemtTest`, `UsedFile = True`, `UsedFileName = .\scripts\editor.inc\createenvironemttest.inc` — an editor **registry entry**, not a parser call | **Still exactly one textual call site** (`createenvironemttest.inc:20`); X57's citation is the registry for that same script. No conflict | [O] |
| C11 | Prop `scaleproperty` mirrors — but need not equal — envscales | Read `fir.prop:94-102` `DefaultScale=0.5`, `RandomScale=True`, `0.85/1.15` = cfg `:162-164` **exact**; `plantain3.prop:78-86` `X/Y=0.384`, **`Z=0.288`**, `RandomScale=True`, `Min=0.925`, `Max=1.075` vs cfg `:833` `0.384` and `:834-835` `0.85/1.15` | **Confirms semantics** (prop instance scale) **and** reinforces U-X67-1: runtime values can come from the prop's own anisotropic `scaleproperty`, not from the uniform cfg triple. No invented reconciliation | [O]/[D] |

**P9 conclusion [D]:** C9/C11 show that `envscales.cfg` is a *reference/default ladder*, not an authoritative per-instance source; this further weakens any claim that editing it would change a rendered terrain or prop pixel. X57's independent SHA-256 and record count agree exactly with §0/§2 (no count contradiction).

## 7. I10 comparison (task item 3) — no donor-cited replacement from this file

I10 = `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\shaders\terrain_donor_shader.gdshader` (307 lines). Companion `variant3d\scripts\world3d_terrain.gd`.

| I10 symbol (line) | I10 default | Donor citation in I10 / elsewhere | Does `envscales.cfg` supply a replacement? | Verdict |
|---|---|---|---|---|
| `atlas_grid` `:90` | `vec2(16.0, 8.0)` | `:91-92` → `data\terrain\ref\reftile.lib:3-12`; port packing `spec/06 §2`; `tile_atlas_loader.gd:93` `_grid = Vector2(16,8)`; `terrain_donor_mesh.gd:52` expected 16×8 | **No.** No grid/UV key in cfg; ranges in cfg are prop scales 0.033–1.02 | PORT APPROX (16×8 packing) unchanged |
| `uv_repeat` `:115` | `vec2(0.5,0.5)` | `:116` → `data\scripts\dmscript.global:171` (`gc_meters_to_tile=2`); no donor literal equivalent (D08 §3.6) | **No.** `0.5` in cfg is 24 prop-scale literals, different units | unchanged |
| `alpha_uv_scale` `:119` | `1.0` | `:120` PORT APPROX, donor MultiTexCoord1 [U] | **No** | unchanged |
| `face_scale` `:129` | `0.125` | `:130-131` → `reftile.mat:124-126,150-152` TextureScale XYZ | **No.** `0.125` absent from cfg | unchanged |
| `texture_matrix` `:111` | identity | `:112` → `hf.pvl.sm.vert:32`, runtime [U] | **No** | unchanged |
| `donor_sun_position` `:151`, `ambient_rgb` `:154`, `diffuse_rgb` `:156`, `specular_rgb` `:158`, `shininess` `:163` | X35 §5 values | `light.cfg:26-29,3-5,10-12,20-23`; `reftile.mat:76,104` | **No.** X35 already adjudicated these; specular contradiction preserved there, not here | unchanged (see X35) |
| `water_height_basin` `:174`, `water_field_offset_y` `:176`, `water_height_classify` `:179`, `water_shore_height` `:181` | −1.1 / −0.5 / −0.25 / −0.1 | `spec/05 §1`: `generatemap.inc:7,688,704`; `texturemap.inc:29-31,466-472` | **No.** `−0.25` coincides numerically with cfg's `0.25` prop scale only | unchanged |
| Terrain props / mine / stone / field instance size | not in I10 (CPU/entity lane) | `envscales.cfg:20,26,32` / `:44` / `:162,197,372` / `:9` | **Yes, but outside I10** — already in `world3d_entities.gd:128`, `:130-170` | Route to A04/F07/F08/V07, **not** to I10 |

**No donor-cited replacement for any I10 uniform or atlas-grid value arises from this file.** No shader constant was changed, recommended for change, or invented by X67.

## 8. DEFERRED verdict (task item 4) — evidence

**DEFERRED — envscales.cfg affects non-terrain environment object scale only; it is out of scope for I10/terrain shading.**

1. **[O]** All 122 names bind to `data\objects\env\*.prop` (§3 P4a): field, mines, stones, trees, grasses, flowers — props placed *on* terrain, not terrain tiles or ground materials.
2. **[O]** `:45-57` of the only consumer operate on `CreatePlayerGameObjectHandleByHandle(..., gc_racename_env, name, ...)` and `SetGameObjectScaleByHandle`, never on a material/texture/shader.
3. **[O]** No `TextureScale`/UV/tiling/lighting key in the file; donor texture scales are in `reftile.mat:12-16,123-126,149-152` and `terrain.lib:5`.
4. **[O]** No engine literal `envscales.cfg` in either EXE; runtime use in skirmish **[U]** (§1 P1d, §6 C6).
5. **[D]** I10's scale-like uniforms have independent donor citations (§7); `0.125` absent from cfg; overlapping digits are coincidences (§6 C5).
6. **[D]** The donor-grounded values are already present in the port's *prop* lane (`world3d_entities.gd:128,166-170`); moving them into I10 would be a category error.

**Recommended disposition for COORD:** keep DEFERRED for spec/05 (water/shore), spec/06 (tile/atlas) and I10. If COORD wants these values audited, the owning lanes are A04 (landscape props), F07 (field decal) and F08/V07 (flora/minerals scale ladder) — X67 supplies the full literal table (§2.3) as their evidence source, with no parity claim.

## 9. UNVERIFIED register

| ID | Item | Why unverified | Passes attempted |
|---|---|---|---|
| U-X67-1 | Whether shipped skirmish actually loads/applies `envscales.cfg` scales | Only consumer is a fully comment-prefixed editor test script; no engine literal | §1 P1d; §3 P4d; §6 C6 |
| U-X67-2 | Whether `.N` suffixes map to specific mesh/material variants | Inferred by F08 R4 from this cfg; no active selector recovered | §3 [D]; F08 E12/R4 |
| U-X67-3 | Why `pattern.lib` Scaling often differs from cfg defaults (48/122) | Both tables read; no generator code connecting them in readable text | §6 C3 |
| U-X67-4 | Intent of duplicate `horseradish.1` at `:757/:763` | No second source; numerically inert | §6 C4 |
| U-X67-5 | Whether `field` scale `0.033` is applied to a ground decal in engine | F07 E17 literal read; runtime binding [U] | §5; F07 |
| U-X67-6 | Any GPU-visible consequence of these scales | No donor GPU A/B frame; no runner job permitted | §0 parity_guard; CHARTER.md:125 |

## 10. Open questions for COORD

1. Confirm DEFERRED disposition (§8) so no later worker wires `envscales.cfg` into the terrain shader on the strength of the `0.5`/`0.25` digit overlaps.
2. If A04/F07/F08/V07 need the exact per-sid ladder, §2.3 is the citation source; note the line-refinement in §5 and the duplicate-name anomaly in §6 C4.
3. Decide whether the editor-only `createenvironemttest.inc` (`:19-57`) should be recommended for a later D-pass Ghidra/xref study to settle U-X67-1 — X67 does not run donor binaries and submits no jobs.
4. Confirm that X33's "NEEDS READ" marker for this file can be closed in the coverage ledger (C7).

---

*End of X67. READ-ONLY: no repo file other than this report was written; no Godot runner job submitted; no donor binary executed or copied. All donor material is private use. No donor visual parity claim.*
