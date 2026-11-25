---
id: PW-VERIFY-01
task: "Independently re-count PROP-W-PLAN-01's winter-prop (`w`) claims"
date: 2026-11-25
status: DELIVERED__READ_ONLY__INDEPENDENT_RECOUNT__NO_CODE_EDIT__NO_DONOR_COPY__NO_RUNNER_JOB
scope: "Read-only verification only. This report is the ONLY repository file written. No .gd/.gdshader/.json/.png/.dds/config/test/asset was edited or copied; donor was opened bytes-only and never executed, unpacked or copied; no Godot runner job; no test weakened."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1; never executed, unpacked or copied)"
target_report: "docs/coord_swarm_2026-11-25/reports/PROP_W_PLAN_01.md"
output: "docs/coord_swarm_2026-11-25/reports/PW_VERIFY_01.md"
method: "Independent Python parser (section scanner + boundary-safe regex) + raw pathlib walks; helper scripts lived only in %TEMP%\\opencode\\ (pw_verify.py, pw_verify2.py), never in the repo."
labels: [observed, derived, inferred, UNVERIFIED]
---

# PW-VERIFY-01 — independent re-count of PROP-W-PLAN-01 winter-prop claims

> **Read-only verification worker.** This task re-counts, with an independent parser and
> independent `pathlib` walks, the headline numeric claims of `PROP-W-PLAN-01.md`. No code,
> asset, config, test or git state was changed. No donor file was copied, run or unpacked.
> Verdicts are **CONFIRMED**, **REFUTED**, or **CONFIRMED (with nuance)**. No visual-parity
> claim is made or implied.

---

## 0. Sources

| # | Source | Role |
|---:|---|---|
| T | `docs/coord_swarm_2026-11-25/reports/PROP_W_PLAN_01.md` (§1, §2, §7) | Target of verification; all claims re-counted here |
| D1 | `C:\Games\Cossacks 3\data\materials\env\env.mat:815-1551` (1-based; 1,552 lines total) | Fresh donor read of the `// envwinter` block — name/image bindings |
| D2 | `C:\Games\Cossacks 3\data\materials\env\*.dds` | Fresh donor read — same-named DDS on disk and byte total |
| D3 | `C:\Games\Cossacks 3\data\objects\env\*.prop` (raw `rglob`) | Fresh donor read — prop consumption, boundary-safe token match |
| P1 | `variant3d/assets/**` (raw `pathlib.rglob('*')`) | Fresh port read — file census, exact/substring name matches |
| P2 | `variant3d/assets/terrain/decals_dds/*.dds`, `terrain/decals_png/*.png` | Fresh port read — building winter decal stems |
| P3 | `variant3d/assets/terrain/blocks/winter*.png`, `terrain/blocks/desert*.png` | Fresh port read — winter/desert tile PNGs |
| V1 | `%TEMP%\opencode\pw_verify.py` (helper, outside repo) | Independent parser used for all counts below |
| V2 | `%TEMP%\opencode\pw_verify2.py` (helper, outside repo) | Independent 226-stem set cross-check and file-count analysis |

**Labels.** `observed` = literal bytes/lines/files read this pass; `derived` = deterministic
count/set arithmetic over observed data; `inferred` = best reading with a caveat;
`UNVERIFIED` = not provable from readable data.

---

## 1. Method (independent, not the target report's code)

