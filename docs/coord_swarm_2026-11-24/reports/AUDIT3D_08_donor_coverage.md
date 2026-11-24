---
id: AUDIT3D-08
owner: AUDIT3D-08
scope: "Which donor data variant3d/ actually consumes at runtime vs app/ 2D, vs available-but-unused or unreadable"
date: 2026-11-24
status: DELIVERED__AUDIT_ONLY
mode: "read-only; donor private-use at C:\\Games\\Cossacks 3 never run or copied; no repo source/asset/config/test edited"
---

# AUDIT3D-08 — Donor data coverage: `app/` vs `variant3d/`

## 0. Scope and method

- Charter: `docs/coord_swarm_2026-11-24/AUDIT3D_CHARTER.md:6-24`. Assignment: `:34`.
- Sources read: donor file names/counts via read-only `Get-ChildItem`; donor **text** via read-only
  line reads (`Get-Content`, `Select-String`); donor **binaries** only as counts/sizes — their layouts
  are cited from existing decode reports, never re-derived by running donor code.
- Port side read-only: `app/tools/*.py`, `variant3d/scripts/*.gd`, `app/scripts/*.gd`,
  `docs/coord_swarm_2026-11-24/reports/**` (recon reports R03/R04/R06/R07/R08/R09/R10/R11,
  G31-G34, V7-1/V7-2 and the V71x atom reports).
- Labels: **OBSERVATION** = literal file line, filesystem fact or byte-count; **INFERENCE** =
  conclusion from those facts. `UNVERIFIED` = not provable from readable data. No value invented.
- Measurement note: file counts/hashes/file-identity below are labelled **[MEASURE]**; they have no
  line numbers because they are filesystem facts, but every path named can be re-checked directly.

## 1. Structural finding: the two variants share the donor-derived asset base

**[OBSERVATION / MEASURE]** `app/assets` has 3,999 non-`.import`/`.uid` files, `variant3d/assets`
4,002; the name-set difference is only three `.gdignore` files and one
`splat_albedo.png.import` (extra in variant3d). The following are the **same NTFS file IDs**
(hardlinks), not copies: `assets/models/manifest.json`, `assets/models/obj/peasant.obj`,
`assets/terrain/blocks/grass1.png`, `assets/ui/icons.bmp`. `app/tools/**` and `variant3d/tools/**`
have the same 230 tool files. Therefore every donor conversion tool listed below (in `app/tools`)
is also present, byte-identical, in `variant3d/tools`.

**[OBSERVATION / MEASURE]** Runtime script hashes: `game.gd`, `world.gd`, `ai.gd`, `audio.gd`,
`camera.gd`, `mechanics.json` are byte-identical across variants. `variant3d/scripts/data.gd`
adds only four lines, including `RENDER_MODE` at `:61`; `variant3d/config.json` differs only in
`gameplay.render_mode=3d` (app `2d`). The 3D-only code is `main.gd:945-958` (dynamic loads),
`world3d.gd:69-74`, `world3d_entities.gd:52-55`, `world3d_terrain.gd:40-41`,
`world3d_fx.gd:42-74`, `anim3d.gd:49-68`, `camera3d.gd:44-51,100-149`.

**INFERENCE:** donor ingestion is not the differentiator. Both variants own the **same
donor-derived PNG/OBJ/JSON/ogg assets and the same simulation constants**; the difference is which
of those assets the 3D modules actually load. That is what the table measures.

## 2. Evidence table — donor source → app → variant3d → verdict

Legend: **USED** = runtime code reads the derived asset; **BUILD** = read only by an offline tool
at asset-generation time; **UNUSED** = readable but no code path consumes it; **UNREADABLE** = no
existing tool decodes the payload; **UNVERIFIED** = semantics unproven even though bytes parse.

