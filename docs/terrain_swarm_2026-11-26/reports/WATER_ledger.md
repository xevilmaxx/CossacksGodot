# WATER Ledger — Complete FILE Scalar Ledger from `water.lib` (READ-ONLY)

- Worker: WATER-LEDGER (full 1:1 Cossacks 3 donor port)
- Donor source (text, read-only): `C:\Games\Cossacks 3\data\water\water.lib` (71 lines, §1 below)
- Port sources checked (read-only): `variant3d/config_donor_capture.json`, `variant3d/scripts/water3d.gd`, `variant3d/scripts/terrain_donor_mesh.gd`
- Scope: ledger ONLY. No code, no Godot execution, no git, no donor execution, no wiring proposal.
- Parity: UNVERIFIED. No approximations. No parity claim.
- Gate: U4* stays CLOSED. Chain 0/6. RESULT IS NOT GOOD.

## Rules used in this ledger

- Every donor value below was read byte-for-byte from `water.lib` at the cited `water.lib:<line>`.
- "Port transcription" means only: does the literal already appear in one of the three port files listed above? Answer is an exact `port-path:line` or the string `not present`. A port citation is NOT a liveness claim.
- Classification per value:
  - `[D]` = FILE value byte-proven (the bytes in `water.lib` say exactly this; proven by read, nothing more).
  - `[U]` liveness = whether the engine actually uses the FILE tuple or the ENGINE ctor tuple at runtime is UNVERIFIED (U4* FILE-vs-ENGINE, `water3d.gd:210-292,753-761,823-852`; no default; `water_scalar_source` UNSET blocks draw).
  - `[U]` reflection identity = runtime reflection texture identity/provenance is UNVERIFIED (U12; no FBO provenance recovered; `water3d.gd:303-314,685-694` hard-fail, never a neutral texture).
- The three `features.water` keys in `config_donor_capture.json:34-38` (`surface_y`, `alpha_confine`, `shore_prox`) are PORT-ONLY keys. No donor constant backs `alpha_confine`/`shore_prox`; `surface_y` is a port A/B surface value, NOT a `water.lib` value. They are listed in §3 only for the requested cross-check.
- NOTHING in this ledger proposes wiring any value into the port. The U4* gate stays shut.

## §1 Donor file envelope (verbatim structure)

| # | Donor path:line | Bytes (verbatim, incl. comments/empties) | Class | Port transcription |
|---|---|---|---|---|
| 1 | `water.lib:1` | `section.begin` | `[D]` envelope | not present (no port file transcribes the `section.begin` envelope token) |
| 2 | `water.lib:2` | `waters : struct.begin` | `[D]` envelope | not present |
| 3 | `water.lib:3` | `[*] : struct.begin` (single water entry, index `*`) | `[D]` envelope | not present as a token; port `water3d.gd:961-972` records the single-entry contents as telemetry only |
| 4 | `water.lib:62` | `struct.end` (close `[*]`) | `[D]` envelope | not present |
| 5 | `water.lib:63` | `struct.end` (close `waters`) | `[D]` envelope | not present |
| 6 | `water.lib:71` | `section.end` | `[D]` envelope | not present |

## §2 Complete scalar ledger — `waters[*]` + footer (every active AND commented value)

Each row = one FILE line. "Value" is the exact file text after `=`.

### §2.1 Identity / depth / alpha

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:4` | `Name` | `default` | `[D]` byte-proven; `[U]` liveness (which descriptor the engine binds is U1/U4*, uncaptured) | `variant3d/scripts/water3d.gd:961-1004` does NOT transcribe `Name=default` as a value (only line-cite register + proven-scalar telemetry); `variant3d/config_donor_capture.json` — not present; `variant3d/scripts/terrain_donor_mesh.gd` — not present |
| `water.lib:5` | `MaxDepth` | `1` | `[D]` byte-proven; `[U]` liveness (no binding recovered; U4* open) | `variant3d/scripts/water3d.gd:962` (`"MaxDepth": 1` inside `donor_water_lib_proven` telemetry) and `:985` (`"MaxDepth": "water.lib:5"` line-cite); `variant3d/config_donor_capture.json` — not present; `variant3d/scripts/terrain_donor_mesh.gd` — not present |
| `water.lib:6` | `MinDepth` | `0` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:962` + `:985`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:7` | `MaxAlpha` | `1.1` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:962` + `:986`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:8` | `MinAlpha` | `0` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:962` + `:986`; config — not present; `terrain_donor_mesh.gd` — not present |

