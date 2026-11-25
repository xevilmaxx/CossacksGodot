# DEC-08 — Donor UI / minimap / HUD definitions, strings and localization: deep decompilation record

- **Date:** 2026-11-25 · **Ticket:** DEC-08 · **Output:** this report only.
- **Rules kept:** donor `C:\Games\Cossacks 3` inspected **read-only** (no copy, no execution, no unpacking); no source/asset/config/test/git edits; one report file written.
- **Path shorthand:** `C3` = `C:\Games\Cossacks 3`; `ROOT` = `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. Donor paths below are literal subpaths of `C3\data\`; port paths are relative to `ROOT`.
- **Labels:** **OBSERVED** = byte/line read directly at the cited `path:line` or `path:offset` (and re-read a second time); **DERIVED** = arithmetic/composition of observed values; **INFERRED** = best reading of observed code, not runtime-proven; **UNVERIFIED** = no readable evidence, no claim made.
- **Verification policy (twice):** every load-bearing number was read twice by independent means — a Python 3.14 `open(...,'rb').decode('latin-1')` numbered dump and a second `read`-tool / targeted `grep` / binary `struct.unpack_from` pass. Binary headers were read at byte offsets by `struct` and cross-checked with a hex dump. Discrepancies are recorded in §7.

---

## 1. Goal

Produce a donor-truth decompilation record for the Cossacks 3 → Godot 4.x port covering: (a) UI layout / state-machine definitions, (b) minimap definitions and world→minimap mapping, (c) font and texture assets, (d) localization / string tables, (e) HUD panel geometry and constants, (f) selection-related UI elements (selection rectangle, unit info panel, rally flag, build ghost). The port comparison (`variant3d/scripts/hud.gd`, `hud3d_adapter.gd`, plus minimal supporting reads) is **secondary**; where they conflict, the donor record is authoritative. Special attention is paid to anything that changes the **selection rectangle** or the **minimap camera box**.

---

## 2. Prior docs read

| Doc (one-line takeaway used) |
|---|
| `docs/decomp/DE_AUDIO_UI.md` — family counts, `en/gui.txt` key examples, `menu.cfg`/`menu.aix` state-machine sketch; labels locale **MISSING** in port. |
| `docs/coord_swarm_2026-11-24/reports/DEEPDEC_08_ui_minimap.md` — donor script-level HUD/minimap map (E1–E25), camera offset math, hotkey table, parity checklist; flags minimap frustum/donor selection-rectangle geometry **UNVERIFIED**. |
| `docs/coord_swarm_2026-11-24/reports/W23_hud_fidelity.md` — port already back-ported resource net `(income-consume)`, cap, hint buttons; **item 4 (minimap bottom-right 240 px) NOT-DONE** because `uitest.gd:306` asserts bottom-left. |
| `docs/coord_swarm_2026-11-24/reports/V767_hud_minimap_jump.md` — `hud.gd:1402-1454` 3D minimap click → `jump_to_world`; 2D handler byte-identical; donor double-click still missing. |
| `docs/coord_swarm_2026-11-24/reports/V781_minimap_black_fix.md` — camera SIM↔centred frame fix; `camera3d.gd` subtracts map half once; numeric probe 11/11. |
| `docs/coord_swarm_2026-11-24/reports/V717_hud3d_adapter.md` — `hud3d_adapter.gd` box contract: inclusive `Vector4i`, exclusive `Rect2` end, `int(world/TILE_M)` mapping; donor frustum geometry marked UNVERIFIED. |
| `docs/REPORT_DONOR_MENU.md` — verified donor lobby strings/options (also found at `docs/REPORT_DONOR_MENU.md`); locale labels for player/nation/team/color and additional settings. |
| `docs/research/RE_VISUAL.md` — S11 text-only HUD description; explicitly marks donor minimap corner **[U]** (never saw an image) — this report supplies file evidence for that corner. |
| `investigation.cany/investigation/findings.md` — `fnd_1`: 26.6666666 px/m, 53.3333333 px/tile, 32 fps; corroborated independently below. |

---

## 3. File inventory

All rows **OBSERVED** (size/line counts from read-only enumeration; two passes: whole-tree `os.walk` count and per-directory count).

| Family | Path (under `C3\data\`) | Format / size | Role |
|---|---|---|---|
| GUI state machine | `gui\menu.cfg` | text `section.begin`, 1,002 B / 36 lines | binds states to `menu.aix`; see §5 |
| GUI state list | `gui\menu.aix` | text `section.begin`, 22,905 B / 985 lines, **142** `Name = …` + 142 `UsedFileName = …` pairs | state→`.inc` manifest; e.g. `menu.aix:2-5` `DoCreate` → `.\data\gui\menu.inc\docreate.inc` |
| GUI scripts | `gui\menu.inc\*` **133**, `gui\common.inc\*` **3**, whole tree `*.inc` **313** (scripts 177) | CRLF text, `section.begin` + `Code : struct.begin` | layout/behaviour (initminimap, showresourcepanel, showunitcontrol, …) |
| Minimap config | `gui\minimap.cfg` | text, 22,749 B / 818 lines | 240×240 image, frustum, 34 atlas primitives, material |
| HUD config | `hud\hud.lib` | text (class library), `hud.lib:1` `name = btn.dummy` | button/group classes |
| HUD materials/textures | `hud\hud.mat` (35 `.mat` whole tree), `hud\hud.tex` (1 `.tex`) | text; `hud.mat:994-1001` `Material.Name = minimap.background`, `hud.tex:89-115` `LibTextureName = tex03` | atlas UVs for minimap background, icons |
| Font libs | `hud\font.lib` (1 line), `font1250/1251/1252/1254.lib`, `hud\ref\<cp>\reffont*.lib` | text; `font.lib:1` `{refurl=.\data\hud\font1251.lib}` | bitmap font families / codepages |
| Font atlases | `hud\textures\font\<1250,1251,1252,1254>\font.{sans,serif,opensans}.<size>.bmp` — **23 per codepage (92)** | 512×512 **8-bpp** paletted BMP: `font.sans.12.bmp:0x12`=512, `:0x16`=512, `:0x1C`=8 | no TTF/OTF anywhere (consistent with DE_AUDIO_UI.md:22) |
| Minimap primitive atlas | `hud\textures\primitives.bmp` | 64×64 **32-bpp** BMP: `:0x02`=16440, `:0x0A`=0x36, `:0x12`=64, `:0x16`=64, `:0x1C`=32 (`maNearest` at `minimap.cfg:741-742`) | blip sprites |
| UI bitmaps | `hud\textures\ui\*.bmp` **26**, whole tree `*.bmp` **264** | e.g. `ui\tex03.bmp`, `ui\icons.bmp`; `hud.tex:95`, `:211` | HUD/menu atlases |
| Cursors (raster) | `cursors\cursors.lib` (297 lines) + `cursors\textures\bmp\*.bmp` **14** | `cursors.lib:5-12` `crDefault Index=1 CurWidth=32 … SpotX=0` | 16 action cursors + 8 scroll cursors |
| Cursors (OS) | `cursors\textures\cur\*.cur` **8** | Windows CUR: `bottom.cur:0x00-0x05` `{0,2,1}`, `:0x0A-0x0D` hotspot `(15,24)`, `:0x12`=0x16, `:0x16` DIB 32×64 24-bpp | edge-scroll hotspots |
| Selection brushes | `brushes\selection.cfg` (299 B / 15 lines), `brushes\brushes.mat:199-260`, `brushes\textures\selection.*.dds` (6) | `selection.cfg:4-11` yellow line; `.dds` binary not decoded | drag-rectangle outline + unit/building/ship rings |
| Rally flag | `actors\misc\rallypoint.actor`, `objects\misc\rallypoint.prop`, `materials\misc\rallypoint.dds` | actor refs `.osm` mesh; `rallypoint.prop:19-21` scale 0.0525; `:25` roll 45 | 3D rally marker |
| Camera constants | `cameras\camera.cfg` (66 lines), `cameras\default.cameras` (97 lines) | text; `camera.cfg:6-10` sphere 58/20; `:32-35` four `-32°` | camera height/tilt feeding minimap jump |
| Global constants | `scripts\dmscript.global` (2,000+ lines) | text; `:170-173` px/m=26.6666666, m/tile=2, px/tile=53.3333333, tiles→px=0.01875 | world/minimap scale chain |
| Locale tables | `locale\<cs,de,en,es,fr,it,pl,po,ru,tu,uk>\` + `needloc\` + `lang.loc` | whole `data\locale`: **1,093 `.lng`, 1,082 `.txt`, 11 `.lib`, 1 `.loc`**; whole `data\`: **1,086 `.txt`** (4 outside locale) | bilingual source (`*.txt`) + compiled binary (`*.lng`) |
| Locale strings in use | `locale\en\gui.txt` 24,932 B / 937 lines, **461** `@key` records; `locale\en\gui.lng` 24,880 B, **460** records | `gui.txt:1-2` `\t@ver` / `PEGI v%ver%%dataver%` | HUD/menu strings |

**Inventory note:** DE_AUDIO_UI.md:20 says "455 `.inc`"; re-count gives **313** (133 `menu.inc` + 3 `common.inc` + 177 under `scripts\`). The 133/3 sub-counts in that doc are correct; the 455 total is not. See §7.

---

## 4. String table records

### 4.1 Binary `.lng` format (OBSERVED, offsets verified twice)

`C3\data\locale\en\gui.lng` is **not** plain text. Header and record layout:

```
@0x00  u32 LE record count = 460 (0x1CC)
repeat count times:
  @off  u32 LE byte length L of ASCII "key=value"
  @off+4   L bytes of latin-1/ascii text
  @off+4+L one byte 0x03 separator