| # | Donor source (format / measured count) | Used by `app/` 2D? | Used by `variant3d/` runtime? | Verdict — readable / unreadable |
|---|---|---|---|---|
| 1 | `data/actors/**/*.osm` **3,897** + `data/materials/**/*.dds` **844**; IDP2 binary | BUILD → 116 sids: `app/tools/convert_models.py:43-94,109-125,327-363`; V7-2 §2.1 | **YES** — `world3d_entities.gd:52-55,101-118,170-188` loads `manifest.json`, `obj/<sid>.obj`, `tex/<sid>.png` | **USED BOTH / READABLE** (`docs/decomp/DC_FORMATS.md:66-94`, ev `ev_0bbb20c1…`). Only 116 of 3,897 sids converted (V7-2:396). |
| 2 | `data/actors/**/*.oss` **335** + `data/animations/aaf/*.aaf` **246**; skinned binary + ASCII action ranges | BUILD → 54 land + 7 naval baked sheets: `bake_sprites.py:91-116,131-143`; consumed `world.gd:399-413,503-529` | **PARTIAL** — `anim3d.gd:49-68,98-143` computes donor frame numbers only; `world3d_entities.gd:41-50,75` renders a **static bind pose** | **PARTIAL / DEFORMATION UNVERIFIED**: `.oss` verts, weights, `k×7f` tracks readable (V7-2:156-166); **bone parent hierarchy absent** (V7-2:180-186, :382). |
| 3 | `.ani` (asked about in scope) | — | — | **NO SUCH DONOR SOURCE [MEASURE]**: recursive donor census has **0 `.ani`** files; actual animation formats are `.oss` **335**, `.aaf` **246**, `.acl` **30** (V7-2:144-150). Treat any `.ani` claim as `UNVERIFIED`. |
| 4 | `data/animations/acl/*.acl` **30**, `data/animations/ref/*` (`refunit.acl`, `tpl.library`) | no | no | **UNUSED / UNVERIFIED**: text parses (`docs/decomp/DC_FORMATS.md:14`; `V72:383`), playback mapping undocumented. Keyword scan of `data/animations/**` + `data/actors/**` found only `ShaderIDNoBones` references (e.g. `data/actors/ref/refunit.actor:3`), **no bone-parent table**. |
| 5 | `data/sounds/**/*.ogg` **325**, plus `ambient.snd`, `manager.cfg` | BUILD → `copy_assets.py:236-251`; runtime `audio.gd:13,24-28,78-113,298` | **YES** — `variant3d/scripts/audio.gd` byte-identical to app **[MEASURE]**; `audio.gd:13` `DIR := "res://assets/sounds"` | **USED BOTH / READABLE**. `sounds.slc` and `.snd` playlists are transcribed, not read at runtime. |
| 6 | `data/hud/textures/ui/{icons,iconsunits}.bmp`, `data/cursors/textures/bmp/*.bmp` | `copy_assets.py:226-234`; `hud.gd:171-174`, `input_controller.gd:73` | **YES** — same hardlinked BMPs **[MEASURE]**, same scripts | **USED BOTH / READABLE**. 3D HUD stays CanvasItem (`hud3d_adapter.gd:1-4`). |
| 7 | `data/game/var/formations.cfg` (149 structs) | `data.gd:380-530` `FORMATION_BONUSES`; R03:29-31 measured 149/149 with 0 value diffs | **YES** — shared `data.gd` / `game.gd`; 3D sim identical | **USED BOTH / READABLE**. |
| 8 | `data/game/var/generator.cfg` + `data/pattern/*.pattern` **710** + `data/gen/terrainmasks/*.tga` | `donor_gen.py:10-12`; `mapgen.gd:1-14,36,137`; `pattern_gen.gd:42` | **YES** — same scripts/assets; `mapgen.gd:137` loads `res://assets/terrain/masks/…` | **USED BOTH / READABLE** (masks converted from TGA; pattern mask bytes parsed, object records synthesised per `donor_gen.py:22-23`). |
| 9 | `data/game/var/envscales.cfg` (mine 0.3152, stone 0.329, spruce1 0.5) | `convert_models.py:228` (env texture base) | **YES (3D-only direct use)** — `world3d_entities.gd:29-34,68` | **USED BOTH / READABLE** (`V72:58`, donor `:25-28,:43-46,:371-374`). |
| 10 | `data/game/var/{campaigns,battles,startingsettings}.cfg` | `build_missions.py:6-9,138-141` → `assets/missions.json`; `menu.gd:171` | **YES (scenario selection)** — same mission JSON/menu | **USED BOTH / READABLE**; random-map relief still procedural (row 16). |
| 11 | `data/cameras/camera.cfg` (height 20–58, tilt −32°, focal 400) | `data.gd:165-167`, `camera.gd` | **YES** — `camera3d.gd:12-17,44-51,100-149` | **USED BOTH / READABLE**; absolute FOV/sensor **UNVERIFIED** (`G31:227,262-263`; `camera3d.gd:48-51` labels 17.27° an assumption). |
| 12 | `data/env/lights/light.cfg` (ambient/diffuse/specular RGB, `Position=-0.3447,0.9387,0`) | **NO** in 2D skirmish (R10:30 flat ellipse shadow only) | **NO** in 3D skirmish: no `WorldEnvironment`/`DirectionalLight3D` in `world3d.gd:1-130` or `main.gd` **[MEASURE]**; `world3d_terrain.gd:20` explicitly excludes them; only the sandbox records `terrain3d_sandbox.gd:191` | **UNUSED / READABLE** (`V72:61`, `R10:30`). Visual consequence of no scene light **UNVERIFIED** (AUDIT3D-09). |
| 13 | `data/env/colors/colors.lib` **8 static tables** (`SkyDome*`, `Fog`, `Ambient`, `LSAmbient`, `FogStart/End`) | **NO** beyond three tints: `data.gd:219-225`; R10:22, :29 | **NO** — same tint only; port FX palette `world3d_fx.gd:62-74` | **UNUSED / READABLE** (donor `colors.lib:17-40` read this pass). |
| 14 | `data/env/clouds/clouds.{cfg,weather,presets}`, `data/env/pfx/particles.snow.cfg` | **NO** (R10:24-26) | **NO** | **UNUSED / READABLE** (`clouds.weather:2-22` read this pass: `Weather=40`, `WindVector X=-0.7421 Z=-0.8673`). Day/night is donor-**disabled** (`R10:28`), so do not ticket it as parity. |
| 15 | `data/pfx/source.pfx` (1 file) + `data/pfx/*.dds` **18** | no PFX art; `groundexp*.dds` copied as decals `copy_assets.py:100-103` | **PARTIAL** — `world3d_fx.gd:42-60` quotes 3 literal keys (`TimeLimit`, `Alpha`, `MarkWidth`); FX materials are synthetic (`:323-329`); no donor PFX texture load | **SEMANTICS UNVERIFIED** (`V72:384`, `V715:9-14`); text and DDS readable. |
| 16 | `data/maps/*.map` **38** (30–125 MB each), `.aix` **30** | BUILD → only header + ASCII placements: `extract_map.py:4-17,42-47,56-110`; 4 JSON in `assets/maps` | **YES for scenario JSON** (`menu.gd:171`); **NO for relief** — terrain comes from the procedural dump `world3d_terrain.gd:32-34` | **RELIEF UNREADABLE** (`extract_map.py:5-6,108-110`: closed binary; only block offsets). |
| 17 | `data/terrain/tiles/textures/*.dds`, `data/terrain/decals/**/*.dds` | `copy_assets.py:97-103,178-206`; `world.gd:1019,2533-2534` | **YES (indirect)** — `heightmap_splat.py:5-6,26-37` builds `splat_albedo.png` from port block PNGs; `world3d_terrain.gd:40,73-88` loads it | **USED BOTH / READABLE**. `heightmap_splat.py:360` states "No donor file read" — donor albedo is inherited through `copy_assets.py`. |
| 18 | `data/actors/env/terrainmesh{1..4}.osm` (2,177–2,662 verts; DDS albedo) | **NO** — not among 116 sids (`V72:396`) | **NO** | **UNUSED / READABLE** (G31:98-104 decodes IDP2 headers; `terrainmesh1.actor:1-5`). |
| 19 | `data/shaders/*.vert/.frag` **109** | approximate water shader only (`world.gd:952`) | **NO** — `StandardMaterial3D` (`world3d_terrain.gd:73-88`) | **UNUSED / READABLE TEXT**, not Godot-compatible verbatim (G31:34, :95-96). |
| 20 | `data/scripts/lib/{unit,country,res,player}.script`, `dmscript.global` (unit stats, economy, combat, AI) | transcribed into `data.gd:32-107`, `MECHANICS.md:220-363`; cited per row by R04/R06/R07/R08 | **YES** — `data.gd`/`game.gd` identical except the render-mode lines | **USED BOTH / READABLE**; note some values are explicitly estimated (`data.gd:46`, `data.gd:84-103` port additions). |
| 21 | `data/scripts/lib/classes.script:7986-8011` `GetKeyColorByPlayerIndex` (14 RGB + koef), used at `misc.script:5073` | **NO** — port palette `hud.gd:144-151` | **NO** — port palette `world3d_fx.gd:67-74`; 3D entity materials carry **no team tint** (`world3d_entities.gd:170-188`) | **UNUSED / READABLE**. Donor literals read this pass: player0 `164,0,0 @1.15`, player1 `15,85,192 @1.2`, … |
| 22 | `data/locale/en/*.txt` / `.lng` **2,187** | names/effects transcribed into `data.gd:174-175,1054-1055,1326-1341` and `mechanics.json`; cited by R08/R11 | **YES via shared data.gd/config** (`config.gd:550-551,581-584`) | **INDIRECT / NO RUNTIME DONOR READ**: text parseable; names come from config dictionaries, not a live `.txt` load. |

