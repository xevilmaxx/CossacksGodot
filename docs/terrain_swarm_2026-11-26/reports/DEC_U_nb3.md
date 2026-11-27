# DEC-U-NB3 — `TraceLineQuadTree(Ext)` call-edge: placement/selection ray, not a proven FOW occlusion primitive (2026-11-26)

- id: DEC-U-NB3
- worker: DEC-U-NB3 (subagent, full 1:1 Cossacks 3 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied/patched. Donor read as bytes/text only. No code/asset/config/Godot/git edit. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` (re-verified this worker via `certutil` SHA256, §1 P1)
- upstream: `DEC_U_fow_occ_deep.md` §§1–2, §2.5/§4 (NB-3 source: `TraceLineQuadTree(Ext)` `@0x2a735b/@0x2a7388` file-offs recorded as unlinked positional candidate only, LOS occlusion `[U]`) · `PORT1TO1_b_angle_index.md` §3 NB-3 ("only a byte-proven call edge upgrades it from candidate to callee")
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling experiment given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor GPU A/B frame. No donor binary executed by this worker. No port capture compared.
- network: OUT OF SCOPE.

## 0. Result in one paragraph

Class-B candidate NB-3 is executed with multiple NEW byte-level passes pinned to `t_87f0f3c130b0`, using the engine Deep (native) command set against the already-open target. The two `TraceLineQuadTree(Ext)` signatures are re-recovered verbatim with file-off/RVA/VA (§2.1). Their argument shape is a flat ground-plane segment probe — `(stx,stz,endx,endz: Float; prior,quadtree: Integer): Boolean`, with the `Ext` overload adding `var resnearx,resnearz,resfarx,resfarz: Float` hit-point out-args — selected by a Topology `prior`+`quadtree` integer pair, with no height/Y, no direction vector, no blocker list, and no distance output (§2.2). The only shipped-script call sites (NEW census, §2.3) are AI formation clamping (`ai.script:677`, `progresswarai.inc:1954`), guard-order building standoff (`miscext.script:513` via `TopologyGetPathPriority/QuadTree`), and one commented-out wall probe (`init.script:241`); every live site consumes the Boolean/near-far result for placement/selection, and none sits in any FOW procedure or passes any FOW value. The only two `GetFOWLOSData` call sites (`control.script:270`, `gui.script:3479`) pass plain unit `(x,z)` and test `>0`, with zero `TraceLine*` textual or procedural co-occurrence (§2.4). Native static xrefs to the three string VAs return zero hits with an explicit computed-pointer blind spot, and string-table adjacency (~1.2 KB upstream of the FOW binding block) is registration order, not a call edge (§2.5). Therefore no byte-proven caller chain from `GetFOWLOSData @0x2a7812` (VA `0x6a8412`) or any FOW API to `TraceLineQuadTree(Ext)` exists in readable bytes: linkage stays `[U]`, and the function is classified — on positive caller evidence, not absence — as a placement/selection ray, never as an FOW occlusion primitive. No blocker invented; no parity claimed. LOS occlusion (OCC-a…d) remains `[U]` pending the §4 fixed-camera hill/wall/forest transect with zero-mismatch termination.

## 1. Pass ledger (all native passes pinned `t_87f0f3c130b0`; donor-text passes read-only)

| # | Pass | Result |
|---|---|---|
| P1 | Binary pin re-verified (size + SHA256, no execution) | `certutil` → `87f0f3…4e16c`. Matches pin. `[O]` |
| P2 | Re-read `DEC_U_fow_occ_deep.md` §§1–2 + `PORT1TO1_b_angle_index.md` §3 NB-3 in full | Confirmed prior: signatures verbatim, linkage `[U]`, upgrade rule = byte-proven call edge only |
| P3 | Engine Deep: `native_bytes_find {text:"TraceLineQuadTree"}` + `native_bytes_show` at hits (NEW) | 2 hits: file-offs `0x2a734e`/`0x2a73b2` (VA `0x6a7f4e`/`0x6a7fb2`, CODE). 512-B/1024-B dumps recover both signatures verbatim + FOW binding-block neighbour (§2.1). `[O]` — ev_0304782b66bab6ac70cdb1bf585994b75f3d46918a0c6250c225566eb42bc2fd, ev_d31fd8ef54e582649e92198ea047558cbef976467489ed8b0e79a0367d5de822, ev_bb488f1a19259fa22590936a31d22e384104f41d9e91f97d1ec3fab71004a5b9, ev_0357b1d3292316e28312c07bd22a490ba5e949c16dd7771e230f9845d45dc895 |
| P4 | Engine Deep: `native_bytes_show` at `0x6a7f00` (1024 B) + `0x6a8412` (512 B) window (NEW) | Proves adjacency with exact distance: `TraceLineQuadTree` string starts 1,207 B upstream of `GetFOWLOSData` (`0x2a7812−0x2a735b=0x4B7`); window `0x6a7f00` reads `…DoGameManagerSelectionRebuildGUI → TraceLineQuadTree → TraceLineQuadTreeExt → GetPatternPlayerName → Get/SetFOWEnable → Get/SetFOWElevation → …`, i.e. selection/topology → line-trace → pattern/FOW registration order, not a call graph (§2.5). `[O]` — ev_0357b1d3292316e28312c07bd22a490ba5e949c16dd7771e230f9845d45dc895, ev_874f99da774cdf82232df6d62bfce6060dd762d415c9d3b219314b82cc0a175d |
| P5 | Engine Deep: `native_function_find` at `0x6a7f5b`/`0x6a7f88`/`0x6a7fbf`/`0x6a8412` + `native_xrefs_list` at `0x6a7f4e`/`0x6a7fb2`/`0x6a8412` (NEW) | All four `function_find` return "not inside any discovered function" (packed-CODE blind spot, absence≠proof); all three `xrefs_list` return 0 references with explicit `static_references` limitation (computed pointers unseen). No edge, no anti-edge. `[O]` negatives with stated limits — ev_73f8f13428c620cf5d91deb2660d99f882b252a23227cb986b12e696a58a8441, ev_6163fe8b06286435ba85ea530015f49d91570ec1ef05e55e73233e13ce079eb0, ev_0aa0c12eafa5a8ddd7fe3cb1b311e2b653006ab552a20d7470434e457093d0f8, ev_f87fdea71897224d9e4ccd034b589e5099a5fc20c90b04625980e53ef3f8da34, ev_7bf8c160d13452cf2e2b8fbfadad38c597d05ac3c6c2dcded2dad703a07f0b54, ev_b3f933b9099f3a735e08a92883513f0ea5e7013ee6146932c6d99c2c6f7ce465, ev_c2f22250b5dd9e698adf81392724f0098a993b3257e58b4ce663c8eceeb995a8 |
| P6 | Engine Deep: `native_bytes_find` for `TopologyGetTopologyQuadTree/Priority`, `TopologyGetPathPriority/QuadTree`, `WorldAddQuadTree`, `GetFOWLOSData`, `RayCast*` (NEW) | Selector APIs each exactly one CODE hit (`Topology…` cluster `0x6a6e00` window reads as Get/Set pairs); `GetFOWLOSData` exactly one hit `@0x2a7812`; `RayCast` 70 hits across 3 families (placement `RayCastHeight/Terrain/Water` @`0x6a25b2`, precision/viewer @`0x6a41bc`, selection `GameObjectRayCast*` @`0x69e39c` window) — full disambiguation, none in any FOW path (§2.6). `[O]` |
| P7 | Donor-text `TraceLine*` caller census (NEW, `data/scripts/**`) | Exactly 3 live call sites + 1 commented probe, all placement/selection (§2.3). `[O]` |
| P8 | Donor-text `GetFOWLOSData`/FOW caller census (NEW re-read) | Exactly 2 call sites, both plain `(x,z)>0`; zero `TraceLine*` co-occurrence in any FOW procedure (§2.4). `[O]` |

VA convention: file-off = raw image offset; RVA = CODE `vaddr 0x1000` mapping (`RVA = file-off + 0xC00` in CODE); VA = RVA + `0x400000` image base. Prior `@0x2a735b`-style labels are file-offs; this report gives file-off/RVA/VA at first mention for every NEW address.

## 2. Deep decomp: signatures, shapes, callers, and the missing FOW edge

### 2.1 Verbatim signatures — corrected offsets included `[O]`

- 1024-B dump at `0x6a7f00` (file-off `0x2a7300`, ev_0357b1d3292316e28312c07bd22a490ba5e949c16dd7771e230f9845d45dc895) reads, in order: `…procedure DoGameManagerSelectionRebuildGUI()`, then `function TraceLineQuadTree(stx, stz, endx, endz: Float; prior, quadtree: Integer): Boolean`, then `function TraceLineQuadTreeExt(stx, stz, endx, endz: Float; prior, quadtree: Integer; var resnearx, resnearz, resfarx, resfarz: Float): Boolean`, then `…GetPatternPlayerName…SetPatternPlayerName…Get/SetFOWEnable…Get/SetFOWElevation…`.
- The `native_bytes_find` hits are the two `TraceLineQuadTree` prefixes at file-offs `0x2a734e`/`0x2a73b2` (VA `0x6a7f4e`/`0x6a7fb2`); the canonical signature starts the prior report cites (`@0x2a735b` file-off / RVA `0x2a7f5b` / VA `0x6a7f5b` for the short form, `@0x2a7388` / RVA `0x2a7f88` / VA `0x6a7f88` for the `Ext` mid-form, full `Ext` overload `@0x2a73bf` / VA `0x6a7fbf`) fall inside those same two dumped strings — consistent, not conflicting. `[D]`: the three labels name two string records (short + full-Ext), and the `0xD`–`0x2D` deltas are intra-string offsets to the `function` keyword vs the `Trace…` name start.
- `[D]` boundary: these are Delphi DScript registration strings (length-prefixed string-table DATA with `ffffffff` separators visible in hex), not disassembly. They prove the script-visible arity and types, never the native body, loop, or step count.

### 2.2 Argument shape: a flat XZ segment probe with a Topology selector — no ray, no blocker, no distance `[D]`

- Inputs: start `(stx,stz)` → end `(endx,endz)`, all `Float`; that is four ground-plane floats, i.e. a 2D segment, not a 3D ray (contrast `RayCastTerrain(x1,y1,z1,x2,y2,z2; var xres,yres,zres): Boolean @0x6a25b2` and `ScreenToWorldRayCast(ascreenx,ascreeny; var arayx,arayy,arayz)` in the §1 P6 windows, which both carry Y). `[D]` by direct signature comparison.
- Selector: `prior, quadtree: Integer` — both plain integers, sourced at every live call site from Topology getters (`TopologyGetTopologyQuadTree/Priority` for formation/AI, `TopologyGetPathQuadTree/Priority` for guard standoff; each getter exactly one CODE hit, Get/Set pairs in the `0x6a6e00` window, §1 P6). No height, slope, step, radius, forest, building, wall, unit, or FOW argument exists in either arity. `[O]` signatures + `[D]` reading.
- Outputs: short form returns `Boolean` (clear/blocked predicate); full `Ext` form returns `Boolean` plus four `var Float` near/far hit XZ (`resnearx,resnearz,resfarx,resfarz`). There is no distance float, no normal, no hit-handle, no count. `[O]`.
- `[I]` (labelled, not claimed): the shape fits a topology-masked 2D segment query (which quadtree layer at which priority blocks the segment, and where it enters/exits) — exactly what the §2.3 callers use it for.

### 2.3 Caller census: three live sites, all placement/selection — zero FOW `[O]`

1. `data/scripts/lib/ai.script:675-681` — `_ai_SetArmyPosition`-family formation loop: `topQuadTree := TopologyGetTopologyQuadTree; topPrior := TopologyGetTopologyPriority; if not TraceLineQuadTree(posX, posZ, x, z, topPrior, topQuadTree) then begin x := posX; z := posZ; end;` — per-squad offset target clamped back to the army anchor when the topology segment is blocked, before `_player_SetSquadPosition`. Placement clamp, never visibility. `[O]`.
2. `data/scripts/units/global.inc/progresswarai.inc:1952-1958` — identical shape inside `_ai_GetArmyDanger`: same `TopologyGetTopologyQuadTree/Priority` pair, same `if not TraceLineQuadTree(posX, posZ, x, z, …) then x := posX; z := posZ;` clamp before `_misc_PosToScanGridIndices` danger lookup. Placement clamp feeding a danger grid, never FOW. `[O]`.
3. `data/scripts/lib/miscext.script:497-514` — `gc_obj_order_type_guard` handler: guard near a building computes `prior := TopologyGetPathPriority; quadtree := TopologyGetPathQuadTree; TraceLineQuadTreeExt(dx, dy, px, py, prior, quadtree, rnx, rny, rfx, rfy); dst := VectorDistance(px, 0, py, rfx, 0, rfy);` — the Ext near/far XZ feeds a `mindst/maxdst` standoff distance (`1/1.5` when colliding, else `2/3`) and `_unit_SetSTP(hnd, rfx, rfy)`. Selection/pathing standoff, never visibility. `[O]`.
4. `data/scripts/lib/init.script:240-241` — commented out: `//WorldAddQuadTree(gc_top_WallPriority, 'ctpoNotEqual'); //if TraceLineQuadTree(gox, goz, trx, trz, gc_top_WallPriority, gc_top_WallQuadTree) then`. Dead text; proves only that a wall-priority/quadtree selector pair existed as a concept, never that it ran or that it touched FOW. `[O]` dead, not evidence.
- No other `TraceLineQuadTree` textual hit exists in shipped `data/scripts/**` (P7: 4 matches total = the 3 live + 1 comment). No call site passes a height, a blocker name, a distance, or any FOW value. `[O]`.

### 2.4 FOW side: two `GetFOWLOSData` sites, neither reaches `TraceLine*` `[O]`

- `control.script:270`: `(not GetFOWEnable) or (GetFOWLOSData(GetGameObjectPositionXByHandle(nearestHnd), GetGameObjectPositionZByHandle(nearestHnd))>0)` — picking veto `bVisible`. `[O]` (re-read, matches `DEC_U_fow_occ_deep.md` §2.6).
- `gui.script:3479`: `(not GetFOWEnable) or (GetFOWLOSData(GetGameObjectPositionXByHandle(goHnd), GetGameObjectPositionZByHandle(goHnd))>0)` — resource tint `bNotInFOW`. `[O]`.
- `player.script:463/472/477` (`AddFOWPlayers`, `SetFOWEnable`) and `scenario.script:1861-1862` (`GetFOWEnable → FOWBuildFull`) complete the shipped FOW writer/trigger set; none contains, defines, or is contained in a procedure containing `TraceLine*`. A whole-tree grep for `TraceLine` returns only the §2.3 files; a whole-tree grep for `GetFOWLOSData` returns only the two veto sites. Zero textual co-occurrence, zero shared procedure. `[O]`.
- Native side: single CODE hits for `GetFOWLOSData @0x2a7812` (VA `0x6a8412`) and `GetFOWElevation @0x2a750a` (VA `0x6a810a`) confirm the registration block exists once each; they prove nothing about callees. `[O]`.

### 2.5 Why adjacency is not an edge `[D]`

- Measured distance (P4): `GetFOWLOSData` string start `0x2a7812` minus `TraceLineQuadTree` string start `0x2a734e` = `0x4C4` (1,220 B); minus the canonical `@0x2a735b` label = `0x4B7` (1,207 B). The prior "±4 KB window / ~2 KB upstream" description is refined to ~1.2 KB upstream — inside the same DScript binding table, between `DoGameManagerSelectionRebuildGUI` (selection rebuild) and `GetPatternPlayerName`/`GetFOWEnable` (pattern/FOW registration). String-table adjacency is registration order, never a call edge. `[D]`.
- The engine's static `xrefs_list` to all three string VAs returns zero with the explicit limitation that computed-pointer (Delphi dynamic-dispatch / registration-table) references are unseen — so the zero is a null result under a known blind spot, not a proof of no-caller. Likewise `function_find` misses all four VAs because the built-in engine never discovered functions in this packed CODE region (absence≠proof). No byte-proven edge in either direction is therefore available from this lane; a disassembly lane that resolves the registration table to code bodies is the only route that could upgrade linkage, and it was not available to this worker. `[D]`.

### 2.6 `RayCast*` disambiguation (so the ray is not re-litigated later) `[D]`

- `RayCastHeight(x, y: Float): Float`, `RayCastTerrain(x1,y1,z1,x2,y2,z2; var xres,yres,zres): Boolean`, `RayCastWater(x, y; var h): Boolean @0x6a25b2` window = placement/movie/sync height probes (cf. `misc.script:5926` fogreveal Y in the prior report). `GameObjectRayCast*/ScreenToWorldRayCast/*IntersectGameObjectFromMouseRay @0x69e39c` window = mouse/selection picking. `RayCastPrecison/GetTerrainRayCastPrecison/ViewerBuffer* @0x6a41bc` window = precision knob + viewer buffers, adjacent to cadencer — render-adjacent, never FOW. None appears in any FOW path. `TraceLineQuadTree(Ext)` belongs textually and functionally with the Topology/pathing family (§2.3), not with any of these three ray families. `[D]` by signature + caller context.

## 3. Still-`[U]` items (nothing invented)

| Item | Status | Evidence of absence / next read |
|---|---|---|
| NB3-a — native body of `TraceLineQuadTree(Ext)`: loop, step count, slope, height sampling | `[U]` | P5: bodies undiscovered by built-in engine; registration strings carry no immediates by construction. Needs disassembly lane resolving the registration table to code (computed-pointer-respecting trace, never a string-xref). |
| NB3-b — byte-proven caller chain `GetFOWLOSData/TLOSData/FOWElevation → TraceLine*` | `[U]` | P5+P8: zero static xrefs under a known blind spot; zero textual/procedural co-occurrence in shipped scripts. Only a code-level cross-reference upgrades this to `[D]`; string adjacency never does. |
| OCC-a — blocker set (terrain height, buildings, forests, walls, units) | `[U]` | Unchanged from `DEC_U_fow_occ_deep.md` §3; this report adds no blocker and removes none. |
| OCC-b — blocker mechanism (hard block vs height-slope vs quadtree line-trace; step count / slope) | `[U]` | `TraceLine*` shape is suggestive `[I]` but unlinked; no slope/step literal recovered. |
| OCC-c — `FOWElevation` effect | `[U]` | Zero script writers (prior P9, re-confirmed by P8 census: no `SetFOWElevation` hit in scripts); live value runtime-only. |
| OCC-d — TLOS record layouts | `[U]` | Type names only (prior §2.1); untouched by this worker. |

Explicit non-inventions: no blocker list (not hills, not forests, not walls/buildings, not units), no slope or step count, no `prior`/`quadtree` numeric values, no `FOWElevation` value or effect, no TLOS field layout, no parity claim.

## 4. Runtime experiment (one; fixed camera; zero-mismatch termination)

Unchanged from `DEC_U_fow_occ_deep.md` §4 (owned by OCC, reused here because NB-3 failed to close it). General harness (owner-authorised donor session, skirmish map, FOW on, fixed map seed): gameplay camera pinned (`SphereHeight/SphereLength=58`, pitch `−32°`, focal 400 fixed, `DynFogDepth=False` so visual fog never confounds the readout), fixed camera target for the whole experiment. Readout is script `GetFOWLOSData(x,z)` dumps only — never pixels. Log `GetFOWElevation` default alongside every run and do NOT change it. Every run ends with `FOWBuildFull` + one settled tick before dumping.

- **E-OCC (hill / wall / forest transect).** One viewer, known `vision` (default peasant 1 → predict `res=24` via `floor(20+4*vision)`; confirm the control radius first with the E-GRID-a coarse transect). Fix one transect line through the viewer at 1.0-world-unit steps, ±(res + 8) units. Control run with no interposition on the seed. Then, same seed, interpose in turn: (i) a hill ridge between viewer and far transect half, (ii) a built wall/building row across the transect, (iii) a forest block across the transect. Dump the identical transect each time.
- Termination: if all three interpositions dump **cell-identical** to the control with **zero mismatches**, verdict is pure-radius disc (no occlusion) — close as `[O]`-by-experiment. If any interposition shortens/shadows the run, map the shadow edge at 1.0-unit steps and fit the blocker rule (hard block vs height-slope vs line-trace); the fitted rule must predict a second, rotated transect (different bearing, same blocker types) with **zero mismatches**. Never write a slope, step count, blocker list, or `FOWElevation` effect without that second-transect confirmation. Any flapping cell keeps the field `[U]`.
- Native follow-up (disassembly lane only): if E-OCC shows shadowing, `TraceLineQuadTree(Ext)` file-offs `0x2a735b`/`0x2a7388` remain the first cross-reference target — but only a byte-proven call edge upgrades candidate to callee.

## 5. Exact port change list for `variant3d/scripts/world3d_fog.gd` (NOT applied; owner/COORD applies after E-OCC terminates)

No port file was read by this worker beyond the prior report's census; the list below carries the prior report's anchors forward unchanged:

1. **Occlusion (on E-OCC terminate).** If pure-disc: add one comment at the viewer disc loop stating the negative result + experiment id; no code change. If blocking wins: insert the fitted blocker test inside the viewer disc loop using the port height/blocker grid actually present at that time — never a slope constant without the §4 second-transect confirmation. `FOWElevation` gets no port counterpart until its effect is measured; log only.
2. **Do-not-touch list.** `donor_unit_vision` (`floor(20+4*vision)` / `floor(dx)`), reveal-then-count-then-commit order, alpha ladder, `FOWColor`/`FOWTextured`/`FOWSmooth`/`FOWLerpFactor`/`FOWDateTime` (render-only). `camera.cfg` DynFog values are never ported as gameplay constants. `TraceLineQuadTree(Ext)` gets no port counterpart: it is a placement/selection ray with live script callers, not an FOW primitive, and wiring it into FOW on shape-similarity alone would be an approximation.

## 6. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor bytes `[O]` with file-off/RVA/VA (§1 P3–P6, §§2.1–2.6) and donor text `[O]` with file:line (§§2.3–2.4); open items (§3) list the exact next runtime read in §4.
- No approximation substituted: no blocker, slope, step count, `prior`/`quadtree` value, `FOWElevation` constant, or TLOS layout is added to the port by this report.
- Read-only compliance: exactly one repo file written (this report). Native citations are pinned to `t_87f0f3c130b0` (P1 pin + P3–P6 evidence with file-offs/RVAs/VAs and evidence ids in §1); the already-open investigation target was used, never opened/selected/closed/renamed by this worker; no code/asset/config/Godot/git edit; no donor execution.

*End of DEC-U-NB3.*
