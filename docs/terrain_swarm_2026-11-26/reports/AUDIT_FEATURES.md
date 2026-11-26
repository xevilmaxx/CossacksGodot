# AUDIT-FEATURES — opt-in flag audit (donor-terrain visual wave, 2026-11-26)

Worker: AUDIT-FEATURES. READ-ONLY. No code/Godot/git touched. No parity claim made.
Inputs read at the exact lines cited below:
`variant3d/scripts/config.gd`, `variant3d/scripts/main.gd`, `variant3d/scripts/world3d.gd`,
`variant3d/scripts/terrain_donor_world.gd`, `variant3d/scripts/terrain_donor_mesh.gd`,
`variant3d/scripts/terrain_donor_inputs.gd`, `variant3d/scripts/terrain_donor_gen.gd`,
`variant3d/scripts/game.gd`, `app/scripts/game.gd`, `variant3d/config.json`, `app/config.json`,
`%TEMP%\opencode\v42\map_donor_240.json`, `map_donor_240_hires.json`, `map_donor_64.json`.
The four named input reports (`COORD_terrain_root_cause.md`, `AUDIT_ATLAS_RESOLUTION.md`,
`COMPACT_PATTERNS_offline.md`, `FIELD_ASSETS_conversion.md`) were not found on disk under
`docs/terrain_swarm_2026-11-26/reports/` (glob lists only V/W/X-series files); related
evidence was taken from W01/W03/W05/W07/W09 and V36/V52/V61/V63/V81/V96 instead, cited inline.

## 1. Verdicts (one line each)

1. Default legacy backend unchanged: YES. `main.gd:125` declares `var terrain_backend := "legacy"`;
   `main.gd:189` reads `cfg.text("features.terrain.backend", "legacy")` and `:190-191` coerce any
   non-`"donor"` value back to `"legacy"`. `world3d.gd:144` declares `var terrain_backend := "legacy"`;
   `:224` coerces the same way; `:624` instantiates the donor composer only on the exclusive
   `terrain_backend == "donor"` ternary, and `:645` locks the switch at first `bind()`.
2. Donor opt-in only: YES. No shipped config file contains a `backend` key (see §2), so stock
   startup always takes the literal `"legacy"` fallback. Donor runs only via explicit TEMP overlays
   (`map_donor_240.json:31`, `map_donor_64.json:31` set `"backend": "donor"`) or a direct
   `set_terrain_backend("donor")` call before `bind()` (`main.gd:593-594`, `:1112-1113`).
3. No flag leaks into default gameplay: YES, with one shipped-config exception (R2, low).
   `variant3d/config.json:24-26` ships `"relief_stamps": true` while the code default is false;
   effect is confined to the `--dump-map` producer path (`main.gd:806-810`), never the sim.
4. No conflicting flag names: YES, with one caution (R3, low). `features.terrain.demo_mill` (config)
   vs entity marker `"terrain_demo_mill"` (`game.gd:3253,3278`) live in disjoint namespaces
   (config table vs entity dict) and cannot collide through `flag()`/`text()` readers.
5. No telemetry claiming parity: YES. Every donor-telemetry surface hard-codes
   `visual_parity_claim: false` / `"parity": "UNVERIFIED"` (see §5). No numeric gate, VRAM figure,
   or dump marker feeds back into sim, mesh, water, tile assignment, or any gate threshold.
6. No stale config paths: YES, with two stale prose comments (R4/R5, info). All four asset paths
   probed by the flags resolve on disk (see §6).

## 2. Flag-by-flag table (exact reads)