### Coverage verdict by family

- **Fully consumed in 3D:** static meshes + albedo (1), sounds (5), HUD/cursor bitmaps (6),
  formations (7), generator/pattern/masks (8), env scales (9), mission scenario JSON (10),
  camera bounds/tilt (11), terrain tile albedo via splat (17), transcribed sim stats (20).
- **Consumed only at clock/metadata level in 3D:** `.oss`/`.aaf` animation (2), PFX (15),
  map placements (16), locale (22).
- **Available and readable but unused by both skirmish paths:** lights (12), colour tables (13),
  clouds/weather (14), relief LOD meshes (18), shaders (19), team palette (21).
- **Unreadable / unverifiable with current tooling:** `.map` relief (16), bone parents (2, 4),
  ACL semantics (4), PFX semantics (15), donor absolute FOV (11).

## 3. Ranked gaps

### P0-1 — 3D units have no donor deformation (biggest fidelity loss)
**OBSERVATION:** `world3d_entities.gd:41-50,75` renders a static bind pose; `anim3d.gd:13-23`
declares "NOT donor-faithful skeletal animation" and `:98-143` only publishes a frame number.
The 2D path does animate from the same donor source (`world.gd:399-413,503-529`).
**INFERENCE:** a 3D skirmish frame shows units frozen regardless of sim action. Donor data is
**readable** (`.oss` tracks, `V72:156-166`; AAF ranges, `V72:167-170`) and the blocker is solely
the missing bone-parent table (`V72:180-186`), not the bytes.
**Smallest donor-grounded fix:** reuse the already-working CPU skinner `bake_sprites.py:118-143`
with `bake_sprites.sample` (`:145`) to sample one pose per AAF action range (`anim3d.gd:49-68`)
into morph targets in a lit 3D scene — V7-2 §4.4 / Table C (`:305-333,400-410`). Must be labelled
**PORT APPROXIMATION — NOT DONOR PARITY** (`anim3d.gd:41`); do **not** invent a bone tree.

