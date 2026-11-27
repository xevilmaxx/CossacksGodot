# PORT1TO1 — NATION-LABEL: read-only correction note for stale `NATION_MESH_BLOCKED_EVIDENCE` (1:1 donor port)

- id: PORT1TO1-NATION-LABEL
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER NATION-LABEL — READ-ONLY label correction note; no source edit"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_nation_label.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD while blocking_unverified is non-empty. No parity is claimed. No completeness is declared. No approximation is endorsed. No same-camera donor/port A/B was produced or examined. Nothing was executed; no donor file was opened, run, or copied; no port byte was changed."
- scope_guard: "Exactly one repo file written (this report). No source/Godot/git/donor-execution; no other edits. Read-only: `read` + `glob` only."

## 1. Exact label line(s) on disk (read this pass, NOT edited)

- Location: `variant3d/scripts/world3d_entities.gd:249` (single-line const; context `:239-250` NATION-MODEL-01 / B-NATION-PLAN2 block).
- Verbatim string on disk this pass:

```
const NATION_MESH_BLOCKED_EVIDENCE: String = "BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."
```

- Neighbouring labels left untouched and merely noted: `:241` `NATION_MESH_EXACT_STATUS`, `:242` `NATION_MESH_FALLBACK_STATUS`, `:247` `NATION_MESH_ROLE_SUB_STATUS`, `:270` `NATION_STAGE_GHOST_BLOCKED_STATUS`.
- Correction status: **the label is NOT already corrected on disk.** The `:249` string still carries the blanket "0/172 … (no rus*/bav*/eur*/tur*/ukr* stems)" premise verbatim, identical to the stale text quoted in `PORT1TO1_art_gaps.md §8`. Stated plainly per task: no correction has been applied.

## 2. On-disk re-verification of the `PORT1TO1_art_gaps.md §8` cited paths (this pass)

All globs below are under `variant3d/assets/models/obj/`. [V] = glob returned the file this pass.

- bav (refutes "no bav*" and "musketeer18bav absent"):
  - `variant3d/assets/models/obj/bav/land_units/musketeer18bav.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/bav/buildings/bavcen.obj` — PRESENT [V]
- ukr (refutes "no ukr*"; 8 building families + 4 land units observed):
  - `variant3d/assets/models/obj/ukr/land_units/serdiuk.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/ukr/land_units/peaukr.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/ukr/land_units/hetman.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/ukr/land_units/cossackregister.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/ukr/buildings/{cen,hou,bar,sta,bla,aca,art,dip}.obj` plus full `1..4`/`a`-suffixed stage sets (e.g. `cen1.obj`, `cen1a.obj` … `sta4a.obj`) — PRESENT [V] (100-entry glob, families enumerated)
- tur (refutes "no tur*"):
  - `variant3d/assets/models/obj/tur/land_units/tatar.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/tur/land_units/spakh.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/tur/land_units/sipahi.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/tur/land_units/jannisary.obj` — PRESENT [V]
- swe (additional nation-keyed presence, cited in art_gaps §8):
  - `variant3d/assets/models/obj/swe/land_units/pikeman18swe.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/swe/land_units/hackapell.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/swe/buildings/swecen.obj` — PRESENT [V]
- rus (extra observation this pass, beyond the art_gaps citation list; strengthens the refutation of "no rus*"):
  - `variant3d/assets/models/obj/rus/land_units/vityaz.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/rus/land_units/strelet.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/rus/land_units/pikemanrus.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/rus/land_units/pearus.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/rus/land_units/cossackdon.obj` — PRESENT [V]
  - `variant3d/assets/models/obj/rus/buildings/ruscen.obj` — PRESENT [V]
- eur: glob `variant3d/assets/models/obj/eur/**/*.obj` → **no file found** [V] this pass. The `eur*` stem clause is therefore the only stem sub-clause not refuted by an `obj/<stem>/` directory; the blanket "no rus*/bav*/tur*/ukr*" conjunction is still false as written.
- Clauses that STAND (carried from art_gaps §§3/8, not re-globbed beyond the above except as noted): `chaika` absent under `assets/models/`; `rusmil`/`turmil` building meshes absent under `assets/models/`; `grenadierbav` existence not checked this pass — left to the manifest owner, no claim made here. The bav-texture existence cite (`tex/bav/land_units/musketeer18bav.png`, `tex/bav/buildings/bavcen.png`) is carried from the review lane, not re-globbed here.

Conclusion: the blanket census premise at `:249` is refuted as written. Every OBJ path cited in `PORT1TO1_art_gaps.md §8` still exists on disk this pass.

