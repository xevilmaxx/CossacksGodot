---
id: RCODE-FIX-01
title: "Exact donor R-code decode implemented in variant3d/scripts/mapgen.gd"
agent: "RCODE-FIX-01 (implementation builder, coord swarm 2026-11-25)"
date: 2026-11-25
status: IMPLEMENTED__VARIANT_RUNNER_VALIDATED__SCRIPT_ERROR_0__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, UNVERIFIED]
owner_files:
  - variant3d/scripts/mapgen.gd
  - docs/coord_swarm_2026-11-25/reports/RCODE_FIX_01.md
donor: "READ-ONLY; no donor file copied, executed or modified"
backup: inbox/backup/mapgen.gd.bak-RCODEFIX01
parity_claim: false
---

# RCODE-FIX-01 — exact donor R-code decode

## 1. Reconciliation of the two donor reports (done before editing)

Both reports agree on the same live donor formula; there is **no substantive
difference in truth**. The apparent conflict is textual, not numeric.

- **HEIGHT-GEN-DEEP-01** (`reports/HEIGHT_GEN_DEEP_01.md:309-345`, §4.3) says the
  live amplitudes at R=96 and R=48 are `+0.495937258` and `−0.557929397`
  because the suffixes `//*(255/cRColorHill)` and `//*(255/cRColorRavine)` on
  `generatemap.inc:571-572` are `//`-disabled. It explicitly warns that older
  docs' `+1.317`/`−2.964` expect those disabled multipliers.
- **RCODE-DEEP-01** (`reports/RCODE_DEEP_01.md:112-125`, §2; `:230-243`, §3.2;
  `:451-459`, §6) uses the same class×`fr` values: R=96 → `+0.495937`,
  R=48 → `−0.557929`, R=88 → `−1.022871`, R=191 → `+2.220094`. Its §5.1 table
  lists `−2.964`/`+1.317` as **port outputs**, not donor truth. Its §2
  "full class amplitude at `fr=1`" phrase refers to byte normalisation
  (`255/255`), not to R=48 reaching `−2.964`.

Verified read-only against the donor source itself this pass:

- `generatemap.inc:21-27` — `cRColorPlateau=255`, `cRColorHill=96`,
  `cRColorRavine=48`, `cRColorSmooth=128 div 2 (64)`,
  `cRColorPlateauSmooth=191`, `cRColorHillSmooth=112`,
  `cRColorRavineSmooth=88`.
- `generatemap.inc:342-344,352-370` — `ir = floor(fr*255)`; exact-byte
  `case ir of`: `255,191 → cRPlateau` (`bsmooth = ir=191`), `96,112 → cRHill`
  (`bsmooth = ir=112`), `48,88 → cRRavine` (`bsmooth = ir=88`), else
  `cRNone` with `bsmooth = (ir=64)`. Intermediate bytes get no class.
- `generatemap.inc:569-574` — `hterrain := cPlateauHeight*fr` (`:570`),
  `cHillHeight*fr;//*(255/cRColorHill)` (`:571`),
  `cRavineHeight*fr;//*(255/cRColorRavine)` (`:572`); `//` disables the
  multipliers; `SetHeightData(..., hwater+hterrain)` at `:574`.
- `generatemap.inc:587-592` — `SmoothTerrain(realx, -realy, False, 3)` for
  every `bsmooth` cell. Its native kernel is **UNVERIFIED** (both reports).

**Decision:** use the disabled-multiplier-free `class × (R/255)` lattice from
both reports. The disabled multipliers were not used as truth.

## 2. Change made (only `variant3d/scripts/mapgen.gd`)

1. `relief()` (`:63-73` pre-edit) replaced with the exact 8-code decode:
   `roundi(v)` recovers the authored byte from the float channel; `255/191 →
   C_PLATEAU*(code/255)`, `96/112 → C_HILL*(code/255)`, `48/88 →
   C_RAVINE*(code/255)`, everything else (including 64, 250-254 and all
   intermediate bytes) → `0.0`. No `±12` bands, no `×0.5` ramp.
2. `relief_smooth(v) -> bool` added: true for `{64, 88, 112, 191}` per
   `generatemap.inc:354,358,362,367`. Code 64 is included because the donor
   flags it `bsmooth` even though it has no relief class.
3. `build()` now allocates a `PackedByteArray` `relief_smooth`, fills it at the
   same per-cell site as `height` (`:211`), and returns it as a new dictionary
   key in all three return paths. **Data only** — no smoothing kernel was
   invented, because the donor kernel is native and UNVERIFIED.
