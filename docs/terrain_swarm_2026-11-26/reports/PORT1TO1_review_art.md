# PORT1TO1 — REVIEW-ART: read-only completeness review of OBJECTS/ART/AAF (1:1 donor port)

- id: PORT1TO1-REVIEW-ART
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER REVIEW-ART — READ-ONLY completeness review of the OBJECTS/ART/AAF domain (objects, AAF, art, animation, death art, tool attach, nation art)"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_review_art.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_DONOR_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD while blocking_unverified is non-empty. No parity is claimed. No completeness is declared. No approximation is endorsed. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only report/spec line citation carried from landed reports; every port statement is a read-only on-disk observation verified this pass unless marked carried [C]. Nothing here was executed; no donor file was opened, run, or copied; no port byte was changed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git, or donor edit. Read-only: `glob` / `grep` / `read` over `variant3d/scripts/**`, `variant3d/assets/models/**`, `variant3d/assets/fx/**`, plus carried citations from landed reports/spec. Singleplayer skirmish only."
- prior_reports_read:
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md` (194+52 AAF census, 66-skin census at audit time, [U]-G/R/T/B/F/S)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_triggers.md` (T1–T26 trigger map, orphan verdicts, [U]-W/W2/S/A/R/C1/C2/B)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md` (56 attach .oss, attach map §2.1, C1–C5, [U]-T-A/T-B)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md` (12-family death inventory, 48 OSMs, [U]-STUB/-BURN/-EX/-14)
  - `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_assets.md` (the parent audit; NEW-1..NEW-5, P0-1..P0-9)
  - `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_a.md` (G1 count-definition, G2 48-OBJ existence, G3 desert_frt_un correction)
  - `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_b.md` (grass split verdict, 40-action vs T-set difference)
  - `docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md` (three channels, mill-fields-are-decals, rus/tur mills missing)

## 0. How to read this report

- **IMPLEMENTED** = exact port path + label observed on disk this pass. Existence evidence only; never correctness, never parity.
- **PARTIAL** = the port path exists but the cited missing half is exactly named (no fabrication, no value invented).
- **ABSENT** = "no file found" stated literally with the exact searched path/pattern.
- **[C]** = carried from a cited landed report (not re-verified this pass). **[V]** = verified on disk this pass. **[U]** = unresolved, with an exact acceptance condition.
- **Priority rule (as tasked):** anything already listed in `PORT1TO1_terrain_assets.md`, `PORT1TO1_asset_gap_a.md`, or `PORT1TO1_asset_gap_b.md` is cited once in §1 and NOT re-audited in depth. §2–§4 record only what is NEW or CHANGED relative to those three reports. Where nothing new exists in a sub-domain, that is stated plainly.

## 1. Already covered by the three prior reports — not re-audited (citations only)

| # | Item | Governing prior report | This pass |
|---|---|---|---|
| P-1 | 668-vs-680 sections = count-definition difference (680−12=668); [U]-G1 per-name cross-check open | `PORT1TO1_asset_gap_a.md` §1 | Not re-opened; no new evidence taken |
| P-2 | 48/48 derived death OBJs PRESENT (12 stems × 4) + 12/12 script stems; [U]-G2 byte/vert/bbox verification open | `PORT1TO1_asset_gap_a.md` §2 | Existence re-confirmed by glob this pass (§2.1), byte verification still not performed — stays [U]-G2 |
| P-3 | `desert_frt_un` resolved under its own name; `desert_forests_big` naming deferred; [U]-G3 open | `PORT1TO1_asset_gap_a.md` §3 | Not re-opened |
| P-4 | Grass split verdict: tile-block grass IMPLEMENTED, 21 prop-BaseName grass meshes ABSENT with skip (no stub), plantain/bush/fern/reed/flower PARTIAL, winter unwired; [U]-GRASS open | `PORT1TO1_asset_gap_b.md` §1 | Not re-opened |
| P-5 | 40-action vs T-set difference EMPTY both directions at index level; per-sid sparseness is per-cell gaps, never substitution; [U]-ACT-COVERAGE open | `PORT1TO1_asset_gap_b.md` §2 | Not re-opened |
| P-6 | 18-name→40-name skin index growth, 63 tool-skin JSONs (57/66 `attach: None`), T1–T26 table, ACTION_ALIAS bridge, orphan/partial flags | `PORT1TO1_terrain_assets.md` §1.9–1.10 | Re-observed header only (§2.2); no new audit |
| P-7 | Ghost colour/blink + rally TTL/behaviour keys absent from both `.prop` files; [U]-G/[U]-R captures required | `DEC_U_aaf_art_audit.md` §4; `PORT1TO1_terrain_assets.md` P0-5 | Behaviour keys still absent per carried cites; NEW code-side wiring observed — see §3.1 (PARTIAL, not closure) |
| P-8 | Mill fields are script-sown decals (not pattern stamps); fields/mine placement PORT APPROXIMATION; rus/tur mills missing | `spec/08_FIELDS_AND_PROPS.md` §8 | Rus/tur-mill absence re-confirmed (§4.3); no new field audit |
| P-9 | PFX semantics: 52 `aaf/pfx/*.aaf` + `source.pfx` keys carried; world/time scale + seed UNVERIFIED ([U]-F/[U]-S) | `DEC_U_aaf_art_audit.md` §2.4/§4 | FX code constants re-observed (§3.3); no new PFX audit |

