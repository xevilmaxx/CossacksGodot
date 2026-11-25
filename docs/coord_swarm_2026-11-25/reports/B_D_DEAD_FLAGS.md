---
id: B-D-DEAD-FLAGS
title: "P1-3 docs-safe variant — delete five dead terrain feature flags + accessors + JSON leaves; keep relief_stamps"
agent: "B-D-DEAD-FLAGS (implementation builder), coord swarm 2026-11-25"
date: 2026-11-25
scope: "Exactly three files: variant3d/scripts/config.gd, variant3d/config.json (owned code/config) and this report. app/ never opened; no other .gd/.gdshader/test/fixture/backup directory file edited."
labels: [observed, derived, inference, UNVERIFIED]
parity_guard: "No behavioural change intended; no donor A/B run; PORT APPROXIMATION only; no donor parity claim."
---

# B-D-DEAD-FLAGS — P1-3 removal of dead `features.terrain` keys

## 1. Decision (option b for all five; no wiring)

| Key | Code default | Outcome | Owner ticket recorded in code comment |
|---|---|---|---|
| `texgen_mode` | `"world_xz"` | **DELETED** (key, accessor, JSON leaf) | shader=A — TRN-SHADER A1; PORT APPROX / RV-TRN-01 A |
| `m_per_tile` | `2.0` | **DELETED** | terrain-gd=B — DTRN-01/DEC-05; `Data.TILE_M = 2.0` unchanged |
| `lighting` | `"donor"` | **DELETED** | shader=A — DENV-01, TRN-SHADER B1 |
| `alpha_patch_mode` | `"donor_approx"` | **DELETED** | shader=A — DALPHA-02 UNVERIFIED; live uniform is `mask_to_alpha` (shader `:235-246`) — **not wired in this ticket, documented only** |
| `tile_diversity` | `true` | **DELETED** | terrain-gd=B — V3D-02 F3, behaviour unconditional |
| `relief_stamps` | `false` (JSON `true`) | **KEPT byte-identical** — wired at `main.gd:789-790` | — |

- **observed:** no consumer call site exists for any of the five in `variant3d/scripts` (§5); the only safe consumer is `relief_stamps`, which was left untouched. No trivially-safe, byte-identical-default call site exists in the two owned files, so option (b) was preferred per ticket.
- **observed:** `alpha_patch_mode` is *not* the live shader control; `Z3_VISUAL_BLEED.md §2` (`shader :235-246`, `mask_to_alpha`) was honoured — this ticket only points to shader=A in a comment.

## 2. Backup evidence (created before any edit, SHA-256 verified)

| Original | Backup | Bytes | SHA-256 | Match |
|---|---|---:|---|---|
| `variant3d/scripts/config.gd` | `inbox/backup/config.gd.bak-BDFLAGS` | 32,455 | `41B538E4B63E9DB8B1C686E1857AD9740166A12D41D91846A800140240010E01` | **YES** |
| `variant3d/config.json` | `inbox/backup/config.json.bak-BDFLAGS` | 15,163 | `96B3C55FACA7C68362D022AF08A38DC08DA1F2AE6E4DAD784CA9B1173F4C4830` | **YES** |

[observed — `Copy-Item -Force`, then `Get-Item` length and `Get-FileHash -Algorithm SHA256` on source vs backup; both hashes equal.]

## 3. Exact diff (`git --no-pager diff`, observed)

```
diff --git a/variant3d/config.json b/variant3d/config.json
@@ -22,12 +22,7 @@
    "double_click_s": 0.5
   },
   "terrain": {
-   "texgen_mode": "world_xz",
-   "m_per_tile": 2.0,
-   "lighting": "donor",
-   "alpha_patch_mode": "donor_approx",
-   "relief_stamps": true,
-   "tile_diversity": true
+   "relief_stamps": true
   },
   "water": {
    "surface_y": -0.25,
diff --git a/variant3d/scripts/config.gd b/variant3d/scripts/config.gd
@@ -52,12 +52,14 @@ const FEATURES_DEFAULTS := {
 		"double_click_s": 0.5,          # DSEL-01: data\gui\menu.cfg:33 KeyDoubleDelay
 	},
 	"terrain": {
-		"texgen_mode": "world_xz",           # TRN-SHADER A1; PORT APPROX (RV-TRN-01 verdict A)
-		"m_per_tile": 2.0,                   # DTRN-01/DEC-05: dmscript.global:171 gc_meters_to_tile=2
-		"lighting": "donor",                 # DENV-01: env\lights\light.cfg:17 lsParallel; TRN-SHADER B1
-		"alpha_patch_mode": "donor_approx",  # DALPHA-02: tile->patch index UNVERIFIED, PORT APPROX
+		# P1-3 / B-D-DEAD-FLAGS: five defs-only keys removed (zero consumers).
+		#   texgen_mode      -> shader=A (TRN-SHADER A1; PORT APPROX / RV-TRN-01 A)
+		#   m_per_tile       -> terrain-gd=B (DTRN-01/DEC-05; Data.TILE_M=2.0 is used)
+		#   lighting         -> shader=A (DENV-01; TRN-SHADER B1)
+		#   alpha_patch_mode -> shader=A (DALPHA-02 UNVERIFIED; the live uniform is
+		#                       mask_to_alpha, shader :235-246 — NOT wired here)
+		#   tile_diversity   -> terrain-gd=B (V3D-02 F3; behaviour unconditional)
 		"relief_stamps": false,              # RELIEF-01: opt-in dump marker, default off
-		"tile_diversity": true,              # current port behaviour (V3D-02 F3; unchanged)
 	},
 	"water": {
 		"surface_y": -0.25,     # TRN-WATER PORT APPROX placeholder; DTRN-03 §9
@@ -416,6 +418,9 @@ func section(name: String) -> Dictionary:
 # value() (get-with-fallback), so a missing key - or no `features` section at
 # all - yields the donor-verified default in FEATURES_DEFAULTS. No consumer
 # outside config.gd reads these yet; wiring is a separate ticket.
+# P1-3 / B-D-DEAD-FLAGS: 5 dead terrain accessors removed with their keys;
+# 16 remain (was 21). texgen_mode/lighting/alpha_patch_mode -> shader=A;
+# m_per_tile/tile_diversity -> terrain-gd=B. relief_stamps kept (used in main.gd).
 
 func feature_selection_world_epsilon_m() -> float:
 	return num("features.selection.world_epsilon_m", 0.005)
@@ -433,24 +438,9 @@ func feature_selection_marquee_width_px() -> int:
 func feature_selection_double_click_s() -> float:
 	return num("features.selection.double_click_s", 0.5)
 
-func feature_terrain_texgen_mode() -> String:
-	return text("features.terrain.texgen_mode", "world_xz")
-
-func feature_terrain_m_per_tile() -> float:
-	return num("features.terrain.m_per_tile", 2.0)
-
-func feature_terrain_lighting() -> String:
-	return text("features.terrain.lighting", "donor")
-
-func feature_terrain_alpha_patch_mode() -> String:
-	return text("features.terrain.alpha_patch_mode", "donor_approx")
-
 func feature_terrain_relief_stamps() -> bool:
 	return flag("features.terrain.relief_stamps", false)
 
-func feature_terrain_tile_diversity() -> bool:
-	return flag("features.terrain.tile_diversity", true)
-
 func feature_water_surface_y() -> float:
 	return num("features.water.surface_y", -0.25)
```