4. Untouched: `C_WATER/C_PLATEAU/C_HILL/C_RAVINE` constants (`:25-28`), the
   `hw` water formula (`:186`), the white-start skip (`:174-175`), the coastal
   passes (`:191-208`), `pick()` seed stream (`:51-61`), and all of `game.gd`.

### Before → after, all 8 codes (`hterrain` only; water term unchanged)

Values are GDScript float64 results; donor figures are float32 from
`HEIGHT_GEN_DEEP_01:316-324` and `RCODE_DEEP_01:112-121`. Differences below
`1e-6` are float32 rounding.

| R | donor class | donor `hterrain` (f32) | before (port) | after (port) | before verdict |
|---:|---|---:|---:|---:|---|
| 0 | none | 0.000000 | 0.000000 | 0.000000 | match, kept |
| 48 | ravine | −0.557929397 | −2.964000000 | −0.557929412 | 5.3× too deep → fixed |
| 64 | none (smooth) | 0.000000 | +0.371952941 | 0.000000 | invented relief → fixed |
| 88 | ravine smooth | −1.022870660 | +1.317333333 | −1.022870588 | sign flip → fixed |
| 96 | hill | +0.495937258 | +1.317333333 | +0.495937255 | 2.66× too high → fixed |
| 112 | hill smooth | +0.578593493 | +0.650917647 | +0.578593464 | wrong branch → fixed |
| 191 | plateau smooth | +2.220094204 | +1.110047059 | +2.220094118 | exactly halved → fixed |
| 255 | plateau | +2.963999987 | +2.964000000 | +2.964000000 | match, kept |

`relief_smooth` flags: `{64,88,112,191} → true`, `{0,48,96,255} → false`;
intermediate bytes (e.g. 94, 111) and 250–254 → `0.0` relief / false flag.

## 3. Backup

`inbox/backup/mapgen.gd.bak-RCODEFIX01` created before the edit via
`Copy-Item -Force`. Pre-edit file and backup SHA-256 are identical:
`FEB6A4D66734D50D0ED2739B2514ED7AF88EAD3013EC431AB53250027BBB961F`.
Post-edit `variant3d/scripts/mapgen.gd` SHA-256:
`D828EC90B3EE643B43B79B086FD30521E530CEC7A8E55B31DDBA92F576A25790`.
No other backup or file was touched by this ticket.

## 4. Validation (variant runner only)

No direct `godot`, no gates, no ladder, no queue mutation, no re-submit loops.
Both jobs were single submissions through
`python variant3d\tools\godot_runner.py run --id <id> --timeout 300 --max-wait 3600 -- …`.

| Ticket | Job id | Command (after `--`) | Result | Wait / run | Artifacts | SCRIPT ERROR |
|---:|---|---|---|---|---|---:|
| 558 | `rcodefix01-smoke` | `--headless --path variant3d --check-only --script res://scripts/mapgen.gd` | **`ok` / exit 0** | 1025.45 s / 5.67 s | `variant3d/.godot_queue/results/00000558_rcodefix01-smoke/{stdout.txt (75 B, Godot 4.7.2 banner only), stderr.txt (0 B)}` | **0** |
| 564 | `rcodefix01-probe` | `--headless --path variant3d --script C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/rcodefix01_probe.gd` | **`ok` / exit 0** | 450.28 s / 4.88 s | `variant3d/.godot_queue/results/00000564_rcodefix01-probe/{stdout.txt (873 B), stderr.txt (0 B)}` | **0** |

`SCRIPT ERROR` counted by `Select-String` over both jobs' stdout and stderr:
**0 matches**. `--check-only` proves parse/compile validity only; the runtime
assertions come from job 564.

### 4.1 Exact height-band evidence (job 564 stdout, verbatim values)

```
R=0   hterrain=0.0              want=0.0              bsmooth=false want=false PASS
R=48  hterrain=-0.55792941176471 want=-0.557929397   bsmooth=false want=false PASS
R=64  hterrain=0.0              want=0.0              bsmooth=true  want=true  PASS
R=88  hterrain=-1.02287058823529 want=-1.022870541   bsmooth=true  want=true  PASS
R=96  hterrain=0.49593725490196  want=0.495937258    bsmooth=false want=false PASS
R=112 hterrain=0.57859346405229  want=0.578593493    bsmooth=true  want=true  PASS
R=191 hterrain=2.22009411764706  want=2.220094204    bsmooth=true  want=true  PASS
R=255 hterrain=2.964             want=2.963999987    bsmooth=false want=false PASS
R=94  unclassed -> 0.0 PASS
R=111 unclassed -> 0.0 PASS
R=250 unclassed -> 0.0 PASS
R=254 unclassed -> 0.0 PASS
PROBE determinism cells=4096 identical=true smooth_key=true PASS
PROBE_DONE fails=0
```

