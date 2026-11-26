---
id: X20
wave: X (verification swarm)
title: "X20 — Prototype and validation of decode_donor_cfg.py (I01) against F03 ground truth"
date: 2026-11-26
status: LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope: "Donor READ ONLY; Python prototype + emitted JSON live OUTSIDE the repo; one report written in repo; no source/asset/config/test/git edits; no Godot jobs"
prototype_root: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\cfg_decode\\"
donor_root: "C:\\Games\\Cossacks 3"
---

# X20 — `decode_donor_cfg.py` (I01) prototype validated against F03

## 0. Conventions and guardrails

- Labels: **`[O]`** observed literal bytes/line; **`[D]`** derived arithmetic/structure; **`[I]`** inferred; **`[U]`** UNVERIFIED; **`PORT APPROXIMATION`** port behaviour, explicitly **not** a parity claim.
- Donor access is **read-only**. No donor binary executed, no donor byte copied into the repo, no Craft Anything global target changed, no Godot runner job, no git operation.
- The Python prototype and its emitted JSON live **only** in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\cfg_decode\`. The **only** repo file written by this worker is this report.
- **No donor visual-parity claim is made anywhere in this report** (`visual_parity_claim: false` in every emitted document, per `spec/11 §11.1`).
- Citation convention: `gen\X.cfg:N` = `C:\Games\Cossacks 3\data\gen\X.cfg` line `N` (1-based); `var\X.cfg:N` = `data\game\var\X.cfg`; `smoothtiles.inc:N` = `data\scripts\common.inc\smoothtiles.inc`.

---

## 1. Executive summary

1. **`[O]`** All **7** donor configs named in F03 §2 were parsed with Python 3 `latin-1` decoding and CRLF preserved. **7/7 SHA-256 hashes match F03's table exactly**, as do byte counts, line counts and all-CRLF status (§3, §4).
2. **`[O]`** The prototype emits `constants.json` (2,997 active key→value records, each with exact donor path + 1-based line) and `config_strings.json` (4,868 non-constant lines, all labelled `UNVERIFIED`) plus a `manifest.json` carrying hashes, 19 count checks, 4-pass anomaly audit, both preserved contradictions and determinism evidence (§6).
3. **`[D]`** Of the **16 counts requested by this task, 15 PASS and 1 FAIL**. The failure is **`globalparams.cfg` global keys: F03 claims 20, donor bytes contain 19**. Four independent passes agree on 19, and F03's own §3.1 verbatim dump and §4 table each list 19 rows — the "20" is an internal off-by-one, not a recoverable 20th key (§5, §8).
4. **`[O]`** All weighted-table figures reproduce exactly: **22 chains / 130 groups (118 active, 12 commented) / 310 entries (282 active, 28 commented) / 86 distinct active names / ΣProb = 174.0168** using `Decimal` arithmetic, with `//Prob` alternatives excluded (`tilesmooth_scripts.cfg:1-1863`). Generator (`64/493`) and start-settings (`19/61/61/276`) counts also reproduce.
5. **`[D]`** Both donor contradictions are preserved **verbatim** in the manifest, with the exact donor script lines re-read read-only: `TileSmoothPasses = 6` (`globalparams.cfg:9`) vs `SmoothTileMap(..., 3)` (`smoothtiles.inc:237`), and `tilesmooth.cfg` (`globalparams.cfg:10`) vs `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`) (§7).
6. **`[O]`** Determinism holds: two runs produced **byte-identical** `constants.json`, `config_strings.json` and `manifest.json` (§9). `--dry-run` writes nothing; `--out` inside the donor root is refused.

---

## 2. Evidence table

