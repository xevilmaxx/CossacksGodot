---
id: X56-PLATEAU-GENERATOR-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X56 — locate and decode plateaugenerator2.inc and sibling plateau scripts (read-only)"
title: "X56 — plateau generator DScripts are editor-authoring states, not skirmish terrain stages: DEFERRED"
agent: "X56 (read-only donor-text worker, DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY_EXECUTED__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X56_plateau_generator.md
labels: [O, D, I, U, "PORT APPROXIMATION", DEFERRED]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed. 'Read' means bytes were read from disk read-only; quoted lines are DScript [*]=; comment-encoded source, not proof that any line executes in the shipped skirmish path."
scope_guard: "Exactly one repo file written (this report). Donor at C:\\Games\\Cossacks 3 opened read-only (Get-ChildItem, rg, python open('rb')); no donor file written, copied or executed; no source/shader/config/asset/test/git/Godot-runner state touched."
sources_read: "CHARTER.md; reports/X33_donor_text_coverage.md; reports/X03_dscript_corpus.md; reports/D05_relief_stamp.md; reports/A02_algorithm.md; spec/04_PATTERN_STAMPING.md; donor scripts\\editor.inc\\plateaugenerator{1,2,3}.inc, scaleplateauterrain.inc, generatemapfrombitmap.inc, scripts\\editor.aix, data\\scripts\\common.aix, data\\scripts\\common.inc\\{dogenerate,generatemap}.inc, data\\pattern\\pattern.lib (targeted), data\\gen\\globalparams.cfg (grep), both EXEs (read-only string scan)."
passes: "P1 locate by filename; P2 read all four plateau states in full; P3 rg call-site census over 7 text extensions in the whole donor tree; P4 read dogenerate.inc/generatemap.inc/generatemapfrombitmap.inc contexts; P5 read editor.aix + common.aix registration; P6 read-only byte scan of cossacks.exe and editor.exe for state names, native signature and aix path; P7 pattern.lib section lookup for every pattern named by the scripts; P8 contradiction reconciliation vs task path, X33 inventory, D05 and spec §04."
---

# X56 — Plateau generator scripts decoded: editor-only, DEFERRED

## 0. Executive summary

1. **[O] Location contradiction with the ticket.** The ticket says the scripts are
   under `C:\Games\Cossacks 3\data\scripts\**`. A filename walk of that tree
   returned **zero** `plateau*` files. All four plateau states live under
   **`C:\Games\Cossacks 3\scripts\editor.inc\**`** — the second tree in X33 E1/E2
   (`data\scripts\**` = 222 files, `scripts\editor.inc\**` = 142 files). This is
   exactly the X33 §4.1 "12 editor `.inc` files / 26,146 B, NEEDS READ, editor
   algorithms (plateau grid, terrain data save/load, collision tools)" bucket.
   Files read: `plateaugenerator1.inc` (13,803 B, 305 lines),
   `plateaugenerator2.inc` (13,844 B, 316 lines),
   `plateaugenerator3.inc` (2,132 B, 51 lines),
   `scaleplateauterrain.inc` (2,239 B, 51 lines).
2. **[O] `plateaugenerator2.inc` is a DScript *state*** (`Name = PlateauGenerator2`,
   lines 1–3), not a function of the generation pipeline. It builds an 80×80
   integer grid (`cSize=4`, 320/4), fills it with **hardcoded cell literals**,
   runs a hand-written 4-neighbour cell-classifier (`CalcPlateau`, lines 73–191),
   and stamps a handful of `box_4x4_*` / `box_4x4_l` patterns (`DrawPlateau`,
   lines 25–71). It contains a debug `if (x=9) and (y=8) then log('a');`
   (lines 76–77) and ends with `GUIMiniMapUpdate;` (line 313). There is **no RNG
   draw, no seed, no `generator.cfg` weight, no mask read** anywhere in it.
3. **[O] No skirmish call site exists.** Across the seven donor text extensions,
   `ExecuteState('PlateauGenerator1/2/3')` occurs **nowhere**. The only
   occurrences of the three state names are their definitions and their
   registrations in `scripts\editor.aix:621–630, 687–690`. The sole
   `ExecuteState('ScalePlateauTerrain')` (editor
   `generatemapfrombitmap.inc:334`) is gated by
   `const cScalePlateauTerrain = False; // disabled` (line 98, re-checked line
   331). The game-side `PlateauTerrain` calls are either inside a fully
   `{...}`-commented block (`dogenerate.inc:467–478`) or inside the
   **`else` of `if (bRandomMap)`** (`generatemap.inc:261–280`).
4. **[O] Binary pass corroborates.** The strings `PlateauGenerator1/2/3` and
   `ScalePlateauTerrain` occur **zero times** in both `cossacks.exe` (5,768,048 B)
   and `editor.exe` (7,874,416 B), so no engine-side hardcoded dispatch. The
   native `PlateauTerrain` exists in both, with signature recovered at
   `cossacks.exe` file offset `2,764,438` decimal:
   `procedure PlateauTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const reproduce: Boolean)`.
5. **[O] The `box_*` pattern names do not exist in the donor data.** Zero
   `box_` substrings in the 30 MB `pattern.lib`, zero `box*` `.pattern` files,
   and no occurrence outside these two scripts. `PlateauGenerator1/2` therefore
   reference undefined pattern sections; `PlateauGenerator3` uses real editor
   brushes (`brush_plt_*`, eight sections in `pattern.lib:2–318`) with
   `HeightFieldScale = -0.925000011920929` and
   `HeightFieldMin = HeightFieldMax = 3.20392155647278`.
6. **[D] Verdict: DEFERRED.** These states are editor-authoring/debug tools, not
   inputs to spec §04's skirmish stamping stage. No plateau parameter from them
   may enter the port. The skirmish plateau rule stays as already specified:
   mask class `cRPlateau` / `cPlateauHeight = 2.964` (D2:4, :570) and the
   `plateau`, `plateau_small`, `plateau_big` families of `generator.cfg:581/606/635`
   stamped via D05's three blend paths. **§5 gives ready-to-paste replacement
   text for spec §04.**
7. **[I]/[U] Honest limit.** `scripts\editor.aix` is a path string present in
   *both* EXEs (cossacks.exe file offset `5,039,880` decimal, editor.exe file
   offset `6,433,548` decimal), so
   "only editor.exe can ever load this manifest" is **not** proven by text
   alone. What *is* proven: no skirmish call site, no hardcoded engine
   reference, editor-manifest registration only, debug code and undefined
   pattern names. No parity claim is made.

---

## 1. Evidence table

