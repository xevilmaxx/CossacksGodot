---
id: V60
swarm: TERRAIN-SWARM-2026-11-26
wave: V (verification) — I04 mask-decoder audit
title: "Audit of variant3d/tools/decode_donor_masks.py (I04) against the 9-point mask-decoder contract"
owner_file: reports/V60_i04_audit.md
status: LANDED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists. Nothing here is a donor-visual-parity claim; 'matches' means byte/formula agreement on read-only donor data only."
audited_file: variant3d/tools/decode_donor_masks.py (TOOL_VERSION 1.0.0, 618 lines)
---

# V60 — I04 mask decoder audit (read-only)

## 0. Verdict at a glance

| # | Contract item | Verdict | Primary evidence (file:line) |
|---|---|---|---|
| 1 | Covers ALL 4,466 masks across 3 trees; no `PER_TYPE=8` subsample | **PASS** | `TREES` :50-54; `discover` :287-298; `iter_paths` :301-305; `build_manifest` :484-489; live `masks=4466` |
| 2 | RLE 24-bit TGA: 320² bottom-left **and** 256² top-left | **PASS** | `parse_header` :73-90; `decode_tga` :107-140 (flip :136-137, BGR→RGB :139); live V5 / header checks |
| 3 | `h=-1.1*B/255` exactly; water `B>=58` (not `B>58`); starts excluded from water fraction | **PASS** | :57-58, :192-212, :243-247, :256-258; live V2 transect + `deep=0.213827` |
| 4 | R/G forest semantics `null` + UNVERIFIED for vanilla; both channel-facts preserved (F04 vs A02) | **PASS** | :260-264; :542-557; manifest `note` :511-513 |
| 5 | Both `.src` and `.dlc5` variants | **PASS** | :52-53; `discover` :289-298; `run_check` :319-331; V5 :414-421; V7 :446-460 |
| 6 | Manifest schema + `visual_parity_claim:false` | **PASS** | :229-265 (record schema); :508-570 (manifest); :516, :565-569 |
| 7 | Deterministic; no donor bytes copied | **PASS** | :27-28, :281, :302-305, :504-505, :604, :592-597; two identical dry-run hashes |
| 8 | `--dry-run --check` CLI semantics | **PASS** | :574-590, :599-603; live runs below (2 latent reporting gaps noted in §3) |
| 9 | No forbidden constructs / parity claims | **PASS** | grep: no `subprocess`/`eval`/`PER_TYPE`; :5, :472, :513, :516, :566, :568 |

**Overall: 9/9 PASS.** Six non-blocking observations with concrete fixes are in §3; none flips a verdict. No donor-parity claim is made anywhere.

## 1. Method, provenance and passes

Files read (all under the workspace root): `docs/terrain_swarm_2026-11-26/CHARTER.md`, `SWARM_BOARD.md`, `spec/03_MASK_TO_HEIGHT.md`, `reports/F04_masks.md`, `reports/X18_mask_channel_verification.md`, `reports/X19_mask_decoder_gap.md`, `reports/D03_mask_pipeline.md`, and the audited `variant3d/tools/decode_donor_masks.py`.

Discipline: analysis only. No source/shader/config/asset/git edit, no Godot job, no donor binary executed. Donor at `C:\Games\Cossacks 3` was only *read* by the audited tool's own `--check`/dry-run paths; all three donor trees exist (`Test-Path` = True). The only file written by this worker is this report.

Four live, read-only observations (all wrote nothing — verified by `Test-Path` after each):

