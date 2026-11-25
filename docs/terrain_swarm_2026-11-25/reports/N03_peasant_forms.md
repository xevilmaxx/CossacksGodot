---
ticket: N03 (Wave N — NATION OBJECT ASSOCIATIONS)
owner_scope: "peasants are of different form" — audit peasant unit mesh/sid per nation in the 3D port
author: N03 subagent
created: 2026-11-25
labels: [OBSERVED, DERIVED, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3); 'Ukrainian-derived' below is a FILE-PROVENANCE fact, not a rendered-look comparison. No Godot was run; no code edited; N03 owns only this report."
---

# N03 — peasant forms in the 3D port: one baked mesh/skin for every nation

## 0. Verdict in one line

**DERIVED (high confidence, file-level):** in the 3D port every nation's peasant — including
Russia — is the *same* presentation entity: sim sid `"peasant"` → mesh `assets/models/obj/peasant.obj`,
skin `assets/models/skin/peasant.json`, albedo `assets/models/tex/peasant.png`, all three converted
from the donor **Ukrainian** `peaukr.oss` / `peaukr.dds` / `peaukr.aaf`. The nation selector cannot
produce a different form because `NATION_UNITS` has **no peasant entry**, and no nation-keyed
peasant OBJ/GLB/skin/texture exists on disk. Only the player-slot key-colour tint differs per player
(not per nation). The 2D sibling *does* render eight distinct nation peasant sprite sets; the 3D port
does not. Whether the resulting pixels actually *look* Ukrainian/Russian is **UNVERIFIED** (no GPU
A/B frame was captured; no Godot was run per ticket).

---

## 1. OBSERVED — donor truth available locally (8 nation peasant bases)

| Evidence | Fact |
|---|---|
| `docs/REPORT_ASSETS_BAKING.md:174` | "Peasants for exactly 8 nations": donor `data/actors/units/pea{aus,eng,pol,rus,sco,spa,tur,ukr}.oss`; index has exactly `ukr/rus/pol/aus/eng/spa/tur/sco_peasant`. |
| `docs/guides/GUIDE1.md:126` | "Nation peasants: peaukr, pearus, peapol, peaaus, peaeng, peaspa, peatur, peasco." |
| `docs/audit/ANIM_ATTACK.md:134,142,151` | Bake mapping: `peasant→peaukr`, **`rus_peasant→pearus`**, `ukr_peasant→peaukr` (attack0 237..254). |
| `app/tools/bake_sprites.py:43-48` | `ALIAS_OF = {"peasant": "ukr_peasant"}` — the generic key and the Ukrainian key resolve to the SAME donor base `peaukr`; their 14 sheets are byte-identical. |
| `docs/UNIT_BAKING_FIX.md:71,197-198` | All 8 peasant nations ship 7 attach props, but per-nation tool UV/texture differences are flagged for later visual confirmation. |

**OBSERVED conclusion:** the donor genuinely has eight distinct nation peasant forms, and Russia's
is `pearus`, not `peaukr`. The generic `peasant` key is an alias of the Ukrainian one.

---

## 2. OBSERVED — 2D sprite sheets differ per nation (the port already does this)

`app/scripts/world.gd:457-468` (`_anim_key`) resolves `<nation>_peasant` **before** the base sid:
if the anim index has e.g. `rus_peasant`, a Russian player's peasant animates with that key.
`app/scripts/world.gd:870-895` (`nation_of` / `_nation_sheet`) then routes the sheet to
`res://assets/models/anim/<nat>/units/<nat>_peasant_<action>.png`, with `common/units` as fallback.

* `app/assets/models/anim/land_units/index.json` holds **eight** nation peasant keys:
  `ukr_peasant` (:4648), `rus_peasant` (:4975), `pol_peasant` (:5302), `aus_peasant` (:5629),
  `eng_peasant` (:5956), `spa_peasant` (:6283), `tur_peasant` (:6610), `sco_peasant` (:6937).
