---
id: AUDIT3D-02
owner: AUDIT3D-02
date: 2026-11-24
scope: "variant3d/ colours for units, buildings, terrain and FX vs app/ (2D port) and private-use donor at C:\Games\Cossacks 3. Nation/player colour basis, materials, team tint."
status: "AUDIT COMPLETE — evidence-based; AUDIT ONLY (no source edits, no git, no donor writes)"
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBSERVATION vs INFERENCE, UNVERIFIED labels, P0/P1/P2, smallest donor-grounded fix."
---

# AUDIT3D-02 — Nation/player colour, materials and team tint

## 1. Scope and method

- Files read in full: `variant3d/scripts/world3d_entities.gd` (590 lines),
  `variant3d/scripts/world3d_fx.gd` (631), `variant3d/scripts/world3d_terrain.gd` (348),
  `variant3d/scripts/camera3d.gd` (376); relevant sections of
  `app/scripts/data.gd`, `app/scripts/world.gd`, `app/scripts/hud.gd`,
  `app/scripts/menu.gd`; donor **read-only** text at `C:\Games\Cossacks 3\data\**`.
- `camera3d.gd` was read in full: it contains **no colour code at all** (no
  `Color`, material, albedo, tint, fog or sky creation). Its constants are camera
  geometry (`camera3d.gd:43-55`) and donor-cited framing only; terrain/FX colour is
  explicitly not owned by it (`variant3d/scripts/world3d_terrain.gd:19-20`,
  `world3d_fx.gd:17-18`). No camera finding in this report.
- Labels: **OBS** = directly readable at the cited `path:line`; **INF** =
  inference from OBS; **UNVERIFIED-INVENTED** = hardcoded RGB/RGBA with no
  donor text key and no matching `app/` line that itself cites such a key.
- The donor was never written to and no binary was copied or executed. Donor
  `.script`/`.inc`/`.pfx`/`.mat` files were read as text only.

## 2. Evidence table