### §2.2 DeepColor RGBA (`water.lib:9-14`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:9` | `DeepColor : struct.begin` | (struct open) | `[D]` envelope | not present as a token; contents at `variant3d/scripts/water3d.gd:88,181,829,963,987` |
| `water.lib:10` | `DeepColor.Red` | `0` | `[D]` byte-proven; `[U]` liveness (FILE `0,0,0.1255,0.5` vs ENGINE ctor converge is `[D]` path-insensitive per `water3d.gd:85-89,235-236,828-830`, but LIVE draw-path selection itself is still `[U]` U1/U4* — no capture) | `variant3d/scripts/water3d.gd:88` (`LIB_DEEP_COLOR := [0.0, 0.0, 0.1255, 0.5]`); `:181` (BUILTIN mode deep_color); `:829` (bind `deepColor`); `:963` (proven telemetry); `:987` (line-cite `water.lib:9-13 [D] (== ctor)`); `variant3d/config_donor_capture.json` — not present; `variant3d/scripts/terrain_donor_mesh.gd` — not present |
| `water.lib:11` | `DeepColor.Green` | `0` | `[D]`; `[U]` liveness (same note as :10) | Same as :10 — `variant3d/scripts/water3d.gd:88,181,829,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:12` | `DeepColor.Blue` | `0.1255` | `[D]`; `[U]` liveness (same note as :10) | Same as :10 — `variant3d/scripts/water3d.gd:88,181,829,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:13` | `DeepColor.Alpha` | `0.5` | `[D]`; `[U]` liveness (same note as :10) | Same as :10 — `variant3d/scripts/water3d.gd:88,181,829,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:14` | `struct.end` (DeepColor) | (struct close) | `[D]` envelope | not present |