* On-disk 14-sheet sets exist in `app/assets/models/anim/<nat>/units/<nat>_peasant_*.png` for exactly
  those eight nations, plus the generic `app/assets/models/anim/common/units/peasant_*.png`.
* **OBSERVED (SHA-256, first 16 hex):** `common/units/peasant_idle.png` =
  `60AB745C1D7990C4` = `ukr/units/ukr_peasant_idle.png` (both 143719 B) — byte-identical.
  The other seven are distinct: `rus B08C8DE428A882B9`, `pol 381D83BF82773188`,
  `aus 05665E6E30A87F99`, `eng B68126D3E6432CBA`, `spa 9EFC33DFEEE62AEC`,
  `tur 7C43BFCBE0480EF4`, `sco 5647B46E164DCEE2`.
* The index metrics differ too, e.g. `walk.center` / `ay`: `rus_peasant` 1.08 / 0.7978
  (`index.json:4985-4989`) vs `ukr_peasant` 1.101 / 0.8037 (`index.json:4658-4662`).

**DERIVED:** 2D faithfully shows a Russian peasant with Russian sheets; Bavaria and Sweden have no
`<nat>_peasant` key (neither index nor folder), so those two default nations fall back to the generic
Ukrainian sheet — a donor-limited gap, not a resolver bug.

---

## 3. OBSERVED — how the 3D port resolves a unit sid to a mesh

1. **Sim sid is always generic.** `variant3d/scripts/game.gd:2955-2963` spawns every starting peasant
   with `spawn("peasant", i, ...)`, whatever the player's nation. `game.gd:4215-4221`
   (`train_unit`) calls `Data.resolve_sid(nat, sid)`; `data.gd:1564-1568` maps
   `NATION_UNITS.get(nat).get(sid, sid)`, and `NATION_UNITS` (`data.gd:294-306`) contains entries for
   serdiuk/musketeer/cossack/dragoon/priest only — **no `peasant` for any nation**. Hence
   `resolve_sid(nat, "peasant") == "peasant"` for rus/bav/pol/swe/ukr/tur/… alike.
2. **Nation is known but produces no candidate.** `variant3d/scripts/world3d_entities.gd:665-683`
   (`_nation_of`) reads `ed["nation"]` → `game.players[player]["nation"]` →
   `Data.PLAYER_NATIONS[player]`; `config.gd:540-556` seeds player 0 = `"rus"`, player 1 = `"bav"`.
   `_entity_mesh_sid()` (:746-800) for family `"units"` appends a candidate **only when**
   `rsid != base_sid` (:768-770). For `peasant` there is no remap, so `candidates` stays empty,
   `sid = base_sid = "peasant"`, `exact = false`, status = `NATION_MESH_FALLBACK_STATUS`
   (:789; label defined at :206). `_record_nation_mesh()` (:803-808) logs e.g.
   `units|rus|peasant->peasant`.
3. **Mesh load is a single sid-keyed lookup.** `add_unit()` (:1612-1620) passes that sid to
   `_mesh_info()`. `_mesh_info()` (:1110-1160) reads `OBJ_DIR + sid + ".obj"` (:1146-1150) or a GLB,
   bakes with the manifest bbox and caches by `kind|sid`. `_default_material()` (:582-590) loads
   `TEX_DIR + sid + ".png"`. Batch keys are `"unit|" + sid + "|p<player>"` (:1625-1629) — the player
   index separates key-colour tint only, never the mesh. Batch metas carry `nation` /
   `nation_mesh_exact` / `nation_mesh_label` (:1637-1639) but all peasant batches read
   `nation_mesh_exact = false`.
