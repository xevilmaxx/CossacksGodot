---
id: DEC-02
title: Full catalog and decompiled logic of donor data\scripts
area: donor / decompilation / scripts
owner: DEC-02 (subagent)
date: 2026-11-25
status: COMPLETE — 222/222 files catalogued; 20 gameplay systems translated to pseudocode
tools: Python 3.14 read-only bytes/latin-1/cp1251; Craft Anything core_text_read (5 corroborating reads)
compliance: donor READ-ONLY, never executed, no donor bytes copied into repo, no code edits
---

# DEC-02 — Full catalog and decompiled logic of donor `data\scripts`

## 1. Goal

Produce the exhaustive catalog of **every** file under
`C:\Games\Cossacks 3\data\scripts` (including nested directories), with size,
text/binary class, encoding and a faithful syntax/purpose description; translate
the gameplay-relevant logic into pseudocode with exact `path:line` citations;
focus on selection/micro, formations, morale, AI, economy, build/recruit,
terrain/decor, camera, FX, weather/season and hotkeys; cross-reference the 2D
port's current implementation (secondary); and record corrections, ranked
porting implications, open questions and an evidence index.

**Donor is truth.** Donor files were opened in place with Python `bytes` reads
and decoded with `latin-1` first, then `cp1251` where high bytes occurred. No
donor executable was run, no donor file was copied into the repository, no Godot
process was started, and no code file was edited. The only repository file
written is this report.

Label convention used throughout: **observed** = literal bytes/text or tool
output; **derived** = arithmetic/control-flow following directly from observed
text; **inferred** = strong but indirect interpretation; **UNVERIFIED** = no
plaintext evidence found.

---

## 2. Prior docs read (all eight, as instructed)

| # | Document | What it contributed / how this report treats it |
|---|---|---|
| P1 | `docs/decomp/DB_SCRIPTS.md` | First pass over 8 configs + 4 `common.inc` files; file table, generator constants, G1–G7 gaps, DB-01..DB-06 ticket estimates. **Corrected here** on CP1251 encoding, DLC5 version gate, and current port state. |
| P2 | `docs/audit/DECOMP.md` | Independent audit: `formations.cfg` 149 records / 137 symmetry / **46** nonzero / **15** exact `(2,2,7,7)`. Confirmed again independently here by reading the *consumer* `_init_InitializeFormations` (`lib/init.script:7-81`). |
| P3 | `docs/coord_swarm_2026-11-24/reports/DECOMP_02_rtti_terrain_classes.md` | Delphi RTTI names (`XTerrain`, `XHeightField`, `XBrush`, `XTileSeason`, `XMapGenerator`…) with **0 code xrefs**; establishes that implementation lives in external text, not the PE. This report documents that external text. |
| P4 | `docs/coord_swarm_2026-11-24/reports/DECOMP_04_strings_config.md` | CODE-resident config keys and the real consumer `sub_7ab704` reading `SphereHeight`, `DynFogDepth`, `FocalLength`. **Joined here** to `lib/control.script:574-665`, which loads `.\data\cameras\camera.cfg` with exactly those keys. |
| P5 | `docs/coord_swarm_2026-11-24/reports/DECOMP_05_static_vs_runtime.md` | No runtime unpacking; static function-by-function decompilation only. This report stays entirely in plaintext donor data. |
| P6 | `docs/audit/DONOR_RECRUIT_MODIFIERS.md` | Shift=5 / Ctrl=∞ / Ctrl+Alt=100 / Ctrl+Shift=5×∞ click modifiers, `gc_obj_order_produce_infinite=-1`. **Re-verified here** from `lib/unit.script:10362-10365` and `dmscript.global:660`. Its "port gap" section is now **stale**: see §8. |
| P7 | `docs/research/RB_MECHANICS.md` | Public-source mechanic checklist and gaps G-01..G-14. **Corrected here**: market is mean-reverting with exact formulas; "morale" as a numeric stat does not exist in scripts; famine is a death-probability roll, not HP drain. |
| P8 | `investigation.cany/investigation/findings.md` | fnd_1..fnd_4 constants (26.666 px/m, 32 fps, gather hits, damage formula) — all re-observed at `dmscript.global:170-182,799-801` and `lib/miscext2.script:332-440`. |

---

## 3. Method and corpus facts

- **Enumeration:** `os.walk` over `C:\Games\Cossacks 3\data\scripts`, sorted; **222 files, 4,373,442 bytes** (observed). Zero NUL bytes in all 222 files; zero BOMs. All files use **CRLF** line endings (observed).
- **Encoding:** 203 files are pure 7-bit ASCII; **19 files contain Windows-1251 Cyrillic in comments only** (all executable tokens remain ASCII). UTF-8 strict decode fails on those 19; `cp1251` decodes them correctly (e.g. `dmscript.global:508` → `Культивировать новые сорта пшеницы…`). Craft Anything `core_text_read` reports `encoding: utf8` with `replaced_sequences` equal to the high-byte count (4,770 for `dmscript.global`, 1,137 for `lib/player.script`), confirming the replacement rather than a UTF-8 decode — evidence `ev_462f7a319d79c987b7381bb56e46e6e928be7022685e1060d438b8020682dae9`. **Correction to P1**, which described these scripts generically as UTF-8 text.
- **Dialect:** Delphi-like **DScript**. Two containers:
  1. Plain code files (`.script`, `.global`, `.source`, `resource.script`) — `section.begin`, `function`/`procedure … begin … end;`, `//` and `{ … }` comments.
  2. `.inc` **code wrappers** — `section.begin / Name = … / UsedFile = True / UsedFileName = … / Code : struct.begin`, with every code line stored as `[*] = ;<line>`, ending `struct.end / section.end`. All citations below quote the *unwrapped* line but keep the physical file line number.
  3. `.aix` **manifests** — only `section.begin … Name = <event> … UsedFileName = .\data\scripts\…` records; no code. 13 files.
  4. `patch.txt` — modder changelog, not executable.
- **Normalisation:** a corpus of all 222 files was built with the `[*] = ;` prefix stripped; index of **1,465 constants** (all in `dmscript.global`; other files use prefixed `const cX = …` declarations), **1,752 procedure/function declarations**, **92 `ExecuteState`/handler registrations**, **8,036 `_xxx(...)` calls** (derived from the observed corpus).
- **Duplicate content (observed, SHA-256):** `misc/ballon.inc/nothing.inc` = `misc/movearrow.inc/nothing.inc` = `units/group.inc/nothing.inc` (identical 54 B stubs); `units/building.inc/onbeforesave.inc` = `units/unit.inc/onbeforesave.inc` (identical 90 B stubs).
- **Corroboration:** 5 read-only Craft Anything `core_text_read` calls minted evidence ids (§12). Line numbers from Python and from Craft Anything agree on content lines; a trailing empty physical line may be counted by Python but not by Craft Anything's `total_lines`.

### 3.1 Full file table (222 files)

Columns: path relative to `C:\Games\Cossacks 3\data\scripts`; size in bytes; physical lines (CRLF `splitlines()`); encoding class; syntax container; purpose (observed from `Name =`, declarations and stage code; **inferred** where it is a summary label).

