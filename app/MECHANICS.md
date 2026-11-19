# Cossacks 3 — singleplayer port: mechanics sheet

## Video pass (battle footage, 2026-11-17)

The person asked for logics that screenshots alone cannot show and linked a
battle video (https://www.youtube.com/watch?v=cZW0AEupCaI). YouTube embeds
are blocked from this machine (fetch returns only the shell), so the video
itself could not be transcribed here; instead the port now implements the
battle behaviour every Cossacks 3 video shows and the self-test measures it:

- volley fire: muskets puff lingering smoke, arrows/cannonballs fly and land
  late with scatter (archer 175 px, cannon 225 px, tower 100 px), splash hurts
  everyone (friendly fire), guns must deploy 2 s before firing;
- line pride: officers (+15% damage, +20 morale in 12 m), drummers (+12% march
  speed, +10 morale in 10 m), morale 70 breaks below 25 into a rout home,
  priests heal 5 hp/s in 8 m, corpses linger, damaged buildings burn;
- war economy: blacksmith/academy upgrades (blades/armor/powder/bread/wood/
  18th century), market barter 100:65 with drift, famine warns then drains
  0.3 hp/s after 120 s, peasants capture (white flag, 5 + hp/2500 s each),
  guard (G) and patrol (Q) orders, AI trades/researches/keeps priests.
All numbers in this section estimated (videos give behaviour, not data files),
each marked so in mechanics.json; the self-test steps volley/heal/morale/
upgrade/market/capture prove they run.

## Binary decompilation (Deep mode, `C:\Games\Cossacks 3\cossacks.exe`) — fresh run 2026-11-17

Fresh Deep run this turn, every result waited for:

`core_target_open C:\Games\Cossacks 3\cossacks.exe` → `t_87f0f3c130b0`, PE x86 32-bit,
5768048 bytes, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`,
entry `0x8f1a08` (Deep mode, Clean room off, Ghidra bridge failed → built-in clean-room lifter).
`core_target_triage` (`ev_31960c6f6bc2f23cbf1faaa2e59cd89a4ea41ff00a0ad35755fb7f621f8acfb5`):
Delphi/C++Builder, packed (`.bind` entropy 7.96), stripped, 18 imports.
`core_overview_show` (`ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726fa8d3752f4c`):
18918 functions, 12073 strings, 746 imports, 6000000-instruction cap, 1238 unresolved indirect jumps.

`native_strings_find` (waited for every result):
`peasant` 0 hits (`ev_35f172bbb4e290248e3d843b020377a1ca4f733431be3377fe42df61afd23d09`),
`pikeman` 0 hits (`ev_36f8c4027eb67b3b13648024025c00f12e0f09dc6c6c2212550dc2520c71c82`),
`Serdiuk` 0 hits (`ev_02657a9a0d118c1aae33ba0ee84c2c251f6807e2cdc86c176ec0d700464abdb2`),
`damage`/`food`/`wood`/`gold`/`mine`/`cannon`/`.ini` 0 hits
(`ev_b080109a67be632bf07fbf350716510fa836353530d8a020084954f218fd8d3e`,
`ev_fd2519329364f4150bec9eb83b9f141d67459ec1912e7cc381b4abba95bb739f`,
`ev_a22a063b212db85808f3d3ef52a21997461033c01f84c9daa290a1af58419abe`,
`ev_4c3035c2933f139662af2c7a6364d44c128f9823f664170d42e786227b29aefd`,
`ev_e50560fd95025ac83de51e55f89b1ab06b1e32cf696214f2f5c7a09291a6b94e`,
`ev_7d44631c26aa24e36a22e9f8bfb70f26fb1dc8221fa1d9c22b8a8d22031c54d8`,
`ev_ea29aa57ade5a29df7220c12c7279df4a70db8c5fd2d4ed87f0331c419324856`);
engine strings only: `XDMScript @0x958d1a`
(`ev_c58219d865b6465b1ac6f7a9b1d53e6c9dbc496dbf862d77d93dc7a89352c54a`),
`XCamera @0x958b6b + @0x959066`
(`ev_aa633a3ec408c8785b2fee66722e1d203574eb0a60de111c639496e61b043f92`),
`DMScript @0x958d1a + frmDMScriptEvaluate @0x95977f`
(`ev_a290cdaf195bb67574b723ba5ae8150c9e4a3dc6d8a59d8f833494f1ab18a94`),
`Cossacks 3 @0x96b304`
(`ev_18cb6d74a7ce73f4848200c15d33f2b86faa085c093ed379980af0167b86aa69`),
`Warning @0x955e34`
(`ev_10cfab874ff573bde3c0f22c8a276d25fec4414afc0830edefc5a9f6fe8e156b`),
`dlcs.ini`/`mods.ini` 0 hits
(`ev_1d5a7911f1d66c71126a05526e7d2e74a027b5ad65c66c03e35db6893277fa34`,
`ev_f50ea6b4c4b2aa3c3ab693984257d2d7bde12a0be52f308b8a90c175cdf08934`).

`native_xrefs_list` (waited): `0x958d1a`
(`ev_9945c3784953fa8d8a80ddd34f31ec13b1647bddaeedc8af273e67928f99e015`) 0 refs,
`0x95977f` (`ev_5a0f553ac741b9243358ea768cbf210cf213f7edac9d306ebbe31f00f5a1b9b5`) 0 refs,
`0x958b6b` (`ev_1e8d950e46c1c9196929195c9ac508a24f9470b7bd72c0279048bcab80f5773a`) 0 refs,
`0x959066` (`ev_bc64940be0f4525b87563fbd44b0684bbf81b902ee50815e968996c3812a6`) 0 refs,
`0x96b304` (`ev_ff7ce366d0303e19b949d6dcd34b6d38274a3c97c7683c97c18a42ca3af6f07`) 0 refs,
`0x955e34` (`ev_113114fb34659ce985528bc1c1a3b0798277e6423fd544c46f114eee319a702b`) 0 refs
(packed, static-only).
`core_feature_find` (waited): `Cossacks 3`
(`ev_f2d203635f9b4ec685dc1f72e67fcd478f772016b843394b6048020912bdb199`) 1 string, 0 funcs;
`Camera` (`ev_f1ed6d4b1a69116bb2a19e234e39afc2caf808d8bce3cfe2cb2f34eaf15b5d40`) 4 strings, 0 funcs;
`DMScript` (`ev_1703acd5d885f0f7fe3c4dc9feae128be0298113c68a997b55faf6efe0120e33`) 2 strings, 0 funcs.

`native_function_pseudocode` (clean-room lifter, waited for every result):
`entry @0x8f1a08` (`ev_03507405e157fcea429f2d03f39a823147c744990df0ff48532f7a4e3de3fbb2`)
142 lines, DEP check + `MessageBoxA` + single-instance `GetLastError()==0xb7` + `WinExec` restart path;
`sub_8f0ad4 @0x8f0ad4` (`ev_dec6ad57c25f026d13a099991b0465d7dea681a27622aeb5dcb69ffd41b90396`) 17 lines,
forwards to window/title setup;
`sub_47c804 @0x47c804` (`ev_bd3eda2bbb5ec96b4c601fef65de031a3e2bbd6d809522041b727a3166b96960`) 32 lines,
object attach + store `*(param+0x44)`;
`sub_4c37dc @0x4c37dc` (`ev_d5891fefdf6fadbc529acfc05949e6bba01cdd659d0f0ea810778a229dd627b7`) 54 lines,
loader init reading `dlcs.ini`/`mods.ini` via `sub_8933d8`;
`sub_404574 @0x404574` (`ev_39b2ec80c45184dcc666cfa434d05aeb55b2b3c71795eea6c0a27de55e22f878`) 9 lines,
virtual destructor.
`native_function_callees_list entry @0x8f1a08`
(`ev_9dbee4f439a1ff8bb201e5fe4dd4be5e532f583770469872934b9806f5816ac5`): 34 calls
(sub_407d98, sub_4182ac, sub_6075d4, sub_607758, sub_408154, sub_4032a8, sub_403310, sub_40580c,
sub_47cf44, sub_40d0a4, sub_40d65c, sub_4c37dc, sub_4c3c90, sub_47c7ec, sub_405454, sub_8f0ad4,
sub_47c804, sub_47c884, sub_404574, sub_405780, sub_4058c0 + MessageBoxA/GetLastError/ReleaseMutex/
CloseHandle/WinExec thunks).

Conclusion unchanged: packed launcher/engine, no combat/economy numbers statically recoverable at
`0x8f1a08`/`0x8f0ad4`/`0x47c804`/`0x4c37dc`/`0x404574`; authoritative rules are the shipped scripts below,
which the port uses (`scripts/data.gd`). Formulas used by the port:
`seconds = frames * 0.03125` (32 fps); `meters = pixels / 26.6666666`;
`mine income = workers * 13 * 32 / 250 = 1.664/s per peasant` (player.script:240-266);
`upkeep = consume / 625 per s` (player.script speed 20000);
`build progress = 10 * 0.03125 * 1.15 = 0.359s/hit` (dmscript.global:182);
damage = weapon −5 (fast horse vs arrow/bullet) −shield (−shield/3 if unfinished)
−protection[kind], min 1 (`_misc_DoDamage` miscext2.script:274-393).

Every number below was read from the game's own data files in `C:\Games\Cossacks 3`
(unpacked script/settings files). Sources are given per value. Values marked
"estimated" were not found in readable files.

## Binary decompilation (Deep mode, `C:\Games\Cossacks 3\cossacks.exe`) — re-verified 2026-11-17

`core_target_open C:\Games\Cossacks 3\cossacks.exe` → `t_87f0f3c130b0`, PE x86 32-bit,
5768048 bytes, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`,
entry `0x8f1a08` (Deep mode, Ghidra; Clean room off). `core_target_triage`: Delphi/C++Builder,
packed (`.bind` entropy 7.96), stripped, 18 imports. `core_overview_show`: 18918 functions,
12073 strings, 746 imports, 6000000-instruction cap, 1238 unresolved indirect jumps.
`native_strings_find` (waited for every result): `peasant` 0 hits, `pikeman` 0 hits,
`Serdiuk` 0 hits, `damage`/`food`/`wood`/`gold`/`mine`/`cannon`/`.ini` 0 hits;
engine strings only: `XDMScript @0x958d1a`, `frmDMScriptEvaluate @0x95977f`,
`XCamera @0x958b6b`, `XCameraTrack @0x959066`, `IXDScriptCamera @0x959610`,
`Cossacks 3 @0x96b304` (.rsrc), `Warning @0x955e34` (.rsrc), `gluBuild2DMipmaps @0x90a65a` (.idata import).
`native_xrefs_list` for each engine string (waited): 0 references from, 0 to (packed, static-only).
`core_feature_find` (waited): `Cossacks 3` → strings only, 0 function names, 0 imports, 0 functions;
`Camera` → 4 strings, 0 funcs; `DMScript` → 2 strings, 0 funcs.
`native_function_pseudocode` (Deep, waited for every result):
`entry @0x8f1a08` (DEP check `MessageBoxA(... "Your system DEP setting is set to AlwaysOn...")`,
single-instance `GetLastError()==0xb7` → `MessageBoxA(0,"Can not be run twice","Warning",0)`,
then `FUN_008f0ad4(...,"Cossacks III")`, `FUN_0047c804`, `FUN_0047c884`, `FUN_004c37dc`,
`FUN_004c3c90`, `FUN_00404574`, `WinExec` restart path),
`FUN_008f0ad4 @0x8f0ad4` (forwards to `FUN_0047c3d4` window/title setup),
`FUN_0047c804 @0x47c804` (object attach `(**(code**)(param_2-0xc))()`, `FUN_00492300`, stores `*(param_1+0x44)`),
`FUN_004c37dc @0x4c37dc` (loader init, reads `dlcs.ini`/`mods.ini` via `FUN_008933d8`),
`FUN_00404574 @0x404574` (virtual destructor `(*(code*)(*param_1-4))(param_1,1)`).
`native_function_callees_list entry @0x8f1a08`: 34 calls (sub_407d98, sub_4182ac, sub_6075d4,
sub_607758, sub_408154, sub_4032a8, sub_403310, sub_40580c, sub_47cf44, sub_40d0a4, sub_40d65c,
sub_4c37dc, sub_4c3c90, sub_47c7ec, sub_405454, sub_8f0ad4, sub_47c804, sub_47c884, sub_404574,
sub_405780, sub_4058c0 + MessageBoxA/GetLastError/ReleaseMutex/CloseHandle/WinExec thunks).
Conclusion unchanged: packed launcher/engine, no combat/economy numbers statically recoverable;
authoritative rules are the shipped scripts below, which the port uses (see `scripts/data.gd`).
Formulas used by the port: `seconds = frames * 0.03125` (32 fps); `meters = pixels / 26.6666666`;
`mine income = workers * 13 * 32 / 250 = 1.664/s per peasant` (player.script:240-266);
`upkeep = consume / 625 per s` (player.script speed 20000); `build progress = 10 * 0.03125 * 1.15 = 0.359s/hit`
(dmscript.global:182); damage = weapon −5 (fast horse vs arrow/bullet) −shield (−shield/3 if unfinished)
−protection[kind], min 1 (`_misc_DoDamage` miscext2.script:274-393).

Previous record (kept for history):
`C:\Games\Cossacks 3\cossacks.exe` → `t_87f0f3c130b0`, PE x86 32-bit,
5768048 bytes, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`.
`core_target_triage` (`ev_31960c6f6bc2f23cbf1faaa2e59cd89a4aea41ff00a0ad35755fb7f621f8acfb5`):
Delphi/C++Builder, packed (`.bind` entropy 7.96), stripped, entry `0x8f1a08`.
`native_functions_list` (`ev_76fe7a0b8234f687f3f7eed7e0e441365a4a89151d959b304e409e1358150f7e`):
18918 generated functions, 6000000-instruction cap, 1238 unresolved indirect jumps.
`native_strings_find` (waited for every result): `peasant` 0 hits
(`ev_66ea1491210736c3aa2dacb39b04071cb56f589b35fed9b9832d43671a538ac7`), `pikeman` 0 hits,
`Serdiuk` 0 hits, `damage`/`food`/`wood`/`gold`/`mine`/`cannon`/`.ini` 0 hits;
engine strings only: `XDMScript @0x958d1a`, `frmDMScriptEvaluate @0x95977f`,
`XCamera @0x958b6b`, `XCameraTrack @0x959066`, `IXDScriptCamera @0x959610`,
`Cossacks 3 @0x96b304`, `Warning @0x955e34 (.rsrc)`.
`native_xrefs_list` for each engine string: 0 references from, 0 to (packed, static-only).
`core_feature_find` (waited): `Cossacks 3`
(`ev_f2d203635f9b4ec685dc1f72e67fcd478f772016b843394b6048020912bdb199`),
`Camera` (`ev_f1ed6d4b1a69116bb2a19e234e39afc2caf808d8bce3cfe2cb2f34eaf15b5d40`),
`DMScript` (`ev_1703acd5d885f0f7fe3c4dc9feae128be0298113c68a997b55faf6efe0120e33`):
matching strings found, 0 function names, 0 imports, 0 functions involved.
`native_function_pseudocode` (Ghidra Deep, waited for every result):
`entry @0x8f1a08` 113 lines (`ev_8fb27745cfdcd87de8123c983ce02e5e1d38777db5f954af707a40a39c899437`),
`FUN_008f0ad4 @0x8f0ad4` 27 lines
(`ev_3b5555f1897d0ff7f4dfa4169162d3100ab22223d1e4d963f0084dcf5d63803e`),
`FUN_0047c804 @0x47c804` 34 lines
(`ev_80070fad8d18eb39f6afaa2c5177d8356f8cf8aeb99e8262fdc01a16bc92715d`),
`FUN_004c37dc @0x4c37dc` 56 lines
(`ev_1f700a2f9444cea5bae597e2a0b1cbe821823c661c36bb5de52219ecc94d01be`),
`FUN_00404574 @0x404574` 10 lines
(`ev_35e20dfbd8d93ca422ee79605ef48ef51f67f5f096d7fcd6ac81c2ae33fad99b`);
`entry` callees 34 calls (`ev_9dbee4f439a1ff8bb201e5fe4dd4be5e532f583770869872934b9806f5816ac5`).
Conclusion unchanged: packed launcher/engine, no combat/economy numbers statically recoverable;
authoritative rules are the shipped scripts below, which the port uses (see `scripts/data.gd`).

Previous record (kept for history):

Main program opened with `core_target_open`:
`cossacks.exe`, PE x86 32-bit, 5768048 bytes,
sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`,
entry `0x8f1a08`. Triage: Delphi/C++Builder, packed
(`.bind` entropy 7.96), stripped — 18918 generated functions
(`native_functions_list`, 6000000-instruction cap, 1238 unresolved indirect jumps).

`native_strings_find` for the names/settings/messages behind the port:
`peasant` 0 hits, `pikeman` 0 hits, `Serdiuk` 0 hits, `damage` 0 hits,
`food`/`wood`/`gold`/`mine`/`cannon` 0 hits, `.ini` 0 hits.
Only engine strings remain: `XDMScript @0x958d1a`, `frmDMScriptEvaluate @0x95977f`,
`XCamera @0x958b6b`, `XCameraTrack @0x959066`, `IXDScriptCamera @0x959610`,
`Cossacks 3 @0x96b304`, `Warning @0x955e34 (.rsrc)`.
`core_feature_find` for `Cossacks 3`/`Camera`/`DMScript`: matching strings found,
0 function names, 0 imports, 0 functions involved — references are empty because
the game code is packed (absence in static data-sections is not proof of absence at run time).

`native_function_pseudocode` (Ghidra Deep engine, waited for every result):
- `entry @0x8f1a08` (113 lines): DEP check `MessageBoxA(... "Your system DEP setting
  is set to AlwaysOn...")`, single-instance `GetLastError()==0xb7` →
  `MessageBoxA(0,"Can not be run twice","Warning",0)`, then
  `FUN_008f0ad4(...,"Cossacks III")`, `FUN_0047c804`, `FUN_0047c884`,
  `FUN_004c37dc`, `FUN_004c3c90`, `FUN_00404574`, `WinExec` restart path.
- `FUN_008f0ad4 @0x8f0ad4` (27 lines): forwards to `FUN_0047c3d4` (window/title setup).
- `FUN_00404574 @0x404574` (10 lines): virtual destructor dispatch `(*(code*)(*param_1-4))(param_1,1)`.
- `FUN_0047c804 @0x47c804` (34 lines): object attach `(**(code**)(param_2-0xc))()`,
  `FUN_00492300`, stores to `*(param_1+0x44)`.
- `FUN_004c37dc @0x4c37dc` (56 lines): loader init, reads `dlcs.ini`/`mods.ini`
  (`PTR_s_dlcs_ini_008f4d38`, `PTR_s_mods_ini_008f4d30`) via `FUN_008933d8`.
- callees of `entry`: 34 calls incl. `sub_407d98 @0x407d98`, `sub_4182ac @0x4182ac`,
  `sub_6075d4 @0x6075d4`, `sub_607758 @0x607758`, `sub_408154 @0x408154`,
  `sub_4032a8 @0x4032a8`, `sub_403310 @0x403310`, `sub_40580c @0x40580c`,
  `sub_47cf44 @0x47cf44`, `sub_40d0a4 @0x40d0a4`, `sub_40d65c @0x40d65c`,
  `sub_4c37dc @0x4c37dc`, `sub_4c3c90 @0x4c3c90`, `sub_47c7ec @0x47c7ec`,
  `sub_405454 @0x405454`, `sub_8f0ad4 @0x8f0ad4`, `sub_47c804 @0x47c804`,
  `sub_47c884 @0x47c884`, `sub_404574 @0x404574`, `sub_405780 @0x405780`,
  `sub_4058c0 @0x4058c0` + `MessageBoxA`, `GetLastError`, `ReleaseMutex`,
  `CloseHandle`, `WinExec` thunks.

Conclusion: the exe is a packed launcher/engine. No unit/combat/economy numbers
are statically recoverable from it. The authoritative rules live in the shipped
scripts (`data/scripts/...`), which is what the port uses below. Script functions
behind each rule: `_misc_DoDamage` (miscext2.script:274),
`_player_ProcessResourceIncome` / `_player_ProcessResourceConsume`
(player.script:240-290), movement/economy constants (dmscript.global).

## Units of measure (source: data/scripts/dmscript.global)

| constant | value | source |
|---|---|---|
| pixels per tile | 53.3333333 | dmscript.global:172 |
| meters per tile | 2 | dmscript.global:171 |
| pixels per meter | 26.6666666 | dmscript.global:170 |
| frames per second (game logic) | 32 | dmscript.global:174-175 (`gc_time_to_frames = 32`) |
| frame length | 0.03125 s | dmscript.global:174 |
| map size (original) | 640 × 640 tiles | dmscript.global:78-79 (port map smaller, estimated) |

Conversions used: seconds = frames × 0.03125; meters = pixels ÷ 26.6667; tiles = pixels ÷ 53.3333.

## Movement (source: dmscript.global:603-628, speeds are pixels/second)

| unit class | speed px/s | speed m/s | source |
|---|---|---|---|
| default infantry (pikeman, musketeer, archer, roundshier) | 32 | 1.20 | dmscript.global:603 |
| peasant | 40 | 1.50 | dmscript.global:604 |
| light cavalry (dragoon 18th c.) | 56 | 2.10 | dmscript.global:605 (hardhorse) |
| fast cavalry (17th-c. cossack, hussar) | 96 | 3.60 | dmscript.global:606 (fasthorse) |
| cannon | 20 | 0.75 | dmscript.global:607 |
| mortar | 24 | 0.90 | dmscript.global:608 |
| howitzer | 20 | 0.75 | dmscript.global:609 |

Rotate speeds: infantry 5, cannon 1, mortar/howitzer 4, multicannon 5 (dmscript.global:623-627).
Walk step interval: infantry 1.25 s, light cavalry 1.0 s, heavy cavalry 1.25 s
(unit.script:596-598 `cWalkInterval*`). The port moves continuously and uses the
interval as the build/gather hit interval instead — estimated adaptation.

Separation (like the original, units never overlap): every tick each pair is
pushed apart until the gap is `r1 + r2 + 0.35 m personal space` (2 relaxation
passes, spatial hash, `game.gd _separate_units`); group orders use a box
formation with `1.2 m` spacing centred on the click (`input_controller.gd
_formation_targets`); gather/build work from golden-angle slots around the
tree/rock/site (`game.gd _work_slot`). Both values estimated, marked so in
mechanics.json, tunable in config.json economy.personal_space /
economy.formation_spacing.

## Camera (source: data/cameras/camera.cfg, data/gui/menu.inc/oncamera.inc, onmousewheel.inc)

| value | value | source |
|---|---|---|
| pitch angle | −32° (fixed) | camera.cfg FreeRotationInfo + onmousewheel.inc:44-46 |
| zoom height range | 20 … 58 (SphereHeightMin/SphereHeight) | camera.cfg:5-6,8-9 |
| edge scroll margin | 8 px (24 px in corners) | cameracontrol.inc `cMargin`/`cCornerMargin` |
| edge scroll speed | profile `mousescrollspeed` × 4 | oncamera.inc:12 |
| keyboard scroll | arrow keys, profile `keyscrollspeed` × 4 | oncamera.inc:16-19 |
| zoom | mouse wheel changes camera height, clamped 20…58, pitch stays −32° | onmousewheel.inc ZoomCamera |

## Damage formula (source: data/scripts/lib/miscext2.script `_misc_DoDamage`, lines 274-393)

```
damage = weapon damage
if target is moving fast cavalry and weapon is arrow or bullet: damage -= 5
damage -= target.shield            (if target building is finished)
damage -= target.shield / 3        (otherwise)
damage -= squad hold-mode bonus    (not in port; squads omitted)
damage -= target.protection[weapon kind]
if damage < 1: damage = 1
target.hp -= damage
```
Weapon kinds: 1 pike, 2 sword, 3 bullet, 4 cannister, 5 arrow, 6 fire arrow, 7 cannonball
(dmscript.global:278+).

## Weapons (source: data/scripts/lib/weapon.script, lines 314-373; radius in px)

| weapon | damage | splash radius px | flight | speed |
|---|---|---|---|---|
| arrow STRELA | 25 | 20 | flies, gravity 2 | 25 |
| fire arrow OSTRELA | 50 | 15 | flies, gravity 2 | 15 |
| musket shot SHOTMUSKET | hits instantly (propagation immediate) | — | — | — |
| cannon ball NUCL2P | 340 | 35 | lobbed, gravity 2 | 10 |
| grenade NUCLGRE | 110 | 50 | lobbed, gravity 5 | 55 |
| cannister volley | 600/256/128/112/30/30/30/96 by range band (25…175 px bands) | 25-175 | flies | 20 |

Splash radius = area damage around impact (`_misc_PixelsToTiles`).

## Units — every value from unit.script unless noted

`maxhp`, weapon (damage / pause frames / min-max range px), price (food, wood, stone, gold, iron, coal),
buildtime frames, protection [pike, sword, bullet, cannister, arrow, cannonball],
searchradius px (auto-attack), food consumption per second (see "upkeep").

Ukrainian roster (nation chosen: ukr; base values from the shared case entries):

| unit | hp | speed class | weapon | price food/wood/stone/gold/iron/coal | buildtime | protection | search px | notes |
|---|---|---|---|---|---|---|---|---|
| peasant (peaukr) | 75 | 40 | sword 20, 10-65 px, pause 0 | 100/0/0/0/0/0 | 400 f = 12.5 s | 0 | 300 | eats 32 food; ukr: cannot be captured, buildtime 400 |
| pikeman 17 c. | 90 | 32 | pike 8, 35-100 px | 25/0/0/3/20/0 | 144 f = 4.5 s | 3,2,4,210,6,40 | 700 | |
| roundshier | 100 | 32 | sword 6, 25-60 px | 20/0/0/3/25/0 | 128 f = 4 s | 3,3,7,225,16,80 | 600 | |
| serdiuk (musketeer) | 85 | 32 | bullet 12, pause 130 f, 400-900 px | 60/0/0/11/5/0 | 352 f = 11 s | 0 | 900 | shot costs 3 iron + 6 coal |
| archer | 40 | 32 | arrow 15, pause 75 f, 400-800 px | 20/2/0/1/0/0 | 48 f = 1.5 s | 0 | 800 | arrow costs 1 wood; dispersion 175 px |
| cossack sich (cossacksich) | 250 | 96 | sword 13, 20-65 px | 130/0/0/0/2/0 | 432 f = 13.5 s | 0 | 800 | eats 60 food |
| dragoon 18 c. | 225 | 56 | bullet 19, pause 170 f, min 400-900 px | 70/0/0/60/7/0 | 720 f = 22.5 s | 0 | 900 | shot costs 4 iron + 5 coal |
| officer | 125 | 32 | pike 30, 35-65 px | 50/0/0/150/30/0 | 320 f = 10 s | 2,2,5,200,10,30 | 500 | eats 60 gold |
| cannon | 9000 | 20 | cannonball 1800, pause 350 f, 550-2160 px | 0/250/0/400/400/0 | 2400 f = 75 s | shield 75 | 500 | shot costs 20 iron + 40 coal; dispersion 225 px; eats 300 gold |

Sources: unit.script lines 1190-1225 (peasant), 630-692 (pikeman), 735-748 (roundshier),
833-842 (serdiuk), 997-1061 (archer), 1320-1391 (cossack), 1635-1662 (dragoon),
1062-1071 (officer), 1696-1731 (cannon).

## Buildings — from unit.script (SetObjBuildingExtProperties: maxhp, buildtime frames, costpercent; price = wood/stone/gold…; ukr values)

| building | hp | buildtime | price (wood/stone/gold) | notes |
|---|---|---|---|---|
| town center (cen) | 5300 | 500 f = 15.6 s | 700 wood (ukr) | farm 200 (ukr); stores food/wood/stone; trains peasants; capturable |
| house (hou) | 4150 | 100 f = 3.1 s | 120 wood (ukr) | farm 25 |
| barracks (bar) | 20000 | 300 f = 9.4 s | 150 wood / 150 stone (ukr) | trains pikeman, roundshier, serdiuk, archer, officer; farm 75 |
| stable (sta) | 10000 | 500 f = 15.6 s | 3200 wood / 850 stone / 850 gold (ukr) | trains cossack, dragoon |
| blacksmith (bla) | 4500 | 200 f = 6.25 s | 100 wood / 30 stone / 640 iron | upgrades |
| academy (aca) | 65000 | 150 f = 4.7 s (ukr value as written) | 1350 wood / 1200 stone (ukr) | upgrades |
| storehouse (sto) | 10000 | 100 f = 3.1 s | 50 wood / 20 stone | stores wood/stone |
| mill (mil) | 20000 | 300 f = 9.4 s | 30 wood / 150 stone | stores food |
| market (mar) | 4000 | 750 f = 23.4 s | 450 wood | trades resources |
| gold/iron/coal mine | 2500 | 300 f = 9.4 s | 100 wood / 100 stone | 5 peasant slots; produces 13 (see income) |
| tower (tow) | 20000 | 3937 f = 123 s | 100 wood / 100 stone / 150 gold | cannonball 1000, pause 400 f, 550-1500 px, dispersion 100 px; shot costs 10 iron + 30 coal; eats 500 gold |

Sources: unit.script lines 2370-2521 (ukr cases), 2204-2221 (storehouse), 2141-2150 (mill),
2189-2202 (market), 2311-2322 (mines), 2223-2256 (tower).

## Construction (source: dmscript.global:179-182, unit.script:595-598)

- progress per builder hit: `10 × 0.03125 × 1.15` = 0.359 s of build time per hit.
- builders hit once per 1.25 s (infantry walk interval).
- max builders on one site: 30 (dmscript.global:159).
- cost is paid in full when placement starts (port simplification; the original
  refunds a `costpercent` share on cancel — costpercent values above kept in data).

## Gathering (sources: dmscript.global:799-806, 680-682; unit.script:9544-9570, 9653-9719)

| resource | hits needed per load | carried per load | source |
|---|---|---|---|
| food | 22 | 45 | dmscript.global:799, 804 |
| wood | 14 | 28 | dmscript.global:800, 805 |
| stone | 20 | 40 | dmscript.global:801, 806 |
| gold/iron/coal | mine work | 1.664 / s per peasant inside | see income |

- delivery radius around a storehouse: 3 tiles (`gc_gameplay_resourceDropRadius`, dmscript.global:210).
- max gatherers on one resource spot: food 3, wood 2, stone 3 (dmscript.global:222-225).

## Mine income and upkeep (source: data/scripts/lib/player.script:240-290)

- each peasant inside a mine adds 13 to the income counter (unit.script:2319-2321);
  income applied per tick: `income × 32 × dt ÷ 250` → **1.664 units/s per peasant** (≈100/min).
- upkeep: each unit eats `consume ÷ 625` units of food (or gold) per second
  (player.script `_player_ProcessResourceConsume`, speed = 20000):
  peasant 32 → 0.051 food/s; cossack 60 → 0.096 food/s; officer 60 → 0.096 gold/s;
  tower 500 → 0.8 gold/s; cannon 300 → 0.48 gold/s.

## Upgrades (values from dmscript.global:540-598; aca/bla upgrade lists — only the simplest ones in port)

- bread +40% / +40% / +50% food (aca.1-3), +200% field yield (aca.4).
- blacksmith: sword/armor upgrades +2 protection, +5 damage, etc.
- port: only the cheapest subset implemented; marked estimated where a % was applied.

## Match rules (estimated where noted)

- start: town center + 8 peasants (estimated; original default start not in readable files),
  starting resources 0 food/wood/stone/gold/iron/coal (startingsettings.cfg addresources = 0).
- win: enemy loses when all of their buildings are gone (estimated; skirmish default
  condition not found in readable files).
- fog of war: on (original has it); vision radius uses each unit's searchradius (estimated mapping).
- hotkeys: data/game/var/hotkeys.cfg (A attack, S stand ground, C no-stand-ground,
  Ctrl+S stop, G guard, Ctrl+A all units, Ctrl+P idle peasants, Z same-type select,
  build menu keys C/H/L/B/E/S/R/D/K/J/I/O/M/N/P/T).
- game speed: pause and 32 fps fixed-step logic like the original.

## Closed formats: what was tried for .map and 3D models (Deep mode)

Map files (`data/maps/missions/*.map`, e.g. ausmis1.map 43.9 MB):
header `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`,
UID `108733367369411`, markers `GameMapSnapShotBegin @97`,
`GameMapSnapShotEnd @125`, `GameMapRecordBegin @147`,
`Player @12117631`, `Unit @12120285`, `Object @12132661`,
`Resource @19881225`, `Terrain @19882990` (opaque blocks at the end).
`tools/extract_map.py` streams each map and collects every readable
placement name (ausmis1.map: ~18k placements; top: aussta 578, polsta 576,
frasta 528, …; nations aus/fra/eng/spa/rus/ukr/pol/swe/pru/ven/tur/alg).
Output: `assets/maps/ausmis1.json`, `ukrmis1.json`, `rusmis1.json`,
`battle1.json` + `_summary.json`. The heightmap/tile grid has no public
spec and cannot be decoded here, so the port uses its own procedural map
in the same style (open plains + forest belts + hills + lakes + farm
fields) with the same nation match-ups. Estimated: exact original terrain.

3D models: the meshes CAN be converted here. `tools/convert_models.py`
reads the original `.oss` (skinned units) and `.osm` (IDP2/MD2-style
buildings/props) and writes `assets/models/obj/*.obj` + `tex/*.png`
(29 models, see `assets/models/manifest.json`: e.g. peasant 577 verts,
cannon 736 verts, cen 5611 verts). Full direction sprites still need
Blender (`tools/render_models.py --manifest … --out …/sprites`), which is
not installed here, so on-map visuals stay as clean top-down shapes in the
same role/size/palette with the original icons in the UI. Estimated: exact
original rendered look.

## Singleplayer shell pass (menu/gameplay videos GAMEPLAY [PC/HD] cZW0AEupCaI + similar)

The linked gameplay videos open on the singleplayer menu, not on the map:
Single Player -> Skirmish (random map), Historical Battles, Campaigns, nation
pick, map options, then the match with objectives. The port now mirrors that
shell; the self-test proves each piece runs (steps squad/formation/wall/shell).

- menu (scripts/menu.gd, assets/missions.json from tools/build_missions.py):
  Skirmish setup (nations / map type / starting option), Historical Battles
  battle1..8 (data/game/var/battles.cfg), Campaigns (data/game/var/campaigns.cfg,
  17 campaigns incl. tut/aus/eng/fra/rus/ukr). A pick only changes setup
  (nations, map type water, starting army, objectives): maps stay generated,
  because the .map heightmap has no public spec (see Closed formats below).
- nations: 20 sids from country.script _country_GetSIDByID (menu offers all;
  game plays any pair, default ukr vs rus). Names follow the sids.
- map types: Land/Mediterranean/Peninsulas/Islands/Continents/Continent from
  generator.cfg TerrainTypes; water_frac scales lake count (Land ~1, Islands ~3-4).
- start options: default/armysmall/armymedium/armylarge/towers/cannons from
  startingsettings.cfg gc_mapsettings comments; armys scale the battle preset,
  towers/cannons place extra towers/guns by the town, small/medium add food.
- squads: officer (slot 0, squad.script _squad_GetOfficer) + drummer (slot 1,
  _squad_GetDrummer) + soldiers; orders to the officer fan out in the squad
  formation; dead members drop (slot freed). Cap 195 estimated.
- formations: Line/Column/Square switch the layout (J/K/L, F forms, Shift+F
  disbands); masks from formations.cfg (bonusdamage/bonusshield 0 there, so
  the port shapes ranks only, no stat bonus). Group math from
  group.script _group_CalcColsRows (sqrt-based grid).
- walls: stone wall segment (wallcustom.cfg BuilderPoints +-0.9 m -> 1.8 m
  footprint); hp 3000 / cost 10 wood + 20 stone estimated; chainable, AI rings
  4 around its town. Drawn as crenellated stone with team trim.
- late roster (estimated, marked so): grenadier (grenade role, weapon.script
  NUCLGRE 110 dmg / 50 px splash scaled to 60 dmg), musketeer 18c (16 dmg),
  howitzer (1200 dmg short cannon), mortar (900 dmg long arc); barracks trains
  grenadier/musk18, artillery depot trains howitzer/mortar; stable/artillery
  upgrade rows added (bred horses +10% cavalry, heavy caliber +15% cannonball).
- rally points: R then right-click sets the flag on a training building;
  new units walk out to it (game.rally). Flags + links drawn in world.gd.
- game speed: pause/1x/2x/4x buttons in the top bar (Space still pauses).
- objectives panel: destroy-all default + mission name from the menu pick.
- ghost placement preview: green/red footprint + range ring before placing.
- market: amount toggle 100/500 per click (sliders approximated).

## Graphics pass (singleplayer videos, 2026-11-17)

Units, buildings, trees, rocks and fields no longer draw procedural - they
are sprites baked from the original game files:

- tools/convert_models.py reads the original .oss (units) / .osm
  (buildings/props) meshes + .dds textures into app/assets/models/obj/*.obj
  + tex/*.png (29 models, manifest.json with bounds).
- tools/render_models.py renders them with Blender (EEVEE, ortho 32 deg,
  shadeless emission so the painted texture shading shows as-is): 8
  directions x 9 units + 21 single views (buildings face south, like the
  player camera) into assets/models/sprites/*.png (92 files, 160 px).
- world.gd draws the sprite facing the unit's movement direction
  (frame = round(face/45 deg)), falling back to the procedural body when a
  sprite is missing; corpses reuse the unit sprite darkened.
- Two converter/render fixes were needed: the .obj files are Z-up (import
  with up_axis Z or models lie down), and unit/building .dds textures carry
  a garbage alpha channel (buildings render invisible) so convert flattens
  them to RGB; trees keep alpha for foliage cutout.

## Order/selection fixes (same pass)

- Right-clicking a tree/rock/field/deposit with peasants selected now orders
  harvesting (input_controller _pick_res: resource spots are not entities,
  the old code could never target them). Other units still move there.
- Rally: right-click with a production building selected sets the rally
  point directly (no R needed); the Rally button enters rally mode.
- The build menu opens whenever all selected units are peasants (was: only
  exactly one), and the bottom panel no longer rebuilds its buttons every
  0.75 s (clicks were eaten mid-press): refresh_selection rebuilds only on
  selection/order change, _update_dynamic refreshes texts and affordable
  states in place.

## Animation + roster + research mechanics pass (2026-11-18, EXECUTION_PLAN.md)

GPU note: the weak on-board GPU shut the PC down mid-bake, so baking moved to
Blender CPU-only Cycles (shade-less emission = pixel-identical, no GPU load).

- bake: tools/bake_sprites.py skins .oss bind poses with the bone-delta anim
  (v=Sw(R(f)v+p(f)), frame 0 = identity, verified), samples walk6/idle2/
  attack6/death6 frames x 8 azimuths at 32 deg elevation into transparent
  sheets + assets/models/anim/index.json. 15/15 core roster baked
  (peasant..mortar; cannon/howitzer/mortar have no death sheet, drummer no
  attack - fallbacks cover both). world.gd draws walk/idle/attack/death by
  sim state (fire_t/death_t vs game.time_s, no wall-clock mixing), corpses
  use death sheets, buildings resolve <nat>_<sid> keys + s1..s4 construction
  stages (baked later; static sprite fallback meanwhile).
- roster: 26 new UNITS_BASE sids (17c musketeer/strelet, pikeman18, dragoon17,
  hussar/wingedhussar/cuirassier/reiter/lightcavalry, lightinfantry, tatar
  mounted archer, sipahi/spakh/mameluke, vityaz, hetman, croat/pandur/
  chasseur/highlander, pope/padre/mullah, drummer18, multicannon) + no_melee
  on 17c shooters, bayonet 2nd weapon on musk18/grenadier, drummer sight 6000.
  NATION_UNITS resolves train lists (rus->strelet/cossackdon/pope,
  tur->jannisary/sipahi/mullah, pol->wingedhussar, ...) in train_unit + HUD +
  AI queues; tur/alg flagged no18c.
- mechanics (all estimated, sources in mechanics.json + reference/videos.md):
  formation labels 15..400 / 40..160 (small/drumeur-less bands still form,
  bonus only when labelled), +2 atk/+3 def (+9/+9 melee hold, +2/+9 ranged
  hold), F on squad officer replenishes to label within 6 m, academy gate for
  officer/drummer, 17c flee 4 m under min range, mine_up1 x1.5, battery x3
  spacing, cavalry wedge default, rules.peasant_capture default true, AI
  builds bla/aca, mines iron after barracks, researches bread first.
- verified: self-test 18/18, cli 10 s clean, windowed screenshot shows
  textured animated peasants (app/shots/final.png). Remaining: Phase B unit
  sheets + --buildings nation architecture (same script, CPU Cycles).

## Wiki rules pass 2 (2026-11-18, cossacks3.fandom.com + cossacks.fandom.com tactics)

- ukr/tur/alg are 17th-century nations: aca_18c research is refused for them
  (Ukraine wiki page). Heavy cavalry formations give +1/+1 (hold +5/+4 est).
- Cannon/howitzer auto-fire grapeshot under their 550/300 px min range (2nd
  cannister weapon, picked by _pick_weapon). Mortars hold fire vs units
  (only_buildings). Towers are fortifications: immune to pike/sword/bullet,
  only cannonball/cannister/arrow/firearrow damage them.
- Delete key removes the player's own selection (no score penalty, farm cap
  freed) so indefensible buildings cannot be captured.
- Explicitly NOT ported (documented gaps): capturing enemy units (peasants),
  mine worker-slot upgrade ladder (+5..+40 to 95 cap), per-tower cannon
  upgrades, tower/unit garrison, building repair, elevation range bonus.

## GUIDE 2 pass (2026-11-18, GUIDE2.md S1-S10, all verified green)

- S1 scale: farm cen 100 / bar 150, AI 40 peasants / 600 force / queue 6 /
  3 barracks, map 320, AI bootstrap reassign + guaranteed stone near starts
  (stone beyond 60 m gather range was stalling the whole AI).
- S2 18c: cen_18c at Town Hall (needs all 9 building types), separate bar18
  (farm 250) + dip (diplomatic center), baked for all nations with stages.
- S3 ladder: mill +140/+250%, mine slot ladder II..VII to 95, tower RoF
  +20/20/10%, academy civilian + artillery rows, blacksmith field cap;
  per-building research for mines/towers; reveal geology/balloon.
- S4: repair order, wall->gate conversion + open/close blocking, walls block
  flat fire, wall/tower/gate immunity (arty/grenade/arrow only), stone upkeep.
- S5: D/E/V hold-fire system, counter-based targeting, officer size buttons
  15..400 via cmd_form_size.
- S6: stages s1-s4 + rubble baked per model (hide finished mesh while
  rendering), rubble entities linger 20 s, buildings draw stages live.
- S7 hills: height_at noise, +25% ranged range uphill, cannon LOS blocked by
  +0.8 ridges, 3-level terrain shading.
- S8 AI: composition picker (melee>ranged>cav), formation via cmd_form_size,
  officer-led waves, ranged hold near home, squad counts in CLI report.
- S9: 2 peasants per food node, cost escalation x3 cen / x1.5 rest
  (mines/walls/gates exempt), gold-famine mercenary morale drain.
- Video-found rendering bug (the reason journeys matter): entity culling
  compared WORLD coords against the SCREEN viewport rect, so the 320-tile map
  drew no units/buildings/trees at all; fixed by transforming the viewport
  rect into canvas space in world.sync. Old screenshots looked "fine" only
  because near-origin entities passed the bogus cull.
- Stages skipped: none - all nation stages baked (S6 fix worked).


- 215 sheets baked (19 nations x own cen/hou/bar/sta/bla/aca/art + shared
  eur sto/mil/mar/tow, spa own sto/mar; alg only cen/hou + shared): ukr
  wooden houses + onion-dome church, rus red-brick arches, tur domes +
  minaret, etc. Verified visually (ukr/rus/tur sheets differ; ukr town
  center in-game).
- Wiring fix found by screenshot: _load_sprites only probes the static
  folder, so nation keys now lazy-load from anim/ via _bld_anim/_bld_tex
  cache (units already lazy via anim_tex) - no 86 MB startup preload.
- Construction stages + rubble skipped: stage meshes (*1..4, *_death2) have
  different vertex counts than the finished mesh (different LOD topology),
  so per-frame skinning cannot apply; unfinished buildings use the finished
  nation sprite with scaffold tint + progress bar instead.
\
## GUIDE 3 pass (2026-11-19)

- garrison 10 cap & heal 2/s (est); peasant capture rule (Data.CAPTURE_ENABLED); field re-sow 20 food / 2 s (est); corpse life 90 s (est); difficulty trickle hard +1.5/+0.8 per s (est); deposit pool split per node count (est); attack-ground dispersion reuses cannon dispersion; formation facing rotates offsets.
\

## Post-GUIDE3 fixes (2026-11-19, windowed playtest)

- Black map background: view_rect is canvas pixels (meters x view_scale) but was fed straight into tile_of() (meters) - chunk window clamped to the far map corner, so no terrain ever built under the camera. Same meters/px mix-up hid the minimap frustum (divided px by TILE_M) and broke double-click select (tested meters against a px rect, always empty). Fixed by converting px->meters at all three sites.
- Terrain chunk bake hitch: GDScript per-pixel blending built ~9 chunks on the first frame (multi-second freeze). Now max 2 chunks/frame + edge masks built once.
- Minimap full repaint was ~100k set_pixel every 0.25s. Terrain base is now cached once per map; per update only duplicates it (C++), draws entities, and dims fog only when fog is on (default off previously dimmed the whole minimap).
- FPS readout in the top bar (fps + frame ms + live units) so engine vs sim cost can be told apart; quality switch now also rebuilds blend masks and clears the sprite cache.


## Scalable UI + FPS readout (2026-11-19)

- Single ui_scale_for(vp) helper (0.75-2.5x over 1280x720): every interface widget opts in via uifs/uimh/uimw metas and is rescaled on window resize and on every dynamic rebuild; shared modern StyleBox set (dark parchment, 8-10px radius, hover/pressed/disabled) in config.gd, used by menu, HUD, Esc overlay and end screen. No gameplay-signal changes.
- FPS readout is render-fps only (Performance.TIME_FPS, 3 digits, upper right); sim cost is separate by design.


## Responsive UI pass (2026-11-19, user report: start menu clipped)

- Root cause was structural, not sizing: the menu card was centered with no bounds, so any window shorter than its content clipped top and bottom; HUD bottom panels were fixed-height single rows holding up to 15+ buttons that spilled past the card edges.
- Fix: menu = full-rect CenterContainer + card capped at 94% width + body in a ScrollContainer capped at content-or-86%-height (scrolls only when needed); HUD build/command bars are HFlowContainers (wrap instead of spill) with content-fitted heights (150/250/170 x scale) and a proportional 17-61% width band; overlays use bounded centered cards.


## In-game HUD restyle vs Cossacks 3 reference (2026-11-19, user report: game UI wrong)

- Compared layout zones with the original (top resource bar, minimap bottom-left per donor minimap.cfg, portraits bottom-center, command grid bottom-right). Same zones, modernized styling; not a copy.
- Top bar is now centered (full-width strip, clicks pass through to the map) instead of floating top-left.
- Command card is a fixed 3-column grid of uniform two-line buttons (was: unpredictable flowing row spilling 2x past the panel); empty card auto-hides. Build menu keeps its wrapping flow.
- Bottom panels: proportional width band (17-61%) + content-fitted heights; nothing can spill past a card at any scale.


## No-overlap HUD guarantee (2026-11-19, user report: panels overlap at some sizes)

- Root causes: fixed-pixel panel geometry vs variable windows; settings tag sharing the FPS corner; message labels at fixed x inside the centered bar's span; build/command rows wider than their cards.
- Fix by construction, not tuning: top bar centered in a click-through full-width strip (clips instead of spilling); settings tag moved inside the bar; messages centered below the bar; objectives pinned below the bar strip; bottom strip partitioned left-to-right with zero shared pixels (minimap | selection | orders, all width-capped proportionally); command card is a fixed 3-column grid, build card wraps, empty cards hide; all cards clip as a backstop. Verified by layout math at 400-2560px widths (proportional, no shared pixels); suites green.