| # | Finding | Donor source or `app/` line (truth) | `variant3d/` line | Verdict |
|---|---|---|---|---|
| 1 | Donor player "key colour" table exists and is readable text. 14 case entries with integer RGB + per-entry `koef`, normalised `r/g/b = ir*koef/255` (values >1 intended/clamped downstream). | `C:\Games\Cossacks 3\data\scripts\lib\classes.script:7986-8015` (`GetKeyColorByPlayerIndex`), counts `data\scripts\dmscript.global:121-122` (`gc_MaxColorCount = 13`, `gc_MaxKeyColorCount = 24`), global array `classes.script:7685`, populated at `:8091-8092` | no consumer found in `variant3d/scripts/**` | **OBS** — donor truth is present and readable; **never consumed by either port**. |
| 2 | Donor applies that key colour to real 3D unit/building objects recursively as shader uniform 0. | `misc.script:5067-5081` (`SetGameObjectUniform4fByHandle(goHnd, 0, gKeyColor[colorInd][0..2], a, False)`); called for units `unit.script:3860`, buildings `player.script:2971`, on load `common.inc\onloadfull.inc:28`, `units\building.inc\initial.inc:138`, `units\global.inc\readnewp.inc:50`, `units\global.inc\writenewp.inc:32` | `world3d_entities.gd:170-188`, `:265-268` create materials from donor albedo PNG only; no colour uniform/tint | **OBS** donor / **OBS** absence in 3D → **gap G1**. |
| 3 | Donor key colour is by **player slot**, not by nation: `mapplayer.color := ind`, mercenary = `gc_MaxColorCount-1`. | `data\scripts\lib\map.script:118-123,136-137`; GUI reads `gKeyColor[gMap.players[i].color]` at `data\gui\menu.inc\showcustomgame.inc:705`, `showtraderesources.inc:265` | `world3d_fx.gd:67-74,622-623` indexes palette by `player` (same concept, wrong values/order) | **OBS** — concept matches, **values do not** (see row 6/7). |
| 4 | 2D port `NATIONS` table has **no colour field** despite its own comment "Colors are the two team colours the port draws". | `app/scripts/data.gd:225-239` (comment `:225-226`, entries `:227-239` have only `name`/`no18c`); mirrored `variant3d/scripts/data.gd:229-243` | `variant3d/scripts/data.gd:229-243` identical | **OBS** — stale comment; there is no nation→colour mapping in either port. |
| 5 | 2D main palette (world-space rings, flags, roster) is a hardcoded 12-entry literal, copied between `world.gd` and `menu.gd`; `world.gd`'s comment credits `hud.gd MM_PLAYER_COLORS` but the arrays are **not equal**. | `app/scripts/world.gd:2165-2182`, `app/scripts/menu.gd:492-501`; `app/scripts/hud.gd:126-138` (different values) | mirrored in `variant3d/scripts/world.gd:2165-2182`, `variant3d/scripts/menu.gd:492-501`, `variant3d/scripts/hud.gd:138-151` | **OBS** — port palette is **UNVERIFIED-INVENTED** relative to donor; internally inconsistent across port lanes. |
| 6 | Donor palette P0..P12 recomputed from `classes.script:7991-8007` (with `koef` `:7988`): P0 red (0.740,0,0), P1 blue (0.071,0.400,0.904), P2 teal (0.198,0.812,0.667), P3 purple (0.548,0.216,0.820), P4 orange (1.0,0.424,0), P5 green (0,0.643,0), P6 cyan (0.659,1.0,1.0), P7 pink (1,0.314,0.549), P8 amber (1,0.745,0), P9 dark teal (0,0.502,0.549), P10 light green (0.549,0.745,0.314), P11 brown (0.475,0.388,0.151), P12 dark brown/mercenary (0.436,0.224,0). All pairwise distinct; 13 slots. | `classes.script:7988-8014`, `dmscript.global:121` | port palette `world.gd:2172-2179` = P0 blue, P1 red, P2 yellow, P3 green, P4 purple, P5 cyan, P6 pink, P7 grey, P8 orange, P9 lime, P10 teal, P11 brown — all 12 pairwise distinct but **not donor values and not donor order** (port P0≈donor P1, port P1≈donor P0, port P2 has no donor equivalent at slot 2) | **INF from OBS** — P1..N are distinct in both, but **port ≠ donor in both value and permutation**; port has 12 slots vs donor 13 (`data.gd:184 MAX_PLAYERS := 12`). |
| 7 | 3D FX player colour is an exact literal copy of the 2D world palette (`app/scripts/world.gd:2172-2179`), not of `hud.gd MM_PLAYER_COLORS` or donor `gKeyColor`. | `app/scripts/world.gd:2172-2179` | `variant3d/scripts/world3d_fx.gd:62-74`, `_player_color` `:622-623`; used only for the rally pennant `:469,480-484` | **OBS** — 2D **parity PASS** with world.gd; **donor fidelity FAIL**; minimap palette (`variant3d/scripts/hud.gd:144-151`) still differs from the 3D flag colour. |
| 8 | 3D FX kind colours (shot/smoke/explode/crater/fire/heal/capture/rout/chop/trail) are literal copies of 2D `world.gd:3653-3685` RGB; alphas are approximating constants instead of 2D's `(1-k)` fade. | `app/scripts/world.gd:3652-3686` | `variant3d/scripts/world3d_fx.gd:358-380` | **OBS** — port-reused RGB (not donor art); alpha values `0.95/0.55/0.90/0.80/0.85/0.80/0.85/0.85/0.80` and `TRAIL_ALPHA=0.2` (`fx:58`) are **UNVERIFIED-INVENTED** approximations. |
| 9 | Build-ghost green/red exactly copied from 2D. | `app/scripts/world.gd:3509` `Color(0.2,1.0,0.3,0.5)` / `Color(1.0,0.25,0.2,0.5)` | `variant3d/scripts/world3d_fx.gd:65-66` `Color(0.20,1.00,0.30,0.45)` / `Color(1.00,0.25,0.20,0.45)` | **OBS** — port-reused RGB; alpha 0.45 vs 0.50 minor drift (**P2**). Module itself says "no donor ghost config was readable" (`fx:165-166`). |
| 10 | 3D FX material is procedurally created: unshaded + emissive, `emission_energy_multiplier = 0.35`. | no donor equivalent cited; PFX has interval/alpha keys (`source.pfx:1740-1746`), not this material model | `variant3d/scripts/world3d_fx.gd:323-334`, pulse `:516-521` | **UNVERIFIED-INVENTED** (0.35 energy, unshaded/emissive shading choice). |
| 11 | Donor PFX **does** contain readable life-colour blocks (not mapped by this port): `standingsmoke` RGB 0.3137, alpha 0→0.1→0; `buildingfirestart` RGB 0.7843, alpha 0.5; `buildingsmokestart` RGB 0.1569, alpha 0.75. | `data\pfx\source.pfx:942-947` (section name) + `:973-994`; `:1805-1810` + `:1871-1893`; `:1900-1905` + `:1966-1988` | 3D smoke `fx:363` (0.85,0.85,0.82), fire `fx:369` (1.0,0.45,0.10) | **OBS** — donor colour keys exist; section→FX-kind mapping is UNMAPPED in V7-2 and in `fx:9-14`, so values cannot be substituted blindly. |
| 12 | 3D unit/building albedo is donor-grounded: donor DDS per model, baked to PNG, loaded as `albedo_texture`. | `variant3d/assets/models/manifest.json:8,27` (`texture: C:\Games\Cossacks 3\data\materials\units\*.dds`); `world3d_entities.gd:17-20` header | `variant3d/scripts/world3d_entities.gd:170-188`, `:265-268` | **OBS** — albedo source PASS; **no player/nation tint is ever applied** to these materials. Env/bbox scaling is donor-cited (`entities.gd:67-68,283-289`), but colour is not. |
| 13 | 3D batches are keyed by `sid` only; per-player colour cannot be represented; `player` never appears in the entity module. | 2D applies player colour to building flags/rings/stripes `app/scripts/world.gd:2845,2969-2972,3015-3041,3094,3103` and to unit selection ring / procedural coat `:3240-3254` | `variant3d/scripts/world3d_entities.gd:321-336` (`key = "unit|sid"`), `:450-468`, `:471-489`; grep `player|nation|tint|albedo_color|vertex_color|set_instance_color` over this file → **0 matches** | **OBS** — 3D units/buildings are **unchanged donor albedo with no team tint**; 2D selection/flag/stripe cues are absent in 3D. |
| 14 | 3D rally marker is the **only** 3D object using player colour, but `draw_rally()` has no caller anywhere in `variant3d/scripts/**` (only its own definition and internal references). | 2D equivalent is driven from selected building with rally at `app/scripts/world.gd:3602-3629` | `variant3d/scripts/world3d_fx.gd:191-203`, `:442-473`; grep for `draw_rally(` across `variant3d/scripts` returns only `fx:7,191` | **OBS** — in current wiring, **no player colour is rendered in the 3D world at all** (minimap is a separate HUD lane). |
| 15 | Terrain albedo comes from a splat PNG (or a donor grass fallback); vertex colours explicitly disabled; a port-tuned emission floor is added. | 2D terrain tint table `app/scripts/data.gd:213-221` hardcoded port values; height source `data\scripts\generatemap.inc:537-577` (geometry, not colour) | `variant3d/scripts/world3d_terrain.gd:40-45` (`EMISSION_RGB := Color(0.06,0.06,0.05)`), `:73-88` (`vertex_color_use_as_albedo = false`, `emission_enabled = true`), `:217-225`, `:262-270` | **UNVERIFIED-INVENTED** emission constant (module labels it "PORT-TUNED art floor", `:43-44`); albedo texture path is donor-derived per header `:16-17` but not independently re-verified here. |
| 16 | Water plane is a flat translucent RGBA constant; donor water material is a luminance wave texture with no RGB literal. | `C:\Games\Cossacks 3\data\water\water.mat:3-14` (`Image = .\data\water\textures\diffusewaves0.bmp`, `TextureFormat = tfLuminance`); 2D blue `app/scripts/world.gd:1057` = `Color(0.16,0.36,0.44)` and `SHORE_DEEP :1317` = same | `variant3d/scripts/world3d_terrain.gd:166-170` `Color(0.19,0.245,0.255,0.45)` | **UNVERIFIED-INVENTED** — matches neither donor texture nor the 2D port blue; **P1**. |
| 17 | Season tint exists as a hardcoded table in both ports; terrain module does not consume it. | `app/scripts/data.gd:215-221`; mirrored `variant3d/scripts/data.gd:219-225` | `variant3d/scripts/world3d_terrain.gd` never calls `Data.terrain_tint()` | **OBS** — 3D terrain ignores even the port's own season tint; winter/desert 3D ground will look like summer. **P1/P2** (overlaps AUDIT3D-03). |
| 18 | Env props use donor bbox + `envscales.cfg` numbers, but their material colour comes from the same donor albedo PNG with no team tint. | `data\game\var\envscales.cfg` cited at `world3d_entities.gd:32-34`; manifest texture source row 12 | `world3d_entities.gd:67-73,170-188,283-289` | **OBS** — geometry/scale donor-grounded; colour donor-grounded by texture only. |