| path | bytes | lines | encoding | syntax | purpose |
|---|---:|---:|---|---|---|
| `common.aix` | 3027 | 129 | ASCII | manifest (.aix) | state-machine manifest: 18 section(s) -> .inc handlers [InitMap,OnInit,OnSave,OnLoad] |
| `common.inc/dogenerate.inc` | 109219 | 2103 | ASCII+CP1251 comments | code in .inc wrapper | DoGenerate: full random-map generation stages, starts, mines, formations |
| `common.inc/dogeneratemissionmap.inc` | 219 | 9 | ASCII | code in .inc wrapper | DoGenerateMissionMap stub |
| `common.inc/generatemap.inc` | 51794 | 1059 | ASCII | code in .inc wrapper | GenerateMap: heightmap from terrain masks, water, forests, smoothing |
| `common.inc/initmap.inc` | 4003 | 95 | ASCII | code in .inc wrapper | InitMap: create players, reset map settings |
| `common.inc/initmapgen.inc` | 13193 | 289 | ASCII | code in .inc wrapper | InitMapGen: players + starting resources via startingsettings.cfg |
| `common.inc/initmaphistoricalbattle.inc` | 7156 | 166 | ASCII | code in .inc wrapper | historical-battle init, service players and country availability |
| `common.inc/loadenvironmentfrombitmap.inc` | 3049 | 85 | ASCII | code in .inc wrapper | load decor/environment from bitmap mask (season-aware) |
| `common.inc/loadtextureterrainfrombitmap.inc` | 1885 | 49 | ASCII | code in .inc wrapper | load terrain texture from bitmap |
| `common.inc/oninit.inc` | 68 | 5 | ASCII | code in .inc wrapper | OnInit stub |
| `common.inc/onload.inc` | 2359 | 52 | ASCII | code in .inc wrapper | OnLoad: locale table for mission, trigger state machine creation |
| `common.inc/onloadfull.inc` | 6350 | 133 | ASCII | code in .inc wrapper | OnLoadFull: post-load season/FX/color-table setup |
| `common.inc/onsave.inc` | 1221 | 28 | ASCII | code in .inc wrapper | OnSave: save state dispatch |
| `common.inc/postprocess.inc` | 19416 | 466 | ASCII | code in .inc wrapper | PostProcess: terrain-mask noise/filter passes (plateau/water/border) |
| `common.inc/saveenvironmenttobitmap.inc` | 4397 | 92 | ASCII | code in .inc wrapper | save decor/environment to bitmap mask |
| `common.inc/smoothforestborders.inc` | 7791 | 171 | ASCII | code in .inc wrapper | SmoothForestBorders: forest edge tile blending |
| `common.inc/smoothtiles.inc` | 10691 | 246 | ASCII | code in .inc wrapper | SmoothTiles: tile-index neighbour smoothing |
| `common.inc/texturemap.inc` | 48954 | 963 | ASCII | code in .inc wrapper | TextureMap: collision painting, tile selection, forest placement, season suffix |
| `dmscript.global` | 91341 | 2400 | ASCII+CP1251 comments | code (.script/.global/.source) | global constants, type declarations (struct), global vars |
| `dmscript.source` | 20221 | 558 | ASCII | code (.script/.global/.source) | bootstrap: init vars, Files load order, protected/private/global lists |
| `env/env.aix` | 1757 | 81 | ASCII | manifest (.aix) | state-machine manifest: 12 section(s) -> .inc handlers [OnTagStates,SetTagStates,Initial,InitialDecor] |
| `env/env.inc/dodeath.inc` | 168 | 9 | ASCII | code in .inc wrapper | env/decor object state: DoDeath |
| `env/env.inc/dodestroy.inc` | 213 | 9 | ASCII | code in .inc wrapper | env/decor object state: DoDestroy |
| `env/env.inc/doextract.inc` | 466 | 16 | ASCII | code in .inc wrapper | env/decor object state: DoExtract |
| `env/env.inc/initial.inc` | 6354 | 121 | ASCII | code in .inc wrapper | env/decor object state: Initial |
| `env/env.inc/initialdecor.inc` | 2051 | 42 | ASCII | code in .inc wrapper | env/decor object state: InitialDecor |
| `env/env.inc/nothing.inc` | 5889 | 103 | ASCII | code in .inc wrapper | env/decor object state: Nothing |
| `env/env.inc/nothingdecor.inc` | 54 | 4 | ASCII | code in .inc wrapper | env/decor object state: NothingDecor |
| `env/env.inc/onafterload.inc` | 181 | 9 | ASCII | code in .inc wrapper | env/decor object state: OnAfterLoad |
| `env/env.inc/ondestroy.inc` | 2648 | 61 | ASCII | code in .inc wrapper | env/decor object state: OnDestroy |
| `env/env.inc/ontagstates.inc` | 6685 | 146 | ASCII | code in .inc wrapper | env/decor object state: OnTagStates |
| `env/env.inc/settagstates.inc` | 1098 | 27 | ASCII | code in .inc wrapper | env/decor object state: SetTagStates |
| `lib/ai.script` | 95596 | 2530 | ASCII | code (.script/.global/.source) | army analysis, army orders, enemy tracking, unit/upgrade lists |
| `lib/classes.script` | 256161 | 8123 | ASCII | code (.script/.global/.source) | OO/struct runtime: TObj/TSquad/TPlayer/TFormation/TWeapon/TPlayer types + helpers |
| `lib/control.script` | 29015 | 764 | ASCII+CP1251 comments | code (.script/.global/.source) | selection (all/units/ships/peasants/idle mines), cursor picking, camera moves |
| `lib/country.script` | 355207 | 4283 | ASCII | code (.script/.global/.source) | country/nation definitions, unit rosters, officer-formation masks |
| `lib/group.script` | 5459 | 187 | ASCII+CP1251 comments | code (.script/.global/.source) | group formation geometry (cols/rows, shift by direction) |
| `lib/gui.script` | 169837 | 3572 | ASCII | code (.script/.global/.source) | GUI element creation, tags, fonts, colours, update dispatch |
| `lib/init.script` | 11328 | 258 | ASCII | code (.script/.global/.source) | startup initialisers (formations, topology, game settings, sound listener) |
| `lib/map.script` | 12169 | 337 | ASCII+CP1251 comments | code (.script/.global/.source) | map/start-point setup, historical-battle country availability |
| `lib/misc.script` | 250432 | 7013 | ASCII+CP1251 comments | code (.script/.global/.source) | core geometry, collision, patterns, damage helpers, selection/scoring utilities |
| `lib/miscext.script` | 74037 | 1628 | ASCII+CP1251 comments | code (.script/.global/.source) | extra search/spiral-grid/order-progress helpers |
| `lib/miscext2.script` | 207723 | 4743 | ASCII+CP1251 comments | code (.script/.global/.source) | damage, round damage, walls, alarms, projectile simulation |
| `lib/miscext3.script` | 10948 | 306 | ASCII | code (.script/.global/.source) | quick-play and reconnect session management |
| `lib/movie.script` | 47874 | 1183 | ASCII | code (.script/.global/.source) | camera save/load/move, fades, movie playback |
| `lib/net.script` | 6381 | 198 | ASCII | code (.script/.global/.source) | network session/replay/record mode helpers |
| `lib/parser.script` | 2379 | 99 | ASCII | code (.script/.global/.source) | parser handle wrappers (load/select/value get/set) |
| `lib/pfx.script` | 17880 | 415 | ASCII | code (.script/.global/.source) | particle-effect instance pool (Create/GetOrCreate/Save/Load) |
| `lib/player.script` | 145234 | 3517 | ASCII+CP1251 comments | code (.script/.global/.source) | players, economy tick, squad/order/group commands, construction, upgrades |
| `lib/profile.script` | 28042 | 740 | ASCII | code (.script/.global/.source) | player profile defaults, locale, graphics settings, famine toggle |
| `lib/res.script` | 13604 | 360 | ASCII+CP1251 comments | code (.script/.global/.source) | resource pools, grids, income/consume, market pricing and trade |
| `lib/scenario.script` | 208321 | 3346 | ASCII | code (.script/.global/.source) | scenario/trigger compile, text formatting, in-game trigger actions |
| `lib/scenarioeditor.script` | 10511 | 206 | ASCII | code (.script/.global/.source) | trigger condition/action registries |
| `lib/serial.script` | 96599 | 2980 | ASCII | code (.script/.global/.source) | save/load serialisation of players, squads, objects, triggers |
| `lib/sound.script` | 28196 | 586 | ASCII | code (.script/.global/.source) | sound library registration and emitter playback |
| `lib/squad.script` | 24609 | 785 | ASCII | code (.script/.global/.source) | squad membership, formation placement/symmetry, fill, central position |
| `lib/steam.script` | 28586 | 729 | ASCII | code (.script/.global/.source) | Steam achievements/workshop/cloud state |
| `lib/ui.script` | 22959 | 388 | ASCII | code (.script/.global/.source) | UI engine containers/buttons/text initialisation |
| `lib/unit.script` | 560101 | 12381 | ASCII+CP1251 comments | code (.script/.global/.source) | unit creation, orders, costs, production, AI targeting, movement, runaway |
| `lib/weapon.script` | 68889 | 1266 | ASCII | code (.script/.global/.source) | weapon/projectile definitions, trails, sounds, decals, custom explosions |
| `misc/airegion.aix` | 2984 | 73 | ASCII | manifest (.aix) | state-machine manifest: 2 section(s) -> .inc handlers [OnInclude,OnDeclude] |
| `misc/ballon.aix` | 1217 | 54 | ASCII | manifest (.aix) | state-machine manifest: 8 section(s) -> .inc handlers [OnTagStates,SetTagStates,Initial,Nothing] |
| `misc/ballon.inc/initial.inc` | 1452 | 34 | ASCII | code in .inc wrapper | FX/object state: Initial |
| `misc/ballon.inc/nothing.inc` | 49 | 4 | ASCII | code in .inc wrapper | FX/object state: Nothing |
| `misc/ballon.inc/onaclanimationend.inc` | 738 | 19 | ASCII | code in .inc wrapper | FX/object state: OnAclAnimationEnd |
| `misc/ballon.inc/onaclanimationfloat.inc` | 5953 | 91 | ASCII | code in .inc wrapper | FX/object state: OnAclAnimationFloat |
| `misc/ballon.inc/onendframereached.inc` | 188 | 9 | ASCII | code in .inc wrapper | FX/object state: OnEndFrameReached |
| `misc/ballon.inc/ontagstates.inc` | 5643 | 96 | ASCII | code in .inc wrapper | FX/object state: OnTagStates |
| `misc/ballon.inc/settagstates.inc` | 891 | 23 | ASCII | code in .inc wrapper | FX/object state: SetTagStates |
| `misc/movearrow.aix` | 925 | 40 | ASCII | manifest (.aix) | state-machine manifest: 5 section(s) -> .inc handlers [Initial,Nothing,OnEndFrameReached,OnAfterLoad] |
| `misc/movearrow.inc/dodestroy.inc` | 51 | 4 | ASCII | code in .inc wrapper | FX/object state: DoDestroy |
| `misc/movearrow.inc/initial.inc` | 973 | 24 | ASCII | code in .inc wrapper | FX/object state: Initial |
| `misc/movearrow.inc/nothing.inc` | 49 | 4 | ASCII | code in .inc wrapper | FX/object state: Nothing |
| `misc/movearrow.inc/onafterload.inc` | 308 | 11 | ASCII | code in .inc wrapper | FX/object state: OnAfterLoad |
| `misc/movearrow.inc/onendframereached.inc` | 314 | 11 | ASCII | code in .inc wrapper | FX/object state: OnEndFrameReached |
| `misc/projectile.aix` | 2725 | 115 | ASCII | manifest (.aix) | state-machine manifest: 16 section(s) -> .inc handlers [Initial,Nothing,InitialEmpty,NothingEmpty] |
| `misc/projectile.inc/dodeath.inc` | 704 | 19 | ASCII | code in .inc wrapper | FX/object state: DoDeath |
| `misc/projectile.inc/dodestroy.inc` | 256 | 11 | ASCII | code in .inc wrapper | FX/object state: DoDestroy |
| `misc/projectile.inc/doexplode.inc` | 13367 | 234 | ASCII | code in .inc wrapper | FX/object state: DoExplode |
| `misc/projectile.inc/doexplodecustom.inc` | 11700 | 206 | ASCII | code in .inc wrapper | FX/object state: DoExplodeCustom |
| `misc/projectile.inc/freetopool.inc` | 463 | 15 | ASCII | code in .inc wrapper | FX/object state: FreeToPool |
| `misc/projectile.inc/freetopoolnext.inc` | 408 | 14 | ASCII | code in .inc wrapper | FX/object state: FreeToPoolNext |
| `misc/projectile.inc/initial.inc` | 561 | 19 | ASCII | code in .inc wrapper | FX/object state: Initial |
| `misc/projectile.inc/initialempty.inc` | 664 | 21 | ASCII | code in .inc wrapper | FX/object state: InitialEmpty |
| `misc/projectile.inc/nothing.inc` | 7266 | 125 | ASCII | code in .inc wrapper | FX/object state: Nothing |
| `misc/projectile.inc/nothingempty.inc` | 54 | 4 | ASCII | code in .inc wrapper | FX/object state: NothingEmpty |
| `misc/projectile.inc/onafterload.inc` | 296 | 9 | ASCII | code in .inc wrapper | FX/object state: OnAfterLoad |
| `misc/projectile.inc/oncollide.inc` | 530 | 16 | ASCII | code in .inc wrapper | FX/object state: OnCollide |
| `misc/projectile.inc/ondestroy.inc` | 388 | 13 | ASCII | code in .inc wrapper | FX/object state: OnDestroy |
| `misc/projectile.inc/onstopevent.inc` | 531 | 17 | ASCII | code in .inc wrapper | FX/object state: OnStopEvent |
| `misc/projectile.inc/onterraincollide.inc` | 536 | 17 | ASCII | code in .inc wrapper | FX/object state: OnTerrainCollide |
| `misc/soundemitter.aix` | 1361 | 63 | ASCII | manifest (.aix) | state-machine manifest: 6 section(s) -> .inc handlers [Initial,Nothing,OnAfterLoad,OnBeforeSave] |
| `patch.txt` | 4434 | 121 | ASCII | changelog (.txt) | modder changelog: script files changed per game version |
| `progress/progress.aix` | 2682 | 112 | ASCII | manifest (.aix) | state-machine manifest: 16 section(s) -> .inc handlers [Initial,OnBeforeSave,OnAfterLoad,Scenario] |
| `progress/progress.inc/initial.inc` | 188 | 10 | ASCII | code in .inc wrapper | progress state machine: Initial |
| `progress/progress.inc/nothing.inc` | 44873 | 762 | ASCII | code in .inc wrapper | progress state machine: Nothing |
| `progress/progress.inc/onafterload.inc` | 147 | 8 | ASCII | code in .inc wrapper | progress state machine: OnAfterLoad |
| `progress/progress.inc/onbeforesave.inc` | 108 | 5 | ASCII | code in .inc wrapper | progress state machine: OnBeforeSave |
| `progress/progress.inc/readlansyncdata.inc` | 3520 | 71 | ASCII | code in .inc wrapper | progress state machine: ReadLanSyncData |
| `progress/progress.inc/readres.inc` | 2781 | 67 | ASCII | code in .inc wrapper | progress state machine: ReadRes |
| `progress/progress.inc/readscenario.inc` | 4341 | 87 | ASCII | code in .inc wrapper | progress state machine: ReadScenario |
| `progress/progress.inc/readstats.inc` | 2789 | 63 | ASCII | code in .inc wrapper | progress state machine: ReadStats |
| `progress/progress.inc/scenario.inc` | 4708 | 99 | ASCII | code in .inc wrapper | progress state machine: Scenario |
| `progress/progress.inc/soundcontrol.inc` | 14698 | 296 | ASCII | code in .inc wrapper | progress state machine: SoundControl |
| `progress/progress.inc/soundcontrolcounters.inc` | 10017 | 198 | ASCII | code in .inc wrapper | progress state machine: SoundControlCounters |
| `progress/progress.inc/writelansyncdata.inc` | 4504 | 97 | ASCII | code in .inc wrapper | progress state machine: WriteLanSyncData |
| `progress/progress.inc/writeres.inc` | 4294 | 96 | ASCII | code in .inc wrapper | progress state machine: WriteRes |
| `progress/progress.inc/writescenario.inc` | 7393 | 115 | ASCII | code in .inc wrapper | progress state machine: WriteScenario |
| `progress/progress.inc/writestats.inc` | 4980 | 105 | ASCII | code in .inc wrapper | progress state machine: WriteStats |
| `resource.script` | 3066 | 75 | ASCII | code (.script/.global/.source) | locale resource cache generator + Steam Workshop init (startup) |
| `units/building.aix` | 2393 | 105 | ASCII | manifest (.aix) | state-machine manifest: 16 section(s) -> .inc handlers [OnTagStates,SetTagStates,Initial,Nothing] |
| `units/building.inc/deathstage1.inc` | 569 | 16 | ASCII | code in .inc wrapper | building state/event: DeathStage1 |
| `units/building.inc/deathstage2.inc` | 1108 | 25 | ASCII | code in .inc wrapper | building state/event: DeathStage2 |
| `units/building.inc/delaydestroy.inc` | 285 | 10 | ASCII | code in .inc wrapper | building state/event: DelayDestroy |
| `units/building.inc/doprogressorders.inc` | 26651 | 416 | ASCII+CP1251 comments | code in .inc wrapper | building state/event: DoProgressOrders |
| `units/building.inc/initial.inc` | 21477 | 395 | ASCII+CP1251 comments | code in .inc wrapper | building state/event: Initial |
| `units/building.inc/nothing.inc` | 29774 | 497 | ASCII+CP1251 comments | code in .inc wrapper | building state/event: Nothing |
| `units/building.inc/onafterload.inc` | 328 | 13 | ASCII | code in .inc wrapper | building state/event: OnAfterLoad |
| `units/building.inc/onbeforesave.inc` | 90 | 5 | ASCII | code in .inc wrapper | building state/event: OnBeforeSave |
| `units/building.inc/oncollided.inc` | 88 | 5 | ASCII | code in .inc wrapper | building state/event: OnCollided |
| `units/building.inc/ondeath.inc` | 1662 | 39 | ASCII | code in .inc wrapper | building state/event: OnDeath |
| `units/building.inc/ondestroy.inc` | 1263 | 31 | ASCII | code in .inc wrapper | building state/event: OnDestroy |
| `units/building.inc/ontagstates.inc` | 27317 | 472 | ASCII | code in .inc wrapper | building state/event: OnTagStates |
| `units/building.inc/onuncollided.inc` | 90 | 5 | ASCII | code in .inc wrapper | building state/event: OnUncollided |
| `units/building.inc/settagstates.inc` | 2897 | 61 | ASCII | code in .inc wrapper | building state/event: SetTagStates |
| `units/global.aix` | 11752 | 497 | ASCII | manifest (.aix) | state-machine manifest: 72 section(s) -> .inc handlers [Initial,OnBeforeSave,OnAfterLoad,Progress] |
| `units/global.inc/checkerrors.inc` | 12445 | 243 | ASCII | code in .inc wrapper | global unit update: CheckErrors |
| `units/global.inc/initial.inc` | 277 | 11 | ASCII | code in .inc wrapper | global unit update: Initial |
| `units/global.inc/onafterload.inc` | 144 | 7 | ASCII | code in .inc wrapper | global unit update: OnAfterLoad |
| `units/global.inc/onbeforesave.inc` | 107 | 5 | ASCII | code in .inc wrapper | global unit update: OnBeforeSave |
| `units/global.inc/progress.inc` | 10962 | 187 | ASCII | code in .inc wrapper | global unit update: Progress |
| `units/global.inc/progressai.inc` | 802 | 21 | ASCII | code in .inc wrapper | global unit update: ProgressAI |
| `units/global.inc/progresseconomicai.inc` | 231799 | 3924 | ASCII | code in .inc wrapper | global unit update: ProgressEconomicAI |
| `units/global.inc/progresswarai.inc` | 228378 | 4261 | ASCII | code in .inc wrapper | global unit update: ProgressWarAI |
| `units/global.inc/readapply.inc` | 1141 | 27 | ASCII | code in .inc wrapper | net read handler: apply |
| `units/global.inc/readconstruct.inc` | 3527 | 71 | ASCII | code in .inc wrapper | net read handler: construct |
| `units/global.inc/readdeath.inc` | 3489 | 78 | ASCII | code in .inc wrapper | net read handler: death |
| `units/global.inc/readfree.inc` | 1729 | 35 | ASCII | code in .inc wrapper | net read handler: free |
| `units/global.inc/readfreelist.inc` | 862 | 23 | ASCII | code in .inc wrapper | net read handler: freelist |
| `units/global.inc/readgate.inc` | 1287 | 33 | ASCII | code in .inc wrapper | net read handler: gate |
| `units/global.inc/readleave.inc` | 825 | 24 | ASCII | code in .inc wrapper | net read handler: leave |
| `units/global.inc/readleaveorder.inc` | 1123 | 30 | ASCII | code in .inc wrapper | net read handler: leaveorder |
| `units/global.inc/readmove.inc` | 3069 | 78 | ASCII | code in .inc wrapper | net read handler: move |
| `units/global.inc/readnew.inc` | 5788 | 104 | ASCII+CP1251 comments | code in .inc wrapper | net read handler: new |
| `units/global.inc/readnewp.inc` | 4021 | 80 | ASCII | code in .inc wrapper | net read handler: newp |
| `units/global.inc/readorder.inc` | 7294 | 120 | ASCII | code in .inc wrapper | net read handler: order |
| `units/global.inc/readpackage.inc` | 772 | 23 | ASCII | code in .inc wrapper | net read handler: package |
| `units/global.inc/readpeacetime.inc` | 1423 | 36 | ASCII | code in .inc wrapper | net read handler: peacetime |
| `units/global.inc/readplayer.inc` | 942 | 24 | ASCII | code in .inc wrapper | net read handler: player |
| `units/global.inc/readproduce.inc` | 1748 | 37 | ASCII | code in .inc wrapper | net read handler: produce |
| `units/global.inc/readproj.inc` | 2766 | 48 | ASCII | code in .inc wrapper | net read handler: proj |
| `units/global.inc/readprojfree.inc` | 1413 | 30 | ASCII | code in .inc wrapper | net read handler: projfree |
| `units/global.inc/readrally.inc` | 1955 | 47 | ASCII | code in .inc wrapper | net read handler: rally |
| `units/global.inc/readsearch.inc` | 1323 | 32 | ASCII | code in .inc wrapper | net read handler: search |
| `units/global.inc/readsquadlistaction.inc` | 12850 | 240 | ASCII | code in .inc wrapper | net read handler: squadlistaction |
| `units/global.inc/readsquadnew.inc` | 4456 | 94 | ASCII | code in .inc wrapper | net read handler: squadnew |
| `units/global.inc/readstand.inc` | 1316 | 32 | ASCII | code in .inc wrapper | net read handler: stand |
| `units/global.inc/readstop.inc` | 1132 | 30 | ASCII | code in .inc wrapper | net read handler: stop |
| `units/global.inc/readsync.inc` | 5951 | 108 | ASCII | code in .inc wrapper | net read handler: sync |
| `units/global.inc/readsyncunitsparams.inc` | 1510 | 40 | ASCII | code in .inc wrapper | net read handler: syncunitsparams |
| `units/global.inc/readtrade.inc` | 1728 | 39 | ASCII | code in .inc wrapper | net read handler: trade |
| `units/global.inc/readtraderesources.inc` | 1777 | 40 | ASCII | code in .inc wrapper | net read handler: traderesources |
| `units/global.inc/readupgrade.inc` | 3540 | 80 | ASCII | code in .inc wrapper | net read handler: upgrade |
| `units/global.inc/readwall.inc` | 10116 | 192 | ASCII | code in .inc wrapper | net read handler: wall |
| `units/global.inc/writeapply.inc` | 1439 | 36 | ASCII | code in .inc wrapper | net write handler: eapply |
| `units/global.inc/writeconstruct.inc` | 2412 | 57 | ASCII | code in .inc wrapper | net write handler: econstruct |
| `units/global.inc/writedeath.inc` | 5220 | 109 | ASCII | code in .inc wrapper | net write handler: edeath |
| `units/global.inc/writefree.inc` | 1184 | 30 | ASCII | code in .inc wrapper | net write handler: efree |
| `units/global.inc/writefreelist.inc` | 1378 | 38 | ASCII | code in .inc wrapper | net write handler: efreelist |
| `units/global.inc/writegate.inc` | 1851 | 48 | ASCII | code in .inc wrapper | net write handler: egate |
| `units/global.inc/writeleave.inc` | 985 | 28 | ASCII | code in .inc wrapper | net write handler: eleave |
| `units/global.inc/writeleaveorder.inc` | 1660 | 44 | ASCII | code in .inc wrapper | net write handler: eleaveorder |
| `units/global.inc/writemove.inc` | 7441 | 164 | ASCII | code in .inc wrapper | net write handler: emove |
| `units/global.inc/writenew.inc` | 4588 | 96 | ASCII | code in .inc wrapper | net write handler: enew |
| `units/global.inc/writenewp.inc` | 3982 | 89 | ASCII | code in .inc wrapper | net write handler: enewp |
| `units/global.inc/writeorder.inc` | 2997 | 64 | ASCII | code in .inc wrapper | net write handler: eorder |
| `units/global.inc/writepackage.inc` | 1066 | 31 | ASCII | code in .inc wrapper | net write handler: epackage |
| `units/global.inc/writepeacetime.inc` | 1478 | 39 | ASCII | code in .inc wrapper | net write handler: epeacetime |
| `units/global.inc/writeplayer.inc` | 1133 | 31 | ASCII | code in .inc wrapper | net write handler: eplayer |
| `units/global.inc/writeproduce.inc` | 2247 | 53 | ASCII | code in .inc wrapper | net write handler: eproduce |
| `units/global.inc/writeproj.inc` | 3368 | 72 | ASCII | code in .inc wrapper | net write handler: eproj |
| `units/global.inc/writeprojfree.inc` | 1208 | 31 | ASCII | code in .inc wrapper | net write handler: eprojfree |
| `units/global.inc/writerally.inc` | 1364 | 36 | ASCII | code in .inc wrapper | net write handler: erally |
| `units/global.inc/writesearch.inc` | 1857 | 47 | ASCII | code in .inc wrapper | net write handler: esearch |
| `units/global.inc/writesquadlistaction.inc` | 2707 | 61 | ASCII | code in .inc wrapper | net write handler: esquadlistaction |
| `units/global.inc/writesquadnew.inc` | 7145 | 146 | ASCII | code in .inc wrapper | net write handler: esquadnew |
| `units/global.inc/writestand.inc` | 1852 | 47 | ASCII | code in .inc wrapper | net write handler: estand |
| `units/global.inc/writestop.inc` | 1574 | 42 | ASCII | code in .inc wrapper | net write handler: estop |
| `units/global.inc/writesync.inc` | 5272 | 110 | ASCII | code in .inc wrapper | net write handler: esync |
| `units/global.inc/writesyncunitsparams.inc` | 1716 | 45 | ASCII | code in .inc wrapper | net write handler: esyncunitsparams |
| `units/global.inc/writetrade.inc` | 1666 | 41 | ASCII | code in .inc wrapper | net write handler: etrade |
| `units/global.inc/writetraderesources.inc` | 1767 | 40 | ASCII | code in .inc wrapper | net write handler: etraderesources |
| `units/global.inc/writeupgrade.inc` | 7251 | 158 | ASCII | code in .inc wrapper | net write handler: eupgrade |
| `units/global.inc/writewall.inc` | 11393 | 202 | ASCII | code in .inc wrapper | net write handler: ewall |
| `units/group.aix` | 375 | 18 | ASCII | manifest (.aix) | state-machine manifest: 2 section(s) -> .inc handlers [Position,Nothing] |
| `units/group.inc/nothing.inc` | 49 | 4 | ASCII | code in .inc wrapper | unit/group manifest |
| `units/group.inc/position.inc` | 86 | 5 | ASCII | code in .inc wrapper | unit/group manifest |
| `units/unit.aix` | 3771 | 159 | ASCII | manifest (.aix) | state-machine manifest: 24 section(s) -> .inc handlers [OnTagStates,SetTagStates,Nothing,DoProgressOrders] |
| `units/unit.inc/deathstage1.inc` | 4790 | 86 | ASCII | code in .inc wrapper | unit state/event: DeathStage1 |
| `units/unit.inc/deathstage2.inc` | 4079 | 84 | ASCII | code in .inc wrapper | unit state/event: DeathStage2 |
| `units/unit.inc/deathstage3.inc` | 4581 | 81 | ASCII | code in .inc wrapper | unit state/event: DeathStage3 |
| `units/unit.inc/deathstage4.inc` | 397 | 11 | ASCII | code in .inc wrapper | unit state/event: DeathStage4 |
| `units/unit.inc/doprogressorders.inc` | 200 | 8 | ASCII | code in .inc wrapper | unit state/event: DoProgressOrders |
| `units/unit.inc/initial.inc` | 18182 | 330 | ASCII+CP1251 comments | code in .inc wrapper | unit state/event: Initial |
| `units/unit.inc/nothing.inc` | 39005 | 596 | ASCII+CP1251 comments | code in .inc wrapper | unit state/event: Nothing |
| `units/unit.inc/onaclanimationreachedattack.inc` | 9775 | 155 | ASCII | code in .inc wrapper | unit state/event: OnAclAnimationReachedAttack |
| `units/unit.inc/onaclanimationreachedattackend.inc` | 688 | 18 | ASCII | code in .inc wrapper | unit state/event: OnAclAnimationReachedAttackEnd |
| `units/unit.inc/onaclanimationreachedconstruct.inc` | 3032 | 54 | ASCII+CP1251 comments | code in .inc wrapper | unit state/event: OnAclAnimationReachedConstruct |
| `units/unit.inc/onaclanimationreachedwork.inc` | 3106 | 62 | ASCII+CP1251 comments | code in .inc wrapper | unit state/event: OnAclAnimationReachedWork |
| `units/unit.inc/onafterload.inc` | 1107 | 28 | ASCII | code in .inc wrapper | unit state/event: OnAfterLoad |
| `units/unit.inc/onbeforesave.inc` | 90 | 5 | ASCII | code in .inc wrapper | unit state/event: OnBeforeSave |
| `units/unit.inc/ondeath.inc` | 1959 | 35 | ASCII | code in .inc wrapper | unit state/event: OnDeath |
| `units/unit.inc/ondestroy.inc` | 974 | 25 | ASCII | code in .inc wrapper | unit state/event: OnDestroy |
| `units/unit.inc/ondirectionreached.inc` | 1929 | 42 | ASCII | code in .inc wrapper | unit state/event: OnDirectionReached |
| `units/unit.inc/onendpointreached.inc` | 3626 | 71 | ASCII | code in .inc wrapper | unit state/event: OnEndPointReached |
| `units/unit.inc/ontagstates.inc` | 58913 | 1010 | ASCII | code in .inc wrapper | unit state/event: OnTagStates |
| `units/unit.inc/position.inc` | 208 | 9 | ASCII | code in .inc wrapper | unit state/event: Position |
| `units/unit.inc/sailtodestroy.inc` | 1674 | 43 | ASCII | code in .inc wrapper | unit state/event: SailToDestroy |
| `units/unit.inc/setrallypoint.inc` | 1401 | 34 | ASCII | code in .inc wrapper | unit state/event: SetRallyPoint |
| `units/unit.inc/settagstates.inc` | 9270 | 155 | ASCII | code in .inc wrapper | unit state/event: SetTagStates |
| `user/user.aix` | 258 | 12 | ASCII | manifest (.aix) | state-machine manifest: 1 section(s) -> .inc handlers [ResetDefaults] |
| `user/user.inc/resetdefaults.inc` | 122 | 7 | ASCII | code in .inc wrapper | user state: ResetDefaults |


