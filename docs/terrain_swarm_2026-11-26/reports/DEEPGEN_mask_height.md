# DEEPGEN-1 — MASK→HEIGHT path logic audit (READ-ONLY)

Scope: donor-derived law in `docs/terrain_swarm_2026-11-26/spec/03_MASK_TO_HEIGHT.md` (§1 donor mask truth, §2 height formula, §5 port bugs) + landed reports D03_mask_pipeline, F04_masks (via spec/X19 cites), X19_mask_decoder_gap, X54_ground_truth_card — traced against the PORT computation in `variant3d/scripts/terrain_donor_inputs.gd` and `variant3d/scripts/terrain_donor_gen.gd`. No code/Godot/git/donor-execution; no parity claim.

Donor law baseline (all [O] text/pixels, runtime activation [U]):
- L1: shipped vanilla `_gauss` masks: R=G=0 on every non-start pixel; only 5,125 single-pixel white starts (R=G=B=255); B spans all 256 values (spec/03:12-21; X54 row 2).
- L2: height `h = −1.1·B/255` (B=0→0 m; B=255→−1.1 m); water `h<−0.25` ⇔ integer **B≥58**; shore `h<−0.1` ⇔ B≥24 (spec/03:14-15,21; X54 rows 2,6; X19 §5.1).
- L3: start pixels: record on exact white (`fr=fg=fb=1`), then zero and skip before height decode (D03 §3.7/§4 steps 1,3 → `generatemap.inc:325,413-443,565-566`).
- L4: R→class / G→forest code table is authored donor intent, INERT on shipped masks; keep as schema, never derive relief counts or forest density from zero G on shipped data (spec/03:23,42-46; X19 C-A/C-E/C-G).
- L5: tile water/shore tag requires mask-B gate: `B>0 AND h<−0.25/−0.1` (`texturemap.inc:29-31,66-75`; D03 E10); coastal smoothing gate is water-CLASS (B==255) + radius-2 neighbourhood, not a height threshold (spec/03:36-40; X19 BUG-3).
- L6: resample is donor NEAREST `floor(x/W·srcW)` (X19 E14; spec via D2:409-411,541-542); offline gauss/noise is baked into `_gauss` assets, never re-run at load (D03 §3.2-3.3, E13).

## Step trace (port computation)

S1 — Mask load / channel read.
- Port: `terrain_donor_inputs.gd:674-684` `_load_image` (Texture2D→Image, file fallback); `:687-694` `_mask_bytes_from_image` reads `img.get_pixel(x,y).r*255` only; `:729-756` `_apply_mask` loads `ASSET_ROOT+masks/+rel`, asserts manifest size == image size (`:749-751`, else skip, no invention), resamples to requested w/h.
- Verdict: MATCHES L1/L6 **conditionally on the asset precondition**: `variant3d/assets/terrain_new/masks/mask_index.json:2` declares `gray8 v=B`; `:58-63` declares `height_m=-1.1*v/255`, `start_pixels=v=0 (donor zeroes starts after recording)`; `:64-75` carries `water` (starts excluded), `water_class_fraction` (B==255), `b58_pixels`, `nonstart_r/g_sum=0` with per-field labels. Single-channel `.r` read is therefore the B byte by construction. R/G class semantics are NOT read from pixels here — correctly so for shipped data (L4); `forest_density:null` + `[U]` label at `inputs.gd:796-797`.

S2 — Resample.
- Port: `inputs.gd:705-726` nearest `mini(m-1, floor(y·m/h))` default (`:715-717` labelled `[O]` D2:409-411/541-542); bilinear is an explicit opt-in comparison hook (`:718-726`, labelled `[U] PORT APPROXIMATION`, never donor truth).
- Verdict: MATCHES L6. No synthetic values on the default path. (Bilinear hook exists but is dormant unless `mask_resample_mode="bilinear"`.)

S3 — Start-pixel rule.
- Port (inputs): starts arrive as manifest normalised coords → donor-centred cells (`inputs.gd:766-778`); no per-pixel white detection here.
- Port (gen): `terrain_donor_gen.gd:1426-1451` exact-white `fr==1.0 and fg==1.0 and fb==1.0` record + zero + `continue`, with prev-only vs full-scan dedup branches (`:1424-1444`, labelled D2:329/417-435, no minimum-distance rule).
- Verdict: MATCHES L3 **at the asset level, FIXED**: asset PNGs carry starts pre-zeroed (`mask_index.json:62` `start_pixels=v=0`) and manifest `water` excludes starts (`:74` label; `water_all` vs `water` pair at `:20,64`). The gen exact-white detector is therefore a redundant safety net — inert on these assets (inputs supplies only `mask_b`; `mr/mg` fall back to zeroed container channels via `_channel`, `gen.gd:1530-1560`, so `fr==fg==fb==1` cannot fire on this path). Effect: start cells decode from v=0 → h=0, never −1.1. Old BUG-2 (white starts counted as water, `import_donor_masks.py:98` / X19 G2) is **fixed in this path by asset construction**, not by the gen detector. Residual note (not a bug): gen telemetry `mask_start_rule` (`gen.gd:1525-1526`) describes the detector as if live; on the mask_b-only path it never fires — labelled donor rule, harmless.

