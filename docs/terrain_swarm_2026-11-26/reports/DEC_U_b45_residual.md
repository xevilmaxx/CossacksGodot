---
id: DEC-U-B45-RESIDUAL-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B45 — residual angles B4 (T-SMOOTH packed-CODE radiusFloat/mb consumers) + B5 (T-VER mapsize/gRecordGeneratorVersion native selector)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b45_residual.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined."
scope_guard: "Exactly one repo file written (this report). Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state changed. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode, shared Craft Anything session). Every native call pinned with document=t_87f0f3c130b0. Binary never executed."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.2 domain T all-B; §4 B4 T-SMOOTH/MINMAX/MOD, B5 T-VER/MDEN/HF/OBJ)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md (§2 B4 EXECUTED-partial, B5 EXECUTED-partial; §3.1 NB-7 S0 kernel body)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_smooth_kernel_deep.md (mb:Integer signature correction [D]; 0x6a39xx string window; kernel body undiscovered)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tver_deep.md (ship envelope 53/320²-384² vs port 92/240²; 8 script-namespace patterns 0-hit; MapSize×9/DefaultMapSize property table)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb7.md (S0 window is registration strings; S0/VM [U])
---

# DEC-U-B45-RESIDUAL — T-SMOOTH packed-CODE residual + T-VER native-selector residual

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0` (not port test ids).
> Context carried: `PORT1TO1_b_angle_final` marked original class-B B4 (smooth kernel) and B5 (T-VER) PARTIAL because their COMBINED §4 angles from `PORT1TO1_u_classify.md` were not fully lifted. This worker executes verbatim the two residual angles: (a) any remaining packed-CODE angle for `MapGeneratorSmoothTerrain` radiusFloat and S0 `mb:Integer` consumers outside the exhausted `0x6a39xx` string window; (b) the remaining `mapsize`/`gRecordGeneratorVersion` native selector angle beyond the already-proven string-table negatives. Result: no kernel body, no radius value, no version value — every selector stays `[U]` with its exact zero-mismatch termination.

## 0. Method, pin and pass ledger

Pin re-verified before and after the passes: `core_session_show` active target `t_87f0f3c130b0` (cossacks.exe, 5,768,048 B) at open and at close of this job. Every native call below passed `document="t_87f0f3c130b0"`. No donor binary executed; no donor bytes copied.

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_bytes_find` exact `RaiseTerrain` / `LowerTerrain` / `PlateauTerrain` / `RandomHeightTerrain` (sibling `mb:Integer` sharers) | `RaiseTerrain` 1 hit `0x6a39ae` (ev_1f81a7f9…); `LowerTerrain` 1 hit `0x6a3a22` (ev_52434b02…); `PlateauTerrain` **5 hits**: `0x6a3a96` + `0x842c30/0x842c4c/0x842df0/0x842e0c` (ev_c83cb909…); `RandomHeightTerrain` 1 hit `0x6a3b72` (ev_fc52e0c2…) — all section CODE [O] |
| P2 | `native_bytes_show` `0x6a394e+900` (radiusFloat registration run re-read) | ev_f0cdc98e…: contiguous `MapGeneratorSmoothTerrain(x,y,passes:Integer;radius:Float)` → `Raise/Lower/Plateau/Smooth/RandomHeightTerrain` → `PaintTerrain` → `GetHeightData` verbatim, byte-identical to the smooth-kernel-deep P6 window [O] |
| P3 | `native_bytes_show` `0x842c30+700` + `0x71c280+512` (outside-window candidates) | ev_61b12631…: `0x842c30` run is a CODE-embedded **property table** (`PlateauTerrain / AutoPlateauTerrain / AutoPlateauTerrainRadius / AutoNormalizeTerrain / AutoDirectToCenter / Offset / AutoOffset / OffsetCollideOption …`, each `00 ff <len> …` framed); ev_dbb63717…: `0x71c280` run is a CODE-embedded **generation-settings property table** (`FrequencyFactor / CellsResolution / FailStandCount / DefaultMapSize / TileSmoothPasses / TileSmoothListFileName …`, `84 10 40 …` float-default words) [O] |
| P4 | `native_bytes_find` exact `TerrainTypesDLC5` / `DefaultMapSize` / `TileSmoothPasses` / `AutoPlateauTerrainRadius` / `gen.mapsize` (T-VER residual spellings) | `TerrainTypesDLC5` **0** (ev_7b76fc1a…); `gen.mapsize` **0** (ev_a81e9c84…); `DefaultMapSize` **2** `0x71c30e/0x71d19c` (ev_cb420f37…); `TileSmoothPasses` **4** `0x71912d/0x71b2c4/0x71c337/0x71d1b4` (ev_e3c01bb8…); `AutoPlateauTerrainRadius` **2** `0x842c48/0x842e08` (ev_e9fc10cc…) — all section CODE where hit [O] |
| P5 | `native_function_find` `0x6a394e` / `0x842c30` / `0x71c30e` | `0x6a394e` not inside any discovered function (ev_cb7d2f7f…, re-affirms smooth-kernel-deep P8); `0x842c30` likewise null (ev_6229297e…); `0x71c30e` inside `sub_71c0b4+0x25a` (ev_cd521f71…) [O] |
| P6 | `native_xrefs_list` `0x6a394e` / `0x71c30e` | Both **0 references from / 0 to** (ev_afe1a905…, ev_81599193…) under the stated computed-pointer limit [O-absence with reserve] |
| P7 | `native_function_disassemble sub_71c0b4` (922 insns) + `native_bytes_show 0x6e940a+256` | ev_af3c5fa3…: disassembly of the property-table region decodes as nonsense (`outsb / bound / arpl / imul … "MapGener…"`, `… "TileSmoothListFileName"` as immediates) — confirms **data table, not executable selector code** [O]; ev_dbed6476…: `0x6e940a` is the parser accessor family `ParserGetIntValueByKeyByHandle / ParserGetFloatValueByKeyByHandle / ParserGetBoolValueByKeyByHandle` (the `ver`-key read path exists as API names; no `ver` literal value table is claimed) [O] |
| P8 | `native_bytes_find` exact `AutoSmooth` / `SmoothRadius` / `Mapsize` (case variants) + session re-check | `AutoSmooth` **0**; `SmoothRadius` **7** (`0x719575/0x719735/0x71b54d/0x71b664/0x7297e4/0x7297fc/0x75c86b`); `Mapsize` **0** (ev_6dd00535…); session still active `t_87f0f3c130b0`; `mb` substring 261 hits (uninterpreted, not enumerated — no consumer claimed from it) [O] |

