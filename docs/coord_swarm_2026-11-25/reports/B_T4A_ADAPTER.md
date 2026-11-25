# B-T4A-ADAPTER — verify/land `hud3d_adapter.gd:172-173` explicit-type fix + smoke

**Ticket:** T4a (per `reports/Z4_TRIAGE.md:73,83`; owner follow-up at `PROGRESS.md:144-155`)
**Owner:** B-T4A-ADAPTER (runtime fault swarm)
**Date:** 2026-11-25
**Scope owned:** `variant3d/scripts/hud3d_adapter.gd` + this report only. `hud.gd` is FOREIGN (HUD-01/MMJUMP-02) and was **not touched**.

## Verdict — ALREADY-FIXED (no re-edit applied)

The `:172-173` fix was already present at HEAD before this ticket. Per the task rule
("if already fixed, do NOT re-edit; run the smoke and report ALREADY-FIXED"), **no code
change was made**. The adapter is byte-clean vs HEAD.

Current lines (`variant3d/scripts/hud3d_adapter.gd:172-173`):
```gdscript
	var w: int = clean_img.get_width()
	var h: int = clean_img.get_height()
```

## Evidence the fix predates this ticket

| Check | Result |
|---|---|
| `git rev-parse HEAD` | `f744dd93d466ec8636db6c2a9100146ac4eb3300` |
| `git status --short -- variant3d/scripts/hud3d_adapter.gd` | empty (clean) |
| `git diff HEAD -- variant3d/scripts/hud3d_adapter.gd` | empty (no diff) |
| `git blame -L 172,173` | both lines → commit `49aa81f72` (xevilmaxx), 2026-11-25 10:55:05 +0100 |
| adapter mtime | 2026-11-25 10:44:24 (local) — working-tree edit was already typed when committed |
| commit distance | `49aa81f7` is 11 commits behind HEAD (`git log --oneline -12`) |

`git log -L 172,173:variant3d/scripts/hud3d_adapter.gd` shows the exact transition:

- `0628b3cf` (2026-11-25 10:39:10 +0100) introduced `- var w := ...` / `- var h := ...` (inferred).
- `49aa81f7` (2026-11-25 10:55:05 +0100) replaced them with `+ var w: int = ...` / `+ var h: int = ...` (explicit).

**Donor for the typed fix:** existing git commit `49aa81f7` — the explicit types are present in
committed source, so this ticket only verifies and smokes them. No new type inference or
donor-derived value was invented. The 4-edge quad logic, the box, and all `hud.gd` call sites
are untouched.

## Backup evidence (governance: backup first, verify)

- Path: `inbox/backup/hud3d_adapter.gd.bak-BT4A`
- Created before any validation; 10221 bytes; mtime 2026-11-25 10:44:24 (mirrors source).
- SHA256 source = SHA256 backup =
  `F2CCFA02E9D92A52CEC1165C96FADF4B061551087656DCB0CAD75FEDACE6FF6C` → **MATCH=True**.

## Exact diff applied this ticket

**None.** No edit to any file (git diff empty; backup hash == source hash). The report file is
the only new file created.

## Targeted validation — one run, via variant runner only

Queue pre-check: `python variant3d/tools/godot_runner.py status` → `pending = 0`, `godot.lock = free`
(idle; no WAIT required).

Command (parse smoke, one validation only):
```
python variant3d/tools/godot_runner.py run --id bt4a-adapter-parse --timeout 120 -- `
  --headless --path variant3d --check-only --script res://scripts/hud3d_adapter.gd
```

| Field | Value |
|---|---|
| Ticket | **570** (`bt4a-adapter-parse`) |
| Runner line | `[runner] ticket 570 'bt4a-adapter-parse' START (waited 0.00s)` / `END ok (run 8.01s)` |
| Status | **ok** |
| Exit | **0** |
| SCRIPT ERROR count | **0** (stderr empty; stdout = Godot 4.7.2 version banner only) |
| Result JSON | `variant3d/.godot_queue/results/00000570.json` |

No full gate, no selftest, no uitest was run. `--check-only` is Godot's native parse-check
flag, so this proves the adapter parses — it is **not** runtime proof.

## Cascade check — `hud.gd:207` `GDScript.new()` error

Owner symptom (`PROGRESS.md:144-155`): adapter parse failure at `:172-173` cascaded to
`hud.gd:207` (`GDScript.new()` nonexistent because the adapter failed to load). Result:
**cascade closed** for the current tree.

- All relevant stderr files scanned for `SCRIPT ERROR`, `GDScript.new`, `hud.gd:207` and
  `hud3d_adapter`: **0 matches in every case**.
- Every cited job was created **after** the fix commit (10:55:05 +0100 / ~10:44 local) and
  returned `ok`, exit 0, SCRIPT ERROR 0:

| Job | Id | Created (local) | Status / Exit | SCRIPT ERROR | Role |
|---|---|---|---|---|---|
| 559 | `minimaptip01-smoke-hud` | 13:03:14 | ok / 0 | 0 | `--check-only` parse of foreign `hud.gd` (the `:207` caller) |
| 561 | `minimaptip01-smoke-adapter` | 13:03:15 | ok / 0 | 0 | prior `--check-only` parse of the adapter |
| 562 | `minimaptip01-hudlayout` | 13:03:26 | ok / 0 | 0 | windowed HUD layout run — loads `hud.gd` at runtime |
| 563 | `maskalpha01-realmap` | 13:09:41 | ok / 0 | 0 | real-map capture — loads HUD at runtime |
| 566 | `blankcheck01-posthide-clean` | 13:20:57 | ok / 0 | 0 | load-usability atom — loads HUD at runtime |
| **570** | **`bt4a-adapter-parse`** | 13:56:46 | **ok / 0** | **0** | **this ticket's parse smoke** |

Any recurrence of the `hud.gd:207` `GDScript.new()` cascade would surface as a `SCRIPT ERROR`
in these post-fix jobs that load `hud.gd`/the adapter; none does.

## Limits / no parity claim

- This is a **parse-level confirmation** (`--check-only`, exit 0, SCRIPT ERROR 0) plus
  post-fix stderr evidence — not a new windowed capture and not a full gate.
- **No donor parity claim** is made for the quad geometry or the minimap box; those were not
  edited or re-verified here (`reports/MINIMAP_QUAD_01.md` / file header hold the donor notes,
  marked PORT APPROX there).
- The owner's original windowed fault frame itself was not re-created; its recurrence is
  inferred absent from the clean post-fix job stderr. Mark **UNVERIFIED** for that exact
  owner frame, while the current shipping tree is clean.