| Flag (task list) | Canonical path | Code default | Shipped value | Consumer / gating lines | Status |
|---|---|---|---|---|---|
| `backend` | `features.terrain.backend` | `"legacy"` (no `FEATURES_DEFAULTS` entry, no typed getter; inline `text()` fallback) | absent in `variant3d/config.json:16-49`, absent in `app/config.json`, absent in `config.gd:46-86` | `main.gd:189-191` (read+coerce), `main.gd:593-594` + `:1112-1113` (guarded setter calls), `world3d.gd:144,220-224,624,645,706-707` (switch+lock+A/B stats) | OPT-IN ONLY. Missing-hook reports V36 A17 / V52:108-109 / V81:156-160 still factually true for shipped files; the seam itself (V96, V63:52) is landed, so opt-in works via overlay/setter. |
| `relief_stamps` | `features.terrain.relief_stamps` | `false` — `config.gd:62` (`FEATURES_DEFAULTS.terrain`), getter `config.gd:441-442` | `true` in `variant3d/config.json:24-26`; absent in `app/config.json` (no `features` table at all); `true` in all three TEMP overlays | producer `main.gd:791-810` (emits `dump["relief_stamps"]` only when enabled; default = key absent = byte-identical to pre-RELIEF baseline); legacy reader `world3d_terrain.gd:532-534` (null-safe `.get`, no-op when absent); tests set it true (`t_terrain_donor.gd:55`) | OPT-IN, wired. Only flag with DEFAULTS entry + typed getter. Shipped-`true` deviation is R2. |
| `demo_mill` | `features.terrain.demo_mill` | `false` — NO `FEATURES_DEFAULTS` entry, NO getter; inline `flag()` fallback at `game.gd:3246` | absent everywhere shipped; `true` in `map_donor_240.json:31-33`-region, `map_donor_64.json`, `map_donor_240_hires.json` | `game.gd:3240-3246` (`_demo_mill_enabled`, null-safe: inactive config or missing method → `false`), call sites `:2718, :2848, :2975` (field-sowing rings), `:3237-3238` (spawn); `app/scripts/game.gd` has NO `demo_mill`/`terrain_demo` match — 2D port unaffected | OPT-IN ONLY, variant3d-only. Unvalidated default (R1). |
| `detail_bitmap` | `features.terrain.detail_bitmap` | `false` — NO `FEATURES_DEFAULTS` entry, NO getter; inline `flag()` fallback at `terrain_donor_inputs.gd:1220` | absent everywhere shipped; NOT set even in TEMP donor overlays (donor-gen path stays SKIPPED in captures) | `terrain_donor_inputs.gd:1216-1220` (sets `p["detail_bitmap_enabled"]`), `terrain_donor_gen.gd:1205-1213` (SKIPPED vs APPLIED branch; skipped telemetry at `:1208-1213` labels reason + `parity: UNVERIFIED`), `:1221-1315` routine, missing-asset skips at `:1333-1344` | OPT-IN ONLY, donor-gen-only. Unvalidated default (R1). Legacy `game.gd:2098` `_apply_detail_pass` is a SEPARATE unconditional legacy stage — see §4. |
| `hires_atlas` | `features.terrain.hires_atlas` | `false` — NO `FEATURES_DEFAULTS` entry, NO getter; inline `flag()` fallback at `terrain_donor_mesh.gd:427-435` (const path at `:76`) | absent everywhere shipped; `true` ONLY in `map_donor_240_hires.json:31-35`-region | `_resolve_hires_atlas_flag` `:427-435` (null-safe: null/missing config or method → `false`); tier select `_atlas_paths` `:509-538`; labelled stats `_atlas_resolution_info` `:456-506`; resolved once per build `:912` | OPT-IN ONLY, diagnostic tier. Unvalidated default (R1). Default tier stays `terrain_new_2048x1024_128cell` (`:515`); nothing resampled/generated (`:69-72`). |

## 3. Unvalidated feature defaults

`config.gd:46-86` (`FEATURES_DEFAULTS`) contains exactly ONE terrain key: `relief_stamps: false`
(`:62`). The other four flags are read through the generic unvalidated readers with inline
fallbacks and have neither a DEFAULTS entry nor a typed `feature_*` getter nor `_donor_id`-style
unknown-value reporting (`config.gd:696-701` covers only `gameplay.*` donor ids):

- `backend`: `cfg.text(..., "legacy")` + explicit coerce (`main.gd:190-191`, `world3d.gd:224`).
  Unknown strings safely collapse to `"legacy"`. VALIDATED by coercion. No action.
- `demo_mill` / `detail_bitmap` / `hires_atlas`: `bool(cfg.call("flag", <path>, false))`.
  `flag()` (`config.gd:402-404`) returns the raw value when `v is bool`, else the fallback —
  so a malformed non-bool (e.g. the STRING `"false"` in a hand-edited JSON) falls back to
  `false` rather than enabling. Mis-typed values fail CLOSED. The residual gap is only that a
  JSON-literal `true` in any user overlay silently enables a diagnostic; that is the documented
  opt-in mechanism, not a leak. No central registry to extend, but behaviour is safe.

Related: `config.gd:42-45` comment "No consumer reads these yet (separate wiring tickets)" is
STALE for `relief_stamps` (consumed at `main.gd:796-797` since RELIEF-02/CONFIG-WIRE-RELIEF) — R5.

## 4. Leak / conflict analysis

- L1 — Legacy sim untouched by donor flags. `app/scripts/game.gd` contains NO `demo_mill`,
  `backend`, `hires_atlas`, or `features.terrain` reads (grep: only `_load_detail_bitmaps` at
  `:1571` and unconditional `_apply_detail_pass()` at `:1581-1584, :1689`). The 2D shipping port
  cannot observe any flag in the task list.
