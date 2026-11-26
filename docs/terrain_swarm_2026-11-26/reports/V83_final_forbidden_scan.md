---
id: V83
ticket: "TERRAIN-SWARM-2026-11-26 / V83 — final forbidden-construct scan of the implementation tree"
owner: "V83 (read-only verification subagent, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_ACCESS
owner_file: "docs/terrain_swarm_2026-11-26/reports/V83_final_forbidden_scan.md"
files_created: ["docs/terrain_swarm_2026-11-26/reports/V83_final_forbidden_scan.md"]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
scope: "Read CHARTER.md, SWARM_BOARD.md, reports/V33_do_not_do_checklist.md, reports/V44_code_review_r3.md, reports/V58_i07_audit.md. Two read-only PowerShell scanners (V33 §4 top-8 verbatim + a 5-pattern expansion) over the COORD-mandated 13-file set; every suspicious hit re-verified with a second instrument (fresh Select-String/grep plus a targeted re-read of line + context). Read-only grep of generated JSON under variant3d/assets/terrain_new for absolute donor paths."
parity_guard: "No donor binary was executed or copied; no Godot job, gate, capture, source, shader, config, asset, test or git state was touched. No donor GPU A/B frame exists (CHARTER.md:43-44,125). NO DONOR PARITY CLAIM is made anywhere in this report; parity stays UNVERIFIED."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
gate_verdict: "NO-GO — see §9"
---

# V83 — final forbidden-construct scan

## 0. Executive summary

1. **[O]** V33's §4 top-8 scanner, re-run verbatim over the 13-file final set, returns **`FILES=13 HITS=7`**. An expanded scan for the remaining mandated patterns returns **`FILES=13 HITS=36`**. Every hit in both scans is re-read with a second instrument and classified below.
2. **[O]** **13 of the 14 requested patterns are clean at this scan**: zero executable `mix64`, `DONOR_UNITS=160` scaling, `B>58` off-by-one, 6-pass smoothing, 3×3 kernel, heightmap-as-albedo, `rgb*a` multiply, non-1.0 `HEIGHT_SCALE`, face promotion, synthetic noise/dither, food rects, unjustified invented constants, or parity claim. All hits for those patterns are **BENIGN DOC/TELEMETRY** or **FALSE POSITIVE** (§3–§5). This corroborates V44 §2 P10 and V44 §4 R3-8 at the current tree.
3. **[O]** **One pattern is LIVE: absolute donor paths in generated JSON.** Source emit sites `decode_donor_cfg.py:673` (`"game_root": game_root`), `decode_donor_pattern.py:944` (`"donor_root": str(game_root)`), `decode_pattern_lib.py:1041` (`"game": game`) write the resolved absolute install root into emitted JSON. Generated files on disk confirm it: `cfg/manifest.json:235,242,255,…,369`, `cfg/constants.json:9,…,581`, and per-pattern JSON `source` fields (e.g. `patterns/desert_frt_big1.json:6965`). This is the already-landed **V28 F-07 / MINOR — OPEN** finding (V28 `:159`, V38 `:164`, V49 `:23,78`, V62 C4 `:128`). **[D]** It is a live, unfixed compliance defect, not a docstring or a telemetry false positive.
4. **[D]** **Single gate verdict: NO-GO** (§9), solely because of item 3. If COORD formally rules V28 F-07 out of this gate's scope (it is a JSON-hygiene defect, not a terrain-generation anti-pattern), the remaining 19-pattern V33 set is clean; as the gate was scoped to this task — which explicitly includes "absolute donor paths in generated JSON" — the honest answer is NO-GO.
5. **[U]** Line numbers drifted during this ticket (e.g. `terrain_donor_gen.gd` `mine_band_units` moved `:726 → :741`; `stats()` key `:523 → :538`; `_stage_begin` assignments `:642 → :657`). All numbers below are from the **final** scan; re-read before acting. **No gate PASS and no parity claim follow from a token scan.**

---

## 1. Method and pass register (CHARTER.md:85–93 directive)