- **P1 `python variant3d/tools/decode_donor_masks.py --check`** → `CHECK SUMMARY: 18/18 PASS | parity=UNVERIFIED | no donor frame, no writes`. Inventory `1331 / 1856 / 1279`; `corpus_total 4466`; headers `320x320 desc=0x00` (vanilla, dlc5) and `256x256 desc=0x20` (src); `vanilla_starts 5125`; `vanilla_rg_nonstart_zero R sum=0 G sum=0`; `vanilla_b_spans_256`; V1–V7 all PASS; V2 transect `[0,1,7,31,97,194,246,254,255]` and `water_all=0.213857`; `three_water_notions deep=0.213827 class=0.174069 shore=0.221727`.
- **P2 two full real dry-runs** → both `DRY-RUN | masks=4466 | trees=3 | png_bytes=0 | … sha256=7ca159c5581146ae8b8daf6997f88d69951f599e3da9bf83f68544d29ea1a2b2 | visual_parity_claim=false`. Identical hash across two independent ~190 s runs; output directory absent afterwards.
- **P3 empty-corpus `--dry-run` and default (no flag)** → both `DRY-RUN … masks=0`, `OUT_EXISTS=False`.
- **P4 licence guard** `--game <donor> --out <inside donor> --write` → `REFUSED …`, `EXIT=2`, no probe directory created.

Anomalies were re-checked before any defect claim (see §3: each item lists ≥2 passes).

## 2. Per-item findings

### (1) Full-corpus coverage — PASS

- `TREES` :50-54 declares `(vanilla, terrainmasks, 320, 0x00, 1331)`, `(dlc5, terrainmasks.dlc5, 320, 0x00, 1856)`, `(src, terrainmasks.src, 256, 0x20, 1279)`. `1331+1856+1279 = 4466`, matching `EXPECTED_TOTAL` :64 and F04 §0.1.
- `discover()` :287-298 uses `root.rglob("*.tga")` for every tree and sorts each shape (`shapes[shape].sort(key=lambda p: p.name)` :296) — no count cap. `iter_paths()` :301-305 walks every discovered path in sorted order. `build_manifest()` :484-489 calls `analyse()` on every path and appends one record per mask.
- There is **no** `PER_TYPE`, `step`, `[:8]` or `[::n]` in the tool (grep returned zero matches). The legacy `import_donor_masks.py:37,78-86` subsample criticised in X19 §2.1/§3 G5 is not repeated.
- `--check` independently re-counts all three trees (`inventory/*` :319-322) and asserts `corpus_total` :357-358; live P1/P2 confirm `4466` in both check and manifest modes.
- Note: `*.removed` files are correctly excluded by the `*.tga` glob, consistent with F04 §3's TGA-only counts.

### (2) RLE 24-bit TGA, both orientations — PASS

- `parse_header()` :73-90 enforces `idlen=0`, no colour map, `itype=10`, `depth=24`, zero alpha bits, and derives `top_left = bool(desc & 0x20)` :90 — matches F04 E3-E5 / §4 and X18 X2-X4.
- `decode_tga()` :107-133 implements RLE packets (`count=(packet&0x7f)+1`; bit7 ⇒ repeated run with one BGR triple, else raw run), with truncation/overrun guards :115-131. BGR→RGB is the index swap `[:, :, [2, 1, 0]]` :139. Orientation: `arr[::-1]` when descriptor bit `0x20` is clear :136-137 (320² bottom-left → top-down); no flip for the 256² top-left masters. Trailing `TRUEVISION-XFILE.` footer (D03 E17) is harmlessly ignored.
- `run_check()` validates `w/h/desc` on **every** file per tree :323-331; live P1 shows `320x320 desc=0x00` for vanilla+dlc5 and `256x256 desc=0x20` for src. V5 :414-421 additionally asserts the `.src` master's 256²/0x20/binary-B shape, matching X19 V5 and F04 E5.

### (3) Height formula, `B>=58`, starts excluded — PASS