**Strange-read log:** `native_bytes_find` searches stored file bytes only — compressed/packed regions and runtime-built strings are not seen, so a 0-hit result is file-bytes absence, not engine-side absence (carried from smooth-kernel-deep §0.1 P1–P5 and tver-deep §1). `native_function_find` null carries "the address may be in code the engine didn't discover". `native_xrefs_list` 0-hit carries "references made through computed pointers at run time are not seen". The `sub_71c0b4` disassembly is deliberately cited as a **negative**: the engine disassembles a data table as instructions, which proves the region is a table, not that any instruction there executes. No donor binary executed; no donor bytes copied into the repo.

## 1. Residual angle (a) — T-SMOOTH packed-CODE beyond the `0x6a39xx` window

### 1.1 What the sibling-registration census adds [O]

- The full `mb:Integer` family is now VAs-fixed in one contiguous CODE registration run (ev_f0cdc98e…, byte-identical re-read of the smooth-kernel-deep window): `MapGeneratorSmoothTerrain 0x6a394e` → `RaiseTerrain 0x6a39ae` → `LowerTerrain 0x6a3a22` → `PlateauTerrain 0x6a3a96` → `SmoothTerrain 0x6a395a/0x6a3b12` → `RandomHeightTerrain 0x6a3b72` → `PaintTerrain` → `GetHeightData/SetHeightData/TerrainUpdate/MapGeneratorSmoothTiles`.
- **[D] consequence (structural only):** the S0 call `SmoothTerrain(realx,-realy,False,3)` still binds `(x,y,round,mb)` with `3 → mb: Integer`; the **only** Float-radius smooth entry in the whole run remains the unused-by-S0 `MapGeneratorSmoothTerrain(x,y,passes:Integer;radius:Float)`. No second `radius: Float` overload, no `SmoothTerrain` variant with a Float parameter, and no `mb`-enum table was found in this residual pass. The literal `3` gains no new name here.
- `function_find` misses at the radius entry `0x6a394e` (ev_cb7d2f7f…) and xrefs on it return 0/0 (ev_afe1a905…) under the computed-pointer reserve — same standing as the `0x6a395a` table VAs. **No kernel body, no radius consumer, no `mb` consumer is localized from the registration run.**

