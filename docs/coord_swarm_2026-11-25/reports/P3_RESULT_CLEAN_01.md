---
id: P3-RESULT-CLEAN-01
title: "Quarantine stale false-green P3 result t_terrain_mines.json"
owner: P3-RESULT-CLEAN-01 (result-artifact cleanup worker)
date: 2026-11-25
status: DONE__QUARANTINED_OUTSIDE_REPO__NO_RUNNER_JOB
scope: "Move-only quarantine of variant3d/tests/results/t_terrain_mines.json plus this report. No atom, other result JSON, manifest, game code or queue state was touched; no Godot job was submitted."
owns:
  - "variant3d/tests/results/t_terrain_mines.json (move only)"
  - "docs/coord_swarm_2026-11-25/reports/P3_RESULT_CLEAN_01.md"
labels: [RESULT_JSON, FALSE_GREEN, QUARANTINE, P3, STALE, CLEANUP]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
---

# P3-RESULT-CLEAN-01 — quarantine the stale false-green `t_terrain_mines.json`

## 1. Evidence — false-green signature confirmed

Source of truth read directly from the JSON (`python` 3.14, `python -c`, not `python3`) plus the two cited reports.

| Field | Value in `variant3d/tests/results/t_terrain_mines.json` |
|---|---|
| `id` | `t_terrain_mines` |
| `passed` | `true` |
| `passes` / `total` | `13` / `13` |
| `headless` | `true` |
| `status` | `HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED` |
| `verdict` / `capture_status` | absent / absent |
| `png.written` | `false` |
| `png.size` | `[0, 0]` |
| `png.path` | `C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/results/t_terrain_mines.png` (never produced) |
| `unix_ms` | `1795597259289.0` |
| `atom_completed.check.detail` | `structural assertions completed; capture stage pending` |

Three checks are `passed:true` while their own status says the visual work never ran (observed verbatim):

- `png_capture_windowed` → `HEADLESS_SKIP__PNG_UNVERIFIED` — `headless guard: 3D PNG readback skipped (no GPU canvas)`
- `ground_luma_variance_outside_mine_bbox` → `UNVERIFIED` — `headless guard: no two-frame A/B available`
- `no_z_fighting_seam_visual` → `UNVERIFIED__VISUAL_REVIEW_REQUIRED` — `headless guard: no PNG for second-agent visual review`

Mtimes (observed, `Get-Item`; local time = UTC+1 on this host):

| Item | Local | UTC | Size |
|---|---|---|---|
| result JSON | 2026-11-25 10:00:59 | 2026-11-25 09:00:59Z | 4618 bytes |
| source atom `variant3d/tests/t_terrain_mines.gd` | 2026-11-25 11:36:50 | 2026-11-25 10:36:50Z | 33135 bytes |

**Derived:** source is newer than the result by ~5751 s (matches `QA_ATOM_STALE_02.md:44`), so the JSON certifies pre-edit source only. The 13/13 green is inflated by the three headless guard rows; it is a structural-only artifact, not a structural **and visual** PASS.

Corroboration:

- `docs/coord_swarm_2026-11-25/reports/QA_ATOM_STALE_02.md:104-118` — the *only* `passed:true` + `headless:true` false-green among 65 result files; HIGH-1 at `:124-125` calls for a **windowed** P3 ladder row and says not to carry `passed:true`/13-of-13 forward.
- `docs/coord_swarm_2026-11-25/reports/DARKROW_REPAIR_01.md:96-104` — result unchanged at 10:00:59 with the same fields; "parse-green jobs do not refresh it"; instruction to COORD: delete/ignore the stale artifact and let a fresh windowed P3 ladder row regenerate it. The parse failure at job 497 was fixed and job 501 (`darkrowall-t_terrain_mines-r2`) passed `--check-only` (`:65,:70`), but that is parse evidence, not a visual result (`:108-109`).
- `t_terrain3d.json` mtime 2026-11-25 10:31:28 local; it is a different atom's result and was not involved.

## 2. Exact move / quarantine

No contents were edited. The operation was a single `Move-Item` from the repo to a temp path outside the repo (PowerShell, run with cwd = repo root):

```powershell
$qdir = Join-Path $env:TEMP 'opencode\quarantine'
$dst  = Join-Path $qdir 't_terrain_mines.stale.json'
New-Item -ItemType Directory -Path $qdir -Force | Out-Null
Move-Item -LiteralPath 'variant3d\tests\results\t_terrain_mines.json' -Destination $dst
```

`$env:TEMP` resolves to `C:\Users\Maxym.Oboyshev\AppData\Local\Temp`, giving the resolved destination:

`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\quarantine\t_terrain_mines.stale.json`

The quarantine directory did not exist before this ticket and was created; the destination did not previously exist, so nothing was overwritten.

## 3. Verification

| Check | Result |
|---|---|
| `Test-Path variant3d\tests\results\t_terrain_mines.json` after move | `False` — file no longer in `results/` |
| `Test-Path` quarantine destination | `True` |
| SHA-256 before move | `40204A9DF74A9137EA3E57BF2B43716814A96350812343DCAE51BFE5D5B15DCD` |
| SHA-256 after move | `40204A9DF74A9137EA3E57BF2B43716814A96350812343DCAE51BFE5D5B15DCD` — byte-identical, contents untouched |
| Byte count / mtime after move | 4618 / `2026-11-25T09:00:59.2924301Z` — unchanged |
| Result JSONs in `results/` | 64 before → 63 after; exactly one removed |
| Hash comparison of the 63 remaining result JSONs vs pre-move snapshot | 0 changed, 0 added; includes `t_terrain3d.json` (`E00B6C3B38C5707852BAFA3189FD5A678EAF7306637240D65EA4226C3E6416B5`) |
| Atom `variant3d/tests/t_terrain_mines.gd` | still present, mtime still `2026-11-25T10:36:50.1087669Z`; not edited |
| Runner / queue state | no job submitted, no queue mutation |

**No other file changed.** The only repository changes made by this worker are the removal of the one quarantined result JSON and the creation of this report. No atom, other result JSON (including `t_terrain3d`), manifest, game code, backup or queue state was modified, and no runner job was submitted.

## 4. Rationale

A `passed:true`, 13/13 artifact whose three visual checks are headless skips, with no PNG and a source edited ~95 minutes later, would still read as "P3 PASS 13/13" to any consumer of `results/`. Removing it from the canonical results directory eliminates that false green while preserving the exact bytes in an out-of-repo quarantine for audit. Regeneration must come from an actual windowed run — a parse-only green cannot substitute for the PNG and runtime luma gates.

## 5. Open question

A fresh **windowed** P3 ladder row belongs to the COORD ladder (not to this cleanup worker). Until it lands, there is no valid machine-readable P3 result. It must produce a real PNG and genuinely evaluate `png_capture_windowed`, `ground_luma_variance_outside_mine_bbox` and `no_z_fighting_seam_visual`; the caller must not carry `passed:true`/13/13 forward from the quarantined artifact. The `>=40` / `>=100` luma gates remain PORT APPROX with no donor GPU A/B (`DARKROW_REPAIR_01.md:110-111`), and whether the headless guard rows should count as passes at all is still open (`QA_ATOM_STALE_02.md:153`) — a windowed re-run may mask rather than correct that counting pattern.