| # | Observation / artefact | Label | Donor citation or prototype evidence |
|---:|---|---|---|
| E1 | 7 canonical source files hashed; all SHA-256, byte and line counts match F03 §2; all CRLF | `[O]` | §4 table; `manifest.json::source_hashes` |
| E2 | `globalparams.cfg` contains **19** `Key = value` lines (`:2-20` inclusive), not 20 | `[O]`+`[D]` | verbatim dump `globalparams.cfg:1-22`; 4 passes in §8 MP-1 |
| E3 | F03 §3.1 dump lists 19 keys; F03 §4 parameter table has 19 numbered rows; only F03 §1/§9-F1/§14 and `spec/09 §1` say "20" | `[O]` | `reports/F03_gen_config.md:36,438-457,801,878`; `spec/09_EDITOR_PARAMETERS.md:11` |
| E4 | `localparams.cfg` 13 keys | `[O]` | `localparams.cfg:4-16` |
| E5 | `mapcover.cfg` 15 value lines; four seasonal tile names empty | `[O]` | `mapcover.cfg:4-30`, specifically `:12-15` |
| E6 | `tilesmooth.cfg` 8 `section.begin` blocks at lines 1, 15, 29, 46, 63, 80, 97, 114; 30 `TileName` lines; no `Prob` key | `[O]` | `tilesmooth.cfg:1-129` |
| E7 | `tilesmooth_scripts.cfg` 22 `SmoothTiles : struct.begin` chains, 130 `TileNames : struct.begin` groups (118 active), 310 `TileName` lines (282 active) | `[O]` | `tilesmooth_scripts.cfg:1-1863`; §5 C06–C10 |
| E8 | 86 distinct active tile names; Σ active `Prob` = **174.0168** over 282 active Prob lines; commented `//Prob = 0.36` alternatives excluded | `[O]`+`[D]` | `tilesmooth_scripts.cfg:449-452,572-573,681-682` and mirrors `:1381-1382,1502-1503,1611-1612`; `Decimal` pass |
| E9 | `generator.cfg` 64 `Name =` family records, 493 `Pattern =` pairs and independently 493 `Freq =` pairs | `[O]` | `generator.cfg:67-2366`; §5 C13–C14 |
| E10 | `startingsettings.cfg` 19 `startid` presets, 61 `allowedcountries` blocks, 61 `mask` structs, 61 `legends` structs, 276 `key` legend-entry lines | `[O]` | `startingsettings.cfg:87-3423`; §5 C15–C19 |
| E11 | Literal token `countries : struct.begin` occurs **79** times (all active); the "61 countries" figure is reproduced only by `allowedcountries` blocks | `[O]`+`[D]` | `startingsettings.cfg`; §8 MP-2 |
| E12 | Contradiction 1 verbatim, cfg side `   TileSmoothPasses = 6` | `[O]` | `globalparams.cfg:9` |
| E13 | Contradiction 1 verbatim, script side `      [*] = ;SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3);` | `[O]` | `smoothtiles.inc:237` |
| E14 | Contradiction 2 verbatim, cfg side `   TileSmoothListFileName = .\data\gen\tilesmooth.cfg` | `[O]` | `globalparams.cfg:10` |
| E15 | Contradiction 2 verbatim, script side `      [*] = ;ParserLoadFromFileByHandle(pTileSmoothLists, '.\data\gen\tilesmooth_scripts.cfg');` | `[O]` | `smoothtiles.inc:5` |
| E16 | Ancillary read-only script hash (not one of the 7 canonical files): 10,691 B, `1887b5dd…cf179c` | `[O]` | `smoothtiles.inc` bytes |
| E17 | Emitted JSON: 2,997 constants (19/13/15/30/564/1085/1271 per file), 4,868 UNVERIFIED strings (3,806 structural, 877 anon-assignment, 131 dead-key, 39 comment, 15 blank) | `[O]` | `constants.json`, `config_strings.json`; §6 |
| E18 | Two-run byte identity for all three outputs | `[O]` | §9 SHA-256 table |
| E19 | `--dry-run` prints plan and writes nothing; `--out` under donor root refused | `[O]` | prototype CLI runs |

---

## 3. Method

1. **Inventory / hash gate.** Read the 7 donor paths from F03 §2; for each, read raw `bytes`, decode `latin-1`, count `\r\n` vs `\n`, compute SHA-256, compare with F03's table and with expected byte/line counts.
2. **Generic OSW line parser.** Each physical line (1-based) is classified after stripping any number of leading `//` markers:
   `kv` (`Key = value`), `struct_begin` (`name : struct.begin`), `struct_end`, `section_begin`, `section_end`, `anon_assignment` (`[*] = value`), `blank`, `other`. A frame stack carries section/struct `[*]` indices so every emitted constant has a `structural_path` in addition to exact `source` + `line`.
   - **Active** `kv` lines → `constants.json` with typed `value` (`int`, `float`, `bool`, `string`, `empty`), exact `raw_value`, `label: "O"`, `active: true`.
   - **Commented-out** `kv` lines (dead rules such as `//Prob = 0.36`) → `config_strings.json` with `category: "dead_kv"`, `label: "UNVERIFIED"`; they are *not* emitted as active constants. They are still counted for structural totals (310 entries).
   - All structural tokens, blank lines, comments and `[*] = …` assignments → `config_strings.json`, all labelled `UNVERIFIED`.