### 1.2 The only outside-window hits are property tables, not kernel code [O]

- `PlateauTerrain`'s 4 extra hits (`0x842c30/0x842c4c/0x842df0/0x842e0c`) decode (ev_61b12631…) as a CODE-embedded Delphi published-property table for an auto-plateau/offset feature family: `AutoPlateauTerrain / AutoPlateauTerrainRadius / AutoNormalizeTerrain / AutoDirectToCenter / Offset / AutoOffset / OffsetCollideOption …` followed by `AutoExt` dispatch bytes. `function_find` at `0x842c30` is null (ev_6229297e…): the region is table data the engine did not discover as a function.
- The T-VER-adjacent `DefaultMapSize / TileSmoothPasses` hits (P4) and the `SmoothRadius` 7-hit set (P8: `0x719575/0x719735/0x71b54d/0x71b664/0x7297e4/0x7297fc/0x75c86b`) land in the same **kind** of region: CODE-embedded property/field tables (the `0x71c280` run ev_dbb63717…; the `0x75c8xx` engine-field run already characterised in smooth-kernel-deep P7). The attempted disassembly of `sub_71c0b4` (ev_af3c5fa3…) returns instruction-nonsense over ASCII property names — the expected signature of disassembling data, cited here only to **refuse** any control-flow claim from that region.
- `AutoSmooth` returns **0 hits** file-wide. There is therefore **no observed `SmoothTerrain` counterpart** to the `AutoPlateauTerrain(Radius)` property surface: no auto-smooth toggle, no auto-smooth radius row, no smooth-kernel default word is byte-proven anywhere in this pass.
- **[D] residual consequence:** outside the `0x6a39xx` string window the packed CODE yields **property-table structure only** (plateau/offset auto-family; generation-settings table; field-name rows). No neighbour array, loop bound, load/store, weight, `mb` dispatch, or radiusFloat default is decoded from any of these tables in this pass — adjacent-word typing without the table schema would be inference and is refused. The kernel-body, scope and `mb=3`-semantics questions are untouched.

### 1.3 Still-[U] after the residual (exact terminations)

| ID | Statement | Termination (zero-mismatch, else stays [U]) |
|---|---|---|
| U-S0-KERNEL | Native `SmoothTerrain(x,y;round;mb)` body: neighbour topology, weights, loop bounds, `mb=3` semantics, `round=False` effect, `-y` handling | **Byte-proven kernel dump**: disassembly/pseudocode of the engine function reached through the `0x6a395a/0x6a3b12` registration via a computed-pointer-respecting trace (not a string-xref), reproducing the port hook `hook(height: PackedFloat32Array, w: int, h: int, bsmooth: PackedByteArray, mb: int=3)` in place. Comparison: on fixed seeds, hooked-port height grid equals the dumped kernel output cell-for-cell with **0 differing cells on 320² AND 640²** (both sizes; shipped-mask + synthetic-bsmooth-checker fixtures). One differing cell fails it. Until then `bsmooth_kernel=NULL`, `bsmooth_pass=SKIPPED` on all fixed seeds. |
| U-S0-SCOPE | Per-call write footprint (single cell vs neighbourhood vs whole grid) | Same dump must show the written address range per call (target-only vs neighbour writes). No separate capture; falls out of the dump. Until then no scope claim. |
| U-S0-RADIUSFLOAT | `MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` body and its `radius`/`passes` consumers | Same bar as U-S0-KERNEL for that entry (`0x6a394e` computed-pointer trace + 0-diff on 320² AND 640²). The signature string alone is not a consumer. No radius value (no `3.0`, no window size, no pass count) is claimed from the signature text. |
| U-MB3 | Meaning of `mb=3` shared with Raise/Lower/Plateau/RandomHeightTerrain | Named only by a second static anchor (a second call site with a different `mb` literal, or an enum/comment byte naming `mb`) — never by guessing from the value 3. The sibling VAs above do not supply it. |

