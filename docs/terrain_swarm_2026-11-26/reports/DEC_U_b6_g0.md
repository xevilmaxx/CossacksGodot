---
id: DEC-U-B6-G0-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B6-G0 — class-B static angle T-G0 (B6) execution"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b6_g0.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
pin: t_87f0f3c130b0 (cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c; Deep mode; already active, pinned via document= on every call)
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD for B6 promotion — no byte-proven G→count consumer exists; G=0 closure carried, T-G0 stays [U]; no density invented; no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc file reads + read-only donor disassembly/byte/text reads only. No donor binary executed/copied; no Godot process, runner job, gate, harness, replay or port capture run; no source/shader/asset/config/test/fixture/result-JSON/git state written. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.2 T-G0 = class B; §4 B6 exact angle)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_index.md (§1 B6 NOT EXECUTED; §4 B6 verbatim)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md (§2.2 T-G0 row)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md (T-G0 row)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_placement.md (§§1-2 U-G0, §7 U-G0 probe, §8 P-PLACE-01/02)
  - docs/terrain_swarm_2026-11-26/reports/X18_mask_channel_verification.md (1,331-mask census)
  - docs/terrain_swarm_2026-11-26/reports/X19_mask_decoder_gap.md (decoder gap, water notions, forest=G/255 PORT APPROXIMATION)
---

# DEC-U-B6-G0 — T-G0 zero-density closure (class-B angle B6 executed, 2026-11-27)