- Constants: `H_SCALE=-1.1`, `WATER_DEEP_B=58` (`h<-0.25 ⇔ integer B>=58`), `SHORE_B=24` :56-59, cited to `generatemap.inc:4-7,567` and `texturemap.inc:29-31` (F04 §6, X19 C-B).
- `analyse()`: `B=rgb[:,:,2].astype(np.int16)` :194; `white_mask` :192; `height=B.astype(np.uint8); height[white_mask]=0` :200-201 (lossless gray8 `v=B`, starts zeroed exactly as the donor zeroes them at `generatemap.inc:440-443,565-566`). The decode contract is emitted as `"height_m": "-1.1 * v / 255"` :245 and `"height": "DONOR_B … starts zeroed"` :256. No substituted relief/dither field is synthesised.
- Water: `b_ns = B[nonstart]` :205 (`:203` `nonstart=~white_mask`), `water_count = count_nonzero(b_ns >= WATER_DEEP_B)` :209, `water = water_count/n_nonstart` :232. `B>=58` with starts removed from numerator **and** denominator — this is X19 BUG-1/BUG-2 corrected. The tool uses no `B>58` in any computed field (grep: only the historical mention in the docstring :14 and the explicit fix note :532).
- Integer arithmetic re-derived independently: `-1.1*58/255 = -0.250196 < -0.25`, `-1.1*57/255 = -0.245882 > -0.25` ⇒ `B>=58` is exact. Live V2 :381-392 reports 22 pixels at B=58 and the F04/X19 transect verbatim; live `three_water_notions` :463-468 reports `deep=0.213827` (start-excluded) distinct from `water_all=0.213857` (all-pixel X19 E20 reference) and from `class=0.174069`, `shore=0.221727`. Three water notions kept distinct per X19 §0.5.
- `water_all_count` :212 includes starts; it is a separate diagnostic keyed `water_all` :248 and is **not** the manifest's `water` fraction. This is deliberate reconciliation of X19 §5.3 ("exclude starts") with X19 E20's all-pixel `0.213857` (see §3.4 for a labelling fix).

### (4) R/G forest semantics and both channel-facts — PASS

- Per-record `labels` :255-264 carry `"forest_density": None` :260 and `"forest_density_label": "[U] UNVERIFIED: G=0 on vanilla non-start pixels; no density invented"` :261; `relief_class_r` :262 and `forest_class_g` :263 are explicitly `[U] … donor intent, absent in shipped vanilla pixels`. No density-from-G or relief-from-R value is derived anywhere.
- Manifest-level `observations.C9_contradiction` :542-552 preserves **both** facts: `fact_observed` = F04/X18/X19 measured `R/G=0` on all non-start vanilla pixels with 5,125 white starts (`[O]`), and `fact_cited` = A02/`generatemap.inc` R-class / G-forest-stone codes on source bitmaps (`[U]` authored intent). `status = "PRESERVED — SWARM_BOARD C9 OPEN; both facts emitted, none silently chosen"`, `label = "[U] UNVERIFIED"`. `observations.forest_density` :553-557 repeats `value: None` + `[U]`, citing D07/F08 pattern placement rather than inventing a rule. `note` :511-513 carries "R/G class semantics [U]".
- This matches SWARM_BOARD C9 and spec §03:21-23 (`[U]` residue isolated; shipped-pixel truth authoritative; no parity claim). Neither side of the contradiction was deleted.

### (5) `.src` and `.dlc5` variants — PASS

- Both are first-class `TREES` entries :52-53 with their own size/descriptor/count, both traversed by `discover` :289-298, checked by `run_check` :319-331 (live P1: dlc5 1856 @ 320²/0x00, src 1279 @ 256²/0x20), decoded by `build_manifest` :484, and emitted with distinct output prefixes `height/{tree}/{shape}/…` :227 and `donor_trees` provenance rows :522-526.
- V5 :414-421 exercises the `.src` master; V7 :446-460 exercises two DLC5 grey-pixel masks (`continents/8pl_mask_continents_{8,9}_gauss.tga`, 7 starts, 4 grey px each) — live V5/V7 PASS. `source` :226 and `source_sha256` :235 distinguish trees per record.

### (6) Manifest schema and `visual_parity_claim:false` — PASS

