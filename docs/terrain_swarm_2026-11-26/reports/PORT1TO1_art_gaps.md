# PORT1TO1 — ART-GAPS: read-only static verification of PORT1TO1_review_art.md new items (1:1 donor port)

- id: PORT1TO1-ART-GAPS
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER ART-GAPS — READ-ONLY static probe of the new PARTIAL/ABSENT items and the stale label flagged in PORT1TO1_review_art.md"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_art_gaps.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_DONOR_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD while blocking_unverified is non-empty. No parity is claimed. No completeness is declared. No approximation is endorsed. No same-camera donor/port A/B was produced or examined. Nothing was executed; no donor file was opened, run, or copied; no port byte was changed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git, or donor edit. Read-only: `glob` / `grep` / `read` over `variant3d/scripts/**`, `variant3d/assets/**`. Singleplayer skirmish only."

## 0. Method

Each item below was re-checked this pass against exact on-disk paths. Verdicts:
**confirmed ABSENT** = stated glob returned no file; **PRESENT-UNDER-OTHER-NAME** = only a different asset matches; **WIRING-UNPROVEN `[U]`** = code constant/node exists but its own label keeps runtime proof open. No mesh/texture was fabricated, no parity declared.

## 1. `peaaustools.png` — confirmed ABSENT, live path with labelled fallback

- Searched: glob `variant3d/**/peaaustools*` → **no file found** (any extension, any directory). [V] this pass.
- Reference: `variant3d/scripts/world3d_entities.gd:324` `TOOL_MATERIAL_PATH = "res://assets/models/tex/shared/land_units/peaaustools.png"` — live constant, not dead: consumed by `_get_tool_material()` at `:3264-3287` behind a `FileAccess.file_exists(TOOL_MATERIAL_PATH)` guard (`:3269`); missing file falls through to the labelled `fallback_white_untextured_DATA_GAP` plain material (`:3277-3283`, meta `tool_material_status`), never to a body texture or another nation's art (`:3261-3263` comment).
- Directory control: `variant3d/assets/models/tex/shared/land_units/` lists per-nation `pea*.png` (`peaaus/peaeng/peapol/pearus/peaspa/peatur/peasant` + others) but no `peaaustools.png`. [V]
- Donor grounding (carried): `data/materials/units/units.mat:18-19 → peaaustools.dds`, shared by all 8 attach sets (`world3d_entities.gd:319`, `TOOL_MATERIAL_CITE` at `:325`).
- Verdict: **confirmed ABSENT**. Owner condition: land the PNG via the approved converter (`bake_sprites.py:497` path cited in-code) at exactly the `TOOL_MATERIAL_PATH` location with `donor_bytes`/`donor_sha256` recorded, or re-point the constant through the owning lane — no edit here. Until then every tool-child render measures fallback shading, and `[U]-T-B` pixel proof cannot pass.

## 2. Naval `.tlf` / AAF — confirmed ABSENT, static-hull design label

- Searched: glob `variant3d/assets/models/**/*tlf*` → **no file found**; glob `variant3d/**/*.aaf` → **no file found**. [V] this pass.
- Port skin index: `variant3d/assets/models/skin/index.json` top-level `skipped` array lists exactly 7 naval sids (`yacht/yachttur/fishboat/frigate/galley/battleship/xebec`, reason "donor .osm/IDP2 hull (no skin tracks; V7-63 ships are static)"). [V] via read.
- Donor-side references only (not port runtime loads): `variant3d/scripts/anim3d.gd:327` `"ships"` comment (`yacht.aaf 4 rows 1..280`); `variant3d/tools/unit_bakers/naval.py:43,108` (donor clip notes). No `FileAccess`/load call for any `.tlf`/naval `.aaf` exists in the port runtime path; the live port path is the 7 derived static hull OBJs + `DONOR_SHIP_DEATH_*` suffix constants (`world3d_entities.gd:473-480`) with material/swap-frame semantics labelled `[U]-S` / visual UNVERIFIED (`:480`).
- Verdict: **confirmed ABSENT**. Owner condition: convert-or-document decision for the `.tlf` rigid-transform list through the owning lane; hulls stay static meshes by design label until then.