## 2. IMPLEMENTED — exact port path + label (existence only, no parity)

All items below were observed on disk this pass ([V]) and are **not enumerated** in the three §1 reports (which record only the donor-side census or the older port state).

### 2.1 Building death art — derived files for all 12 families [V]

- `variant3d/assets/models/buildings/models/eurmil_death1.obj` + `_death2` + `_death1a` + `_death2a` (each with `.mtl` sidecar) — PRESENT.
- Same 4-file death set PRESENT for all 11 remaining stems: `ukrcen/ukrhou/ukrbar/ukrsta/ukrbla/ukraca/ukrart/ukrdip/eursto/eurmar/eurtow` (`*_death1.obj`, `*_death2.obj`, `*_death1a.obj`, `*_death2a.obj` + `.mtl` each) under `variant3d/assets/models/buildings/models/`. Full-directory glob returns the complete 12×4 set; no `no file found` for any family/slot.
- Base/attach pair `variant3d/assets/models/buildings/models/eurmil.obj` + `eurmila.obj` (+`.mtl`) — PRESENT.
- `variant3d/assets/models/buildings/manifest.json` — now carries per-family death rows beyond eurmil (observed: `ukrcen_death1` at `:195-201`, `ukrcen_death2` at `:223-229`, `ukrcen_death1a` at `:251-257`, `ukrcen_death2a` at `:279-285`, `ukrhou_death1` at `:307-313` and continuing in the same pattern). The eurmil-only scope recorded in `DEC_U_death_families.md` P7 and `PORT1TO1_terrain_assets.md` §1.11(c) is therefore **superseded on manifest scope** as well as on script stems (`variant3d/scripts/world3d_entities.gd:375` `BLD_DEATH_STEMS` 12/12 — already recorded in gap_a §2.1).
- Relation to priors: existence was already closed by gap_a G2; the manifest-row expansion (death rows for non-eurmil stems in `buildings/manifest.json`) is NEW relative to all three §1 reports, which never cite non-eurmil manifest rows. Byte/vert/bbox verification per [U]-G2 remains undone — see §5.

### 2.2 Skin index — 40-action union already landed [V]

- `variant3d/assets/models/skin/index.json:1` — `actions_requested` 40 names (`idle…attack2after`), `count 66`, `total_bytes 6514967`, per-entry `donor_oss`/`donor_aaf`/frame lists (e.g. `pearus` entry carries `workfood/workwood/workstone/idlefood/idlewood/idlestone/walkfood/walkwood/walkstone/reaction/prepare0/unprepare0` windows). This supersedes the 8-name `actions_requested` recorded in `DEC_U_aaf_art_audit.md` §1.1 — already noted in `PORT1TO1_terrain_assets.md` §1.9(a); no new audit performed.
- `variant3d/assets/models/skin/attach/*.json` — 63 tool-skin files observed via content grep (sample: `peaukr_pick.json`, `peaukr_lumber.json`, `peapol_axe.json`, `pearus_cart.json`, `peaaus_hammer.json`, each with `donor_bytes`/`donor_sha256`, per-tool `actions` windows, `visual_parity_claim:false`). Already recorded in gap_b §2.1; no new audit performed.