Tolerance was `2e-6` (float32 donor figures vs float64 GDScript arithmetic);
largest observed deviation is `8.7e-8` at R=191. All 8 codes, four
non-listed bytes, the smooth flags and determinism passed; `fails=0`, exit 0.

**Determinism:** `C3MapGen.build("land", 424242, 64, 64, 1.0, "high")` was
called twice in the same process; all 4,096 `height` cells and all 4,096
`relief_smooth` bytes were identical (`identical=true`). The `pick()` seed
stream, `hw` term, white-start gate and quality passes were not changed.

## 5. No-weakening / no-parity statement

- This change **weakens no existing behaviour**: both previously correct codes
  (0 and 255) keep their values; the water term, start detection, seed stream,
  coastal smoothing and all downstream consumers are unchanged. The only
  behavioural change is that 6 of 8 codes now return donor-derived values
  instead of the port's band/ramp values, plus an additive dictionary key.
- **No donor parity claim**: the donor engine was not run, no donor frame
  exists, no donor file was copied, and the native `SmoothTerrain` kernel is
  UNVERIFIED. This is a donor-grounded source fix, not a visual match proof.
- **No other file edited**: `game.gd` (RELIEF-LIVE-FIX-01 owner), tests, config,
  `app/**`, assets, donor files and queue files were not modified. The probe
  script lives only in `%LOCALAPPDATA%\Temp\opencode`.

## 6. Open questions / follow-ups

1. **Smooth hook not wired (carried as data only).** The donor's
   `SmoothTerrain(realx,-realy,False,3)` (`generatemap.inc:587-592`) is a
   native routine whose stencil is UNVERIFIED. Implementing it here would mean
   inventing a kernel — explicitly out of scope. The `relief_smooth` array is
   returned so a later owner can wire a reviewed operator; that is a follow-up,
   not a silent omission.
2. **Cell averaging remains a port approximation.** `build()` averages all
   source pixels mapped into a cell (`:170-184`); the donor decodes one exact
   byte per cell (`generatemap.inc:541-543`). `roundi()` makes exact bytes
   round-trip but an averaged cell can land on a class the donor would not
   assign. Fixing the sampler is a separate, larger change (HEIGHT-GEN-DEEP-01
   §6 row 3) and was deliberately not made here.
3. **Latent vs live.** Shipped skirmish masks are almost entirely R=0
   (RCODE-DEEP-01:430-438), so this fix changes base relief only for
   relief-bearing bitmaps; the live stamp/clamp path stays with `game.gd`.
   No live-frame effect is claimed.
4. **`hterrain` zero-init for `cRNone`** remains UNVERIFIED at Delphi level
   (`generatemap.inc:568-573` has no `else`); both reports derive `0.0` from
   the baked `.map` lattice. The port uses `0.0`.
5. **2D mirror not touched.** `app/scripts/mapgen.gd:63-73` carries the old
   body but is outside this ticket's ownership; mirror only if that tree is
   in scope.
6. **Final donor clamp** remains UNVERIFIED (HEIGHT-GEN-DEEP-01 §8 Q1).

## 7. Summary

The exact donor 8-code R decode is now in `variant3d/scripts/mapgen.gd`: six
divergent codes corrected, two already-correct codes preserved, a donor-cited
`relief_smooth` flag exposed without inventing a kernel, no seed or downstream
behaviour changed, no other file edited. Backup taken. Variant-runner jobs 558
(`rcodefix01-smoke`, parse) and 564 (`rcodefix01-probe`, runtime) both ended
`ok` / exit 0 with **SCRIPT ERROR == 0**; the probe passed all 8 code bands,
four non-listed bytes, all smooth flags and a 4,096-cell determinism check
(`fails=0`). Honest limitations (smooth operator not wired, cell averaging,
latent-vs-live scope, no donor parity) are recorded in §5–§6.

---

*End of RCODE-FIX-01.*
