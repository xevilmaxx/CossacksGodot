# MAPSIZE law — donor mapsize selector, 240 status, port `3-if-256-else-2` verdict

Worker: MAPSIZE-LAW. Full 1:1 Cossacks 3 donor port. READ-ONLY decompilation.
Exactly one repository file written: this report. No code/Godot/git/donor-execution;
no other edits. Donor binary never executed; donor text read-only.
Parity UNVERIFIED. No approximations. No parity claim. No invented size or value.
Chain 0/6. RESULT IS NOT GOOD.

Labels: `[O]` = observed bytes/lines re-read this pass. `[D]` = arithmetic/control-flow
consequence over cited `[O]`. `[U]` = could not verify here. `ev_…` ids are per-pass
Craft Anything evidence ids on `t_87f0f3c130b0`
(`C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B,
sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`).

## 1. Donor mapsize selector law (byte-proven, text-side)

The live word is `gMap.settings.gen.mapsize` (integer enum). It is NOT a packed-CODE
literal: native `text:"mapsize"` (lowercase, exact, utf8+utf16le,
`document:"t_87f0f3c130b0"`) returns **0 matches** `[O]`
(`ev_e3592b6a90a0561cd5c7451917d96ef37d1e99823adddcf6634ccece3236ff42`,
re-confirms DEC_U_tver_deep P-a3 / DEC_U_b45_residual §2.1). The selector lives in
donor **text** (`.inc`/`.script`), read-only below. All line numbers are 1-based
`Get-Content`/`Select-String` observations.

### 1.1 Where `mapsize` is read, and what each integer means

Two independent donor-text sites state the SAME mapping `[O]`:

**Site A — `C:\Games\Cossacks 3\data\gui\menu.inc\donewgame.inc:41-48`:**

```
;var genMapSize : Integer;                                              (:41)
;case gMap.settings.gen.mapsize of                                      (:42)
;   0 : genMapSize := 320;                                              (:43)
;   1 : genMapSize := 480;                                              (:44)
;   2 : genMapSize := 640;                                              (:45)
;   3 : genMapSize := 256;                                              (:46)
;   else                                                                (:47)
;   genMapSize := 320;                                                  (:48)
;end;
```

Consumer: `donewgame.inc:166`
`;GenerateMapNeededExtBorder(genMapName, genZoneName, genPresetName, genMapSize, genMapSize …)`
— the selected `genMapSize` is passed as BOTH w and h (square map) `[O]`.

**Site B — `C:\Games\Cossacks 3\data\scripts\lib\miscext2.script:19-25`:**

```
case gMap.settings.gen.mapsize of                                       (:19)
   0: w:=320;                                                           (:20)
   1: w:=480;                                                           (:21)
   2: w:=640;                                                           (:22)
   3: w:=256;                                                           (:23)
   else                                                                 (:24)
   w:=320;                                                              (:25)
```

Inside `_map_RestoreSettings` (`miscext2.script:7-43`); caller passes
`SetMapNeeded(filename, zonename, presetname, w, w, c, …)` — again `w` used for
both axes `[O]` (`:38`).

So the byte-proven donor law is `[D]` over two agreeing `[O]` sites:

| `mapsize` | W=H |
|---|---|
| 0 | 320 |
| 1 | 480 |
| 2 | 640 |
| 3 | 256 |
| any other / unset path falling through `else` | 320 |

`mapsize>2 ≡ 256-cell TINY` (`dogenerate.inc:571`
`;if (gMap.settings.gen.mapsize>2) then // tiny`,
and `:658` `;if (i=2) and (spcount<=4) and (gMap.settings.gen.mapsize>2) then`)
is a direct `[D]` consequence: only enum value 3 satisfies `>2` within the
defined range `[O]` lines cited.

Cap context `[O]`: `dmscript.global:132-133`
`gc_MaxMapWidth = 640; gc_MaxMapHeight = 640;`
(`:134-135` `gc_MaxColMapWidth = 2*gc_MaxMapWidth` etc.) — 640 is the max;
no larger size is defined in text read.

### 1.2 Where `mapsize` is written from settings/config (menu path)

- Setter: `C:\Games\Cossacks 3\data\gui\menu.inc\eventcustomgame.inc:69`
  `;      'mapsize' : gMap.settings.gen.mapsize := tag;` `[O]` — the lobby
  combobox writes the selected item's **tag** straight into the live word.
- Tag source: `showcustomgame.inc:233-248` `FillComboBoxMapSize` `[O]`:
  - `:242` `GUIListBoxAddItem(elmHnd, cTextSizeTiny, 3);`
  - `:243` `GUIListBoxAddItem(elmHnd, cTextSizeNormal, 0);`
  - `:244` `GUIListBoxAddItem(elmHnd, cTextSizeLarge, 1);`
  - `:245` `GUIListBoxAddItem(elmHnd, cTextSizeHuge, 2);`
  - `:246` `SetGUIListBoxItemIndexSilent(elmHnd, 1);` (list index 1 = Normal/tag 0)
