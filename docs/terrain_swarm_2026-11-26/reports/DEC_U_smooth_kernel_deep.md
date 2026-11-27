---
id: DEC-U-SMOOTH-KERNEL-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SMOOTH-KERNEL-DEEP — native static localization of the S0 SmoothTerrain kernel (packed CODE tables, wrapper signatures, script alternative-kernel sweep, write-scope)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_smooth_kernel_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state changed. Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode, shared Craft Anything session). Every native call pinned with document=t_87f0f3c130b0. Binary never executed."
port_scope: "variant3d/scripts/terrain_donor_gen.gd cited read-only only where it owns the [U] hook fields (bsmooth_kernel NULL/SKIP); NOT edited, NOT re-specified."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (T-SMOOTH class-B B4: static lift of the kernel VA; §2.2 domain T all-B)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_placement.md (U-S0: call shape on bsmooth cells [O] D2:591; kernel body undiscovered high VA)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_gen_seed.md (P7: S0 kernel + TerrainUpdate NULL-hook SKIP; §5 bsmooth_kernel/terrain_update_hook)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_relief_stamps.md (U-S0 probe; R-4 KEEP NULL/SKIP)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_n17_gaps.md (N17-G11 hook signature hook(height,w,h,bsmooth,3); G-06 keep SKIP)
  - docs/terrain_swarm_2026-11-26/reports/DEC_LANDSCAPE_hills_water.md (§4 S0/S1/S2 chain; §1 P3 native 2-hit + 1-hit proof)
  - docs/terrain_swarm_2026-11-26/reports/D03_mask_pipeline.md (E09 order S0→S1→S2; U3 native kernel text/call-sites)
  - docs/terrain_swarm_2026-11-26/reports/F09_editor_script.md (SmoothTerrain call shape (x,-y,False,3), negated Y [O]; kernel/power [U])
---

