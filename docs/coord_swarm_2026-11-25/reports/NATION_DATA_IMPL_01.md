---
id: NATION-DATA-01
owner: NATION-DATA-01 implementation subagent
date: 2026-11-25
status: IMPLEMENTED — runner smoke ok/exit 0 (parse-only); static probe pass
scope: "One additive line in variant3d/scripts/data.gd NATION_UNITS. No other repo file edited except this report and the backup."
owner_files: ["variant3d/scripts/data.gd", "docs/coord_swarm_2026-11-25/reports/NATION_DATA_IMPL_01.md"]
backup: "inbox/backup/data.gd.bak-NATIONDATA01"
plan: "docs/coord_swarm_2026-11-25/reports/NATION_DATA_01.md"
parity_claim: none
---

# NATION-DATA-01 — implementation report: donor-correct Bavaria `NATION_UNITS` entry

## 1. What changed (before → after)

Owner file: `variant3d/scripts/data.gd`, `const NATION_UNITS` block (plan cited `:294-305`; current 1-based `:294-306` after the insert).

Before (byte-exact backup):

```gdscript
	"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},
	"ukr": {"priest": "pope"},
```

After:

```gdscript
	"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},
	"bav": {"serdiuk": "musketeer", "cossack": "hussar"},
	"ukr": {"priest": "pope"},
```

Exactly one inserted line:

```
+	"bav": {"serdiuk": "musketeer", "cossack": "hussar"},
```

No value, default, comment, banner, signature or logic was changed. `resolve_sid()` (`data.gd:1564-1567`) is untouched; it now reads the new `bav` dictionary via `NATION_UNITS.get(nat, {})` and accepts both targets because both have `UNITS_BASE` rows.

## 2. Donor citations (first-hand, donor READ-ONLY)

The donor file was opened as bytes and decoded `latin-1` with `python` 3.14; nothing was copied or executed.

| Pair | Donor evidence (first-hand this pass) | Plan citation |
|---|---|---|
| `bav.serdiuk → musketeer` | `C:\Games\Cossacks 3\data\scripts\lib\country.script:2700`: `if (fra) or (eng) or (swe) or (pru) or (ven) or (den) or (bav) or (sax) or (por) or (pie) or (swi) then _country_AddMember(country, 'musketeer', …)` — **`bav` is in the 17c musketeer roster.** | `NATION_DATA_01.md:82` (C:2700), `:138` |
| `bav.cossack → hussar` | `country.script:2754`: `if (aus) or (fra) or (eng) or (spa) or (rus) or (pol) or (swe) or (ven) or (den) or (net) or (bav) or (sax) or (por) or (pie) then _country_AddMember(country, 'hussar', …)` — **`bav` is in the hussar roster.** | `NATION_DATA_01.md:83` (C:2754), `:139` |

Corroboration: `NATION_DONOR_01.md:105` (bav row) and its G1 finding `:181` ("`bav` has no key → identity"). The two substitutions are role-derived from roster membership (`NATION_DATA_01.md:138-139`), not asserted as explicit table rows by the planning reports; no donor/visual parity is claimed.

Port-side conditions (`NATION_DATA_01.md:39-44`): both targets satisfy both gates.

| Target | `UNITS_BASE` row (first-hand) | OBJ asset (first-hand `Test-Path`) |
|---|---|---|
| `musketeer` | present — `data.gd:813` top-level key; probe counted 62 top-level keys in `UNITS_BASE` | `variant3d/assets/models/obj/musketeer.obj` — exists, 79,828 bytes |
| `hussar` | present — `data.gd:852` top-level key | `variant3d/assets/models/obj/hussar.obj` — exists, 64,950 bytes |

Therefore `resolve_sid()` accepts both (`UNITS.has(r)`) and the renderer's nation probe (`world3d_entities.gd`, per `NATION_DATA_01.md:29,141`) has a real mesh stem to select.

## 3. Backup

- Created **before** the edit: `inbox/backup/data.gd.bak-NATIONDATA01`, byte-exact copy via `shutil.copyfile`.
- Source and backup SHA-256 both `b7f5fbdee0f8a6c694c944b89d2533d9aac3ed06e9f83b53d7c00d8b7c519efd` at creation (88,067 bytes; 1,617 CRLF / 1,617 LF).
- Post-edit current SHA-256 `89b1519d5cca412b4572b657ad40572a2b8d94c95855050f369310e2f9f1e919` (88,123 bytes; 1,618 CRLF / 1,618 LF).