### 2.3 Building stage art — base + stage 1–4 + attach for all mapped families [V]

- `variant3d/assets/models/obj/ukr/buildings/` — full stage sets PRESENT: `cen/hou/dip/bla/bar/art/aca/sta` each with base + `1..4` + `a/1a..4a` OBJs (e.g. `sta.obj`, `sta1.obj`…`sta4.obj`, `staa.obj`, `sta1a.obj`…`sta4a.obj`, each with `.mtl`+`.import`).
- `variant3d/assets/models/obj/shared/buildings/` — `sto/stoa/sto1..4(+a)`, `tow/towa/tow1..4(+a)`, `mil/mil1..4(+a)`, `mila.obj`, `mine_gold/mine_iron/mine_coal.obj`, `wal.obj` — PRESENT (first-100 glob entries; pattern uniform).
- `variant3d/assets/models/obj/swe/buildings/swecen.obj` — PRESENT.
- Relation to priors: the three §1 reports never enumerate these stage OBJ paths (gap_a/b are terrain-side; terrain_assets cites only `BLD_DEATH_STEMS` + death OBJs). Recorded here as IMPLEMENTED-existence so a future manifest audit has the path list. Wiring of stage selection (`_donor_raw_stage` hp-fraction proxy vs donor `iVisual` tag) is carried UNVERIFIED per `DEC_U_death_families.md` §2.3[I] — not re-audited.

### 2.4 Naval hull art — 7 derived static hull OBJs [V]

- `variant3d/assets/models/obj/shared/naval_units/` — `yacht.obj`, `yachttur.obj`, `xebec.obj`, `galley.obj`, `frigate.obj`, `fishboat.obj`, `battleship.obj` (each +`.mtl`+`.import`) — PRESENT.
- `variant3d/assets/models/tex/shared/naval_units/yacht.png`, `yachttur.png` (+`.import`) — PRESENT.
- `variant3d/assets/models/anim/common/naval/yacht_hull.png`, `yacht_walk.png`, `yachttur_hull.png`, `yachttur_walk.png` — PRESENT.
- Relation to priors: `DEC_U_aaf_art_audit.md` §1–§2 records only the donor-side fact (`.osm` hull + `.tlf`, 7 sids skipped, no skin tracks) and `PORT1TO1_terrain_assets.md` §1.9(b) carries the same donor fact. The seven derived port hull OBJs + hull PNGs are NOT enumerated in any of the three §1 reports — recorded here as IMPLEMENTED-existence. Runtime use (static placement, `DONOR_SHIP_*` statuses at `world3d_entities.gd:475-505`) was read but not verified — visual UNVERIFIED, no parity claim.

### 2.5 Mill-sail attach model file [V]

- `variant3d/assets/models/obj/shared/buildings/eurmilanim.obj` + `eurmilanim.mtl` — PRESENT.
- Relation to priors: `DEC_U_aaf_art_audit.md` §2.2 records `eurmilanim.aaf: idle 1..249` as donor fact with "attach conversion is a `convert_models`-class `.osm` job"; `PORT1TO1_terrain_assets.md` §1.11(b) carries "`.osm` job not skin job". Neither cites the derived `eurmilanim.obj` port path — recorded here as IMPLEMENTED-existence. Wiring is NOT implemented — see §3.2 (PARTIAL).

### 2.6 FX ghost/rally derived art + donor-keyed constants [V]

- `variant3d/assets/fx/models/box.obj` + `box.mtl`, `rallypoint.obj` + `rallypoint.mtl` — PRESENT.
- `variant3d/assets/fx/tex/box.png`, `rallypoint.png`, `musketsmoke.png`, `musketsmokeup.png`, `musketflash.png`, `musketflashup.png`, `musketsparks.png`, `cannonflash.png`, `bullettrail.png`, `firesmoke.png`, `firepalette.png` — PRESENT.
- `variant3d/assets/fx/manifest.json` — PRESENT.
- `variant3d/scripts/world3d_fx.gd:601-603` `DONOR_BOX_OBJ` / `DONOR_RALLY_OBJ` constants + `:714-741` `_ghost_mesh` / `_donor_ghost` / `_donor_ghost_mat` nodes + `:1668-1680` donor-texture material bind — PRESENT (code cites `box.osm`/`box.dds`, `rallypoint.osm`/`rallypoint.dds`, scales, and `unit.script:6674-6805` blink law).
- Relation to priors: `PORT1TO1_terrain_assets.md` §1.12(a) records the `assets/fx/` tier as PRESENT but never enumerates these paths; `DEC_U_aaf_art_audit.md` §4 [U]-G/[U]-R records art-present/behaviour-missing against procedural quads. The derived mesh paths + donor-keyed constants post-date that audit — recorded here as IMPLEMENTED-existence. Behaviour proof stays open — see §3.1.