## 3. `chaika` + `rus/tur` mills — confirmed ABSENT (decals are not mills)

- Searched: `variant3d/assets/models/**/*chaika*` → **no file found**. [V]
- Searched: `variant3d/assets/models/**/*rusmil*` → **no file found**; `variant3d/assets/models/**/*turmil*` → **no file found**. [V]
- PRESENT-UNDER-OTHER-NAME exclusion: bare `**/*rusmil*` / `**/*turmil*` globs DO match `variant3d/assets/terrain/decals_png/rusmild(.w).png` + `decals_dds/rusmild(.w).dds` and `turmild(.w)` equivalents — these are mill-field decal strips, not mill building meshes, so they do not satisfy the mill-building gap. Recorded to prevent a false PRESENT claim.
- Carried donor/spec context (not re-verified): `spec/08_FIELDS_AND_PROPS.md` §8 "missing rus/tur mills"; `NATION_MESH_BLOCKED_EVIDENCE` chaika clause stands (see §8).
- Verdict: **confirmed ABSENT** for chaika naval unit + rus/tur mill buildings under `assets/models/`. Owner condition: convert-or-document through the manifest/obj owner lane.

## 4. Ghost-blink constants — WIRING-UNPROVEN [U]

- Wired (live, read this pass): `variant3d/scripts/world3d_fx.gd:182-213` donor blink law comments + `:197-204` `GHOST_KEY_TIME` (0.65625 s @ speed 10) / `GHOST_PERIOD_S` / `GHOST_OK_ALPHA` / `GHOST_BAD_ALPHA` / `GHOST_BAD_EMISSION*` / emission-enabled flags; `:596-597` `GHOST_BLINK_STATUS` (law `[O] unit.script:6674-6805`) and `GHOST_MESH_IDENTITY_STATUS` (explicitly "STRONG INFERENCE, NOT [O]"); `:2538-2561` per-frame alpha/emission drive reads the constants.
- Unproven by the code's own labels: key interpolation + `GetTimeSpeedFactor` runtime values are `[U]-native` (`:194-196`, `:596`); mesh identity has "NO mesh-identity switch" — the derived box dummy "REMAINS the labelled CURRENT transport" (`:1241-1250`, `:597`); `_ghost_swap_building_mesh` (`:1238-1276`) prefers `_ghost_donor` (box dummy) when ready, else the finished-building provider mesh or the `_ghost_mesh` footprint fallback (`:1272-1276`).
- Verdict: **WIRING-UNPROVEN [U]**. Owner condition: `E-GHOST-CAP §7` fixed-camera zero-mismatch capture (mesh id constant ≥120 ghost frames + alpha period/floor/ceiling + emission + scale/offset, per `:1687` meta note) in EACH mode; any mismatch keeps the item `[U]`.

## 5. Mill-sail OBJ on disk, rotor still PNG bake — PRESENT file, PARTIAL wiring [U]

