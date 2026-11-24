---
id: AUDIT3D-06
owner: AUDIT3D-06
scope: "FX, animation and audio parity in variant3d/ vs app/ and the private-use donor at C:\\Games\\Cossacks 3"
date: 2026-11-24
status: COMPLETE — AUDIT ONLY; no source edits, no git commands
---

# AUDIT3D-06 — FX, animation and audio parity

## 1. Scope and method

Read-only audit of `variant3d/scripts/world3d_fx.gd`, `anim3d.gd`,
`world3d_entities.gd`, `world3d.gd`, `main.gd`, `audio.gd`, `data.gd`,
`project.godot`, `config.json`; compared with the byte-equivalent 2D files in
`app/scripts/`; donor numbers re-read directly from `C:\Games\Cossacks 3`
(read-only; no donor binary executed, no donor art copied). Every finding below
is an **OBSERVATION** with `path:line`. Judgements are marked **INFERENCE** or
**UNVERIFIED**. No file other than this report was written.

## 2. Independent verification of the "known facts"

| Claim | Independent check | Verdict |
|---|---|---|
| Donor PFX keys are listed but semantics unverified | `C:\Games\Cossacks 3\data\pfx\source.pfx:41-62` (musketsmoke EndFrame 127 / PixelRatio 175 / AlphaTime 1.5), `:105-177` (musketflash 4 frames / Interval 100 / PixelRatio 350), `:385-411` (cannonsmoke PixelRatio 120), `:1322-1415` (cannonexp EndFrame 255 / FrameRate 83.3333 / PixelRatio 30 / AlphaTime 1.2 / AlphaPower 1.0), `:1734-1747` (bullettrail VertLimit 150 / TimeLimit 0.2 / Alpha 0.2 / MarkWidth 0.1). No file in either port maps these keys to a runtime unit. | **CONFIRMED** — keys are real; metre/second/colour mapping **UNVERIFIED**. |
| `.oss` bone parents unreadable, so animation is a labelled approximation | `docs/decomp/DC_FORMATS.md:46-64` defines the complete payload as vertices/faces/UVs/weight pairs/`b×k×<7f>` tracks — no parent field. Recomputed exact closure for `peaukr.oss`: `24 + 577*12 + 921*12 + 733*8 + 921*12 + 6980 + 20*483*28 = 312,376` = on-disk size (header ints `483,30,20,577,921,733` read from byte 0). No trailing block can hold a parent table. | **CONFIRMED for the readable payload**: no bone-parent data. Whether the donor stores a hierarchy in another file is **UNVERIFIED**. The `STATIC BIND POSE` label is honest. |
| Donor frame clock is donor-backed | `C:\Games\Cossacks 3\data\animations\aaf\peaukr.aaf:3-20` matches all 18 rows of `anim3d.gd:49-68` verbatim; `.oss` header fps=30 matches `anim3d.gd:37`. | **CONFIRMED** for `peaukr` only. Other sids: **UNVERIFIED** (194 donor `.aaf` files exist; only one embedded). |
| 2D audio bed is preserved in 3D | `app/scripts/audio.gd` and `variant3d/scripts/audio.gd` have identical SHA-256 `EA57EDA7…F8DA61`; `app/scripts/world.gd` and `variant3d/scripts/world.gd` identical; `app/scripts/game.gd` and `variant3d/scripts/game.gd` identical; event→sound dispatch identical at `app/scripts/main.gd:1541-1591` vs `variant3d/scripts/main.gd:1611-1661`; 325 `.ogg` files in each `assets/sounds/` (spot-hash `musket1.ogg` identical); `variant3d/config.json:119-123` audio enabled, `data.gd:109-111` unchanged. | **CONFIRMED** — the 2D audio bed, clips, volumes and event mapping all run in 3D mode. |
| 3D positional audio present? | No `AudioStreamPlayer3D`, `AudioListener3D`, `AudioServer` or bus-layout file anywhere in `variant3d/` (`scripts/`, `project.godot:1-28`). `audio.gd:318` queries `get_camera_2d()`. | **CONFIRMED ABSENT** — no spatial audio nodes, no buses. |