| Id | Source (donor, read-only) | Establishes | Label |
|---|---|---|---|
| E1 | filename walk `data\scripts\** -Filter *plateau*` | 0 files — ticket path is wrong | [O] |
| E2 | filename walk `scripts\editor.inc\** -Filter *plateau*` | 4 files, sizes/line counts in §0.1 | [O] |
| E3 | `plateaugenerator2.inc:1–316` (quoted in full, §2.2) | state name, cSize 4, 320², 80×80 grid, 14 cell codes, hardcoded cells, two procedures, `PlateauTerrain(-30,0,False,(GetMapHeight div 2)-1+32,True)`, `GUIMiniMapUpdate`, debug `log('a')` | [O] |
| E4 | `plateaugenerator1.inc:1–305` | same design with `cSize = 17` (→ 18×18), `box_c3` family, one live `StandPattern` at :140 | [O] |
| E5 | `plateaugenerator3.inc:1–51` | brush-line tool: `PlateauTerrain(0,0,False,r,True)`, `PaintTerrain(...)`, 8 brush constants, `DrawLineWithPattern` | [O] |
| E6 | `scaleplateauterrain.inc:1–51` | editor height post-pass: `cMaxHeight=3.2`, band `0.05..2.5`, `Lerp(...,random)`, `Pow(...,1.25)`, `Clamp(0,3.2)` | [O] |
| E7 | `scripts\editor.aix:620–630, 686–690, 721–725` | four states registered with `UsedFile=True` under `.\scripts\editor.inc\`; no `LanClientExecute` flag (contrast `data\scripts\common.aix`) | [O] |
| E8 | `data\scripts\common.aix:50–55, 69–74, 76–88, 111–123` | skirmish states `DoGenerate`, `GenerateMap`, `PostProcess`, `TextureMap`, `SmoothTiles`, `SmoothForestBorders` registered with `LanClientExecute=True` | [O] |
| E9 | whole-tree `rg` over `.inc/.script/.global/.source/.aix/.cfg/.txt/.mat/.lib` | zero `ExecuteState('PlateauGenerator…')`; only `generatemapfrombitmap.inc:334` calls `ScalePlateauTerrain` and it is gated `False` | [O] |
| E10 | `dogenerate.inc:467–478` | `PlateauTerrain(0,0,False,r,True)` inside `{...}` comment block — dead | [O] |
| E11 | `generatemap.inc:257–280` | `if (bRandomMap) then ResetPatternMap(False) else begin PlateauTerrain(...); … end` — non-random branch only | [O] |
| E12 | `generatemapfrombitmap.inc:98, 112–120, 331–336` | editor state `GenerateMapFromBitmap_OLD`; `cScalePlateauTerrain = False // disabled` | [O] |
| E13 | read-only byte scan both EXEs | 0 hits for the four state names; `PlateauTerrain` native present in both; signature string at cossacks.exe file offset `2,764,438` decimal; `scripts\editor.aix` path string in both | [O] |
| E14 | `pattern.lib:2–318` (8 `brush_plt_*` sections, targeted) | `brush_plt_13x13_2:42–78` Scale −0.925, ReplaceForWater True, Smooth True (r1/f4/o1), Min=Max=3.20392155647278; `brush_plt_1x1:202–238` Scale −0.925, Smooth False; `brush_plt_1x1_mid:282–318` Scale 1.17499995231628, Min=Max=2.18083715438843 | [O] |
| E15 | `rg 'box_' pattern.lib` + `Get-ChildItem data\pattern -Filter box*` + whole-tree text `rg` | zero `box_` in `pattern.lib`; zero `box*` `.pattern` files; `box_*` names occur only in plateau generator 1/2 | [O]/[D] |
| E16 | X33 §4.1 / E2 | these 4 files were in the "NEEDS READ, editor algorithms" residual, not in X03's 8 full reads | [O] (inherited) |
| E17 | X03 §5h / D2:507; X03 §2 Stage 2 | `if (not bRandomMap)` guard on PostProcess; consistent with the non-random gating found at E11 | [O] (inherited) |
| E18 | `spec/00_EVIDENCE_INDEX.md:209` | Already classifies `scaleplateauterrain.inc:4-43` alongside `generatemapfrombitmap.inc` as "Editor states distinct from skirmish; editor-only debug and brush constants" — independent corroboration of this report's verdict; no spec contradiction found | [O] (inherited) |

---

## 2. Full verbatim routine and siblings

### 2.1 Method note

Every line below is `latin-1`-decoded donor source with its original 1-based line
number prefixed as `L<n>:`. The `[*] = ;` marker is how DScript stores script
code as an in-file comment; curly `{...}` and `//` are also DScript comment
forms. **Quoted ≠ live**: §3 determines what, if anything, calls these states.

### 2.2 `C:\Games\Cossacks 3\scripts\editor.inc\plateaugenerator2.inc` — full file (316 lines)