- **observed:** `git diff --numstat` = `config.json 1/6`, `config.gd 10/20`. No rename, no test weakening, no other file in the diff.

## 4. Targeted validation — ONE runner job (variant runner only)

- **Queue pre-check [observed]:** `python variant3d\tools\godot_runner.py status` → `pending=0`, `godot.lock=free` (serving 572 = next 572). No re-submission was made.
- **Command [observed]:** `python variant3d\tools\godot_runner.py run --id bdflags-dump-config --timeout 120 -- --headless --path variant3d -- --dump-config`
- **Ticket 572** `bdflags-dump-config`: `status=ok`, `exit=0`, wait 0.00 s / run 7.07 s; result `variant3d/.godot_queue/results/00000572.json`.
- **SCRIPT ERROR = 0** [observed]: `stderr.txt` is **0 bytes**; `Select-String 'SCRIPT ERROR'` count **0**. stdout 18,345 B = Godot 4.7.2 banner + `settings file: res://config.json` + JSON dump.
- **Round-trip proof [observed, parsed from that stdout]:** dump has **8 groups / 16 leaves**, `terrain == {"relief_stamps": true}`, `map_width_tiles=240`, `map_height_tiles=240`, and **0** of the five deleted keys. Local `json.load(open('variant3d/config.json'))` separately returns 8 groups / 16 leaves / 240² / `terrain.relief_stamps=true` / 0 dead keys.
- **Not run [observed]:** no selftest, no uitest, no gate/ladder (reserved for COORD).

## 5. Grep proof — zero definitions without consumers / deletion list

- **Deletion list [observed]:** `features.terrain.{texgen_mode,m_per_tile,lighting,alpha_patch_mode,tile_diversity}`, getters `feature_terrain_{texgen_mode,m_per_tile,lighting,alpha_patch_mode,tile_diversity}()`, and their five JSON leaves. No other key/accessor touched.
- **Proof [observed]:** `Select-String '^func feature_terrain_(texgen_mode|m_per_tile|lighting|alpha_patch_mode|tile_diversity)\(' variant3d/scripts/config.gd` → **0 matches**; `Select-String 'features\.terrain\.(...5 names...)' variant3d/scripts/*.gd` → **0 matches**; repo-wide grep of `feature_terrain_<5 names>` returns only read-only docs, no code call sites.
- **Kept/wired [observed]:** `main.gd:789` `cfg.has_method("feature_terrain_relief_stamps")` and `main.gd:790` `cfg.call("feature_terrain_relief_stamps")` — the sole live consumer, unchanged.
- **Getter count [observed]:** `^func feature_` in `config.gd` = **16** (was 21). Reconciliation: the "21 keys / 21 getters" statements live in `docs/coord_swarm_2026-11-25/{CONFIG_PIPELINE.md,CONFIG_COUNT_RECONCILED.md,reports/*}` and `SWARM_BOARD.md` — **not owned by this ticket, not edited**; neither owned file previously contained a numeric count comment, so an in-file `16 remain (was 21)` note was added at the readers block (§3) rather than silently leaving 21 stale. Downstream docs still saying 21 are a **derived** follow-up for COORD, not a claim of parity or correctness here.

## 6. Boundaries / UNVERIFIED

- **observed:** `app/` untouched; no donor binary read; no git commit/merge; no queue mutation beyond the single job; backups were created before edits.
- **derived:** runtime behaviour is unchanged because the removed getters had no callers and the removed JSON leaves matched their code defaults; the round-trip dump confirms no other leaf drift.
- **UNVERIFIED:** no donor GPU A/B, no visual/frame measurement, no full selftest/uitest, and no claim that the removed names are donor-faithful. Whether shader=A / terrain-gd=B will later reintroduce these knobs is **UNVERIFIED** and out of scope. Exact future count wording in the non-owned docs is **UNVERIFIED**.
- **No donor parity claim** is made by this report.

*End of B-D-DEAD-FLAGS. One targeted validation, no parity claim.*