# DEC-U-SMOOTH-KERNEL-DEEP — native static localization of the S0 `SmoothTerrain` kernel

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0` (not port test ids). "Address" = donor VA (`0x…`) for binary hits, `path:line` for donor text.
> Context carried: `DEC_U_placement` U-S0 + `DEC_U_gen_seed` P7 + `DEC_U_n17_gaps` N17-G11 recovered the script call shape `SmoothTerrain(realx,-realy,False,3)` on bsmooth cells [O] and parked the port behind `bsmooth_kernel=NULL/SKIP`; the native kernel body, its radius/sample count, and its write scope stayed [U]. This worker attempts the byte-proven native anchor. Result: signatures recovered, kernel body still undiscovered — one signature correction, zero invented weights.

## 0. Method, passes, tool limits

### 0.1 Pass ledger (multiple NEW passes on the pinned packed exe, not just script text)

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_bytes_find` exact `SmoothTerrain` | ev_7f7b87d0a9100e795cc9891f1491460d7b548ef3955217dc192aa6eae5981762: **2 hits, both CODE**: `0x6a395a`, `0x6a3b12` (file offsets `0x2a2d5a`, `0x2a2f12`) |
| P2 | `native_bytes_find` exact `MapGeneratorSmoothTerrain` | ev_f5476876ae54fe5dce47eb4188b0c193f9c156e8fb77a0375d587bc3c6f843ea: **1 hit, CODE**: `0x6a394e` (file offset `0x2a2d4e`) |
| P3 | `native_bytes_find` exact `bsmooth` / `bSmooth` / `BSmooth` / `SMOOTH` | ev_d1709b5633eca98eeceecd72254105be1b3315d00e87220735580435c6532ef6 (`bsmooth`: 0), ev_7a048a0e56f013177fcdcfc0217de3b8447d698fe39349bd01454fa58dfe3e3e (`bSmooth`: 0), ev_2d676612ce12e2993eba7896b7c5df1d8851e7aff610a236f7334b3f225ca626 (`BSmooth`: 0), ev_4c6a881cc525a56b0ca3c87da9cbe73918806e93633e26fc493811f542b19f86 (`SMOOTH`: 0) — **all zero** |
| P4 | `native_bytes_find` exact `GetHeightByte` / `SmoothHeight` / `GeneratemapSmooth` + case variants `smoothterrain` / `SMOOTHTERRAIN` | ev_be1ff326943522a078e923e89059dfe35320a94844b75413351a06edfde7db81 (`GetHeightByte`: 0), ev_469429f0d70ff9a08607c201517add8150fb62332050a1b108110b1e191acf28 (`SmoothHeight`: 0), ev_2423d32058fefe0c99a96a476afccc1bda4d2b47fff2e4d30a8202f45edfb02d (`GeneratemapSmooth`: 0), ev_45ec9d61de2049facd9d51d2f66596e475f8cbdc0457018dc8ccf50c9df237 (`smoothterrain` lower: 0), ev_cff0c432176727cdc668db35244ee0b85bb62951cdf08882ee2fb1fe222f1e46 (`SMOOTHTERRAIN` upper: 0) — **all zero; matching is case-sensitive, only exact-case `SmoothTerrain` exists** |
| P5 | `native_bytes_find` exact `Smooth` (substring census) | ev_00b781e1b54c84746602587536d47ecbbd1c698afbd5c2356893f6669e518a29: **107 total**, first page shows CODE hits incl. `0x6a395a`/`0x6a3b12` plus tile/smooth family — symbols live in **CODE-embedded tables** as in blend/tick, invisible to any data-section-only string index |
| P6 | `native_bytes_show` `0x6a3930+900` + `0x6a3a80+900` + `0x6a3800+500` + `0x6a38e0+1200` | ev_9a2de271cd19f5fd105298fbf673451e2ea9216538b6bbedb7ee6834850157a / ev_525f3565790a6240071528ddebe02721e56d98f66f4321b975b274fefad60747 / ev_791631bd00ed7d4926ca2cd7f8f3f5efd0bc79fd25fb646bd24b7614b4f012fca / ev_30579079b1dc270c6ed541d08d61610d484fbcfdc8ce02e64897b09a65fc17b0: **full wrapper-signature table** `0x6a3390–0x6a3e6e` (§1.2) [O] |
| P7 | `native_bytes_find` height/terrain API names: `HeightData` / `SetHeightData` / `GetHeight` / `TerrainUpdate` / `HeightField` / `SmoothTile` / `SmoothAll` | `HeightData` 4 hits (`0x6a3cb1/0x6a3ced/0x718d44/0x71b054`); `SetHeightData` 1 hit CODE `0x6a3cea` (ev_03c2f1b3222ce827c87e67c6a27e17f5d4c6183dd18349edb4ee9c3d648c2a9c); `GetHeight` 5 hits (`0x541996/0x541a12/0x541d63/0x541d89` RTTI + `0x6a3cae` API table); `TerrainUpdate` 1 hit CODE `0x6a3e6e` (ev_f2499ea859f379e15ef199ef4fa5e458f4529aab0badc3f492030d68ede548b6); `HeightField` 48 hits (ev_96c9671f1627c9a5146f8f364176c4054ac2d82f8ec962074abfee72a1ab06f4, incl. `0x54198b…` RTTI + `0x75c7xx` engine fields); `SmoothTile` 2 hits (`0x6a33c6` = `MapGeneratorSmoothTiles()`, `0x72dab0`); `SmoothAll` 0 hits |
| P8 | `native_function_find` `0x6a395a` + `0x6a394e`; `native_xrefs_list` `0x6a395a` | ev_1ec212956a4952daf3e1769fe3b2241f4393877b19513348444d6f986d4aed6a (`0x6a395a` not inside any discovered function) + ev_cb7d2f7f93ded0ca1957d4e51e1f68ad78ad0cfa8afe64cc82615bce75c5e53 (`0x6a394e` likewise) + ev_3021557ce34f71871eab5d8e44531fd30d8233e1c6b960494ea70db904156ea (0 xrefs to `0x6a395a`) — **table only, no code body localized** |
| P9 | `native_bytes_show` `0x541960+700` (GetHeight neighbourhood) + `0x6a3390+700` + `0x6a3c60+800` | ev_ff836253d49be10d1b7bbc73dade176482805528034199e52db60d78a9d4643 (`THeightFieldGetHeightEvent/GetHeight2Event`, `THeightFieldOption/Options/ColorMode` RTTI — heightfield event plumbing, **no smooth kernel weights**) + ev_1bebd7a46227c870012ab8334e27c3ce2ca5aabce836e2d1702e77c1ad0f49 + ev_ec4c4c5494057e0dad6b03ef700008b4870322da7d4d1455f5f0bbfbcf26d8b3 (`GetHeightData/SetHeightData/TerrainUpdate` signatures verbatim) |
| P10 | Donor-text re-read `generatemap.inc:200-320` (`_misc_SmoothTerrainCustom` body) + `:570-640` (S0/S1/S2 order) via `core_text_read` | New window ev_8553f8170c6f6cff3ea497c0c4127c4503dc67098f9fd1d4d3187771f88664a3 (`:580-610` S0 gate + `SmoothTerrain(realx,-realy,False,3)` + S1 land pass + commented `:607` negative-range line); body + order confirm prior D03/F09 reads byte-identically (see §3) |
| P11 | Donor-tree `//`-comment sweep for alternative kernel: every `*.inc` `Select-String "SmoothTerrain"` + `//` lines matching `mooth|power|lerp|weight|average|kernel|blur|gauss|radius|neighbour|neighbor` | `SmoothTerrain` occurs in exactly **2 live lines** (`generatemap.inc:38` const flag + `:591` call) plus profiler begin/end `:582/:595`; `procedure Smooth` declared exactly **once** (`smoothtiles.inc:191 SmoothTileMap`); `GetHeightByte/SmoothHeight/GeneratemapSmooth` **0 hits** tree-wide; `//` sweep returns only the `:607` disabled land-range line as a smoothing candidate (§3) |
| P12 | Port hook read `variant3d/scripts/terrain_donor_gen.gd:471-529,1440-1479` | `bsmooth_kernel: Callable = Callable()` (`:475`) NULL + `bsmooth_pass=SKIPPED` telemetry (`:1448-1455`), hook shape `hook(height,w,h,bsmooth,3)` (`:471-473,:1448-1449`); `terrain_update_hook` NULL (`:528`) — still parked, never a blur |