## 3. PARTIAL — port path exists, missing half named exactly

### 3.1 Ghost blink law wired as constants; mesh-identity + runtime proof missing

- IMPLEMENTED half: `variant3d/scripts/world3d_fx.gd:182-213` — donor blink law transcribed as labelled constants: `GHOST_KEY_TIME` (`unit.script:6679` 0.65625 s @ speed 10), `GHOST_PERIOD_S`, `GHOST_OK_ALPHA`/`GHOST_BAD_ALPHA` triples, `GHOST_BAD_EMISSION` rgb, `GHOST_OK_EMISSION_ENABLED=false` / `GHOST_BAD_EMISSION_ENABLED=true`, retired-tint note at `:213`. Status string `:593` states "ghost blink law [O] `unit.script:6674-6805` … no rgb tint on the live path; TTL/pennant [U]-R unresolved".
- Missing half: (a) whether the live `draw_ghost` path (`world3d_fx.gd:1197-1230`) renders the derived `DONOR_BOX_OBJ` mesh or the procedural `_ghost_mesh`/`_ghost_building` quads; (b) runtime proof of mesh identity, blink period/amplitude, and rally TTL/pennant ([U]-G/[U]-R carried from `DEC_U_aaf_art_audit.md` §4, owned by `PORT1TO1_terrain_assets.md` P0-5). No capture exists; parity UNVERIFIED.
- Why NEW: none of the three §1 reports cite the `:182-213` blink constants or the `_donor_ghost` node — `DEC_U_aaf_art_audit.md` §4 predates them (procedural quads only) and terrain_assets §1.12(c) still describes the open behaviour gap without this wiring.

### 3.2 Mill sail: `eurmilanim.obj` on disk, rotor still a PNG bake

- IMPLEMENTED half: §2.5 file + `variant3d/assets/models/tex/shared/buildings/mill_rotor.png` (+`.import`), `variant3d/assets/models/anim/common/buildings/mill_rotor.png`, `variant3d/assets/models/anim/buildings/mill_rotor.json` — PRESENT; hub/axis geometry donor-grounded from `eurmilanim.oss` via `_bake_mesh()` per `world3d_entities.gd:592-606` (`ROTOR_MOUNT_STATUS`, `ROTOR_TEX_PATH` at `:565-572`).
- Missing half: the true donor `.oss` sail animation (`eurmilanim.oss`, k=251/fps=30/b=1/v=1098 per `:592`) and `rusmilanim` are NOT converted — `variant3d/scripts/terrain_donor_props.gd:219` `"ROTOR_OSS_AAF": "UNVERIFIED — eurmilanim.oss/.aaf and rusmilanim not converted; baked PNG is PORT APPROX (F07 §3.2)"`; spin sign + 2D-bake-on-quad stand-in stay PORT APPROX (`world3d_entities.gd:606`). No file found for any `*rusmilanim*` or `*eurmilanim*.oss/.aaf` under `variant3d/` (donor-private names only).
- Why NEW: the three §1 reports record the baked rotor without citing the derived `eurmilanim.obj` path or the `:592-606` mount status.

### 3.3 FX compositions: keys + frame laws wired; sheets unproven, loopers deliberately lifeless

