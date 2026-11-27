# DEC-U-MINIMAP-TAIL — minimap scale/offset, frustum quad, tints, unit-tint tail (2026-11-26)

- id: DEC-U-MINIMAP-TAIL
- worker: DEC-U-MINIMAP-TAIL (subagent, full 1:1 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edits. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`
- upstream: `DEC_U_fog_camera_hud.md` §§5.1–5.2 (panel `pl2x2/pl3x3` mapping + corner conflict minimap.cfg bottom-left vs initminimap.inc bottom-right), `IMPL-FOG-HUD` wired donor icon mapping only; port scale labelled approximation.
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling capture given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor GPU A/B frame. No donor binary executed. Closed items rest on donor text `[O]` with file:line; engine-side items stay `[U]`.

## 0. Pass ledger (all native passes pinned `document:"t_87f0f3c130b0"`, Deep, Clean-room off)

| # | Pass | Result |
|---|---|---|
| P1 | `core_session_show` + `core_targets_list` | active `t_87f0f3c130b0` (Deep), 675 evidence records; `editor.exe t_68474ddde43f` present, untouched |
| P2 | `core_feature_find "GUIMiniMap"` | negative — 0 strings/functions/imports (script-bound name family, expected) |
| P3 | `core_feature_find "MiniMapFrustum"` | negative — 0/0/0 (expected; frustum key is `FrustumVisible`, P7) |
| P4 | `core_feature_find "MMPrimitive"` | near-miss only: 1 string `7XMMPrimitives` @ `0x9592d5` — not the behaviour name (expected; behaviour name lives in script + CODE bytes, P9) |
| P5 | `native_bytes_find text "GUIMiniMapPrimitive"` | **positive** — 13 matches, all CODE, file-off `0x26aa94`–`0x26ae1d` (VAs `0x66b694, 0x66b6dd, 0x66b735, 0x66b78d, 0x66b7d9, 0x66b82d, 0x66b891, 0x66b8de, 0x66b914, 0x66b94d, 0x66b995, 0x66b9e1, 0x66ba1d`) |
| P6 | `native_bytes_find text "Minimap"` | **positive** — 4 matches, CODE: file-off `0x26ae6c` (VA `0x66ba6c`), `0x26aea0` (`0x66baa0`), `0x26cf28` (`0x66db28`), `0x26f961` (`0x670561`) |
| P7 | `native_bytes_find text "FrustumVisible"` | **positive** — 4 matches, CODE: file-off `0x269468` (VA `0x66a068`), `0x2694a0` (`0x66a0a0`), `0x370c6e` (`0x77186e`), `0x375004` (`0x775c04`) |
| P8 | `native_bytes_find text "pl3x3"` | **negative** — 0 matches utf8+utf16le (expected: sprite names live in `minimap.cfg` text, engine stores them opaquely) |
| P9 | `native_bytes_find text "TXMiniMapPrimitiveBehaviour"` | **positive** — 4 matches, CODE: file-off `0x21137d` (VA `0x611f7d`), `0x21139e` (`0x611f9e`), `0x214928` (`0x615528`), `0x214960` (`0x615560`) |
| P10 | `native_bytes_find text "MiniMapTextureSize"` | **positive** — 1 match, CODE: file-off `0x269084` (VA `0x669c84`) |
| P11 | `native_bytes_find text "MiniMapZoom"` | **negative** — 0 matches (script-key `SetGUIMinimapZoom(1)` has no resident literal; cf. initminimap.inc §2) |
| P12 | `native_bytes_find text "UserBlend"` | **positive** — 4 matches, CODE: file-off `0x26a623` (VA `0x66b223`), `0x26a66b` (`0x66b26b`), `0x468134` (`0x868d34`), `0x4684a8` (`0x8690a8`) |
| P13–P25 | ~13 donor-text read/grep passes (`C:\Games\Cossacks 3\data\…`, outside Craft Anything) | all `[O]` below with file:line |

Engine-string verdict `[D]`: GUI-minimap entry points that the engine implements (`GUIMiniMapPrimitive*`, `FrustumVisible`, `MiniMapTextureSize`, `UserBlend`, `TXMiniMapPrimitiveBehaviour`) leave CODE byte traces (P5–P7, P9–P10, P12); content names the engine only stores (`pl3x3`, `MiniMapZoom`, cf. parent `SetFOWEnable/FocalLength` negatives) do not. Negatives are expected, not proof of absence. (Ledger `ev_*` ids for P5–P12 are in the shared session evidence store; addresses/file-offs above are the portable citation.)

## 1. Panel geometry + corner conflict (CLOSED as text conflict, scale stays [U])

### 1.1 RECOVERED — `minimap.cfg:1-27` defaults `[O]`

`C:\Games\Cossacks 3\data\gui\minimap.cfg:1-27`, verbatim:

- `[O]` `ImageWidth/ImageHeight = 240`, `Width/Height = 240`, `VAlign = valBottom`, `HAlign = halLeft`, `Position = (0,0,0,1)`, `Visible = True`.
- `[O]` `FrustumVisible = True`; `FrustumLineStyle`: 1 px, white `RGBA(1,1,1,1)`, `LinePattern = 65535`, `AntiAliased = False`, `Visible = False` (the *style* node is hidden; the *frustum* is on — do not conflate the two `Visible` keys).
- `[O]` first primitive `lens.0`: `40×40`, UV `LeftTop (0.5,0.5)`–`RightBottom (1,1)`, i.e. bottom-right quadrant of the atlas image. Remainder of the file (`:52-~740`) is the `pl2x2.*` / `pl3x3.*` sprite atlas (3 px / 4 px cells + `.sel` variants) plus `cross1x1`, `ptborder` — icon art, **not** mapping law (parent §5.1 confirmed).
- `[O]` material: `LibTextureName` empty, `Texture.image = .\data\hud\textures\primitives.bmp`, `magfilter = maNearest`, `minfilter = miNearestMipmapNearest`, `mappingmode = tmmUser`; `moIgnoreFog = True`, `moNoLighting = True`; `BlendingMode = bmTransparency` (additive line commented out). `primitives.bmp` is 16,440 B on disk (`data\hud\textures\`).

### 1.2 RECOVERED — `initminimap.inc` runtime geometry (settles the corner conflict) `[O]`

`C:\Games\Cossacks 3\data\gui\menu.inc\initminimap.inc` (`InitMinimap` state), verbatim:

- `[O]` constants: `cMinimapSize = 240`, `cMinimapOffsetX/Y = -8`, `cKeyColorSize = 3`, `cBorderSize = 2`, `cOffset = 2`.
- `[O]` parent: `_gui_CreateParent('minimap', 0, gc_halParentRightWidth, gc_valParentBottomHeight, cMinimapOffsetX, cMinimapOffsetY, cMinimapSize, cMinimapSize, True)` — i.e. the 240² frame is anchored to the **right/bottom** parent edges with a −8 inset. `gc_halParentRightWidth = 8`, `gc_valParentBottomHeight = 8` (`classes.script:4580,4589`); align-name table `:4634-4705` confirms the vocabulary.
- `[O]` DPI: `scale := _gui_AbsScaleByDPI(elmParent)`; `_gui_GetAbsScaleByDPI` (`gui.script:140-162`) is resolution-based: `2` if `GetViewerHeight > 1535` else `1` (dpi-based arm is commented out).
- `[O]` engine minimap rect (inside `if (bInitial)`): `SetGUIMiniMapHAlign('halLeft')`, `SetGUIMiniMapVAlign('valBottom')`, `SetGUIMiniMapWidth/Height(cMinimapSize*scale)`, **`SetGUIMiniMapPosition(GetViewerWidth-cMinimapSize*scale+cMinimapOffsetX, cMinimapOffsetY, 0)`**, `SetGUIMinimapZoom(1)`, `SetGUIMiniMapLayer(3)`, `SetMiniMapFrustumVisible(true)`, `SetGUIEventStateOnPressMiniMap('EventMinimap')`, `SetGUIMiniMapVisible(True)`.
- `[O]` refresh tail: `_misc_UpdateMiniMapPrimitives(True)` (units skipped, buildings+mines+borders queued — see §4).
- `[O]` dead arm: `mmwidth/mmheight` → `SetGUIMiniMapTextureSize` block is commented out (`{…}`); engine default texture size stands. Native `MiniMapTextureSize` resident at VA `0x669c84` (P10) proves the key is consumed in CODE, but no donor width/height literal exists in text.

`[D]` corner-conflict resolution: `minimap.cfg`'s `halLeft/valBottom Position=(0,0,0,1)` is the **stale config default**; `initminimap.inc` overwrites the live rect every `InitMinimap` to **bottom-right** (`ViewerW − 240·scale − 8`, `−8`). The port's `bottom_right` (`config.gd:80`, `hud.gd:1621-1622,1638-1657`) is therefore the correct runtime reading; the `halLeft` align literal passed to the engine alongside a bottom-right position is a donor quirk to preserve, not to "fix". `EventMinimap` (`eventminimap.inc`) routes LButton press/repeat/release to `OnMouseDown` with `Tag 10/20/30` and `gfloat_gui_movecamerax/z := x/y`; RButton-up cancels brush.

### 1.3 Still-[U] — world→panel scale/offset (V2-MINI core)

No readable text defines the world→minimap affine: `SetGUIMinimapZoom(1)` is a scalar default, `SetGUIMiniMapPrimitivePosition(prim, x, z)` takes **world** coords (see §4), so the engine maps world→panel internally (aspect handling for non-square maps, zoom semantics, `Layer(3)` stacking, and whether the 240² rect shows the whole map or a cropped window are all engine-side). Never invent a metres-per-pixel constant.

- Experiment V2-MINI-SCALE (fixed-camera, owner-authorised): FOW off, full-map scenario with ≥6 surveyed markers at known world (x,z) spanning both axes; fixed camera (`camera.cfg` 58/−32/400, `SetGUIMinimapZoom(1)`); capture panel screenshot + read `GetGUIMiniMapPosition/Width/Height`; fit `u = sx·x + ox`, `v = sz·z + oz` (separate x/z scales + aspect test; repeat at ViewerHeight above/below 1535 for the DPI-scale arm, and on a non-square map). **Zero-mismatch criterion:** max |predicted − observed| marker-centre error = 0 px at native panel resolution across all markers and both DPI arms, plus byte-identical repeat on a second run. Until then every port scale/offset stays `PORT APPROXIMATION`.

## 2. Camera frustum quad vertices (still-[U], head-start recovered)

### 2.1 RECOVERED — donor quad API + style literals `[O]`

- `[O]` `classes.script:6013-6050` (`TSoundManager`): fields `frustumltx/lty, rtx/rty, rbx/rby, lbx/lby, cenx/ceny, rad`; `CalcFrustum()` calls engine **`GetCameraFrustumQuadrangle(frustumltx,y,frustumlty, frustumrtx,y,frustumrty, frustumrbx,y,frustumrby, frustumlbx,y,frustumlby)`** with `const border = 8`, then centres/radius. This proves a 4-corner engine frustum API with LT/RT/RB/LB order — but its only script consumer is **sound** (`audio.gd:29,218` sea-scan port mirrors it), not the minimap. Citing it as the minimap quad source would be wrong-shape.
- `[O]` minimap frustum keys: `FrustumVisible = True` + `FrustumLineStyle` (1 px white 65535) in `minimap.cfg:4,16-26`; `SetMiniMapFrustumVisible(true)` in `initminimap.inc`. Native `FrustumVisible` resident at 4 CODE sites (P7) — engine-drawn, script-toggled.
- `[O]` `lens.0` 40×40 UV cell is the **alarm** primitive (`_misc_ShowAlarm`, `miscext2.script:260-272`: `CreateGUIMiniMapPrimitive('lens.0')`, tag now, blink `0.2 / floor(10/0.2)*10`, position `round(px),round(pz)`, visible) — not the camera box. Do not cite `lens.0` as frustum geometry.

`[D]`: the camera-box quad vertices are engine-computed per frame from the live camera; no vertex literal exists in any readable file. The port's `hud3d_adapter.get_minimap_corners/quad` (TL→TR→BR→BL polygon) is a reasoned adapter shape, correctly labelled `PORT APPROXIMATION`.

- Experiment V2-MINI-QUAD (fixed-camera): FOW off, flat map, fixed camera; move camera to 4 widely separated poses; per pose capture minimap panel and log the 4 engine corners (via `GetCameraFrustumQuadrangle` where exposed, else surveyed ground markers at the rendered quad vertices). **Zero-mismatch criterion:** all 4 stroked edges coincide with the captured white box at 0 px max deviation (magnified ×8 audit) in all 4 poses, including a map-edge-clipped pose. Until then `stroke_minimap_quad` stays opt-in and the AABB stays `PORT APPROXIMATION`.

## 3. Explored/visible tints + thresholds (resource arm CLOSED, unit/global tail [U])

### 3.1 RECOVERED — the only tint literal in the minimap/HUD path `[O]`

`gui.script:3475-3529` (`gc_baseid_res` arm, `not gbool_gui_screenshotcamera` gate), verbatim law:

- `[O]` `bGeology := gPlayer[myPlInd].bgeology`; `bNotInFOW := (not GetFOWEnable) or (GetFOWLOSData(x,z) > 0)` (`:3478-3479`) — **threshold `> 0`** on the integer LOS value; veto shared with picking (`control.script:270-273`).
- `[O]` `bVisible := bGeology or bNotInFOW` (`:3480`).
- `[O]` `if (bVisible) and (not bNotInFOW) then newUserBlend := 0.5 else newUserBlend := 1.0` (`:3488-3491`) — geology-visible-but-LOS-zero → `0.5`, else `1.0`; applied to `hud_img` via `SetGUIElementUserBlend` when changed (`:3516-3517`), with `0.75`-fade show / `0.5`-fade hide (`:3521,3525`). Native `UserBlend` CODE residency (P12) corroborates engine consumption.
- `[O]` sibling guard: HUD icons near the minimap are pushed out of its rect (`gui.script:592-595`: `minimapMinH/W` from `GetGUIMiniMapPosition/Height/Width`, `dpiscale`, 20 px margin).

`[D]`: explored-vs-visible for **resources** is therefore `1.0` (seen-now or FOW-off) vs `0.5` (geology-only, i.e. explored-not-visible) vs hidden (`not bVisible`). No colour literal is involved — it is a blend factor on the existing icon.

### 3.2 Still-[U] — explored persistence, never-seen rendering, minimap-terrain tint

No readable text defines: FOW cell persistence (explored set vs last-seen), never-seen terrain colour on the minimap panel itself, or any threshold other than `> 0`. The `DynFog*` block (`camera.cfg:59-64`, `Depth=False` in gameplay cam) is visual depth fog, never gameplay — do not cite it here.

- Experiment F1-MINI-TINT (paired captures, owner-authorised): fixed camera, FOW on; (a) never-seen, (b) seen-now, (c) explored-not-visible (viewer walked away) cells for **resources**; sample `hud_img` `GetGUIElementUserBlend` + panel pixels; then repeat (a–c) for the **minimap panel terrain** (not the HUD icon). **Zero-mismatch criterion:** resource icons read exactly `1.0/0.5/hidden` per §3.1 law on every sample, and the panel-terrain never/seen/explored pixel sets are pairwise disjoint with 0 misclassified samples across 3 runs. Until then the port fog ladder (`world3d_fog` 0.78/0.30/0.00, `hud.gd` 0.25 never-seen dim) stays `PORT APPROXIMATION`.

## 4. Unit-tint tail (mapping CLOSED, tint/blink tail [U])

### 4.1 RECOVERED — per-unit icon mapping law (was S2-head) `[O]`

`misc.script:1017-1172`, verbatim:

- `[O]` create (`_misc_UnitCreateMiniMapPrimitive`, `:1019-1053`) and update (`_misc_UnitUpdateMiniMapPrimitive`, `:1137-1172`): `if GetGameObjectVisibleByHandle(goHnd)` else remove (`:1166-1171`); building ? `pl3x3.<color>` : `pl2x2.<color>`, or `pl3x3.sel` / `pl2x2.sel` when `bSetAsSelected`; `color = gMap.players[TObj(pobj).pl].color`; behaviour `TXMiniMapPrimitiveBehaviour` key `'prim'` with `GetOrCreatePrimitive` + `MMPrimitiveItemName := primname`, `Interval = 50`, `AutoDestroy = True`, `UpdateDirection = False`, `UseCustomDir = True`, `CustomDir = (1,0,0)`. Native behaviour-name residency (P9, 4 CODE sites) corroborates.
- `[O]` remove (`:1055-1065`): `ReleasePrimitive` + `BehaviourDestroy`.
- `[O]` bulk queue (`_misc_UpdateMiniMapPrimitives`, `:1067-1133`): per-unit `gGuiUpdateHighlights.Add(goHnd)` for alive units of race-`units` players (buildings-only when `bSkipUnits`); geology path stamps `cross1x1` mines at world `(x,z)` (`:1107-1108`); peacemode path stamps `ptborder` borders (`:1125-1127`). Both use `CreateGUIMiniMapPrimitive` + `SetGUIMiniMapPrimitivePosition(prim, worldX, worldZ)` — world-in/panel-out inside the engine.
- `[O]` refresh call sites: `gui.script:3472` per HUD pass (`_misc_UnitUpdateMiniMapPrimitive(goHnd, bPicked)` for every non-resource row) and `player.script:769` on ownership/progress path.

### 4.2 Still-[U] — the tail: FOW gating, `.sel` colour, blink/interval rendering

What the surrounding block does **not** contain (verified by full read `:1015-1180` + `gui.script:3420-3560`): any `userBlend`/colour literal for units, any `GetFOWLOSData` check on the unit path, any `.sel` RGB value, any blink rate for `prim`. Unit FOW hiding (if any) is engine-side inside `TXMiniMapPrimitiveBehaviour`/`GetOrCreatePrimitive`; `Interval = 50` units are unstated (ms? ticks? frames?); `bbuilding` comes from `gObjProp` (walls explicitly excluded from highlight at `gui.script:3468` but **not** from the minimap path — wall blips stay `[U]`).

- Experiment S2-UNIT-TAIL (fixed-camera + runtime): FOW on, fixed camera; (a) selected vs unselected own unit/building → capture `pl2x2.sel/pl3x3.sel` pixel RGB + size; (b) enemy unit in never-seen / explored-not-visible / seen-now cells → presence/absence + blend of its blip per `bPicked` arm; (c) wall segment vs house → blip presence; (d) blink/interval timing (frame-stamped captures at 60 Hz to fit the `Interval = 50` period). **Zero-mismatch criterion:** 0 misclassified blips across (a–d) × 3 runs, `.sel` RGB + cell sizes matching capture exactly, interval period identified with 0 unexplained frames. Until then: unit tint = donor **name** law only (§4.1); every RGB/size/period in the port (`MM_PLAYER_COLORS`, `DONOR_MM_*_PX`, white `.sel`, rims/rings, cluster buckets) stays `PORT APPROXIMATION`. Never write a port RGB back as donor fact.

## 5. Port change list (owner/COORD applies; this worker wrote no code)

Paths are `variant3d/scripts/…` (verified present; line numbers from this checkout):

1. `hud.gd:1-18` (header): keep `[O]` citations (`misc.script:1137-1172`, `minimap.cfg:1-27`, `gui.script:3488-3491`, `control.script:712-720`); keep V2-MINI/S2 `[U]` tags. Amend the corner note: `minimap.cfg:1-27` bottom-left is the **overwritten default**; live geometry is bottom-right per `initminimap.inc` (see §1.2) — header `:12` should say so.
2. `hud.gd:320-415` (`_mm_size/_mm_inset/_mm_corner/_apply_scale`): already correct (240 / −8 / bottom_right). Add DPI-scale arm: `scale = 2` iff viewer height > 1535 else `1` (`gui.script:158-161`), applied to `240·scale` and position `(ViewerW − 240·scale − 8, −8)` (`initminimap.inc`). Cite `gui.script:140-172,440-458`, `classes.script:4578-4589,4634-4705`.
3. `hud.gd:1583-1660` (`_build_minimap`): keep bottom-right; do **not** reintroduce cfg `(0,0,0,1)` as live geometry. Record the quirk: engine align keys stay `halLeft/valBottom` while the rect is bottom-right (`initminimap.inc`).
4. `hud.gd:1662-1718` (`_on_minimap_input`, `_minimap_jump_3d`): keep `world_pos = uv · (MAP_W, MAP_H) · TILE_M` (matches `SetGUIMiniMapPrimitivePosition` world-in contract, §4.1); keep `input_controller.gd:424-455` clamped-UV twin. World→panel **forward** affine (panel pixels from world) must not be derived by inverting this click path — it stays `[U]` (V2-MINI-SCALE).
5. `hud.gd:1726-1801` (`_draw_minimap_viewport_box`, `_mm_paint_box`): keep AABB as `PORT APPROXIMATION`; wire `hud3d_adapter.gd:162-195 stroke_minimap_quad` only after V2-MINI-QUAD passes with the 0 px criterion (§2.1). Cite `minimap.cfg:4,16-26`, `initminimap.inc SetMiniMapFrustumVisible(true)`, P7 VAs; cite `classes.script:6026-6040` as the **sound** frustum only, never as minimap geometry.
6. `hud.gd:177-196,2042-2082,2084-2131` (blips): keep `DONOR_MM_*_PX` + `DONOR_MM_BLEND_*` names but tag all RGB extents `PORT APPROXIMATION`; implement §4.1 name law verbatim (`pl3x3` iff `bbuilding` else `pl2x2`, `.sel` iff picked, `color = players[pl].color`, invisible → release). Add wall-blip, `.sel`-RGB, and `Interval = 50` units to the `[U]` list (S2-UNIT-TAIL). Cross/quarry (`cross1x1`) and peacemode border (`ptborder`) stamps per `:1107-1127`.
7. `camera.gd` + `camera3d.gd` (frustum source): no donor vertex literal to transcribe. `camera3d.gd:97-109` FOV tags stay `PORT APPROXIMATION`; `get_viewport_corners` stays the single quad source until V2-MINI-QUAD closes. Do not invent near/far from `default.cameras` screenshot/debug cams.
8. `world3d_fog.gd:43-55,90-92,190-191,270-533` (FOW): keep `_unit_GetVision` + `_player_UpdateFOW` + reveal-zone + `los_at > 0` veto mirrors; keep `DynFog*` visual-only. Resource tint `0.5/1.0` (`hud.gd:194-196`) is the **only** donor-grounded blend — apply it to resource HUD icons only, never to unit blips or panel terrain. Fog ladder + never-seen dim stay `PORT APPROXIMATION` until F1-MINI-TINT closes (§3.2).
9. Telemetry: keep `visual_parity_claim=false`; unresolved = `[V2-MINI-SCALE, V2-MINI-QUAD, F1-MINI-TINT, S2-UNIT-TAIL]` (+ parent `F1-GRID, V1-SENSOR, V2-PROJ/BOX, R1, O1, S3`).

## 6. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line; open items list exact next reads/captures in §§1–4.
- No approximation substituted: recovered literals replace port estimates 1:1; everything else remains labelled `[U]` with a zero-mismatch settling capture. No port RGB, scale, or vertex is written back as donor fact.
- Read-only compliance: exactly one repo file written (this report). Native passes pinned to `t_87f0f3c130b0` (P1–P12 with VAs/file-offs above); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-MINIMAP-TAIL.*