- L2 — Legacy detail pass is NOT flag-gated (by design, not a leak). `variant3d/scripts/game.gd:2098`
  calls `_apply_detail_pass(brng)` unconditionally inside `_assign_tileblocks`, and
  `app/scripts/game.gd:1689` likewise. The `detail_bitmap` flag gates ONLY the donor-gen routine
  (`terrain_donor_gen.gd:1205`). Same donor source (`loadtextureterrainfrombitmap.inc`), two
  independent call sites, opposite gating — flagged here as a NAMING caution (R3), not a behaviour
  leak: flipping the flag cannot change legacy output, and legacy output never consults the flag.
- L3 — `relief_stamps=true` in shipped `variant3d/config.json:24-26` vs code default `false`.
  Reach is limited to `main.gd:806-810`: the `--dump-map` dump gains a `relief_stamps` key.
  Normal runs (no dump path) never read the key; the legacy terrain reader
  (`world3d_terrain.gd:532-534`) `.get`s it with null default. R2 (low).
- C1 — `display.fog_of_war` (`config.gd:488` APPLIED to `Data.FOG_OF_WAR`) vs
  `features.gameplay.fog_of_war` (getter `config.gd:472-473`, NO consumer — still covered by the
  `:42-45` "no consumer" note) vs `features.render.fog` (getter `:469-470`, NO consumer).
  Three fog keys, one wired. A future edit enabling a `features.*fog*` reader without removing
  `display.fog_of_war` would create a genuine conflict; today it is latent only. R3 (low).
- C2 — `features.terrain.demo_mill` vs entity field `"terrain_demo_mill"` (`game.gd:3253,3278`):
  disjoint namespaces, no reader crosses them. No conflict.
- C3 — `backend` string values: only exact lowercase `"donor"` (after `.to_lower()`) opts in;
  `"Donor"` works via `:189` lower-casing, everything else → legacy. No conflict with
  `gameplay.render_mode` (`main.gd:186-187`, port-side `2d`/`3d` switch, separate key).

## 5. Telemetry / parity-claim scan

No surface claims parity. Exact guards:

- `terrain_donor_world.gd:21-24` + `:28` — `visual_parity_claim: bool = false` const-equivalent,
  "never set true without a real matched-seed donor A/B".
- `terrain_donor_mesh.gd:108` — `var visual_parity_claim: bool = false  # hard guard, never set true`;
  `:489-505` — atlas stats carry `"enabled"`, tier geometry, VRAM arithmetic
  (16384×8192 ⇒ ~512 MiB base / ~683 MiB with mips, per AUDIT-ATLAS-RES §6 B) with
  `"diagnostic_warning"` prefixed `DIAGNOSTIC / NO PARITY CLAIM` and note
  `"diagnostic only; ... NO donor parity claim"`.
- `terrain_donor_inputs.gd:1215` — `p["visual_parity_claim"] = false`; `:1231`
  `"parity": "UNVERIFIED — derived assets only; no donor GPU A/B frame"`.
- `terrain_donor_gen.gd:517` — `_tel["parity"] = "UNVERIFIED"`; `:1208-1213` skipped-branch
  telemetry (`status SKIPPED`, `reason requires features.terrain.detail_bitmap=true`,
  `parity UNVERIFIED`); `:1241` applied-branch `parity: UNVERIFIED — authored donor intent, no GPU A/B`.
- `terrain_donor_world.gd:488` — `"backend": "donor"` is an A/B identity label in stats
  (mirrored by `world3d.gd:706-707` `terrain_backend`/`terrain_script`), not a fidelity claim.
- Capture overlays (`map_donor_240.json`, hires, 64) contain no `parity_claim`/`parity_status`
  keys of their own; harness-level verdicts (`terrain_qa_harness.py:781,789-793,1183`) pin
  `parity.status=UNVERIFIED, parity.claim=NONE`. Consistent — nothing to correct.

## 6. Stale config-path check

All asset paths referenced by flag-gated code resolve on disk (variant3d/):

- `DETAIL_BITMAP_LOW/HIGH_PATH` (`terrain_donor_gen.gd:180-181`):
  `res://assets/terrain/structs/tile_lowground.png`, `.../tile_highground.png` — BOTH PRESENT
  (structs/ listing: `tile_lowground.png`, `tile_highground.png`, plus `.import` files).
- `NEW_ATLAS_*` (`terrain_donor_mesh.gd:66-68`): `assets/terrain_new/atlas/tile_index_atlas.png`
  + `.manifest.json` — PRESENT; `seasons/` subdir PRESENT.
- `LEGACY_ATLAS_*` (`:73-75`): `assets/terrain/atlas/tile_index_atlas.png` + `.manifest.json`
  (+ winter pair) — PRESENT.
- `_atlas_paths` fallback (`:535-538`): if the `terrain_new` tier is absent the build falls back
  to the committed legacy pair WITH a tier label in stats — documented, labelled, not hidden.
  No dangling path.