- Present: `variant3d/assets/models/obj/shared/buildings/eurmilanim.obj` + `.mtl` — PRESENT. [V]
- Present (bake): `variant3d/assets/models/tex/shared/buildings/mill_rotor.png` (+`.import`) and `variant3d/assets/models/anim/common/buildings/mill_rotor.png` — PRESENT. [V]
- Not converted (code's own label): `variant3d/scripts/terrain_donor_props.gd:219` `"ROTOR_OSS_AAF": "UNVERIFIED — eurmilanim.oss/.aaf and rusmilanim not converted; baked PNG is PORT APPROX (F07 §3.2)"`; `variant3d/scripts/world3d_entities.gd:592-606` documents donor `eurmilanim.oss` (k=251/fps=30/b=1/v=1098) hub/axis grounding via `_bake_mesh()` with `ROTOR_MOUNT_STATUS` (`:606`) keeping "spin SIGN and the 2D-bake-on-quad stand-in stay PORT APPROX, visual UNVERIFIED"; `:564` "true donor .oss sail remains a follow-up". Globs `variant3d/assets/models/**/*eurmilanim*` return only the derived `.obj/.mtl`; `**/*rusmilanim*` → **no file found**. [V]
- Verdict: **PRESENT file + WIRING-UNPROVEN [U]** (rotor motion). Owner condition: convert `eurmilanim.oss/.aaf` (+ `rusmilanim`) sail animation or document the stand-in; spin-sign + quad-bake capture required.

## 6. FX keys + sheets + scale — WIRING-UNPROVEN [U]

- Wired (live, read this pass): `variant3d/scripts/world3d_fx.gd:145-172` per-key `source.pfx` cites; `:315-430` 24-name `DONOR_FX` table + `DONOR_TIME_LAW`; `:529-560` `buildingsmoke` 4-child + `parentrandom` composition; `:601-604` `DONOR_BOX_OBJ` / `DONOR_RALLY_OBJ` (+ tex paths); `:623-643` `DONOR_FX_SHEETS` (8 sheets with image/frame geometry + `source.pfx`/`material.mat` cites); `:647+` `DONOR_FX_RAND_CODES`; `:609-618` `DONOR_GHOST_SCALE 0.5` / `DONOR_RALLY_SCALE 0.0525` / roll 45 / `ocoTerrainWater`.
- Present sheets: `variant3d/assets/fx/tex/` 11 PNGs (`box/rallypoint/musketsmoke/musketsmokeup/musketflash/musketflashup/musketsparks/cannonflash/bullettrail/firesmoke/firepalette`) + `variant3d/assets/fx/models/box.obj + rallypoint.obj` (+`.mtl`) + `variant3d/assets/fx/manifest.json` — PRESENT. [V]
- Unproven by the code's own labels: `PixelRatio→metres` divisor unrecovered (`:275-277` "PORT APPROXIMATION quads (donor PixelRatio has no recovered metre conversion)", `:292` "unit UNVERIFIED"); `Interval/FrameRate→seconds` native clock `[U]` (`:381` `DONOR_TIME_LAW` "[U] U3-time"); RNG stream/seed `[U]` (`:582` `DONOR_FX_STATUS` "[U] U7"); ghost/rally art `[U]` (`:582` "[U] U14"); rally TTL is a port choice (`:230` `RALLY_TTL 2.0`, "no donor key"); roll SIGN unproven (`:616` "[U]-R").
- Verdict: **WIRING-UNPROVEN [U]**. Owner condition: sheet pixel-identity/tiling proof per sheet + `PixelRatio/Interval` unit-law calibration + seed/stream isolation + rally TTL/pennant captures (`[U]-F/[U]-S/[U]-R`).

## 7. Tool-child node — WIRING-UNPROVEN [U] (node live, texture missing)

- Wired (live, read this pass): `variant3d/scripts/world3d_entities.gd:3297-3341+` `_sync_unit_tool()` creates one `MeshInstance3D` (`"Tool_"+sid+"_"+uid`, `:3303-3310`) per peasant, gates visibility/actorInd through `anim3d.attach_for()` (`:3319-3341`), draws donor verts as points without invented faces/UVs (`:3342-3345`); material path goes through `_get_tool_material()` (`:3264-3287`) whose missing-PNG branch is the labelled fallback (see §1).
- Unproven by the code's own labels: `:326` `TOOL_ATTACH_STATUS` "visual UNVERIFIED"; `:330` `TOOL_U_STATUS` keeps `[U]-T-A` (donor runtime swap trace) and `[U]-T-B` (port 3D tool-mask pixel proof, zero-mismatch) OPEN with fixed-camera close-up captures; child metas carry `visual_status UNVERIFIED` (`:3309`).
- Verdict: **WIRING-UNPROVEN [U]**. Owner condition: land `peaaustools.png` first (§1), then pass `[U]-T-A` donor trace + `[U]-T-B` zero-mismatch tool-mask captures; until then the live child measures fallback shading.

## 8. Stale label `NATION_MESH_BLOCKED_EVIDENCE` — byte-proven correction (NO edit made)

- Exact location: `variant3d/scripts/world3d_entities.gd:249` — full string: `"BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."` [V] read this pass.
- Contradicting disk facts [V] this pass (so the blanket premise is refuted as written):
  - `variant3d/assets/models/obj/bav/land_units/musketeer18bav.obj` (+`.mtl`) and `variant3d/assets/models/obj/bav/buildings/bavcen.obj` (+`.mtl`) — PRESENT (refutes "no bav*" and "musketeer18bav absent").
  - `variant3d/assets/models/obj/ukr/**` — 8 building families + 4 land units observed (first-100 glob entries; e.g. `sta/hou/dip/...` stage sets, `serdiuk/peaukr/hetman/cossackregister`) — PRESENT (refutes "no ukr*").
  - `variant3d/assets/models/obj/tur/land_units/{tatar,spakh,sipahi,jannisary}.obj` — PRESENT (refutes "no tur*").
  - `variant3d/assets/models/obj/swe/land_units/{pikeman18swe,hackapell}.obj` + `obj/swe/buildings/swecen.obj` — PRESENT.
  - `NATION_MESH_BLOCKED_EVIDENCE` also claims "0 rus-keyed and 0 bav-keyed textures" — bav-keyed textures exist on disk per the carried review cite (`tex/bav/land_units/musketeer18bav.png`, `tex/bav/buildings/bavcen.png`); not re-globbed this pass, flagged for the owner lane to confirm.
- Clauses that STAND (confirmed this pass): `chaika` absent (§3); `rusmil`/`turmil` building meshes absent under `assets/models/` (§3); `grenadierbav` — existence not checked this pass (pattern not globbed), left to the manifest owner, no claim made.
- Correction (text only, no source edit): the `:249` string needs re-pointing at the actually-missing items (chaika, rus/tur mills, `grenadierbav` pending owner check, nation stage/ghost art per `NATION_STAGE_GHOST_BLOCKED_STATUS` at `:270`) instead of the blanket "0 nation-keyed OBJs / 0 bav-keyed" premise. **No edit was made here** per task scope; recorded so no lane treats the stale string as a current census.

## 9. Blocking unknowns ledger

| ID | Item | Exact acceptance |
|---|---|---|
| [U]-PEAAUSTOOLS-TEX | `peaaustools.png` missing at `TOOL_MATERIAL_PATH` | §1 condition |
| [U]-T-A / [U]-T-B | Tool-attach donor swap trace + port 3D tool-mask zero-mismatch | §7 condition (`peaaustools.png` first) |
| [U]-G / [U]-R | Ghost blink/mesh identity + rally TTL/pennant | §4 + §6 conditions (`E-GHOST-CAP §7`) |
| [U]-F / [U]-S | FX sheet identity, `PixelRatio/Interval` laws, RNG seed/stream | §6 condition |
| [U]-MILL-SAIL | Sail `.oss/.aaf` conversion, spin sign, quad-bake | §5 condition |
| [U]-NAVAL-TLF | Naval `.tlf`/AAF convert-or-document | §2 condition |
| [U]-NATION-LABEL | Stale `:249` blanket premise re-pointing | §8 condition (owner lane) |
| carried | [U]-G1/G2/G3, [U]-GRASS, [U]-ACT-COVERAGE, [U]-STUB/BURN/EX/14, [U]-W/W2/S/A/R/C1/C2/B | Owned by cited prior reports; unchanged |

## 10. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Blocking_unverified is non-empty (§9). **RESULT IS NOT GOOD** while blocking_unverified is non-empty.
- No parity is claimed. No completeness is declared. §2/§5/§6 PRESENT paths are file-presence evidence only, not correctness, not a gate pass, not donor parity.
- No approximation is made or endorsed in this report; carried approximations are the port files' own labels (`PORT APPROXIMATION — NOT DONOR PARITY`, `visual UNVERIFIED`, `visual_parity_claim:false`), quoted as observed.
- Exactly one file was written: this report. No code, asset, config, shader, test, runner, Godot, git, or donor state was changed.

*End of PORT1TO1-ART-GAPS.*