### 2.1 Palette mismatch at a glance (all RGB values are OBS from cited lines)

Donor `gKeyColor` (from `classes.script:7991-8007`, `koef` applied) vs port main
palette (`world.gd:2172-2179`, copied at `world3d_fx.gd:67-74`) vs port minimap
palette (`hud.gd:131-138`):

| Slot | Donor (`classes.script`) | Port main / 3D FX | Port minimap (`hud.gd`) |
|---|---|---|---|
| 0 | red (0.740, 0, 0) | blue (0.30, 0.62, 1.00) | blue (0.35, 0.75, 1.00) |
| 1 | blue (0.071, 0.400, 0.904) | red (1.00, 0.32, 0.26) | red (1.00, 0.35, 0.30) |
| 2 | teal (0.198, 0.812, 0.667) | yellow (1.00, 0.78, 0.22) | yellow (1.00, 0.85, 0.20) |
| 3 | purple (0.548, 0.216, 0.820) | green (0.42, 0.85, 0.42) | green (0.35, 1.00, 0.45) |
| 4 | orange (1.0, 0.424, 0) | purple (0.70, 0.45, 1.00) | purple (0.85, 0.50, 1.00) |
| 5 | green (0, 0.643, 0) | cyan (0.25, 0.85, 0.85) | cyan (0.30, 1.00, 1.00) |
| 6 | cyan (0.659, 1.0, 1.0) | pink (1.00, 0.55, 0.72) | pink (1.00, 0.50, 0.85) |
| 7 | pink (1, 0.314, 0.549) | grey (0.85, 0.85, 0.85) | white (1.00, 1.00, 1.00) |
| 8 | amber (1, 0.745, 0) | orange (1.00, 0.60, 0.10) | orange (1.00, 0.60, 0.10) |
| 9 | dark teal (0, 0.502, 0.549) | lime (0.55, 0.95, 0.30) | lime (0.55, 0.95, 0.30) |
| 10 | light green (0.549, 0.745, 0.314) | teal (0.10, 0.70, 0.65) | teal (0.12, 0.88, 0.80) |
| 11 | brown (0.475, 0.388, 0.151) | brown (0.65, 0.42, 0.22) | amber-brown (0.88, 0.58, 0.30) |
| 12 | dark brown / mercenary (0.436, 0.224, 0) | — (no 13th slot; `data.gd:184` cap 12) | — |