### §2.3 ShallowColor RGBA (`water.lib:15-20`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:15` | `ShallowColor : struct.begin` | (struct open) | `[D]` envelope | not present as a token; contents at `variant3d/scripts/water3d.gd:89,181,830,963,987` |
| `water.lib:16` | `ShallowColor.Red` | `0` | `[D]` byte-proven; `[U]` liveness (same converge/live note as DeepColor; `water3d.gd:85-89,235-236,828-830`) | `variant3d/scripts/water3d.gd:89` (`LIB_SHALLOW_COLOR := [0.0, 0.0, 0.0, 0.5]`); `:181`; `:830` (bind `shallowColor`); `:963`; `:987` (`water.lib:15-19 [D] (== ctor)`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:17` | `ShallowColor.Green` | `0` | `[D]`; `[U]` liveness | Same as :16 — `variant3d/scripts/water3d.gd:89,181,830,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:18` | `ShallowColor.Blue` | `0` | `[D]`; `[U]` liveness | Same as :16 — `variant3d/scripts/water3d.gd:89,181,830,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:19` | `ShallowColor.Alpha` | `0.5` | `[D]`; `[U]` liveness | Same as :16 — `variant3d/scripts/water3d.gd:89,181,830,963,987`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:20` | `struct.end` (ShallowColor) | (struct close) | `[D]` envelope | not present |

### §2.4 Scalar block S1–S9 (`water.lib:21-29`) — all `[U]` liveness (U4* FILE vs ENGINE)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:21` | `ReflectionAmount` | `1` | `[D]` byte-proven; `[U]` liveness (FILE `1` vs ENGINE `0.4`; U4* uncaptured; `water3d.gd:129,237-242,261,279-280,832,964,988`) | `variant3d/scripts/water3d.gd:261` (FILE tuple); `:279` (ENGINE `0.4` candidate); `:129` (uniform-key row n=7); `:832` (bind `reflectionAmount` from selected tuple only); `:964` + `:988` (telemetry + line-cite `water.lib:21 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:22` | `WaterAmount` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `0.3`) | `variant3d/scripts/water3d.gd:262,280,130,833,964,988`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:23` | `FresnelPower` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `4`) | `variant3d/scripts/water3d.gd:263,281,131,834,965,989`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:24` | `FresnelBias` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `0.1`) | `variant3d/scripts/water3d.gd:264,282,132,835,965,989`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:25` | `HDRMultiplier` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `0.5`; DEV path binds port const, BUILTIN binds selected tuple) | `variant3d/scripts/water3d.gd:73` (`HDR_MULTIPLIER := 1.0  # water.lib:25`); `:265` (FILE); `:283` (ENGINE `0.5`); `:133` (uniform-key row n=11); `:781` (DEV bind `hdr_multiplier`); `:827` + `:859` (BUILTIN/LEGACY binds); `:958` + `:990` (telemetry + line-cite `water.lib:25 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:26` | `WaveFreq` | `0` | `[D]`; `[U]` liveness (FILE `0` vs ENGINE `1`) | `variant3d/scripts/water3d.gd:266,284,134,838,966,990`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:27` | `WaveAmp` | `0` | `[D]`; `[U]` liveness (FILE `0` vs ENGINE `0.05`) | `variant3d/scripts/water3d.gd:267,285,135,839,966,991`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:28` | `DistFactor` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `2`) | `variant3d/scripts/water3d.gd:268,286,136,836,966,991`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:29` | `BumpFactor` | `1` | `[D]`; `[U]` liveness (FILE `1` vs ENGINE `0.01`) | `variant3d/scripts/water3d.gd:269,287,137,837,966,992`; config — not present; `terrain_donor_mesh.gd` — not present |

### §2.5 TexScaleS/T — commented pair AND active pair (all four lines ledgered)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:30` | `//TexScaleS` (commented, INACTIVE) | `0.115` | `[D]` byte-proven (comment text is byte-proven INACTIVE; NOT a live value); `[U]` liveness (never a candidate; U4* is FILE-active vs ENGINE only) | not present in any of the three port files (no `0.115` transcribed in `water3d.gd`, `config_donor_capture.json`, or `terrain_donor_mesh.gd`) |
| `water.lib:31` | `//TexScaleT` (commented, INACTIVE) | `0.015` | `[D]` byte-proven INACTIVE; `[U]` liveness (never a candidate) | not present in any of the three port files (no `0.015` transcribed) |
| `water.lib:32` | `TexScaleS` (active) | `0.1` | `[D]` byte-proven; `[U]` liveness (FILE S10 `0.1` vs ENGINE S10 `0.4` vs embedded-VP source-default `0.01` which is NOT a live uniform; `water3d.gd:71,101-108,138,241-243,270,288,779,849-851,958,968,992`) | `variant3d/scripts/water3d.gd:71` (`TEX_SCALE_S := 0.1  # water.lib:32`); `:270` (FILE); `:288` (ENGINE `0.4`); `:107` (`BUILTIN_TEX_SCALE_S := 0.01` embedded-source-default, explicitly NOT live); `:779` (DEV bind `tex_scale_s`); `:850` (BUILTIN bind keeps `0.01` until U4*); `:958` + `:968` + `:992` (telemetry + line-cite `water.lib:32 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:33` | `TexScaleT` (active) | `0.01` | `[D]` byte-proven; `[U]` liveness (FILE S11 `0.01` vs ENGINE S11 `0.825` vs embedded-VP source-default `0.02` NOT live; `water3d.gd:72,241-243,271,289,780,851`) | `variant3d/scripts/water3d.gd:72` (`TEX_SCALE_T := 0.01  # water.lib:33`); `:271` (FILE); `:289` (ENGINE `0.825`); `:108` (`BUILTIN_TEX_SCALE_T := 0.02` NOT live); `:780` (DEV bind); `:851` (BUILTIN bind keeps `0.02` until U4*); `:959` + `:968` + `:993` (telemetry + line-cite `water.lib:33 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |

### §2.6 Wave dirs (`water.lib:34-41`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:34` | `WaveDir0 : struct.begin` | (struct open) | `[D]` envelope | not present as a token; contents at `water3d.gd:140,184,272,847,967,993` |
| `water.lib:35` | `WaveDir0.X` | `-1` | `[D]` byte-proven; `[U]` liveness (FILE W0 `(-1,0)` documented candidate; ENGINE W0 slot unenumerated → ENGINE select hard-fails; `water3d.gd:237-240,272,290-291,840-848`) | `variant3d/scripts/water3d.gd:272` (`"waveDir0": [-1.0, 0.0]` FILE); `:290` (`"waveDir0": null` ENGINE — no invented value); `:140` (uniform-key row n=18); `:184` (BUILTIN mode `waveDir0: [-1.0, 0.0]`); `:847` (bind from selected tuple); `:967` + `:993` (telemetry + line-cite `water.lib:34-36 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:36` | `WaveDir0.Y` | `0` | `[D]`; `[U]` liveness (same W0 note) | Same as :35 — `variant3d/scripts/water3d.gd:140,184,272,290,847,967,993`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:37` | `struct.end` (WaveDir0) | (struct close) | `[D]` envelope | not present |
| `water.lib:38` | `WaveDir1 : struct.begin` | (struct open) | `[D]` envelope | not present as a token; contents at `water3d.gd:141,184,273,848,967,994` |
| `water.lib:39` | `WaveDir1.X` | `-0.7` | `[D]` byte-proven; `[U]` liveness (FILE W1 `(-0.7,0.7)` candidate; ENGINE W1 unenumerated → hard-fail) | `variant3d/scripts/water3d.gd:273` (FILE); `:291` (ENGINE `null`); `:141` (uniform-key row n=19); `:184`; `:848` (bind); `:967` + `:994` (telemetry + line-cite `water.lib:38-40 [U4*]`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:40` | `WaveDir1.Y` | `0.7` | `[D]`; `[U]` liveness (same W1 note) | Same as :39 — `variant3d/scripts/water3d.gd:141,184,273,291,848,967,994`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:41` | `struct.end` (WaveDir1) | (struct close) | `[D]` envelope | not present |

### §2.7 Speed + material names (`water.lib:42-46`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:42` | `Speed` | `1.0` | `[D]` byte-proven AND `[D]` path-insensitive converge (FILE `1.0` == ENGINE ctor `1.0f`; `water3d.gd:235-236,251,377-387,885,933,994,1002`); the WRITER (C+0xc8 EIP) and live `time` accumulation remain `[U]` U5 | `variant3d/scripts/water3d.gd:234` (`fstp @0x854091 (Speed=1.0, water.lib:42)`); `:250`-`:251` (converge note); `:378` (time formula `Speed=1.0`); `:885` + `:933` (stats `time_writer_formula`); `:967` (`"Speed": 1.0` proven telemetry); `:994` + `:1002` (line-cites); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:43` | `NormalMapLibMaterialName` | `DiffuseWaves2` | `[D]` byte-proven filename; `[U]` liveness (which map the engine binds at runtime is uncaptured; port binds `diffusewaves0.png` as `wave_noise`/`waveMap`, NOT this name) | `variant3d/scripts/water3d.gd:995` (line-cite `"NormalMapLibMaterialName": "water.lib:43 (DiffuseWaves2)"` — cite ONLY, no bind of `DiffuseWaves2`); the string `DiffuseWaves2` is otherwise not present as a bound texture in the three port files; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:44` | `DiffuseMapLibMaterialName` | `DiffuseWaves0` | `[D]` byte-proven filename; `[U]` liveness | `variant3d/scripts/water3d.gd:115` (`WAVE_TEX_PATH := "res://assets/terrain/water_png/diffusewaves0.png"  # water.mat:7,11 (donor-derived, shipped)` — port binds the derived PNG, NOT the lib material name itself); `:996` (line-cite `"DiffuseMapLibMaterialName": "water.lib:44 (DiffuseWaves0)"`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:45` | `//NormalMapLibMaterialName` (commented, INACTIVE) | `HeightMapWaves0` | `[D]` byte-proven INACTIVE comment; `[U]` liveness (never a candidate; `HeightMapWaves0` is `water.mat:86-106` commented alpha-255 art, never a substitute — `water3d.gd:342,980`) | `variant3d/scripts/water3d.gd:342` + `:980` (cite `HeightMapWaves0` as commented/absent — cite ONLY, no bind); otherwise not present; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:46` | `//DiffuseMapLibMaterialName` (commented, INACTIVE) | `DiffuseWaves0` | `[D]` byte-proven INACTIVE comment | not present as a commented pair in any of the three port files (the ACTIVE `DiffuseWaves0` of :44 is cited at `water3d.gd:115,996`; the `//`-commented duplicate itself is not transcribed) |

### §2.8 Geometry/offset/count (`water.lib:47-50`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:47` | `Width` | `1` | `[D]` byte-proven; `[U]` liveness (NOT plane Y — plane Y is `cOffsetY=-0.5` `generatemap.inc:654`; `water3d.gd:974,997`) | `variant3d/scripts/water3d.gd:974` (`"Width": 1` telemetry + NOT-plane-Y note); `:997` (line-cite `water.lib:47`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:48` | `Height` | `1` | `[D]` byte-proven; `[U]` liveness (same NOT-plane-Y note) | `variant3d/scripts/water3d.gd:974` + `:997`; config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:49` | `Offset` | `0.495` | `[D]` byte-proven; `[U]` liveness (NOT plane Y; `water3d.gd:974,997`) | `variant3d/scripts/water3d.gd:969` (`"Offset": 0.495` telemetry); `:997` (line-cite `water.lib:49 (NOT plane Y)`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:50` | `LayerCount` | `1` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:969` (`"LayerCount": 1` telemetry); `:998` (line-cite `water.lib:50`); config — not present; `terrain_donor_mesh.gd` — not present |

### §2.9 Custom block (`water.lib:51-59`) — `[U]` reflection identity where marked

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:51` | `CustomEnable` | `False` | `[D]` byte-proven; `[D]` inference base (both construction paths leave C+0x184=0 → CUSTOM unreachable; `water3d.gd:28-30,159-168,235-236,251,888-897`); LIVE path selection itself stays `[U]` U1 (global `[0x8fc6b8]`/map-mod override uncaptured) | `variant3d/scripts/water3d.gd:28` (comment `CustomEnable=False leaves C+0x184=0`); `:159` (`shipped water.lib CustomEnable=False`); `:201` + `:203`; `:236` + `:251`; `:312`; `:890`; `:927`; `:975` (`"CustomEnable": false` telemetry); `:998` (line-cite `water.lib:51 [D] CUSTOM unreachable`); `variant3d/shaders/water3d.gdshader:24,99` mention `CustomEnable=False` but that shader file is OUTSIDE the requested three-file cross-check (noted here only to avoid miscounting); `variant3d/config_donor_capture.json` — not present; `variant3d/scripts/terrain_donor_mesh.gd` — not present |
| `water.lib:52` | `CustomShaderID` | `0` | `[D]` byte-proven; `[U]` liveness + `[U]` reflection identity (custom path unreachable per :51, no live ID captured) | not present in any of the three port files |
| `water.lib:53` | `CustomReflection` | `False` | `[D]` byte-proven; `[U]` reflection identity (custom reflection off in FILE; live reflectionMap provenance itself is `[U]` U12 regardless) | not present as a `CustomReflection` key in any of the three port files (port records only the derived inference `reflection_enabled=0.0` / `reflectionMapBound` hard-fail at `water3d.gd:795,822,885-897,909-913,921-925` — that is NOT a transcription of this FILE key) |
| `water.lib:54` | `CustomReflectionUnit` | `0` | `[D]` byte-proven; `[U]` reflection identity | not present in any of the three port files |
| `water.lib:55` | `CustomLibMaterialName` | `` (empty) | `[D]` byte-proven (empty); `[U]` reflection identity | not present in any of the three port files (no empty-name key transcribed) |
| `water.lib:56` | `CustomTexCoord` | `True` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:969` (`"CustomTexCoord": true` telemetry only); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:57` | `CustomTexCoordScale` | `1` | `[D]` byte-proven; `[U]` liveness | not present in any of the three port files |
| `water.lib:58` | `CustomTexReflectMatrix` | `False` | `[D]` byte-proven; `[U]` reflection identity | not present in any of the three port files |
| `water.lib:59` | `CustomTexReflectMatrixUnit` | `0` | `[D]` byte-proven; `[U]` reflection identity | not present in any of the three port files |

### §2.10 Height/shadow enables (`water.lib:60-61`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:60` | `HeightMapEnable` | `True` | `[D]` byte-proven; `[D]` as the ONE live hmap FILE fact (enable gate; `water3d.gd:340` `water_lib_live_keys: ["HeightMapEnable=True"]`); the engine hmap OBJECT identity/values stay `[U]` U3 (chain settled, numbers uncaptured; `water3d.gd:144-148,303-314,322-349,928`) | `variant3d/scripts/water3d.gd:340` (live-keys telemetry); `:970` (`"HeightMapEnable": true`); `:999` (line-cite `water.lib:60 [D] file True`); config — not present; `terrain_donor_mesh.gd` — not present (its `:1700-1703` comment mentions `hmapTex` only as a parameter key, NOT this enable flag) |
| `water.lib:61` | `ShadowMapEnable` | `True` | `[D]` byte-proven; `[U]` liveness (no shadow sampler bound in port; `water3d.gd:148-152,926` records `shadowed/shadowMap/shadowSize/shadowColor` as UNRESOLVED) | `variant3d/scripts/water3d.gd:970` (`"ShadowMapEnable": true` telemetry); `:999` (line-cite `water.lib:61`); config — not present; `terrain_donor_mesh.gd` — not present |

### §2.11 Footer (`water.lib:64-70`)

| Donor path:line | Key | Value | Class | Port transcription |
|---|---|---|---|---|
| `water.lib:64` | `MaterialLibraryFileName` | `.\data\water\water.mat` | `[D]` byte-proven | `variant3d/scripts/water3d.gd:1000` (line-cite `"MaterialLibraryFileName": "water.lib:64"` — cite ONLY; the `.\data\water\water.mat` string itself is not transcribed); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:65` | `DefaultWaterIndex` | `0` | `[D]` byte-proven; `[U]` liveness (single `[*]` entry, no index selection captured) | `variant3d/scripts/water3d.gd:972` (`"DefaultWaterIndex": 0` telemetry); `:1000` (line-cite); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:66` | `Tag` | `512` | `[D]` byte-proven; `[U]` liveness | `variant3d/scripts/water3d.gd:972` (`"Tag": 512`); `:1001` (line-cite `water.lib:66`); config — not present; `terrain_donor_mesh.gd` — not present |
| `water.lib:67` | `VertexProgramFileName` | `.\data\shaders\water\water.dev.vert` | `[D]` byte-proven; `[U]` liveness (DEV pinned by this pair, but LIVE path is `[U]` U1) | `variant3d/scripts/water3d.gd:971` (`"VertexProgram": "water.dev.vert"` telemetry basename); `:1001` (line-cite `water.lib:67`); the full `.\data\shaders\water\water.dev.vert` string is not transcribed; config — not present; `terrain_donor_mesh.gd:92` cites `water.dev.vert:18` for the `WATER_SURFACE_Y` placeholder note only, NOT this filename key |
| `water.lib:68` | `FragmentProgramFileName` | `.\data\shaders\water\water.dev.frag` | `[D]` byte-proven; `[U]` liveness (same U1 note) | `variant3d/scripts/water3d.gd:971` (`"FragmentProgram": "water.dev.frag"`); `:1001` (line-cite `water.lib:68`); full path not transcribed; config — not present; `terrain_donor_mesh.gd` — not present (its `:107-108` cites `water.dev.frag:227` absence only) |
| `water.lib:69` | `VertexProgramLODFileName` | `` (empty) | `[D]` byte-proven (empty) | not present in any of the three port files |
| `water.lib:70` | `FragmentProgramLODFileName` | `` (empty) | `[D]` byte-proven (empty) | not present in any of the three port files |

## §3 Requested port-key cross-check (PORT-ONLY, not donor)

These three keys exist ONLY in the port. None is a `water.lib` value. Listed solely because the task names them.

| Port path:line | Key | Value | Donor backing |
|---|---|---|---|
| `variant3d/config_donor_capture.json:35` | `features.water.surface_y` | `-0.25` | No `water.lib` backing. Port A/B surface value; donor plane Y is `cOffsetY=-0.5` (`generatemap.inc:654`, `water3d.gd:58,63,588,774`). Recorded for audit at `water3d.gd:744,748,1020` (`config_surface_y_ignored`) and `terrain_donor_mesh.gd:92,2088-2089` (`WATER_SURFACE_Y` PORT APPROX placeholder). |
| `variant3d/config_donor_capture.json:36` | `features.water.alpha_confine` | `true` | No donor backing. Port-only gate; consumed as telemetry at `water3d.gd:745,749,1018` and labelled at `terrain_donor_mesh.gd:101-110,2352-2362`. |
| `variant3d/config_donor_capture.json:37` | `features.water.shore_prox` | `false` | No donor backing. REMOVED port art (`water3d.gdshader:533`, absent from donor `water.dev.frag:227`); recorded as `false`/removed at `water3d.gd:746,750,1017,1019` and `terrain_donor_mesh.gd:101-110,2352-2362`. |

## §4 Classification summary (no wiring, no claim)

- `[D]` FILE byte-proven: every value in §2 (active, commented, empty, and envelope tokens) is byte-proven by the read of `water.lib:1-71`. That proves FILE TEXT ONLY.
- `[U]` liveness (FILE vs ENGINE): UNVERIFIED for every scalar that diverges between the `water.lib` layer block (:21-40) and the `FUN_00856080` ctor tuple — i.e. `ReflectionAmount`, `WaterAmount`, `FresnelPower`, `FresnelBias`, `HDRMultiplier`, `WaveFreq`, `WaveAmp`, `DistFactor`, `BumpFactor`, `TexScaleS/T` (active), `WaveDir0/1`, plus `Speed` (convergent value, uncaptured writer U5), `Custom*`, `Width/Height/Offset/LayerCount`, `HeightMapEnable/ShadowMapEnable`, footer indices/paths. U4* capture (`water3d.gd:220-222`) is still required; `water_scalar_source` UNSET blocks any draw (`water3d.gd:364-365,753-761`). The commented `//TexScaleS/T` and `//Normal/Diffuse` lines are INACTIVE and never candidates.
- `[U]` runtime reflection texture identity: UNVERIFIED. No reflection FBO provenance is recovered (`water3d.gd:303-314` `UNVERIFIED_BINDINGS.reflectionMap_FBO`, `:685-694` BUILTIN hard-fail). `CustomReflection=False` (:53), `CustomReflectionUnit=0` (:54), `CustomLibMaterialName=` (:55), `CustomTexReflectMatrix=False` (:58), `CustomTexReflectMatrixUnit=0` (:59) do NOT resolve it.
- Chain 0/6. RESULT IS NOT GOOD. No parity claim of any kind is made by this ledger.
- Ledger-only: no value above is proposed for wiring into the port. The U4* gate stays closed.