> **Required reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`. This report closes **zero** P0 items, promotes **zero** `[U]`→`[D]` values, invents **zero** densities, and makes **no parity claim**.

## 0. Task and answer in 30 seconds

**Task (B6, verbatim remaining angle per `PORT1TO1_u_classify.md §4 B6` / `PORT1TO1_b_angle_index.md §1 B6`):**

> Static fixed-seed mask check for `fdens==0` off-starts; confirm no zero-density branch writes height. (`DEC_U_placement` U-G0.)

**Expanded worker prescription (this ticket):** packed CODE byte search for `GColor`, `GNone`, `forestDensity`, `GetFreePatternMaskModifier`, `ig` property/API names with VAs; inspect wrapper arities for any native consumer that could turn G into a pattern count; check shipped mask bundles read-only for non-zero G pixels on non-start cells; only if byte-proven promote a value, otherwise keep `[U]` with a fixed-seed map byte-dump zero-mismatch experiment. No invented density; no parity claim.

**Answer:**

1. **All script-namespace G/density/modifier names have zero packed-CODE hits** (file-bytes, both utf8+utf16le, pinned `t_87f0f3c130b0`; packed-tail opaque per X31): `GColor` 0, `GNone` 0, `forestDensity` 0, `forest_density` 0, `GetFreePatternMaskModifier` 0, `cGForest`/`cGNone`/`cGColor`/`cGStone`/`cGForestStone`/`GForest`/`GenForest`/`ForestStone` 0 each, `SmoothForestBorders`/`SetupPatternsByType`/`cPlaceFreeForests`/`probsmall`/`probmid`/`problarge`/`probhuge`/`SetupMines`/`SetupStartingResources`/`GetPatternNameByParser`/`PatternIncreaseFreq`/`CheckStandPattern`/`gMapMask`/`MapMask`/`forestType`/`foreststype`/`TerrainType` 0 each `[O]` (§1). The G enum lives in donor **text** (`generatemap.inc:473-485`), not in packed CODE literals.
2. **No native consumer turns G into a pattern count.** Byte-proven wrapper arities take no G/density/count argument: `GetBitmapPixel(const bitmap,x,y: Integer; var r,g,b,a: Float)` (reader, 3 in + 4 var-out) at `0x60ce36`; `SmoothTerrain`/`MapGeneratorSmoothTerrain(const x,y,passes: Integer; const radius: Float)` at `0x6a395a/0x6a394e`; `GetHeightData(const x,y: Integer): Float` / `SetHeightData(const x,y: Integer; const cheightvalue: Float)` at `0x6a3cae/0x6a3cea`; `StandPattern(WithAngle/Adv)` family takes `(plhandle,patternname,standx,standz,rotangle[,minangle,maxangle|makegr,movetopar,grname,parbase,parind])` — pattern **name + coordinates**, never a G byte or density `[O]` (§2). `Forest` ×17 hits are property/file-name strings (`ForestPatternsFileName`, `ForestMapFileName`, `ForestPlayerName/Race`, `ForestTileChallenge*`, `Forest.seCity.seMountains…`), not a density API `[O]`.
3. **Shipped vanilla masks carry no live G.** Fresh read-only re-decode this pass (Pillow, 5 masks across 4 shapes): `mediterranean_22` (320², 4 starts), `islands_0` (320², 2 starts), `nowater2_170` (320², 4 starts), `land_0` (320², 4 starts), `peninsulas_0` (320², 2 starts) — **non-start G≠0 = 0 on every file**, non-start R distinct = `{0}` `[O]` (§3). Carried full-corpus census (X18: 1,331 vanilla masks, 136,294,400 px, non-start R/G≠0 = 0, 5,125 white starts; X19 P3 agreement) is **not re-argued**, only cited. DLC5 8 grey pixels (`R=G=B∈{5,7,128,145}` at F04/X18 coords) are the sole carried non-zero-G non-starts — a source-data anomaly, not a vanilla density channel `[O]` carried.
4. **Zero-density branch writes no height.** Height text uses only `fr,fb` + class term (`generatemap.inc:567 hwater=cWaterHeight*(fb*(1+fr*3.5))`, `:569-574 hterrain`, `:574 SetHeightData`); start-skip tests `fr=1 ∧ fb=1` (**ignores `fg`**, `:565` asymmetry carried); S0/S1/S2 smoothing gates test `bsmooth` / `water==cBWater` + radius-2 class neighbourhood, never `fdens`/`ig` `[O]` text (§4). Port `terrain_donor_gen.gd:1339-1358` match (`255→1, 127-gated→1, 64→2, 128→3, 192→4, else 0`) therefore yields `fdens==0` on every non-start cell of the §3 files by derivation `[D]`; the port's own `forest_density` array is side data only (`:1344-1348, :1381-1384` comments, U-G0) — counts come exclusively from `_setup_patterns_by_type` passes `[O]` port text.
5. **No value promoted. T-G0 stays `[U]`.** The shipped-mask zero is a **value on shipped inputs** (`ig=0→cGNone→fdens=0` off-starts `[O]`), not a byte-proven native derivation rule, and the live-dial half (`SetupStartingResources` ring probes + `_misc_SetupPatternsByType` global passes with roulette/damping/occupancy reject) is engine-executed behaviour `[U]` pending the §5 fixed-seed byte-dump battery. Any `count = f(G)` formula on vanilla masks remains invented and is explicitly refused.

## 1. Pass (a) — packed CODE byte search, all pinned `t_87f0f3c130b0`

Method: `native_bytes_find` (utf8+utf16le, exact case-sensitive) with `document: "t_87f0f3c130b0` on every call; contexts via `native_bytes_show`; function attribution via `native_function_find`; strings cross-check via `native_strings_find`. Session verified pinned `t_87f0f3c130b0` (cossacks.exe, 5,768,048 B) before the first call. File-bytes limitation applies throughout: matches in compressed/packed regions or runtime-built strings are not seen; a 0-hit result is observed file-bytes absence (X31), not proof of engine-side absence.

### 1.1 Ticket needles — all zero `[O]`

| # | Pattern | Hits | Evidence id | Disposition |
|---|---|---|---|---|
| P-a1 | `GColor` | **0** | `ev_be345be8bda44d2b72ba1881844034a9286017a62db13a3ddb0514cddf9bb532` | `[O]` file-bytes absence; colour constants are text-side (`generatemap.inc:28-31`) |
| P-a2 | `GNone` | **0** | `ev_380a57e15c9d4c4bdd8e7e97aad6f7360d8e83f87dee91dacae5daabb2bb14bf` | `[O]` same; `cGNone` is text-side (`generatemap.inc:32`) |
| P-a3 | `forestDensity` | **0** | `ev_a953586c97858659563c1d4ae0b576799b3e2eda8bc8eeb0a601799780a7c17a` | `[O]` same; port-side name only |
| P-a4 | `forest_density` | **0** | `ev_79610ba54b6706f685f0c207a02452bc72fdcbf96234e43068474d36563cb8c1` | `[O]` same; port side array (`terrain_donor_gen.gd:1384`) |
| P-a5 | `GetFreePatternMaskModifier` | **0** | `ev_002c0db0f0d43dc07442e9985e540de47faf43ab98a0c9d47a293317bfe51e00` | `[O]` same; engine-side modifier producer, name is text-side (`dogenerate.inc:1715-1724`) |