**Verdict on distinctness (OBS):** all 12 port colours are pairwise distinct, as
are all 13 donor colours; *but the port P1..N values and their player→colour
assignment do not match the donor*, and the 3D flag uses the port main palette
while the 3D minimap uses the brighter one.

## 3. Ranked gaps

### P0 — blocks acceptance

- **G1 — No donor key-colour tint on any 3D unit or building.** Donor explicitly
  calls `_misc_ApplyKeyColorRecursiveChild(goHnd, gMap.players[pl].color)` for
  units and buildings (`unit.script:3860`, `player.script:2971`,
  `onloadfull.inc:28`) and sets shader uniform 0 from `gKeyColor`
  (`misc.script:5070-5073`). `world3d_entities.gd:170-188` creates one untinted
  donor-albedo material per `sid`; batches are keyed `unit|sid` (`:321-336`), so
  no player colour can exist even in principle. This is the user's stated
  "nation colour basis" concern. **OBS** donor, **OBS** 3D absence.
- **G2 — The player colour palette itself is invented, not donor-derived, in
  both the 2D port and the 3D port.** Donor table is at
  `classes.script:7986-8015` with 13 slots (`dmscript.global:121`); neither
  `app/scripts/world.gd:2172-2179` nor `app/scripts/hud.gd:131-138` nor
  `variant3d/scripts/world3d_fx.gd:67-74` reads it. Values and order differ
  (§2.1). `data.gd:225-226` claims "Colors are the two team colours the port
  draws" but `NATIONS` has no colour field (`data.gd:227-239`). Fixing only the
  3D visual without fixing the palette source leaves the root cause intact.