**Strange-read log:** `native_bytes_find` searches stored file bytes only — "compressed, encrypted or packed regions … are not seen, so no match is not proof of absence" (all P1–P5 carry the reserve; `.bind` entropy 7.96 exec per blend-deep P1, packed region not re-measured here). `native_function_find` misses at both table VAs under "the address may be in code the engine didn't discover (absence is not proof)". `native_xrefs_list` 0-hit carries "references made through computed pointers at run time are not seen" — so 0-xref localizes NOTHING and must not be read as "unreferenced". No donor binary executed; no donor bytes copied.

---

## 1. What the packed CODE DOES contain (new static localization) [O]

### 1.1 Hit/miss table with VAs (task (a))

| Name | Hits | VAs (CODE) / file offsets | Evidence |
|---|---|---|---|
| `SmoothTerrain` | **2** | `0x6a395a` (`0x2a2d5a`), `0x6a3b12` (`0x2a2f12`) | ev_7f7b87d0… (P1) |
| `MapGeneratorSmoothTerrain` | **1** | `0x6a394e` (`0x2a2d4e`) | ev_f5476876… (P2) |
| `bsmooth` / `bSmooth` / `BSmooth` / `SMOOTH` | **0 / 0 / 0 / 0** | — | ev_d1709b56… / ev_7a048a0e… / ev_2d676612… / ev_4c6a881c… (P3) |
| `GetHeightByte` | **0** | — | ev_be1ff326… (P4) |
| `SmoothHeight` | **0** | — | ev_469429f0… (P4) |
| `GeneratemapSmooth` | **0** | — | ev_2423d320… (P4) |
| `smoothterrain` / `SMOOTHTERRAIN` (wrong case) | **0 / 0** | — | ev_45ec9d61… / ev_cff0c4321… (P4) |
| `Smooth` (substring) | **107** | CODE-embedded incl. above + tile/smooth family | ev_00b781e1… (P5) |
| `HeightData` | 4 | `0x6a3cb1/0x6a3ced/0x718d44/0x71b054` | P7 |
| `SetHeightData` | 1 | `0x6a3cea` | ev_03c2f1b3… (P7) |
| `GetHeight` | 5 | `0x541996/0x541a12/0x541d63/0x541d89` (RTTI) + `0x6a3cae` (API) | P7 |
| `TerrainUpdate` | 1 | `0x6a3e6e` | ev_f2499ea8… (P7) |
| `HeightField` | 48 | `0x54198b…` RTTI block + `0x75c7xx` engine fields | ev_96c9671f… (P7) |
| `SmoothTile` | 2 | `0x6a33c6` (`MapGeneratorSmoothTiles()`), `0x72dab0` | P7 |
| `SmoothAll` | 0 | — | P7 |

