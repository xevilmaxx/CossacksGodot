---
id: CONFIG-WIRE-CAM
title: "CONFIG-WIRE-CAM — 3D camera FOV read from the global feature config getter"
owner: CONFIG-WIRE-CAM (implementation builder, subagent)
date: 2026-11-25
status: IMPLEMENTED__PARSE_SMOKE_CLEAN__NO_GATES__NO_BEHAVIOUR_CHANGE
scope: "Exactly two files touched by this ticket: variant3d/scripts/camera3d.gd (7 inserted lines, 0 removed) and this report, plus the required backup copy. No other source, test, config or app file edited or opened for write. No new config key."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION]
backup: inbox/backup/camera3d.gd.bak-CONFIGWIREC
smoke: "python variant3d\\tools\\godot_runner.py run --id configwirec-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/camera3d.gd  [ticket 429: status=ok exit=0 stderr 0 B, SCRIPT ERROR == 0]"
---

# CONFIG-WIRE-CAM — wire camera FOV to the global feature config

## 1. Goal and outcome

Make the shipping 3D camera read its FOV through the typed getter added by
CONFIG-CORE-01 instead of relying solely on the hard-coded literal, **without
changing any runtime value or behaviour**. `features.camera.fov_deg` defaults to
`17.27` (the measured baseline), so with today's config the effective FOV is
exactly `17.27` before and after this ticket.

## 2. Sources read first (all read-only)

| Source | What it supplied |
|---|---|
| `reports/CONFIG_CORE_01.md` `:29-63`, `:414-483` table | `features.camera.fov_deg` = `17.27`, getter `feature_camera_fov_deg() -> float`, **PORT APPROX / UNVERIFIED** label; `config.json` expressly out of that ticket's scope |
| `variant3d/scripts/config.gd` `:46-84` (`FEATURES_DEFAULTS`), `:88-89` (`DEFAULT.features`), `:266/269` (`data`, `static var active`), `:273-274` (`load_all` seeds from `DEFAULT`), `:387-398` (`value()`/`num()` get-with-fallback), `:414-483` (getter block, `feature_camera_fov_deg` at `:466-468`) | Full getter map and proof that an absent key/section still yields `17.27` |
| `reports/CAM_01_view_rect.md` `:137-159`, `:236-247` | FOV relabel to **PORT APPROXIMATION / UNVERIFIED** with RV-CAM-01 rationale; literal `const FOV_DEG_ASSUMED: float = 17.27` deliberately byte-unchanged; no numeric FOV promoted to donor truth |
| `reports/RV_CAM_01_fov_resolution.md` `:217-257`, `:306-314` | Verdict **CONFIRMED_UNVERIFIED**; keep `17.27` as labelled PORT APPROXIMATION; 2.90° is the only other coherent A/B candidate; do not substitute 5.15°/30.22° |
| `reports/MMJUMP_02_minimap_jump.md` `:73-83`, `:95-105` | `jump_to_world()` byte-identical constraint (CAM-RV-01 20/20) and the separate `jump_to_world_donor_offset()` API added by MMJUMP-02; both must stay untouched |
| `variant3d/scripts/camera3d.gd` (owned, read in full) | FOV usage: `const FOV_DEG_ASSUMED: float = 17.27` (`:88`) and `fov = FOV_DEG_ASSUMED` in `bind()` (`:176`); existing `var cfg = C3ConfigScript.active` / `if cfg != null:` config-read block (`:187-201`) |
| `variant3d/config.json` (read-only check) | No `features` key and no `fov` key — getter resolves to the `DEFAULT` value `17.27`; no key was added |

## 3. Getter map

| Link | Value |
|---|---|
| Config path | `features.camera.fov_deg` |
| Default (CONFIG-CORE-01) | `17.27` — **PORT APPROX / UNVERIFIED** (RV-CAM-01), `config.gd:71` |
| Typed getter | `func feature_camera_fov_deg() -> float` — `config.gd:466-468` |
| Getter body | `return num("features.camera.fov_deg", 17.27)` (`:468`), through `num()` (`:396-398`) → `value()` (`:387-394`) get-with-fallback |
| Config instance | `static var active` — `config.gd:269`; already preloaded in `camera3d.gd:55` as `C3ConfigScript` and read in `bind()` at `:187` |
| Consumer | `camera3d.gd:bind()` — `fov = cfg.feature_camera_fov_deg()` inside the existing `if cfg != null:` block |
| Fallback when `active == null` | `fov = FOV_DEG_ASSUMED` (literal `17.27`), unchanged and byte-identical |