### P1 — visible / functional mismatch

- **G3 — Player colour is never rendered in the 3D world.** `draw_rally()` is the
  only 3D consumer of `_player_color()` (`world3d_fx.gd:469,480-484,622-623`)
  and has no caller (`fx:191`; grep over `variant3d/scripts` finds none). The
  2D port draws player-coloured building flags, selection rings and stripes
  (`app/scripts/world.gd:2845,2969-2972,3015-3041,3094,3103`) and unit
  selection ring/coat (`:3240-3254`). In 3D those cues are absent.
- **G4 — FX colours are port-invented while donor colour keys are readable.**
  `world3d_fx.gd:358-380` copies 2D RGB (`app/scripts/world.gd:3652-3686`) and
  invents alphas; donor `source.pfx:973-994,1871-1893,1966-1988` has explicit
  life-colour RGBA. Mapping is unmapped, so a direct swap is not yet safe; at
  minimum the 3D smoke/fire colours do not match donor smoke/fire colours.
- **G5 — Flat invented water colour.** `world3d_terrain.gd:166-170`
  `Color(0.19,0.245,0.255,0.45)` vs donor wave texture `data\water\water.mat:3-14`
  and 2D `Color(0.16,0.36,0.44)` (`app/scripts/world.gd:1057,1317`).
- **G6 — 3D terrain ignores season tint.** Both ports define `TERRAIN_TINT`
  (`app/scripts/data.gd:215-221`; `variant3d/scripts/data.gd:219-225`) but
  `world3d_terrain.gd:73-88` never reads it; winter/desert maps render with
  summer ground colour + a fixed emission floor (`:43-45`). (Shares scope with
  AUDIT3D-03.)

### P2 — polish

- **G7 — Two conflicting port palettes leak into 3D.** 3D rally flags use
  `world.gd` palette (`world3d_fx.gd:67-74`), 3D minimap uses the brighter
  `hud.gd` palette (`variant3d/scripts/hud.gd:144-151`). This mirrors the same
  2D inconsistency, so it is not a 3D regression, but it is a visible
  same-player colour mismatch between world and minimap.
- **G8 — Port has 12 colour slots, donor has 13.** `data.gd:184 MAX_PLAYERS := 12`
  vs `dmscript.global:121 gc_MaxColorCount = 13` (index 12 reserved for
  mercenary by `map.script:136-137`). A 13th donor faction/mercenary cannot be
  represented.