| # | Instrument | Result / effect |
|---|---|---|
| P1 | `Get-ChildItem` over the six mandated globs | 13 files enumerated: 4 `decode_*.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`, 5 `terrain_donor_*.gd`, `terrain_donor_shader.gdshader`, `t_terrain_donor.gd` (§2). |
| P2 | V33 §4 top-8 PowerShell scanner, verbatim regexes, skips `^#`/`^//` lines | `FILES=13 HITS=7` (§3). |
| P3 | Expanded scanner: `mix64/stable_hash/stage_key`, food rects, heightmap-as-albedo/`mask_to_alpha`, suspicious constants (`160/2.7/2.4/0.03/+180/1.6981`), absolute donor paths | `FILES=13 HITS=36` (§4). |
| P4 | Second instrument per suspicious hit: fresh `grep`/`Select-String` + targeted `read` of the line **and surrounding function** | All classifications in §3/§4; two apparent blockers overturned (§0 item 2 and §6.2). |
| P5 | Read-only `grep` over `variant3d/assets/terrain_new/**/*.json` for `C:\Games`/`Cossacks 3` | Confirmed absolute donor paths in generated JSON (§6). |
| P6 | Cross-check against landed reports V28 F-07, V38 N1/N5, V49, V62 C4, V44 R3-8, V58 item 8 | Confirms the absolute-path finding is a known, still-OPEN MINOR; confirms the scan-clean verdict for the other 13 patterns. |

