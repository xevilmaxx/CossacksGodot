# SPEC — donor-faithful terrain (assembled; point-in-time status read 2026-11-26)

This folder holds the **cited specification** that the fresh variant3d terrain
module implements. It is assembled by COORD from the 31 worker reports, not
written from memory. Every statement must carry a donor path:offset:line or a
Craft Anything evidence id, and a label:

`[O]` observed · `[D]` derived · `[I]` inferred · `[U]` UNVERIFIED · `PORT APPROXIMATION`

No donor-parity claim without a real donor GPU A/B frame.

**Verified READY (point-in-time):** all 15 section files §00–§14 were listed twice
and their headers/content read on **2026-11-26** (V73 read). Every row below is
**READY** as an assembled, cited *spec document on disk* — READY does **not** mean
an executable gate PASS, a validated conversion, or donor parity. V26/V37/V43/V47/
V56 notes are themselves point-in-time. **Re-verify before gating.** No gate was
run and no donor GPU A/B frame exists; parity remains `UNVERIFIED`.

## Sections (filesystem-authoritative, 2026-11-26)

| § / File | Content | Source workers | Status |
|---|---|---|---|
| §00 `00_EVIDENCE_INDEX.md` | every evidence id / donor path used, with what it proves | X14 + all | **READY** (`:9` "56 landed reports" snapshot is point-in-time) |
| §01 `01_WORLD_DATA_MODEL.md` | per-cell fields, grid sizes, coordinate conventions, dump contract | A01 + D04 | **READY** |
| §02 `02_SEED_AND_RNG.md` | keys, RNG state update, call-order discipline | D02 + X03 | **READY** |
| §03 `03_MASK_TO_HEIGHT.md` | TGA decode, channels, blur/smoothing, relief formula, thresholds | D03 + F04 + X18/X19 + A02/X03 | **READY** (header still stale on disk — see replacements below) |
| §04 `04_PATTERN_STAMPING.md` | `.pattern`/`pattern.lib` records, blend modes, scale/min/max, family selection | D05 + F01/F02 + A02 + X12/X13 | **READY** (header still stale on disk) |
| §05 `05_WATER_SHORE.md` | water level, shore smoothing, wave binding, tile selection | D06 + F06 + A02 | **READY** |
| §06 `06_TILE_AND_ATLAS.md` | tile ids, smoothing rules, detail pass, block/atlas mapping | D08 + F03 + F05/F06 + X06/X08/X17 | **READY** (alphanull mapping is a labelled PORT APPROXIMATION, V47-05) |
| §07 `07_RESOURCES.md` | mines, stone, forests, starting resources, keep-clear zones, owner fill | D07 + F08 + A02/X03 + V12/X09 | **READY** (header still stale on disk) |
| §08 `08_FIELDS_AND_PROPS.md` | mill fields, pumps, decor, relief prop silhouettes | A04 + F07/F08 + V07 + X22 | **READY** (header still stale on disk) |
| §09 `09_EDITOR_PARAMETERS.md` | editor UI → cfg parameter map and generation commands | F03 + D09 + F09 | **READY** (19 flat keys, not 20 — V37/V47-38) |
| §10 `10_STAGE_ORDER.md` | the ordered generation pipeline with inputs/outputs and telemetry | A02 | **READY** (A02's `[U]` constants carried forward, not silently resolved) |
| §11 `11_ASSET_CONVERSION.md` | donor → runtime compiler inputs/outputs, provenance manifest, licence guard | A03 + P02 + P04 | **READY** |
| §12 `12_QA_AND_INTEGRATION.md` | gates, determinism, A/B protocol, backend switch, rollback | A05 + A06 + P03 | **READY** (A05 integrated into §12.6; gate *values* still `TODO(COORD)` — no gate PASS) |
| §13 `13_PRIOR_WAVE_MEMORY.md` | prior-wave root causes, rejected approaches, confirmed mechanisms | P06 + V03 | **READY** |
| §14 `14_CURRENT_PIPELINE.md` | current legacy variant3d pipeline trace | P01 + V05 | **READY** (describes legacy path; no new-module acceptance) |
| (non-section) `terrain_qa_spec.json` | QA bands (schema only) | I13 / COORD | **FILE PRESENT — SCHEMA-ONLY / UNPOPULATED** (not READY, not a gate result) |

## Six section headers still stale on disk — authoritative replacements

V73 was authorized to edit **this README only**; the six section files below still
carry the stale "pending / to be appended" prose at the V73 read (V56 E4 / D-03,
re-confirmed by a second grep pass). The replacement text below is authoritative
and paste-ready for COORD; until applied, this table overrides those headers. The
paste itself promotes nothing to a gate PASS or donor-parity claim.

| File:line | Stale text still on disk | Authoritative replacement (COORD to apply) |
|---|---|---|
| `03_MASK_TO_HEIGHT.md:1,5` | `# 03 — Mask → height (from F04 + A02/X03; D03/X19 pending)`; "D03 … has not landed" | `# 03 — Mask → height (from D03 + F04 + X18/X19 + A02/X03; all landed)`; "D03, F04, X18 and X19 have all landed; see §5." |
| `04_PATTERN_STAMPING.md:1` | `# 04 — Pattern stamping (from F02 + A02; F01/D05 pending)` | `# 04 — Pattern stamping (from F02 + A02 + F01 + D05 + X12/X13; all landed)` |
| `06_TILE_AND_ATLAS.md:1` | `# 06 — Tile ids and atlas (from F05; D08/F03/F06 pending)` | `# 06 — Tile ids and atlas (from F05 + F06 + D08 + X06/X08/X17; F10 landed)` |
| `07_RESOURCES.md:1` | `# 07 — Resource placement (from D07 + A02/X03; V12/X09 pending)` | `# 07 — Resource placement (from D07 + A02/X03 + V12 + X09; all landed)` |
| `08_FIELDS_AND_PROPS.md:1` | `# 08 — Fields and landscape props (from A04; F07/V07 pending)` | `# 08 — Fields and landscape props (from A04 + F07/F08 + V07 + X22; all landed)` |
| `12_QA_AND_INTEGRATION.md:1,4-5` | `# 12 — QA and integration (from A06; A05 to be appended)`; "will be merged … once its worker finishes" | `# 12 — QA and integration (from A05 + A06; integrated)`; "A05's harness is merged into §12.6; V21 gate register is the executable companion." |

Every report named above was re-globbed and exists on disk at this read (D03, X19,
F04, F01, D05, F02, D08, F03, F06, F05, V12, X09, D07, F08, F07, V07, X22,
X06/X08/X17, F10, A05, A06, X12/X13); "landed" = file presence only.

## Contradiction register (canonical pointer + authoritative outcomes)

The single canonical register is **`reports/V47_final_contradictions.md` (LANDED)**:
V47 §3 holds 43 deduplicated rows (33 RESOLVED / 4 PRESERVED DONOR CONTRADICTION /
2 IMPLEMENTATION DECISION / 4 UNVERIFIED) and V47 §5 holds the 19 genuinely OPEN
items O-A…O-S with named owners. **V47-06** declares V47 canonical; all earlier
registers are historical. `reports/V26_spec_conflicts_resolved.md` §2–§5 is the
paste-ready patch log for V17's four material conflicts;
`reports/V37_minor_conflicts.md` §0–§5 holds the three minor decisions;
`reports/V16_contradiction_register.md` §2/§4 and `reports/V27_unverified_owners.md`
§4.2 are the historical/owner appendices; `reports/V21_gate_register.md` is the
executable gate map. The old C1–C9 board table is a navigation index only. No
worker edits another worker's file — COORD integrates. No gate PASS or donor
parity claim follows from any row below.

| # | Conflicting claims | Workers | Authoritative outcome | Evidence |
|---|---|---|---|---|
| C1 | One-file vs two-file backend seam; "seam unapplied" | A06/P01/V26/V43 | **RESOLVED** — two files only (`main.gd` + `world3d.gd`), one COORD owner, default `"legacy"`, applied once in working tree; never re-apply; re-read status/hashes before dispatch. Permanent "clean/unapplied" claim stays `[U]`. | V26 §2/C4; V43 live note (`spec/12:24`, `spec/13:36`, `spec/14:35`); V47-01/V47-18 |
| C2 | `TileSmoothPasses=6` (cfg) vs `SmoothTileMap(...,3)` (script) | C2/V16-02 | **PRESERVED DONOR CONTRADICTION** — use **3** for skirmish; carry `6` as documented editor anomaly; runtime consumption of `6` is `[U]`. Do not "fix" either literal. | `globalparams.cfg:9`, `smoothtiles.inc:237`; V47-02 |
| C3 | cfg `tilesmooth.cfg` vs script `tilesmooth_scripts.cfg` | C3/V16-03 | **PRESERVED DONOR CONTRADICTION** — port the weighted script table; keep the plain table as editor-only data; never merge them. | `globalparams.cfg:10`, `smoothtiles.inc:5`; V47-03 |
| C4 | `m_swamp_12_old` 17×20 (lib) vs 18×23 (binary) | C4/V16-04 | **PRESERVED DONOR CONTRADICTION** — binary 18×23 is geometry authority; quarantine with a warning; never abort the 680-record parse. | `pattern.lib:905525-905526`; binary header `18,23`; V47-04 |
| C5 | Port "8 constant-zero ids" vs donor `alphanull` 86/110/123 | C5/V16-05 | **PRESERVED DONOR CONTRADICTION** — keep the two id sets distinct; prefer `alphanull` semantics; label the port guard `PORT APPROXIMATION`. | `tiles.mat:346-359`, `presets_summer.json`; V47-05 |
| C6 / meta | Four-plus competing registers; OPEN count and C9 disagreed | V34/V16/V26/board | **IMPLEMENTATION DECISION** — V47 is the single canonical register (43 rows, 19 named OPEN items in §5); board "4 OPEN" and V16 "14 OPEN" are point-in-time snapshots. | V47-06, V47 §5; V34 §0 item 5 |
| C7 | A02 "small/large" vs `mapsize>2` = 256-cell tiny map | C7/V26-C2 | **RESOLVED** — use the enum `0→320, 1→480, 2→640, 3→256`; never the `// tiny` comment; ring 2 zero `dst` reproduced with a trace flag. | `donewgame.inc:42-46`; V47-07 |
| C8 | 5 `mix64` re-seeds vs 11+3 identity re-seeds | C8/V16-08 | **RESOLVED** — re-seed verbatim same `randkey1`; no per-stage key mixing; `RandomExt` internals stay `[U]` (OPEN O-G). | `initmapgen.inc:99,146`; V47-08/V47-40 |
| C9 | "R=class, G=forest" (authored intent) vs shipped R/G=0 except white starts | C9/V16-22/V26-C3 | **RESOLVED** (authored-intent vs shipped-pixel layer distinction; board/V16 OPEN is stale) — `h=−1.1·B/255`; never map R→height on shipped masks; raw R stored `ENGINE/UNVERIFIED`. | F04/D03/X18/X19; `generatemap.inc:537-547`; V26 §4; V47-09 |
| X1 / stamp | A02/X13 `clamp(...,Min,Max)` / `Replace=base_h+g+Offset` vs decoded three-branch stamp | V17/V26/X12/X13/X26 | **RESOLVED** — RFW/Replace/Smooth formulas authoritative, `Min` pivot, `Max` unused, **no `[Min,Max]` clamp**; in-place post-pass (`sub_755db4`), not double-buffer. Row-sign/global-clamp/x87 residue stays `[U]` (O-I). | `cossacks.exe:0x755f30`, x87 `0x756607–0x7566d2`; V26 §2; V47-22/23/24 |
| X2 / fields | A02 "food rects in `SetupStartingResources`" vs D07/V12 | V17/V26/V12 | **RESOLVED** — **zero** food rects; fields are 7×7=49-node runtime sow (`_unit_DoSeedWheat`); no invented field stage. | `dogenerate.inc:720-977`, `unit.script:6470-6570`; V26; V47-34 |
| V37 #1 | F03 "20 flat keys" vs 19 observed | F03/X20/V37 | **RESOLVED** — exactly **19** keys; C01=19; F03 summary "20" is an error; never invent a 20th key. | `globalparams.cfg:2-20`; `decode_donor_cfg.py:437`; V37 §1; V47-38 |
| V37 #2 | Shader name `terrain_donor.gdshader` vs canonical `terrain_donor_shader.gdshader` | I10/V11/V37 | **RESOLVED** — canonical `variant3d/shaders/terrain_donor_shader.gdshader` is present; old alias absent; composer `terrain_donor_world.gd` now exists (V43/V47 point-in-time). | V37 D2; V47-18; V43 note `spec/14:35` |
| V37 #3 | X13 grid offsets `1000/1912/2866` vs F01 `G=8+(w−1)(h−1)` | X13/F01/V37/X26 | **RESOLVED** — F01 offsets `968/1864/2798` authoritative (size closure 710/710); X13 bit vectors are shifted-window artifacts; regenerate before using them as a spatial gate. X23 absent — no X23 value invented (O-P). | V37 P6/P7; X26 S3/S5; V47-39 |
| Gate claim | "All gates green" vs stale green JSONs | V16-21/V03/V47 | **RESOLVED (stale, not fabricated)** — no PASS for today's tree; fresh unique-id baseline is OPEN O-D; no threshold lowered, no assertion deleted. | stale JSON mtimes 2026-11-25; V21; V47-29 |

## Out-of-scope register

| Feature | Reason deferred | Source |
|---|---|---|
| Missions / campaigns / network | D-12 singleplayer skirmish only | variant3d charter |
| Spring/Autumn seasons | DLC/mod, not vanilla skirmish (verify in F10) | RC_TERRAIN S8 |
| Donor skinned-rig visual parity | bone parents unreadable (V72) | V72 report |

*V73 point-in-time edit (2026-11-26): only this README was written; statuses were
read from the section files on disk, not from stale report prose. No gate result,
no donor parity and no green gate is claimed. Re-verify before gating.*