S4 — Height formula.
- Port: `gen.gd:1505` `hwater = C_WATER_HEIGHT*(fb*(1.0+fr*C_R_MULT))` with `C_WATER_HEIGHT=-1.1` (`:199`, `generatemap.inc:7`) and `C_R_MULT=3.5` (`:200`, `:567`); `:1506-1510` class×fr `hterrain` (`C_PLATEAU_HEIGHT=2.964` `:196`, `C_HILL_HEIGHT=2.964/2.25` `:197`, `C_RAVINE_HEIGHT=-2.964` `:198`); `:1511` `set_height(hwater+hterrain)` (D2:574). Height skip `b_random_map and fr==1 and fb==1` (`:1499-1504`, D2:565, fg ignored — asymmetry explicitly labelled).
- Verdict: MATCHES L2 + donor text D2:567-574. Sign is negative-correct; the stale "wrong-sign relief()" claim is correctly NOT acted on (`gen.gd:73-79,1498` cite X19 C-F). On shipped pixels fr=0 ⇒ `h=-1.1*B/255` exactly; R-term is schema-only and inert (L4 respected: `fdens` is side data, never mapped to counts, `:1471-1490,1513-1516` + P-PLACE-02 comments).

S5 — Threshold / water-class distinction.
- Port: three levels kept distinct — `_mask_water[i] = 1 iff ib==C_BCOLOR_WATER(255)` (`gen.gd:1493`, `generatemap.inc:486-487`); tile tag `b>0.0 and h<C_TILE_WATER_HEIGHT(-0.25)` / `h<C_TILE_SHORE_HEIGHT(-0.1)` (`gen.gd:1910-1911`, D4:68-74); coastal gate reads `_mask_water` radius-2 5×5 (`gen.gd:1654-1662`, D2:621-637). Old `mapgen.gd:126` `height<0.8` global gate is ABSENT here.
- Verdict: MATCHES L5. Old BUG-3 (G3) **fixed in this path**. Old BUG-1 (`B>58`, X19 G1): **absent** — no `>58` occurs in either file; boundary is enforced via the float tag `B>0 ∧ h<−0.25`, which for R=0 is arithmetically ⇔ B≥58 (margin at B=58: h=−0.250196, far above f64 epsilon). Observation (not a divergence): `C_WATER_BYTE=58` (`gen.gd:215-216`, `MASK_B_WATER_BYTE=58` in inputs `:80`) is **defined but never consumed** by any comparison; the integer B≥58 rule is emergent, not asserted. No manifest-style `water_fraction` is recomputed in gen (it is read from the manifest labels) — correct, no second off-by-one source.

S6 — Clamp / smoothing interaction with height array.
- Port: `_smooth_custom` gates `h∈[minh,maxh]` (`gen.gd:1638`, D2:236), skips flat neighbourhoods (`:1645`), applies `h+((avg−h)/power)` then Lerp (`:1649-1650`, D2:240-241) incl. coastal effective 1.428571 telemetry (`:1614-1615`); land pass power=4/lerp=0.5, coastal 3× power=0.35/lerp=0.5 band [−100,−0.01] (`:1600-1608`); bsmooth native kernel stays a NULL hook + SKIPPED telemetry (`:1581-1590`, D03 U3, N17-G11 — no blur substituted).
- Verdict: MATCHES donor text gates/coefficients. No height clamp/fudge beyond donor bands; `data.set_height` quantisation is I06-side and out of scope → [U] downstream (see blocking list).

S7 — Synthetic field check.
- Port: explicit no-synthesis statements (`inputs.gd:17-18`, `gen.gd:88`, `:1391,1396` no Gaussian/noise, `:1552` absent channels zeroed with note, `:1589-1590` no blur substituted); `_hash32` is a stable selector, labelled NOT noise (`inputs.gd:430-436`); land→nowater2 alias only (`inputs.gd:74`); use_port_water_sentinel defaults false (`gen.gd:675`).
- Verdict: MATCHES — no synthetic noise/dither/fudge constant introduced in the MASK→HEIGHT path. (Comparison-only bilinear/double-buffer/f32 hooks exist but are dormant and labelled.)

## Known-bug disposition

- BUG-A (`B>58` vs `h<−0.25` boundary): FIXED in this path. No `>58` in either file; manifest stores corrected `water` (starts excluded) + `b58_pixels` + `water_class_fraction` (`mask_index.json:20,64-67`); gen enforces the donor float gate (`gen.gd:1910-1911`). `C_WATER_BYTE/MASK_B_WATER_BYTE=58` constants are present and correctly labelled (`gen.gd:215-216`; `inputs.gd:80`) but unreferenced — document, do not "fix" by adding a redundant integer gate.
- BUG-B (white start pixels counted as water): FIXED in this path by asset construction (starts zeroed to v=0 in PNG, excluded from manifest water). Gen's exact-white zero+skip (`gen.gd:1431-1451`) is present and correctly labelled but inert on the mask_b-only input — defence in depth, not the fix mechanism. No unlabelled water-count contamination remains in these two files.

## UNVERIFIED register [U] (blocking)

1. Runtime execution of `;`-prefixed DScript (`generatemap.inc`/`texturemap.inc`) in the shipped build — donor text only (D03 U2; X19 U1).
2. Native `SmoothTerrain(x,−y,False,3)` kernel — hook NULL/SKIPPED (`gen.gd:1583-1590`); no substitute invented, stage incomplete by design (D03 U3).
3. Stored-height unit/quantisation of `data.set_height` (I06 setter) — donor float precision/engine rounding unproven (D03 §5.2 DERIVED note; X54 §3).
4. `fa`/`broad` road branch absent in 24-bit TGAs — omitted, labelled (`gen.gd:1527,1898`; X19 U4).
5. Forest/stone density derivation from G — enum kept as side data only; placement-stage source stays [U] (spec/03 §4; X19 U3; `gen.gd:974` U-G0 probe).
6. Seed/stream position feeding this stage (key0 discard is [O]/[D]; per-map derivation timing [U]) — does not alter the mask→height arithmetic but gates reproducibility (spec/02; X54 row 1).

Parity: UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD — blocking_unverified non-empty (items 1-6 above); no parity claim. No value invented; every [U] above carries its terminating probe owner (D03/D01/X19/X54 refs in code comments).