4. **Animation is also one sid-keyed lookup.** `sync()` (:2055, :2071-2087) samples the pose with
   the base sid: `has_skin(sid)` / `pose_for(ed, action, t)` on the sibling anim module discovered by
   `_find_anim()` (:1168-1183). `anim3d.gd:489-509` (`pose_for`) looks up `_skins[sid]` and derives
   action frames from `AAF_ACTIONS` (:71-90), which are transcribed from `peaukr.aaf:3-20` (:68).
   `_morph_mesh()` (:1308-1326, `:1253-1257`) rebuilds the mesh from `OBJ_DIR + sid + ".obj"` topology
   + those donor verts. All peasants therefore share one pose cache entry and one morphed mesh per
   (action, frame).
5. **No nation meshes exist on disk to select.** Directory enumeration of
   `variant3d/assets/models/obj/*.obj` (280 files): only `peasant.obj` matches peasants;
   **0** filenames start with `rus_/ukr_/bav_/tur_/eur_` (the sole `sco_highlandersword.obj` is a
   Scotland roster sid, not a nation peasant). `variant3d/assets/models/glb/` is empty;
   `variant3d/assets/models/tex/` has no `<nat>_peasant` albedo. `variant3d/assets/models/skin/`
   has 56 JSONs; only `peasant.json` is a peasant skin. Parsing `skin/index.json` (55 entries):
   exactly one peasant entry — `sid=peasant, file=peasant.json,
   donor_oss=…\peaukr.oss, donor_aaf=data/animations/aaf/peaukr.aaf, frame_count=30`.

The code itself declares the block honestly:
`world3d_entities.gd:206` `NATION_MESH_FALLBACK_STATUS` = "BLOCKED: exact nation 3D art is absent on
disk; Ukrainian-derived base mesh reused (manifest.json peasant->peaukr, …)";
`:213` `NATION_MESH_BLOCKED_EVIDENCE` = "0/172 converted OBJs carry a nation key … 0 rus-keyed and
0 bav-keyed textures … NOT VISUALLY FIXED".

---

## 4. OBSERVED — the single baked mesh is Ukrainian-derived

* `variant3d/assets/models/manifest.json:5-11`: `"sid": "peasant"` →
  `"mesh": …\data\actors\units\peaukr.oss`, `"texture": …\data\materials\units\peaukr.dds`,
  `"obj": …\assets\models\obj\peasant.obj`, `"texture_png": …\assets\models\tex\peasant.png`.
* `variant3d/tools/convert_models.py:162,168-170`: header "the models this port uses (**Ukrainian
  roster, the port's nation**)" and table `"peasant": "peaukr"`; the full table (:169-234) contains
  no `rus_peasant`/`ukr_peasant`/other nation peasant entries. That is *why* only one peasant OBJ
  was ever converted.
* `variant3d/assets/models/skin/peasant.json:1`: `sid=peasant`, `source=donor_oss`,
  `path=…\peaukr.oss`, `aaf_path=data/animations/aaf/peaukr.aaf`, 577 verts / 20 bones / 483 frames,
  actions from `peaukr.aaf` (idle 64..113, walk 1..20, death 115..149, attack0 237..254,
  construct 186..198).
* `variant3d/assets/models/skin/index.json:1` entry 1 repeats that provenance; `index.json` has no
  `rus_peasant`/`pearus` entry.
* `world3d_entities.gd:75-82` documents the tint mask measured on `peaukr.dds`
  (alpha>0.5 on 34990/262144 texels = 13.35%), decoded per sid from the same manifest path
  (:811-911). So even the player-colour bands come from the Ukrainian texture.

---

## 5. Concrete mismatches (owner's question answered)