## 3. Precise label-only correction wording for a COORD hard worker (text only, NOT applied)

Scope: string-literal text of `NATION_MESH_BLOCKED_EVIDENCE` at `world3d_entities.gd:249` ONLY. No value, logic, guard, branch, constant name, type, behaviour, or visual output may change. The const must remain a `String`, remain `BLOCKED`-labelled, keep the `NATION_DONOR_01 G7-G10/C6` cite, keep the `Missing-art owner: manifest.json + assets/models/obj/` routing, and keep `NOT VISUALLY FIXED` / `visual UNVERIFIED`.

Suggested replacement literal (point-in-time qualifier + nation-keyed file list; owner to paste as the full `:249` string):

```
"BLOCKED (NATION_DONOR_01 G7-G10/C6) [label corrected 2026-11-27; supersedes the stale 0/172 no-nation-key census]: nation-keyed OBJs ARE present on disk (bav/land_units/musketeer18bav.obj, bav/buildings/bavcen.obj; ukr/ 8 building families + serdiuk/peaukr/hetman/cossackregister; tur/land_units/tatar+spakh+sipahi+jannisary; swe/land_units/pikeman18swe+hackapell + swe/buildings/swecen.obj; rus/land_units/vityaz+strelet+pikemanrus+pearus+cossackdon + rus/buildings/ruscen.obj; eur-keyed obj/ NOT observed); still absent under assets/models/: Ukrainian chaika, rusmil/turmil building meshes; grenadierbav pending manifest-owner check; nation stage/ghost art per NATION_STAGE_GHOST_BLOCKED_STATUS (:270). Presence is file-presence only, NOT donor visual parity. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED; visual UNVERIFIED."
```

Why this wording is label-only and safe:

- It deletes no guard and adds none: the const stays a diagnostic string; no reader (`_nation_mesh_on_disk` candidate gating, `NATION_PEASANT_SIDS` sharing map at `:256-265`, fallback/role-sub labels) changes meaning, because the correction only narrows the *evidence clause* to actually-missing items and lists present files.
- The `2026-11-27` qualifier pins the census to a point in time so a future converter run cannot silently inherit a stale count; the owner lane can re-census without touching logic.
- It preserves the `BLOCKED` + `NOT VISUALLY FIXED` posture: the remaining gap (chaika, rus/tur mills, grenadierbav pending, stage/ghost art) keeps the blocked state truthful instead of flipping the label to PRESENT.
- It does not touch `NATION_MESH_EXACT_STATUS` / `NATION_MESH_FALLBACK_STATUS` / `NATION_MESH_ROLE_SUB_STATUS` / `NATION_STAGE_GHOST_BLOCKED_STATUS`, the `NATION_ROLE_SUB_SIDS` array, or any mesh-selection code.

## 4. Why this correction asserts no donor parity and cannot close any `[U]` or P0 row

- File presence is not visual proof: listing `musketeer18bav.obj`, `bavcen.obj`, `peaukr.obj`, tur/swe/rus sets on disk says nothing about donor mesh identity, scale, pivot, material, texture bytes, or animation. No donor/model-viewer A/B, no fixed-camera capture, and no byte/hash comparison was performed in this worker. The wording therefore carries `NOT donor visual parity` and `visual UNVERIFIED` explicitly.
- The `[U]-NATION-LABEL` unknown is a *label-accuracy* item, not an art-proof item: correcting the string removes a false census premise but proves no render correct. It cannot close `[U]-NATION-LABEL`'s underlying art gaps (chaika, mills, grenadierbav, stage/ghost), nor any `[U]-T-A/[U]-T-B`, `[U]-G/[U]-R`, `[U]-F/[U]-S`, `[U]-MILL-SAIL`, `[U]-NAVAL-TLF`, or carried `[U]` rows, and it cannot close or downgrade any P0 row, which requires owner-lane conversion evidence plus captured proof.
- Chain impact: none. Parity chain stays 0/6; blocking_unverified stays non-empty.

## 5. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Blocking_unverified is non-empty (stale `:249` premise live; chaika + rus/tur mills absent; grenadierbav pending; stage/ghost art blocked per `:270`). **RESULT IS NOT GOOD** while blocking_unverified is non-empty.
- No parity is claimed. No completeness is declared. §2 PRESENT paths are file-presence evidence only, not correctness, not a gate pass, not donor parity.
- No approximation is made or endorsed; no source, logic, guard, or behaviour was changed or proposed for change — string text only.
- Exactly one file was written: this report. No source/Godot/git/donor-execution; no other edits.

*End of PORT1TO1-NATION-LABEL.*