3. **Count verification, 19 checks.** Each check is computed by **three independent instruments**:
   - **P1 structural** — from the parsed frame/token census.
   - **P2 regex** — `re` scan over `latin-1` lines with comment-aware normalisation.
   - **P3 raw bytes** — anchored byte-level regex / byte substring count over the untouched donor blob (explicit `\r?$` for CRLF).
   A check PASSES only when `expected == P1 == P2 == P3`. On any FAIL, a **fourth pass** re-reads the F03-cited line range verbatim and records what changed (§8).
4. **Contradiction preservation.** The two cfg lines are taken from the parsed donor files; the two script lines are re-read read-only from `smoothtiles.inc` and stored verbatim in `manifest.json::preserved_contradictions` with F03 citations and the port rule.
5. **Determinism.** `json.dumps(..., indent=2, sort_keys=True, ensure_ascii=True) + "\n"` encoded UTF-8; two full in-process parses compared byte-for-byte, plus two separate CLI runs written to distinct directories and compared externally (§9).

Prototype location (outside repo): `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\cfg_decode\decode_donor_cfg.py`.

---

## 4. SHA-256 verification — all `[O]`

| Donor file | Bytes | Lines | EOL | SHA-256 observed = F03 §2 | Result |
|---|---:|---:|---|---|---|
| `gen\globalparams.cfg` | 537 | 22 | CRLF (22) | `15a8dc64a91dc4e72f45a997d6f6a5b770b2b77786518f48a75e04ab95727a51` | **PASS** |
| `gen\localparams.cfg` | 508 | 20 | CRLF (20) | `8d174830c47388e28ed80ad434ad591943a7d69616fb89697e68175b0934a12d` | **PASS** |
| `gen\mapcover.cfg` | 1,196 | 40 | CRLF (40) | `ff0a7bf43314af53c93dd14f992fa4e6b866cd5acf07b95abdb2404ed9fa43f2` | **PASS** |
| `gen\tilesmooth.cfg` | 2,796 | 129 | CRLF (129) | `1753533e7984c2319c3c5fdbc519728e0937905c4cc5117846432ce008b89c7d` | **PASS** |
| `gen\tilesmooth_scripts.cfg` | 64,017 | 1,863 | CRLF (1,863) | `b82c88844160c0451696951466a72bcd1dff64079388c0ad0b3b0a07a531b433` | **PASS** |
| `var\generator.cfg` | 70,074 | 2,367 | CRLF (2,367) | `f8a5cd2e08952565290adf4da888017467097c9b6e7666a45cf141827a974cc3` | **PASS** |
| `var\startingsettings.cfg` | 116,920 | 3,424 | CRLF (3,424) | `17d4aeddaf4496594bda74e5f1fcc4f8ff0e149a5b2a53211c8f1eba200c111f` | **PASS** |

**7/7 PASS.** No donor file was modified.

---

## 5. Pass/fail count table

Task-requested counts (16): **15 PASS / 1 FAIL**. Prototype includes 3 extra cross-checks (C08, C10, C14) for a total of 19 checks, **18 PASS / 1 FAIL**.