[D] consequences: (i) the S0 kernel name exists **only** as CODE-embedded DScript-API registration strings (as in blend/tick) — a data-section string search would report 0 and be wrong (P5 explains the trap). (ii) `bsmooth` is a **script-struct field name only** (`TGeneratorBitmapMask.bsmooth`, `generatemap.inc:473-480`); its total absence from the exe is expected, not a gap — the native side never names the mask flag. (iii) `GetHeightByte` / `SmoothHeight` / `GeneratemapSmooth` have **zero** byte standing anywhere in the exe or the script tree; they are not alternative entry points — do not cite, wire, or probe them further.

### 1.2 Wrapper signatures and argument order (task (b)) — exact table strings [O]

Contiguous registration run `0x6a3390–0x6a3e6e` (ev_9a2de271…/ev_525f3565…/ev_791631bd…/ev_30579079…/ev_1bebd7a4…/ev_ec4c4c54…), verbatim:

```
procedure MapGeneratorSmoothTerrain(const x, y, passes: Integer; const radius: Float)
procedure RaiseTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const delta: Float)
procedure LowerTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const delta: Float)
procedure PlateauTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const reproduce: Boolean)
procedure SmoothTerrain(const x, y: Integer; const round: Boolean; const mb: Integer)
procedure RandomHeightTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const delta: Float)
procedure PaintTerrain(const x, y: Float; const tilebrush, cliffbrush, waterbrush: Integer; const ramp: Boolean; const cliffapply, level, size: Integer; const round, reproduce: Boolean)
function GetHeightData(const x, y: Integer): Float
procedure SetHeightData(const x, y: Integer; const cheightvalue: Float)
procedure TerrainUpdate(const terrainupdate, horizontexture: Boolean)
procedure MapGeneratorSmoothTiles()
```