**Denied:** any box/gaussian/lerp blur, any "radius 3 = 3×3/7×7 window", any `mb=brush-size` gloss, any "modifies only bsmooth cells" kernel claim. The port keeps `bsmooth_kernel` NULL with `SKIPPED` telemetry.

## 2. Residual angle (b) — T-VER `mapsize` / `gRecordGeneratorVersion` native selector beyond the string-table negatives

### 2.1 What this residual pass searched [O]

- Script-namespace negatives extended: `TerrainTypesDLC5` **0** (ev_7b76fc1a…), `gen.mapsize` **0** (ev_a81e9c84…), `Mapsize` (capital-M variant) **0** (ev_6dd00535…) — same standing as the eight tver-deep P-a negatives (`gDataVersion`, `gRecordGeneratorVersion`, `mapsize`, `gc_Max`, `MaxTerrainTypeCount`, `TerrainTypeCount`, `RecordGenerator`, `TerrainTypes`, `Tiny` all 0). The live version/menu words remain **donor-text-side only** (sole writer `gDataVersion:=92 serial.script:27`; record/new-game fan-out `initmapgen.inc:57/62/72`; mapsize enum `0→320,1→480,2→640,3→256`; `gc_MaxTerrainTypeCount=9` — all carried from tver-deep §3, not re-dumped here).
- Positive CODE hits re-confirmed and bounded: `DefaultMapSize` **2** (`0x71c30e/0x71d19c`, ev_cb420f37…); `TileSmoothPasses` **4** (`0x71912d/0x71b2c4/0x71c337/0x71d1b4`, ev_e3c01bb8…); `AutoPlateauTerrainRadius` **2** (`0x842c48/0x842e08`, ev_e9fc10cc…). Contexts (ev_dbb63717…, ev_61b12631…) place every one of them in **CODE-embedded property tables**, not in executable selector code. The numeric default words adjacent to `DefaultMapSize` (`84 10 40 …`) were **not** decoded to a value in this pass — adjacent-word typing without the table schema would be inference and is refused (same reserve as tver-deep §1.3).
- Parser accessor family exists as CODE API names at `0x6e940a` (ev_dbed6476…): `ParserGetIntValueByKeyByHandle / ParserGetFloatValueByKeyByHandle / ParserGetBoolValueByKeyByHandle`. This is the mechanism the `ver`-key reads (`initmapgen.inc:72`) go through, but **no `ver` literal value table and no record-`ver` integer** was dumped at a proven offset in this pass. The live `gRecordGeneratorVersion` word and the live menu `mapsize`/terraintype indices remain unobserved.
- `function_find` puts `0x71c30e` inside `sub_71c0b4+0x25a`, but the 922-insn disassembly of `sub_71c0b4` (ev_af3c5fa3…) is table-bytes-misread-as-code (ASCII property names as immediates, `outsb/bound/arpl` nonsense): it proves the region is **data**, and no control-flow, default-value, or selector claim is drawn from it. Xrefs on `0x71c30e` return 0/0 (ev_81599193…) under the computed-pointer reserve — so no native selector caller is localized from the property row either.

### 2.2 Still-[U] after the residual (exact termination)