```text
L1: section.begin
L2:    Name = PlateauGenerator2
L3:    Code : struct.begin
L4:       [*] = ;const cSize = 4;
L5:       [*] = ;const cMapWidth = 320;
L6:       [*] = ;const cMapHeight = 320;
L7:       [*] = ;const cMapW = (cMapWidth div cSize);
L8:       [*] = ;const cMapH = (cMapHeight div cSize);
L9:       [*] = ;const cNone = 0;
L10:       [*] = ;const cExists = 1;
L11:       [*] = ;const cLeft = 2;
L12:       [*] = ;const cTop = 3;
L13:       [*] = ;const cRight = 4;
L14:       [*] = ;const cBottom = 5;
L15:       [*] = ;const cCornerLT = 6;
L16:       [*] = ;const cCornerRT = 7;
L17:       [*] = ;const cCornerLB = 8;
L18:       [*] = ;const cCornerRB = 9;
L19:       [*] = ;const cLT = 10;
L20:       [*] = ;const cRT = 11;
L21:       [*] = ;const cLB = 12;
L22:       [*] = ;const cRB = 13;
L23:       [*] = ;var platarray : array[0..cMapW-1] of array[0..cMapH-1] of Integer;
L24:       [*] = ;var ind : Integer;
L25:       [*] = ;procedure DrawPlateau(const x, y : Integer; bDrawExist : Boolean);
L26:       [*] = ;begin
L27:       [*] = ;   var plhnd : Integer = GetPlayerHandleByIndex(gc_playerind_env);
L28:       [*] = ;   var name : String;
L29:       [*] = ;   if (platarray[x, y]<>cNone) then
L30:       [*] = ;   begin
L31:       [*] = ;      var angle : Float = 0;
L32:       [*] = ;      var xoff, yoff : Integer;
L33:       [*] = ;      case platarray[x, y] of
L34:       [*] = ;         cExists : name := 'box_4x4_c';
L35:       [*] = ;         cLeft : begin
L36:       [*] = ;            name := 'box_4x4_l';
L37:       [*] = ;            xoff := -1;
L38:       [*] = ;         end;
L39:       [*] = ;         cTop : begin
L40:       [*] = ;            name := 'box_4x4_l';
L41:       [*] = ;            angle := 90;
L42:       [*] = ;            xoff := -1;
L43:       [*] = ;            yoff := -1;
L44:       [*] = ;         end;
L45:       [*] = ;         cRight : begin
L46:       [*] = ;            name := 'box_4x4_l';
L47:       [*] = ;            angle := 180;
L48:       [*] = ;            xoff := 0;
L49:       [*] = ;            yoff := -1;
L50:       [*] = ;         end;
L51:       [*] = ;         cBottom : begin
L52:       [*] = ;            name := 'box_4x4_l';
L53:       [*] = ;            angle := 270;
L54:       [*] = ;            yoff := 0;
L55:       [*] = ;         end;
L56:       [*] = ;         {cCornerLT : name := 'box_corner_lt';
L57:       [*] = ;         cCornerRT : name := 'box_corner_rt';
L58:       [*] = ;         cCornerLB : name := 'box_corner_lb';
L59:       [*] = ;         cCornerRB : name := 'box_corner_rb';
L60:       [*] = ;         cLT : name := 'box_lt_1';
L61:       [*] = ;         cRT : name := 'box_rt';
L62:       [*] = ;         cLB : name := 'box_lb';
L63:       [*] = ;         cRB : name := 'box_rb';}
L64:       [*] = ;      end;
L65:       [*] = ;      if ((bDrawExist) and (platarray[x, y]=cExists)) or ((not bDrawExist) and (platarray[x, y]<>cExists)) then
L66:       [*] = ;      begin
L67:       [*] = ;         if (name<>'') then
L68:       [*] = ;         StandPattern(plhnd, name, cSize*(x-1)-(GetMapHeight div 2)+xoff, cSize*y-(GetMapHeight div 2)+yoff, angle*(pi/2)/90);
L69:       [*] = ;      end;
L70:       [*] = ;   end;
L71:       [*] = ;end;
L72:       [*] = ;
L73:       [*] = ;procedure CalcPlateau(const x, y : Integer);
L74:       [*] = ;begin
L75:       [*] = ;   var plhnd : Integer = GetPlayerHandleByIndex(gc_playerind_env);
L76:       [*] = ;   if (x=9) and (y=8)  then
L77:       [*] = ;   log('a');
L78:       [*] = ;
L79:       [*] = ;   var current : Integer = platarray[x, y];
L80:       [*] = ;   var left : Integer = platarray[x-1, y];
L81:       [*] = ;   var top : Integer = platarray[x, y-1];
L82:       [*] = ;   var lefttop : Integer = platarray[x-1, y-1];
L83:       [*] = ;
L84:       [*] = ;   var right : Integer = platarray[x+1, y];
L85:       [*] = ;   var bottom : Integer = platarray[x, y+1];
L86:       [*] = ;   var leftbottom : Integer = platarray[x-1, y+1];
L87:       [*] = ;   if (current=cExists) then
L88:       [*] = ;   begin
L89:       [*] = ;      ind := ind+1;
L90:       [*] = ;      //StandPattern(plhnd, 'box_c3', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L91:       [*] = ;      if (left<>cExists) and (leftbottom=cExists) then
L92:       [*] = ;      begin
L93:       [*] = ;         //StandPattern(plhnd, 'box_lt_1', cSize*(x-1)-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L94:       [*] = ;         platarray[x-1, y] := cLT;
L95:       [*] = ;      end
L96:       [*] = ;      else
L97:       [*] = ;      if (left=cNone) then
L98:       [*] = ;      begin
L99:       [*] = ;         //StandPattern(plhnd, 'box_l', cSize*(x-1)-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L100:       [*] = ;         platarray[x-1, y] := cLeft;
L101:       [*] = ;      end;
L102:       [*] = ;      if (top=cNone) then
L103:       [*] = ;      begin
L104:       [*] = ;         //StandPattern(plhnd, 'box_t', cSize*x-(GetMapHeight div 2), cSize*(y-1)-(GetMapHeight div 2), 0);
L105:       [*] = ;         platarray[x, y-1] := cTop;
L106:       [*] = ;      end;
L107:       [*] = ;      if ((lefttop=cNone) and (left<>cExists) and (top<>cExists)) then
L108:       [*] = ;      begin
L109:       [*] = ;         //StandPattern(plhnd, 'box_corner_lt', cSize*(x-1)-(GetMapHeight div 2), cSize*(y-1)-(GetMapHeight div 2), 0);
L110:       [*] = ;         platarray[x-1, y-1] := cCornerLT;
L111:       [*] = ;      end;
L112:       [*] = ;      if (lefttop=cNone) and (left=cExists) and (top=cExists) then
L113:       [*] = ;      begin
L114:       [*] = ;         //StandPattern(plhnd, 'box_lt_1', cSize*(x-1)-(GetMapHeight div 2), cSize*(y-1)-(GetMapHeight div 2), 0);
L115:       [*] = ;         platarray[x-1, y-1] := cLT;
L116:       [*] = ;      end;
L117:       [*] = ;   end
L118:       [*] = ;   else
L119:       [*] = ;   if (current=cNone) then
L120:       [*] = ;   begin
L121:       [*] = ;      if (left=cExists) and (top=cExists) then
L122:       [*] = ;      begin
L123:       [*] = ;         //StandPattern(plhnd, 'box_rb', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L124:       [*] = ;         platarray[x, y] := cRB;
L125:       [*] = ;      end
L126:       [*] = ;      else
L127:       [*] = ;      if (left=cExists) then
L128:       [*] = ;      begin
L129:       [*] = ;         if (bottom<>cExists) then
L130:       [*] = ;         begin
L131:       [*] = ;            //StandPattern(plhnd, 'box_r', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L132:       [*] = ;            platarray[x, y] := cRight;
L133:       [*] = ;         end
L134:       [*] = ;         else
L135:       [*] = ;         //if (bottom=cExists) then
L136:       [*] = ;         begin
L137:       [*] = ;            //StandPattern(plhnd, 'box_rt', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L138:       [*] = ;            platarray[x, y] := cRT;
L139:       [*] = ;         end;
L140:       [*] = ;         if (top=cNone) then
L141:       [*] = ;         begin
L142:       [*] = ;            //StandPattern(plhnd, 'box_corner_rt', cSize*x-(GetMapHeight div 2), cSize*(y-1)-(GetMapHeight div 2), 0);
L143:       [*] = ;            platarray[x, y-1] := cCornerRT;
L144:       [*] = ;         end;
L145:       [*] = ;      end
L146:       [*] = ;      else
L147:       [*] = ;      if (left=cExists) and (bottom=cExists) then
L148:       [*] = ;      begin
L149:       [*] = ;         //StandPattern(plhnd, 'box_corner_rt', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L150:       [*] = ;         platarray[x, y] := cCornerRT;
L151:       [*] = ;      end
L152:       [*] = ;      else
L153:       [*] = ;      {else
L154:       [*] = ;      if leftbottom=cExists then
L155:       [*] = ;      begin
L156:       [*] = ;         //StandPattern(plhnd, 'box_corner_rt', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L157:       [*] = ;         //platarray[x, y] := cRT;
L158:       [*] = ;      end;}
L159:       [*] = ;      if (top=cExists) then
L160:       [*] = ;      begin
L161:       [*] = ;         if (right=cNone) then
L162:       [*] = ;         begin
L163:       [*] = ;            //StandPattern(plhnd, 'box_b', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L164:       [*] = ;            platarray[x, y] := cBottom;
L165:       [*] = ;         end
L166:       [*] = ;         else
L167:       [*] = ;         if (right=cExists) then
L168:       [*] = ;         begin
L169:       [*] = ;            //StandPattern(plhnd, 'box_lb', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L170:       [*] = ;            platarray[x, y] := cLB;
L171:       [*] = ;         end;
L172:       [*] = ;         if (left=cNone) then
L173:       [*] = ;         begin
L174:       [*] = ;            //StandPattern(plhnd, 'box_corner_lb', cSize*(x-1)-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L175:       [*] = ;            platarray[x-1, y] := cCornerLB;
L176:       [*] = ;         end;
L177:       [*] = ;      end
L178:       [*] = ;      else
L179:       [*] = ;      if ((platarray[x-1, y-1]=1) and (left<>cExists) and (top<>cExists)) then
L180:       [*] = ;      begin
L181:       [*] = ;         //StandPattern(plhnd, 'box_corner_rb', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);
L182:       [*] = ;         platarray[x, y] := cCornerRB;
L183:       [*] = ;      end
L184:       [*] = ;      else
L185:       [*] = ;      if (platarray[x, y-1]=cNone) and (platarray[x-1, y-1]=cTop) then
L186:       [*] = ;      begin
L187:       [*] = ;         //StandPattern(plhnd, 'box_corner_rt', cSize*x-(GetMapHeight div 2), cSize*(y-1)-(GetMapHeight div 2), 0);
L188:       [*] = ;         platarray[x, y-1] := cCornerRT;
L189:       [*] = ;      end;
L190:       [*] = ;   end;
L191:       [*] = ;end;
L192:       [*] = ;
L193:       [*] = ;var plhnd : Integer = GetPlayerHandleByIndex(gc_playerind_env);
L194:       [*] = ;if (plhnd<>0) then
L195:       [*] = ;begin
L196:       [*] = ;   ResetPatternMap(False);
L197:       [*] = ;   PlateauTerrain(-30, 0, False, (GetMapHeight div 2)-1+32, True);
L198:       [*] = ;   {StandPattern(plhnd, 'box_c3', 0, 0, 0);
L199:       [*] = ;   StandPattern(plhnd, 'box_c3', cSize, 0, 0);
L200:       [*] = ;   StandPattern(plhnd, 'box_c3', -cSize, 0, 0);
L201:       [*] = ;   StandPattern(plhnd, 'box_c3', 0, -cSize, 0);
L202:       [*] = ;   StandPattern(plhnd, 'box_c3', 0, cSize, 0);
L203:       [*] = ;
L204:       [*] = ;   StandPattern(plhnd, 'box_t', 0, -cSize*2, 0);
L205:       [*] = ;   StandPattern(plhnd, 'box_b', 0, cSize*2,0);
L206:       [*] = ;   StandPattern(plhnd, 'box_l', -cSize*2, 0,0);
L207:       [*] = ;   StandPattern(plhnd, 'box_r', cSize*2, 0,0);
L208:       [*] = ;
L209:       [*] = ;   StandPattern(plhnd, 'box_lt_1', -cSize, -cSize,0);
L210:       [*] = ;   StandPattern(plhnd, 'box_rt', cSize, -cSize,0);
L211:       [*] = ;   StandPattern(plhnd, 'box_lb', -cSize, cSize,0);
L212:       [*] = ;   StandPattern(plhnd, 'box_rb', cSize, cSize,0);
L213:       [*] = ;
L214:       [*] = ;   StandPattern(plhnd, 'box_corner_lt', -cSize*2, -cSize,0);
L215:       [*] = ;   StandPattern(plhnd, 'box_corner_rt', cSize*2, -cSize,0);
L216:       [*] = ;   StandPattern(plhnd, 'box_corner_lb', -cSize*2, cSize,0);
L217:       [*] = ;   StandPattern(plhnd, 'box_corner_rb', cSize*2, cSize,0);
L218:       [*] = ;
L219:       [*] = ;   StandPattern(plhnd, 'box_corner_lt', -cSize, -cSize*2,0);
L220:       [*] = ;   StandPattern(plhnd, 'box_corner_rt', cSize, -cSize*2,0);
L221:       [*] = ;   StandPattern(plhnd, 'box_corner_lb', -cSize, cSize*2,0);
L222:       [*] = ;   StandPattern(plhnd, 'box_corner_rb', cSize, cSize*2,0);}
L223:       [*] = ;end;
L224:       [*] = ;
L225:       [*] = ;var x, y : Integer;
L226:       [*] = ;for y:=0 to cMapH-1 do
L227:       [*] = ;for x:=0 to cMapW-1 do
L228:       [*] = ;platarray[x, y] := cNone;
L229:       [*] = ;
L230:       [*] = ;platarray[8,12] := 1;
L231:       [*] = ;platarray[12,12] := 1;
L232:       [*] = ;platarray[13,12] := 1;
L233:       [*] = ;platarray[14,12] := 1;
L234:       [*] = ;
L235:       [*] = ;//platarray[11,22] := 1;
L236:       [*] = ;platarray[10,22] := 1;
L237:       [*] = ;platarray[9,22] := 1;
L238:       [*] = ;platarray[8,22] := 1;
L239:       [*] = ;//platarray[7,22] := 1;
L240:       [*] = ;
L241:       [*] = ;//platarray[9,20] := 1;
L242:       [*] = ;platarray[9,21] := 1;
L243:       [*] = ;platarray[9,22] := 1;
L244:       [*] = ;platarray[9,23] := 1;
L245:       [*] = ;//platarray[9,24] := 1;
L246:       [*] = ;//platarray[9,25] := 1;
L247:       [*] = ;//platarray[8,5] := 1;
L248:       [*] = ;
L249:       [*] = ;platarray[20,22] := 1;
L250:       [*] = ;
L251:       [*] = ;platarray[26,21] := 1;
L252:       [*] = ;platarray[27,21] := 1;
L253:       [*] = ;platarray[26,22] := 1;
L254:       [*] = ;platarray[27,22] := 1;
L255:       [*] = ;
L256:       [*] = ;platarray[35,20] := 1;
L257:       [*] = ;platarray[36,21] := 1;
L258:       [*] = ;platarray[37,22] := 1;
L259:       [*] = ;platarray[38,23] := 1;
L260:       [*] = ;
L261:       [*] = ;platarray[35+1,20] := 1;
L262:       [*] = ;platarray[36+1,21] := 1;
L263:       [*] = ;platarray[37+1,22] := 1;
L264:       [*] = ;platarray[38+1,23] := 1;
L265:       [*] = ;
L266:       [*] = ;platarray[60,20] := 1;
L267:       [*] = ;platarray[59,21] := 1;
L268:       [*] = ;platarray[58,22] := 1;
L269:       [*] = ;platarray[57,23] := 1;
L270:       [*] = ;
L271:       [*] = ;
L272:       [*] = ;platarray[27,40] := 1;
L273:       [*] = ;platarray[28,41] := 1;
L274:       [*] = ;platarray[29,42] := 1;
L275:       [*] = ;platarray[30,43] := 1;
L276:       [*] = ;platarray[31,43] := 1;
L277:       [*] = ;platarray[32,42] := 1;
L278:       [*] = ;platarray[33,41] := 1;
L279:       [*] = ;platarray[34,40] := 1;
L280:       [*] = ;
L281:       [*] = ;platarray[28,40] := 1;
L282:       [*] = ;platarray[29,40] := 1;
L283:       [*] = ;platarray[30,41] := 1;
L284:       [*] = ;platarray[33,40] := 1;
L285:       [*] = ;platarray[31,41] := 1;
L286:       [*] = ;platarray[29,41] := 1;
L287:       [*] = ;platarray[30,42] := 1;
L288:       [*] = ;platarray[31,42] := 1;
L289:       [*] = ;platarray[32,41] := 1;
L290:       [*] = ;
L291:       [*] = ;//platarray[11,8] := 1;
L292:       [*] = ;
L293:       [*] = ;for [MAIN]y:=1 to cMapH-1 do
L294:       [*] = ;for x:=1 to cMapW-1 do
L295:       [*] = ;CalcPlateau(x, y);
L296:       [*] = ;
L297:       [*] = ;{platarray[7,8] := cLeft;
L298:       [*] = ;platarray[8,8] := cRight;
L299:       [*] = ;platarray[7,9] := cCornerLB;
L300:       [*] = ;platarray[8,9] := cCornerRB;
L301:       [*] = ;
L302:       [*] = ;platarray[7,7] := cLB;
L303:       [*] = ;platarray[8,7] := cRight;
L304:       [*] = ;platarray[8,6] := cRB;}
L305:       [*] = ;
L306:       [*] = ;for [MAIN]y:=1 to cMapH-1 do
L307:       [*] = ;for x:=1 to cMapW-1 do
L308:       [*] = ;DrawPlateau(x, y, False);
L309:       [*] = ;for [MAIN]y:=1 to cMapH-1 do
L310:       [*] = ;for x:=1 to cMapW-1 do
L311:       [*] = ;DrawPlateau(x, y, True);
L312:       [*] = ;
L313:       [*] = ;GUIMiniMapUpdate;
L314:    struct.end
L315: section.end
L316: 
```