---

## 4. Syntax reference and cross-cutting vocabulary

**Statement forms (observed):** `var x : Integer = expr;`, `const c = expr;`,
`if (…) then … else …;`, `case x of v : …; end;`, `for i:=a to b do`,
`for i:=a downto 0 do`, `while`, `procedure/function`, `Result := …`,
`registers` (`IntRegister0`, `FloatRegister0`, `StringRegister0`, `BoolRegister0/5`)
used as a call bridge into engine/GUI state machines, and
`ExecuteState('Name')` / `GUIExecuteState('Name')` / `StateMachineExecuteState(sm,'Name',0)`
to dispatch another state.

**State-machine events (observed, 92 registrations).** The recurring set is:
`Initial`, `Nothing`, `OnTagStates`, `SetTagStates`, `DoProgressOrders`,
`OnDeath`, `DeathStage1..4`, `OnDestroy`, `DoDestroy`, `OnCollide`,
`OnTerrainCollide`, `OnStopEvent`, `OnEndPointReached`, `OnDirectionReached`,
`OnEndFrameReached`, `OnAclAnimationReachedAttack`, `OnAclAnimationReachedWork`,
`OnAclAnimationReachedConstruct`, `OnAfterLoad`, `OnBeforeSave`, plus GUI events
`ShowHUD`, `ShowMainMenu`, `WriteRes`, `ReadRes`, `WriteScenario`, `ReadScenario`,
`WriteStats`, `ReadStats`, `WriteTimeSpeed`, `ShowPause`, `DoUpdateSelection`,
`InitMinimap`, `ShowSettings`, `ShowCustomGame`, `ShowInternetShell`, `ShowNews`,
`ShowModalMessage`, `ShowConnectStateMessage`, and generation events
`InitMap`, `InitMapGen`, `InitMapHistoricalBattle`, `DoGenerate`,
`DoGenerateMissionMap`, `GenerateMap`, `PostProcess`, `TextureMap`,
`SmoothTiles`, `SmoothForestBorders`, `LoadEnvironmentFromBitmap`,
`SaveEnvironmentToBitmap`, `LoadTextureTerrainFromBitmap`, `Progress`,
`ProgressAI`, `ProgressEconomicAI`, `ProgressWarAI`, `CheckErrors`.
(Indexed from all `.aix` manifests and `Name =` lines; individual `path:line`
citations appear in the per-script records and the file table.)