| ID | Statement | Termination (zero-mismatch, else stays [U]) |
|---|---|---|
| U-TVER-SELECTOR | Live integers selecting the version-gated branches (`gRecordGeneratorVersion` vs `<80/<91` bands, `mapsize>2` ≡ 256-cell TINY, `v<91 → 6-way else N-way`, mine-band matrix, 16×8 fallback): which live `gDataVersion` / `gRecordGeneratorVersion` / `mapsize` / `gc_MaxTerrainTypeCount` values are active in a session | **Live-settings dump + owner paired-save battery**: record `ver` integers on both sides of v91, menu mapsize/terraintype indices, and the re-save `5C 00 00 00` control, compared against the fixed shipped heads (`35 00 00 00`=53 envelope, `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, terrain 320²×3 + 384×1, sub=4, w4 64 vs 25920) with **0 mismatching words** across ≥2 shipped maps plus the paired-save control. Until then 92 stays the current-script-word literal only, 240² stays a port debug alias, and every branch selector stays `[U]`. |
| U-TVER-NATIVE-VALUE | Any CODE-constant version/mapsize default (e.g. a `DefaultMapSize` numeric default, a `ver` constant, a mapsize-enum jump table) | **Typed table-schema decode**: the property-table schema (field लें / type tag / default-word layout) byte-proven from a second anchor (a second table instance with the same framing, or a reader function consuming the framing), then the default word read through that schema — never by guessing adjacent bytes. No such schema anchor was recovered in this pass. |

**Verdict for (d) re-affirmed, not re-derived:** the port pins (`C_BROKEN_GENERATOR_VERSION = 92`, `generate()` default 92, `config.json` 240² debug alias) do **not** byte-match shipped artifacts (53 envelope; 320²/384² extents) per tver-deep §4. No value is promoted here; the mismatch stands and the selectors stay `[U]`.

## 3. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | Sibling `mb:Integer` family VAs fixed in one CODE registration run: `RaiseTerrain 0x6a39ae`, `LowerTerrain 0x6a3a22`, `PlateauTerrain 0x6a3a96`, `RandomHeightTerrain 0x6a3b72` around `MapGeneratorSmoothTerrain 0x6a394e`; `PlateauTerrain` has 5 total CODE hits (1 registration + 4 property-table at `0x842c30/0x842c4c/0x842df0/0x842e0c`) | [O] ev_1f81a7f9…/ev_52434b02…/ev_c83cb909…/ev_fc52e0c2… + ev_f0cdc98e… (§1.1) |
| 2 | `0x842c30` neighbourhood and `0x71c280` neighbourhood are CODE-embedded property tables (plateau/offset auto-family; generation-settings `FrequencyFactor…DefaultMapSize…TileSmoothPasses…`); `sub_71c0b4` disassembly is table-bytes-as-code nonsense; adjacent default words not typed | [O] ev_61b12631…/ev_dbb63717…/ev_af3c5fa3… (§1.2) |
| 3 | `AutoSmooth` 0 hits file-wide; no `SmoothTerrain` auto-property counterpart observed; `SmoothRadius` 7 hits are field-name rows (`0x719575/0x719735/0x71b54d/0x71b664/0x7297e4/0x7297fc/0x75c86b`), not a kernel consumer | [O] §0 P8 (§1.2) |
| 4 | `function_find` null at `0x6a394e` and `0x842c30`; xrefs 0/0 at `0x6a394e` and `0x71c30e` under the computed-pointer reserve — no kernel body, radius consumer, `mb` consumer, or selector caller localized | [O-absence with reserve] ev_cb7d2f7f…/ev_6229297e…/ev_afe1a905…/ev_81599193… (§1.1/§2.1) |
| 5 | T-VER residual negatives: `TerrainTypesDLC5` 0, `gen.mapsize` 0, `Mapsize` 0; positives bounded to property tables (`DefaultMapSize` 2, `TileSmoothPasses` 4, `AutoPlateauTerrainRadius` 2); parser `ByHandle` accessor family at `0x6e940a` names the `ver`-key mechanism but yields no live integer | [O] ev_7b76fc1a…/ev_a81e9c84…/ev_6dd00535…/ev_cb420f37…/ev_e3c01bb8…/ev_e9fc10cc…/ev_dbed6476… (§2.1) |
| 6 | No kernel radius or sample count recoverable from the call structure; no native version/mapsize default decoded; no invented radius, no invented version, no parity claim; kernel + scope + `mb` semantics + all T-VER selectors stay `[U]` with the §1.3/§2.2 zero-mismatch terminations | [D] over §§1–2 + scope guard |
| 7 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared by this worker; `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; exactly one repository file written | [O] scope guard |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; T-SMOOTH kernel/scope/`mb=3`/radiusFloat consumers and T-VER live selectors (`gRecordGeneratorVersion`, `mapsize`, live terraintype index) remain `[U]`; six-condition chain unchanged by this report. **RESULT IS NOT GOOD** while `blocking_unverified` is non-empty. No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of DEC_U_b45_residual. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