## 3. Evidence table — FX

`2D` column is `app/scripts/world.gd` (byte-identical copy at
`variant3d/scripts/world.gd`; the 3D world does not call its `_draw_fx`).

| FX kind | What variant3d actually emits (`path:line`) | Data source | 2D counterpart | Verdict |
|---|---|---|---|---|
| Muzzle flash (`shot`) | `world3d_fx.gd:391-397`: one `SphereMesh` radius 0.35 at y=1.2 + `OmniLight3D` energy 3.0/range 6.0; alpha fades over `LIFE.shot=0.35` (`:28`, `:516-524`). Spawned by `main.gd:1617-1627` from `game.gd:4938`. | Hardcoded geometry/energy; colour `world.gd:3653` (port). Donor `musketflash` 4 frames / PixelRatio 350 (`source.pfx:105-177`) **not consumed**. | `world.gd:3653` circle radius 2 px, same 0.35 s. | **PORT PRIMITIVE** — 2D parity of timing only; donor visuals **UNVERIFIED**. |
| Smoke | `world3d_fx.gd:398-402` two crossed `PlaneMesh` 1.4×1.4; rises 1.6 m and scales 1→2.4 over 1.6 s (`:29`, `:501-504`). Donor `musketsmoke` keys quoted only in comments at `:43-45`. | Port lifetime from `world.gd:3567`; colour `world.gd:3657`. No donor frame count, PixelRatio, AlphaTime/Power, size or particle count. | `world.gd:3654-3658` two circles. | **HARDCODED GUESS** — no donor size/lifetime/colour/count used. |
| Explosion | `world3d_fx.gd:403-409` one `SphereMesh` radius 0.8 + light 5.0/12.0; scale 1→3.2 over 0.8 s (`:30`, `:505-507`). Spawned `main.gd:1646-1648`. | Hardcoded; colour `world.gd:3660`. Donor `cannonexp` 256 frames / 83.3333 fps / PixelRatio 30 / AlphaTime 1.2 (`source.pfx:1322-1415`) only quoted at `:50-51`. | `world.gd:3659-3661` arc + circle. | **HARDCODED GUESS** — donor parameters not consumed. |
| Crater / fire / heal / capture / rout / chop | `world3d_fx.gd:410-435`: cylinder, crossed planes+torch light, torus, box, plane, plane. Lifetimes `:30-37`. Only `chop`/`heal`/`rout`/`crater` are actually forwarded (`main.gd:1630-1651`); `fire` and `capture` have **no event producer** (`game.gd:2821-2823` post_event list). | All from `world.gd:3563-3579` / `:3663-3676` port values. No donor PFX section identified for these. | Same kinds in `world.gd:3563-3579,3663-3676`. | **PORT PRIMITIVES**; `capture`/`fire` dead kinds in both ports (P2). |
| Bullet trail | `world3d_fx.gd:270-295` emits `"trail"` only for `game.projectiles` with kind `arrow`/`firearrow`; `BoxMesh 0.1×0.1×1.2` (`:436-439`), oriented along projectile direction (`:533-552`), life 0.2 s. | **Only place donor literals are used**: `TRAIL_TIME_LIMIT=0.2` (`source.pfx:1740`), `TRAIL_ALPHA=0.2` (`:1742`), `TRAIL_WIDTH_M=0.1` (`:1746`) at `:57-59`; `TRAIL_STREAK_M=1.2` is a port value (`:60`). Semantics (pixels vs metres) **UNVERIFIED**. Donor calls the key `bullettrail`, port applies it to arrows only. | `world.gd:3545-3559,3677-3686` arrow streak. | **LITERAL-ONLY donor grounding**; geometry is a 3D box, not donor `msFaceCamera` quad (`source.pfx:1745`). |
| Hit | **No FX at all.** `main.gd:1643-1645` plays only `arrowimpact1` audio for `kind=="bullet"`; `game.gd:5037,5068,5073` emits `hit` events. | Donor `musketsparks` (`source.pfx:183-247`) and `impactsmoke` texture exist but are private-use/uncopied. | `world.gd` has no `"hit"` FX branch. | **GAP P2** — no visual impact in either port. |
| Dust | **No `"dust"` kind** in `world3d_fx.gd` (`LIFE` `:27-38`, `_build_visual` `:383-439`) or `app/scripts/world.gd`. | None. | None. | **ABSENT in both** — no 2D parity gap; donor dust PFX **UNVERIFIED**. |
| Ghost | `world3d_fx.gd:167-186` + `:309-316,570-580`: translucent green/red box footprint, size from `Data.BUILDINGS[".radius"]` (`:626-631`), pulsing alpha. **Never called at runtime**: only definition at `:167`, API listing at `:7`, and tests `tests/t_fx3d.gd:218-219`. | Colours from `world.gd:3509`; no donor ghost config. | `world.gd:3460-3529` (called at `:3630`) draws ghost sprite + footprint from `hud.build_ghost_sid` and `game.can_place`. | **GAP P0** — API exists but no 3D caller; 3D has no build-placement preview. |
| Rally | `world3d_fx.gd:191-203,442-484,555-567`: pole + pennant in `PLAYER_COLORS` (`:67-74`), TTL 2 s port choice (`:84`). **Never called at runtime** — no caller outside `tests/t_fx3d.gd:219`. | Donor `data\materials\misc\rallypoint.dds` exists but is private-use/uncopied; colours are port palette. | `world.gd:3602-3629` draws selected building's rally flag. | **GAP P0** — no rally marker in 3D. |
| FX placement / coordinate frame | `world3d_fx.gd:227-236` maps sim Vector2 → scene `Vector3(p.x - world_offset.x, …)`; `world_offset` is declared at `:90` and **never assigned anywhere in the project**. Terrain and entities use a centred frame: `world3d_terrain.gd:312-314` `(x+0.5-w/2)*TILE_M`, `world3d_entities.gd:416` `p.x - w*0.5*TILE_M`. `config.json:39-40` sets 320×320 tiles → half-extent 320 m. | Port coordinate contract, no donor art involved. | 2D uses map-origin px (`world.gd:350`). | **GAP P0** — FX land ~320 m from the entities they mark; **INFERENCE**: invisible in a normal camera view. |