| ID | Count claimed (F03 / task) | Observed P1 / P2 / P3 | Result | Citation |
|---:|---|---|---|---|
| C01 | **20** global keys | **19 / 19 / 19** (+ pass 4 = 19) | **FAIL** | `globalparams.cfg:2-20`; §8 MP-1 |
| C02 | 13 local keys | 13 / 13 / 13 | PASS | `localparams.cfg:4-16` |
| C03 | 15 mapcover values | 15 / 15 / 15 | PASS | `mapcover.cfg:4-30` |
| C04 | 8 plain sections | 8 / 8 / 8 | PASS | `tilesmooth.cfg:1,15,29,46,63,80,97,114` |
| C05 | 30 plain `TileName` entries | 30 / 30 / 30 | PASS | `tilesmooth.cfg:1-129` |
| C06 | 22 chains | 22 / 22 / 22 | PASS | `tilesmooth_scripts.cfg:1-1863` |
| C07 | 130 groups | 130 / 130 / 130 | PASS | `tilesmooth_scripts.cfg` (`TileNames` structs) |
| C08 | (extra) 118 active groups | 118 / 118 / 118 | PASS | F03 §6.3 |
| C09 | 310 entries | 310 / 310 / 310 | PASS | 282 active + 28 commented |
| C10 | (extra) 282 active entries | 282 / 282 / 282 | PASS | F03 §6.3 |
| C11 | 86 distinct active names | 86 / 86 / 86 | PASS | F03 §6.5 |
| C12 | ΣProb 174.0168 | 174.0168 / 174.0168 / 174.0168 | PASS | `Decimal`, 282 active Prob lines |
| C13 | 64 families | 64 / 64 / 64 | PASS | `generator.cfg:69-2314` |
| C14 | (extra) `Freq` lines = pairs | 493 / 493 / 493 | PASS | `generator.cfg:67-2366` |
| C15 | 19 presets | 19 / 19 / 19 | PASS | `startingsettings.cfg:87-3423` |
| C16 | 61 countries | 61 / 61 / 61 | PASS `[D]` | via `allowedcountries` blocks; §8 MP-2 |
| C17 | 61 masks | 61 / 61 / 61 | PASS | `mask : struct.begin` |
| C18 | (task lists 61 masks only; extra) 61 legends | 61 / 61 / 61 | PASS | `legends : struct.begin` |
| C19 | 276 legend entries | 276 / 276 / 276 | PASS | `key =` lines |

`--check` therefore exits **1** in the prototype (by design: the single genuine discrepancy must not be silently accepted). Counts C02–C19 and all hashes pass.

---

## 6. Emitted schema

All three documents carry `"schema_version": "1.0"`, `"tool": "X20-cfg-decoder-prototype"`, `"visual_parity_claim": false`.

### 6.1 `constants.json` — 2,997 records `[O]`

```json
{
  "schema_version": "1.0", "tool": "…", "label": "[O] active literal…",
  "visual_parity_claim": false,
  "note": "PORT APPROXIMATION only. Every entry carries exact donor path + 1-based line.",
  "constants": [
    {
      "key": "Size",
      "value": 512,
      "raw_value": "512",
      "value_type": "int",
      "source": "C:\\Games\\Cossacks 3\\data\\gen\\globalparams.cfg",
      "source_rel": "data\\gen\\globalparams.cfg",
      "source_short": "gen\\globalparams.cfg",
      "line": 2,
      "structural_path": "<root>/Size",
      "label": "O",
      "active": true
    }
  ]
}
```

Per-file active constants: `globalparams 19`, `localparams 13`, `mapcover 15`, `tilesmooth 30`, `tilesmooth_scripts 564`, `generator 1085`, `startingsettings 1271`. Empty literals are preserved as `value: ""`, `value_type: "empty"`, `label: "O"` — an observed empty value is **not** the same as an undecodable field (which goes to `config_strings.json` as `UNVERIFIED`, per `spec/11 §11.1`).

### 6.2 `config_strings.json` — 4,868 records `[U]`

```json
{
  "schema_version": "1.0", "tool": "…", "label": "[U] UNVERIFIED — not an active key->value constant",
  "visual_parity_claim": false,
  "entries": [
    {
      "source": "C:\\Games\\Cossacks 3\\data\\gen\\globalparams.cfg",
      "source_rel": "data\\gen\\globalparams.cfg",
      "source_short": "gen\\globalparams.cfg",
      "line": 1,
      "raw": "section.begin",
      "category": "structural",
      "structural_token": "section_begin",
      "structural_path": "<root>",
      "label": "UNVERIFIED"
    }
  ]
}
```

`category` ∈ `structural | anon_assignment | dead_kv | comment | blank | other`; observed totals 3,806 / 877 / 131 / 39 / 15 / 0. Every commented-out key→value line (e.g. `//Prob = 0.36` at `tilesmooth_scripts.cfg:451`) is here as `dead_kv`, so commented rules never leak into the active-constant set.