Resolution chain: `load_all()` seeds `data` from `DEFAULT` (which contains
`features: FEATURES_DEFAULTS`); `config.json` has no override; `value()` walks the
dotted path and returns `17.27` from the defaults. A missing key, a missing
`features` section, or no config instance at all all still yield `17.27`.

## 4. Before → after (exact diff)

`variant3d/scripts/camera3d.gd` — **7 insertions, 0 deletions**; no executable
line was removed or rewritten.

| # | Location | Before | After |
|---:|---|---|---|
| 1 | `bind()`, before `fov = FOV_DEG_ASSUMED` | literal assignment with no comment | 3 new comment lines naming CONFIG-WIRE-CAM, the `17.27` fallback and the **PORT APPROXIMATION / UNVERIFIED** label; assignment itself unchanged |
| 2 | `bind()`, inside existing `if cfg != null:` | first read was `zoom_notch_gain = cfg.num(...)` | 3 new comment lines + **`fov = cfg.feature_camera_fov_deg()`** as the authoritative FOV read, ahead of the unchanged config reads |

```diff
 	projection = PROJECTION_PERSPECTIVE  # G31:225 — donor main view is perspective, not ortho
+	# CONFIG-WIRE-CAM — FOV is now read through the global feature-config getter
+	# below. FOV_DEG_ASSUMED (17.27) is kept as the exact null-config fallback and
+	# equals the getter's own default; PORT APPROXIMATION / UNVERIFIED (RV-CAM-01).
 	fov = FOV_DEG_ASSUMED
 	near = NEAR_M
...
 	var cfg = C3ConfigScript.active
 	if cfg != null:
+		# CONFIG-WIRE-CAM — authoritative FOV read via the typed getter. It falls
+		# back to 17.27 when features.camera.fov_deg is absent, so the shipped
+		# value/behaviour is unchanged; PORT APPROX / UNVERIFIED (RV-CAM-01).
+		fov = cfg.feature_camera_fov_deg()
 		zoom_notch_gain = cfg.num("camera.zoom_notch_gain", 2.0)
```

### Byte-identity checks (pre-edit backup vs edited file)

| Block | Bytes | SHA-256 (first 16) | Identical |
|---|---:|---|---|
| `jump_to_world()` (CAM-RV-01 dependency) | 450 / 450 | `16edf5a426a280aa` / `16edf5a426a280aa` | **yes** |
| `jump_to_world_donor_offset()` (MMJUMP-02 API) | 1501 / 1501 | `7d8a3b605779ae1a` / `7d8a3b605779ae1a` | **yes** |
| FOV const + PORT APPROX rationale block | 1234 / 1234 | `483f2a45bf3a0bed` / `483f2a45bf3a0bed` | **yes** |

`const FOV_DEG_ASSUMED: float = 17.27` remains verbatim; exactly one getter call
was added; no new key, constant, method, signature or class was introduced.
File length: 760 → 767 lines.

## 5. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/camera3d.gd.bak-CONFIGWIREC` |
| Taken | before the first edit (plain copy of `variant3d/scripts/camera3d.gd`) |
| Bytes | 40,155 |
| SHA-256 (backup and pre-edit source) | `893C2BA1BD6CC8AEC18166DDE066F902AC3CEE65873015B7FB0B9F8DA042255B` |

Restore is a plain file copy back over `variant3d/scripts/camera3d.gd` if this
ticket is rejected.

## 6. Validation — variant runner only

**Command (Windows `python`; no direct `godot`, no gates, no ladder):**

```powershell
python variant3d\tools\godot_runner.py run --id configwirec-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/camera3d.gd
```

| Field | Value |
|---|---|
| Ticket / id | 429 / `configwirec-smoke` (unique) |
| argv | `--headless --path variant3d --check-only --script res://scripts/camera3d.gd` |
| wait / run | 112.70 s / 7.95 s (shared queue delay only) |
| status / exit | `ok` / `0` |
| stdout | 75 B — `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` |
| stderr | **0 bytes** |
| `SCRIPT ERROR` occurrences (stdout + stderr) | **0** |