FX cap is `Data.FX_CAP=220` (`data.gd:121`, enforced `world3d_fx.gd:585-593`),
same as 2D; event peeking (`:246-265`) is deliberately disabled by
`world3d.gd:241-244` because `main.gd:1611-1661` forwards `add_fx` explicitly,
so no double-spawn. No RNG (`:16`).

## 4. Evidence table — animation

| Item | Evidence | Verdict |
|---|---|---|
| Donor-timed clock | `anim3d.gd:37` fps 30; `:49-68` AAF ranges; `:98-143` `play()` resolves frame and publishes `anim3d_pose` (`:78`, `:199-203`). Verified against donor `peaukr.aaf:3-20` and `.oss` header. | **DONOR-BACKED for one unit**, honestly returned as `verified=false`. |
| Honest label | `anim3d.gd:41` `PORT_LABEL`, `:44` `BLOCKED_RIG`; `world3d_entities.gd:75,81-82,140,144,556-557,590` `STATIC BIND POSE … NOT DONOR PARITY`, `anim_handoff["applied"] = false`. | **VERIFIED HONEST** — no false parity claim. |
| Runtime consumer | `world3d.gd:328-331` exposes `play_anim()` but **no call site exists** in `scripts/`, `scenes/` or `tests/`; `anim3d_pose` appears only in `anim3d.gd:78,199-203`. `world3d_entities.gd:555-590` only refreshes transforms; no mesh morph or pose sampling. | **GAP P0** — the clock is instantiated/bound (`world3d.gd:223,247-248`) but never driven; every entity stays in bind pose. |
| Coverage | `AAF_ACTIONS` has 18 actions for **one** sid; `play()` key has no `sid` parameter (`anim3d.gd:98`), so any future caller would apply peasant frames to every unit. 194 donor `.aaf` files exist. `ACTION_ALIAS attack→attack0` (`:70-75`) is a port assumption. | **GAP P1** — donor-coverage limitation; alias UNVERIFIED. |
| Rig feasibility | `.oss` size closure above leaves no parent table; no morph/skin GLB in project; `anim3d.gd:139-141` marks visual/loop UNVERIFIED. | **BLOCKED, not a coding omission** — do not fabricate a hierarchy. |