- Record schema :229-265: `file`, `starts`, `water` (legacy keys preserved), plus `source`, `source_sha256`, `source_bytes`, `shape`, `tree`, `width`, `height`, `descriptor`, `start_components`, `start_pixel_count`, `height_encoding`, `water_all`, `water_class_fraction`, `water_shore_fraction`, `b58_pixels`, `nonstart_r_sum`, `nonstart_g_sum`, `b_distinct`, `labels`; `height_sha256`/`height_bytes` added at :493-494. This is the A03-style labelled index X19 §0/G14 called missing.
- Manifest :508-570: `version:1`, `source`, `note`, `types[tree/shape].masks`, `visual_parity_claim: False` :516, `provenance` (tool/version/licence/`derived_only`/`donor_trees`/`total_masks`/method/citations) :517-540, `observations` :541-564, and `parity` block :565-569 with `visual_parity_claim: False` :566, `status: "UNVERIFIED"`, note "No donor GPU A/B frame exists" :568.
- `note` :511-513 contains the literal `visual_parity_claim=false`. Live P1/P2/P3 all print `visual_parity_claim=false`.

### (7) Determinism and no donor-byte copying — PASS

- Ordering is stable: `iter_paths` sorts tree→shape→filename :301-305; `types` keys sorted and each `masks` list sorted by `file` :504-505; `white_components` uses `min(remaining, …)` and sorted output :169-184; `json.dumps(indent=1, ensure_ascii=True)` :604 with no timestamps anywhere. PNG writer :272-281 emits only IHDR/IDAT/IEND with fixed zlib level 9 :281 and computed CRCs — no metadata/time chunk.
- Live determinism: P2's two independent full 4,466-mask dry-runs produced byte-identical manifest SHA-256 (`7ca159c5…`) and P3's empty-corpus runs both produced `7f1e8c32…`.
- Only derived assets are written: gray8 height PNG at `out/rec["file"]` :496-499 and `mask_index.json` :607-609. Raw donor bytes are read into memory at :100 and used solely for `source_sha256`/`source_bytes` :235-236; no TGA is written. No subprocess/donor execution exists (grep: no `subprocess`, `os.system`, `Popen`, `eval`, `exec`). Licence guard :592-597 refuses `--out` inside the donor root; live P4 confirms `EXIT=2`, `REFUSED`, no directory created.

### (8) CLI semantics — PASS

- Flags :580-586: `--check` (self-test, writes nothing), `--dry-run` (explicit; already default), `--write` (emit derived assets). `do_write = write and not dry_run and not check` :590. `if args.check: return run_check(...)` :599-601 short-circuits all writes. Build path :603-609 writes only when `do_write`.
- Live: P1 `--check` = 18/18 PASS with no writes; P3 explicit `--dry-run` and no-flag default both `DRY-RUN … masks=0` with output dir absent; P2 real default runs `DRY-RUN … masks=4466` with output dir absent; P4 `--write` into donor root refused. Precedence (`--check` > `--dry-run` > `--write`) matches the help text. Two latent reporting gaps are recorded in §3.1-§3.2; neither changes the no-write guarantee or the exit code on currently valid donor data.

### (9) Forbidden constructs / parity claims — PASS

- No new donor constants are invented: the only constants are donor-cited :56-59 and F04/X19 corpus facts :63-64. No synthetic noise/dither, no lowered threshold (`B>=58`, not `B>58`), no assertion deleted, no fake A/B.
- Every derived field carries a label :255-264, :541-564; UNVERIFIED slots are `None` :260/:554 rather than guessed. `visual_parity_claim=False` at :516 and :566; `parity.status=UNVERIFIED` :567; summary strings `parity=UNVERIFIED` :472 and `visual_parity_claim=false` :613. Grep found no affirmative parity assertion. No donor GPU A/B frame exists and none is claimed.

## 3. Non-blocking observations and concrete fixes

Each was re-checked on ≥2 passes; all are latent or cosmetic on the present valid donor corpus. None changes the 9 verdicts.

**3.1 `--check` header generic PASS always fires (LOW, misleading output).** `run_check` :323-331: the `else:` at :330 is attached to the **outer** `for shape, paths` loop, while the `break` at :329 exits only the **inner** `for p` loop; the outer loop never breaks, so `record(f"header/{name}", True, …)` :331 always executes even after a specific header FAIL at :327-328. Passes: (a) line-by-line read; (b) isolated Python reproduction with exact indentation → `['innerfail','innerfail','outerelse']`; (c) live P1 — all donor headers valid, so the bad branch stayed latent and the line was correctly `PASS`. Fix: use a flag instead of `for…else`, e.g. `bad=False` :323, set `bad=True` at :327, replace :330-331 with `if not bad: record(f"header/{name}", True, …)`.