**[O]/[D] Reading of the quoted routine.** `cMapW = cMapH = 80`. Lines 225–228
zero the grid; 230–289 write hardcoded `1`s (with several `//`-commented
alternatives — an author hand-tuning a shape); 293–295 classify every cell with
`CalcPlateau`; 306–311 draw the derived edge/corner cells twice (non-exists then
exists); 313 refreshes the editor mini-map. `DrawPlateau` stamps only when
`name<>''`; for `cExists` the name is `box_4x4_c`, for the four edge codes it is
`box_4x4_l` rotated by `angle*(pi/2)/90` — i.e. `0, 90, 180, 270` degrees become
`0, pi/2, pi, 3pi/2` radians (L31, L41, L47, L53, L68). **[I]** The two calls at
L68/L197 use `GetMapHeight` for *both* the `x` and `y` centre offsets; on a
square 320² map this is indistinguishable from `GetMapWidth`, so this report
does not claim it is a bug. **[O]** No `RandomExt`, seed, `Freq`, mask or
`SetRandomKey` appears in the 316 lines. **[D]** The entire routine is a
deterministic, hand-authored editor brush macro.

### 2.3 Sibling `plateaugenerator1.inc` (305 lines) — line-cited structural diff

This file is the same state design with a different cell size. It is read in
full at the donor path; to keep this report single-purpose the 305 lines are
summarised by exact line ranges instead of re-quoted.

| Lines | `plateaugenerator1.inc` content (verbatim values) | Diff vs `plateaugenerator2.inc` |
|---|---|---|
| 1–3 | `Name = PlateauGenerator1` | different state name |
| 4 | `const cSize = 17;` | **17, not 4** → `cMapW = cMapH = 320 div 17 = 18` (L7–8) |
| 5–23 | identical 320², `cNone..cRB`, `platarray` declaration | same |
| 25–121 | `procedure DrawPlateau(const x, y : Integer);`; `var rndInd : Integer = 0; //floor(random*3);` (L31); `cExists : name := 'box_c3'` (L35); edge codes pick `box_l/box_b/box_t/box_r/box_rt/...` by `rndInd` (L36–117); stamp at L119 | richer name table, **but `rndInd` is fixed 0** so the `floor(random*3)` idea is dead; pattern family is `box_*`, not `box_4x4_*` |
| 123–241 | `CalcPlateau` identical in structure; **L140 live** `StandPattern(plhnd, 'box_c3', cSize*x-(GetMapHeight div 2), cSize*y-(GetMapHeight div 2), 0);` | P2's equivalent is commented out (P2 L90) |
| 243–273 | `ResetPatternMap(False); PlateauTerrain(-30, 0, False, (GetMapHeight div 2)-1+32, True);` (L246–247); `{...}` demo stamps (L248–272) | identical to P2 L196–222 |
| 275–278 | grid zero-fill | identical |
| 280–281 | `platarray[7,6] := 1; platarray[8,5] := 1;` | hardcoded 2-cell seed |
| 285–287, 298–300 | `CalcPlateau` then single `DrawPlateau(x,y)` pass | P2 classifies then draws twice |
| 289–296 | manual overrides `cLeft/cRight/cCornerLB/cCornerRB/cLB/cRB` | P2 has this block commented out |
| 302 | `GUIMiniMapUpdate;` | same |