[D] argument-order correction (byte-proven, supersedes the "radius/param 3" shorthand used in all prior reports including this worker's title line):

- The S0 script call `SmoothTerrain(realx, -realy, False, 3)` (generatemap.inc:591, ev_8553f817…) binds positionally to `(x, y, round, mb)`: `False → round: Boolean`, **`3 → mb: Integer`**.
- `mb` is the shared 4th-parameter name across `Raise/Lower/Plateau/Smooth/RandomHeightTerrain`; it is an Integer, never a Float radius. The **only** smooth entry carrying a Float radius is the *unused-by-S0* `MapGeneratorSmoothTerrain(x, y, passes; radius: Float)`.
- Therefore **no kernel radius or sample count is recoverable from the native call structure**: the literal `3` is an opaque integer `mb` whose semantics (brush? mask-bit? mode?) have zero further byte standing — no enum, comment, or second call site names it. Prior "radius 3 / 3 passes / 3×3 neighbourhood" readings of the `3` are **refuted as names** (the S1/S2 `times=1` + `for i:=0 to 2` pass counts are separate script literals and remain [O]; they do not transfer to S0).
- `function_find` misses at both `SmoothTerrain` table VAs and `MapGeneratorSmoothTerrain` (ev_1ec21295…/ev_cb7d2f7f…), and xrefs on `0x6a395a` return 0 under the computed-pointer limit (ev_3021557c…). So the table gives **signatures only — no body, no weights, no neighbour topology, no loop bound, no stride**. Any blur/average/box tentatively attached to `3` would be invention.

Related [O] (no kernel content, recorded so future hunts do not re-walk them): the `GetHeight` hits at `0x541996…` decode as `THeightFieldGetHeightEvent / THeightFieldGetHeight2Event / THeightFieldOption(s) / THeightFieldColorMode` RTTI (ev_ff836253…); the `0x75c7xx` `HeightField` run is engine field plumbing. Neither names a smoothing weight.

### 1.3 Port-side hook today [O]

`variant3d/scripts/terrain_donor_gen.gd:475` declares `var bsmooth_kernel: Callable = Callable()` (NULL); `:1448-1455` keeps `bsmooth_pass="SKIPPED — native kernel [U] (D03 U3); TODO(D03/D01)"` with hook shape `hook(height_arr, w, h, bsmooth_arr, 3)` documented at `:471-473`. `terrain_update_hook` stays NULL (`:528`, `:1474-1478`). No blur substituted — matches the termination rule in §5.

---

## 2. Donor `data/scripts/**/*.inc` commented-kernel sweep (task (c)) — text-only, not executable

[O] `SmoothTerrain` occurs in exactly two live script lines tree-wide: the flag `const cSmoothTerrainUsingBitmap = True` (`generatemap.inc:38`) and the S0 call `SmoothTerrain(realx, -realy, False, 3)` (`generatemap.inc:591`, ev_8553f817…), plus profiler bookends `:582/:595`. There is **no** `procedure SmoothTerrain` / `function SmoothTerrain` declaration anywhere (exhaustive `procedure Smooth|function Smooth` grep: sole hit is `procedure SmoothTileMap(mini,minj,maxi,maxj,passes: Integer)` at `smoothtiles.inc:191` — the tile smoother, not a height kernel). `GetHeightByte` / `SmoothHeight` / `GeneratemapSmooth` return 0 hits tree-wide.

[O] The `//`-comment sweep (`mooth|power|lerp|weight|average|kernel|blur|gauss|radius|neighbour|neighbor`) returns exactly **one** smoothing-candidate commented line:

```
generatemap.inc:607: //_misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, -100, 0.01);
```

— the disabled negative-land-range variant of the *already-known* `_misc_SmoothTerrainCustom` (power/lerp shape, not a new kernel). All other `//` hits are non-candidates: height-range notes `:571-572` (`//*(255/cRColorHill|Ravine)` — relief amplitude scaling, not smoothing), map-size arithmetic `:689`, `//MapGeneratorSmoothTiles` `:784` (tile stage toggle), bitmap `PostProcessSaver` gauss `BitmapGaussBlur(bitmaptrg,width,height,0.00001/0.925,…)` in `postprocess.inc:437/441` (offline mask-file blur producing shipped `_gauss` TGAs — live lines, not S0, no per-cell weights beyond the `rs=Round(r*2.57+0.5)` formula already in D03/DEC_LANDSCAPE), water/bridge/radius gameplay comments elsewhere.

[D] **No commented-out alternative kernel with explicit weights exists** in the readable script tree. The `:607` line adds no weight, no radius, no neighbour list beyond the S1 line it mirrors (`:606` live `custom(1,4,0.5,0.01,100)`). Do not promote it to a kernel.

---

## 3. Write scope: bsmooth-only call loop vs whole-grid kernel (task (d))

[O] Call loop (generatemap.inc:580-595, ev_8553f817…):

```
if (cSmoothTerrainUsingBitmap) then
  for y:=0 to mapheight-1 do for x:=0 to mapwidth-1 do
    if (gMapMask[x,y].bsmooth) then begin
      realx := floor(lx+x); realy := floor(ty+y);
      SmoothTerrain(realx, -realy, False, 3);
    end;
```

[O] The S1 land pass (`:598-608` `custom(1,4,0.5,0.01,100)` over `x,y ∈ [0,mapwidth]`) is whole-map and the S2 coastal passes (`:611-640` `custom(1,0.35,0.5,-100,-0.01)` ×3 with clamped 5×5 water-neighbourhood gate `const rad=2`, `break(MAIN)`) are neighbourhood-gated — both are `_misc_SmoothTerrainCustom` with exact bodies at `:218-245`, distinct from S0.

[D] What this proves and what it does not: the **call scope** of the native S0 entry is bsmooth-gated (one call per flagged mask cell, with negated Y `−realy` preserved) — [D] over the loop text. The **write footprint** of the native kernel itself (whether one call rewrites only `(realx,realy)`, a neighbourhood around it, or the whole height grid) has **zero** byte standing: no body, no Get/SetHeightData xref chain into the kernel, no stride/loop literal in the table window. So "the kernel modifies only bsmooth cells" is [U] as a kernel property even though "the script calls it only for bsmooth cells" is [O]. A whole-grid S0 effect (each call re-blurring shared neighbours) is neither confirmed nor excluded from static bytes.

[I→U] The negated-Y convention (`-realy` at both S0 and the editor-bitmap twin per F09) is consistent with a bottom-left vs top-left height origin, but without the kernel body no axis claim is made.

---

## 4. Still-[U] register — exact byte-dump termination, no invented blur

| ID | Statement | Termination (zero-mismatch, else stays [U]) |
|---|---|---|
| U-S0-KERNEL | Native `SmoothTerrain(x,y;round;mb)` body: neighbour topology, weights, loop bounds, `mb=3` semantics, `round=False` effect, `-y` handling | **Byte-proven kernel dump**: disassembly/pseudocode of the engine function reached through the `0x6a395a/0x6a3b12` registration (computed-pointer-respecting trace, not a string-xref), reproducing the port hook `hook(height: PackedFloat32Array, w: int, h: int, bsmooth: PackedByteArray, mb: int=3)` in place. **Comparison**: donor-behavioural, not byte-identical-exe: on fixed seeds, hooked-port height grid equals the dumped kernel's output cell-for-cell with **0 differing cells on 320² AND 640² maps** (both sizes; shipped-mask + synthetic-bsmooth-checker fixtures). One differing cell fails it. Until then `bsmooth_kernel=NULL`, `bsmooth_pass=SKIPPED` on all fixed seeds. |
| U-S0-SCOPE | Per-call write footprint (single cell vs neighbourhood vs whole grid) | Same dump as above must show the written address range per call (target-only vs neighbour writes). No separate capture; falls out of the dump. Until then no scope claim. |
| U-MB3 | Meaning of `mb=3` (brush/mode/mask-bit?) shared with Raise/Lower/Plateau/RandomHeightTerrain | Named only by a second static anchor (second call site with a different `mb` literal, or an enum/comment byte naming `mb`) — never by guessing from the value 3. |
| U-GETHEIGHTBYTE / U-SMOOTHHEIGHT / U-GENERATEMAPSMOOTH | Hypothetical alternative entries | **CLOSED-NEGATIVE by absence sweep**: 0 exe hits + 0 script-tree hits this pass (P3/P4/P11). No probe prescribed; do not re-search without a new spelling. |
| U-COMMENT-KERNEL | Commented-out explicit-weight kernel | **CLOSED-NEGATIVE**: exhaustive `//` sweep this pass finds only `:607` (same power/lerp shape, no weights). No further text hunt prescribed. |

**Denied:** any box/gaussian/lerp blur, any "radius 3 = 3×3/7×7 window", any `mb=brush-size` gloss, any "modifies only bsmooth cells" kernel claim, any parity/similarity claim. The port keeps `bsmooth_kernel` NULL with `SKIPPED` telemetry.

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `SmoothTerrain` = 2 CODE hits `0x6a395a` + `0x6a3b12`; `MapGeneratorSmoothTerrain` = 1 CODE hit `0x6a394e`; file offsets `0x2a2d5a/0x2a2f12/0x2a2d4e` | [O] ev_7f7b87d0…/ev_f5476876… (§1.1) |
| 2 | `bsmooth/bSmooth/BSmooth/SMOOTH/GetHeightByte/SmoothHeight/GeneratemapSmooth/smoothterrain/SMOOTHTERRAIN` = 0 hits each; `Smooth` substring = 107 CODE-embedded (CODE-table discipline as in blend/tick) | [O] ev_d1709b56…/ev_7a048a0e…/ev_2d676612…/ev_4c6a881c…/ev_be1ff326…/ev_469429f0…/ev_2423d320…/ev_45ec9d61…/ev_cff0c4321…/ev_00b781e1… (§1.1) |
| 3 | Wrapper table `0x6a3390–0x6a3e6e`: `MapGeneratorSmoothTerrain(x,y,passes:Integer;radius:Float)` vs `SmoothTerrain(x,y:Integer;round:Boolean;mb:Integer)`; shared `mb` across Raise/Lower/Plateau/RandomHeightTerrain; `GetHeightData/SetHeightData/TerrainUpdate/MapGeneratorSmoothTiles()` verbatim | [O] ev_9a2de271…/ev_525f3565…/ev_791631bd…/ev_30579079…/ev_ec4c4c54… (§1.2) |
| 4 | Script 4th argument `3` binds to `mb: Integer`, NOT a Float radius; no radius/sample count recoverable from call structure; "radius 3" reading refuted as a name | [D] over #3 + ev_8553f817… (§1.2) |
| 5 | No kernel body localized: `function_find` misses at both table VAs; 0 xrefs under stated computed-pointer limit; `0x541960` neighbourhood is HeightField event RTTI, not kernel weights | [O-absence with packed/computed-pointer reserve] ev_1ec21295…/ev_cb7d2f7f…/ev_3021557c…/ev_ff836253… (§1.2) |
| 6 | Script tree: `SmoothTerrain` in exactly 2 live lines (`:38` flag, `:591` call); no `procedure SmoothTerrain` declaration (only `SmoothTileMap` at `smoothtiles.inc:191`); alternative names 0 hits | [O] P11 + ev_8553f817… (§2) |
| 7 | Sole commented smoothing candidate is `:607` disabled negative-range `custom(1,4,0.5,-100,0.01)` — same shape, no explicit weights; no commented-out alternative kernel exists | [O] P11 (§2) |
| 8 | S0 call loop is bsmooth-gated with negated Y [O]; S1 whole-map + S2 5×5-gated `custom` stages are distinct [O]; kernel write footprint itself is [U] | [O]/[D]/[U] ev_8553f817… (§3) |
| 9 | Port `bsmooth_kernel=NULL/SKIP` + `bsmooth_pass=SKIPPED` + hook shape `hook(height,w,h,bsmooth,3)` still parked; every [U] carries the §4 320²+640² zero-mismatch dump termination | [O] port reads + [D] §4 |
| 10 | No parity, no approximation, no invented blur/kernel; kernel + scope + mb-semantics stay [U] | [D] scope guard + §4 |

---

## 6. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) and the read-only `C:\Games\Cossacks 3\data` script tree (text reads only, nothing run). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-SMOOTH-KERNEL-DEEP.*
