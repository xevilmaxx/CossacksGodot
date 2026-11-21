# DE — Audio / UI / locale decomp findings

Agent DE (decompilation lane §5a). Donor is **PRIVATE USE ONLY**: all donor
inspection was read-only (`core_archive_show`, `core_text_read`, directory
listing); no donor file was copied into this repo and no donor executable was
run. This file is the only file DE changed.

## Family inventory

Counts are from the full donor folder inventory
`ev_bd4dc176de0eb461bfee69e52e7fc061fafa35647d5798ad9bdef1a7fbcee676`
(17,528 entries / 17,237 files). Port counts are from read-only inspection of
`app/`.

| Family | Donor count / path | Port equivalent | Status | Evidence id |
|---|---|---|---|---|
| Audio | 325 `.ogg` + 3 `.snd` manifests; `data/sounds/ambient` (28), `interface` (52), `units` (248) | `app/assets/sounds/**` — 305 `.ogg` (all donor names except 20) | **PARTIAL — 20 nation tracks missing**; chop present as `workwood1..9.ogg` but not wired | ev_bd4dc176…, fnd_17/fnd_18/fnd_19 |
| Nation music | `data/sounds/ambient/<code>.ogg` — 22 nation codes (`alg,bat1,aus,bav,den,eng,fra,hun,net,pie,pol,por,pru,rus,sax,sco,spa,swe,swi,tur,ukr,ven`); `rus.ogg`, `ukr.ogg` present in port | `audio.gd:start_music()` loads `res://assets/sounds/<nation>.ogg`; only `rus.ogg` + `ukr.ogg` exist | **GAP — 20 of 22 silent**, incl. default enemy `bav` | ev_bd4dc176…, fnd_19 |
| Locale / strings | 11 languages × ~97–99 files; 1,093 `.lng` + 1 `.loc` + 1,086 `.txt`; `data/locale/{cs,de,en,es,fr,it,pl,po,ru,tu,uk}/` (`gui.txt` = 937 lines, mission tables) | none — all UI text hardcoded English in `hud.gd`, `menu.gd`, `config.gd` | **MISSING** (no locale asset or translation layer) | ev_90e0959…, ev_bd4dc176…, fnd_21 |
| UI definitions | 455 `.inc` (133 `data/gui/menu.inc/*`, 3 `common.inc/*`), `data/gui/menu.cfg`, `data/gui/menu.aix` | hand-built GDScript controls in `menu.gd` / `hud.gd`; no `.inc`/`.aix` | **APPROXIMATED** — menu structure/hints rebuilt, not data-driven | ev_75d79f6…, ev_b7e35c2…, ev_bd4dc176…, fnd_21 |
| Cursors / icons | 264 `.bmp` (UI bitmaps + font atlases), 8 `.cur` in `data/cursors/textures/cur/`, `data/hud/textures/**` | 13 `.bmp` in `app/assets/ui/` (11 cursors + `icons.bmp` + `iconsunits.bmp`), rest generated PNG | **PARTIAL** — hand-drawn equivalents | ev_bd4dc176… |
| Fonts | no `.ttf`/`.otf`; `data/hud/font*.lib`, `data/hud/ref/{1250,1251,1252}/reffont*.lib`, codepage BMP atlases `font.sans.*.bmp` / `font.serif.*.bmp` | Godot built-in font; 4 `.lib` are terrain decals, not fonts | **APPROXIMATED** | ev_bd4dc176… |
| Hotkeys | `data/game/var/hotkeys.cfg` (243 lines) + 74 `.cfg` total | `app/config.json` `hotkeys{}` (~30 entries) + `input_controller.gd` + `Data.HOTKEYS` | **PARTIAL** — ~6 binding families absent | ev_cf45b67…, ev_7d1a569…, fnd_20 |

## Concrete missing items (exact donor filenames)

A read-only basename diff of `data/sounds/**/*.ogg` against
`app/assets/sounds/**/*.ogg` gives donor 325, port 305, **20 missing, 0 extra**:

```
data/sounds/ambient/alg.ogg    data/sounds/ambient/aus.ogg    data/sounds/ambient/bat1.ogg
data/sounds/ambient/bav.ogg    data/sounds/ambient/den.ogg    data/sounds/ambient/eng.ogg
data/sounds/ambient/fra.ogg    data/sounds/ambient/hun.ogg    data/sounds/ambient/net.ogg
data/sounds/ambient/pie.ogg    data/sounds/ambient/pol.ogg    data/sounds/ambient/por.ogg
data/sounds/ambient/pru.ogg    data/sounds/ambient/sax.ogg    data/sounds/ambient/sco.ogg
data/sounds/ambient/spa.ogg    data/sounds/ambient/swe.ogg    data/sounds/ambient/swi.ogg
data/sounds/ambient/tur.ogg    data/sounds/ambient/ven.ogg
```

(`rus.ogg`, `ukr.ogg` are already ported.) The 3 donor `.snd` files
(`ambient.snd`, `interface.snd`, `units.snd`) are bank manifests, not playable
audio; they are deliberately not ported.

### Chop — silent event, not a missing file