### 2.4 Sibling `plateaugenerator3.inc` — full file (51 lines)

```text
L1: section.begin
L2:    Name = PlateauGenerator3
L3:    Code : struct.begin
L4:       [*] = ;function DrawLineWithPattern(x1, y1, x2, y2 : Integer; const pattern : String; step : Integer) : Integer;
L5:       [*] = ;begin
L6:       [*] = ;   var plhnd : Integer = GetPlayerHandleByIndex(gc_playerind_env);
L7:       [*] = ;   var lpixel, lMaxAxisLength : Integer;
L8:       [*] = ;   var lRatio : Float;
L9:       [*] = ;   var x, y, t : Integer;
L10:       [*] = ;   t := step;
L11:       [*] = ;   lMaxAxisLength := Max(Round(abs(x1-x2)), Round(abs(y1-y2)));
L12:       [*] = ;   for lpixel:=0 to lMaxAxisLength do
L13:       [*] = ;   begin
L14:       [*] = ;      t := t + 1;
L15:       [*] = ;      if (t>step) or (lpixel=lMaxAxisLength) then
L16:       [*] = ;      begin
L17:       [*] = ;         lRatio := lpixel / lMaxAxisLength;
L18:       [*] = ;         x := x1 + Round((x2 - x1) * lRatio);
L19:       [*] = ;         y := y1 + Round((y2 - y1) * lRatio);
L20:       [*] = ;
L21:       [*] = ;         StandPattern(plhnd, pattern, x, y, 0);
L22:       [*] = ;
L23:       [*] = ;         t := 0;
L24:       [*] = ;      end;
L25:       [*] = ;   end;
L26:       [*] = ;
L27:       [*] = ;   Result := lMaxAxisLength;
L28:       [*] = ;end;
L29:       [*] = ;
L30:       [*] = ;const cPattern = 'brush_plt_13x13_2';
L31:       [*] = ;const cPatternDot = 'brush_plt_1x1';
L32:       [*] = ;const cPatternHalf = 'brush_plt_1x1_half';
L33:       [*] = ;const cPatternMiddle = 'brush_plt_1x1_mid';
L34:       [*] = ;
L35:       [*] = ;var plhnd : Integer = GetPlayerHandleByIndex(gc_playerind_env);
L36:       [*] = ;ResetPatternMap(False);
L37:       [*] = ;var r : Integer = (GetMapHeight div 2)-1;
L38:       [*] = ;PlateauTerrain(0, 0, False, r, True);
L39:       [*] = ;PaintTerrain(0, 0, 0, -1, -1, false, -1, -1, r, false, True);
L40:       [*] = ;
L41:       [*] = ;DrawLineWithPattern(-15, -4, -10, 10, cPattern, 1);
L42:       [*] = ;DrawLineWithPattern(-10, 10, -7, 10, cPattern, 1);
L43:       [*] = ;
L44:       [*] = ;StandPattern(plhnd, cPatternMiddle, -7, 10+7, 0);
L45:       [*] = ;StandPattern(plhnd, cPatternMiddle, -7, 10+8, 0);
L46:       [*] = ;
L47:       [*] = ;//ExecuteState('ScalePlateauTerrain');
L48:       [*] = ;//ExecuteState('TextureTerrain');
L49:    struct.end
L50: section.end
L51: 
```

**[O]** Hardcoded line endpoints (-15,-4)→(-10,10)→(-7,10), step 1;
`cPatternDot`/`cPatternHalf` are declared but never used. **[D]** This is a
brush-stroke test, not a terrain generator.

### 2.5 Sibling `scaleplateauterrain.inc` — full file (51 lines)

```text
L1: section.begin
L2:    Name = ScalePlateauTerrain
L3:    Code : struct.begin
L4:       [*] = ;const cAdd = 0.0;
L5:       [*] = ;const cRandMin = -0.45;
L6:       [*] = ;const cRandMax = 0.45;
L7:       [*] = ;const cLerpMin = 0.5;
L8:       [*] = ;const cLerpMax = 1.0;
L9:       [*] = ;const cMaxHeight = 3.2;
L10:       [*] = ;var height, newheight : Float;
L11:       [*] = ;var x, y, colind, plind : Integer;
L12:       [*] = ;var lx, ty : Float;
L13:       [*] = ;_misc_GetMapLeftTopPos(lx, ty);
L14:       [*] = ;for y:=0 to GetMapHeight do
L15:       [*] = ;for x:=0 to GetMapWidth do
L16:       [*] = ;begin
L17:       [*] = ;   var realx : Integer = floor(lx+x);
L18:       [*] = ;   var realy : Integer = floor(ty+y);
L19:       [*] = ;   height := GetHeightData(realx, realy);
L20:       [*] = ;   if (height<>0) then
L21:       [*] = ;   begin
L22:       [*] = ;      if (height>0.05) and (height<2.5) then
L23:       [*] = ;      begin
L24:       [*] = ;         newheight := height;
L25:       [*] = ;         //newheight := newheight+cAdd+(cRandMin+random*cRandMax);
L26:       [*] = ;         //newheight := height*(1+random*0.75);
L27:       [*] = ;         newheight := Lerp(newheight*cLerpMin, newheight*cLerpMax, random);
L28:       [*] = ;         newheight := Pow(newheight, 1.25);
L29:       [*] = ;         newheight := Clamp(newheight, 0, cMaxHeight);
L30:       [*] = ;         SetHeightData(realx, realy, newheight);
L31:       [*] = ;      end
L32:       [*] = ;      else
L33:       [*] = ;      if (height<cMaxHeight) then
L34:       [*] = ;      begin
L35:       [*] = ;         //newheight := pow(height, 2);
L36:       [*] = ;         newheight := height*(1{+random});
L37:       [*] = ;         newheight := Clamp(newheight, 0, cMaxHeight);
L38:       [*] = ;         SetHeightData(realx, realy, newheight);
L39:       [*] = ;      end
L40:       [*] = ;      else
L41:       [*] = ;      SetHeightData(realx, realy, height);
L42:       [*] = ;   end
L43:       [*] = ;   else
L44:       [*] = ;   SetHeightData(realx, realy, height);
L45:       [*] = ;   //gMapTerrainData.tile[x][y].tex := GetTileIndex(x, y);
L46:       [*] = ;   //for colind:=0 to gc_terraindata_collision-1 do
L47:       [*] = ;   //gMapTerrainData.tile[x][y].collision[colind] := GetMapCollisionTag(realx+(colind div 2)*0.5, realy+(colind mod 2)*0.5, False);
L48:       [*] = ;end;
L49:    struct.end
L50: section.end
L51: 
```

**[O]** Inclusive loops `0..GetMapHeight` / `0..GetMapWidth` (L14–15). The
random additive variants at L25–26 and the multiplication jitter at L36 are
commented out; only `Lerp(h*0.5, h*1.0, random)` + `Pow(h,1.25)` + `Clamp(0,3.2)`
remain live in the `0.05<h<2.5` band. **[D]** This is a global editor height
remap, not a stamp, and is disabled at its only call site (§3.4).

---

## 3. Scope determination — call sites, or their absence

### 3.1 Registration: editor manifest only [O]

`scripts\editor.aix`:

```text
L620: section.begin
L621:    Name = PlateauGenerator1
L622:    UsedFile = True
L623:    UsedFileName = .\scripts\editor.inc\plateaugenerator1.inc
L624: section.end
L626: section.begin
L627:    Name = PlateauGenerator2
L628:    UsedFile = True
L629:    UsedFileName = .\scripts\editor.inc\plateaugenerator2.inc
L630: section.end
L686: section.begin
L687:    Name = PlateauGenerator3
L688:    UsedFile = True
L689:    UsedFileName = .\scripts\editor.inc\plateaugenerator3.inc
L690: section.end
L721: section.begin
L722:    Name = ScalePlateauTerrain
L723:    UsedFile = True
L724:    UsedFileName = .\scripts\editor.inc\scaleplateauterrain.inc
L725: section.end
```