**Global units (observed, `dmscript.global:170-182`):**
`gc_pixels_to_meter = 26.6666666`, `gc_meters_to_tile = 2`,
`gc_pixels_to_tile = 53.3333333`, `gc_tiles_to_pixels = 0.01875`,
`gc_frames_to_time = 0.03125`, `gc_time_to_frames = 32`,
`gc_c1rand_to_random = 32768` (original Cossacks I scale),
`gc_buildtime_modifier = 10`,
`gc_buildtime_progressperhit = 10*0.03125*1.15 = 0.359375 s` (derived).
This closes fnd_1 exactly.

**Limits (observed, `dmscript.global:97-168`):** 12 players, 8 non-spectators,
32,000 objects, 12 orders per object (`gc_obj_MaxOrderCount`, line 113), 280
inside units, 4 weapons + 32 weapon slots, 24 countries (13 release), 640×640
map/collision/terrain grids, 4 scan-grid/res-grid cell size, 8 sound-grid cell
size, 30 builders, 160 formation slots, formation mask max 54×24, 500 squads
per player.

---

## 5. Per-script deep records

### D-01 `dmscript.global` — the constant/type bible (91,341 B, 2,400 lines)

**Syntax (observed):** one `section.begin … section.end`; 1,465 `name = value;`
constant lines plus `struct.begin`/`struct.end` type declarations and global
variable declarations. Lines 1–45 define state-tag bitmasks; 47–81 spatial
grids; 83–94 collision tags; 97–168 engine limits; 203–225 gameplay radii;
235–240 enum counts; 307–339 `gc_obj_usage_*`; 341–601 AI ids/tuning;
630–658 order types/modes; 660 `gc_obj_order_produce_infinite = -1`;
770–815 resources/upkeep; 977–1013 result codes; 1233–1315 sound indices;
1340–1360 file paths; 1618–1625 squad actions; 1871–1880 country officer
formations; 1955–1968 `TFormation`; 2064 `gFormation`; 2110–2112 GUI formation
state. Evidence `ev_462f7a319d79c987b7381bb56e46e6e928be7022685e1060d438b8020682dae9`.

**Key constants (observed / derived):**

| Rule | Citation | Value |
|---|---|---|
| Squad disband threshold | `dmscript.global:156` | `gc_player_SquadDismissPercent = 0.25` |
| Squad move tick | `dmscript.global:155` | 10 |
| Hold-mode ramp time | `dmscript.global:180` | `150*8*0.03125 = 37.5 s` (derived) |
| Officer search radius | `:205` | `1280/53.3333 = 24 tiles` (derived) |
| Capture radius | `:208` | `214/53.3333 = 4.0125 tiles` (derived) |
| Protection radius | `:209` | `426/53.3333 = 7.9875 tiles` (derived) |
| Cannon-blockshot radius | `:207` | `160/53.3333 = 3 tiles` (derived) |
| Resource drop radius | `:210` | 3 tiles |
| Gather hits (food/wood/stone) | `:799-801` | 22 / 14 / 20 |
| Infinite production sentinel | `:660` | `-1` |
| Max orders / max builders | `:113`, `:159` | 12 / 30 |
| AI difficulty levels | `:781-785` | none -1, easy 0 … impossible 4 |
| Seasons / terrain types | `:236-238` | `MaxSeasonCount=3`, terrain 9, relief 6-1=5 |
| Market elasticity | `:810-811` | `exp=0.00002`, `time=0.0001*32=0.0032` |
| Formation struct | `:1955-1968` | `id, sid, symmetry, bonus{damage,shield,damagehold,shieldhold}, width, height, countunits, countofficers, mask[24][54], maskofficers[24][54]` |

### D-02 `dmscript.source` — bootstrap and load order (20,221 B, 559 lines)

**Pseudocode (observed at `dmscript.source:1-70,71-100,101-104`):**
```
initialise all gbool_*/gint_*/gstring_* GUI/editor globals   // lines 3-69
gInterface.gamemode := gc_gamemode_mainmenu                  // :66
gRecordGeneratorVersion := 0                                 // :67
gbool_use_collision := True; gbool_use_nomeleeminradius := True // :68-69
load Files[] in this exact order:                             // :71-100
  classes, parser, init, map, net, pfx, misc, profile, res,
  country, sound, weapon, unit, group, squad, player, miscext,
  gui, control, ai, ui, scenarioeditor, scenario, serial,
  miscext2, movie, steam, miscext3
protected := [_init_InitializeFormations, _gui_CheckMaterialWidthHeight] // :101-104
private/global := long declaration lists                      // :105-...
```
**Inference:** load order is semantically relevant (e.g. `pfx` before `misc`,
`squad` before `player`). A faithful port should preserve it as an explicit
module order, not rely on implicit autoload. **Observed** ordering.

### D-03 `lib/init.script` — formation loader and startup (11,328 B, 258 lines)

**`_init_InitializeFormations()` (`lib/init.script:7-81`)** — this is the
definitive proof that the donor *consumes* the four `bonus*` fields:
```
pFormations := temporary Parser; load gc_filepath_formations (.\data\game\var\formations.cfg)   // :9-10
if count > gc_formation_maxcount(160): ErrorLog                                                // :11-14
else:
  for i in 0..159: zero id,sid,symmetry,4 bonuses,width,height,counts,masks                     // :17-37
  for i in 0..ParserCount-1:                                                                   // :38-79
    gFormation[i].id := i                                                                       // :41
    sid := ParserGetValueByKey(pFormation,'id')                                                // :42
    symmetry := ParserGetInt(...,'symmetry')                                                    // :43
    bonusdamage     := ParserGetInt(...,'bonusdamage')                                          // :44
    bonusshield     := ParserGetInt(...,'bonusshield')                                          // :45
    bonusdamagehold := ParserGetInt(...,'bonusdamagehold')                                      // :46
    bonusshieldhold := ParserGetInt(...,'bonusshieldhold')                                      // :47
    for each mask row j:
      '*' => countunits++, mask[j][pos-1] = True                                                // :58-65
      'O' => countofficers++, maskofficers[j][pos-1] = True                                     // :66-75
    width := longest mask row; height := number of rows                                          // :77-78
```
**Constants (observed):** `TopologySetPosSearchRadius(7)`
(`lib/init.script:90`), `SetDateTimeManagerEnabled(false)` and `SetTimeSpeedFactor(10)`
(`:99-100`), highlight size 0.7 (`:111`).