- Stale PROSE (not paths): (a) `config.gd:42-45` "no consumer reads these yet" — false for
  `relief_stamps` since CONFIG-WIRE-RELIEF (`main.gd:791-810`); (b) V36 A17 / V52 / V61:398-399 /
  V81:156-160 "no `features.terrain.backend` key in config.gd/config.json, opt-in needs override
  or setter" — still TRUE for shipped files and correctly describes the mechanism; treat as
  standing documentation, not a defect.

## 7. Ranked risks (highest first)

- R1 — Unvalidated defaults for `demo_mill` / `detail_bitmap` / `hires_atlas` (LOW-MEDIUM).
  No DEFAULTS entry, no typed getter, no unknown-value log. Mitigated: `flag()` fails closed on
  non-bool; `backend` analogue is fully coerced; all three are read-only diagnostics with
  labelled stats. Recommendation (for COORD, not this worker): add the three keys
  (`false`) to `FEATURES_DEFAULTS.terrain` plus typed getters mirroring `feature_terrain_relief_stamps`,
  so `--dump-config` shows them and future readers go through one validated surface.
  No behaviour change required; do NOT change any default to `true`.
- R2 — Shipped `variant3d/config.json:24-26` sets `relief_stamps: true` against code default
  `false` (LOW). Effect confined to `--dump-map` output shape (extra key when enabled).
  Any byte-identity check of dump files must pin this key explicitly. Recommend either reverting
  shipped value to `false` (pure opt-in) or recording the deviation in the capture protocol.
- R3 — Name collisions-in-waiting (LOW, latent). (a) Legacy-always-on `_apply_detail_pass`
  vs flag-gated donor `detail_bitmap` share one donor source name — a future reader could assume
  the flag governs both; it does not. (b) Three fog keys with one wired reader
  (`display.fog_of_war` applied at `config.gd:488`; `features.gameplay.fog_of_war`,
  `features.render.fog` reader-only). Recommend a one-line comment at each site naming the
  authoritative key; no rename (renames break overlays).
- R4 — Stale comment `config.gd:42-45` (INFO). "No consumer reads these yet" predates
  CONFIG-WIRE-RELIEF. One-line correction; no behaviour impact.
- R5 — Absent input reports (INFO, process). The four reports named in the task were not on disk;
  this audit substituted W/V-series evidence (cited per-section). COORD may wish to confirm the
  intended filenames/paths.

## 8. Files-and-lines index (everything cited)

`config.gd`: FEATURES table `:42-86`, terrain `:54-63`, relief default `:62`, getter `:441-442`,
readers `:402-404`/`value :389-396`, stale note `:42-45, :417-423`, apply fog `:488`,
gameplay relief default `:131`, relief resolve `:598-600`.
`main.gd`: var `:125`, backend `:188-191`, setter calls `:593-594, :1112-1113`,
relief producer+gate `:770-810`.
`world3d.gd`: donor const `:117-118`, var `:143-145`, setter `:220-224`, ternary `:624`,
lock `:645`, A/B stats `:705-707`.
`terrain_donor_world.gd`: parity guard `:21-28`, backend label `:488`, composition `:6-19`.
`terrain_donor_mesh.gd`: flag path `:76`, var `:111`, resolver `:427-435`, tier `:509-538`,
resolution telemetry `:456-506`, once-per-build `:912`, parity guard `:108`.
`terrain_donor_inputs.gd`: detail enable `:1216-1220`, parity labels `:1215, :1231`.
`terrain_donor_gen.gd`: hook `:364`, p-doc `:506`, gate `:1205-1213`, routine `:1216-1315`,
loader `:1318-1344`, consts `:177-181`, tel init `:516-534`.
`game.gd` (variant3d): detail loader `:1950-1958`, detail pass `:1960-2011`, call `:2098`,
demo_mill `:2718, :2848, :2975, :3237-3246`, marker `:3248-3278`.
`app/scripts/game.gd`: detail `:1571-1589, :1689`, NO demo_mill/backend/terrain-feature match.
`variant3d/config.json`: features `:16-49`, relief `:24-26`, NO backend/demo_mill/detail_bitmap/
hires_atlas keys. `app/config.json`: NO `features` table at all.
TEMP overlays: `map_donor_240.json` terrain block `:29-35`-region
(`relief_stamps: true, backend: donor, demo_mill: true`), 3D/size/seed `:80-83`-region;
`map_donor_240_hires.json` adds `hires_atlas: true`; `map_donor_64.json` mirrors 240 non-hires.
Prior reports: V36 `:37, :75, :131` (P11/EV15/A17 missing-hook), V52 `:108-109`, V61 `:343, :398-399`,
V63 `:52`, V67 `:61`, V76 `:51`, V81 `:156-160, :398`, V96 `:71`, W05 `:35, :70, :159, :224-234`,
W09 `:18, :52, :124`, W01 `:57`, W03 `:55`.

No edits made. No parity claimed. Parity remains UNVERIFIED (no donor GPU A/B frame).