Contrast `data\scripts\common.aix` (the game-side state manifest):

```text
L50: section.begin
L51:    Name = DoGenerate
L52:    LanClientExecute = True
L53:    UsedFile = True
L54:    UsedFileName = .\data\scripts\common.inc\dogenerate.inc
L55: section.end
L69: section.begin
L70:    Name = GenerateMap
L71:    LanClientExecute = True
L72:    UsedFile = True
L73:    UsedFileName = .\data\scripts\common.inc\generatemap.inc
L74: section.end
```

**[O]** `DoGenerate`/`GenerateMap` carry `LanClientExecute = True`; the four
plateau states do not appear in `common.aix` at all. **[D]** They are in the
editor script manifest, not the skirmish state manifest.

### 3.2 No `ExecuteState` call anywhere in the text corpus [O]

Whole-tree `rg` over `.inc/.script/.global/.source/.aix/.cfg/.txt/.mat/.lib`
for `PlateauGenerator[123]|ScalePlateauTerrain` returned only:

- the four definitions (`.inc:2`),
- the four `editor.aix` registrations (§3.1),
- `generatemapfrombitmap.inc:334` (§3.4),
- the commented `plateaugenerator3.inc:47`.

There is **no** `ExecuteState('PlateauGenerator1')`,
`ExecuteState('PlateauGenerator2')` or `ExecuteState('PlateauGenerator3')`
string in any donor text file. **[D]** If a user can run these states at all,
it is via an editor UI/manifest dispatch by state name (the `.aix` registration
itself makes the name addressable), not via a generation script.

### 3.3 Skirmish generation call sites — both non-random or dead [O]

`data\scripts\common.inc\dogenerate.inc:465–479`:

```text
L465:       [*] = ;   // clear terrain
L466:       [*] = ;   var r : Integer = (GetMapHeight div 2)-1;
L467:       [*] = ;   {if BoolRegister5 then
L468:       [*] = ;   begin
L469:       [*] = ;      ClearPlayerGameObjectsByHandle(envplhnd);
L470:       [*] = ;      PlateauTerrain(0, 0, False, r, True);
L471:       [*] = ;      BoolRegister5 := not BoolRegister5;
L472:       [*] = ;      TimeLog('Clear finished');
L473:       [*] = ;      exit;
L474:       [*] = ;   end
L475:       [*] = ;   else
L476:       [*] = ;   if not BoolRegister5 then
L477:       [*] = ;   PaintTerrain(0, 0, 0, -1, -1, false, -1, -1, r, false, True);
L478:       [*] = ;   BoolRegister5 := not BoolRegister5;}
L479:       [*] = ;   MapDrawCollision(0, 0, 0, r*2-2, False);
```

**[O]** L467–478 are inside a single `{...}` DScript comment. This agrees with
X03 §2 Stage 2's explicit note that D1:467–478 is fully commented out. There is
therefore **no live `PlateauTerrain` call in `DoGenerate`**.

`data\scripts\common.inc\generatemap.inc:253–283`:

```text
L253:       [*] = ;var lx, ty : Float;
L254:       [*] = ;_misc_GetMapLeftTopPos(lx, ty);
L255:       [*] = ;
L256:       [*] = ;var x, y : Integer;
L257:       [*] = ;if (cResetTerrainHeight) then
L258:       [*] = ;begin
L259:       [*] = ;   _misc_ProfilerBegin('Reset terrain height');
L260:       [*] = ;   ApplicationProcessMessages;
L261:       [*] = ;   if (bRandomMap) then
L262:       [*] = ;   ResetPatternMap(False)
L263:       [*] = ;   else
L264:       [*] = ;   begin
L265:       [*] = ;      PlateauTerrain(0, 0, False, ((mapheight div 2)-1), True);
L266:       [*] = ;      for y:=0 to mapheight do
L267:       [*] = ;      for x:=0 to mapwidth do
L268:       [*] = ;      SetTileIndex(x, y, 0);
L269:       [*] = ;
L270:       [*] = ;      ClearPlayerGameObjectsByHandle(envplhnd);
L271:       [*] = ;      LoadPatterns(True, True);
L272:       [*] = ;      for y:=0 to gc_terraindata_mapheight-1 do
L273:       [*] = ;      for x:=0 to gc_terraindata_mapwidth-1 do
L274:       [*] = ;      begin
L275:       [*] = ;         var realx : Integer = floor(lx+x);
L276:       [*] = ;         var realy : Integer = floor(ty+y);
L277:       [*] = ;         MapDrawCollision(realx+0.5, realy+0.5, 0, 2, True); // clear
L278:       [*] = ;      end;
L279:       [*] = ;      ResetPatternMap(False);
L280:       [*] = ;   end;
L281:       [*] = ;
L282:       [*] = ;   _misc_ProfilerEnd('Reset terrain height');
L283:       [*] = ;end;
```

**[O]** `cResetTerrainHeight = True` (L35 of the same file), but the only
`PlateauTerrain` call is in the **`else` of `if (bRandomMap)`**. For a skirmish
random map the live branch is L262 `ResetPatternMap(False)` only. This is the
same `bRandomMap` discipline X03 documented at D2:507 for `PostProcess` (X03
§5h) and D2:818 for occupancy prefill (X03 §0 summary item 4d). **[D]** The
native `PlateauTerrain` is reachable from skirmish files *syntactically* but is
not executed on the random-map path.

### 3.4 Editor bitmap tool — the one `ExecuteState`, disabled [O]

`scripts\editor.inc\generatemapfrombitmap.inc` (registered in `editor.aix:710–713`
as `Name = GenerateMapFromBitmap_OLD`):

```text
L98:       [*] = ;const cScalePlateauTerrain = False; // disabled
L112:      [*] = ;if (cResetTerrainHeight) then
L113:      [*] = ;begin
L114:      [*] = ;   _misc_ProfilerBegin('Reset terrain height');
L115:      [*] = ;   PlateauTerrain(0, 0, False, ((GetMapHeight div 2)-1), True);
...
L331:      [*] = ;if (cScalePlateauTerrain) then // most likely disabled
L332:      [*] = ;begin
L333:      [*] = ;   _misc_ProfilerBegin('Scale plateau terrain');
L334:      [*] = ;   ExecuteState('ScalePlateauTerrain');
L335:      [*] = ;   _misc_ProfilerEnd('Scale plateau terrain');
L336:      [*] = ;end;
```

**[O]** The only call to any plateau-related state is gated by a literal
`False` in an editor-only, `_OLD`-named state. **[D]** Dead in the shipped
configuration.

### 3.5 Binary pass (read-only bytes, no execution) [O]

| Needle | cossacks.exe (5,768,048 B) | editor.exe (7,874,416 B) |
|---|---:|---:|
| `PlateauGenerator1` | 0 | 0 |
| `PlateauGenerator2` | 0 | 0 |
| `PlateauGenerator3` | 0 | 0 |
| `ScalePlateauTerrain` | 0 | 0 |
| `PlateauTerrain` | 5 hits | 15 hits |
| `scripts` + `editor.aix` path pair | 1 hit (file offset `5,039,880` dec) | 1 hit (file offset `6,433,548` dec) |

`cossacks.exe` file offset `2,764,438` decimal contains the DScript native declaration:

```text
procedure PlateauTerrain(const x, y: Integer; const round: Boolean; const mb: Integer; const reproduce: Boolean)
```

which matches the 5 arguments used at `plateaugenerator2.inc:197` and
`generatemap.inc:265`. **[D]** Zero engine-side references to the four state
names means they cannot be hardcoded dispatch targets; addressing must be
data-driven from the `.aix` manifest. **[I]/[U]** The `editor.aix` path string in
`cossacks.exe` prevents claiming "only editor.exe can load it" from text alone;
no claim is made here.

### 3.6 Verdict

| Question | Answer | Evidence |
|---|---|---|
| Does `plateaugenerator2.inc` participate in random-map skirmish generation? | **NO** | E9, E10, E11, E13 |
| Is any sibling on the skirmish path? | **NO** | E7/E8/E9/E12/E13 |
| Is it editor authoring/debug? | **YES [D]** | debug `log('a')` (E3), hardcoded arrays (E3/E4), editor env player + `GUIMiniMapUpdate`, editor manifest (E7), undefined `box_*` patterns (E15) |
| Disposition | **DEFERRED — no port action** | charter §6 guardrails; no donor constant from these files may be imported |