## 4. Byte-level diff proof — `rus` no-op and MORALE-02 preservation

Verified with `difflib.SequenceMatcher(autojunk=False)` over UTF-8 `splitlines()` of backup vs current, plus raw-byte replacement (script: `%LOCALAPPDATA%\Temp\opencode\nationdata01_verify.py`; full result also saved as a temp artifact):

| Check | Result |
|---|---|
| Change operations | **1** (`insert`), 0 deletes, 0 replaces |
| Added lines | **1** — exactly `\t"bav": {"serdiuk": "musketeer", "cossack": "hussar"},` |
| `rus` row occurrences backup/current | **1 / 1**, exact same bytes; index 294 in both |
| `bav` immediately after `rus` | `True`; absent from backup, present in current |
| Line count backup/current | 1,617 → 1,618 (CRLF count 1,617 → 1,618; line ending style preserved) |
| `NATION_UNITS` block line count backup/current | 12 → 13 (header + rows + closing brace) |
| **Removing the one inserted line reproduces the backup byte-for-byte** | `True` |
| MORALE markers `PORT_MORALE_FAMINE_ENABLED` / `MORALE_BASE` / `MORALE_FAMINE_PENALTY` occurrence counts backup/current | 2/2, 1/1, 1/1 |

The last two rows are the decisive `rus` / no-op proof: no other byte in the file changed, so every MORALE-02 banner, marker and constant remains byte-identical. This uses **content**, not line numbers — inserting at `:296` shifts later line numbers (e.g. the XP/constants block) while leaving its bytes unchanged, exactly as warned in `NATION_DATA_01.md:158-164`. No attempt was made to re-check any line-number-based claim.

Note: `git diff -- variant3d/scripts/data.gd` on this working tree is **not** a clean one-line diff, because `data.gd` was already modified by earlier agents (MORALE-02 et al.; 46 changed lines in the pre-existing diff) before this task began. The correct baseline for this ticket is the pre-edit backup, and that comparison is the one-line diff proved above. Those pre-existing changes are not attributed to this ticket.

## 5. Validation

### 5.1 Read-only static probe — PASS

Script: `%LOCALAPPDATA%\Temp\opencode\nationdata01_probe.py` (outside the repo; no repo test file created). Artifact: `%LOCALAPPDATA%\Temp\opencode\nation_data_01_probe.json`. It reads only; it does not run Godot and does not modify the project.

All checks passed (`ALL_CHECKS_PASS = true`):

- `rus` line exact and present once; `bav` line exact, present only in current, immediately after `rus`;
- `UNITS_BASE` has top-level `musketeer` **and** `hussar` (62 top-level keys — matches `NATION_DATA_01.md:21`);
- both `obj/musketeer.obj` and `obj/hussar.obj` exist and are non-empty;
- `NATION_UNITS` block grew by exactly one line.

One initial run reported `ALL_CHECKS_PASS = false` solely because of an off-by-one in the probe's own expected block-line count (11→12 instead of the correct 12→13 including header and closing brace); the assertion was corrected and re-run. No data condition changed.

### 5.2 Variant runner smoke — see final job result appended below

Variant runner only, unique id `nationdata01-smoke`, parse/compile smoke (not runtime proof):

```
python variant3d\tools\godot_runner.py run --id nationdata01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/data.gd
```

`--max-wait 1800` follows the precedent in `CONFIG_CORE_01.md:81` / `CONFIG_WIRE_CAM.md:108` because the variant spool had 10 pending jobs at submission (`godot_runner.py status`: `next_ticket 542`, pending `[532..541]`). No direct `godot` call, no 2D runner, no `doctor`, no gate weakening.

Result: **ticket 542, `status=ok`, `exit=0`** (runner output `START (waited 1053.04s)` / `END ok (run 20.33s)`). Artifact `variant3d/.godot_queue/results/00000542.json` records `argv` exactly as above, `wait` 1053.04 s, `run` 20.33 s, `exit` 0.