1. **Donor materials.** Read `env.mat` with `open(p,'rb').read().decode('latin-1')`.
   Sliced lines 815–1551 (indices 814–1550), scanned each `section.begin … section.end`
   for `Material.Name` and `Material.Texture.image` (split on `=`). Kept names ending in
   literal `w`. For each, derived the image stem by stripping `.\data\materials\env\`
   and `.dds`; "same-named" iff stem == material name, otherwise "alias". Checked every
   image path on disk. This is a fresh section scanner, not the report's line scanner/regex.
2. **Prop consumption.** Walked all `*.prop` under `data\objects\env` with `rglob`. For each
   of the 79 names, matched with a boundary-safe regex
   `(?<![A-Za-z0-9_])NAME(?![A-Za-z0-9_])`, so `stonesw` does **not** falsely match
   `smallstonesw` and `plantswateratlasw` does **not** falsely match
   `plantswateratlastransparencyw`. Counted distinct prop files with ≥1 hit and the set of
   names hit. (A substring matcher would over-count; boundary-safe is required.)
3. **Port inventory.** Walked `variant3d/assets/**` with raw `Path.rglob('*')`.
   For every file: (a) exact stem match (lowercased) against the 79 names; (b) full-path
   case-insensitive substring match against the 79 names. Counted building decals as files
   in `decals_dds`/`decals_png` whose **stem ends in `w`** (the real stems are e.g.
   `algcendw`, not `_w`-suffixed), compared the two stem sets, and compared my 226 stems to
   the target report's §2.2 list token-by-token. Counted `winter*.png` and `desert*.png`
   in `terrain/blocks`.

---

## 2. Verification table

Evidence paths D1–D3/P1–P3/V1–V2 are defined in §0.

| # | Claim (from PROP-W-PLAN-01) | Report | Independent count | Verdict | Label | Evidence |
|---:|---|---:|---:|---|---|---|
| 1 | Distinct `w`-suffixed `Material.Name` in `env.mat:815-1551` | 79 | **79** (88 sections in block, 79 unique `w` names, 0 duplicates) | CONFIRMED | observed | D1, V1 |
| 2 | `w` materials with a same-named `.dds` | 72 | **72** (all 72 on disk) | CONFIRMED | observed | D1, D2, V1 |
| 3 | Aliases (image stem ≠ material name) | 7 | **7** — `desert1w..5w`→`desert1..5`, `desertstumpw`→`desertstump`, `plantswateratlastransparencyw`→`plantswateratlasw` | CONFIRMED | observed | D1, V1 |
| 4 | Every `w` material's image path resolves on disk | implied | **79/79** exist (0 missing) | CONFIRMED | observed | D1, V1 |
| 5 | DDS byte total for the 72 same-named files | 91,198,648 B | **91,198,648 B** | CONFIRMED | observed | D2, V1 |
| 6 | Donor `.prop` files referencing any `w` name | 321 | **321** (boundary-safe regex; 354 total `.prop`, 353 with season tokens) | CONFIRMED | observed + derived | D3, V1 |
| 7 | Of the 79 names, how many are referenced | 74 | **74** | CONFIRMED | observed | D3, V1 |
| 8 | The 5 never-referenced names | `field5w, field6w, field7w, rocksea2w, rocksea3w` | identical set | CONFIRMED | observed | D3, V1 |
| 9 | Port files with exact stem == any of the 79 names (case-insensitive) | 0 | **0** | CONFIRMED | observed | P1, V1 |
| 10 | Port files with any of the 79 names as path substring (case-insensitive) | 0 | **0** | CONFIRMED | observed | P1, V1 |
| 11 | Building `*_w` DDS decals | 226 | **226** (462 total `.dds` in dir) | CONFIRMED | observed | P2, V1 |
| 12 | Building `*_w` PNG decals | 226 | **226** (462 total `.png` in dir) | CONFIRMED | observed | P2, V1 |
| 13 | DDS and PNG decal stem sets identical; no one-sided stem | yes | **identical** (0 only-DDS, 0 only-PNG) | CONFIRMED | derived | P2, V1 |
| 14 | The 226 stems equal the §2.2 prose block verbatim | 226 | **226; set difference 0 both ways** | CONFIRMED | observed | P2, V2 |
| 15 | Winter tile PNGs (`winter*.png`), no gaps | 27 (`winter0..26`) | **27** (`winter0.png … winter26.png`, no gaps) | CONFIRMED | observed | P3, V1 |
| 16 | Desert tile PNGs (`desert*.png`) | 12 | **12** (`desert1.png … desert12.png`) | CONFIRMED | observed | P3, V1 |
| 17 | Total files under `variant3d/assets/**` | 8,210 | **8,211** (+1) | CONFIRMED (with nuance) | observed | P1, V2 |
| 18 | `models/tex/*.png` count | 346 | **173** PNGs (346 = total files incl. `.import`) | CONFIRMED (with nuance) | observed | P1, V1 |
| 19 | `models/tex` stems ending in literal `w` | 0 | **1** (`tow.png`; 0 of the 79 winter names) | CONFIRMED (with nuance) | observed | P1, V1 |
| 20 | Suffix `w` (props) distinct from `_winter` (tiles) | asserted | consistent with §15/16 naming | CONFIRMED | inferred | P3, T |

**Result: all 16 headline numeric claims (rows 1–16) confirmed.** Rows 17–19 are minor
counting/labelling nuances that do not change any headline verdict. No headline claim is
refuted.

---

## 3. Corrections and nuances

1. **Total asset files (row 17).** Independent `rglob` yields **8,211**, one more than the
   reported **8,210**. The difference is immaterial (0.012%) and is consistent with a
   counting-method nuance (the tree contains five extensionless `.gdignore` marker files and
   3,503 `.import` sidecars; different walkers include/exclude such files differently). It
   does **not** affect the 0/79 match result. Not a correction to any headline claim.
2. **Prop file denominator (row 6).** The report's S7 calls "all 353 files"; a raw `rglob`
   yields **354** `.prop` files. The extra file is `christmastreea.prop`, the only one with
   no season/winter token, and it references no `w` name. Both denominators produce the same
   **321** referencing count. Not a correction.
3. **`models/tex/*.png` (row 18).** The report's **346** equals the *total file count* of
   that directory, not the PNG count: there are **173** PNGs (plus 173 `.import` sidecars).
   This is a labelling imprecision in the target report's §2 table; it does not affect the
   "summer albedo / no winter art" conclusion.
4. **`models/tex` `w` stems (row 19).** The report states **0** stems ending in literal `w`
   while its own note names `tow.png`/`tow.obj`/`tow.mtl`/`alg_tow.png`. Independent count is
   **1** such stem (`tow`, a tower sprite). The intended claim — **0 of the 79 donor `w`
   material names present** — is confirmed; the literal "0 stems ending in `w`" is imprecise.
5. **Decal suffix notation.** The report writes `*_w.dds`/`*_w.png`, but the actual winter
   decal stems end in bare `w` (`algcendw`, `alghoudw`, …), not `_w`. Counting must use
   "stem ends in `w`" (which gives 226), not a literal `*_w` glob (which gives 0). The
   report's numeric value is correct; only its glob shorthand is misleading.
6. **No corrections donor-side.** Rows 1–8 are reproduced exactly by the independent parser.

---

## 4. Open questions

1. **OQ1** The +1 asset-file and +1 prop-file differences are attributed to counting-method
   nuances; the exact original walker semantics were not re-derived (read-only task). Both
   are immaterial to the headline claims.
2. **OQ2** This is a structural/count verification only. Non-numeric claims in the target —
   donor GPU A/B, native execution of donor season scripts, DDS→PNG conversion permission,
   emission→screen colour, field-decal 3D UV mapping, building-child `detailw` binding,
   relief-prop placement, desert interaction, and `Data.BIOME`↔`GetSeasonType=2` equivalence —
   remain **UNVERIFIED** here; a count-based re-check cannot confirm or refute them.
3. **OQ3** Whether the 7 aliases are bound at runtime (vs. merely sharing an image path in
   `env.mat`) is not provable from a static count; the report already labels this
   `UNVERIFIED`.

---

## 5. Summary

`PW-VERIFY-01` independently re-counted `PROP-W-PLAN-01`'s winter-prop (`w`) claims using a
fresh section scanner, a boundary-safe prop-token regex, and raw `pathlib` walks — no target
code reused, no donor copy, no code edit, no runner job.

- **Donor:** `79` `w` materials, `72` with same-named DDS (91,198,648 B), `7` aliases,
  `321` props referencing `74` names, with the exact unreferenced set
  `{field5w, field6w, field7w, rocksea2w, rocksea3w}` — **all CONFIRMED**.
- **Port:** `0`/`79` exact and `0`/`79` substring matches; `226` building `*_w` DDS +
  `226` PNG with identical stem sets matching the report's list exactly; `27` winter tile
  PNGs; `12` desert PNGs — **all CONFIRMED**.
- **Nuances only:** total assets 8,211 (vs 8,210), `models/tex` 173 PNGs (vs 346 files),
  and one literal `w` stem (`tow`) — none change a headline verdict.
- **No claim refuted.** Non-numeric/runtime claims remain **UNVERIFIED** by design.

*End of PW-VERIFY-01. One report written; no other repository file touched.*