### P0-2 — No scene lighting in the 3D skirmish path
**OBSERVATION:** no `WorldEnvironment`/`DirectionalLight3D` in `world3d.gd` or `main.gd`
**[MEASURE]**; `world3d_terrain.gd:20` deliberately excludes them; the only donor light constant
in code is a sandbox stat (`terrain3d_sandbox.gd:191`). Donor `light.cfg` ambient/diffuse/specular
and position are plain text (`V72:61`, `R10:30`).
**INFERENCE:** donor-lit relief cannot appear, and the emission floor at
`world3d_terrain.gd:43-45` is compensating for that. The actual rendered appearance is
**UNVERIFIED** pending AUDIT3D-09.
**Smallest donor-grounded fix:** in `world3d.gd.bind`, instantiate one `DirectionalLight3D` plus
`WorldEnvironment`/`AmbientLight` with the literal `light.cfg:3-16` RGB values and
`Position=(-0.3447,0.9387,0)` already quoted at `terrain3d_sandbox.gd:191`; no new art, no new
binary conversion.

### P1-1 — Team/player colours are port-authored, and 3D bodies carry no team tint
**OBSERVATION:** donor `classes.script:7986-8011` gives exact per-player RGB + koef; port uses
different literals (`hud.gd:144-151`, `world3d_fx.gd:67-74`, cited as *port* at
`world3d_fx.gd:62-64`). `world3d_entities.gd:170-188` sets only albedo texture, roughness,
metallic and cull mode — no `albedo_color`/team modifier.
**Smallest donor-grounded fix:** parse the 14 `case plInd` tuples into `Data.DONOR_PLAYER_COLORS`
(`r=ir*koef/255`, donor `:8008-8011`), use them for 3D flag/rally/selection tints and minimap,
replacing the port palette. Overlaps AUDIT3D-02; cite donor line per value.

### P1-2 — Donor relief is unreadable, and the readable relief props are unconverted
**OBSERVATION:** `.map` terrain blocks are opaque (`extract_map.py:5-6,108-110`); 3D relief uses
the procedural dump (`world3d_terrain.gd:32-34`); `terrainmesh1..4.osm` are decodeable
(G31:98-104) but absent from the 116 sids (`V72:396`).
**Smallest donor-grounded fix:** run the existing `convert_models.read_osm`/`write_obj`
(`convert_models.py:69-94,109-125`) over the four `terrainmesh*.osm` + their DDS albedo and place
them as static meshes; this uses donor geometry without attempting a `.map` decode.