- IMPLEMENTED half: `variant3d/scripts/world3d_fx.gd:145-172` impact-smoke/flash/trail constants with per-key `source.pfx` cites (`PixelRatio`, `EndFrame`, `FrameWidth/Height`, `Interval`, `FrameRate`, `TimeLimit`, `MarkWidth`, `VertLimit`, `Alpha`); `:315-430` 24-name `DONOR_FX` table + `DONOR_TIME_LAW` (`Interval_ms × FrameRate ≈ 1000`); `:529-560` `buildingsmoke` 4-child + `parentrandom` composition; `:407-429` looper life policy ("buildingfire/buildingsmoke have NO life entry — holder lifetime only").
- Missing half: (a) FX texture sheets are the 11 derived PNGs in §2.6 — whether each covers its donor `source.pfx` sheet (pixel identity, tiling, `mirror_u`) is unverified; (b) `PixelRatio→metres` divisor, `Interval/FrameRate→seconds` law, `AlphaTime/Power` curve, ribbon spawn law stay [U]-F (carried, `DEC_U_aaf_art_audit.md` §4); RNG seed/stream isolation stays [U]-S; (c) damage-smoke/burn TTL semantics: port documents ZERO smoke on the death edge + event-driven stop (`world3d_entities.gd:368` `BUILDING_DEATH_STATUS`, `:376-404` smoke/burn/sound statuses, [U]-BURN/[U]-EX/[U]-T open) — static rule only, no runtime proof.
- Why here: behaviour halves already owned by terrain_assets P0-5 / DEC_U [U]-F/S/BURN/EX; the per-key constant wiring + looper policy is NEW detail vs the three §1 reports but does not close any [U].

### 3.4 Tool attach: resolver + 3D child node wired; material texture + runtime proof missing

- IMPLEMENTED half: `variant3d/scripts/anim3d.gd:356-367` (`TOOL_SKIN_SUBDIR`, `ATTACH_ACTOR_INDEX` axe/bag/cart/hammer/hoe/lumber/pick=0..6, `TOOL_ATTACH_STATUS`), `:1378-1486` `attach_for()`; `variant3d/scripts/world3d_entities.gd:310-330` (`TOOL_ACTOR_INDEX`, `TOOL_MATERIAL_PATH`, `TOOL_ATTACH_STATUS`, `TOOL_GAP_STATUS`, `TOOL_U_STATUS`), `:3260-3352` tool-child `MeshInstance3D` create/drive (`_update_tool_child`), `:4256` per-frame drive call. 63 attach JSONs carry per-tool action windows (§2.2). The stale T22 "no `.oss`" note called out in `DEC_U_aaf_art_audit.md` §5 C3 is corrected in-code (`TOOL_ATTACH_CITE` cites `DEC_U_tool_attach.md`).
- Missing half: (a) `TOOL_MATERIAL_PATH` target `res://assets/models/tex/shared/land_units/peaaustools.png` — **no file found** (glob `variant3d/**/peaaustools*` returns nothing; `tex/shared/land_units/` listing contains per-nation `pea*.png` but no `peaaustools.png`) — see §4.1; (b) [U]-T-A (donor runtime swap trace) and [U]-T-B (port 3D tool-mask pixel proof) stay open with zero-mismatch captures (carried from `DEC_U_tool_attach.md` §4, owned by terrain_assets P0-5). Visual UNVERIFIED by the code's own labels.
- Why NEW: the three §1 reports record the 63 JSONs and the T22 refutation but never check the `peaaustools.png` landing path — the dangling material path is first recorded here.

### 3.5 Nation-art status string is STALE against disk (label, not art)

- Stale label: `variant3d/scripts/world3d_entities.gd:249` `NATION_MESH_BLOCKED_EVIDENCE` claims "0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems)" and "0 rus-keyed and 0 bav-keyed textures".
- Contradicting disk facts [V]: `variant3d/assets/models/obj/ukr/**` (8 building families + 4 land units), `obj/tur/land_units/{tatar,spakh,sipahi,jannisary}.obj`, `obj/swe/land_units/{pikeman18swe,hackapell}.obj`, `obj/bav/land_units/musketeer18bav.obj` + `obj/bav/buildings/bavcen.obj`, `tex/bav/land_units/musketeer18bav.png` + `tex/bav/buildings/bavcen.png`, `skin/bav/land_units/musketeer18bav.json` — all PRESENT. The "0 nation-keyed / 0 bav-keyed" premise is therefore refuted as a blanket statement; the label needs re-pointing at the actually-missing items (see §4.3) rather than edited here.
- Not a parity statement; recorded so no lane treats the stale string as a current census.

## 4. ABSENT — "no file found" stated literally

