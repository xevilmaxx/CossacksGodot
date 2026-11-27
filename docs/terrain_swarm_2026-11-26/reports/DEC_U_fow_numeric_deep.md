# DEC-U-FOW-NUMERIC-DEEP — FOW numerics: script defaults, packed constants, XFOWRender ctors, 20+4V vs tile-size relation (2026-11-26)

- id: DEC-U-FOW-NUMERIC-DEEP
- worker: DEC-U-FOW-NUM (subagent, full 1:1 Cossacks 3 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied/patched. Donor read as bytes/text only. No code/asset/config/Godot/git edits. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` (re-verified this worker via `Get-Item` length + `certutil` SHA256, §1 P1)
- upstream: `DEC_U_fow_grid_deep.md` (§§2–5, 24-name block `0x2a74b2–0x2a79d3`, RTTI `0x361191–0x36141a`, five `[U]` fields) · `DEC_U_fow_knobs.md` (K1–K9 signatures, shipped-active vs engine-default verdict) · `DEC_U_vision_audit.md` (vision law + dead rows) · `DEC_U_fow_persist.md` (reset/merge lifecycle) · port file `variant3d/scripts/world3d_fog.gd` (551 lines, provisional metre driver — not edited)
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling experiment given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor binary executed. No donor GPU A/B frame. No port capture compared. No cell size or slope invented.
- network: OUT OF SCOPE.

## 0. Result in one paragraph

Prior FOW reports closed vision law (`floor(20+4·vision)`), tag-109 reveal plumbing, team-gated `SetFOWEnable`, and `>0` picking/tint vetoes as `[O]`, and inventoried the engine-only knob surface (`FOWElevation`/`FOWLerpFactor`/`FOWTextured`/`FOWDefDov`/`FOWFillMaxNum`/`FOWDateTime`/`FOWSmooth`/`FOWColor`, `TLOSInfo`/`TLOSData`/`TFOWLerpInfo`/`TFOWLerpData`/`TOSWFOWRender`/`XFOWRender`/`FOWRenderT`), leaving FOW cell size, combine operator, LOS occlusion/sampling, explored persistence, and all native RTTI field layouts `[U]`. This report tries four NEW static angles pinned to `t_87f0f3c130b0`: (a) every `FOW*` numeric assignment in `player.script`, `camera.cfg`, `gui.script`, `dmscript.global` including commented/dead rows (§2); (b) packed constants within ±1 KiB of `FOWEnable @0x1d9daa/VA 0x5da9aa`, `GetFOWLOSData @0x2a7812/VA 0x6a8412`, `FOWBuildFull @0x2a7906/VA 0x6a8506` with immediates and float literals classified against capstone-5.0.7 disassembly (§3); (c) constructor/default-allocator patterns for `XFOWRender`/`FOWRenderT` (§4); (d) the `20+4V` → tile-size (`53.333…`) / 2.5 m / 5 m relation, only if byte-proven (§5). Result: (a) finds zero `FOW*` numeric writes — only Boolean gates, one string callback, radii, and a 0.5/1.0 tint; (b) finds the three anchors sit in length-prefixed string-table DATA with no immediates by construction, the one adjacent CODE run carries no FOW float, and the only float within ±1 KiB of any FOW anchor is `1.0f (0x3F800000)` as a boolean-to-float move immediate, not a grid step; (c) finds one boolean-to-float helper and one SEH-guarded factory referencing `[ebx+0x48/0x14/0x4c]` with `push 2 / mov ecx,1` — no grid divisor or step; (d) finds zero `53.333…` float32+float64 hits image-wide and kilometre-scale distances for every 2.5/5.0/20.0/4.0 hit, so no byte-proven relation exists. Every still-`[U]` field keeps one exact `GetFOWLOSData` transect/GL dump with a zero-mismatch termination criterion (§6); no port file is touched (§7).

## 1. Pass ledger (all passes NEW this worker; binary pin `t_87f0f3c130b0`; donor text read-only)

| # | Pass | Result |
|---|---|---|
| P1 | Binary pin re-verified (size + SHA256, no execution) | `Get-Item` → 5,768,048 B; `certutil` → `87f0f3…4e16c`. Matches pin. `[O]` |
| P2 | Script-default sweep (a): `player.script:451-478`, `camera.cfg:1-65`, `gui.script:3478-3496`, `dmscript.global` full `FOW` grep + `:170-209/:965/:1439/:2120` re-reads, `unit.script:11563-11614`, `scenario.script:1851-1864`, `misc.script:5881-5944`, `control.script:270`, `cossacks.ini`/`editor.ini` FOW grep | **Negative for numerics, positive for gates** — verbatim in §2. Zero `FOW* := <number>` / `= <number>` rows; dead `//cBaseVal 18 / 3.6 / 3.75` rows recorded text-only. `[O]` |
| P3 | Packed-constant windows (b): `repr()` ±128 B + hex ±64 B at `0x1d9daa`, `0x2a7812`, `0x2a7906`, `0x1d9c16`, `0x361419`, `0x549f0d` | Anchors re-observed byte-for-byte; §2.1-block order and feature-table order confirmed. `[O]` |
| P4 | Capstone-5.0.7 disassembly (b/c): CODE run at `0x1d9de0` +128 B, string-table at `0x2a79d3` (control), `0x361424` factory +0x200 B, helper at `0x3613e4` +64 B | String-table decodes as DATA (meaningless as code = correct classification); feature-table tail decodes as SEH/table-dispatch CODE with no FOW float; helper/ctor decoded in §4. `[O]`/`[D]` |
| P5 | Float-literal scan (b/d): `<f`/`<d` encodings of 2.5, 5.0, 53.3333333, 53.333, 20.0, 4.0, 1.0, 0.5, 0.25, 0.025, 2.0, 0.85, 1280.0, 214.0, 426.0, 160.0 image-wide + ±1024 B window scan at five anchors | `53.333…` f32+f64 = **0 hits image-wide**; `0.85/214.0/426.0` = 0 hits; every other hit ≥20 KiB from nearest FOW anchor except one `1.0f` at `0x3613f5` (classified §4, not a grid step). `[O]` |
| P6 | VA/RVA xref scan (c): correct VA = file-off + `0x400C00` (CODE; §4 PE parse) / + `0xEE00` (`.rsrc`); 12 record/string VAs + RVA (no-base) forms searched image-wide | **Zero flat-pointer xrefs** for all 12 VAs and all RVA forms — linkage is packed/relative, not flat pointers. `[O]` negative |
| P7 | PE section parse (c groundwork): `e_lfanew`, 10 section headers decoded | `CODE raw 0x400 VA 0x1000`, `DATA`, `BSS`, `.idata`, `.edata`, `.tls`, `.rdata`, `.reloc`, `.rsrc raw 0x53d200 VA 0x54c000`, `.bind`. VA formulae proven by reproducing the three prior VAs (`0x5da9aa`, `0x6a8412`, `0x6a8506`). `[O]` |
| P8 | Feature-table structural decode (c): `0x1d9b80–0x1d9e40` entry-boundary walk + `FOW`-anchored context dump (38 hits in scope) | `FOWRenderT`/`FOWEnable` entries match sibling `…Renderer`/`…Enable` shape (flag bytes, no numeric default). `[O]`/`[D]` |
| P9 | Tile-size/script-divisor census (d): `dmscript.global:170-209` re-read + `53.333` binary + `1280/160/214/426` binary | `53.3333333` is text-only (`:172`); its only script consumers are search/capture radii (`:205/:207-209`); its binary float is absent (§5). `[O]` |
| P10 | Port anchor re-read (no edit): `world3d_fog.gd` provisional driver / combine / persistence / sampler sites | Confirmed unchanged from parents; change list stays conditional (§7). Read-only. |

## 2. Angle (a) — script-level defaults/constants (verbatim; dead rows text-only)

**A1. `player.script:451-478` — the only FOW writer block. Zero numeric `FOW*` assignments.** `[O]`

```pascal
// _player_UpdateFOW
procedure _player_UpdateFOW(plInd : Integer);
begin
   var bFOW : Boolean = True;                                          // :455 — Boolean init, not a grid constant
   if (gPlayer[plInd].bballoon) or (gMap.settings.additional.balloon=gc_mapsettings_balloon_with) or (gPlayer[plInd].victorystate<>gc_player_victorystate_none) then
   bFOW := False;                                                      // :457
   if (not gbool_editor_fogofwar) then                                // :458, flag at dmscript.global:2120
   bFOW := False;                                                      // :459
   ClearFOWPlayers;                                                    // :460 — unconditional viewer-set reset
   if (bFOW) then
   begin
      AddFOWPlayers(GetPlayerHandleByIndex(plInd));                     // :463
      var team : Integer = gPlayer[plInd].team;                        // :464 — team int, not FOW geometry
      var i : Integer;
      for i:=0 to gc_MaxPlayerCount-1 do                               // :466 — loop bound, not FOW geometry
      begin
         if (i<>plInd) and (gPlayer[i].team=team) then
         begin
            //if ((not gScenario.bactive) or (plInd<>0)) or ((plInd=0) and (not gPlayer[i].bneutral)) then  // :470 DEAD comment, text-only
            if (plInd<>0) or (not gPlayer[i].bneutral) then            // :471
            AddFOWPlayers(GetPlayerHandleByIndex(i));                   // :472
         end;
      end;
      SetFOWDovFunc('_unit_GetVision');                                // :475 — the ONLY knob write in shipped scripts; string, not numeric
   end;
   SetFOWEnable(bFOW);                                                 // :477 — Boolean gate, not numeric
end;
```

**A2. `dmscript.global` — zero `FOW` hits; `fogreveal`/tile-size rows verbatim.** `[O]` Full-file `FOW` grep returns **no lines** (empty result before `---camera---` in P2). The only FOW-adjacent globals are the tag/basename pair plus the tile-size family:

- `:965` `gc_basename_fogreveal = 'fogreveal';` (string, not numeric)
- `:1439` `gc_properties_stringtag_fogreveal = 109;` (tag int — object identity, never cited as grid size)
- `:2120` `gbool_editor_fogofwar = Boolean` (flag declaration, no default literal on the line)
- `:170` `gc_pixels_to_meter = 26.6666666;` · `:171` `gc_meters_to_tile = 2;` · `:172` `gc_pixels_to_tile = 53.3333333;` · `:173` `gc_tiles_to_pixels = 0.01875;` — the tile-size family. Consumers: `:205` `gc_gameplay_officersearchradius = 1280/gc_pixels_to_tile;` · `:207` `…captureblockshotradius = 160/gc_pixels_to_tile;` · `:208` `…captureradius = 214/gc_pixels_to_tile;` · `:209` `…protectionradius = 426/gc_pixels_to_tile;`. **No `FOW*` name appears on any of these lines or anywhere else in the file.** The `53.333…` literal is therefore a render/search divisor, never a FOW grid claim. `[D]`

**A3. `camera.cfg:1-65` — zero `FOW`; `DynFog*` is visual depth fog, not gameplay FOW.** `[O]` `FOW` grep: no hits. `Fog` grep: exactly five lines, all visual: `:59 DynFogDepth = False` · `:60 DynFogStart = 0.25` · `:61 DynFogEnd = 0.025` · `:62 DynFogDensity = 2.0` · `:63 DynFogPower = 0.85` · `:64 DynFogOffset = 0`. Gameplay pose constants (`:6/:9 SphereHeight/SphereLength=58`, `:44/45 Min/MaxFocalLength=400`) fix the experiment camera (§6), never the FOW grid.

**A4. `gui.script:3478-3491` — veto + tint only; the only numerics are `0.5`/`1`.** `[O]`

```pascal
var bGeology : Boolean = (gPlayer[myPlInd].bgeology);                                                                 // :3478
var bNotInFOW : Boolean = (not GetFOWEnable) or (GetFOWLOSData(GetGameObjectPositionXByHandle(goHnd), GetGameObjectPositionZByHandle(goHnd))>0); // :3479 — >0 veto, grounded
…
if (bVisible) and (not bNotInFOW) then newUserBlend := 0.5 else newUserBlend := 1;  // :3488-3491 — resource tint, excluded from grid law
```

No `SetFOW*`/`FOW* :=` numeric row exists in `gui.script` (full-file `FOW` grep = `:3479/:3480/:3488` only).

**A5. `unit.script:11565-11598` — vision law + dead rows recorded text-only.** `[O]`

```pascal
//const cBaseVal = 18;    // :11567 DEAD comment
//const cModVal = 3.6;    // :11568 DEAD comment
//const cModVal = 3.75;   // :11569 DEAD comment
const cBaseVal = 20;      // :11570 live
const cModVal = 4;        // :11571 live
…
res:=floor(TProj(pproj).dx)                                  // :11578 fogreveal arm (float dx → Integer res)
res:=floor(cBaseVal+cModVal*gObjProp[…].vision)              // :11598 normal arm → 20/24/28/32/36/40/44/48/52
res:=0  // ×5 dead/unbuilt/invisible/nil arms (:11580/:11584/:11600/:11604/:11608/:11612)
```

Units of `res` remain engine-defined — exactly F1-GRID-a, still `[U]`.

**A6. `scenario.script:1851-1863`, `misc.script:5881-5944`, `control.script:270`, inis.** `[O]` `map_revealZone` passes `radius : Float` through (`:1854`) into `TProj.dx` (`misc.script:5937`) with no numeric default; `FOWBuildFull` is a bare trigger (`:1862`); fogreveal lookup radius is `gc_epsilon` (`misc.script:5886/5905`, value not FOW-geometry); `control.script:270` repeats the `:3479` `>0` veto verbatim; `cossacks.ini` + `editor.ini` carry **zero** `FOW` keys (P2 empty results).

`[D]` verdict for angle (a): shipped scripts contain **no** `FOW*` numeric default. Every `FOW*` call site is a Boolean gate, a handle-set merge, a string callback install, a bare recompute trigger, or a `>0` read. All knob defaults (`FOWElevation`, `FOWLerpFactor`, `FOWTextured`, `FOWDefDov`, `FOWFillMaxNum`, `FOWDateTime`, `FOWSmooth`, `FOWColor`) are engine-internal and readable at runtime only through their paired `Get*` entry points — never invented here.

## 3. Angle (b) — packed constants near the three pinned anchors

VA groundwork (P7, `[O]`): `CODE raw 0x400 ↔ VA 0x1000`, so `VA = file-off + 0x400C00` (reproduces `0x1d9daa→0x5da9aa`, `0x2a74b5→0x6a80b5`, `0x2a7812→0x6a8412`, `0x2a7906→0x6a8506`). `.rsrc raw 0x53d200 ↔ VA 0x54c000`, so `VA = file-off + 0xEE00`.

**B1. `FOWEnable @0x1d9daa / VA 0x5da9aa` — feature-table DATA; adjacent CODE has no FOW float.** `[O]` ±64 B hex: prefix `…36 00 0A 46584141456E61626C65…` (`FXAAEnable` entry) and suffix `46 4F 57 45 6E 61 62 6C 65 C8 46 76 00 5C 01 00 FF…` (`FOWEnable` + 4-B payload + flags) then `38 00 0D 47726170684465627567676572` (`GraphDebugger`). The entry shape (`80 37 00 09 <name> <u32 LE> <u16?> … 00 00 00 00 01 … 80 …`) matches every sibling renderer/enable entry (§1 P8) — a registration record, carrying **no float literal and no grid integer** in its window. The bytes immediately after the table (`0x1d9de0`, VA `0x5d9de0`) are CODE (capstone P4): `mov ebx,eax / mov eax,esi / xor edx,edx / mov dl,bl / mov ecx,[0x8fbe30] / mov edx,[ecx+edx*4] / call 0x404854 / pop esi / pop ebx / ret` then an SEH frame (`push ebp / mov ebp,esp / push 0x5daa46 / mov fs:[eax],esp / push 0 / mov eax,[0x8fbe30] / mov edx,1 / call 0x894758 …`). Immediates observed: table pointers, `1`, `0`, SEH cookies `0x5daa46/0x5daa4d`. **No `20.0/4.0/2.5/5.0/53.333…` float and no `20/24/32/52` grid immediate.** Classification: generic feature-dispatch epilogue, not FOW arithmetic. `[D]`

**B2. `GetFOWLOSData @0x2a7812 / VA 0x6a8412` — string-table DATA; disassembly as code is correctly meaningless.** `[O]` ±64 B is pure Pascal-string table: `…2D 00 00 00 ' function GetFOWLOSData(x, z: Float): Integer' 00 00 00 FF FF FF FF 28 00 00 00 'procedure SetFOWFillMaxNum(val: Integer)'…` (length-prefix `0x2D`, `00`-padded, `FFFFFFFF` separators — same framing as all 24 entries in §1 P8). There are **no immediate operands and no float literals** in this window by construction: it is a binding registry, not emitted code. The same holds for the full `0x2a74b2–0x2a79d3` block (P3 re-dump; control disassembly at `0x2a79d3` yields `cmp esp,[eax] / popal / … / outsd / insb` garbage, confirming DATA mis-decoded as code). No dims/stride/operator/threshold literal is co-located with any of the 24 entries. `[D]`

**B3. `FOWBuildFull @0x2a7906 / VA 0x6a8506` — same string-table DATA verdict.** `[O]` Window: `…FF FF 26 00 00 00 'procedure SetFOWDateTime(val: Boolean)' 00 00 FF FF FF FF 16 00 00 00 'procedure FOWBuildFull' 00 00 FF FF FF FF 70 00 00 00 'procedure GetFOWSmooth(…'`. Length-prefixes `0x26/0x16/0x70`, same separators. No immediates, no floats. The recompute body lives elsewhere engine-side and is not statically adjacent to its name string.

**B4. Window float census (±1024 B, P5).** `[O]` Within ±1024 B of `0x1d9daa`, `0x2a7812`, `0x2a7906`, `0x1d9c16`: **zero** hits for every scanned value (2.5, 5.0, 53.3333333, 20.0, 4.0, 0.5, 1.0, 0.25, 0.025, 2.0, 0.85, 1280.0, 214.0, 426.0, 160.0). The single exception image-wide-near-FOW is at `0x3613f5` (±1024 B of `XFOWRender @0x361419`): bytes `C7 04 24 00 00 80 3F` = `mov dword ptr [esp],0x3F800000` (`1.0f`), classified in §4 as the false-arm of a boolean-to-float helper — **a flag constant, never a grid divisor or step**. Image-wide, `53.3333333` (f32 `55 55 55 42`, f64 `79 15 63 AA AA AA 4A 40`) and `53.333` (both widths) have **0 hits**; `0.85/214.0/426.0` have 0 hits; the closest `20.0` hit (`0x1d4d99`) is 20,093 B from the nearest FOW anchor; the closest `5.0` hit (`0x1a46b5`) is 218,465 B away; both `2.5` hits are >1.6 MB away. Distances are byte-measured (`abs(hit-anchor)` minima over the five anchors), not estimates.

## 4. Angle (c) — `XFOWRender` / `FOWRenderT` constructor/allocator patterns

**C1. `FOWRenderT @0x1d9c16 / VA 0x5da816` — feature-table slot, not a constructor.** `[O]` Context `…80 2B 00 18 'AnimatedSpriteFXRenderer' … 80 2C 00 09 'FOWRenderT' 17 77 00 1C 01 00 FF … 80 2D 00 07 'MiniMap' A0 12 5D 00 …` (P8). Same record shape as every sibling: index bytes (`2C 00`), length-prefixed name, small LE payload, `FF`-framing, flag bytes. No divisor, stride, dims, or float default is stored in the record. No flat VA/RVA pointer to it exists image-wide (P6 zero). There is no constructor body adjacent to a feature-table slot by engine design — the slot is referenced by index/table dispatch (cf. the `mov edx,[ecx+edx*4] / call` shape at §3 B1). No grid divisor recoverable here. `[D]`

**C2. `XFOWRender` first record `@0x3613d6` — name + boolean-to-float helper, not an allocator.** `[O]` Bytes `…02 00 0A 'XFOWRender' 00 00 8B C0 51 83 78 18 00 7E 07 33 C0 89 04 24 EB 07 C7 04 24 00 00 80 3F D9 04 24 5A C3…`. Capstone from `0x3613e4` (P4): `push ecx / cmp dword ptr [eax+0x18],0 / jle +7 / xor eax,eax / mov [esp],eax / jmp / mov dword ptr [esp],0x3F800000 / fld dword ptr [esp] / pop edx / ret`. Classification: a `float Getter(this)` returning `0.0f` vs `1.0f` from flag byte `[eax+0x18]` — the `1.0f` of §3 B4. No `edx` divisor, no multiply/divide, no grid-width immediate. `[D]`

**C3. `XFOWRender` second record `@0x361419 / VA 0x762019` — SEH-guarded factory, immediates are small ints and field offsets.** `[O]` Bytes `…00 00 00 00 0A 'XFOWRender' 90 55 8B EC 83 C4 F8 53 56 33 C9 89 4D F8 8B F2 8B D8 33 C0 55 68 B2 20 76 00 …`. Capstone from `0x361424` (= `55 8B EC…`, P4): `push ebp / mov ebp,esp / add esp,-8 / push ebx / push esi / xor ecx,ecx / mov [ebp-8],ecx / mov esi,edx / mov ebx,eax / … push 0x7620B2 / mov fs:[eax],esp / mov eax,[ebx+0x48] / test eax,eax / je … / cmp [eax+0x14],0 / je … / push 2 / lea eax,[ebp-8] / mov ecx,1 / mov edx,[0x762000] / call 0x406150 / … call 0x405F7C / mov ecx,eax / mov eax,[ebx+0x48] / mov eax,[eax+0x14] / call 0x704DF0 … / else mov eax,[ebx+0x4C] …`. Immediates enumerated completely: `2`, `1`, field offsets `0x48/0x14/0x4C/0x04`, SEH cookies `0x7620B2/0x7620B9`, table word `[0x762000]`. **No float literal, no divide/shift by a grid width, no `20/24/32/52/53.333/2.5/5` constant, no stride multiply.** The following function (`0x3614C2…`) is `mov esi,edx / mov ebx,eax / mov edi,[ebx+0x48] / … call 0x404854 / call 0x404800` — a release/forward pair with the same field. Classification: engine object factory/teardown around a `[ebx+0x48]`-rooted aggregate, not a grid allocator with a recoverable divisor. `[D]`

**C4. `TLOSInfo @0x361191` / `TLOSData @0x3611e9` / `TFOWLerpInfo @0x361241` / `TFOWLerpData @0x36129d` / `TOSWFOWRender @0x3613a9/@0x3613be` / multiplier table `@0x549f0d` — names re-observed, layouts absent.** `[O]` `0x361150–0x361320` shows the `54 11 40 00 D0 47 40 00 … 08 'TLOSInfo'` / `…08 'TLOSData'` prop-list framing with game-class pointer prefixes; `0x549F00`-window shows the `XMiniMap / XFOWRender / XDMScript / XRace / …` multiplier table (`10 A8 'XFOWRender'`). P6: zero flat VA/RVA xrefs to any of these eight record VAs, so no constructor call site is statically linkable by pointer scan. Field counts, offsets, and cell geometry are not resident strings and stay `[U]`. No layout is drawn here. `[D]`

## 5. Angle (d) — `20+4V` vs 53.333 px/tile vs 2.5/5 m candidates (byte-proven only)

- `[O]` Script identities: `gc_pixels_to_meter = 26.6666666` (`:170`), `gc_meters_to_tile = 2` (`:171`), `gc_pixels_to_tile = 53.3333333` (`:172`, = 26.6666666 × 2 `[D]`), `gc_tiles_to_pixels = 0.01875` (`:173`, = 1/53.333… `[D]`). The ONLY script divisions by `gc_pixels_to_tile` are `1280` (`:205` officer search), `160` (`:207` block-shot), `214` (`:208` capture), `426` (`:209` protection). **No FOW radius (`res`, `dx`, `radius`, `vision`) is ever divided by `gc_pixels_to_tile`, `gc_pixels_to_meter`, or `gc_meters_to_tile` in any readable line** (P2/P9 full-corpus `FOW` + `vision` + `pixels_to_tile` census).
- `[O]` Binary: `53.3333333`/`53.333` occur **0× as f32 and 0× as f64** image-wide (P5); `1280.0` occurs 1× at `0x531ACF` (≈1.9 MB from FOW anchors); `160.0` 1× at `0x4ED31A` (≈1.6 MB away); `214.0`/`426.0`/`0.85` 0×. `2.5` occurs 2× (`0x4F5714`, `0x52F27B`, both >1.6 MB away); `5.0` 14× (nearest 218,465 B away); `20.0` 10× (nearest 20,093 B away — still 20 KiB outside every ±1 KiB FOW window). A byte-proven `k` (world-units per `res`) or cell width would require a float/int literal **inside** a FOW window or a `res × k` multiply at a linked call site; neither exists statically.
- `[D]` Consequence: the relation of `res = floor(20+4V)` / `floor(dx)` to metres, map tiles, or any 2.5/5 m grid is **unproven by static means**. The numbers 2.5/5 are not donor FOW constants in evidence — they are audit hypotheses with zero byte support and are **not adopted** here. The only portable reading remains the script integers themselves (e.g. vision 1 → `res` 24) with the unit explicitly `[U]` until E-GRID-a terminates.

## 6. Still-`[U]` fields (no value invented; each with its exact settling dump)

General harness (all arms, owner-authorised donor session only — this worker runs none of it): skirmish map, FOW on, gameplay camera pinned (`camera.cfg:6-10,32-35,44-45` → `SphereHeight/SphereLength=58`, pitch `-32°`, focal 400 fixed), fixed camera target, fixed map seed. Readout is script `GetFOWLOSData(x,z)` dumps only (never pixels — `FOWSmooth`/PCF would move a pixel edge without moving the script grid). Transect step 1.0 world unit unless stated; every run ends with `FOWBuildFull` + one settled tick before dumping. Termination everywhere: **zero mismatching cells** across all listed repeats — otherwise the field stays `[U]`. During all arms, never change `FOWElevation`/`FOWLerpFactor`/`FOWFillMaxNum`/`FOWSmooth` from defaults; log their `Get*` readings with every run (E-KNOB arm).

- **F1-NUM-a — cell size (FOW cells per map tile / world metres per FOW cell).** `[U]` Evidence of absence: §2 (no `res`-to-metres literal), §3 B1–B4 (no FOW-window float), §5 (no byte-proven `k`). Settling dump **E-NUM-a**: one peasant, known `vision` (default 1 → predict `res=24`). Dump `GetFOWLOSData` on two perpendicular transects through the unit at 1.0-unit steps, ±(`res`+8) units. Fit visible-run length against `floor(20+4·vision)`; repeat for vision 0/3/8 sids (predict 20/32/52) and a `map_revealZone` fogreveal radius R=10/20/30 (predict `floor(dx)`=R). Then one transect at 0.25-unit steps across the predicted edge to expose quantisation steps. Termination: all six radii fit one linear scale `k` with **zero transect cells mismatching** `dist ≤ k·res` on coarse passes AND the fine pass shows one stable step width (the cell size) with zero off-step cells; report `k` + cell width, else keep `[U]`.
- **F1-NUM-b — multi-viewer combine (`max` vs sum-threshold vs per-team channels; `FOWFillMaxNum`/`FOWDefDov` roles).** `[U]` Evidence: one scalar per viewer via `SetFOWDovFunc`; zero script writers for K4/K6 (§2); §3–§4 no accumulation operator. Settling dump **E-NUM-b**: two identical peasants (`res` from E-NUM-a), separation ≈0.75× diameter; dump transect through both centres + perpendicular bisector. Then three co-located peasants, removed one at a time with `FOWBuildFull` between removals (Boolean-OR keeps the cell until the last viewer leaves). Then ally vs enemy second viewer (ally extends per `player.script:464-473`, enemy must not). Log `GetFOWFillMaxNum`/`GetFOWDefDov`; if the cap is small, repeat stacking at raised `SetFOWFillMaxNum` and report whether the drop-out moves. Termination: union-shape match + removal sequence matches Boolean-OR (or stated threshold N with fill-cap dependence) + ally/enemy split, with **zero mismatching cells** across all sub-runs.
- **F1-NUM-c — LOS occlusion (pure disc vs height/forest/wall blocking; any slope; `FOWElevation` effect).** `[U]` Evidence: no blocker predicate in any FOW path (§2 A6, parent P14); `FOWElevation` never written (§2 A1); §3–§4 no slope literal. Settling dump **E-NUM-c**: fix E-NUM-a geometry; interpose in turn (i) hill ridge, (ii) forest block, (iii) wall/building row; control run on same seed. Log `GetFOWElevation` default, do not change it. Termination: all three interpositions dump **cell-identical** to control (zero mismatches) → pure-radius disc, close as `[O]`-by-experiment; else map the shadow edge at 1.0-unit steps, fit the blocker rule, and confirm it on a second rotated transect with **zero mismatches**. Never write a slope without that second-transect confirmation.
- **F1-NUM-d — explored-vs-visible persistence (sticky vs volatile, per-player vs global, clear triggers).** `[U]` Evidence: script shows only recompute triggers + viewer-set resets (`ClearFOWPlayers`, `FOWBuildFull`, `AddFOWObjects` re-merge); `onsave.inc` carries no explored payload. Settling dump **E-NUM-d**: reveal a far probe cell (`GetFOWLOSData>0`), then with `FOWBuildFull` + settled tick before each dump: (i) walk viewer beyond `res`+margin; (ii) `_control_SetPlayer` round-trip; (iii) balloon/victory/editor-fog gates where scriptable; (iv) kill viewer (`res:=0` dead arm); (v) save + reload (fogreveal re-merge vs explored-cell restore). Repeat per arm for ally vs enemy viewing player. Termination: full matrix dumps identically on two repeats with **zero mismatches**, yielding sticky-vs-visible, per-player-vs-global, and what each trigger clears.
- **F1-NUM-e — `GetFOWLOSData(x,z)` sampling (point vs cell-area, quantisation/threshold, return domain beyond grounded `Integer` + `>0`).** `[U]` Evidence: signature `(x,z: Float): Integer` grounded (§3 B2), call sites compare only `>0`; `TLOSData` proves a sampled record exists (§4 C4) but not its domain. Settling dump **E-NUM-e**: on E-NUM-a setup, 0.25-unit fine transect across the edge logging raw `Integer` returns; stability re-dumps; inside/outside tile-border probes; any value >1 noted (informs E-NUM-b). Termination: raw domain enumerated (e.g. exactly {0,1}) with **zero out-of-domain values** over full fine transect × 3 repeats, and edge cell matches stated point-vs-area rule with **zero mismatches**; portable port predicate stays `>0` until then.
- **F1-NUM-f — native RTTI layouts (`TLOSInfo`/`TLOSData`/`TFOWLerpInfo`/`TFOWLerpData`/`TOSWFOWRender`/`XFOWRender` record fields; `FOWRenderT` slot payload).** `[U]` Evidence: names + framing re-observed (§§3–4 C1–C4), zero flat xrefs (P6), field bytes not resident-readable. No static layout is drawn. Settling read **E-NUM-f** (owner-authorised debugger/memory read only, no binary patch): dump field offsets/sizes for each record at the §4 file-offs on the pinned build and log them with the run id; cross-check the `XFOWRender` flag at `[+0x18]` (§4 C2) and factory fields `[+0x48/0x14/0x4c]` (§4 C3) against observed defaults. Termination: identical layout on two reads with **zero mismatching bytes/fields**; anything flapping stays `[U]`. No layout constant is ported until then.
- **F1-NUM-g — knob live defaults (K1–K8 values).** `[U]` Evidence: zero script writers, zero config keys, zero binary defaults (§§2–4). Settling log **E-NUM-defaults**: in the E-NUM-a control setup, call each readable getter once per run (`GetFOWElevation`, `GetFOWLerpFactor`, `GetFOWTextured`, `GetFOWDefDov`, `GetFOWColor`, `GetFOWFillMaxNum`, `GetFOWDateTime`, `GetFOWSmooth`) and log values. Termination: identical values across the three E-NUM-a repeats with **zero mismatches**; the logged values become the documented engine defaults for that build. Never set a knob to reproduce a look — defaults are observed, not chosen.

Explicit non-inventions: no cell size (not 0.5 m, not 2 m, not 2.5/5 m, not `53.333`-derived, not one map tile), no combine operator, no occlusion slope or blocker list, no persistence lifetime, no LOS domain beyond `Integer` + `>0`, no RTTI field layout, no knob default.

## 7. Port guidance (NOT applied; owner/COORD applies after experiments terminate)

Paths are `variant3d/scripts/world3d_fog.gd` line numbers in the current 551-line file (parents). Until an experiment terminates, keep every `[U]` label and the provisional driver; each change below is conditional on its zero-mismatch criterion — **this worker makes no port edit**.

1. Cell size (on E-NUM-a): replace `_vision_radius_m` body with `float(res) * GRID_K`, add `DONOR_FOW_METRES_PER_RES := <k>` + `DONOR_FOW_CELL_M := <step>` citing the log; mirror into viewer/fogreveal disc loops. Never hard-code 2.5/5.0/`53.333` without the fit.
2. Combine (on E-NUM-b): Boolean-OR keeps `fog_counts>0` with re-label; threshold/per-team wins replace the accumulation site; `FOWFillMaxNum`/`FOWDefDov` get port constants only from dumped defaults + move-the-drop-out proof.
3. Occlusion (on E-NUM-c): pure-disc adds one comment, no code; blocking inserts the fitted test only with second-transect confirmation. `FOWElevation` gets no counterpart until measured.
4. Persistence (on E-NUM-d): sticky-explored keeps `fog_explored[i]=1`; visible-only or trigger-clears rewire `rebuild_fow_full`/`rebuild_fow_enable` per the verdict; no explored-restore until the save arm terminates.
5. Sampler (on E-NUM-e): keep `>0` veto always; richer domain adds a second accessor without changing the veto; document point-vs-area with E-NUM-a geometry.
6. RTTI/knobs (on E-NUM-f/defaults): no `TLOS*`/`TFOWLerp*`/`XFOWRender` struct enters the port (engine-internal); knob defaults enter as logged constants only.
7. Do-not-touch: `donor_unit_vision` (`floor(20+4·vision)`/`floor(dx)`), `rebuild_fow_enable`/`_fow_viewer_players`, fogreveal create/remove, reveal-then-count-then-commit order, alpha ladder, `FOG_Y_OFFSET`, overlay build, `FOWColor`/`FOWTextured`/`FOWSmooth`/`FOWLerpFactor`/`FOWDateTime` render-only tuning.

## 8. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line (§2) and native CODE/RTTI hits with file-offs + derived VAs (§§1/3/4); open items (§6) list exact next runtime reads.
- No approximation substituted: the provisional `1 res = 1 metre` driver, the sticky `fog_explored` mirror, and the absence of any `FOWElevation`/`FOWFillMaxNum`/`FOWDefDov`/grid-step port constant stay labelled PORT law / `[U]` until their experiments terminate. The 2.5/5 m hypotheses are recorded as hypotheses with zero byte support, never as constants.
- Read-only compliance: exactly one repo file written (this report). Native citations are pinned to `t_87f0f3c130b0` (sizes, hashes, file-offs, derived VAs, P3–P9 counts/distances in §§1–5; capstone-5.0.7 `C:\Python314\python.exe` used as a byte-reader/disassembler only); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-FOW-NUMERIC-DEEP.*