- Receiver/display: `showcustomgame.inc:822`
  `;var mapsizeind : Integer = GetGUIListBoxItemIndexOfTag(elmHnd, gMap.settings.gen.mapsize);` `[O]`.
- Serialisation: `miscext2.script:2370`
  `roomdata := roomdata+IntToStr(gMap.settings.gen.mapsize)+…` and parse-back
  `:2631` `gc_MaxPlayerCount+5 : map.settings.gen.mapsize := istr;` `[O]`
  (carried from DEC_U_tver_deep §3.2, re-grepped this pass).
- Quickplay override (not a default): `doprogressquickplay1x1.inc:945`
  and `doprogressquickplay2x2.inc:1136` both
  `;            gMap.settings.gen.mapsize := 3;` `[O]` — ranked 1×1/2×2 forces Tiny.

### 1.3 DEFAULT when unset (byte-proven)

`C:\Games\Cossacks 3\data\gui\menu.inc\initmapsettings.inc:10`
`;   gMap.settings.gen.mapsize := 0;` `[O]` (full-file `Get-Content` read this
pass; neighbours `:11-15` zero the other gen words, `:19-29` zero additional
options — procedure `InitMapSettings`, executed at `:45` `;InitMapSettings;`).

`[D]` consequence over §1.1 + §1.3: donor default `mapsize = 0`, and `0 → 320`
by BOTH case sites (plus the `else → 320` fallthrough). **The byte-proven donor
default map size is 320×320** (enum 0). The combobox initial selection
(`SetGUIListBoxItemIndexSilent(elmHnd, 1)` = Normal = tag 0, §1.2) agrees with
it `[D]`.

Native side note (structure only, no value): `DefaultMapSize` occurs **2×** in
packed CODE `[O]` (`ev_cb420f3771198bea7e51f891cfd700bb5dfb241295d4f0ad441739db7124de4d`):
file offsets `0x31b70e` (VA `0x71c30e`) and `0x31c59c` (VA `0x71d19c`), section
CODE — re-confirms DEC_U_b45_residual P4 / DEC_U_b5_ver_residual §4. Per those
reports the neighbourhoods are CODE-embedded **property tables**
(`0x71c280` run: `FrequencyFactor / CellsResolution / FailStandCount /
DefaultMapSize / TileSmoothPasses …`), and no numeric default word was ever
decoded through a typed table schema (adjacent-word typing refused). So the
native table proves a `DefaultMapSize` **row exists** `[O]` but contributes
**zero** to the default VALUE — the value comes from the text sites above.
No native mapsize-enum table was found (`mapsize` 0 hits, `Mapsize` 0 hits per
DEC_U_b45_residual §2.1, not re-attempted beyond the lowercase probe here).

## 2. Can 240 ever be a donor map size?

**No — on all evidence read, 240 is purely a port invention.** `[O]`/`[D]`:

- The donor-text size universe found this pass is exactly `{256, 320, 480, 640}`:
  both case sites (§1.1) enumerate only these four; `dmscript.global:132-133`
  caps at 640; editor `generatemap.inc`-era path (per DEC_U_tver_deep §3.2) is a
  `Map Size (320-640)` form, not a 240 entry.
- Whole-donor-text `240` grep (`*.script,*.inc,*.cfg,*.global,*.aix`,
  `Select-String -Pattern "\b240\b"`) returns **zero map-size hits** `[O]`.
  Every hit is an unrelated namespace: `gui/minimap.cfg:2-6`
  `ImageWidth/ImageHeight/Width/Height = 240` (minimap UI widget size);
  `menu.inc/initminimap.inc:5` `cMinimapSize…`; `top100_season*.cfg`
  `wins/games = 240` (leaderboard counts); `classes.script:7963`
  `gFonts[i].chars[240]` (font glyph index); `country.script` upgrade food/gold
  literals; `misc.script:4276` peacetime constants; `miscext2.script:1214…`
  GUI offsets; `res.script:220` economy costs; `unit.script` objbase stats;
  `dmscript.global:1223` `gc_gui_charfilter_default`. None is a grid size.
- Shipped-map extents (DEC_U_tver_deep §2.2, carried, not re-dumped) are
  320²×3 + 384×1 — no 240² specimen `[O]` (carried).