- **G9 — Minor 3D FX drift:** ghost alpha 0.45 vs 2D 0.50
  (`world3d_fx.gd:65-66` vs `world.gd:3509`); invented emission energy 0.35
  (`fx:330`); trail alpha 0.2 (`fx:58`) vs 2D `0.7*(1-k)` (`world.gd:3685-3686`).

## 4. Smallest donor-grounded fix (no new art invented)

1. **Transcribe the donor table once** into `variant3d/scripts/data.gd` as
   `KEY_COLORS` from `classes.script:7991-8007`, applying `koef` at `:7988` and
   the normalisation at `:8012-8014`; use `gc_MaxColorCount = 13`
   (`dmscript.global:121`) and reserve slot 12 per `map.script:136-137`.
   Keep the existing 12-entry port palette only as a labelled port extension
   for slots 8..11 if the owner chooses 2D visual parity over donor fidelity
   (open question Q2).
2. **Apply it to entity materials** in `world3d_entities.gd`: in
   `_default_material` (`:170-188`) set `albedo_color`/shader-uniform-0
   equivalent from `Data.KEY_COLORS[player]` on top of the existing donor
   albedo texture, mirroring `misc.script:5070-5073`. Change the batch key from
   `"unit|sid"` (`:462`) to `"unit|sid|player"` and the building node name/map
   (`:471-489`) to carry `player`; this is the minimum change that makes donor
   team tint representable. Do **not** replace donor textures — they are already
   donor-grounded (`manifest.json:8,27`).
3. **Wire the existing rally path** from `world3d.gd.sync()` for selected
   buildings that have `rally`, passing `e.player`, mirroring
   `app/scripts/world.gd:3605-3629`; no new mesh or colour is needed because
   `world3d_fx.gd:442-473` already builds the pennant.
4. **Only then** change `world3d_fx.gd:67-74` to read `Data.KEY_COLORS`, so the
   3D flag and the 3D model tint agree. Leave `hud.gd` minimap palette untouched
   until Q2 is decided.
5. For FX/water, replace invented values only with cited donor keys once their
   mapping is verified (Q1); otherwise keep and label them as port
   approximations, as the modules already do (`world3d_fx.gd:9-14`,
   `world3d_terrain.gd:43-44`).

## 5. Open questions

- **Q1** — Which donor `source.pfx` section maps to each port FX kind
  (`shot/smoke/explode/fire/...`)? V7-2 calls PFX semantics UNMAPPED and
  `world3d_fx.gd:9-14` repeats this; donor colours found are grey
  (`:975-992`, `:1873-1890`, `:1968-1985`), port colours bright. Needs a
  section→kind mapping before substitution.
- **Q2** — Owner decision: **donor fidelity** (adopt donor 13-colour order and
  values) vs **2D parity** (keep the invented world/menu palette so 3D matches
  the shipping 2D port). These are mutually exclusive; all three 2D palettes
  disagree with the donor and with each other.
- **Q3** — Exact donor rendering of uniform 0: multiplicative tint, additive,
  or palette swap? No key-colour shader fragment was found under
  `data\shaders\**` (grep for `keycolor|uniform0|color0` yields only unrelated
  tone shaders), so the Godot-side replication is **UNVERIFIED**.
- **Q4** — Is `world3d_fx.gd` bound and synced at all by the integration seam?
  Grep shows no `draw_rally(` caller; confirm against `main.gd` /
  `world3d.gd` before assuming G3 is purely a wiring bug.
- **Q5** — Donor GUI also has a "team color container" skin
  (`data\gui\menu.inc\showhistoricalbattle.inc:376-377,639`;
  `showcustomgame.inc:490`). Are those per-team colour *choices* distinct from
  `gKeyColor`? Skins/images were not read in this audit.
- **Q6** — Are the DDS-derived albedo PNGs in `variant3d/assets/models/tex/**`
  byte-faithful to the donor DDS named in `manifest.json:8,27`? This audit
  accepted the manifest/code claim (`world3d_entities.gd:17-20`) without
  re-converting a donor DDS; AUDIT3D-08 may cover it.