### 6.3 `manifest.json`

Fields: `game_root`, `visual_parity_claim: false`, `source_hashes[7]` (expected/observed bytes, lines, sha256, EOL, result), `count_checks[19]` (expected, P1/P2/P3, result, F03 citation), `multi_pass_audit` (only FAILs, with pass-4 verbatim re-read), `preserved_contradictions[2]`, `derived` (`active_prob_sum`, `active_prob_line_count`, `distinct_active_tilenames`, `mp_notes`), `summary`, and — when `--check` is used — `determinism[3]`.

---

## 7. Preserved contradictions (verbatim) `[O]`/`[D]`

Both are preserved as **data**, not corrected. The script lines were re-read read-only; all four lines are `;`-prefixed in their source, so the runtime behaviour remains `[U]` donor intent (F03 F15).

| # | cfg side (verbatim, with leading whitespace) | script side (verbatim) | Port rule |
|---:|---|---|---|
| C2 | `globalparams.cfg:9` — `   TileSmoothPasses = 6` | `smoothtiles.inc:237` — `      [*] = ;SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3);` | Follow **3** for skirmish; retain literal `6` as provenance. `PORT APPROXIMATION` |
| C3 | `globalparams.cfg:10` — `   TileSmoothListFileName = .\data\gen\tilesmooth.cfg` | `smoothtiles.inc:5` — `      [*] = ;ParserLoadFromFileByHandle(pTileSmoothLists, '.\data\gen\tilesmooth_scripts.cfg');` | Load **`tilesmooth_scripts.cfg`**; retain cfg path as provenance |

These match `SWARM_BOARD.md` contradictions C2/C3 and `spec/09 §4`. Neither is resolved away.

---

## 8. Multi-pass anomaly register (owner directive, charter §4)

**MP-1 — global key count 20 vs 19. REAL F03 ERROR `[O]`/`[D]`.**

| Pass | Instrument | Result | What changed |
|---:|---|---|---|
| 1 | Structural parse of active `kv` tokens | **19** | — |
| 2 | Independent regex over decoded lines | **19** | agrees with P1 |
| 3 | Anchored byte regex over raw untouched blob | **19** | agrees with P1/P2 |
| 4 | Full verbatim re-read of `globalparams.cfg:1-22` | **19** | `:2-20` inclusive = 19 physical keys; `:21` is `section.end`, `:22` is empty |
| 5 | Cross-check F03's own dump/table | **19 rows** | `F03:64-89` dump and `F03:438-457` §4 table each list 19 keys; only the headline (`F03:36`), finding F1 (`F03:801`) and summary (`F03:878`), plus `spec/09:11`, say 20 |

**Accepted reading: 19.** `:2-20` is an inclusive range of 19 lines; F03's `[D]` breakdown at `F03:459` ("3 non-empty strings") is also arithmetically inconsistent — the file has 2 non-empty string keys (`:10`, `:12`), 10 numeric/bool (`:2-9`,`:18`,`:19`) and 7 empty (`:11`,`:13-17`,`:20`) = **19**. **No 20th key was guessed.** I01 must emit 19 constants for this file and flag F03/spec/09 for COORD correction.

**MP-2 — "61 countries" definitional ambiguity `[D]`/`[U]`.** Passes 1–3 reproduce 61 **only** for `allowedcountries : struct.begin` blocks (`startingsettings.cfg`). A literal count of `countries : struct.begin` returns **79** (all active), while F03 §8 prose says "18 `countries` blocks". Three different numbers refer to different tokens; there is no byte-level contradiction because each is reproducible. Accepted reading for the task's "61 countries" check: **61 `allowedcountries` blocks**, with the 79 literal `countries` structs recorded separately in `mp_notes`. Flagged as an open question, not silently harmonised.

**MP-3 — prototype byte-heuristic bugs (not donor anomalies).** Initial P3 for C08/C10/C13 returned 0/130/0 because (a) `\r` was not allowed before `$` on CRLF lines and (b) a naive `Name =` substring subtraction cancelled itself out. Fixed by anchored byte regexes with `\r?$`; all three then PASS. Recorded here so the correction is auditable — no donor value was altered.

---

## 9. CLI and determinism check