**[D]** consequence: no static CODE xref walk can start from any ticket needle; the B6 residual "fixed-seed mask check" is correctly aimed at **shipped-mask bytes + donor text + wrapper-arity inspection**, not at a CODE literal.

### 1.2 G-enum / dress / modifier vocabulary — all zero `[O]`

| Pattern | Hits | Evidence id |
|---|---|---|
| `cGForest` | 0 | `ev_961e4081995e7060006c5a62798de2ab471c74cb1867044cc8443ae96100a354` |
| `cGNone` | 0 | `ev_5ebb2f26b8ed54d6d0cc2a58ae6d9647364d052269e49a429f6c6d2c1adf8509` |
| `cGColor` | 0 | `ev_f2e1b071af6264f5c64501268a4c2b33ee853e318dda56b2b1f726bd0d607a95` |
| `cGStone` | 0 | `ev_8802095e4e48d878e972868989684065db9d0bd22ede3c24ff77c347eae06181` |
| `cGForestStone` | 0 | `ev_9155d8793856cdb3fbeb352179cb25e9d675f40d529227d45487681e08c1d3ff` |
| `GForest` | 0 | `ev_3c74d28031202e389a1232e1e1a071b6b15dd1d86c9dc6e07e5cbba52cbf6c8b` |
| `GenForest` | 0 | `ev_d3d3da6ed873cb58edd67b9e9e6594cc0e369989fcfc8043ec8f11575bdc2347` |
| `ForestStone` | 0 | `ev_5ad3e6143ff023c2b37ef22fcf1283f20d30ac4129754b0b44a5042bafcc2aee` |
| `SmoothForestBorders` | 0 | `ev_6dde9c8fa0070f65c6a3d91140bd7af66c96abf9cf23c3203c211b34e39c79de` |
| `SetupPatternsByType` | 0 | `ev_255458cdd746b1f50012cbf98db81c558dc6dce0d7b6be9fd7062d801285a48b` |
| `cPlaceFreeForests` | 0 | `ev_b94d7b00fef3c643e4e91a52a3a1768d4e06908332b771639bc7f2c8618134ab` |
| `probsmall` | 0 | `ev_abc5d7f3bee9cc919c475f111c01dec861d36be99aab27bacb2902026e393ce1` |
| `probmid` | 0 | `ev_b0a8c798cba0347fabe4f933cd692ab2d303d29ffcd1ca3c3713ccf2042c205e` |
| `problarge` | 0 | `ev_7616cec8f95d9216ecddc7d8e99f0f564ddf98452ecda38fe8f551e5b2720c8b` |
| `probhuge` | 0 | `ev_9495f9ea8b65e86b4cd9adddd320fe27c948054545d609c0a28c524fb5a78d4b` |
| `SetupMines` | 0 | `ev_ecf5990f109493bbc8c28b56e04ae84f419c2c1ab2c1e34f2e138e563a5c0bf5` |
| `SetupStartingResources` | 0 | `ev_9ac17eedca8b384625ee55705dd21933e91ca74fbc61fdbaa95e80f9d0fd4997` |
| `GetPatternNameByParser` | 0 | `ev_8fd0967c0a82a4a7ffe026190bdc7b66295737cdfd0aa606fa58984d7624d774` |
| `PatternIncreaseFreq` | 0 | `ev_37df2f3d9b0b0725d6f3fcd14c4bb50ad6384ec47bd97519293c1db304c85815` |
| `CheckStandPattern` | 0 | `ev_3f3d61886b3b46e1d22a2784ef7fedb9d3c81b21c3cb83d54a3ddeb5e9750489` |
| `gMapMask` | 0 | `ev_a080c2e7260b945e2dd7f14b63fb52d93d37cabb34653a71b64327af496f6397` |
| `MapMask` | 0 | `ev_d66f84266d55df2b021bd984cd0c2675fdf377c508afe8845ddd4dc7a9530f66` |
| `forestType` / `foresttype` | 0 / 0 | `ev_1aa0341627ada8a33ac0c05fcddb56910f76d8a32b009dffd5f170f5280f48b0` / `ev_b782b6bf74b4a4d759259c47fe34b548666ffef9e010614dfb1727e28535b536` |
| `foreststype` | 0 | `ev_f87c195a66acc93f853de8d96de7900778ae1be052f8b8d3261841a892acdd60` |
| `TerrainType` | 0 | `ev_06860342ad9db53b7ba5961960003504df44f561b800d777d9fd4e691f9597e0` |
| `forest` (lowercase) | 0 | `ev_cf903bfbf7a5fd4b0448e7c17b672af2596ab21d47e4c69af723a358f67c73d3` |
| `FOREST` (upper) | 0 | `ev_480cc521a1e2e0976cf458a724610edb9012e40327561f997c3d0ca05b7d318c` |