- Port-side 240 (contrast): `variant3d/scripts/config.gd:132-133`
  `"map_width_tiles": 240, "map_height_tiles": 240` (comment at `:131`
  `Tiny (240) is the port's smallest donor-backed skirmish size` — the comment's
  "donor-backed" gloss is contradicted by the donor text above);
  `config.gd:538-539` writes them to `Data.MAP_W/H`;
  `terrain_donor_data.gd:44-46` lists `DONOR_SIZES := [256,320,480,640]`,
  `PORT_DEBUG_ALIASES := [160,64,240]`, `ALLOWED_SIZES := […,240]` — i.e. the
  port itself labels 240 a **debug alias**, not a donor size `[O]`.

Therefore: donor-allowed `W=H ∈ {256,320,480,640}` (spec/01 §2 table stands);
`240 ∉ donor sizes` on all text + shipped-extent + native-literal evidence
read. The DEEPGEN `240²` consequence stays exactly as classified: port default
DIVERGES from donor size law; donor consequence of a 240² request is `[U]`
(no donor code path consumes 240 — both case sites would fall to `else → 320`).

## 3. Does `terrain_donor_gen.gd:1266`'s `3 if _grid_w==256 else 2` match the donor?

No. It is an **uncited port approximation** (no donor cite at the use site, and
it contradicts the byte-proven default). `[O]`/`[D]`:

Port line (task-cited `:1266`; current file `:1267` after a one-line shift —
same statement, verified by fresh read):

`variant3d/scripts/terrain_donor_gen.gd:1267`
`var mapsize: int = int(p.get("mapsize", 3 if _grid_w == 256 else 2))` `[O]`.

Header comment at `:1274` correctly cites the enum
(`mapsize_gt2 … 256-cell TINY … donewgame.inc:46`), but the **default expression
itself carries no donor cite** (verified: no comment on `:1267`) `[O]`.

Why it does not match:

1. Donor default is unconditional `0` (`initmapsettings.inc:10`), i.e. 320 —
   it is never derived from the grid width `[D]` (§1.3). The port default is a
   function of `_grid_w` (grid-derived), a mechanism with zero donor-text basis.
2. For every non-256 grid the port defaults to `2` (= 640, the LARGEST donor
   size), while donor defaults to `0` (= 320) `[D]`. Concrete divergence:
   a 320²/480²/640²/240² request with no explicit `p.mapsize` gets port
   `mapsize=2`; the donor, at default settings, runs `mapsize=0`. The `mapsize>2`
   branch readout then differs in kind (port says non-tiny-via-2, donor says
   non-tiny-via-0 — same branch outcome here, different selector value, and the
   `ver<91 → 6-way else N-way` / mine-band paths keyed off the version word are
   selected with a wrong `mapsize` literal in the ledger).
3. For a 256 grid the port defaults to `3`, which happens to equal the donor
   enum member for 256 — but arrival is by grid-sniffing, not by the donor's
   settings word. `3` is the right member for the wrong reason, and only when
   the caller already passed `w=256` through a path the donor would have reached
   via `mapsize=3`, not via width inspection `[D]`. No donor text reads the
   width back into `mapsize` (both donor sites map `mapsize → w`, never
   `w → mapsize`) — the port inverts the donor data-flow direction.
4. The generator honours any `w/h` without coercion (DEEPGEN §(b) verified), so
   the `3-if-256` fallback also fires on port-debug grids (e.g. 240² → `else 2`),
   a case with no donor meaning at all (§2).

Related port line (same verdict, out of the asked scope but recorded so no one
re-litigates it): `variant3d/scripts/main.gd:410-411`
`if cfg.has("mapsize") or cfg.has("map_size"): var sz := int(…320…)` — grid-size
fallback 320 is numerically the donor default size but is plumbed as a GRID
word (`Data.MAP_W/H`), never into a `mapsize` enum word, so it does not supply
the missing selector either `[O]`.

Verdict for (3): **DIVERGES-as-approximation / [U]-as-donor-proof** — precisely
DEEPGEN's `[U]` at `:110-111`, now resolved against the re-read donor text:
the expression matches NO donor statement; the donor statement it should match
is `initmapsettings.inc:10` (`:= 0`).

## 4. Byte-proven donor default + minimal conforming change (NO EDIT MADE)

**Byte-proven donor default exists** `[D]` (§§1.1–1.3):

- Selector default: `gMap.settings.gen.mapsize := 0`
  (`C:\Games\Cossacks 3\data\gui\menu.inc\initmapsettings.inc:10`).
- Size meaning: `0 → 320`, `else → 320`
  (`donewgame.inc:42-48`; `miscext2.script:19-25`).
- **Exact value: `mapsize = 0`, i.e. 320×320.** No alternative default is
  byte-proven anywhere in text read (quickplay forces `3`, menu writes tags,
  `else` falls to 320 — none is the unset default).

Minimal port change needed to conform (STATED ONLY — **DO NOT APPLY**; no file
was edited by this worker):