**[O] No suspicious hit was accepted after a single reading.** The two potential blockers — props `DONOR_UNITS` (V33's old live hit) and `_current_stage_key` ("stage_key" ≈ mix64) — were each overturned by a second instrument and are explicitly **not** reported as defects.

### 1.1 Files scanned (exact set, no backups or docs prose)

`variant3d/tools/decode_donor_cfg.py`, `decode_donor_masks.py`, `decode_donor_pattern.py`, `decode_pattern_lib.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`; `variant3d/scripts/terrain_donor_data.gd`, `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor_props.gd`, `terrain_donor_world.gd`; `variant3d/shaders/terrain_donor_shader.gdshader`; `variant3d/tests/t_terrain_donor.gd`.

---

## 2. V33 §4 top-8 scan — full output and classification

Verbatim scanner output (final run, filenames shortened for readability):

```
terrain_donor_gen.gd:741: [P4_donor_units] _tel["mine_band_units"] = "MAP CELLS 1:1 (V08:155-190) — no DONOR_UNITS scaling"
terrain_donor_props.gd:467: [P4_donor_units] "unit": "MAP CELLS 1:1 — no DONOR_UNITS=160 multiplier (V08 C1)",
terrain_donor_props.gd:478: [P4_donor_units] "no_donor_units_multiplier": true,
terrain_donor_props.gd:578: [P4_donor_units] "pattern_index", "note", "donor_units"]:
t_terrain_donor.gd:757: [P1_noise_dither] "CHARTER §4 (no synthetic noise/dither S-25-09); spec/10:60; V21 GR-A21")
decode_donor_cfg.py:23: [P7_smooth_6_3x3] never "fixed": TileSmoothPasses=6 vs script SmoothTileMap(...,3), and
decode_donor_masks.py:14: [P5_B_gt_58] and the two manifest bugs in the legacy tool (B>58 off-by-one; starts
FILES=13 HITS=7
```

| # | file:line | Pattern | Classification | Second-instrument reason |
|---|---|---|---|---|
| T1 | `terrain_donor_gen.gd:741` | P4 `DONOR_UNITS` | **BENIGN TELEMETRY** | Re-read `:720–741`: inside `_resolve_settings`; `_tel["mine_band_units"]` is a string literal asserting 1:1 cells. Header `:57` explicitly refutes `DONOR_UNITS=160`. No arithmetic. |
| T2 | `terrain_donor_props.gd:467` | P4 | **BENIGN TELEMETRY** | Re-read `:464–469`: `mine_recipe.unit` label in `telemetry()`. States "no DONOR_UNITS=160 multiplier". |
| T3 | `terrain_donor_props.gd:478` | P4 | **BENIGN TELEMETRY** | Re-read `:474–481`: `scale_contract.no_donor_units_multiplier = true` flag. No scaling op anywhere in file. |
| T4 | `terrain_donor_props.gd:578` | P4 | **FALSE POSITIVE** | Re-read `:570–585`: a **field-name skip-list** (`"pattern_index", "note", "donor_units"`) for parsing the I03 feed. Fresh `grep` of whole file finds `DONOR_UNITS` only at comments `:24,:88,:634` and strings `:467,:478`; **no `const DONOR_UNITS`, no `cell_scale`, no `/160`** — V33's old live hits at `:76/:608` are gone (V44 P3/P4, R3-3 PASS). |
| T5 | `t_terrain_donor.gd:757` | P1 dither | **FALSE POSITIVE** | Re-read `:745–757`: a **gate description string** passed to `check("no_synthetic_noise_field", synth_hits.is_empty(), …)`; the loop at `:752–754` *detects* `SYNTHESIS_TOKENS` and FAILS on them. The word appears only as the test's rationale. |
| T6 | `decode_donor_cfg.py:23` | P7 6-pass | **BENIGN DOC** | Re-read `:8–25`: triple-quoted module docstring preserving the C2 contradiction (`TileSmoothPasses=6` vs `SmoothTileMap(...,3)`) "never fixed". Deleting it would destroy the contradiction record (V33 §5.4). |
| T7 | `decode_donor_masks.py:14` | P5 `B>58` | **BENIGN DOC** | Re-read `:5–19`: docstring describing the *legacy tool's* `B>58` off-by-one which this tool "does NOT repeat". Live code uses `B>=58` / `==58` only (`:58,:259,:388,:533`). |

**No executable hit** for P1/P2/P3/P6/P8. This is a static observation, not a gate PASS.

---

## 3. Expanded scan — full output and classification

```
terrain_donor_data.gd:45: [D11_const_susp] const PORT_DEBUG_ALIASES := [160, 64, 240]
terrain_donor_data.gd:46: [D11_const_susp] const ALLOWED_SIZES := [256, 320, 480, 640, 160, 64, 240]
terrain_donor_gen.gd:163: [D11_const_susp] const C_CLIFF_ABS_HIGH: float = 2.7         # texturemap.inc:594; X03:603-604
terrain_donor_gen.gd:164: [D11_const_susp] const C_CLIFF_ABS_MID: float = 2.4          # texturemap.inc:597; X03:605-606
terrain_donor_gen.gd:175: [D11_const_susp] const TILE_ID_ROCK8: int = 24               # F05 §3:160; X28:47
terrain_donor_gen.gd:203: [D11_const_susp] const C_SCANGRID_SIZE: int = 160            # 640/4, dmscript.global:55-59; V12:226
terrain_donor_gen.gd:394: [D13_mix64] var _current_stage_key: String = ""
terrain_donor_gen.gd:538: [D13_mix64] out["stage_keyed_draw_ledger"] = _draw_ledger.duplicate(true)
terrain_donor_gen.gd:613: [D11_const_susp] "step_cells": 1.6981,            # unit.script field lattice step; X22:60
terrain_donor_gen.gd:657: [D13_mix64] _current_stage_key = _ledger_key(site, int(_gen.get("version", 0)), _active_rng)
terrain_donor_gen.gd:658: [D13_mix64] _draw_ledger[_current_stage_key] = {
terrain_donor_gen.gd:689: [D13_mix64] if _current_stage_key == "" or not _draw_ledger.has(_current_stage_key):
terrain_donor_gen.gd:691: [D13_mix64] var entry: Dictionary = _draw_ledger[_current_stage_key]
terrain_donor_gen.gd:1251: [D11_const_susp] var pre: float = float(a["pre"])         # NO +180 (cliff is in the else)
terrain_donor_gen.gd:1687: [D19_food_rects] _note("No food rects in SetupStartingResources (X22 X-C6); C3 placement dead text", "notes")
terrain_donor_mesh.gd:516: [D06_height_albedo] + "fallback; albedo multiply disabled (mask_to_alpha=0) but ALPHA=1.0 is "
terrain_donor_mesh.gd:544: [D06_height_albedo] "mask_to_alpha": 0.0,
terrain_donor_props.gd:107: [D11_const_susp] const FIELD_STEP_CELLS: float = 1.6981              # donor data/scripts/lib/unit.script:6480 (size); CELLS not metres (V08 C1)
terrain_donor_props.gd:438: [DONOR_ABS_PATH] "donor_root": "C:\\Games\\Cossacks 3 (READ ONLY; no binary run/copy)",
terrain_donor_props.gd:467: [D11_const_susp] "unit": "MAP CELLS 1:1 — no DONOR_UNITS=160 multiplier (V08 C1)",
terrain_donor_world.gd:51: [D11_const_susp] const ROCK8_H: float = 2.7               # texturemap.inc:433-447,557-611 (|h|>2.7 -> rock8)
terrain_donor_world.gd:52: [D11_const_susp] const ROCK4_H: float = 2.4               # texturemap.inc:433-447,557-611 (>2.4 -> rock4)
terrain_donor_world.gd:56: [D11_const_susp] const FIELD_STEP_CELLS: float = 1.6981   # unit.script:6468-6570 (F07 A8 mill-sown fields)
t_terrain_donor.gd:75: [D11_const_susp] const PORT_ALIASES := [64, 160, 240]        # port debug aliases, terrain_donor_data.gd:43-45 (not donor mapsizes)
t_terrain_donor.gd:76: [D11_const_susp] const ALLOWED_SIZES := [256, 320, 480, 640, 160, 64, 240]
t_terrain_donor.gd:754: [D11_const_susp] synth_hits.append(str(p) + ": " + t.substr(0, 160))
build_terrain_new_atlas.py:81: [DONOR_ABS_PATH] DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
decode_donor_cfg.py:785: [DONOR_ABS_PATH] ap.add_argument("--game", default=r"C:\Games\Cossacks 3",
decode_donor_cfg.py:786: [DONOR_ABS_PATH] help="donor install root, read only (default: C:\\Games\\Cossacks 3)")
decode_donor_masks.py:45: [DONOR_ABS_PATH] DEFAULT_GAME = os.environ.get("COSSACKS3_DIR", r"C:\Games\Cossacks 3")
decode_donor_masks.py:578: [DONOR_ABS_PATH] help="donor install folder (default: $COSSACKS3_DIR or C:/Games/Cossacks 3)")
decode_donor_pattern.py:62: [DONOR_ABS_PATH] python variant3d/tools/decode_donor_pattern.py --game "C:\\Games\\Cossacks 3" \
decode_donor_pattern.py:88: [DONOR_ABS_PATH] DEFAULT_GAME = Path(r"C:\Games\Cossacks 3")
decode_pattern_lib.py:49: [DONOR_ABS_PATH] DEFAULT_GAME = r"C:\Games\Cossacks 3"
terrain_qa_harness.py:124: [D11_const_susp] ("GR-A15", "A", ("D-3",), "V12-G11 FillOwnerMap 160^2 wavefront", ("EV05",), ("O",)),
terrain_qa_harness.py:757: [D19_food_rects] "GR-A13": "requires res[].t attribution to SetupStartingResources",
FILES=13 HITS=36
```

### 3.1 Classification of expanded hits

| Cluster (file:line) | Classification | Second-instrument reason |
|---|---|---|
| `terrain_donor_gen.gd:394,538,657,658,689,691` (`stage_key`) | **FALSE POSITIVE — not mix64** | Fresh grep: `_ledger_key` at `:683–684` is `return "%s|v%d|%s" % [site, ver, st.stream_name]` — a plain diagnostic dictionary key, **no hashing/mixing**. Reseeds at `:648` `reseed_from_key64(k0,k1)` and `:655` `reseed_from_key(k1)` are identity re-seeds (X21), key0 ledger-only. No `mix64`/`stable_hash` token exists in any of the 13 files. V01:145 / SWARM_BOARD C8 / V44 R3-4 agree. |
| `terrain_donor_gen.gd:163–164` (`2.7`/`2.4`) | **BENIGN — donor-cited art gate** | Re-read `:1212–1223`: `_cliff_tile_name` uses `absf(h)` only as **art gates** returning tile names `"rock8"/"rock4"`, comment `:1214` "ART GATES, never a height substitute (spec/05 §4)". No face/UV2 promotion, no height write; V58 item 8 PASS. Citations `texturemap.inc:594/597`. |
| `terrain_donor_world.gd:51–52` (`ROCK8_H`/`ROCK4_H`) | **FALSE POSITIVE — citation dictionary only** | Fresh grep: the constants occur at `:313–314` only, inside a `donor_constants` label/value table (`{"value":ROCK8_H,"cite":"texturemap.inc:..."}`). No `_relief_face_at`, no threshold comparison, no promotion call. |
| `terrain_donor_gen.gd:203` (`C_SCANGRID_SIZE=160`) | **BENIGN — donor-cited, different meaning** | Re-read `:203` comment `640/4, dmscript.global:55-59; V12:226`; used at `:2046,:2106–2107` as a **160×160 owner scan grid**, not a `W/160` distance scale. Not D14. |
| `terrain_donor_data.gd:45–46`, `t_terrain_donor.gd:75–76` (`160,64,240`) | **BENIGN — labelled port debug aliases** | `PORT_DEBUG_ALIASES` / `PORT_ALIASES` are explicitly "port debug aliases … not donor mapsizes" (test `:75`); `DONOR_SIZES` is separately `[256,320,480,640]`. No unit scaling. |
| `terrain_donor_gen.gd:175` (`TILE_ID_ROCK8 = 24`) | **FALSE POSITIVE — regex matched the citation** | The `160` hit is in the trailing comment `F05 §3:160` (a report line number), not the value `24`. Tile id `24` is donor-cited `F05 §3:160; X28:47`. |
| `terrain_donor_gen.gd:1251` (`NO +180`) | **FALSE POSITIVE — negated assertion in trailing comment** | Line is `var pre: float = float(a["pre"])  # NO +180 (cliff is in the else)`. The code deliberately omits the `+180` shift (X28 §3.4). |
| `terrain_donor_gen.gd:613`, `terrain_donor_props.gd:107`, `terrain_donor_world.gd:56` (`1.6981`) | **BENIGN — donor-cited field lattice step** | Each carries an inline donor citation (`unit.script:6468–6570 / :6480; X22:60`) and is labelled CELLS, not metres (V08 C1). This is the donor mill-sown field step, not the refuted half-cell port bug (`game.gd:2729–2740`). |
| `terrain_donor_gen.gd:1687`, `terrain_qa_harness.py:757` (food rects) | **BENIGN DOC / gate description** | `:1687` is `_note("No food rects in SetupStartingResources (X22 X-C6) …")` — an explicit denial. `qa:757` is GR-A13's *requirement text* in the gate register ("requires res[].t attribution to SetupStartingResources") — the gate FAILS such attribution (V21 GR-A13:85). No food creation exists. |
| `terrain_donor_mesh.gd:516,544` (`mask_to_alpha`) | **BENIGN — sanctioned diagnostic** | Re-read `:474–475,516,544`: `mask_to_alpha = 0.0` disables the legacy albedo multiply; telemetry states `ALPHA=1.0` caveat. Fresh shader read `terrain_donor_shader.gdshader:297–306`: comment explicitly rejects `rgb * a`, code is `rgb = rgb * v_packed + v_specular;` then `ALBEDO = rgb; ALPHA = a;`. No `rgb*a`, no height→albedo. |
| `t_terrain_donor.gd:754` (`substr(0,160)`) | **FALSE POSITIVE** | `160` is a display substring length in the noise-token detector, not a donor constant. |
| `terrain_qa_harness.py:124` (`160^2 wavefront`) | **BENIGN — gate description** | GR-A15 text citing the V12-G11 FillOwnerMap test on a 160² scan grid; no generator scale. |
| `terrain_donor_props.gd:438` (`donor_root` literal) | **BENIGN TELEMETRY** | Hard-coded provenance label inside `telemetry()` (`"C:\\Games\\Cossacks 3 (READ ONLY; no binary run/copy)"`). No path resolution, no file access; not emitted derived JSON. |
| `build_terrain_new_atlas.py:81`; `decode_donor_cfg.py:785–786`; `decode_donor_masks.py:45,578`; `decode_donor_pattern.py:62,88`; `decode_pattern_lib.py:49` | **BENIGN — CLI defaults / doc example** | All are `$COSSACKS3_DIR`-overridable input defaults or help/doc strings. `build_terrain_new_atlas.py:471` explicitly records `"donor_root_read": False` and `:473` `"out_refused_in_donor_root": True`. The *defaults themselves* are not the defect (§6). |
| `decode_donor_cfg.py:673`, `decode_donor_pattern.py:944`, `decode_pattern_lib.py:1041` | **LIVE DEFECT (MINOR)** | These are not in the expanded scanner output because they contain no `C:\Games` literal — they interpolate the **resolved absolute path** into emitted JSON. See §6. |

---

## 4. Coverage matrix — all 14 mandated patterns

| # | Pattern | Verdict at final scan | Classification of every hit |
|---|---|---|---|
| 1 | **mix64** | CLEAN | 6 `stage_key` hits = FALSE POSITIVE (`_ledger_key` is a `"%s|v%d|%s"` string; identity re-seeds at gen.gd:648/655). No `mix64`/`stable_hash`/`hash(sid)` token. |
| 2 | **DONOR_UNITS=160** | CLEAN | 4 P4 hits = BENIGN TELEMETRY (gen:741, props:467/478) + FALSE POSITIVE (props:578 field-name list). No executable `const DONOR_UNITS` or `cell_scale = W/160` in any fresh file. |
| 3 | **B>58 off-by-one** | CLEAN | 1 hit (masks:14) = BENIGN DOC. Live decoder uses `B>=58`/`==58` (`decode_donor_masks.py:58,259,388,533`); gen.gd enforces via `h<-0.25` (`:138–139`, V58 item 2 PASS). |
| 4 | **6-pass smoothing** | CLEAN | 1 hit (cfg:23) = BENIGN DOC (C2 contradiction). Generator uses `TILE_SMOOTH_PASSES=3` (gen.gd:166, V58 item 6 PASS). |
| 5 | **3×3 kernel** | CLEAN | No executable hit. `_smooth_tiles` (gen.gd:1226+) is a 3× H-then-V adjacent-pair sweep in place (V20/V58 item 6). |
| 6 | **heightmap-as-albedo** | CLEAN | 2 hits (mesh:516,544) = BENIGN diagnostic `mask_to_alpha=0`; shader `ALBEDO=rgb`, `ALPHA=a` (shader:305–306). No mask/height→albedo routing. |
| 7 | **rgb*alpha multiply** | CLEAN | No executable hit in fresh shader; shader:297 comment rejects legacy `rgb*a`, :299 has no mask factor. |
| 8 | **HEIGHT_SCALE fudge** | CLEAN | P3 zero hits. `mesh.gd:42 HEIGHT_SCALE=1.0` labelled PORT contract; `:150,:748` multiply by 1.0 (V28 F-09 MINOR, not a fudge); `t_terrain_donor.gd:72 =1.0` gate. |
| 9 | **face promotion** | CLEAN | P2 zero hits. Cliff constants are donor-cited art gates (gen:1212–1223) or citation table (world:313–314); relief cells forced face 0 (V58 item 8, V44 E15). |
| 10 | **synthetic noise/dither** | CLEAN | 1 hit (test:757) = FALSE POSITIVE gate-description string. Generator skips editor PostProcess noise (V58 item 8). |
| 11 | **food rects** | CLEAN | 2 hits = BENIGN note/gate text. No food creation in start-resource path (V58 item 7 passing sub-part; X22 X-C6). |
| 12 | **invented donor constants** | CLEAN | All 15 suspicious-literal hits carry a donor `path:line` citation or are explicitly labelled port/test aliases; the two `160` alias arrays are labelled "not donor mapsizes". `C_WATER_BYTE=58` is documentation-only (V58 item 2 note). |
| 13 | **parity claims** | CLEAN | P8 zero hits. `visual_parity_claim=false` universal (world:28/350, props:435/480, gen:518, cfg:39/673, atlas per V38:646+). `qa_harness.py:784 banned_phrases_absent=True` is a **hardcoded advisory telemetry boolean, not a parity claim and not a lowered gate** (V44 E16 residual MINOR). |
| 14 | **absolute donor paths in generated JSON** | **LIVE DEFECT (MINOR)** | Source emit sites + generated JSON evidence in §6. Source CLI defaults (11 hits) are BENIGN; emission into committed-derived JSON is the defect. |

---

## 5. The live defect — absolute donor paths in generated JSON

### 5.1 Source emission sites (in scanned files)

| file:line | Code | Effect |
|---|---|---|
| `decode_donor_cfg.py:673` | `"game_root": game_root, "visual_parity_claim": NO_PARITY_CLAIM,` | Writes resolved absolute `--game` into `cfg/manifest.json`. (`game_root = os.path.abspath(args.game)` at `:797`.) |
| `decode_pattern_lib.py:1041` | `"game": game,` in the emitted docs dict | Writes absolute donor root into lib-derived JSON (`game = os.path.abspath(args.game)` at `:1081`). |
| `decode_donor_pattern.py:944` | `"donor_root": str(game_root),` | Writes resolved donor root into `pattern_decode_manifest.json` (`game_root = Path(args.game).resolve()` at `:878`). |

Additionally, generated `source` fields concatenate the absolute root with a relative donor path (e.g. `decode_donor_cfg.py:205 os.path.join(game_root, spec["rel"])`).

### 5.2 Generated-JSON evidence (second instrument, read-only grep)

```
variant3d/assets/terrain_new/cfg/manifest.json:235:  "game_root": "C:\\Games\\Cossacks 3",
variant3d/assets/terrain_new/cfg/manifest.json:242:        "source": "C:\\Games\\Cossacks 3\\data\\gen\\globalparams.cfg",
variant3d/assets/terrain_new/cfg/manifest.json:255:        "source": "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\smoothtiles.inc",
variant3d/assets/terrain_new/cfg/manifest.json:369:      "source": "C:\\Games\\Cossacks 3\\data\\game\\var\\generator.cfg"
variant3d/assets/terrain_new/cfg/constants.json:9:      "source": "C:\\Games\\Cossacks 3\\data\\gen\\globalparams.cfg",
variant3d/assets/terrain_new/patterns/desert_frt_big1.json:6965:  "source": "C:\\Games\\Cossacks 3\\data\\pattern\\desert_frt_big1.pattern",
```

**[O]** The absolute install path is present in generated JSON on disk. **[D]** It therefore violates the stated policy `donor_root_policy`: "$COSSACKS3_DIR (value NOT recorded as an absolute path in committed output)" (`A03_asset_pipeline.md:218`, `X15_asset_manifest_skeleton.md:17`, spec/11 §11.1 invariant 1).

### 5.3 Landed-report corroboration (multiple instruments)

- **V28 F-07** (`V28_code_review_r1.md:159`): MINOR — "Absolute donor install paths leak into committed derived JSON although another tool declares 'no absolute donor path in committed data'"; fix: emit only `source_rel`/`source_short`, drop `game_root` or use `<DONOR_ROOT>`.
- **V38** (`V38_code_review_r2.md:123,127,164`): N1 and N5 OK but "[MINOR] absolute donor path still emitted"; F-07 tracked **OPEN (MINOR)**.
- **V49** (`V49_licence_credits.md:23,78`): **714 of 780** derived JSON files (9,304 occurrences) embed `C:\Games\Cossacks 3`; "contrary to A03 §2.2.5 / X15 §2.1"; files still untracked; strip/relativise before commit.
- **V62** (`V62_asset_completeness.md:101–102,128`): C4 **[O] MEDIUM** violation if committed; normalise before commit.

### 5.4 Classification and severity

**LIVE DEFECT — MINOR (hygiene/compliance), pre-existing and known-open, not a terrain-generation anti-pattern.** It is **not** BENIGN DOC/TELEMETRY because it is a computed absolute path written into emitted data, and **not** FALSE POSITIVE because the generated files demonstrably contain the path. It is not a V33 19-pattern item (V33's D11 covers invented *constants*, not paths); it enters this gate only because the task explicitly lists "absolute donor paths in generated JSON". No donor binary was copied and no donor parity claim attaches to this finding.

**[U]** Whether the derived files are currently tracked is not re-verified here (V49 says untracked at its read); the defect is recorded regardless, and my file scope was the 13 source files plus a read-only JSON grep.

---

## 6. Out-of-scope observation (not counted as hits)

A whole-`variant3d` grep surfaced noise/dither/3×3 tokens in **legacy or 2D-only files outside the mandated set**: `tools/import_donor_masks.py:98` (`rgb[:,:,2] > 58`), `tools/terrain_blend_test.py:107,318–328`, `tools/gen_variant_maps.py:78,217–218,530–531`, `tools/pieces/t6_{shore_sand,stones_rocks,plateau,grass_mottled,hill_ridge}.py`, legacy `shaders/terrain_tileindex.gdshader:235,427`, `scripts/game.gd`/`world3d_relief.gd`/`pattern_gen.gd` (`DONOR_UNITS`), and vendored `tools/blender_py/PIL/*`. These are **not** the fresh `terrain_donor_*`/`decode_donor_*` implementation tree; V33 §1.1 deliberately excludes `inbox/**`, `docs/**` and V33 D09 explicitly treats the 2D tools as out of scope. They are recorded here only so the reader does not mistake them for clean-tree evidence. No defect is asserted against them in this report.

---

## 7. Multi-pass verification log (second instrument per suspicious hit)

| Suspect | First pass | Second instrument | Final reading |
|---|---|---|---|
| Props `DONOR_UNITS` (V33's old live hit) | P4 regex hit at props:467/478/578 | Whole-file `grep` + re-read `:430–489,:570–585`; `const`/`cell_scale` absent | **Not a defect** — comments/telemetry/field-name list only. |
| `stage_key` ≈ mix64 | D13 regex hit ×6 | Re-read `_ledger_key` `:683–684` = string format; reseeds `:648/:655` identity | **Not a defect** — no hash/mix anywhere. |
| `C_CLIFF_ABS_*` / `ROCK*_H` = face promotion | D11 hits ×4 | Re-read gen `:1212–1223` (art gates, returns tile names); `grep` world `:313–314` (citation table) | **Not a defect**. |
| `mask_to_alpha` = heightmap-as-albedo / rgb*a | D06 hits ×2 | Re-read mesh `:474–516,544` + shader `:290–307` (`ALBEDO=rgb; ALPHA=a`) | **Not a defect** — sanctioned diagnostic. |
| `B>58` | P5 hit at masks:14 | Re-read `:5–19` docstring + `grep` live `B>=58/==58` | **Not a defect**. |
| `TileSmoothPasses=6` | P7 hit at cfg:23 | Re-read `:8–25` docstring + `TILE_SMOOTH_PASSES=3` at gen:166 | **Not a defect**. |
| food rects | D19 hits ×2 | Re-read gen:1687 note + qa:757 gate text | **Not a defect**. |
| `160` constants | D11 hits ×5 | Re-read each + inline donor citations / alias labels | **Not a defect** (one FALSE POSITIVE from a citation string). |
| absolute donor paths | DONOR_ABS_PATH hits ×11 in source | Re-read emit sites cfg:673 / lib:1041 / pattern:944 + grep generated JSON | **LIVE DEFECT (§5)** — CLI defaults benign, emission not. |

---

## 8. Risks / caveats

1. **[O] Line drift:** `terrain_donor_gen.gd` moved ~15 lines during this ticket; V33's `:726` is now `:741`. Re-run scanners before acting on any line number.
2. **[D] Regex is triage, not proof:** clean scans do not certify stage order, 11+3 identity reseeds, no sim write-back, determinism replay, Godot parse, gates or visual result (V33 §2.1, V44 §6 R4).
3. **[U] No parity:** no donor GPU A/B frame exists; parity remains UNVERIFIED / PORT APPROXIMATION throughout.
4. **[D] Scope boundary:** only the 13 mandated files were scanned; a wider "no forbidden token anywhere in variant3d" claim would be false (§6).

---

## 9. Final gate verdict

> **NO-GO** — the "no forbidden constructs" gate fails because of exactly one live construct: absolute donor install paths are emitted into generated JSON (`decode_donor_cfg.py:673`, `decode_pattern_lib.py:1041`, `decode_donor_pattern.py:944`; confirmed in `variant3d/assets/terrain_new/cfg/manifest.json:235,242,…`, `cfg/constants.json:9,…`, per-pattern JSON `source` fields), which violates A03 §2.2.5 / X15 §2.1 and remains OPEN as V28 F-07 (MINOR). All other 13 mandated patterns — mix64, DONOR_UNITS=160, B>58, 6-pass, 3×3, heightmap-as-albedo, rgb*alpha, HEIGHT_SCALE fudge, face promotion, synthetic noise/dither, food rects, invented constants and parity claims — are clean at this scan (all hits BENIGN DOC/TELEMETRY or FALSE POSITIVE). **No donor parity claim; parity stays UNVERIFIED.**

*End of V83 report. Exactly one repository file written (this report). No source, shader, config, asset, test, backup, git, queue, runner, Godot or donor state changed.*