### D-04 `lib/control.script` — selection, cursor picking, camera (29,015 B, 764 lines)

**Selection (observed):**
- `_control_DeselectAllUnits(bUpdateSelection)` (`:7-22`) clears picked objects,
  `gSelectedObjects`, calls `_misc_SetSquadsSelection(plInd,false)`, optionally
  `_misc_UpdateSelection`.
- `_control_SelectAllUnits(bBuildings, bExcludePeasants)` (`:26-74`): uses
  `GameManagerBeginSelection` / `GameManagerStartSelection('spmRunTime')`, walks
  player objects backwards, filters `bbuilding` vs non-building and
  `usage <> gc_obj_usage_peasant`, sets picked, adds only squad-less units to
  `gSelectedObjects`, and calls `GameManagerCancelSelection` **once** as an
  optimisation (comment at `:30` explains a 10,000-unit lag bug).
- `_control_SelectAllShips()` (`:78-100`) selects first member of each water
  squad; `_control_SelectAllPeasants()` (`:104-152`) uses
  `gc_statemachine_interval_peasants` progress section.
- `_control_SelectIdlePeasants()` (`:422-485`): idle iff
  `orders[0].itype = gc_obj_order_type_none` (server) or movement mode 0 and
  `orders[0].itype <> gainres` (client/replay), **and** state tags
  `action_none & move_idle & visual_none` (`:460-464`).
- `_control_SelectIdleMines()` (`:489-530`): built mines with
  `inside + insidereserved < peasantabsorber + individual.addpeasantabsorber` (`:513`).

**Cursor picking (observed, `:156-274`):**
```
if over minimap: return 0                                          // :161-162
GameObjectRayCastMouseRay; GameObjectSortRayCastList               // :164-165
for each ray-cast handle:
   prio := 0.5                                                    // :180
   food raised -> 3, wood -> 2, stone -> 4 (gc_gui_cursorprio_*)   // :205-216
   enemy attackable -> 7; own -> 1                                // :225-234
   unfinished building + _unit_UnitsCanBuild -> 6                 // :236-242
   absorber (mine/transport) -> 5                                 // :243-253
   relativeDst := (1+dist)/prio; pick minimum                      // :260-265
finally reject if FOW LOS data = 0                                 // :270-272
```
This is a **distance/priority-weighted** pick, not a simple "topmost object".
Port has no equivalent documented (search of `input_controller.gd` found no
raycast-priority weighting) — **inferred gap**.

**Camera (observed, `:574-665`):** both `_control_GetMoveCameraToPositionOffset`
and `_control_MoveCameraToPosition` load `.\data\cameras\camera.cfg`, read
`RestrictInfo/{SphereLengthMin,SphereLength}` and
`FreeRotationInfo/{MinHeightMinAngle,MinHeightMaxAngle,MaxHeightMinAngle,MaxHeightMaxAngle}`
(`:581-589`, `:628-637`), then:
```
angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle, Clamp((height-minHeight)/(maxHeight-minHeight),0,1))  // :595 / :646
offZ   := ArcTan(angleZ)*height                                                                              // :602 / :653
angleX := VectorAngle(0,0,1, dx,0,dz); rotate offX/offZ by angleX                                            // :604-609
new target := dst + off + (dx,0.1,dz)                                                                        // :611-612 / :662
```
`_control_MoveCameraToUnitsListCenter` (`:669-686`) averages member positions;
`_control_MoveCameraToSelectedUnits` (`:688-708`) adds all selected squad members.
**Cross-link:** these are exactly the keys the binary config parser
`sub_7ab704` reads (`DECOMP_04_strings_config.md` §8.3) — donor truth is split
between the PE key names and this script's consumer.

**D-04a `data\cameras\camera.cfg` (1,613 B — read-only cross-file check, observed).**
This file exists and supplies the exact values the PE parser and the script
consume. `RestrictInfo`: `HeightTarget=1`, `HeightTargetMin=5`,
`SphereHeight=58` (49 commented out), `SphereHeightMin=20`, `SphereLength=58`
(49 commented out), `SphereLengthMin=20`. `ElasticInfo`: `MoveVelocity=0.125`,
`HeightVelocityFactor=0.05`, `RotationVelocity=0.05`, `IntervalTime=10`,
raycast step times 0.05/0.05/0.005. `FreeRotationMode=True`,
`FreeRotationInfo`: all four angle limits `=-32`, `AngleLerpPower=1`,
`MinDistToTargetObject=1`, `MaxDistToTargetObject=10`, `MaxHeightLerpFactor=0.15`.
`Bounded=True`, `DistToGroups=15`, `MinFocalLength=MaxFocalLength=400`,
`FocalLengthPower=1.0`, both elastic raycast modes `false`. DOF: `PowerDOF=0.5`,
length/near/far all 128/256/256; `DynFogDepth=False`, `DynFogStart=0.25`,
`DynFogEnd=0.025`, `DynFogDensity=2.0`, `DynFogPower=0.85`, `DynFogOffset=0`.
**Derived:** with all four angle limits equal, `angleZ` in `control.script:595`
reduces to `+32°` independent of height; the Lerp is nevertheless fully wired
for future variants.

**Game speed (observed, `:535-570`):** 3 modes from `gc_settings_gamespeed_0/1/2`;
the 4th is commented out ("fourth mode no longer with us", Russian comment at
`:553`); speed change is dispatched through `GUIExecuteState('WriteTimeSpeed')`.

### D-05 `lib/squad.script` + `lib/player.script` — formation construction

**`_player_SetSquadFormation` (`lib/player.script:792-890`)** (observed):
```
cols := gFormation[formInd].width; rows := gFormation[formInd].height   // :804-805
TSquad.fAddDamage      := gFormation[formInd].bonusdamage               // :809
TSquad.fAddShield      := gFormation[formInd].bonusshield               // :810
TSquad.fAddDamageHold  := gFormation[formInd].bonusdamagehold           // :811
TSquad.fAddShieldHold  := gFormation[formInd].bonusshieldhold           // :812
mask '*' cells filled in row-major order; 'O' cells are officer slots    // :830, :845
required count := gFormation[formInd].countunits                         // :929
```
`_player_CreateSquad` (`:910-978`) and `_player_FillSquad` (`:996-1053`) build
the squad; `_squad_GetOfficer`/`_squad_GetDrummer` read slots 0/1 of `TSquad`
(`lib/squad.script:7-29`). `lib/squad.script:373` reads `gFormation[form].symmetry`;
`:154-222, 250, 384-469, 495-557` implement grid placement, row/column fill and
symmetric rearrangement.

**Per-nation formation availability (observed, `lib/country.script:2404-2406`
and `:2436-2438`):** each country's officer record gets exactly three families:
`LINE` → `LINE15, LINE36, LINE72, LINE120, LINE196, LINE400`; `SQUARE` and
`KARE` analogous. Artillery officer formations are defined by
`AddFormationArtHowitzer/Mortar/Cannon` with explicit 9/19/40-row masks
(`:2253-2358`). **Inferred:** skirmish formation choice is nation-gated; the
port's 5 generic shapes are not nation-aware.

### D-06 `lib/miscext2.script` — damage formula (74,037 B, 1,628 lines)

**`_misc_DoDamage(goHnd, trgHnd, indamage, weapind, weapkind)`
(`lib/miscext2.script:276-…`)** — exact order of operations (observed at
`:332-440`):

```
damage := indamage                                                             // :332
if arrow/bullet AND target not building AND target usage=fasthorse AND moving:  // :334-335
    damage -= 5                                                                // :337
if target.built: damage -= target.shield                                        // :339-340
else:            damage -= target.shield div 3                                  // :341-342
if target in squad:
    damage -= targetSquad.fHoldMode ? fAddShieldHold : fAddShield               // :347-355
if attacker is priest: heal target by indamage, clamp to maxhp                  // :362-377, 388-399
else:
    if attacker in squad AND weaponkind <> firearrow:
        damage += attackerSquad.fHoldMode ? fAddDamageHold : fAddDamage         // :421-433
    damage -= target.protection[weapkind]                                       // :380 / :434
    bHeadShot := arrow/bullet AND random<0.05 AND not fast-horse case           // :420
    if bHeadShot: damage += floor(attacker.uniqrnd*500)                         // :436-437
    damage := max(1, damage)                                                    // :381 / :439
    target.hp -= damage                                                         // :383 / :440
    on kill: attacker.score += target.score*2; inside units give *3             // :445-459
```
**Notable observation:** the comment at `:420` says C1 had 4% and "in c3 after
shooters rebalance changed to 2 percent", but the code threshold is `0.05`
(5%). Do not encode the comment; encode the code. **Derived.**
`_misc_DoRoundDamage` applies the same damage path to units in radius
(`_misc_DoDamage` called at `:595`).

### D-07 `units/global.inc/progress.inc` — per-player progress tick, squad hold/disband

**`CheckSquadsDisband(plInd)` (`:5-35`):**
```
for each squad descending:
    basecount := squad.fBaseCount; count := _squad_GetBaseUnitCount(squad)   // :12-13
    if count < basecount * gc_player_SquadDismissPercent (0.25):            // :15
        if interface player and squad selected: cache members                // :17-28
        _misc_DisbandSquad(plHnd, i, true)                                    // :30
        re-add cached members to selection                                    // :31-32
```
**Hold-mode ramp (`:160-170`):** if squad `fStandGround AND not fHoldMode AND
not fAgressive AND fMoveCount=0` **and** hold bonuses differ from normal ones,
`fHoldModeProgress += deltatime / 37.5 s`; at ≥1 set `fHoldMode := True`.
This is how the `bonusdamagehold=7 / bonusshieldhold=7` values become active —
**derived, twice verified** (`dmscript.global:180`, `progress.inc:162-169`,
`miscext2.script:350-354,427-430`).

**Player existence check (`:54-140`):** every `addtime = 0.125*plInd +
gc_global_TimeCheckExists*{4,12}` seconds; player is "exists" if food farm used
in (0,100) and has a visible peasant or a built town hall; otherwise units are
killed and `victorystate := lose` (`:124-135`).
**Economy tick hook:** `_player_ProcessResourceIncome` then
`_player_ProcessResourceConsume` at `:146-147`; `ExecuteState('ProgressAI')` at
`:178`. Client/replay skip global progression (`:46-49`).

### D-08 `lib/unit.script` — costs, production, runaway (560,101 B, 12,381 lines)

**Cost escalation (`_unit_GetCostByID`, `:5652-5689`):**
```
costpercent := gObjProp[cid][id].costpercent                       // :5654
if costpercent not in (100,0):
    count := gPlayer[pl].counter.all[cid][id]                       // :5658
    for mercenary pairs archerdip/archerturdip, dragoon18dip/lightcavalrydip:
        count += counterpart count                                  // :5660-5672
    costmodifier := pow(costpercent/100, count)                     // :5673
    cap := mercenary ? 2 : 20000                                    // :5674-5678
each resource := floor(base_price[i] * costmodifier)                // :5681-5688
```
Observed `costpercent` examples: 100.5 (`:1051,1310,1380`), 102 (`:1653`),
105 (`:1867,1889,2018`), default 100 (`lib/classes.script:3661`).
**Derived:** this is exponential per owned unit, not a flat multiplier.

**Affordability (`_unit_CanApplyCountCostByID`, `:5694-5717`):** multiplies all
six prices by `count`, adds AI buffers (`+300` food, `+25` gold when `bAI`,
`:5704-5710`), then applies six `not res >= cost` comparisons (`:5711-5716`).
**UNVERIFIED:** the exact DScript precedence of `not` relative to `>=` cannot be
settled from plaintext; the surrounding call sites (`:10435-10443`) treat the
result as "enough resources", so the intended semantics is affordability, but
we do not assert the parser's precedence. The same pattern occurs in
`lib/player.script:290-302`.