```

- `gui.lng:0x00` = `cc 01 00 00` → 460 (**OBSERVED**, `struct.unpack_from('<I',b,0)` + hex dump).
- `gui.lng:0x04` = `18 00 00 00` (24); `gui.lng:0x08` = `ver=PEGI v%ver%%dataver%` (24 B); `gui.lng:0x20` = `03`.
- `gui.lng:0x21` = `10 00 00 00` (16); `gui.lng:0x25` = `name.def=Cossack`; `gui.lng:0x35` = `03`.
- `gui.lng:0x36` = `0e 00 00 00` (14); `gui.lng:0x3A` = `restype.1=Food`; `gui.lng:0x48` = `03`.
- Full parse consumed **exactly** 24,880 B (no tail) — format confirmed.
- Same format in `locale\table.lng:0x00` (`01 00 00 00`, count 1) and `locale\style.lng:0x00` (`01 00 00 00`); `locale\units.lng:0x00` = `de 01 00 00` (478).
- `locale\en\tooltip.lng` is **1,048,576 B of zeros** while `tooltip.txt` is **0 B** (**OBSERVED** at `:0x00-0x3F` and file size) — an empty/placeholder compiled table; do not treat its size as content.

### 4.2 Source `.txt` format (OBSERVED)

`locale\en\gui.txt` alternates a tab-indented key line and one or more value lines: `gui.txt:1-2` `\t@ver` → `PEGI v%ver%%dataver%`; values may span lines until the next `\t@` (e.g. `gui.txt:85-89` `infowindow.marketpricestip` is four lines). 461 keys vs 460 compiled records — **UNVERIFIED** which single source key is dropped at compile time (likely a header/placeholder; no byte-diff was attempted).

`GetLocaleTableListItemByID(table, key)` is the runtime accessor: e.g. `gui\menu.inc\showresourcepanel.inc:28-42` reads `'gui','resourcepanel.food.hint'`, `'misc','resourcepanel.farms'`. The `misc` table has **no `en` variant**: `locale\en\` contains no `misc.*`; English `misc` strings live in `locale\needloc\misc.txt:21` `%farmused% out of %farmexist%`, `:23` farmsnotenough, `:251` `No objectives`, `:253` `Show objectives`, `:255` `Hide objectives` (**OBSERVED**, two directory enumerations).

### 4.3 Key string IDs and English text (all **OBSERVED** at `locale\en\gui.txt:<line>`)

| Key | Line | English value (short excerpt) |
|---|---|---|
| `ver` | 1-2 | `PEGI v%ver%%dataver%` |
| `name.def` | 3-4 | `Cossack` |
| `restype.1 … .6` | 5-16 | `Food`, `Wood`, `Stone`, `Gold`, `Iron`, `Coal` |
| `text.win` / `text.lose` | 17-20 | `VICTORY! Press ESC to exit.` / `DEFEAT! Press ESC to exit.` |
| `info.population` / `info.maxpopulation` | 27-30 | `Population: %amount%` / `Max. Population: %amount%` |
| `log.notenoughres` | 51-52 | `Insufficient resources: %s1%` |
| `log.cantshootnogold` | 57-58 | `You have no gold. %s1% is unable to fire.` |
| `log.cantshootnocoaloriron` | 59-60 | `You have neither coal nor iron. %s1% is unable to fire.` |
| `log.lowfood` / `log.lowgold` / `log.lowshoot` | 73-78 | famine / mutiny / ammunition warnings |
| `resourcepanel.food.hint` | 227-228 | `Food is produced by peasants in the fields …` |
| `resourcepanel.wood.hint(.add)` | 229-232 | woodcutting / `Wood is primarily used for building construction.` |
| `resourcepanel.stone.hint(.add)` | 233-236 | quarries / walls and towers |
| `resourcepanel.gold.hint(.add)` | 237-240 | gold mines / mercenaries rebel |
| `resourcepanel.iron.hint(.add)` | 241-244 | armored units / ammunition |
| `resourcepanel.coal.hint(.add)` | 245-248 | ammunition for ranged units, artillery and ships |
| `resourcepanel.populationlimit` | 249-250 | `You cannot train more units once you hit the population limit. …` |
| `resourcepanel.lotofresources` | 251-252 | `9999999+` |
| `resourcepanel.lowfood` | 253-254 | `You are very low on food! Famine is possible.` |
| `control.btn.idlepeasants` / `.idlemines` | 255-258 | `Select all idle peasants` / `Select all unoccupied mines` |
| `control.btn.rallypoint` | 283-284 | `Rally point` |
| `unitpanel.info.inside` / `.maxinside` / `.kills` | 301-306 | `Inside` / `Max. Inside` / `Kills` |
| `unitpanel.hint.damage` / `.shield` / `.protection` | 261-266 | `Damage` / `Defence` / `Protection` |
| `control.btn.holdposition` … `.squadformsquare` | 317-347 | order-button labels (`Stand Ground`, `Patrol`, `Assume Formation`, …) |
| `control.btn.officerdecreasize(increase)` | 337-339 | `Shrink Formation` / `Expand Formation` |
| `control.btn.artillerypreparation` | 341-342 | `Bombard an Area` |
| `control.btn.groupformations` / `.ungroupformations` | 359-362 | `Group Formations` / `Ungroup Formations` |
| `minimap.info.peacemode` / `.scores` / `.time` / `.fps` | 163-171 | `Peace Mode` / `Scores:` / `Game time` / `FPS=` |
| `text.minimap.gametime(.peacetime)` | 509-512 | `Game time` / `P.t` |
| `text.pause` / `text.saving` | 217-220 | `Pause` / `Saving...` |
| `menu.gamemenu` | 739-740 | `Game Menu` |
| `customgame.text.player/nation/team/color` | 405-412 | `Player` / `Nation` / `Team` / `Color` |
| `map.size.normal/large/huge` | `needloc\new.txt:45-50` | `Normal` / `Large 2x` / `Huge 4x`; `new.txt:347-348` `map.size.tiny`=`Tiny` |

No `selection` / `ghost` key exists in `gui.txt` (**OBSERVED**: parsed 461 keys, zero matches) — the donor renders selection/ghost visually, not via UI strings.

### 4.4 Locale ↔ font mapping (OBSERVED)

`C3\data\locale\lang.loc` is a text map; `default`/`english` → `font1252.lib` + `en\table.lng` (`lang.loc:2-11`), `czech`/`polish` → 1250 (`:22-31`), `russian`/`ukrainian` → 1251 (`:32-36`, `:47-51`), `turkish` → 1254 (`:57-61`). `hud\font.lib:1` is a 1-line refurl to `font1251.lib` (fallback, **not** the English default). Font indices are in `scripts\lib\classes.script:4539-4560` (`gc_font_sans_12=6`, `gc_font_sans_13=7`, `gc_font_serif_13=18`) and family names at `:4707-4731` (`sans12`, `sans13`, `serif13`); colour tokens at `scripts\dmscript.global:1200-1218` (`white FFFFFF`, `darkgrey 707070`, `red FF0000`, `orange FFAA00`).

---

## 5. HUD / minimap geometry + transforms

### 5.1 State-machine and UI layout containers

- `gui\menu.cfg:2-4` binds `StateMachineFileName = .\data\gui\menu.aix`, `StateCreateGUI = DoCreate`, `StateDestroyGUI = DoDestroy`; `:9-16` binds mouse/enter/leave/move/wheel, `OnClear`, `OnSelection`; `:20` `StateProgressGUI = DoProgress`; `:21` `StateOnPressMiniMap = ` **empty** (the press state is installed at runtime, §5.2); `:24` `OnHint`; `:28-34` `ProgressInterval = 10`, `DefaultCursorIndex = 0`, `KeyRepeatDelay = 0.05`, `KeyDoubleDelay = 0.5`, `HintWaitDelay = 0.1` (**OBSERVED** twice).
- `gui\menu.cfg:17-18` `StateOnBeginSelection` / `StateOnEndSelection` are **empty** — no script hook draws the selection rectangle; consistent with `onmousemove.inc:154-162` which only calls engine APIs `GameManagerBeginSelection` / `GameManagerStartSelection('spmAdd'|'spmRunTime')` (**OBSERVED**).
- `gui\menu.aix:1-6` shows the manifest shape; 142 states include `InitMinimap` (`:211-214`), `EventMinimap` (`:218-221`), `ShowResourcePanel` (`:246-249`), `ShowUnitControl` (`:260-263`), `ShowRallyPoints` (`:316-319`), `InitHUD` (`:323-326`), `OnSelection` (`:159-162`) — **OBSERVED**.

### 5.2 Minimap widget geometry (OBSERVED; two reads of `minimap.cfg`)

- `gui\minimap.cfg:2-6` `ImageWidth=240`, `ImageHeight=240`, `Width=240`, `Height=240`, `FrustumVisible=True`; `:7-8` `VAlign=valBottom`, `HAlign=halLeft`; `:9-15` position `(0,0,0)`, `W=1`, `Visible=True`.
- `gui\minimap.cfg:16-27` frustum style: white `(1,1,1,1)`, `LinePattern=65535` (solid), `LineWidth=1`, `AntiAliased=False`, `Visible=False` (line-style default; note the apparent tension with `FrustumVisible=True` at `:4`).
- `gui\menu.inc\initminimap.inc:5-7` `cMinimapSize = 240`, `cMinimapOffsetX = -8`, `cMinimapOffsetY = -8`; `:13-15` `cKeyColorSize=3`, `cBorderSize=2`, `cOffset=2`.
- `initminimap.inc:17` `_gui_CreateParent('minimap', 0, gc_halParentRightWidth, gc_valParentBottomHeight, -8, -8, 240, 240, True)`; `:16` border material `gc_hud_icons_keycolor + IntToStr(color+1)`; `:22-25` four 2-px key-colour borders.
- `initminimap.inc:29-35` `SetGUIMiniMapHAlign('halLeft')`, `VAlign('valBottom')`, width/height `240*scale`, `SetGUIMiniMapPosition(GetViewerWidth - 240*scale - 8, -8, 0)`, `SetGUIMinimapZoom(1)`, `SetGUIMiniMapLayer(3)`; `:37-39` `SetMiniMapFrustumVisible(true)`, `SetGUIEventStateOnPressMiniMap('EventMinimap')`, visible.
- **DERIVED: the donor minimap sits in the bottom-RIGHT 240×240 box**, left edge ≈ `ViewerWidth - 240*scale - 8`, Y offset −8 from the bottom. Corroboration: `showunitcontrol.inc:109-110` `cParentSizeY = 151`, `cMinimapSizeX = 289`, and `:586` the unit-control parent is `GetViewerWidth - cMinimapSizeX` wide — a 289-px right-hand strip is reserved for the minimap+score. This settles the **[U]** in `docs/research/RE_VISUAL.md:205-208` and confirms W23 item 4's donor side.
- `hud\hud.mat:994-1001` `minimap.background` uses atlas `tex03` (`hud.tex:89-115`), UV `(1768,179)` size `280×279`, `ImageH=512`, linear/nearest filtering.
- `gui\minimap.cfg:28-723` 34 primitives: `lens.0` 40×40 UV `(0.5,0.5)-(1,1)` at `:31-50`; `pl2x2.0…13` 3×3 at `:52-345` plus `pl2x2.sel` at `:346-365`; `pl3x3.0…13` 4×4 at `:367-659` plus `pl3x3.sel` at `:661-680`; `cross1x1` 4×4 at `:682-701`; `ptborder` 4×4 at `:703-722`. UV cell pitch is `0.0625` (1/16) — **OBSERVED**.
- `minimap.cfg:724-759` material `bmTransparency`, `moIgnoreFog`, `moNoLighting`, `image = .\data\hud\textures\primitives.bmp`, `magfilter=maNearest`, `minfilter=miNearestMipmapNearest` — pixel-exact blips (**OBSERVED**).

### 5.3 HUD panels / geometry (OBSERVED)

- Top resource strip: `showresourcepanel.inc:44` `cResourceSizeX = 162`; `:25-26` `cResourceOffY = -7`, `cPopulationOffsetX = 64`; `:21-22` `cButtonOffsetX = 11`, `cButtonOffsetY = 40`. `:48-56` DPI logic (`GetViewerWidth<2520 → dpiscale=1`; `<1260 → width/1260`; `cminwidth=1280`). `:54` parent height = `GetGUITextureHeight('resourcepanel.background')`, width `ViewerWidth/dpiscale`, top-left anchored.
- Resource slot X at `:78-85`: `162*((i mod 6)-1) - 3*162 + 84 + 5`, plus `cSideOffsetX=-10` halved for `i<4` and `+4` otherwise; `:87-90` swaps display indices 1↔2 (wood/food). Text at `:139` uses `gc_font_serif_13`; hover hit rects `resourcehintN` at `:141-144`; hints prefixed `gc_font_sans_13` at `:28-33`.
- Net readout arithmetic: `:101-125` stock string, `income = counter.workersonres[ind]`, for `ind >= gold`: `rawconsume = floor((resconsume[ind]*32/100)/250)`, `income1 = floor(income-rawconsume)`, `income2 = floor(rawconsume)`, darkgrey `(`/`-`/`)` when `income1>=0`, red otherwise. `:102` literal threshold `99999999` vs locale `9999999+` (`gui.txt:251-252`) — the well-known cap mismatch (W23 Q2).
- Population: `:151-201` `farmused>=farm` (with 8 `gc_mapsettings_limit_N` caps), `:163` 142×N hit rect at `(0,5)`, `:164` `icons.nofarm` icon, `:202` text `gc_font_sans_12` at `cPopulationOffsetX=64`. Caps: `dmscript.global:1090-1097` = **500/750/1000/1500/2200/3000/5000/8000**.
- Idle buttons: `:219-229` `_img_idlepeasants/_btn_idlepeasants` at `(3,64+posY)` with `posY = 50` when objectives exist (`:216-218`), serif-14 count, user-blend 1/0.4; `:232-243` mines at `(3,114+posY)`, blend 1/0.5. Event tags `110/111/112` at `:15-17`; `eventresourcepanel.inc:35-36` → `EmulateGUIShortcut('select|idlepeasants'|'select|idlemines')`.
- Menu button: `:425-427` `btnmenu` right-width anchored at `(-1,1)` with `menu.gamemenu` text.
- Unit-control / info panel: `showunitcontrol.inc:7-8` `serif_13/serif_14`; `:46-47` alpha `0.4` insufficient-res / `0.75` failed-requisites; `:49-53` `cIconSize=46`, `cResIconSize=46`, `cIconMarginX=0`, `cIconMarginY=1`, `cMaxControlBtnCount=min((ViewerWidth-270-220-2)/46,35)`; `:54-55` margins `(8,-2)`; `:71` `cSizeY=46*3+1*4=142`; `:109-110` `cParentSizeY=151`, `cMinimapSizeX=289`; `:586` parent `halLeft/valBottomHeight` at `(0,-9)`, width `ViewerWidth-289`, height 151. Rally button at `:1735-1741` uses `cRallyX=6`, `cRallyY=2` (**OBSERVED** at `:1735-1741`).
- World-space HUD: `inithud.inc:14-36` creates `TXGroupHUDCollection` `hud` full-viewport at `(0,0,ViewerWidth,ViewerHeight)`, min/mid/max distance `1/10/(GetMapWidth+GetMapHeight)`, scale distance `1..100`, min scale `0.5` if `gProfile.bfreezoom` else `1`, terrain offset `0`; `:39-61` `envhud` similar but terrain offset `2.0` and max scale distance `300` (**OBSERVED**). This is an in-world 3D HUD layer the port does not reproduce.

### 5.4 Minimap clicks and the camera transform (donor truth)

- `initminimap.inc:38` installs `EventMinimap`; `eventminimap.inc:6-17` consumes `X`/`Y` as **integers** and sets `Tag=10` on LMB down with `gfloat_gui_movecamerax := x`, `gfloat_gui_movecameraz := y`; `:26-34` repeat `Tag=20`; `:37-54` up `Tag=30` (plus RMB `RButton`, `RButtonUp`, `GameManagerCancelBrush`).
- `onmousedown.inc:116-131` (verified in DEEPDEC-08 E2; unchanged here) routes non-double LMB under the minimap to `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)` + `SetMainCameraMoveToTargetXZ(newx,newy)`; double-click uses `_control_MoveCameraToPosition(x,y,0,False)` at `:121-122`.
- `scripts\lib\control.script:574-613` computes the offset: `minHeight=SphereLengthMin=20`, `maxHeight=SphereLength=58` (`camera.cfg:9-10`), `angleZ=-Lerp(minHeightMaxAngle,maxHeightMaxAngle,Clamp((height-minHeight)/(maxHeight-minHeight),0,1))`, `dx=cx-tx`, `dz=0.1`, `VectorRotateX`, `offZ=ArcTan(angleZ)*height`, `angleX=VectorAngle(0,0,1,dx,0,dz)`, `VectorRotateY`, `newX=dstX+offX+dx`, `newZ=dstZ+offZ+dz`. With all four angles `-32` (`camera.cfg:32-35`) the tilt is constant (**INFERRED**; `ArcTan` units UNVERIFIED — no donor definition found in `data\scripts`).
- `gui\common.inc\onmousewheel.inc:29-47` same offset family for zoom; `:41` `Clamp(height,minHeight,maxHeight)`; `:43-46` force `-32`; `:56` `dstZ=tz+ArcTan(-angleZ)*oldHeight`; `:296-303` `wheelDelta = -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2` then `ZoomCamera(0,…)` → `SetMainCameraMoveToTargetXZ`.
- **Observation on coordinates:** the same minimap `X`/`Y` are written to move-arrow and group-target positions (`onmousedown.inc:618-624`, `:788-801`, DEEPDEC-08 E5) and consumed as **sim metres**, not pixels. `GetCurrentMouseWorldCoord` is likewise world-space (`onmousemove.inc:135`).
- **World→minimap transform:** the engine owns the pixel conversion; the only donor API in readable scripts is `SetGUIMiniMapPrimitivePosition(primHnd, GetGameObjectPositionXByHandle(goHnd), GetGameObjectPositionZByHandle(goHnd))` at `scripts\lib\misc.script:1107-1108`, `:1125-1127` and `scripts\common.inc\dogenerate.inc:422-423`, `:1946-1947`; alarm lens uses `round(px), round(pz)` at `scripts\lib\miscext2.script:260-270`. No donor script states the scale factor, so:
  - **DERIVED (engine projection assumed linear, UNVERIFIED internally):** minimap pixel `≈ (world_x / (map_tiles * 53.3333333)) * 240`, using `minimap.cfg:2-5` 240 px and `dmscript.global:172` 53.3333333 px/tile, `gc_MaxMapWidth/Height=640` (`:132-133`). Map sizes `256/320/480/640` come from `donewgame.inc:43-46`.

    | Map tiles | minimap px/tile | px/metre (2 m/tile) |
    |---|---|---|
    | 256 | 0.9375 | 0.46875 |
    | 320 | 0.75 | 0.375 |
    | 480 | 0.5 | 0.25 |
    | 640 | 0.375 | 0.1875 |

  - **OBSERVED** blip footprint in the 240-px image: `pl2x2.*` 3×3, `pl3x3.*` 4×4 (`minimap.cfg:52-680`), i.e. 3–4 minimap pixels per entity regardless of map size.
  - **OBSERVED** map-generation `cMapSize = 640` (`donewgame.inc:6`, `dogenerate.inc:447`) matches `gc_MaxMapWidth`.
- Primitive colour keying: `scripts\lib\misc.script:1028-1041` picks `pl3x3.<color>` for buildings, `pl2x2.<color>` for units, `<.sel>` variants when selected; player-index 0..15 ↔ HUD material `icons.keycolor.1..16` (`initminimap.inc:16`, `hud.mat:1701-1877 (1..16 at :1701-1866 plus `.sel` at :1877)`, `dmscript.global:122` `gc_MaxKeyColorCount=24`, `:121` `gc_MaxColorCount=13`). Mine blips use `pl2x2.4` (`dogenerate.inc:422`); geology crosses `cross1x1` and peace border `ptborder` (`misc.script:1095-1129`).

---

## 6. Selection UI elements

### 6.1 Drag-selection rectangle — donor definition found

- `resources\resource.lib:47` `SelectionBrushFileName = .\data\brushes\selection.cfg`; also `StretchBrushFileName = stretch.cfg` (`:48`) and `ArrowBrushFileName = arrow.cfg` (`:49`).
- `brushes\selection.cfg:2-14` (verified twice via numbered dump and `read` tool): `LineSetup.AntiAliased=False`, `LineColor=(1,1,0,1)` **yellow**, `LinePattern=65535`, `LineWidth=1`, `Visible=True`, `LineStep=1`. **OBSERVED.** This is the first concrete donor geometry/style record for the selection rectangle (prior docs called it UNVERIFIED/engine-only).
- The rectangle is still **engine-driven**: `menu.cfg:17-18` no begin/end hooks, `onmousedown.inc:365` `gbool_gui_isselectionstarted := false` on up, `:377-379` `GameManagerIsSelectionMode` → `GameManagerCancelSelection`; `onmousemove.inc:142-162` records the previous world point, threshold `epsilon=0.005` (`:32`; `0.25` in guard/attack-point mode at `:33-34`), then calls `GameManagerBeginSelection` + `GameManagerStartSelection`. Shift adds (`spmAdd`); `spmRemove` is commented out (`:159-161`). x/z are world metres from `GetCurrentMouseWorldCoord` (`:135`).
- Selection **rings/highlights** are separate brush materials: `brushes\brushes.mat:199-260` `selection.friend` diffuse `(1, 0.9451, 0.713725, 0.65)`, `selection.building.0/.1` alpha `0.65/0.85` (small texture), `.2/.3` alpha `0.65/0.85` (large), `selection.ship.0/.1` alpha `1`, `selection.enemy`; `scripts\lib\gui.script:3372-3377` names `selection.friend/building/ship` and `highlight.friend/ally/enemy`.

### 6.2 Unit info panel

Covered in §5.3 (`showunitcontrol.inc:49-110,586`): 46-px icon grid, 151-px bottom-left panel spanning `ViewerWidth-289`, tag vocabulary at `:73-106` (`cTagRally=50`, `cTagControlPatrol=305`, squad formations 312-314, officer size 320-321, unload 322). Filtering is in `onselection.inc:10-53` (`_control_GetSelectionInfo(building,unit,water,nonGuard)`; units/water/buildings mutually exclusive; guards dropped when non-guard units exist) and `:60-90` squad collapse; flags at `:24-28` peasant/water/drummer/officer/bagpiper. Selection refresh: `doupdateselection.inc:7-17` adds selected handles to `gGuiUpdateHighlights`, forces unit control, updates highlights.

### 6.3 Rally flag

- `showrallypoints.inc:5-16` destroys all prior `gc_basename_rallypoint` objects on `gc_playerind_misc`; `:18-31` for every selected object with `brally` and `bcansetrally`, creates `CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_misc, gc_basename_rallypoint, rallyx, 0, rallyy)` then `_misc_CreateEffectZTest(goHnd, False)`; `:33-46` repeats for selected water squads. **The flag is a 3D game object, not a 2D GUI sprite.**
- `onmousedown.inc:8-18` `SelectedUnitsSetRallyPoint(x,z)` calls `_unit_SetRallyPoint(goHnd,x,z,true,true)`, sets `gbool_gui_update_rallypoints := True` and clears rally mode.
- `eventunitcontrol.inc:38,555-558` tag `50` sets `gbool_gui_setrallypointmode := True`; `doupdatecursor.inc:24-25` switches to `crSetRallyPoint`.
- Asset chain: `actors\misc\rallypoint.actor:2-4` mesh `rallypoint.osm`; `objects\misc\rallypoint.prop:4-21` `CustomName/BaseName=rallypoint`, `DefaultScale=0.0525`; `materials\misc\rallypoint.dds` (binary DDS, not decoded) — **OBSERVED** file paths and text config; DDS pixels **UNVERIFIED** (not decoded, not copied).
- Cursor `crSetRallyPoint` is `cursors.lib:161-167` index 8, **FileIcon = default.bmp** (no dedicated raster) — **OBSERVED**.

### 6.4 Build ghost

- Ghost is an engine dummy + blink: `onshortcut.inc:283-286`, `eventunitcontrol.inc:490-496`, `eventaiassistantadvices.inc:125-128` call `_player_CreateConstructionDummyBySID(miscplhnd, cid, sid, mx, mz)` and `_unit_DoConstructionBlinkGameObject(gint_gui_pickedbldhnd, gc_gui_blinkmode_canbuild, False, False)`; wall mode via `gWallCluster.SetWallBuildMode(...)` (`eventunitcontrol.inc:496`). No donor script defines ghost colour or size — **UNVERIFIED**.
- Cursor `crConstruct` = `cursors.lib:152-160` index 7, `construct.bmp`, hotspot `(1,1)`; cancellation `eventresourcepanel.inc:23-24` `_misc_GUICancelBuilding(True,False)`, `eventminimap.inc:53` `GameManagerCancelBrush`.
- Placement snap in editor: `onmousemove.inc:111-112` `x := floor(x*2)/2+0.25` (0.5-tile grid, +0.25 centre) — **OBSERVED**, but editor-only, not the skirmish ghost.

### 6.5 Cursor vocabulary (selection-related, OBSERVED)

`cursors.lib`: `crDefault` 1 (`:5-12`), `crPress` 2 (`:106-115`), `crAttack` 3 hotspot `(2,3)` (`:117-123`), `crGainFood/Wood/Stone` 4/5/6, `crConstruct` 7, `crSetRallyPoint` 8, `crGoInside` 9, `crPatrol` 10, `crNotGuard` 11, `crGuard` 12, `crWait` 13 hotspot `(15,15)`, `crArtillery` 14, `crCapture` 15, `crCaptureAttack` 16 **64×64** hotspot `(2,8)`, `crScrollLeft/Right/Top/Bottom` 24-27, four corners 28-31 (`:240-295`). Selection state machine `doupdatecursor.inc:4-106` picks among them (`crCapture`/`crCaptureAttack` at `:65-75`, `crGain*` at `:78-85`, `crConstruct`/`crGoInside` at `:92-97`).
OS cursor hotspots (Windows CUR `type=2`, 1 image, 32×32, DIB 32×64 24-bpp, image offset `0x16`): `bottom.cur:0x0A-0x0D` `(15,24)`, `bottom.left.cur` `(5,26)`, `bottom.right.cur` `(26,25)`, `left.cur` `(7,15)`, `right.cur` `(24,15)`, `top.cur` `(15,7)`, `top.left.cur` `(5,5)`, `top.right.cur` `(25,6)` — **OBSERVED** via `struct.unpack_from`, cross-checked with hex.

---

## 7. Corrections to prior docs

| # | Prior claim | This record | Status |
|---|---|---|---|
| C1 | `docs/research/RE_VISUAL.md:205-208` donor minimap corner **[U]** | Bottom-**right** strip established at `initminimap.inc:17,33` + `showunitcontrol.inc:109-110,586` | **CORRECTED** (file evidence, no screenshot needed) |
| C2 | `DEEPDEC_08_ui_minimap.md:168` minimap "240×240 bottom-left" (§3 row says port left/donor 240) and W23 item 4 "bottom-right 240 px vs port bottom-left 200 px" | Donor is right-anchored; W23's donor side is right, DEEPDEC §3 wording "bottom-left" for donor is imprecise | **CORRECTED** in favour of W23 + donor files |
| C3 | `DEEPDEC_08_ui_minimap.md:177-179,278` selection rectangle geometry "engine-side, UNVERIFIED" | Engine-side still true, **but** `resources/resource.lib:47` + `brushes/selection.cfg:2-14` give the outline style (yellow, 1 px, solid, step 1) | **PARTIALLY CORRECTED** — style now known; drawn polygon still engine-side |
| C4 | `V717_hud3d_adapter.md:37-56,69-75` box mapping `int(world/TILE_M)` with **no** half-map offset and donor frustum UNVERIFIED | Current `hud3d_adapter.gd:57-62` adds `Vector2(mw,mh)*TILE_M*0.5` (PLAY2FIX-NAVBOX); V717 report predates that fix | **SUPERSEDED** by current port file (donor truth still only `FrustumVisible=True` + `SetMiniMapFrustumVisible(true)`) |
| C5 | `camera3d.gd:354` comment says `get_viewport_corners()` returns "metres, top-left map origin" | `camera3d.gd:435-436` and `hud3d_adapter.gd:57-61` say **CENTRED**; adapter adds half-map. Comment is stale | **PORT DOC BUG** (secondary; do not used the stale comment as truth) |
| C6 | `DE_AUDIO_UI.md:20` "455 `.inc`" (133 menu + 3 common) | Whole-tree count is **313** `.inc` (133 + 3 + 177 under `scripts\`); two independent counts | **CORRECTED** |
| C7 | `DE_AUDIO_UI.md:19` locale inventory "1,093 `.lng` + 1 `.loc` + 1,086 `.txt`" | Whole `data\` tree: **1,093 .lng, 1 .loc, 1,086 .txt** ✔; `data\locale\` alone: **1,082 .txt** (4 `.txt` live elsewhere) | **CONFIRMED**, with scope clarification |
| C8 | `DEEPDEC_08_ui_minimap.md:22` `minimap.cfg:2-27,28-723,724-816` | Confirmed exactly: 818 lines; 34 primitives; material ends at `:816-818` | **CONFIRMED** |
| C9 | `W23_hud_fidelity.md:28` `9999999+` cap, donor script threshold 8 digits | `showresourcepanel.inc:102` `not … > 99999999` and `gui.txt:251-252` `9999999+` both confirmed | **CONFIRMED** (donor inconsistency stands) |
| C10 | `V767_hud_minimap_jump.md:135-137` donor double-click unimplemented in port | `eventminimap.inc:41-43` (Tag 30 up) and `onmousedown.inc:121-122` (double path) reconfirmed; port `hud.gd:1402-1454` has one jump path | **CONFIRMED GAP** |

---

## 8. Port implications (SECONDARY comparison; donor truth primary)

Files read: `variant3d/scripts/hud.gd`, `variant3d/scripts/hud3d_adapter.gd`, and minimal supporting `camera3d.gd`, `world3d.gd`, `world3d_fx.gd`, `world.gd`, `input_controller.gd`. Line numbers are current as of this report.

| Donor truth (cite) | Port state (cite) | Verdict / implication |
|---|---|---|
| Minimap 240×240, bottom-right, 2-px player-colour border, layer 3, zoom 1 (`initminimap.inc:5-7,16-39`; `minimap.cfg:2-15`) | `hud.gd:1376-1398` 200×200, `anchor_left=0`, bottom-left, panel `(4,-212,234,0)` | **WRONG SIDE + SMALLER.** W23 item 4 closed only by changing `uitest.gd:306-307` and re-partitioning `hud.gd:244-273`; 289-px right strip would be needed |
| Minimap image 240×240 fixed, blips 3×3/4×4 (`minimap.cfg:2-6,52-680`) | `hud.gd:1356-1375` image is `MAP_W×MAP_H` (1 px/tile), widget 200×200; blips 1–2 px (`hud.gd:1514-1526`) | **APPROXIMATED.** Blip density/scale differs per map size; donor atlas UVs not reproduced |
| Minimap press LMB down/repeat/up with distinct double-click (`eventminimap.inc:8-55`; `onmousedown.inc:116-131,121-122`) | `hud.gd:1402-1426` press/drag via `jump_to_world`; `_minimap_jump_3d` `:1433-1443`; no `bDouble` branch | **GAP P1.** Double-click instant jump (`control.script:618-665`) still missing |
| Camera target preserves pre-existing offset (`control.script:595-612`) | `camera3d.gd:463-480` `jump_to_world` sets SIM target directly; no `cx-tx`, `dz=0.1`, `ArcTan*height` | **DIVERGENT** (already in DEEPDEC-08 §2); no invented constant — translate donor formula behind a flag |
| Frustum visible, white 1-px solid (`minimap.cfg:4,16-27`; `initminimap.inc:37`) | `hud.gd:1462-1500` paints 1-px white AABB via `_mm_paint_box:1502-1512`; `hud3d_adapter.gd:37-82` four-corner AABB | **PARTIAL.** Rotation/quad geometry donor-side is engine-only, still **UNVERIFIED**; adapter now corrects centred→SIM at `:57-62` |
| Selection rectangle: yellow 1-px solid outline (`brushes/selection.cfg:2-14`), engine drag (`onmousemove.inc:142-162`) | `world3d.gd:126` declares `sel_rect` only; `input_controller.gd:1164-1172` writes it; `world.gd:3642-3647` (2D) draws white `Color(1,1,1,0.9)`/`0.18` — **no 3D draw** | **GAP P2 — selection rectangle missing in 3D.** Donor shape/colour now known; no new constant needed: project `sel_rect` through `camera3d.world_to_px()` into a `CanvasLayer` |
| Selection rings `selection.friend (1,0.9451,0.713725,0.65)`, building alpha 0.65/0.85, ship 1 (`brushes.mat:199-260`) | `world3d_fx.gd:387-430` procedural rings in **player colour**, no donor texture | **APPROXIMATED** (no donor asset copied). Colour/alpha parity untested |
| Rally flag = 3D object `rallypoint` scale 0.0525 roll 45 (`showrallypoints.inc:18-31`; `rallypoint.prop:19-25`) | `world3d_fx.gd:362-376` procedural pole+pennant; `world3d.gd:463-498` ghost/rally sync | **APPROXIMATED**; donor `.dds` deliberately not copied |
| Build ghost = engine dummy + `gc_gui_blinkmode_canbuild` (`onshortcut.inc:283-286`; `eventunitcontrol.inc:490-496`) | `world3d_fx.gd:338-359` translucent green/red footprint; `world3d.gd:463-498`, input `:1173-1177` | **SEMANTIC PARITY**; donor colour/geometry **UNVERIFIED** |
| Top strip 6 resources, net `(income-consume)`, hints, idle buttons (`showresourcepanel.inc:44-144,219-243`) | `hud.gd:104-116` RES_TOOLTIPS/cap, `:347-415` icons, `:471-481` idle buttons (per W23) | **PARITY (semantic)**; donor locale strings are condensed, not verbatim (W23 Q3) |
| Population caps 500…8000 (`dmscript.global:1090-1097`) | port pop default 200 (`docs/research/RE_VISUAL.md:157`, port-doc inference) | **DIVERGENT**; HUD population readout will not match donor at scale |
| Key-colour border 16 materials (`hud.mat:1701-1877 (1..16 at :1701-1866 plus `.sel` at :1877)`), `gc_MaxColorCount=13` (`dmscript.global:121-122`) | `hud.gd:144-151` `MM_PLAYER_COLORS` has **12**, `wrapi` fallback | **PARTIAL**; donor has 13 playable colours + 16 key materials |
| 11 locales, `.lng` binary tables, `lang.loc` codepage map | no locale layer; strings hardcoded English (`DE_AUDIO_UI.md:19`, W23) | **GAP P2.** `.lng` format decoded here (§4.1) makes bulk import feasible; `gui.lng` has 460 records |
| Cursors 16 action + 8 scroll, hotspots (`cursors.lib`; `.cur` offsets §6.5) | 11 cursors in `app/assets/ui/` per `DE_AUDIO_UI.md:21` | **PARTIAL**; `crSetRallyPoint` donor reuses `default.bmp`, so a dedicated port cursor would be a (harmless) extension |
| World-space HUD collections (`inithud.inc:14-61`) | no equivalent in `variant3d` | **GAP P3** (in-world resource/building labels); donor distance/scale constants available |

**Highest-value, donor-grounded fixes:** (1) render the 3D drag-selection rectangle using `brushes/selection.cfg:4-11` values; (2) move/resize the minimap to the donor's bottom-right 240×240 slot and re-partition the bottom strip; (3) add the donor double-click minimap branch; (4) import `gui.lng` (460 records) + `needloc/misc.txt` as a keyed locale layer.

---

## 9. Open questions

1. **Engine projection internals** — the linear world→minimap scale table in §5.4 is **DERIVED**, not stated by any donor script. Runtime A/B (or engine-side decompilation of `SetGUIMiniMapPrimitivePosition`) is needed to confirm whether the engine always stretches the full map extent into 240 px, and how zoom (`SetGUIMinimapZoom(1)`) interacts.
2. **Frustum shape** — `FrustumVisible=True` (`minimap.cfg:4`) but `FrustumLineStyle.Visible=False` (`:26`); whether the visible frustum is a rotated quad, an AABB, or a lens-style marker remains **UNVERIFIED**.
3. **`ArcTan` / `VectorRotate*` units** — no donor definition found; the numeric minimap-click offset cannot be asserted (also DEEPDEC-08 §2 Q).
4. **461 vs 460** — one `gui.txt` key is absent from compiled `gui.lng`; identity not established (no compile/binary diff performed).
5. **`selection.cfg` scope** — the file is a global `SelectionBrushFileName` and is referenced by all 40 mission maps, but whether the yellow outline is used for the drag rectangle *and/or* the picked-object border is an engine-side detail; style is OBSERVED, assignment is **INFERRED**.
6. **DDS pixels** — `materials\misc\rallypoint.dds` and `brushes\textures\selection.*.dds` were not decoded (binary, private-use, not copied); exact flag/ring raster remains **UNVERIFIED**.
7. **Port stale comment** — `camera3d.gd:354` vs `:435-436` should be reconciled by that file's owner; this report only records it.
8. **Donor `envhud`** — world-space HUD labels exist (`inithud.inc:39-81`); whether they appear on minimap or only over units/resources in 3D is **UNVERIFIED** without a screenshot.

---

## 10. Evidence index

**Donor (read-only, `C3\data\`):**
- `gui\menu.cfg:2-34`; `gui\menu.aix:1-6,159-163,211-221,246-263,316-326`.
- `gui\menu.inc\initminimap.inc:5-39`; `gui\minimap.cfg:2-27,28-723,724-818`.
- `gui\menu.inc\showresourcepanel.inc:15-56,76-145,151-202,216-243,245-427`; `eventresourcepanel.inc:16-42`.
- `gui\menu.inc\showunitcontrol.inc:7-110,586,1735-1741`; `eventunitcontrol.inc:38,490-496,555-558`; `doupdatecursor.inc:4-106`; `showrallypoints.inc:5-46`; `onmousedown.inc:5-18,116-131,260-400,445-901`; `onmousemove.inc:32-34,135-162`; `onselection.inc:10-90`; `doupdateselection.inc:4-17`; `inithud.inc:14-81`; `donewgame.inc:6,41-48`; `cameracontrol.inc:12-35`.
- `gui\common.inc\onmousewheel.inc:25-80,288-305`.
- `scripts\lib\control.script:574-613,618-665`; `scripts\lib\misc.script:1017-1172`; `scripts\common.inc\dogenerate.inc:416-462,1942-1947`; `scripts\lib\miscext2.script:258-272`; `scripts\lib\gui.script:3372-3400`; `scripts\dmscript.global:3,97-135,170-173,1089-1108,1199-1224`; `scripts\lib\classes.script:4539-4560,4707-4731`.
- `resources\resource.lib:47-49`; `brushes\selection.cfg:2-14`; `brushes\brushes.mat:199-260`; `actors\misc\rallypoint.actor:2-4`; `objects\misc\rallypoint.prop:4-25`; `materials\misc\rallypoint.dds` (path only).
- `cursors\cursors.lib:5-12,106-295`; `cursors\textures\cur\*.cur:0x00-0x25`.
- `hud\hud.mat:994-1001,1701-1877,3219-3426`; `hud\hud.tex:89-115,205-240`; `hud\font.lib:1`; `hud\font1251.lib:1-60`; `hud\textures\primitives.bmp:0x00-0x1F`; font atlas BMPs `:0x12/:0x16/:0x1C`.
- `locale\en\gui.txt:1-937` (keys in §4.3); `locale\en\gui.lng:0x00-0x5B`; `locale\needloc\misc.txt:21,23,251-255`; `locale\needloc\new.txt:43-50,347-348`; `locale\lang.loc:2-61`; `locale\en\table.lng:0x00`; `locale\en\tooltip.lng:0x00`.
- `cameras\camera.cfg:6-10,30-40,44-57`.

**Port (secondary, `ROOT`):** `variant3d\scripts\hud.gd:104-116,144-155,244-273,347-415,471-481,1340-1404,1405-1454,1462-1512,1514-1831`; `hud3d_adapter.gd:21-82,85-109`; `camera3d.gd:13-16,188-198,218-252,266-290,354-362,435-480`; `world3d.gd:126,463-498,784-786`; `world3d_fx.gd:338-430`; `world.gd:3642-3647`; `input_controller.gd:1159-1177`.

**Prior docs:** §2 table (all read in full before donor work). **Findings:** `investigation.cany\investigation\findings.md:3` (`fnd_1`) corroborated by `scripts\dmscript.global:170-173`.

---

## 11. Summary

Donor UI truth is now anchored in readable data: a 142-state `menu.aix`/`menu.cfg` state machine; a **bottom-right 240×240** minimap with player-colour border, layer 3, zoom 1, frustum on, and a 34-primitive nearest-filtered atlas; a top 162-px-per-slot resource strip with donor net `(income-consume)` arithmetic and locale-backed hints; a 151-px bottom-left unit panel with a 46-px icon grid; an in-world HUD collection layer; a yellow 1-px selection brush; a 3D rally-point game object; and an engine construction-dummy build ghost. Localization is a **460-record binary `.lng`** format with a tab-key `.txt` source, 11 languages via `lang.loc`, and English `misc` strings in `needloc`. World→minimap is engine-side; the linear scale (0.75 px/tile at 320 tiles) is derived, not donor-stated.

The port matches semantics for resources and minimap clicks but diverges in **placement** (bottom-left 200 px vs donor bottom-right 240 px), **blip scale**, **double-click jump**, **population caps**, and **locale absence**. The two task-critical items are: the **3D drag-selection rectangle is not drawn** (`world3d.gd:126` only holds data), and the **minimap camera box is an AABB** whose donor frustum shape remains UNVERIFIED; the adapter's centred→SIM correction (`hud3d_adapter.gd:57-62`) is present and a stale comment at `camera3d.gd:354` should be fixed. No donor file was copied or executed; no code was changed.