### 4.1 `peaaustools.png` (peasant tool shared material) — no file found [V]

- Searched: glob `variant3d/**/peaaustools*` → **no file found** (any extension, any directory).
- Expected by: `variant3d/scripts/world3d_entities.gd:324` `TOOL_MATERIAL_PATH = "res://assets/models/tex/shared/land_units/peaaustools.png"` (cite `units.mat:18-19 → peaaustools.dds` + `bake_sprites.py:497` approved DDS→PNG path).
- Donor grounding [C]: `D:materials/units/units.mat:18-19` → `peaaustools.dds`, shared by all 8 attach sets (`DEC_U_tool_attach.md` §1.3). The 2D baker already consumes it (`bake_sprites.py:497`); the 3D tex-tree copy the constant points at was never landed.
- Not listed in any of the three §1 reports. Acceptance: land the PNG via the approved converter at exactly the `TOOL_MATERIAL_PATH` location (or re-point the constant through the owning lane — no edit here), with `donor_bytes`/`donor_sha256` recorded; until then every tool-child render falls back to untextured/base material by code path (`_update_tool_child` material-load guard `:3269`) and stays labelled.
- Parity UNVERIFIED; chain 0/6.

### 4.2 Naval transform + animation data — no file found [V]

- Searched: `variant3d/assets/models/**/*tlf*` and `*yacht*.aaf`-class skin entries → **no file found**; `skin/index.json` top-level `skipped` lists the same 7 naval sids (`yacht/yachttur/fishboat/frigate/galley/battleship/xebec`, reason "donor .osm/IDP2 hull (no skin tracks…)") [V].
- Donor grounding [C]: `yacht.aaf` 4× `1..280` + `yacht.actor` (`aamLoop` + `TransformationFrameList=yacht.tlf`) + hull `yacht.osm + yacht1/2/3.osm` (`DEC_U_aaf_art_audit.md` §1/§2.1).
- Not listed in any of the three §1 reports (they record only the skipped-sid list). Acceptance: convert-or-document decision for the `.tlf` rigid-transform list through the owning lane; until then hulls are static meshes by design label and any motion claim stays UNVERIFIED.

### 4.3 Nation-art holes that remain after §3.5 — no file found [V]

- `variant3d/assets/models/**/*chaika*` → **no file found** (Ukrainian chaika absent from manifest+obj — consistent with the carried clause in `NATION_MESH_BLOCKED_EVIDENCE`, which is otherwise stale per §3.5).
- `variant3d/assets/models/**/*rusmil*` / `**/*turmil*` (rus/tur mill buildings) → **no file found** (consistent with `spec/08_FIELDS_AND_PROPS.md` §8 "missing rus/tur mills"; `NATION_MESH_BLOCKED_EVIDENCE` "8 core buildings→ukr*" clause stands for buildings).
- `variant3d/assets/models/**/*grenadierbav*` → existence not checked this pass (pattern not globbed); the carried "grenadierbav absent" clause is therefore neither confirmed nor refuted here — left to the manifest owner, no claim made.
- `eursto/eurtow _deathNa` 660 B stub handling: derived `eursto_death1a/2a.obj` + `eurtow_death1a/2a.obj` are PRESENT (§2.1); whether they converted to honest near-empty meshes (vs substituted geometry or a 1×1×1 cube via the `:3067-3072` AABB guard) is byte-verification work under [U]-STUB/[U]-G2 — not performed here.

## 5. Unknowns ledger (blocking_unverified — nothing closed by this report)