## 5. Evidence table — audio events and spatialisation

All events below are dispatched identically in 3D and 2D (`variant3d/scripts/main.gd:1611-1661`
vs `app/scripts/main.gd:1541-1591`) and use the same 325 donor `.ogg` clips.
`at` is a sim-metre `Vector2` passed on each positional line.

| Event | 3D `main.gd:line` | Sound | Positional arg? |
|---|---|---|---|
| shot / bullet | 1620-1621 | musket1, musket2 | yes, `ev.pos` |
| shot / arrow, firearrow | 1622-1623 | arrow1 | yes |
| shot / cannonball | 1624-1625 | shotcannon1 | yes |
| shot / other | 1626-1627 | sabre1 | yes |
| smoke | 1628-1629 | (FX only) | n/a |
| heal | 1630-1631 | (FX only) | n/a |
| rout | 1632-1634 | alarm, -6 dB | **no** |
| crater | 1635-1636 | (FX only) | n/a |
| research / upgraded / trade | 1637-1642 | construct / alarm / btnclick | no |
| hit / bullet | 1643-1645 | arrowimpact1, -8 dB | yes |
| explode | 1646-1648 | cannonexpl1 + FX | yes |
| chop | 1649-1651 | workwood, -8 dB + FX | yes |
| death (building / unit) | 1652-1656 | deathbuilding1 / deathinf1,2 | yes |
| capture | 1657-1658 | alarm | no |
| done | 1659-1660 | `audio.building_sound(ev.kind)` (`audio.gd:393-402`) | no |
| walk (per-frame) | 1580-1587 | `audio.walk_sound` (`audio.gd:376-390`) | **no** |

Ambient beds: `audio.gd:63-116` starts atmosphere + 4 donor beds; `:137-231`
drives windmill/town/sea by distance to `parent.get("camera")`.

| Spatial issue | Evidence | Verdict |
|---|---|---|
| Positional attenuation silently inert | `audio.gd:317-323`: `get_viewport().get_camera_2d()`; in `render_mode="3d"` (`config.json:38`, `main.gd:583-586`) the current camera is `Camera3D` (`camera3d.gd:38`), so `cam == null` and the 20–60 m cutoff/dB curve is skipped. | **GAP P1** — every positional event above plays at full volume anywhere on the map. |
| Ambient centre uses wrong frame/scale | `audio.gd:150-153`: `center = cam.global_position / 16.0` assumes a Camera2D in px (`main.gd` 2D convention). A `Camera3D.global_position` is Vector3 **metres in scene frame** (`camera3d.gd:148-152`), while `game.live_blds[*].pos` is map-origin metres (`game.gd:2821-2823` producers). Dividing by 16 shrinks the camera near scene origin; buildings are hundreds of metres away. Vector3→Vector2 assignment is also type-suspect. | **GAP P1** — mill/town/sea beds will not ramp correctly; runtime type error **UNVERIFIED** (headless 3D run not in this scope). |
| No spatial audio implementation | No `AudioStreamPlayer3D`/`AudioListener3D`/bus layout (`variant3d/project.godot:1-28`; grep across `variant3d/scripts/`). Donor is emitter-based: `SndGetOrCreateSound(sndtag, libname, emitterHnd)` at `C:\Games\Cossacks 3\data\scripts\lib\sound.script:418,468,515`, with `SetSndSoundRadius(8000, …)` and the comment "80 - for 3D sound, 8000 for isometric sound" at `:425,477,524`. | **GAP P1** — no panning/distance falloff in the 3D view. Donor radius semantics (8000 vs 80, panning) **UNVERIFIED**. |