**Order merging (`_unit_OrderProduce`, `:5995-6052`):**
```
for each of 12 order slots descending:
  if slot is produce of same id:
    if new amount = -1 and existing amount > 0: cancel existing, exit  // :6011-6015
    if costpercent in (100,0) or unitcount = slot.restype:             // :6017
      if not (existing = -1 and new > 0):                             // :6019
         existing = -1 if new=-1 else existing+new                    // :6021-6024
         for j in 0..new-1: ApplyCost                                  // :6026-6031
         bMerged := True
      else exit
if not merged: charge new non-infinite amount, add one order            // :6043-6051
```
**`_unit_ProduceUnit(plHnd,list,cid,id,tryamount,bState,bcheckres,blan)`
(`:10351-…`):**
```
amount := tryamount
if amount <= -1: bsetinfinite := True; amount := round(Abs(amount))   // :10362-10365
repeat amount times:
   pick built building with fewest queued units of this id (or most if bState) // :10374-10425
   if bState: if affordable or !bcheckres:
        _unit_OrderProduce(bld,cid,id, bsetinfinite ? -1 : 1)           // :10435-10443
   else: ... (see :10454+)
```
This is the mechanism behind the click modifiers documented in P6; `-5`
becomes five separate infinite orders (P6 Open Q1 is answered: **five orders**,
observed at `:10365` + `:10440-10443`).

**Shooter kiting / "morale" (`_unit_IsRunAway`, `_unit_DoRunAway`,
`:7175-7238`):** there is **no numeric morale variable anywhere in the 4.37 MB
corpus** (searched `morale|rout|panic|fear`; only `fear` hits are a local bool in
AI at `progresswarai.inc:2799-2832`). What exists:
```
isRunAway := order[0].itype=move AND order[0].info.progress=move_mode_runaway(2)  // :7179
deltadst  := min(minattackradius, runawaydist(3.5))  ... Clamp(minsearchdist-dist, 3*epsilon, 3.5) // :7189-7197
move to point on line away from threat, clamped 0.25 inside map edge                // :7199-7237
triggered when a melee threat is within minsearchdist and not standground          // :7364-7368
```
`gc_unit_runawaydelay = 1.3`, `gc_unit_runawaydist = 3.5` (`dmscript.global:198-199`).
**Correction to P7 G-13:** donor has *formation disband on 25% losses*, not a
morale/disband threshold of 30% with officer/drummer death; public wiki S13 is
not supported by donor plaintext (UNVERIFIED there).

### D-09 `units/building.inc/doprogressorders.inc` — production tick (26,651 B, 416 lines)

**`gc_obj_order_type_produce` branch (`:123-310`):**
```
cid := order.info.upgradeid (stores producing building cid); id := produceid   // :126-127
if field usage: _unit_DoSeedWheat, drop order                                  // :130-136
bFarmOk := farmused < farm, optionally clamped by mapsettings limit 1..8       // :142-152
bUnitLimitOk := total units over all players < gc_MaxObjCount(32000)            // :162-164
bArtOk := artillery count < per-type limit                                     // :165-169
if infinite order and bStart: require affordable and food >= 500 for food units // :184-201
if port: require GetPortPlaceIsFree                                            // :202-203
if all gates pass:
   if start and infinite and affordable: charge one unit                       // :210-211
   deltabuildtime := dt / objbase[cid][id].buildtime                           // :221
   if AI (not human-like): multiply by difficulty 0.30/0.50/0.75/1.00/1.25     // :222-231
   progress += deltabuildtime; clamp to 1                                      // :232-234
   AI cancels at 0.995 when _unit_CheckCapturersStopProduce                    // :235-239
   on completion: spawn at last exit point (or port resource point),          // :247-270
      finite amount--, progress:=0; if amount=0 remove order;                  // :273-293
      if infinite: move the order to the last free slot (round-robin)          // :295-310
```
This round-robin is important: **five infinite orders** each get one unit in
turn rather than one order starving the others (derived from `:295-310`).

### D-10 `lib/player.script` — income, upkeep, famine, rebellion (145,234 B, 3,517 lines)

**`_player_ProcessResourceIncome(plInd,dt)` (`:242-266`):**
```
bank   := remains[i]/100 + resincome[i]*32*dt
real   := bank / (256/1.024)                 // speed = 250
value  := floor(real)
add value; remains[i] := floor((real-value)*speed*100)   // :252-263
```
**Derived:** one `resincome` counter point = 32/250 = 0.128 resource/s; a mine
peasant contributing 13 points gives `13*32/250 = 1.664/s` — closes fnd_2 and
the port's `MINE_INCOME_PER_S`.

**`_player_ProcessResourceConsume(plInd,dt)` (`:270-322`):**
```
bank := remains/100 + resconsume[i]*32*dt; real := bank/20000; value := floor(real)
if enough: charge value, clear famine/rebellion flag                    // :290-298
else: charge all remaining, set bfamine (food) / brebellion (gold if consume>income) // :299-312
clear flags when the deficit condition disappears                        // :318-321
```
One consume counter point = 32/20000 = 0.0016/s; `consume=…` yields the
"upkeep /625" shorthand used by the port (observed divisor at
`data.gd:66` linked to this function).

**Famine/rebellion are probabilistic death/defection, not HP drain (observed,
`units/unit.inc/nothing.inc:450-496`):**
```
if gProfile.bFamine and player.bfamine and playable and not building/nohungry:
   roll := floor(random*32768)                                   // lib/misc.script:494-498
   die if roll < 50 (difficulty>1 or online) / < 5 (easy) / < 12 (normal)   // :482-483
if player.brebellion and unit.bmercenary:
   roll < 6000 (hard) / < 100 (easy) / < 200 (normal) => transfer to mercenary player // :492-495
```
**Correction to P7/PORT:** port `FAMINE_GRACE_S=120`, `FAMINE_DRAIN_PER_S=0.3`
(`app/scripts/data.gd:96-97`) is an invented model; donor has no grace timer and
no HP drain.

### D-11 `lib/res.script` — market with exact mean-reverting prices (13,604 B, 360 lines)

**`_res_InitEconomy()` (`:178-250`)** — observed price bands:

| Resource | buy min/def/max | sell min/def/max |
|---|---|---|
| food | 20 / 25 / 40 | 10.64013 / 15.20018 / 19.76024 (derived: `18.24095*0.8333 = 15.20018` then ×0.7/×1.3 at `:193-197`) |
| wood | 40 / 50 / 60 | 20 / 30 / 40 (`:199-206`) |
| stone | 40 / 50 / 60 | 15.67506 / 20.90008 / 26.12510 (derived: `19.29725*1.08306 = 20.90008` then ×0.75/×1.25 at `:211-215`) |
| gold | 140 / 190 / 240 | 80 / 110 / 140 (`:217-224`) |
| iron, coal | 100 / 140 / 180 | 40 / 60 / 80 (`:225-232`) |

**`_res_ProcessEconomy(dt)` (`:272-309`)** — each price relaxes toward `def`
with `dt' = dt*0.025*max(1, garr_res_dlt[i]*0.01)` and is clamped to its band
(`:291-307`). **Derived:** this is exponential mean reversion, monotonic only
while on one side of `def`. **Correction to P7 G-08**, which assumed monotonic
drift to a floor.

**`_res_MarketTradeResources(plHnd,sellres,buyres,amount)` (`:320-344`):**
```
sellamount := min(amount, player.res[sellres])                         // :323-326
buyamount  := floor(sellamount * sellcost[sellres] / buycost[buyres])   // :313-316, :327
on server/offline: add buyamount, subtract sellamount, force sync        // :329-333
w := buyamount * buyexp(0.00002)                                       // :337
buycost[buyres]  := (buycost + buycostmax*w)/(1+w)                      // :338
sellcost[buyres] := (sellcost + sellcostmax*w)/(1+w)                    // :339
w := sellamount * buyl... sellexp(0.00002)                              // :340
sellcost[sellres] := (sellcost + sellcostmin*w)/(1+w)                   // :341
buycost[sellres]  := (buycost  + buycostmin*w)/(1+w)                    // :342
```
The four updates are the donor's commission/drift mechanism, with exact
denominators — **direct porting value, high**.

### D-12 AI — three cooperating layers

**Layer 1 `lib/ai.script` (95,596 B, 2,531 lines):** 69 declared helpers. Army
model: 16 army types (`gc_ai_armytype_*`, `dmscript.global:402-418`), 9 army
specialisations (`:420-428`), 9 army orders (`:430-438`, incl. `attackwall=8`),
`maxarmytypes=16`, `maxupgradelevel=8`, `max_construction_sites=12`,
`UpdateEnemyInfoTick=200`, `MergeArmyDist=3`, `AgressorsCount=5`,
`OfficerWaitTime=20 s`, `ArmyBattleDist=4` scan-grid cells, `CityDangerDist=20`
(`:461-481`). Functions: `_ai_CalcEnemyArmies` (`:765`), `_ai_ProcessTowers`
(`:1011`), `_ai_CreateMinimalArmy` (`:1099`), `_ai_ArmyBitva` (`:1826`),
`_ai_GetClosestOrePlaceWithRes` (`:1954`), `_ai_ArmyTooStrong` (`:2190`),
`_ai_ArmyCanMerge` (`:2210`), `_ai_FindMoorPosition` (`:2507`).

**Layer 2 `units/global.inc/progresseconomicai.inc` (231,799 B, 3,925 lines):**
74 helpers covering resource balance, mine placement/upgrades, trading,
construction and production. Key rules (observed): AI affordability buffers
`+300 food / +25 gold` (`lib/unit.script:5704-5710`); mine rings at distances
30 / 60 / 85 (`dmscript.global:503-506`); `_ai_MakeUpgrades` (`:2383`),
`_ai_BuildHouses` (`:2677`), `_ai_DoTrade` (`:3006`),
`_ai_MainConstructionIdeasScript` (`:3165`), `_ai_ProduceUnits` (`:3242`),
`_ai_ProcessIdeas` (`:3268`), `_ai_ControlConstruction` (`:3519`),
`_ai_ProgressTowersUpgrades` (`:3636`), `_ai_DoSeedWheat` (`:3688`),
`_ai_SetupDevelopingStrategy` (`:3783`).
The AI upgrade ids `gc_ai_upg_* = 1..45` with SIDs `aca.1..aca.36`,
`bla.1..bla.6`, `mil.1..mil.2`, `cen.1` are at `dmscript.global:508-598` —
this is the authoritative academy/blacksmith/mill upgrade catalogue that P7
G-02..G-06 asks for.

**Layer 3 `units/global.inc/progresswarai.inc` (228,378 B, 4,262 lines):**
58 helpers: army creation/merge/battle links (`:831-1193`), pathing via
`_ai_GetNextZone`/`_ai_GetNextGreCell`/`_ai_GetNextSafeZone` (`:1193-1369`),
wall attack (`:1391-1582`), naval `ArmyMakeWaterBattleLink` (`:2707`),
diversion/raids `_ai_ArmyDiversia` (`:2770`), `_ai_CheckDiversants` (`:2953`),
mine-denial `_ai_DisbandMineSettlers` (`:3098`) and
`_ai_ProgressMineBuilders` (`:3143`), defenders (`:3351`), aggressors
(`:3451-3572`), officer-squad creation (`:3595-3775`), transport (`:3776`),
wall-assault link (`:3961`), and the army executor `_ai_ExecuteArmies` (`:4069`).

**Dispatch:** `units/global.inc/progressai.inc:1-22` (`ProgressAI`) and
`progress.inc:178` call `ExecuteState('ProgressAI')` only for existing players
with AI or an enabled adviser.

**UNVERIFIED:** P7 G-11 ("AI blows up mines before capture") — there is a
`_ai_DisbandMineSettlers` and `_ai_CheckCapturersStopProduce`
(`doprogressorders.inc:237`), but no explicit "self-destruct mine" call was
found in plaintext. Do not implement on this evidence alone.

### D-13 Terrain/decor generation