**3.2 Seven validation vectors are silently skipped if a donor file is missing (LOW/MED, check completeness).** `if p:` guards at :373 (V1), :383 (V2), :397 (V3), :407 (V4), :416 (V5), :465 (three-water-notions) have no `else:` branch; `by_rel` :360-364 returns `None` for a missing file. A `--check` on a partial donor install can therefore report a smaller denominator and still return 0. (V6 :437 and V7 :452 *do* record `MISSING` correctly.) Passes: (a) code read; (b) grep enumerating all 7 guard sites; (c) live P1 — all files present, so no skip occurred (latent). Fix: add to each guard `else: record("<name>", False, "MISSING <rel>")`, or assert the seven expected files exist before the vector block.

**3.3 `water_all` has no label and includes white starts (LOW).** :212/:248 count `B>=58` over all pixels, so the 4 white starts (B=255) count as water; the primary `water` :232 correctly excludes them. Live P1 shows both numbers (`water_all=0.213857` vs `deep=0.213827`) but `labels` :255-264 has a `water` entry :258 and no `water_all` entry. Fix: add `"water_all": "DONOR_B [D] B>=58 over ALL pixels INCLUDING white starts (X19 E20 reference 0.213857); not the start-excluded manifest water"` to `labels`, or rename the key `water_all_incl_starts`.

**3.4 Start label overstates connectivity as donor fact (LOW).** :257 labels `starts` as `"DONOR_WHITE [O] 8-connected components"`; the 8-connected merge of 1–2 px duplicates (`_NEIGHBOURS` :67, `white_components` :158-184) is a **PORT APPROXIMATION** per X19 C-D / §5.2 step 2, and the V6 comment :423 says "six near-duplicate starts" although X18 §6.1 corrected this to **five** near-duplicates + one prefix exception (`peninsulas_5`). Live P1 V6 prints `peninsulas_5 … 5/5`, consistent with the corrected reading. Fix: append `"; 1-2 px duplicate merging = PORT APPROXIMATION (X19 C-D)"` to the label and change the :423 comment to "five near-duplicate + one prefix-exception start masks (X18 §6.1)". The check logic itself is correct.

**3.5 `H_SCALE` is dead; `png_bytes` reads 0 in dry-run (LOW/cosmetic).** `H_SCALE=-1.1` :57 is never referenced (grep: single occurrence); the formula exists only as the string at :245 and label at :256. `png_bytes` :482 is incremented only inside `if do_write` :495-499, so dry-run prints `png_bytes=0` (P2/P3) rather than "would-be" bytes. Fixes: build the string from `f"{H_SCALE} * v / 255"` or drop the constant; accumulate `png_bytes` unconditionally and rename the printed field `would_write_bytes` in dry-run mode.

**3.6 Console mojibake (COSMETIC).** Live P2/P3/P4 print `PRESERVED ? SWARM_BOARD C9 OPEN` because the em dash in the status string :550 is rendered in a Windows non-UTF-8 console. The JSON payload uses `ensure_ascii=True` :604, so written assets are unaffected. Fix: use an ASCII hyphen in the status string or set stdout encoding.

## 4. Sign-off

All 9 contract items are satisfied with exact file:line evidence, corroborated by read-only live runs (`--check` 18/18; full 4,466-mask deterministic dry-run; no-write and donor-root guard checks). Six low-severity, non-blocking improvements are proposed above; none is a correctness failure on the present corpus and none was silently skipped.

**No donor visual-parity claim.** Formula/byte agreement with read-only donor data is reported as such; runtime activation of the `[*] = ;` DScript, native smoothing kernels, stage order, density-from-G and any px→world scale remain `[U]` UNVERIFIED (F04 §13, X18 §9, X19 §8, D03 §7, spec §03:23). No donor GPU A/B frame exists.

*End of V60. Exactly one report written. No code/asset/config/test/git edit, no Godot job, no donor binary executed or copied; donor touched only through the audited tool's read-only paths.*