## 6. Ranked gaps

| Rank | Gap | Why it blocks / hurts | Evidence |
|---|---|---|---|
| **P0-1** | FX are placed in an uncentred frame: `world_offset` is never set | With the default 320-tile map every shot/smoke/explosion/trail is ~320 m away from the unit/building that emitted it; the FX layer is effectively useless in 3D. | `world3d_fx.gd:90,227-236`; `world3d_terrain.gd:312-314`; `world3d_entities.gd:416`; `config.json:39-40` |
| **P0-2** | Ghost and rally APIs have no runtime caller | Building placement has no green/red footprint and no rally pennant in 3D, both of which exist in 2D. | `world3d_fx.gd:167,191`; `tests/t_fx3d.gd:218-219`; `app/scripts/world.gd:3460-3529,3602-3630` |
| **P0-3** | Animation clock is instantiated but never driven; meshes stay in bind pose | No `play_anim` call and no `anim3d_pose` consumer anywhere, so even the donor-timed frame numbers never reach the renderer. The static-pose label is honest but the feature is inert. | `world3d.gd:223,247-248,328-331`; `anim3d.gd:78,98-143`; `world3d_entities.gd:75,556-590` |
| **P1-1** | Positional audio disabled in 3D; ambient centre wrong | All positional events are full-volume; windmill/town/sea proximity logic is fed a Camera2D-shaped value that does not exist in 3D. | `audio.gd:150-153,317-323`; `camera3d.gd:38,148-152`; `main.gd:583-586` |
| **P1-2** | Explosion/smoke/flash use hardcoded primitives, not donor PFX parameters | No donor size, lifetime, colour or count is consumed; only three bullettrail literals are used. Donor sprite sheets exist but are private-use, so port parity cannot be claimed. | `world3d_fx.gd:27-39,42-60,358-439`; `source.pfx:41-62,105-177,385-411,1322-1415` |
| **P1-3** | Animation coverage is one unit and has no sid key | Even once wired, all units would use `peaukr` frames; 193 other donor AAF files are unused. | `anim3d.gd:46-68,98`; `peaukr.aaf:3-20`; 194 donor `.aaf` files |
| **P2-1** | Hit and dust have no FX; `capture`/`fire` kinds are unreachable | No visual impact feedback; dead table entries mislead coverage claims. Donor impact PFX exists but cannot be copied. | `main.gd:1643-1645`; `game.gd:5037,5068`; `world3d_fx.gd:27-38`; `source.pfx:183-247` |
| **P2-2** | No audio buses / spatial nodes; per-FX `OmniLight3D` | Mixing is flat Master-only; each flash/explosion/fire adds an unshadowed light, an unbounded cost with 220 FX. | `project.godot:1-28`; `audio.gd:57-60`; `world3d_fx.gd:348-355,396,408,421` |

## 7. Smallest donor-grounded fixes (no new art, no invented values)

1. **P0-1 — one line in `bind`.** Set
   `fx.world_offset = Vector2(game.MAP_W * Data.TILE_M * 0.5, game.MAP_H * Data.TILE_M * 0.5)`
   in `world3d.gd:241-244`. This reuses the exact centring already used by
   `world3d_entities.gd:416` and `world3d_terrain.gd:312-314`; no new constant.
2. **P0-2 — reuse the existing 2D trigger sources.** In `world3d.gd.sync()`
   (`:279-288`), call `fx.draw_ghost(sid, wp, ok)` from the same
   `hud.build_ghost_sid` + `game.can_place` state used by `world.gd:3460-3505`,
   and `fx.draw_rally(e.rally, e.player)` for selected buildings as in
   `world.gd:3605-3613`. The 3D meshes already exist in `world3d_fx.gd:309-316,
   442-473`; no donor art is copied.