| # | Mismatch | Evidence | Label |
|---|---|---|---|
| M1 | **Russian peasant form = Ukrainian mesh.** A Russian player's (`config.gd:540` → `nation0=rus`) starting peasant spawns as sid `peasant`, binds `peasant.obj`/`peasant.png`/`peasant.json` converted from `peaukr.*`, and is tagged `exact=false`. Donor Russia uses `pearus`. | §2-§4 above: `game.gd:2963`, `data.gd:294-306,1564-1568`, `world3d_entities.gd:768-789,1617-1620`, `manifest.json:5-11`, `docs/audit/ANIM_ATTACK.md:142` | **DERIVED** (file chain complete); rendered appearance UNVERIFIED |
| M2 | **All four default nations share one form.** Player 0 `rus`, 1 `bav` and menu picks `pol`/`swe` all resolve `peasant→peasant`; batches differ only by `|p<player>` tint key, so mesh identity is identical. | `config.gd:540-556`, `data.gd:208,294-306`, `world3d_entities.gd:1625-1629`, §3-§4 | **DERIVED** |
| M3 | **2D/3D divergence.** 2D draws a distinct `rus_peasant_*` / `pol_peasant_*` / etc. sheet set; 3D ignores those sheets entirely (header `world3d_entities.gd:17-20`: "NEVER reads the 2D bake"). Same entity looks nation-dressed in 2D and Ukrainian-neutral in 3D. | `app/scripts/world.gd:457-468,870-895`; `app/assets/models/anim/<nat>/units/*`; `land_units/index.json:4648,4975,…`; `world3d_entities.gd:17-20` | **DERIVED** |
| M4 | **The converter erased nation identity before the renderer ever saw it.** `convert_models.py` only ever mapped `peasant→peaukr`, so no amount of runtime nation lookup can find a Russian mesh. | `convert_models.py:162,169-170,236-242`; `manifest.json:5-11`; §4 | **OBSERVED** (source + outputs) |
| M5 | Bavaria/Sweden 2D fallback is also Ukrainian (no `<nat>_peasant` key), so donor fidelity for those nations is missing in **both** renderers. | index/folder enumeration in §2; `app/scripts/world.gd:457-468` | **DERIVED** |
| M6 | Adjacent (out-of-scope-but-related) risk: `sync()` samples animation with the **base** sid (`world3d_entities.gd:2055,2072,2085`), not `ns["sid"]` from `_entity_mesh_sid`. For nation-remapped soldiers (e.g. rus `serdiuk→strelet`, `data.gd:295`) the static bind mesh and the animated mesh/skin can disagree. Peasants are unaffected today only because their remap is the identity. | `world3d_entities.gd:2055,2072,2085` vs `:1617-1620`; `data.gd:295` | **DERIVED** (by code reading; no runtime probe) |

---

## 6. UNVERIFIED / open questions

1. **UNVERIFIED — rendered pixels.** No windowed Godot capture was taken (ticket forbids running
   Godot), so "the Russian peasant *visually reads* Ukrainian" is a provenance/mesh argument, not a
   pixel comparison. `ANIM_STATUS` / `NATION_MESH_*` labels themselves say "visual UNVERIFIED".
2. **UNVERIFIED — donor art availability on this machine.** No donor install was located under
   `reference/` in this tree; existence of `pearus.oss`/`pearus.dds` rests on the cited local
   audit docs (`REPORT_ASSETS_BAKING.md:174`, `GUIDE1.md:126`, `ANIM_ATTACK.md:142`), not a fresh
   byte read here. N02 owns donor verification.
3. **UNVERIFIED — whether the eight nation peasant .oss meshes differ in actual geometry vs only
   textures/attach props.** `UNIT_BAKING_FIX.md:197-198` calls per-nation tool UV/texture differences
   open; the 2D sheets are byte-distinct (§2) but that does not prove skeletal geometry differs.
4. **UNVERIFIED — a fix's visual result.** Adding `pearus/peapol/…` OBJ+skin+texture would require
   donor conversion, manifest/index edits and a GPU A/B; outside N03 (see N04/N05).

---

## 7. Scope / safety attestation

* Read-only: no `.gd`, `.json`, `.py`, asset or config was modified. No runner job, no Godot launch.
  This report is the only file written (`docs/terrain_swarm_2026-11-25/reports/N03_peasant_forms.md`).
* All line numbers are from the current working tree at 2026-11-25; asset filenames are quoted verbatim.
* No donor-parity claim is made; every status string quoted from the port is a PORT APPROXIMATION /
  visual-UNVERIFIED label.