---

## 4. Exact parameters (extracted, with donor lines) and comparison

### 4.1 Parameters actually present in the four scripts [O]

| Parameter | Value | Donor line |
|---|---|---|
| `cSize` (P2 cell radius) | `4` | `plateaugenerator2.inc:4` |
| `cSize` (P1 cell radius) | `17` | `plateaugenerator1.inc:4` |
| map constants | `cMapWidth = cMapHeight = 320` | P2 `:5–6`, P1 `:5–6` |
| grid dims | `cMapW = cMapH = 320 div cSize` → **80** (P2), **18** (P1) | P2 `:7–8`, P1 `:7–8` |
| cell codes | `cNone=0, cExists=1, cLeft=2, cTop=3, cRight=4, cBottom=5, cCornerLT=6, cCornerRT=7, cCornerLB=8, cCornerRB=9, cLT=10, cRT=11, cLB=12, cRB=13` | P2 `:9–22`, P1 `:9–22` |
| terrain reset call (P2/P1) | `PlateauTerrain(-30, 0, False, (GetMapHeight div 2)-1+32, True)` | P2 `:197`, P1 `:247` |
| terrain reset call (P3) | `PlateauTerrain(0, 0, False, r, True)` with `r=(GetMapHeight div 2)-1` | P3 `:37–38` |
| companion repaint (P3) | `PaintTerrain(0, 0, 0, -1, -1, false, -1, -1, r, false, True)` | P3 `:39` |
| stamp rotation (P2) | `angle*(pi/2)/90` with `angle ∈ {0,90,180,270}` | P2 `:31,41,47,53,68` |
| brush names (P3) | `brush_plt_13x13_2`, `brush_plt_1x1`, `brush_plt_1x1_half`, `brush_plt_1x1_mid` | P3 `:30–33` |
| editor height band | `0.05 < height < 2.5` | `scaleplateauterrain.inc:22` |
| editor lerp / pow / clamp | `Lerp(h*0.5, h*1.0, random)`, `Pow(h,1.25)`, `Clamp(h,0,3.2)` | `scaleplateauterrain.inc:27–29` |
| editor cap | `cMaxHeight = 3.2` | `scaleplateauterrain.inc:9` |
| unused jitter constants | `cAdd=0.0`, `cRandMin=-0.45`, `cRandMax=0.45` (both uses commented) | `scaleplateauterrain.inc:4–6,25–26` |

**No radius-in-tiles smoothing, no height bands, no relief frequency and no
seed/key appears in any of the four states.** The only "radius"-like value is
the `mb: Integer` argument of the native `PlateauTerrain`, passed as
`(GetMapHeight div 2)-1+32` (P1/P2) or `r = (GetMapHeight div 2)-1` (P3) — a
native terrain-reproduction argument, **not** a DScript stamping radius.

### 4.2 Pattern-lib parameters for the brushes P3 actually stamps [O]

| Pattern (`pattern.lib` 1-based line) | Scale | ReplaceForWater | Smooth | Min / Max | Offset |
|---|---|---|---|---|---|
| `brush_plt_13x13_2` (`:42–78`) | `-0.925000011920929` (`:54`) | `True` (`:50`) | `True`, radius 1 / factor 4 / offset 1 (`:58–61`) | `3.20392155647278` / same (`:71–72`) | `0` (`:73`) |
| `brush_plt_1x1` (`:202–238`) | `-0.925000011920929` (`:214`) | `True` (`:210`) | `False`, radius 3 / factor 4 / offset 2 (`:218–221`) | `3.20392155647278` / same (`:231–232`) | `0` (`:233`) |
| `brush_plt_1x1_mid` (`:282–318`) | `1.17499995231628` (`:294`) | `True` (`:290`) | `False` (`:298`) | `2.18083715438843` / same (`:311–312`) | `0` (`:313`) |

Eight `brush_plt_*` sections exist (`pattern.lib:2,42,82,122,162,202,242,282`).
The `box_*` names used by P1/P2 exist in **none** of them and in no `.pattern`
file (E15).

### 4.3 Comparison with D05's stamp formula [O]/[D]

D05 §F4 (spec §04 §6) defines three stamp paths for `sub_755f30`:

- `ReplaceForWater=true`: `new = g*Scale + HeightFieldOffset` (no base height,
  no current-height read, no `TerrainScale`);
- `Replace=true`: `new = base_h + (g−Min)*Scale + Min + Offset`;
- default Smooth: `new = h1 + (base_h−h0)*TerrainScale + (g−Min)*Scale + Min + Offset`.

Applying D05's *already-decoded* path to the editor brush values (E14):
`brush_plt_13x13_2` and `brush_plt_1x1` have `ReplaceForWater=true`,
`Scale=-0.925`, `Offset=0` → `new = −0.925 * g`. **[D]** These brushes carve
terrain *down* by the grid amount; they are negative-relief editor tools. This
is consistent with D05 F3's observation that `-0.925` occurs on "brush patterns"
and with D05 F4's note that a negative scale inverts the grid, not world height.
`HeightFieldMin/Max` are equal to each other in these sections, so even if the
Min-pivot path were taken it would be a degenerate case — but it is **not** the
path selected by `ReplaceForWater=true`. The `HeightFieldSmooth` post-pass of
D05 §F5 applies here only for `brush_plt_13x13_2` (`radius=1, factor=4,
offset=1`), i.e. `(Radius−Offset)/d = 0/d` — **[U]** the runtime effect is not
measured; do not infer a smoothing kernel from it.

**No value from §4.1 or §4.2 overrides or extends D05.** In particular the
editor `cMaxHeight = 3.2` **is not** a stamp clamp: D05 P6/P10 found zero
`HeightFieldMax` (`+0x60`) accesses in `sub_755f30`. The 3.2 clamp lives in a
separate, disabled editor state (`scaleplateauterrain.inc:29,37`).

### 4.4 Comparison with A02's plateau family [O]/[D]

A02 §4b and spec §04 §3 define skirmish plateaus exclusively as:

- class/amplitude: `cPlateauHeight = 2.964` (`generatemap.inc:4`), mask R code
  `cRColorPlateau = 255` / smooth `191` (`:21,25`), height
  `hterrain := cPlateauHeight*fr` (`:570`);
- families: `plateau` (5 members, `generator.cfg:581`), `plateau_small` (6,
  `:606`), `plateau_big` (5, `:635`), stamped at
  `dogenerate.inc:1762/1763/1758` with frequency `plt/3` (`:1738`), plus desert
  variants (`:1750–1753`); relief frequency table `plt` per relieftype
  (`dogenerate.inc:1626,1631,1636,1641,1646`). **[O] as quoted in X03 §3 Stage 8;
  inherited, not re-read here** except the line numbers reconfirmed by grep.

**[D]** None of these weights, amplitudes or family names appear in the four
plateau states. The states use `cSize=4/17` cell grids, hardcoded `platarray`
literals, the `box_*`/`brush_plt_*` patterns, and a 3.2 editor cap. They are a
*different authoring mechanism*, not a second implementation of A02's plateau
family. A02 §4b's own note that `−0.925` and `1.175` occur among
`HeightFieldScale` values is corroborated by E14 — but those literals belong to
editor brush sections, not to the skirmish `plateau*` families.

---

## 5. Contradictions and replacement text for spec §04

### 5.1 Contradiction register (multiple passes)