**`common.inc/generatemap.inc` (51,794 B, 1,060 lines):** constants at `:4-53`:
plateau height 2.964, hill = 2.964/2.25 ≈ 1.3173, ravine −2.964, water −1.1
(texturemap uses a different water height −0.25 and shore −0.1,
`texturemap.inc:29-31`); colour keys plateau 255, hill 96, ravine 48;
forest 255, generated forest 64, stone 128, forest+stone 192, water 255.
Pipeline toggles (`:34-49`) are all `True`: reset height, Gaussian post-process,
load height from texture, smooth using bitmap, smooth all map, place water,
place forest, texture terrain, smooth tiles, load texture, place free forests,
seed wheat, build topology, update minimap, stand patterns.
Heightmap mapping (`:568-574`) `h := hwater + {cPlateau|cHill|cRavine}*fr`
then `SetHeightData`; `SmoothTerrain(…,3)` at `:591`; custom smoothing at
`:606` (power 4, lerp 0.5, min 0.01, max 100) and `:637` (power 0.35, −100..−0.01).
Water field size 2 → 320×320 array (`:649-650`).

**`common.inc/postprocess.inc` (19,416 B, 467 lines):** noise/filter constants
`:63-82`: `cMinDropPower=1`, `cMaxDropPower=3`, `cNoiseProb=0.5`,
`cTryNoiseNearestProb=0.6`, recursive 0.99, `cMaxDeep=10`, plateau/water
thresholds 0.1/0.95, power break 0.1/0.9. Implements
`IsPlateau/IsWater/IsBorderBlack*/TryNoise` (`:1-…`) and fills missing terrain
types with `FindNearestTerrainType` (`:279,405-408`).

**`common.inc/texturemap.inc` (48,954 B, 964 lines):** collision painting with
half-cell offsets for water/shore (`:63-148`); terrain type constants `:4-27`;
forest types pine-fir-spruce / mixed / leaf (`:41-43`); season suffix
`if GetSeasonType=2 then newtile := newtile+'_winter'` at `:525-526, 605-606,
639-640, 927-928, 950-951`; tile index set via `MapGetTileIndexByTileBlock`
(`:527-528`). `cPlaceRoads=True` (`:39`).

**`common.inc/dogenerate.inc` (109,219 B, 2,103 lines):** see P1 §2.2 for the
stage overview; independently re-verified here:
- masks 5×7 / 12×15 / 22×18 (`:407-414`), `cstartoffset=60`,
  `cstartoffsetrnd=25` (`:484-485`), `cMapSize=640` (`:447`), `cSize=25` tile
  cracks (`:1335`), shore `< -0.1` (`:1576-1580`).
- `SetupMines` (`:522-…`): `trycount=256`, density 0/1/2 → 3/4/5 rounds
  (`:528-532`), resource prefixes `mng/mni/mnc` or `desert_*` (`:546-554`),
  version-gated distance tables (`:559-641+`).
- **Correction to P1:** the terrain-family switch is
  `if gRecordGeneratorVersion<91 then TerrainTypes else TerrainTypesDLC5`
  (`:1547-1558`), and random `terraintype` uses `floor(RandomExt*6)` before the
  gate but `floor(RandomExt*gc_MaxTerrainTypeCount)` (=9) after it (`:1550-1557`).
  P1 stated `<90`; the plaintext says **91**.
- Decor scale jitter (`:1971-2027`): in winter, delete objects whose base name
  contains `leaftree` (`:1975-1981`); skip `terrainmesh`/`stones` (`:1984-1985`);
  for objects with `rand` scale props, clamp scale into
  `[min,mid]∪[mid,max]` using uniform `random` (`:1992-2024`), and rescale Z by
  `z/x` when they differ (`:2025-2026`). This is the runtime consumer of
  `envscales.cfg` (P1 G6).
- End-of-generation AI staggering `cProgressAITick=16` (`:2042-2049`), peacetime,
  `FillOwnerMap(spcount)`, border objects, `_misc_SetShoresCollision` (`:2059-2070`).
- Colour table (`:2075-2084`): winter → index 6 + PHDR 1; `season=3` desert →
  index 7; else index 0 + PHDR 0. Confirms P1 §2.2 item 11 with exact lines.

**Env/decor objects:** `env/env.aix` maps 12 events to `env/env.inc/*`.
`InitialDecor` (`:4-39`) makes decor non-playable, disables collision and
inertia, assigns a unique id, and switches to `NothingDecor`; out-of-map decor
is only logged, not destroyed (`:30-34`, destroy call commented at `:32`).
`DoExtract` (`:5-13`) decrements food-resource HP by 1 per hit.
`Initial` (6,354 B) sets run animations/death and resource behaviour;
`OnTagStates` (6,685 B) contains `SendPeasantsToNextRes`.

### D-14 Camera, weather/season, FX, sound (cross-cutting)

- **Camera:** see D-04. Additional movie-side camera helpers in
  `lib/movie.script` (47,874 B): `_movie_SaveCamera` (`:…` first declaration),
  `_movie_LoadCamera`, `_movie_MoveCamera`, `_movie_FadeBlackScreen`,
  `_movie_ProcessMovie`, `_movie_StartMovie` (function list at
  `lib/movie.script:1-…`, 43 declarations total). These are cut-scene camera
  controls; no gameplay camera mode switch was found in `data\scripts`.
- **Weather:** **no `weather` token occurs in any of the 222 script files**
  (searched `weather|rain|snow`; only `winter` season handling and `Weather`
  as a CODE key in the PE per P4). Donor weather/camera keys live in
  `.\data\cameras\camera.cfg` (`lib/control.script:581-589`) and the binary's
  config parser (`DECOMP_04` §8.3). **UNVERIFIED** whether a weather *value* is
  ever applied beyond camera fog/DOF.
- **Season:** exactly two mechanisms in scripts — `GetSeasonType=2` → `_winter`
  tile suffix and leaf-tree deletion; `gMap.settings.gen.season=3` → desert
  pattern families and colour table 7 (`dogenerate.inc:4, 552-553, 1975,
  2075-2084`). `gc_MaxSeasonCount=3` (`dmscript.global:237`).
- **FX/particles:** `lib/pfx.script` (17,880 B) is an object pool with
  `Create/Destroy/GetOrCreate/SaveToStruct/LoadFromStruct` at class level
  (`:34-118`) and effect/level instances (`:164-410`), including
  `FillRand` (`:200`) for random particle parameters.
- **Projectile explosion (`misc/projectile.inc/doexplode.inc:1-170`):**
  `SetRandomKey(floor(arg_proj.uniqrnd*gc_MaxInt))` for MP sync (`:12`);
  water surface clamp `py ≥ waterheight+0.0025` (`:19-28`); splash damage via
  `_misc_DoRoundDamage` (`:83`) then direct target damage (`:84-88`);
  explosion medium chosen from target → water → collision tag
  building/wall/water/land/bridge (`:92-110`); decal via `_weapon_CreateDecalExp(…,4,0,20)`
  (`:114-118`); custom explosion child count
  `mincount + floor(RandomExt*(1+maxcount-mincount))` (`:137-144`).
  `misc/projectile.inc` has 16 states; `doexplodecustom.inc` (11,700 B) is the
  variant with owner-less child effects.
- **Sound:** `lib/sound.script` (28,196 B, 12 decls) registers sounds into three
  libraries `interface / units / ambient` (`gc_snd_lib_*`, `dmscript.global:1237-1239`,
  indices `:1245-1247`) with fade time 0.3 s and loop tags −1/−2/−3 (`:1233-1236`).
  `progress/progress.inc/soundcontrol.inc` (14,698 B, 5 decls) creates emitters in
  listener/world position and has `soundcontrolcounters.inc` (10,017 B) for
  per-unit footstep sounds. Sound-grid is 8×8 cells on a 640 map
  (`dmscript.global:70-75`).

### D-15 Hotkeys (script boundary)

No hotkey bindings exist under `data\scripts`; `hotkeys.cfg` is at
`data\game\var\hotkeys.cfg` and was catalogued in P1 §2.5. The scripts expose
the *actions* the GUI binds keys to: `_control_SelectAllUnits` variants,
`_control_SelectIdlePeasants`, `_control_SelectIdleMines`,
`_control_SelectOnlySquad`, `GUIExecuteState('ShowHUD'/'InitMinimap'/
'WriteTimeSpeed'/'DoUpdateSelection')`, and `_player_OrderUnitsToGuard` /
`_player_OrderUnitsToAttackPoint` (`lib/player.script:2399, 2447`).
GUI-side key handling lives in `data\gui\menu.inc\*` (**outside** this task's
root; P6 read `eventunitcontrol.inc`/`onmousedown.inc` there).
**UNVERIFIED:** whether any script under `data\scripts` receives raw key events —
none found.

### D-16 Network serialisation (secondary but exhaustive)

`lib/serial.script` (96,599 B, 103 decls) reads/writes players, squads, objects,
triggers with size accounting; the four formation bonus fields are persisted
explicitly (`lib/serial.script:1044-1047` write, `:1115-1118` read,
`:1187-1190` size, `:1255-1258` seek).
`units/global.inc/{read,write}*.inc` are 48 paired handlers for orders,
construction, units, squads, rally, trade, walls, upgrades, projects, etc.
**Rule:** every order field is mirrored in a read and a write pair; a porting
change to `TOrderInfo` must update both (observed structure of the 48 files).

---

## 6. Cross-reference to the 2D port (SECONDARY) and missing 3D features

Port files were read only; line numbers are from the current working tree
(2026-11-25), which has advanced since P1/P6/P7 were written.

| Donor rule (this report) | Port today | Status |
|---|---|---|
| 149 formations + 4 bonus fields (`init.script:38-78`) | `Data.FORMATION_BONUSES` imports all 149 ids including 46 nonzero (`data.gd:376-530`); `game.gd:3041-3110` reads donor tuple | **IMPLEMENTED** (P1 G1/DB-01 now closed); masks still only 5 generic shapes (`data.gd:368-374`) |
| Formation XP raises bonuses | `Data.SQUAD_XP_*` + `game.gd:3062-3080` add up to +3 per field | **DIVERGENCE** — not in donor plaintext (P7 G13 partially implemented by invention) |
| Market mean reversion + 4-point update (`res.script:272-344`) | `game.gd:3530-3550` still uses `MARKET_DRIFT` downward to 0.35 plus an "INFERRED" recovery (`data.gd:98-103`) | **PARTIAL / stale comment** — donor exact formulas available now |
| Famine death-roll, no grace (`unit.inc/nothing.inc:450-483`) | `FAMINE_GRACE_S=120`, `FAMINE_DRAIN_PER_S=0.3` (`data.gd:96-97`) | **WRONG MODEL** |
| Mine income 13×32/250 (`player.script:242-266`) | `MINE_INCOME_PER_S=1.664` (`data.gd:64`) | **IMPLEMENTED** |
| Exponential cost `pow(costpercent/100, owned)` (`unit.script:5652-5689`) | flat `×3` town hall / `×1.5` others (`game.gd:2274` per P7) | **DIVERGENCE** |
| 12 orders/object, infinite = one order with amount −1 (`dmscript.global:113,660`) | `BUILD_QUEUE_LIMIT=10`; `game.gd:5268-5316` has `infinite` flag and re-arm | **PARTIAL** (cap 10 vs 12; no costpercent) |
| Shift=5 / Ctrl=∞ / Ctrl+Alt=100 / Ctrl+Shift=5×∞ | `hud.gd:709-754` implements exact constants and RMB cancel | **IMPLEMENTED** — P6's "port gap" section is stale, Q1 resolved as 5 infinite jobs |
| Selection priority `(1+dist)/prio` (`control.script:156-274`) | no equivalent found in `input_controller.gd` | **MISSING** |
| Camera loads `camera.cfg` RestrictInfo/FreeRotationInfo (`control.script:581-589`; D-04a) | port imports `MIN_HEIGHT=20/MAX_HEIGHT=58/pitch=-32` and `CAMERA_PITCH` is declared-but-unused; `SphereLength/FocalLength/DistToGroups/DynFog*` absent (per parallel `DEC_03_configs.md` §7.4) | **PARTIAL** |
| 0.25 squad disband (`progress.inc:15`, `dmscript.global:156`) | squad disband rule not found in `game.gd` | **MISSING** |
| Hold-bonus ramp 37.5 s (`progress.inc:160-170`) | `hold` flag exists (`game.gd:1996`), no ramp found | **MISSING** |
| Shooter run-away 3.5 tiles (`unit.script:7175-7238`) | 4 m fallback at `game.gd:2882-2884` (P7) | **PARTIAL** (units mismatch) |
| Headshot `random<0.05` + `uniqrnd*500` (`miscext2.script:420-437`) | not found | **MISSING** |
| Winter `_winter` tile suffix / desert colours (`texturemap.inc:525`, `dogenerate.inc:2075`) | port has season handling in terrain work (untracked variant3d tests seen) | **UNVERIFIED in stable code** |
| AI army/order model (9 orders, 16 types, 12 sites) | `ai.gd` has `_raids/_waves/_repair` only (P7) | **MISSING / large** |
| Donor market/famine/cost data now in plaintext | `mechanics.json` values still marked `estimated:true` per P7 | **DOC STALE** |