### P1-3 — Parsed donor atmosphere tables unused in 3D
**OBSERVATION:** `colors.lib:17-40` contains 8 static sky/fog/ambient/light tables; `data.gd:219-225`
keeps only three season tints; `world3d_fx.gd`/`world3d.gd` build procedural fog/effects.
**Smallest donor-grounded fix:** parse the `statictables` blocks into `Data.COLOR_TABLES` and drive
`WorldEnvironment` fog/ambient from the selected table (season index is already switched by donor
`dogenerate.inc:2076-2082`, cited R10:20). Do not enable day/night — donor disables it (R10:28).

### P2-1 — PFX art and semantics only partially bridged
**OBSERVATION:** only three literal `.pfx` keys reach code (`world3d_fx.gd:42-60`); all FX geometry
and colour are port-authored (`:25-38,62-74`); 18 donor `.dds` PFX textures exist.
**Smallest donor-grounded fix:** convert the readable PFX DDS sheets to PNG via the existing
`convert_models.convert_texture` (`:135-153`) and use them as additive billboards in
`world3d_fx.gd`, with interval/alpha driven only by cited keys; mark "SEMANTICS UNVERIFIED".

### P2-2 — Weather/cloud/snow data unused
**OBSERVATION:** `clouds.weather:2-22` and `R10:24-26` are readable, no runtime consumer exists;
donor snow is weather ≥70, not winter-only (`R10:26`).
**Smallest donor-grounded fix:** add a weather scalar + wind vector from `clouds.weather` to
`Data`, gate existing fog/overlay alpha; keep as a labelled approximation until AUDIT3D-09 can
compare frames.

### P2-3 — Naval and construction-stage meshes unconverted for 3D
**OBSERVATION:** 7 core ship families / 54 readable meshes (`R09:15-19`) and `_s1..s4`/`_dead`
families (`V72:398`) are not in the 116 sids; 3D entities can only render what is in the manifest
(`world3d_entities.gd:101-118`).
**Smallest donor-grounded fix:** extend the same `read_osm`/`read_oss` converter run to those
sid families; scope-gate on "singleplayer skirmish" per `V72:354-356`.

## 4. Smallest donor-grounded fix (overall)

**Wire `data/env/lights/light.cfg` into the 3D skirmish scene** (P0-2). It is a single readable
text file, its numbers are already quoted in-repo (`terrain3d_sandbox.gd:191`, `V72:61`), no
binary conversion, no new art and no invented value are needed. It is the only gap where one
small change makes all existing donor-derived 3D meshes (`world3d_entities.gd`) and the donor-block
splat (`world3d_terrain.gd:40`) render under donor-like light. Visual acceptance still requires
the AUDIT3D-09 frame check.

## 5. Open questions

1. Is there any donor-readable bone-parent table (`.oss` sibling, `animations/ref/*`, `.actor`
   refkey chain)? This pass's keyword scan found none; file existence is not proof. Until found,
   P0-1 stays a labelled port approximation (`V72:423-424`).
2. Can the `.map` terrain block be decoded with an existing tool? `extract_map.py:4-17` says no;
   if a decoder exists outside this repo, P1-2 changes from "convert relief props" to "read real
   heights".
3. Donor yaw has no citation; only tilt −32° is confirmed (`camera3d.gd:34-37`, `G31:227`).
   Does the 3D camera need a donor yaw constant before A/B?
4. Are PFX `Interval`/`PixelRatio` values pixels or seconds, and do they bind to skirmish FX?
   Text is readable; semantics remain `UNVERIFIED` (`V72:384`).
5. Does `variant3d` actually boot into a lit 3D frame? No windowed proof exists in this audit;
   AUDIT3D-09 owns that verdict.
6. The task scope mentions `.ani`; the installed donor has **0** such files **[MEASURE]**. Was a
   different donor build meant, or were `.aaf`/`.acl`/`.oss` intended?
7. Should the 12-colour port minimap palette (`hud.gd:141-151`) be replaced wholesale by the
   14-entry donor palette (`classes.script:7986-8011`), or only for players 0–7 with donor's
   documented koef applied? AUDIT3D-02 should decide with a visual A/B.

---

*AUDIT3D-08: read-only audit. No donor binary was run or copied; no repo source, asset, config or
test was edited; exactly one report file written (this one). All donor binary statements are
citations of pre-existing decode reports, not new decompilation.*