- Donor: `data/sounds/units/workwood1.ogg` … `workwood9.ogg` (axe chop);
  `workconstruct1..12.ogg` (hammer), `workstone1..11.ogg` (mining). All present
  in `app/assets/sounds/`.
- Port: `main.gd:1063-1065` handles `post_event("chop", …)` with
  `_play(["chop"], -8.0, ev.pos)`. `audio.gd:names_for()` only matches file
  names beginning with the given prefix, so `chop*` matches nothing and the
  sound is silent. Fix is a one-line mapping to `["workwood"]` (fnd_18).

### Hotkey mappings the port approximated

From `hotkeys.cfg` (ev_cf45b67… / ev_7d1a569…) vs `app/config.json` `hotkeys`:

| Donor binding | Donor action | Port state |
|---|---|---|
| `Ctrl+Alt+A` / `Ctrl+Shift+A` | `select|militaryunits` | absent |
| `Ctrl+Q` | `select|allships` | absent |
| `Ctrl+Z`, `Ctrl+Shift+Z` | `select|allunitsofsametype`, `addallunitsofsametype` | absent (`Z`/`Shift+Z` for same-type exist) |
| `Ctrl+P` + alternative `` ` `` | `select|idlepeasants` | `Ctrl+P` only; alternative absent |
| `Q` | `interface|viewcollision` | port `Q` = patrol |
| `C/R/S/E/L/X/M` (on key-up) | main-menu Campaign / Random map / Settings / Editor / Load / Exit / Multiplayer | menu buttons only, no mnemonics |
| `P` | `build|%com%por` | no `P` build binding (port `N` = mine, `W` = wall) |

Build keys C/H/L/B/E/S/R/D/K/J/I/O/M/N/T are otherwise aligned with donor;
port adds `wal: W` and `bar18: K` (donor K is `%nat%ba2`).

### Strings / menu structure the port approximated

Donor `data/locale/en/gui.txt` (ev_90e0959…) is an `@key` → value table whose
values the port hardcodes or paraphrases:

```
@ver  PEGI v%ver%%dataver%      @name.def  Cossack
@restype.1 Food   @restype.2 Wood   @restype.3 Stone   @restype.4 Gold
@restype.5 Iron   @restype.6 Coal
@text.win  VICTORY! Press ESC to exit.     @text.lose  DEFEAT! Press ESC to exit.
@info.population  Population: %amount%     @info.kills  Kills: %amount%
@log.notenoughres  Insufficient resources: %s1%
@log.famine  WARNING! A famine has befallen your state!
```

Donor `data/gui/menu.cfg` (ev_75d79f6…) binds a state machine to `menu.aix`
with `StateCreateGUI=DoCreate`, `StateProgressGUI=DoProgress`,
`StateOnHintGUI=OnHint`, `DefaultCursorIndex=0`, `KeyRepeatDelay=0.05`,
`KeyDoubleDelay=0.5`, `HintWaitDelay=0.1`. `donewgame.inc`
(ev_b7e35c2…) shows menu scripts drive map-size generation (320/480/640/256),
`SoundManagerUnloadAmbientThreads`, `RegisterShortcuts`, DLC gating and
`'Creating new map...'` progress text. The port reproduces the *behaviour*
in `menu.gd`/`main.gd` with literal English labels, not these data files.

## Worker-ticket estimate (player-visible first)

| Ticket | Priority | Scope | Estimate |
|---|---|---|---|
| T-DE-01 Wire `chop` → `workwood` in `main.gd:1065`, verify sound fires on tree chop | **P0** | 1 line + selftest | **0.25 d** |
| T-DE-02 Port the 20 missing `data/sounds/ambient/<code>.ogg` to `app/assets/sounds/` and make `audio.start_music()` fall back when a nation id has no track (covers `bav` default and any custom id) | **P0** | 20 assets + alias/fallback + smoke test | **1 d** |
| T-DE-03 Close hotkey gaps: military/ships/all-same-type selects, `Ctrl+P` alternative `` ` ``, menu mnemonics C/R/S/L, resolve `Q` collision | P1 | config.json + input_controller.gd + menu.gd | **1 d** |
| T-DE-04 Import `en/gui.txt` as a keyed string table and bind the ~20 highest-visibility HUD/menu strings (resources, victory/defeat, population, hints) | P2 | new locale loader + hud/menu edits | **2 d** |
| T-DE-05 Remaining 10 language tables + UI cursor/icon/font-atlas parity (264 BMP / 8 CUR family) | P3 | bulk import + QA screenshot pass | **3 d** |

## Findings ids (craft session)

- `fnd_17` DE-1 audio inventory / exact 20-file gap
- `fnd_18` DE-2 chop mapping, files already present
- `fnd_19` DE-3 nation music silent for 20 nations
- `fnd_20` DE-4 hotkey mapping gaps
- `fnd_21` DE-5 locale / UI data-driven vs hardcoded

Evidence ids: `ev_bd4dc176…` (full archive), `ev_cf45b67…` + `ev_7d1a569…`
(hotkeys.cfg pages), `ev_90e0959…` (en/gui.txt), `ev_75d79f6…` (menu.cfg),
`ev_b7e35c2…` (donewgame.inc).