Prototype CLI (to be ported to `variant3d/tools/decode_donor_cfg.py` by I01):

```
python decode_donor_cfg.py --game <donor-root> [--out <dir>] [--check] [--dry-run]

--game PATH   donor install root, read-only (default C:\Games\Cossacks 3)
--out DIR     output directory; REFUSED if it is inside --game (spec/11 §11.1)
--check       verify 7 SHA-256 + 19 count checks + two-run determinism;
              exit 1 on any FAIL (prototype currently exits 1 on MP-1 only)
--dry-run     print "source path:line -> output -> sha256 -> label" for a
              sample of both outputs; writes NO files
```

Observed behaviour `[O]`: `--dry-run` printed the plan and `dry-run: no files written`; `--out C:\Games\Cossacks 3\data\gen\BAD` was refused with `ERROR: --out must not be inside the donor root`.

**Determinism** — two CLI runs to `…\cfg_decode\run1` and `…\cfg_decode\run2`, plus an in-process double-parse inside `--check`:

| Output | run1 SHA-256 (= run2) | Bytes | Byte-identical |
|---|---|---:|---|
| `constants.json` | `f93ca84ba5de37d9cdf12eabe04be271091905091863912eb1238b29f0abfaca` | 1,343,895 | **YES** |
| `config_strings.json` | `5fd5e5d59dd75f2f240568afcb7cc4877a1a953fc0dfd96b9dbb746c9c83a884` | 2,168,721 | **YES** |
| `manifest.json` | `d5b24811c2b23a5f049ea74a1476b8d1cecad330140577cd47d5dc55a8ea5296` | 14,463 | **YES** |

Guarantees used: `sort_keys=True`, fixed indent, explicit UTF-8 encoding with trailing `\n`, no timestamps, no absolute-path-dependent ordering. Note the in-process `--check` determinism hashes are computed on the manifest **before** the `determinism` field is injected; the two on-disk manifests (which include that field) are nonetheless byte-identical, as shown above.

---

## 10. Implications for I01 (port to `variant3d/tools/decode_donor_cfg.py`)

1. **`[D]` Port the parser shape, not just the output.** The frame-stack classifier is required to produce exact `path:line` for all 2,997 constants; a flat regex without the stack loses `structural_path` and cannot distinguish `mapcover.cfg:4` `Name` from `:6` `Name`.
2. **`[D]` Fix the global-key expectation.** I01 must emit **19** constants for `globalparams.cfg` and record MP-1 in its own report/hand-off; it must not add a synthetic 20th key. Alert COORD to correct `reports/F03_gen_config.md:36,801,878` and `spec/09_EDITOR_PARAMETERS.md:11,14` (spec line 14 is already correct at 30 for `tilesmooth.cfg`).
3. **`[D]` Key `Patterns` by record index, not by family name** — 4 names are duplicated (`generator.cfg:156/1658`, `:173/1683`, `:190/1708`, `:288/1762`); a name-keyed map drops records (F03 F11).
4. **`[D]` Keep `dead_kv` separate from active constants** so commented alternatives (`//Prob = 0.36`, `tilesmooth_scripts.cfg:451`) cannot become runtime weights. ΣProb must stay 174.0168 with `Prob=0` endpoints preserved.
5. **`[D]` Keep `--out` donor-root guard and `--dry-run` write-free behaviour** from `spec/11 §11.1`; keep `visual_parity_claim: false` in every document.
6. **`[D]` Emit the contradiction records verbatim** into the manifest; downstream smoothing must use 3 passes and `tilesmooth_scripts.cfg` (`PORT APPROXIMATION`), while cfg literals remain provenance only.
7. **`[U]` I01 must not infer semantics for `Size`, `CellsResolution`, `Sharpness`, `FrequencyFactor`, castle keys or `Freq` sampling — the decoder emits literals with labels only.**

---

## 11. Risks