Artifacts: `variant3d/.godot_queue/results/00000429.json` and
`variant3d/.godot_queue/results/00000429_configwirec-smoke/{stdout,stderr}.txt`.
`SCRIPT ERROR == 0` — confirmed (observed). `--check-only` parses/validates the
script; it does not execute `bind()` or call the getter at runtime, so this is a
parse smoke, not a runtime FOV probe. No selftest/uitest, no capture, no terrain
ladder, no gate.

## 7. No-behaviour-change and no-test-edit statements

- **No behaviour change under today's configuration.** The getter's default
  (`17.27`) equals the former literal exactly; `config.json` has no `features`
  override, so `data.features.camera.fov_deg` resolves to `17.27` through
  `DEFAULT`. When `C3ConfigScript.active` is `null`, the unchanged
  `fov = FOV_DEG_ASSUMED` fallback still yields `17.27`. Nothing else in
  `bind()` changed, and no other camera method changed.
- **The label is preserved, not promoted.** The value remains a **PORT
  APPROXIMATION / UNVERIFIED** figure (RV-CAM-01 CONFIRMED_UNVERIFIED); the getter
  does not turn it into donor truth and no numeric FOV was substituted.
- **Protected APIs byte-identical.** `jump_to_world()` (CAM-RV-01 20/20) and
  `jump_to_world_donor_offset()` (MMJUMP-02) were extracted from backup and
  edited file and compared byte-for-byte — identical (§4).
- **No test edited.** No test file was opened for write; no assertion was
  retuned, skipped or weakened. In particular `t_view_rect_rv.gd` and
  `t_nav_smoke.gd` are untouched.
- **No new config key.** `config.json`, `config.gd`, `world3d.gd`, `hud.gd`,
  `input_controller.gd`, `app/**` and every other file were not edited by this
  ticket. Concurrent foreign edits visible in `git status` (including other
  CONFIG-WIRE tickets' backups and source files) were left intact; none were
  reverted, staged or reported as this ticket's errors.

## 8. Open questions

1. **JSON schema** — `features.camera.fov_deg` will only differ from `17.27` once
   the JSON owner (MAP-SMALL-01) adds a `features` object with that key; no such
   override exists today. A runtime FOV probe after that lands would confirm the
   wiring end to end (`--check-only` cannot).
2. **FOV remains UNVERIFIED** — RV-CAM-01's native conversion body,
   `viewportdimension`, sensor constant and donor screenshot A/B are still open;
   this ticket wires a reader, it does not add evidence. 2.90° remains the only
   other coherent A/B candidate.
3. **Config instance lifetime** — `bind()` reads `C3ConfigScript.active` once at
   bind time (as it already did for the other camera keys). If a future flow
   reloads config after the camera is bound, the FOV is not auto-refreshed; no
   such flow exists today and adding one is out of scope.
4. **Getter type coercion** — `num()` casts an `int` override to `float`
   (`config.gd:396-398`), so an explicit JSON `17` would become `17.0`; the
   default `17.27` is unaffected.
5. **Other feature getters** — the remaining 20 CONFIG-CORE-01 getters are still
   unwired; each needs its own consumer ticket with the same
   default-preserving pattern.

## 9. Summary

Wired the 3D camera FOV to `C3ConfigScript.active.feature_camera_fov_deg()`
inside `bind()`'s existing config-read block, keeping `fov = FOV_DEG_ASSUMED`
(`17.27`) as the exact null-config fallback and preserving the **PORT
APPROXIMATION / UNVERIFIED** rationale verbatim. Net diff in the owned file: 7
inserted lines, 0 removed, 0 rewritten. `jump_to_world()` and
`jump_to_world_donor_offset()` are byte-identical to the pre-edit backup, so
CAM-RV-01's 20/20 dependency and MMJUMP-02's separate API are unaffected.
Variant-runner smoke `configwirec-smoke` (ticket 429) ended `ok`/exit `0` with
`SCRIPT ERROR == 0` and empty stderr; no gates, ladder or direct `godot` run.
No test was edited, no config key was added, and no file other than
`variant3d/scripts/camera3d.gd` and this report (plus the backup copy) was
edited by this ticket.