`native_strings_find` cross-check: `cG` literal → only 2 `.idata` import hits (`WSAAsyncGetServByName @0x90af7c`, `WSAAsyncGetHostByName @0x90af94`, `ev_3d1b22325c59020b77e21f7b6b9d8ae9d005c5252a79de615fa4a6da2852ac4b`) — no `cG*` donor literal; regex `forestDensity|cGForest|GetFreePattern` → 0 (`ev_f5c427c2e560c2325460eef4f6ae343a6eb0d0194d23df08781903c1434ed206`) `[O]`.

### 1.3 Positive controls — what CODE *does* carry `[O]`

| Pattern | Hits | VAs (all section CODE) | Evidence |
|---|---|---|---|
| `Forest` (capital F) | **17** | `0x514533`; `0x718f0d,0x718f3e,0x718f9a,0x7191d2,0x7191fd,0x7193ea,0x719a41,0x719d93,0x719de8,0x71b178,0x71b198,0x71b1d4,0x71b328,0x71b344,0x71b46d`; `0x83395a` | `ev_d730d5b2ce966d2db96adb7ae57cdbff04709767f86fbb4d7501de983dab116b` (find), `ev_970cd5c83c33bcae41ef648b894eeadefa0cc8ba17487e2e864f0a048a0b6800` (full list) |
| `GetBitmapPixel` | **1** | `0x60ce36` (file `0x20c236`) | `ev_c61f69a6553565afc22f71f9e511d77e0d64bed3d2644c1bbc70e6f597732f65` |
| `GetMapCollisionTag` | **2** | `0x687f0e` (file `0x28730e`), `0x687f62` (file `0x287362`) — truncated name `GetMapCollisionTag…` | `ev_40afefab42c1f5c64171d9dee72952522b1e70a36f92f79118ef8bac440c6803` |
| `SmoothTerrain` | **2** | `0x6a395a` (file `0x2a2d5a`), `0x6a3b12` (file `0x2a2f12`) | `ev_189fb823954c2c91272ab682c11be29de5885baab792d3caa4bb510f81d97883` |
| `MapGeneratorSmoothTerrain` | **1** | `0x6a394e` (file `0x2a2d4e`) | `ev_26036f09441838a636ffc4096e37b60dcec0d70f3e587bbe0c2b98c3b7fa3a48` |
| `GetHeightData` / `SetHeightData` | **1 / 1** | `0x6a3cae` (file `0x2a30ae`) / `0x6a3cea` (file `0x2a30ea`) | `ev_a1717475fcb766ff238c9f6d48ca8f5264ad6b6c2c10da2f506c36ab3c6030bc` / `ev_8fc4e8f107af520ddb6a0463d0d2ae0fa7f99954dbc21f6b546fa7f5b0fdd2b3` |
| `StandPattern` | **4** | `0x6a33e6,0x6a347e,0x6a34fa` (+1 in run) | `ev_2847eed51d0f400b6503e43142ff826995da8b0de3c3e9a4c076bc384f123419` |
| `Pattern` (generic) | **169** | e.g. `0x4392da,0x44258d,0x4b8b14` (first 3) | `ev_e5f2f99f11bc517b3af373670568089ba111a575aa8bc42e4d719bb6f74ffc67` — counted `[O]`, uninterpreted `[U]`; no density table claimed |