| ID | Item | Exact acceptance (zero-mismatch where applicable) |
|---|---|---|
| [U]-G1 | 12 object-less sections per-name cross-check | Carried from gap_a §1.3; unchanged |
| [U]-G2 | 48 death-OBJ byte/vert/bbox verification + manifest `donor_bytes`/`donor_sha256` rows | Carried from gap_a §2.2; extended: now also covers the §2.1 manifest rows + §4.3 stub-face-count check |
| [U]-G3 | Engine name-normalisation (`n_desert_frt_big1`→`_1`) vs quarantine | Carried from gap_a §3.2; unchanged |
| [U]-GRASS | 21 grass-family prop mesh+material rows + winter path | Carried from gap_b §1.4; unchanged |
| [U]-ACT-COVERAGE | 66×40 action-gap matrix + T6/T7/T23–T25 orphan captures | Carried from gap_b §2.5; unchanged |
| [U]-T-A / [U]-T-B | Tool-attach donor swap trace + port 3D tool-mask pixel proof (0 mismatches) | Carried from `DEC_U_tool_attach.md` §4; extended: §4.1 `peaaustools.png` must land first or the T-B capture measures fallback shading |
| [U]-G / [U]-R | Ghost blink/mesh identity + rally TTL/pennant captures | Carried from `DEC_U_aaf_art_audit.md` §4; narrowed by §3.1 (constants wired, proof still missing) |
| [U]-STUB | sto/tow 660 B stub rendering (skip vs cull vs empty) | Carried from `DEC_U_death_families.md` §4; unchanged |
| [U]-BURN / [U]-EX / [U]-14 | Damage-smoke stop, explosion payload/timing, stage_2/3-at-death selection | Carried from `DEC_U_death_families.md` §5.5; narrowed: port now documents ZERO-smoke-on-death-edge + grenadeexp+expflash + 30/30-as-stage-timers (`world3d_entities.gd:368-404`) — static rule only, captures still required |
| [U]-W/W2/S/A/R/C1/C2/B | Trigger-map weapon/sticky/prepare/reaction/completion/blend captures | Carried from `DEC_U_aaf_triggers.md` §6; unchanged |
| [U]-PEAAUSTOOLS-TEX (new) | `peaaustools.png` missing at `TOOL_MATERIAL_PATH` | §4.1 condition |
| [U]-NATION-LABEL (new) | `NATION_MESH_BLOCKED_EVIDENCE` stale blanket claim | §3.5: owner lane re-points the string at §4.3 items; no art synthesised |

## 6. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | §2.1–§2.6 IMPLEMENTED paths exist on disk as stated (death 48 + eurmil pair, stage sets, 7 hull OBJs + tex, `eurmilanim.obj`, fx box/rallypoint + 11 tex, skin 40-name header + 63 attach JSONs) | [V] this pass (globs + reads cited per item) |
| 2 | §3.1–§3.5 PARTIAL verdicts: implemented half path + exact missing half, no value invented | [V] port paths + [C] donor facts |
| 3 | §4.1–§4.3 ABSENT verdicts: literal "no file found" on the stated patterns | [V] this pass |
| 4 | §1 P-1..P-9 already-listed items were not re-audited; their [U]s stay owned by the cited reports | [D] over cited reports |
| 5 | `NATION_MESH_BLOCKED_EVIDENCE` blanket "0 nation-keyed / 0 bav-keyed" premise is contradicted by §3.5 disk paths; chaika/rus-tur-mill absences stand | [V] vs `world3d_entities.gd:249` |
| 6 | The stale T22 "tool prop has no `.oss`" premise stays refuted (56 attach `.oss` per `DEC_U_tool_attach.md` §1; 63 derived attach JSONs on disk); `anim3d.gd` carries the corrected cite | [C] + [V] |
| 7 | Any port visual equalling donor motion/colour/FX/timing, or any trigger/coverage claim beyond the cited paths | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |
| 8 | No mesh, texture, value, or mapping was fabricated, renamed, or declared complete in this report | [D] this report |

## 7. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Blocking_unverified is non-empty (§5: [U]-G1/G2/G3, [U]-GRASS, [U]-ACT-COVERAGE, [U]-T-A/T-B, [U]-G/R, [U]-STUB/BURN/EX/14, [U]-W/W2/S/A/R/C1/C2/B, plus new [U]-PEAAUSTOOLS-TEX and [U]-NATION-LABEL). **RESULT IS NOT GOOD** while blocking_unverified is non-empty.
- No completeness is declared: §2 existence paths are file-presence evidence only, not correctness, not a gate pass, not donor parity.
- No parity is claimed. No approximation is made or endorsed in this report; carried approximations are the port files' own labels (`PORT APPROXIMATION — NOT DONOR PARITY`, `visual UNVERIFIED`, `visual_parity_claim:false`), quoted as observed.
- Exactly one file was written: this report. No code, asset, config, shader, test, runner, Godot, git, or donor state was changed.

*End of PORT1TO1-REVIEW-ART.*