3. **P0-3 — drive the honest clock.** Call `anim.play(e, action, t)` from
   `world3d_entities.gd.sync()` using existing sim state (`e.moving`, attack,
   work) with `t = _anim_t`; keep `ANIM_STATUS`/`PORT_LABEL` and
   `anim_handoff["applied"] = false` until a donor-backed rig exists. This is
   the smallest change that makes the donor-timed frame numbers observable
   without claiming deformation.
4. **P1-1 — make `audio.play` render-mode aware.** In `audio.gd:317-323`, when
   `Data.RENDER_MODE == "3d"`, take the listener from the current `Camera3D`'s
   `_target` (map-origin metres, `camera3d.gd:90`) instead of
   `get_camera_2d()`; keep the existing 20–60 m curve and 60 m cutoff unchanged.
   In `_process` (`:150-153`) use the same `_target` for `center`. For true
   panning, swap the 16-player pool (`:57-60`) to `AudioStreamPlayer3D` placed
   at the donor-style emitter position derived from `at` — structurally
   grounded in `data\scripts\lib\sound.script:418,515`, exact radius semantics
   still **UNVERIFIED**.
5. **P1-2 — consume donor keys as data, not art.** Generate a read-only
   numbers-only table from `source.pfx` (frame counts, Interval/FrameRate,
   PixelRatio, AlphaTime/AlphaPower, bullettrail TimeLimit/Alpha/MarkWidth) and
   use it for FX life/alpha/scale in `world3d_fx.gd`; leave the procedural
   meshes in place because donor DDS art is private-use. Do not change the
   shipped 2D lifetimes without an A/B decision.

## 8. Open questions

- **Q1** How do `PixelRatio`, `Interval`, `FrameRate`, `AlphaTime/Power` map to
  metres, seconds and opacity in the donor engine? Until answered, even the
  three literal trail constants in `world3d_fx.gd:57-59` are unproven.
- **Q2** Does the donor ever attach `bullettrail` to bullets, or only arrows?
  The key name suggests bullets; the 3D port only emits arrow trails
  (`world3d_fx.gd:279`), and 2D does the same (`world.gd:3548-3549`).
- **Q3** Is a donor bone-parent hierarchy stored outside `.oss` (e.g. an
  `.actor`/`.aix` file)? The `.oss` payload itself is closed; if a parent table
  exists elsewhere, `BLOCKED_RIG` should be revisited, otherwise it stands.
- **Q4** Does the donor play these sounds with 3D panning in the main view,
  given `SetSndSoundRadius(8000)` is commented "8000 for isometric sound"
  (`sound.script:425,477,524`) and a separate "80 - for 3D sound" alternative
  exists? This decides whether `AudioStreamPlayer3D` or just distance-volume
  is the faithful fix.
- **Q5** Should the remaining camera/terrain/entity frame inconsistency
  (`camera3d.gd:148-152` map-origin focus vs centred meshes) be fixed in the
  camera or in the FX/entity placement? This audit only proves the FX-vs-entity
  mismatch; the owning decision is outside this scope.
- **Q6** Does a headless 3D run actually execute `audio._process()` with a
  `Camera3D` and throw on the Vector3→Vector2 assignment at `audio.gd:153`?
  Runtime proof is AUDIT3D-09's scope; here it is **UNVERIFIED**.

## 9. Verdict

The 2D audio bed is fully preserved in 3D (same script hash, same clips, same
event dispatch), and the animation/PFX modules are unusually honest about their
limits. But the 3D presentation layer is not acceptance-ready: FX are placed in
the wrong frame, ghost/rally/animation APIs are dead at runtime, and all
"positional" audio falls back to flat volume because the 2D camera lookup
returns null. No donor size/lifetime/colour/count is used for smoke or
explosions — only three unverified bullettrail literals.