| # | Contradiction | Passes | Accepted reading | Label |
|---|---|---|---|---|
| C1 | Ticket says `data\scripts\**`; files are in `scripts\editor.inc\**` | P1 filename walk of `data\scripts` = 0; P2 walk of `scripts\editor.inc` = 4; P3 X33 E1/E2 confirm two distinct trees | **Ticket path wrong.** Cite donor paths as `scripts\editor.inc\plateaugenerator{1,2,3}.inc` and `...\scaleplateauterrain.inc`. No silently repaired path in the claim. | [O] |
| C2 | "Plateau generator" name suggests a skirmish plateau stage | P3 call-site census (0 calls); P4 `dogenerate.inc:467–478` commented and `generatemap.inc:261–280` non-random else; P5 manifests; P6 EXE strings | **DEFERRED/editor-only.** Not a contradiction with spec §04; it is an out-of-scope namesake. | [O]/[D] |
| C3 | Editor `cMaxHeight=3.2` clamp vs spec §04 §6 "no `[Min,Max]` clamp in the stamp" | P2 full read of scale state; P7 pattern.lib brush sections; D05 P6/P10 re-read | **Not a contradiction if kept separate.** The 3.2 clamp is in a disabled editor state, not in `sub_755f30`. A naive merge would contradict spec §04 §6 — guard text added below. | [O]/[D] |
| C4 | A02 §4b lists `HeightFieldScale` values incl. `−0.925`, `1.175` without saying where | P7 `pattern.lib:54,214,294` | **Corroborated and located**: those values are editor `brush_plt_*` sections. No numeric contradiction; add the source to avoid misattribution to skirmish families. | [O]/[D] |
| C5 | P1 `rndInd : Integer = 0; //floor(random*3)` looks like RNG-driven variety | P2 full read of P1: `:31` and the six `case rndInd` blocks | **Dead randomization**: `rndInd` is never reassigned, so only branch 0 is live. Do not import "random plateau orientation" into the port. | [O]/[D] |
| C6 | P2 L68/L197 use `GetMapHeight` for x and y centre | P2 read; cross-check square 320² constants L5–6 | **[O] observed quirk; [I] likely copy-paste.** No file provides `GetMapWidth` here; not claimed as a bug, not ported. | [O]/[I] |
| C7 | `editor.aix` path string exists in cossacks.exe too → "editor.exe only" overclaim risk | P6 byte scan both EXEs | **Accept the weaker claim**: manifest-based registration + no call site + no hardcoded engine reference; do not assert the game EXE can never load the aix. | [O]/[U] |

### 5.2 Ready-to-paste replacement text for `docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md`

Append as a new section (no existing line needs deleting):

```markdown
## 9. Editor plateau generator states — DEFERRED, not skirmish stages [O]/[D]

The donor states `PlateauGenerator1`, `PlateauGenerator2`, `PlateauGenerator3`
and `ScalePlateauTerrain` live at
`C:\Games\Cossacks 3\scripts\editor.inc\plateaugenerator1.inc`,
`...\plateaugenerator2.inc`, `...\plateaugenerator3.inc` and
`...\scaleplateauterrain.inc` — **not** under `data\scripts\**`. They are
registered only in `scripts\editor.aix:620-630, 686-690, 721-725`, without the
`LanClientExecute = True` flag that the game-side `DoGenerate`/`GenerateMap`
states carry in `data\scripts\common.aix:50-74`. There is no
`ExecuteState('PlateauGenerator1/2/3')` anywhere in the donor text corpus; the
only call to `ScalePlateauTerrain` (`generatemapfrombitmap.inc:334`, itself an
editor `_OLD` state) is gated by `const cScalePlateauTerrain = False; //
disabled` (`:98`). `PlateauTerrain` in `dogenerate.inc:470` is inside a
`{...}` comment block (`:467-478`); in `generatemap.inc:265` it is in the
`else` branch of `if (bRandomMap)` (`:261-280`), so skirmish random maps take
only `ResetPatternMap(False)`. The strings of all four state names occur zero
times in both `cossacks.exe` and `editor.exe` (read-only byte scan, X56 E13).

The scripts are hand-authored editor/debug macros: hardcoded `platarray`
literals and a `log('a')` breakpoint (`plateaugenerator2.inc:76-77,230-289`),
cell size `cSize=4` (`80x80` grid) / `17` (`18x18` grid), direct `StandPattern`
of `box_4x4_*`/`box_c3` names that have **no** section in `pattern.lib` and no
`.pattern` file, and brush-line painting with `brush_plt_*`
(`plateaugenerator3.inc:30-45`, eight real sections at `pattern.lib:2-318`,
`HeightFieldScale = -0.925000011920929` / `1.17499995231628`,
`HeightFieldReplaceForWater = True`,
`HeightFieldMin = HeightFieldMax = 3.20392155647278`). Their only height
remap is a separate disabled state, `scaleplateauterrain.inc:9,22,27-29,37`
(`0.05 < height < 2.5`, `Lerp(h*0.5,h*1.0,random)`, `Pow(h,1.25)`,
`Clamp(h,0,3.2)`).

**Decision: DEFERRED — no port action.** None of these constants, grids,
pattern names or the `3.2` cap enters the skirmish pipeline. The skirmish plateau
rule remains the mask-class + family rule of §3 (class `cRPlateau`,
`cPlateauHeight = 2.964`, families `plateau`/`plateau_small`/`plateau_big` and
desert variants) stamped through the D05 blend paths of §6. Do **not** import a
`[Min,Max]` clamp from `scaleplateauterrain.inc`: that would contradict §6,
which records that `HeightFieldMax` is never read by `sub_755f30`. The
`-0.925`/`1.175` scale literals are editor-brush metadata (X56 E14), not
skirmish `plateau*` family values. No donor visual parity is claimed. *(X56)*
```

Also amend §3's phrase "no plaintext consumer" if a COORD decides the wording is
ambiguous: D05 decoded the consumer in native code, so the precise statement is
"no *plaintext DScript/config* consumer — the consumer is the native stamp
`sub_755f30`" (already reflected in §3/§6 as landed; no numeric change).

---

## 6. Multiple-pass register (owner directive)

| Pass | Instrument | Result | Accepted / rejected and why |
|---|---|---|---|
| P1 | `Get-ChildItem -Filter *plateau*` on `data\scripts\**` | 0 files | Accepted as a true negative; forced path correction |
| P2 | same on `scripts\editor.inc\**`; full `read` of all 4 files | 4 files, complete text | Accepted; source of §2 quotes |
| P3 | `rg -n -i` over 7 text extensions, whole donor tree, three needle sets | call-site census (§3.2, §3.3) | Accepted; two independent needle sets agreed |
| P4 | targeted `read` of `dogenerate.inc:440–494`, `generatemap.inc:1–40,240–289` | dead block + non-random else | Accepted; matches X03's prior independent reading (E17) |
| P5 | `read` of `editor.aix:610–729` and whole `common.aix` | registration contrast + `LanClientExecute` flag | Accepted |
| P6 | `python open('rb')` scan of both EXEs for 6 needles; ±110 B context dumps | 0 hits for state names; native signature recovered; aix path in both | Accepted; context made the 0-hit result non-ambiguous. Caveat C7 retained |
| P7 | `rg -n -A 36` in `pattern.lib` for every named pattern; `Get-ChildItem -Filter box*`; `rg 'box_' pattern.lib` | 8 `brush_plt_*` sections with exact fields; **zero** `box_*` | Accepted after two independent checks (text lib + file names) |
| P8 | reconcile task path, X33 bucket, D05 §F4, A02 §4b, spec §04 §3/§6 | 7 contradictions in §5.1 | Accepted; no number silently harmonised |

---

## 7. UNVERIFIED / open questions

| Id | Item | Status / passes attempted |
|---|---|---|
| U1 | Whether the player-facing editor UI exposes these states as buttons | **[U]** No `ExecuteState('PlateauGenerator…')` in text; `.aix` registration makes them addressable but a GUI binding was not located (`data\gui` has no `Plateau` call site). |
| U2 | Whether `cossacks.exe` ever loads `scripts\editor.aix` | **[U]** path string present in both EXEs (P6); no runtime test performed. |
| U3 | Runtime effect of `HeightFieldSmoothRadius=1, Offset=1` on `brush_plt_13x13_2` | **[U]** values observed (E14); `(Radius−Offset)/d` reduces to `0`; no render or A/B. |
| U4 | Whether `box_*` names ever resolved through a removed/older pattern library | **[U]** absent from the shipped 30 MB `pattern.lib` and from all `.pattern` files; P7 twice. |
| U5 | Visual result of any of these states | **[U]** no donor GPU A/B frame exists; no parity claim. |

---

## 8. Closing statement

One report written. `plateaugenerator2.inc` and its three siblings are decoded,
line-cited and scoped: **editor-authoring/debug states, not skirmish terrain
generation, DEFERRED**. No plateau parameter from them should be ported; spec
§04 needs only the additive guard text in §5.2, not a numeric change. Donor was
read only; no donor binary executed or copied; no source, config, asset, test,
git or Godot state touched; no donor visual parity asserted.

*End of X56 report.*