`Forest` contexts (all `[O]` file-bytes reads, none is a density/count API):

- `0x514533` (`ev_3e8c53339d2d26fc191769607be88e1bced4644914453f149638ba307569d4cf`): `Forest.seCity.seMountains.seQuarry.sePlain.seParkingLot.seSewerPipe.seUnderWater.…` — sound/ambience enum run.
- `0x718f0d` (`ev_b7c4939bcf0a2b0fe6cd53f6b4983cdbdbc5a37b488d85efa9c7051e73dcf89e`, inside `sub_718ae0 +0x42d` per `ev_ed2cf8f9745851e47a8e762d10acc9881357ba85d2e62ea1964dfa4ca2e61400`): `ForestPatternsFileName / ForestMapFileName / TileChallengeFileName / ForestTileChallengeFileName / RiverKeyPointsFileName …` — config property-table run.
- `0x7191d2` (`ev_4c7369fb7944e57255d10693e395ee5339662907eac69d38f95200051afed991`): `ForestPlayerName / ForestPlayerRace / BridgePlayerName …`; `0x7191fd` (`ev_0f09010065f5742663ecdb7dde1d024db13a7be633dac117dc1a511ab80f7ebf`): continued player/bridge/town-road names.
- `0x7193ea` (`ev_63f9cbe76a43f59f8c4a7d0d4b23dc2f2a3b48339ae18a3275f583714141fbbc`): `Forest / NoIntersect / UpdateTerrain / LoadRivers / GetRiverPoin…` — script-API name run.
- `0x719a41` (`ev_df008ea9f5550eea65813d6c658fe7c0b76c972fd9bde0d37bd6847607b669e1`), `0x719d93` (`ev_5c30e9e1e719c94064ac23b387aca8303dbb64b10e71ea93f84e59875d4ef36e`), `0x719de8` (`ev_b14fe02de678793bb7fe96485d4c8b94dac7681404e437f693d20f8b732c5c24`) — challenge-list / bitmap property runs.
- `0x71b178` (`ev_3f982a77cb1f94f85f0fcff40a7aa5b3dfa4481f126760ae1ea3f5eeab3f10c6`): short property names `ForestPatternsFileName / ForestMapFileName / TileChallengeFileName / …`.
- `0x83395a` (`ev_64fb538b06e110cffc1dfc49f3fc66dbc7d29e4fbf7523a130b9ede1c67c4e35`): `Forest.seCity.seMountains.seQuarry.sePlain.seParkingLot.…` — second ambience-enum copy.

## 2. Pass (b) — wrapper arities: no native consumer turns G into a count `[O]`