- `stdout.txt`: 75 bytes — Godot Engine v4.7.2 banner only, no diagnostics.
- `stderr.txt`: 0 bytes.
- `SCRIPT ERROR` lines: **0**.

### 5.3 Honest interpretation of the runner result

`--check-only --script res://scripts/data.gd` is a **parse/compile check**, not a runtime test (`CONFIG_PIPELINE.md:310,325`; `CONFIG_CORE_01.md:94-97`). It proves the edited `data.gd` parses cleanly under Godot 4.7.2 with zero script errors. It does **not** execute `resolve_sid()`, does not train a unit, and does not render a mesh. The long 1053 s wait was queue contention (10 pending jobs at submission), not a hang or a failure. No full selftest/uitest gate was run in this ticket (those are separate owner gates), so no 29/29 or 17/17 claim is made. The pre-existing red gate remains **28/29 on `build`** per `RUN_GUIDE.md:57` and `NATION_DATA_01.md:30,181`; it is not attributable to this one-line data insert and is not reported as a pass. No gate was weakened and no direct `godot` call was made.

## 6. Scope / other files

**No other repo file was edited.** Specifically untouched by this ticket: `variant3d/scripts/game.gd`, `variant3d/config.json`, `variant3d/scripts/world3d_entities.gd`, all files under `variant3d/tests/`, all files under `app/**`, all other scripts and reports. The only repo writes are `variant3d/scripts/data.gd` (one inserted line), the new backup `inbox/backup/data.gd.bak-NATIONDATA01`, and this report. Donor files were read only.

## 7. Open questions (carried from `NATION_DATA_01.md:208-217`)

1. Bavaria's unique 18c units `musketeer18bav` / `grenadierbav` have **no port asset** (no OBJ, no `UNITS_BASE` row) — the planned mapping uses role substitutes, not those donor-exact sids. Importing them is a separate asset ticket.
2. There is **no nation-specific 3D art** for any nation: 0 `rus*`/`bav*`/`eur*` OBJ stems; `bav` 2D sprite sheets exist but cannot satisfy the mesh condition. "Looks Ukrainian" building meshes remain a manifest/asset problem (`NATION_DONOR_01.md:184-190`), not something this data line fixes.
3. `rus.reiter → vityaz` is explicitly **deferred** per plan (`NATION_DATA_01.md:147`) — it would change AI army picks and deterministic selftest traces; not in this minimal set.
4. `resolve_sid()` accepting a target proves sid/UNITS membership, not donor-faithful geometry, animation or visual identity; no parity claim.
5. Whether `user://options.json` overrides `Data.PLAYER_NATIONS` on this machine was not inspected (`NATION_DATA_01.md:215`).
6. `nation_mesh_usage` `exact=true` runtime proof (`NATION_DATA_01.md:192`) is **not** claimed here: no repo test file was added, because tests are outside this ticket's exclusive ownership, and `--check-only` is parse-only (`CONFIG_PIPELINE.md:310`, `:325`). It remains an open verification for a test-owning agent.
7. The gate is still red at **28/29 on `build`** per `RUN_GUIDE.md:57` / `NATION_DATA_01.md:30,181`; a pre-existing failure, not attributable to this data-only insert, and not reported as a pass.

## 8. Summary

- Added exactly one donor-correct line to `NATION_UNITS`: `"bav": {"serdiuk": "musketeer", "cossack": "hussar"},` immediately after `rus`.
- Donor basis first-hand: `country.script:2700` (`bav` in musketeer roster), `:2754` (`bav` in hussar roster). Both port targets have `UNITS_BASE` rows and non-empty OBJ files, so `resolve_sid()` accepts them and the nation-mesh probe can select them.
- Byte-level proof: one insert, zero deletes/replaces; removing it reproduces the pre-edit backup byte-for-byte — `rus` and all MORALE-02 banners/markers are provably unchanged (content-based, not line-number-based).
- Backup: `inbox/backup/data.gd.bak-NATIONDATA01` (byte-exact, verified by SHA-256).
- Read-only static probe: all checks pass. Runner smoke `nationdata01-smoke`: ticket 542 `ok`/exit 0, stderr 0 B, `SCRIPT ERROR` 0 — parse-only proof, not runtime proof (§5.3).
- No other file edited. No parity claim.