- In `variant3d/scripts/terrain_donor_gen.gd` `_resolve_settings`
  (task-cited `:1266`, current `:1267`): replace the grid-derived fallback
  `3 if _grid_w == 256 else 2` with the donor unconditional default `0`, i.e.
  `var mapsize: int = int(p.get("mapsize", 0))  # initmapsettings.inc:10;
  0→320 donewgame.inc:42-43,48; miscext2.script:19-20,25`.
- Do NOT add any `w → mapsize` inference (no `if _grid_w==…` form conforms;
  donor data-flow is strictly `mapsize → w`).
- Separately (config layer, same ticket family, also NOT edited here):
  `variant3d/scripts/config.gd:132-133` defaults `240` and `:538-539`
  `num(…, 240)` fallbacks have no donor basis; conforming values are `320`
  (donor default size). Whether the 240 debug-alias grids remain legal port
  inputs is a port-design decision outside this law — but they must stay
  labelled non-donor (`PORT_DEBUG_ALIASES`, as `terrain_donor_data.gd:45`
  already does), never presented as donor sizes.

No `[U]` block is needed for the default — it is closed. Remaining `[U]`
(non-blocking for THIS law, recorded so the chain stays honest):

- U-MAPSIZE-LIVENESS: which `mapsize` tag is live in any given session
  (menu pick / roomdata / quickplay-forced-3) — needs the owner live-settings
  dump; zero-mismatch termination: dumped `gMap.settings.gen.mapsize` integer
  selects the §1.1 row on both sides of `>2` with 0 mismatching words.
- U-MAPSIZE-NATIVE-VALUE: typed decode of the `DefaultMapSize` property-table
  default word — needs a table-schema anchor (second instance framing or a
  reader consuming the framing); adjacent-word guessing refused (carried from
  DEC_U_b45_residual / DEC_U_b5_ver_residual).
- U-240-CONSEQUENCE: what a donor build does when handed 240 (falls to
  `else → 320` per text, but no live 240-request trace exists) — stays `[U]`
  as a runtime question, not a law question.

## Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | Enum law `0→320, 1→480, 2→640, 3→256, else→320`, square (`w,w`), from `donewgame.inc:41-48,166` + `miscext2.script:7-38` | `[O]` re-read this pass |
| 2 | Unset default `gMap.settings.gen.mapsize := 0` from `initmapsettings.inc:10` (+`:45` execution); combobox default index 1 = Normal/tag 0 (`showcustomgame.inc:242-246,821-822`); setter `:69` writes tag verbatim; roomdata `:2370/:2631`; quickplay forces `3` (`doprogressquickplay{1x1:945,2x2:1136}`) | `[O]` re-read this pass |
| 3 | `[D]` donor default = `mapsize 0` = 320×320; `mapsize>2 ≡ 256 TINY` (`dogenerate.inc:571,658`); cap 640 (`dmscript.global:132-135`) | `[D]` over 1–2 |
| 4 | 240 never a donor size: four-member universe in both case sites; `240` grep hits all unrelated (`minimap.cfg:2-6`, leaderboard counts, glyph 240, upgrade/economy literals, GUI offsets); shipped extents 320²/384² (carried); port self-labels 240 debug alias (`terrain_donor_data.gd:44-46`, `config.gd:131-133,538-539`) | `[O]`/`[D]` this pass + carried shipped heads |
| 5 | Port `p.get("mapsize", 3 if _grid_w==256 else 2)` (`terrain_donor_gen.gd:1267`, task-cited :1266) is grid-derived, uncited, inverts donor data-flow, defaults non-256 to 2 (640) vs donor 0 (320) | `[O]` port read + `[D]` vs 1–3 |
| 6 | Native: `DefaultMapSize` 2 hits `0x71c30e/0x71d19c` (`ev_cb420f37…` this pass); `mapsize` 0 hits (`ev_e3592b6a…` this pass); table-row structure only, no default value decoded (carried discipline) | `[O]` native this pass + carried |
| 7 | Minimal conforming change stated, NOT applied: `p.get("mapsize", 0)` + config 240→320; no `w→mapsize` inference conforms | `[D]` prescription, unexecuted |
| 8 | No donor binary executed, no Godot/process run, no code/config edited, exactly one file written; `parity.claim = NONE`, `parity.status = UNVERIFIED` | `[O]` scope guard |

Verdict (governing form): `port=UNVERIFIED`; `parity.claim = NONE`;
`parity.status = "UNVERIFIED"`; six-condition chain **0/6 CLOSED**;
**RESULT IS NOT GOOD** while any `[U]` above is non-empty. No invented size;
no parity claim of any kind.

*End of MAPSIZE_law. Read-only; exactly one repository file written; no
source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