| Wrapper (CODE literal) | Full signature from adjacent bytes | Arity | G/density param? |
|---|---|---|---|
| `GetBitmapPixel` @`0x60ce36` | `GetBitmapPixel(const bitmap, x, y: Integer; var r, g, b, a: Float)` (`ev_b878c83694a4ff56a4d760fdfa4732706704a243e3553155f5eb4cf98f980882`, re-read `ev_08520d4217a81f42d11600fb654eee769749c0518238ce601db45c5bc3dd675a`) | 3 in + 4 var-out | **No.** G is a `var Float` out-param (pixel reader), not a count in-param. `native_function_find` → not inside any discovered function (`ev_9f1e536eeb902b25ff19e3fa6c39d127bdc17ce021cebde5b9972dc6c15001a7`) — undiscovered high-VA region, bytes stepped cleanly |
| `SmoothTerrain` @`0x6a395a` / `0x6a3b12` | `SmoothTerrain(const x, y, passes: Integer; const radius: Float)` (`ev_6bd09713368250485746569e118eddb4ba6b167ca39734ab8cb7ebd411bd8423`) | 3 Int + 1 Float | **No.** Operates on height cells; takes no mask byte, no density |
| `MapGeneratorSmoothTerrain` @`0x6a394e` | `MapGeneratorSmoothTerrain(const x, y, passes: Integer; const radius: Float)` (`ev_e277498899f0050617c10779ed01baa076f2c1effa9e3c2788670ff5de83a604`) | 3 Int + 1 Float | **No.** Same shape; donor call `SmoothTerrain(realx,-realy,False,3)` binds `3` to `passes: Integer`, not a radius (DEC_U_smooth_kernel_deep correction carried) |
| `GetHeightData` @`0x6a3cae` / `SetHeightData` @`0x6a3cea` | `GetHeightData(const x, y: Integer): Float` / `SetHeightData(const x, y: Integer; const cheightvalue: Float)` (`ev_c63b5cd2d8414531b2c95768da8d174f08d43a2773f93e2a4a68f19a5444118d`) | 2 Int → Float / 2 Int + 1 Float | **No.** Height-only; no G/fdens channel |
| `StandPatternWithAngle` @`0x6a33e6` | `StandPatternWithAngle(const plhandle: Integer; const patternname: String; const standx, standz, rotangle, minangle, maxangle: Float)` (`ev_307dc24ef5938c8cfc2f15b2581634e928a881ce9b7af56ead08b64130dd9fda`, `ev_6e065c7ef24033c75b0236aa3341f2667143b06e3d977b838ab6eb647bfe51d3`; `native_function_find` undiscovered, same tool limit) | 1 Int + 1 String + 5 Float | **No.** Pattern identity is a **name**, placement is **coordinates**; no G byte |
| `StandPatternAdv` @`0x6a34fa` | `StandPatternAdv(const plhandle: Integer; const patternname: String; const standx, standz, rotangle: Float; makegr, movetopar: Boolean; grname, parbase: String; parind: Integer): Integer` (`ev_dc6340732b4216387d0af9ac488997091eede035a8c58badeab7dcbfb39bcfd7`) | mixed, returns Integer | **No.** Same name+coords shape with group/move flags; no density in-param |
| `GetMapWidth` @`0x69d3c2` / `GetMapHeight` @`0x69d3ee` | names only (`ev_f080587023912e6aa07630ba826d0f59afe694786cf58fe0002117f1e5560c31` / `ev_e4379d2ed811cd210e21f6795585892ebd63ed52c0eee3f92900447d3c49683a`) | — | **No.** Extent getters, not per-cell consumers |

**[D]** consequence: the only CODE path that ever *receives* a G value is the `var g: Float` out-param of `GetBitmapPixel` (script-side decode at `generatemap.inc:444-495`); every downstream native entry that could stamp a pattern or write height takes names/coords/height — **there is no byte-proven native edge `ig/fdens → needed/count`**. The live count dials remain exactly the two text-side passes carried from `DEC_U_placement.md §2`: `SetupStartingResources` ring probes and `_misc_SetupPatternsByType` global passes (`needed=floor(W·H·freq)`, `trycount=floor(256·mapsizeoptimise)`, name → centred uniform draws → `CheckStandPatternExt` → damp-on-accept).

## 3. Pass (c) — shipped mask bundles read-only: non-zero G on non-start cells `[O]`

Tool: read-only Pillow decode (no donor execution, no repo write; temp-free one-liners). Start = exact `(255,255,255)`; non-start G≠0 counted over all other pixels. Five masks across four shapes re-decoded this pass (second instrument alongside the X18 numpy+Pillow census, which is cited — not re-argued — for the 1,331-file headline):