| Risk | Label | Mitigation |
|---|---|---|
| I01 hard-codes 20 and invents a key to match F03 | `[D]` | Emit 19; carry MP-1 audit in manifest; COORD corrects F03/spec |
| Name-keyed `Patterns` map drops 4 duplicate families | `[D]` | Key by record index; preserve source order of all 64 |
| Commented `//Prob` leaks into roulette weights | `[O]` | `dead_kv` category; ΣProb assertion = 174.0168 |
| Byte-regex P3 false FAIL on CRLF (`\r` before `$`) | `[D]` | `\r?$` in all anchored byte patterns; MP-3 records the fix |
| "61 countries" silently reinterpreted as 79 or 18 | `[U]` | Key on `allowedcountries`; record literal 79 in `mp_notes`; open question Q2 |
| Ancillary script read mistaken for a canonical 7th file | `[O]` | `smoothtiles.inc` is cited separately with its own hash; not in `source_hashes[7]` |
| Treating empty literal as undecodable/null | `[D]` | `value_type: "empty"`, `label: "O"`; only `config_strings` carries `UNVERIFIED` |
| Assuming `;`-prefixed script lines are proven live runtime | `[U]` | Contradiction port rule labelled `PORT APPROXIMATION`; no parity claim |

---

## 12. UNVERIFIED register

| # | Item | Why UNVERIFIED |
|---:|---|---|
| U1 | Whether `smoothtiles.inc` is live runtime code | Every consumer line is `;`-prefixed (`smoothtiles.inc:4-242`); F03 F15 |
| U2 | Which consumer reads `gen\tilesmooth.cfg` (plain 8-section table) | `globalparams.cfg:10` names it; no parser call found; script uses the other file |
| U3 | Runtime selection of Winter chains C11–C20 | No season switch in the parsed configs |
| U4 | Meaning of `Size`, `CellsResolution`, `Sharpness`, `TileChangeFactor`, `FrequencyFactor`, castle keys | Names only; no consumer in the 7 files |
| U5 | `Freq` sampling / normalisation algorithm | Consumer not present in the parsed configs |
| U6 | `mng/mni/mnc` abbreviations | Names only |
| U7 | Semantics of the 79 literal `countries : struct.begin` blocks vs 61 `allowedcountries` blocks | Counts reproducible; structural relationship not established here |
| U8 | Whether the 19th key was ever intended in F03 (i.e. is the "20" a stale earlier revision?) | No 20th literal exists in donor bytes; cannot be recovered from read evidence |
| U9 | Mask ASCII→world transform, dataversion selection, seed/RNG/water/mine counts | Absent from all 7 files (F03 F14) |

---

## 13. Open questions

1. **COORD / F03:** approve correcting the "20 global keys" claim to **19** in `reports/F03_gen_config.md:36,801,878` and `spec/09_EDITOR_PARAMETERS.md:11`? X20 does **not** edit those files (disjoint ownership).
2. **F03 / F09:** what exactly does "61 countries" denote — 61 `allowedcountries` blocks (reproduced) or the 79 literal `countries` structs (F03 §8 says "18")? A token-level definition is needed before I01 finalises its schema.
3. **D09 / F09:** is `globalparams.cfg:10` a stale editor pointer, or is there a live consumer of the plain `tilesmooth.cfg` 8-section table?
4. **I01:** should `manifest.json` be the single place carrying preservation of C2/C3, or should the contradictions also be duplicated into `constants.json` provenance fields? (Prototype uses manifest only.)
5. **A05 / QA:** add the 19-check count gate and `ΣProb == 174.0168` as byte-level assertions so a future F03-count regression cannot pass silently.

---

## 14. Five-line hand-off summary

1. `[O]` 7/7 donor SHA-256, byte and line counts match F03; all CRLF; prototype emitted 2,997 constants + 4,868 UNVERIFIED strings outside the repo.
2. `[D]` 15/16 requested counts PASS; **global keys FAIL — 19 observed vs F03's 20**, confirmed by four passes and F03's own 19-row dump/table; no key invented.
3. `[O]` 22 chains / 130 groups (118 active) / 310 entries (282 active) / 86 names / ΣProb 174.0168; 64 families / 493 pairs; 19 presets / 61 / 61 / 276 all reproduce.
4. `[O]` Both donor contradictions preserved verbatim with script re-read: `globalparams.cfg:9` vs `smoothtiles.inc:237`, `globalparams.cfg:10` vs `smoothtiles.inc:5`.
5. `[D]` CLI (`--game`, `--out`, `--check`, `--dry-run`) defined; two runs byte-identical; `PORT APPROXIMATION` only — **no donor parity claim**.