**Missing 3D features implied by the scripts:** full 3D camera restriction model
(sphere height/length + 4 angle limits), fog/DOF config, tile-block material
selection with winter variants, three-library sound emitters on an 8-cell sound
grid, per-object scale jitter from `envscales.cfg`, 640×640 terrain/collision
grids with 25×25 tile cracks, and the complete 4-layer AI (army, economy, war,
transport/wall) including 45 research decisions.

---

## 7. Corrections to prior docs

1. **P1 / DB_SCRIPTS §1:** `common.inc/*.inc`, `lib/*.script`, `dmscript.global`
   are **ASCII code with CP1251 Cyrillic comments**, not plain UTF-8. 19 of 222
   files affected; UTF-8 strict decode fails. Evidence: `ev_462f7a31…`,
   `ev_4ead67fc…`, `ev_c8cf3d2d…`.
2. **P1 §2.2 / G3:** DLC5 terrain gate is `<91`, not `<90`
   (`dogenerate.inc:1547-1558`), and the random DLC5 terrain type range is 9,
   not 6 (`:1557` + `dmscript.global:236`).
3. **P1 §2.4:** confirmed formation bonuses are consumed (D-03), but the
   corrected counts are P2's 46/15 — P1's "43" and flat tuple list remain wrong.
4. **P1 G2:** `Data.HOTKEYS = {}` is no longer true; `config.gd:135-167,556-566`
   populates `Data.HOTKEYS` from `controls.hotkeys` (patrol Q, patrol_waypoints P).
   **New observation (re-verified this task):** donor `hotkeys.cfg` contains **no
   `patrol` action at all** — `Key = Q` is bound to the interface
   `viewcollision` action, and `Key = P` is `Action = build|%com%por` (the port
   building). Therefore P7 G12's premise ("donor patrol is P, port uses Q") is
   **UNVERIFIED from the authoritative config**; both bindings come from wiki
   S9. Do not change the port key on this evidence. The parallel config agent's
   `DEC_03_configs.md` C8 independently reached the same conclusion (52 keyed
   donor binds vs 42 port binds).
5. **P1 G1/DB-01:** closed in current tree (`data.gd:376-535`, `game.gd:3041-3110`).
6. **P6 §4:** closed in current tree (`hud.gd:709-754`, `game.gd:5268-5316`);
   P6 Q1 resolved as five infinite orders (`lib/unit.script:10362-10365,10440-10443`).
7. **P7 G-08:** donor market is mean-reverting with exact weights, not a
   monotonic floor drift (`lib/res.script:272-344`).
8. **P7 G-13 / morale:** no numeric morale in donor scripts; disband is
   `count < 0.25*basecount`, and shooter retreat is a move-order mode. Port's
   `MORALE_*` and famine drain are invented.
9. **P4 §4 blanket statement** ("0 code references for config keys") already
   corrected by its own §8; this report adds the script-side consumer
   (`lib/control.script:581-589`) for the same keys.
10. **P1 §5 "not read" list:** `generatemap.inc` and `texturemap.inc` ARE now
    read and catalogued here (D-13), closing that verification limit.

---

## 8. Porting implications, ranked

| Rank | Item | Donor citation | Why ranked here | Est. |
|---|---|---|---|---|
| 1 | Market exact pricing + 4-point trade update | `lib/res.script:178-250,272-344` | Small, self-contained, player-visible, resolves P7 G-08/G-14 | S (2–4 h) |
| 2 | Famine/rebellion probabilistic model (replace grace+HP drain) | `lib/player.script:270-322`, `unit.inc/nothing.inc:450-496`, `misc.script:494-498` | Fixes a wrong model; constants exact; difficulty-dependent | S (3–5 h) |
| 3 | Formation masks (54×24, `*` units / `O` officers) + 12-order parity | `init.script:38-78`, `dmscript.global:113,166-168`, `player.script:804-845` | Bonuses already ported; masks/order cap are the remaining fidelity gap | M (6–10 h) |
| 4 | Squad disband 25% + 37.5 s hold ramp + headshot 5% | `progress.inc:15,160-170`; `miscext2.script:420-437` | Core combat feel; exact constants; small code | M (5–8 h) |
| 5 | Exponential `costpercent` pricing with caps | `unit.script:5652-5689` | Player-visible economy balance; data already has costpercent values | M (4–8 h) |
| 6 | Camera restriction config + weighted cursor picking | `control.script:156-274,574-665`; P4 §8.3 | Needed for 3D parity; requires reading a new donor cfg (not in scripts root) | M (8–12 h) |
| 7 | Income/consume exact accumulator (`/250`, `/20000`, remains×100) | `player.script:242-322` | Replay/steady-state fidelity; current port approximates | M (6–10 h) |
| 8 | Season/FX tile suffix + winter decor deletion + scale jitter | `texturemap.inc:525-951`, `dogenerate.inc:1971-2084` | Visual parity; partly present in variant3d work (untracked) | M (6–12 h) |
| 9 | Full AI (16 army types, 9 orders, 12 sites, 45 upgrades) | D-12 | Largest gap; no equivalent in `ai.gd` | L (40–80 h) |
| 10 | Network read/write parity for any changed order field | `lib/serial.script`, 48 `read*/write*` pairs | Must accompany any of items 3/5/7 or replays/MP desync | M (8–16 h) |

---

## 9. Open questions

1. **UNVERIFIED — `not res >= cost` precedence** in `lib/unit.script:5711-5716`
   and `lib/player.script:290-302`. Call sites imply affordability semantics,
   but the DScript operator precedence cannot be proven from plaintext. Confirm
   against a recorded game or the engine parser before porting the comparison.
2. **UNVERIFIED — `Weather` application.** No `weather` token in any script;
   keys are in the binary/`camera.cfg`. Is there any runtime weather state
   beyond camera fog/DOF?
3. **UNVERIFIED — AI mine demolition** (P7 G-11): `_ai_DisbandMineSettlers`
   exists but no self-destruct call was found.
4. **UNVERIFIED — hotkey key-handling boundary:** all raw key logic appears to
   live in `data\gui\menu.inc\*`, outside this root; a dedicated task should
   catalogue that directory against `hotkeys.cfg`.
5. **INFERENCE — is `gProfile.bFamine` (default true, `lib/profile.script:39`)
   user-facing?** Likely a settings checkbox; not confirmed here.
6. **DERIVED — `gc_ai_unit_max_unit=44` (`dmscript.global:462`) is one less than
   the last defined id 54 (`pikeman18`, `:400`).** Possible stale constant; do
   not silently clamp AI unit ids without checking the lists at runtime.
7. **Port state mutability:** several fixes (recruit modifiers, formation
   bonuses, market recovery) are in the working tree; ensure they are committed
   before treating P1/P6/P7 gap tables as current.

---

## 10. Evidence index

**Craft Anything read-only calls (shared investigation memory, 2026-11-25):**

| Evidence id | Subject |
|---|---|
| `ev_548b8a009c8885823f1079b4ed23e2d65b1d9ec5babee752f3af5ec6bcd590dd` | `units/global.inc/progress.inc` lines 1–40 (squad disband) |
| `ev_462f7a319d79c987b7381bb56e46e6e928be7022685e1060d438b8020682dae9` | `dmscript.global` lines 1–20; 4,770 replaced non-UTF-8 bytes |
| `ev_88541949d975875532eee6f18369a06d81385c54006a99adce1bfa61364570cb` | `lib/init.script` lines 1–82 (formation loader) |
| `ev_c8cf3d2dd4cdbb58c540084af22593bf10709ecac22a97605d0520a101f54c99` | `lib/res.script` lines 313–345 (market trade) |
| `ev_4ead67fc9ec16e99dd1e61445c7676ab25c97f4b11b5c61f3bdaac5355768616` | `lib/player.script` lines 242–323 (income/consume) |

**Python-derived evidence (exact `path:line`; all in `C:\Games\Cossacks 3\data\scripts`):**

| Claim | Citation(s) |
|---|---|
| 222 files / 4,373,442 B / 0 NUL / CRLF / 19 CP1251 files | `dec02_enum.py`, `dec02_census.py` outputs (§3) |
| 1,465 constants / 1,752 decls / 92 states / 8,036 calls | `dec02_index.py` output (§3) |
| Formation load & bonuses | `lib/init.script:7-81`; `dmscript.global:1955-1968`; `lib/player.script:792-812` |
| Damage order | `lib/miscext2.script:332-440` |
| Disband 25% / hold 37.5 s | `units/global.inc/progress.inc:5-35,160-170`; `dmscript.global:156,180` |
| Infinite sentinel & 5× orders | `dmscript.global:660`; `lib/unit.script:10362-10365,10440-10443`; `units/building.inc/doprogressorders.inc:295-310` |
| Cost escalation | `lib/unit.script:5652-5689` |
| Income/consume | `lib/player.script:242-322` |
| Market bands & trade | `lib/res.script:178-250,272-344` |
| Famine/rebellion rolls | `units/unit.inc/nothing.inc:450-496`; `lib/misc.script:494-498` |
| Selection priority & camera | `lib/control.script:156-274,422-530,574-708` |
| Terrain/decor/season | `common.inc/dogenerate.inc:407-485,522-641,1542-1581,1971-2084`; `common.inc/texturemap.inc:4-44,525-951`; `common.inc/generatemap.inc:4-53,568-650` |
| FX explosion | `misc/projectile.inc/doexplode.inc:12,19-28,56-168` |
| Camera config values (cross-file) | `data\cameras\camera.cfg` (1,613 B, full file read) + `lib/control.script:581-589` |
| Donor hotkeys.cfg has no patrol action (cross-file) | `data\game\var\hotkeys.cfg` (`Key = Q` → viewcollision; `Key = P` → `build\|%com%por`) |
| AI model | `dmscript.global:341-601`; D-12 function lists |

All temp analysis scripts live in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\dec02_*.py` and are **not**
in the repository.

---

## 11. Summary

Every one of the **222 files (4,373,442 bytes)** under donor `data\scripts` was
enumerated, classified by encoding/syntax/purpose and tabulated (§3). The code
dialect is Delphi-like DScript in three container forms; 19 files carry CP1251
Russian comments (a correction to prior docs). Sixteen deep records translate
the gameplay logic with exact `path:line` citations, including the damage order,
formation bonus consumption, 25% squad disband, 37.5 s hold ramp, exponential
recruit cost, income/upkeep accumulators, exact market mean reversion, famine
death rolls, priority-weighted cursor picking, camera `camera.cfg` keys,
640×640 terrain generation and season/FX rules. The port has since closed the
formation-bonus and recruit-modifier gaps (corrections to P1/P6), but still
diverges on market, famine, cost escalation, selection, camera and the entire
four-layer AI. Ten ranked porting implications and seven open questions are
recorded. Donor was never executed or copied; no code was edited.