| Mask (donor path under `C:\Games\Cossacks 3\data\gen\terrainmasks\`) | dim | starts | non-start G≠0 | non-start R distinct |
|---|---|---|---|---|
| `mediterranean/4pl_mask_mediterranean_22_gauss.tga` | 320² | 4 | **0** | {0} |
| `islands/2pl_mask_islands_0_gauss.tga` | 320² | 2 | **0** | {0} |
| `nowater2/4pl_mask_nowater_170_gauss.tga` | 320² | 4 | **0** | {0} |
| `land/4pl_mask_land_0_gauss.tga` | 320² | 4 | **0** | {0} |
| `peninsulas/2pl_mask_peninsulas_0_gauss.tga` | 320² | 2 | **0** | {0} |

Carried corpus truth (X18 `[O]`, X19 P3 agreement): all **1,331** vanilla `_gauss` masks — 136,294,400 px — have R/G ∈ {0,255} with exactly 5,125 white starts and **0 non-start pixels with R≠0 or G≠0**; the only known non-zero-G non-starts anywhere are the **8 anomalous grey pixels** (`R=G=B ∈ {5,7,128,145}`) in the two DLC5 `8pl_mask_continents_{8,9}_gauss.tga` files at the exact F04/X18 coordinates — a source-data anomaly, never a vanilla density channel `[O]` carried.

**[D]** derivation for the port: with `ig=0` on every non-start cell of the §3 files, the port match at `terrain_donor_gen.gd:1350-1358` (`255→1; 127-gated→1; 64→2; 128→3; 192→4; else→0`) yields **`fdens[i]==0` on every placeable cell** — i.e. the shipped-mask zero-mismatch half of the B6 angle is satisfied on the re-decoded files **without inventing any `G→count` map**. The `ig=127→cGForest` gate (`:1352-1354`, P-PLACE-01: only when decoded `terrain∈{1,2,3}`) is dead code on these inputs (`terrain=cRNone` everywhere off-starts) and is kept as labelled schema intent, never as live density `[O]` port text.

## 4. Pass (d) — no zero-density branch writes height `[O]` + port side

Donor text (carried verbatim, re-cited — not re-derived — from `DEC_U_placement.md §1` / `PORT1TO1_terrain_generation.md §§B-C`):

- Height: `hwater := cWaterHeight*(fb*(1+fr*3.5))` (`generatemap.inc:567`); `hterrain` by R class × `fr` (`:569-573`); `SetHeightData(realx,realy,hwater+hterrain)` (`:574`). **G/`ig`/`fg` appears nowhere in the height computation** `[O]` text.
- Start skip in the height pass: `if (bRandomMap) and (fr=1) and (fb=1)` (`generatemap.inc:565`) — **`fg` ignored** (asymmetry carried); port mirrors it exactly at `terrain_donor_gen.gd:1370-1372` (`skip_height := b_random_map and fr==1.0 and fb==1.0`) `[O]` port text.
- S0 gate: `bsmooth` cells → `SmoothTerrain(realx,-realy,False,3)` (`generatemap.inc:591`); all shipped `bsmooth=False` so the stage is inert on vanilla masks `[O]` carried. S1/S2 gates: interior `x>minx ∧ x<W/2 ∧ y>miny ∧ y<W/2` + diagonal-differs + `[minh,maxh]` band, and coastal `gMapMask.water==cBWater` (B byte **==255**) + radius-2 class neighbourhood (`:611-637`) — **neither gate reads `forest`/`fdens`** `[O]` text.
- Border dress (`smoothforestborders.inc:36-148`, carried): `count=floor(1+RandomExt*16)` with unconditional `break` at `:151` → **one stamp per eligible single-neighbour edge**, `rad=1.5`, `grid=3` cells at 2.5% — a **dress** path on `G`-selected cells, not a density derivation; port keeps it as a labelled NULL stub (`_stage_forest_borders`, telemetry `forest_borders=SKIPPED`, P-PLACE-11) and never synthesises `fb_*` props `[O]` carried.

Port side (repo file:line, read-only `[O]`): `terrain_donor_gen.gd:189-192` (`C_GCOLOR_*` enum literals), `:1339-1358` (gated decode + `else→0`), `:1344-1348/:1381-1384` (side-data-only comments citing U-G0/N17), `:1384` (`assign_side("forest_density", fdens)`), `:863` (U-G0 probe label). **No `forest_density → stamp-count` edge exists anywhere in the port** — the report's own grep surface (`_setup_patterns_by_type`, start-ring steps, mine bands) takes counts only from `needed/trycount`/ring geometry `[O]`.

## 5. Fixed-seed map byte-dump zero-mismatch experiment (T-G0 stays `[U]`)

Common harness (never invent; owner/COORD-gated where a donor run is required):

- Pin `t_87f0f3c130b0`; fix `randkey0=0, randkey1=<K>` (primary `K=1`; repeat `K=12345`), `W=H=320` (repeat 256/640 once), `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`, `foreststype=0`, caller `pattern_modifiers={small:1,mid:1,large:1,huge:1}`, fixed `families/patterns` bundle.
- Run the port `generate()` twice; diff the named arrays/counts below. **Terminate an item only on zero mismatches across the stated repeats; otherwise it stays `[U]`.**

| Check | Named dump | Termination (zero mismatches) |
|---|---|---|
| C-G0a (this angle, port-internal) | `forest_density` side array on **3 shipped `_gauss` masks** with starts masked (§3 files + one more `nowater2` shape) | `fdens==0` on **every** off-start cell, 3/3 masks, 0 differing bytes. Never add a `G→count` map to force a match |
| C-G0b (height non-write) | `height` grid on the same 3 masks + `bsmooth`/water-class flags | height `== -1.1·(B/255)` cell-for-cell (starts excluded), 0 ULP diffs; zero height delta when `fdens` is forced through the `else→0` path vs masked — i.e. the zero-density branch provably writes no height |
| C-G0c (live dials, owner/COORD) | per-family `needed/trycount` trip counts + accepted-stamp counts from `SetupStartingResources` + `_misc_SetupPatternsByType` on fixed seeds | `needed==floor(W·H·freq)` exact and accepted counts identical across repeats, 0 mismatches; roulette/damping/occupancy ledger attached |

Until C-G0a/b/c all terminate, the register entry stays exactly as written: `T-G0 | G=0 zero-density closure | Fixed-seed mask check | fdens==0 off-starts, 0 mismatches | STATIC` (`PORT1TO1_u_register_update.md §2.2`), now with the CODE-search half (`no G→count consumer in packed bytes`) CLOSED-STATIC and the live-count half `[U]`.

## 6. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | 5 ticket needles + 24 vocabulary patterns searched packed CODE pinned `t_87f0f3c130b0`, all 0 hits (file-bytes absence; packed tail opaque per X31); evidence ids in §1.1–§1.2 | `[O]` this pass |
| 2 | Positive CODE controls with VAs/file-offsets: `Forest` ×17 (property/file-name strings, §1.3 contexts), `GetBitmapPixel` ×1 @`0x60ce36`, `GetMapCollisionTag` ×2, `SmoothTerrain` ×2 + `MapGeneratorSmoothTerrain` ×1, `Get/SetHeightData` ×1/×1, `StandPattern` ×4; `Pattern` ×169 counted, uninterpreted | `[O]` this pass |
| 3 | Wrapper arities byte-proven (§2 table): G enters CODE only as a `var Float` out-param of the pixel reader; every stamp/height native takes names/coords/heights — no `ig/fdens→count` edge exists in packed bytes | `[O]/[D]` this pass |
| 4 | 5 shipped masks re-decoded read-only: non-start G≠0 = 0 on every file; port `else→0` derives `fdens==0` off-starts; DLC5 8 grey pixels carried as anomaly, not density | `[O]` §3 + `[D]` port match |
| 5 | Zero-density branch writes no height: height/smoothing gates read `fr/fb/bsmooth/water-class` only, never `fdens/ig`; port `forest_density` is side data, counts come only from pattern passes | `[O]` donor text + port text, §4 |
| 6 | No value promoted; T-G0 stays `[U]` with the §5 C-G0a/b/c zero-mismatch battery; no `G→count` formula invented | `[O]/[D]` scope + §5 |
| 7 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared by this worker | `[O]` scope guard |
| 8 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no approximation adopted; exactly one repository file written | `[O]` scope guard |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; T-G0 selectors (`SetupStartingResources` ring probes, `_misc_SetupPatternsByType` global counts) remain `[U]`; B6 packed-CODE half CLOSED-STATIC (no G→count consumer), shipped-mask zero re-verified on 5 files. **No invented density; no parity claim.**

*End of DEC_U_b6_g0. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
