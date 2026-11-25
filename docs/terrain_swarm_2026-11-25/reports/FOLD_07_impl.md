---
id: FOLD-07
ticket: "WAVE FOLD integration — world.gd + world3d_relief.gd resolver wiring"
title: "FOLD-07 — remove the last two flat-path consumers; route 2D sprites and relief OBJs through asset_paths.gd"
owner: "FOLD-07 subagent (EXCLUSIVE owner of variant3d/scripts/world.gd and variant3d/scripts/world3d_relief.gd)"
created: 2026-11-25
status: DELIVERED__IMPLEMENTED__NO_GODOT__NO_RUNNER__NO_OTHER_FILE__NO_PARITY_CLAIM
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, reports/FOLD_05_all_folders.md, reports/FOLD_06_impl.md, reports/Z08_impl.md]
authority: "FOLD-06_impl.md:209-216 names the two unowned blockers (world.gd flat sprite paths; world3d_relief.gd flat OBJ_DIR); FOLD_05_all_folders.md:373-377, §4.3 specify the manifest `assets` map as the sprite source of truth."
scope: "Only two owned .gd files edited; two backups written under inbox/backup/; this report. No resolver edit, no runner, no Godot, no test/config/asset/manifest edit."
parity_guard: "Path-routing change only. No donor GPU A/B frame and no capture produced by this agent; visual/donor parity stays UNVERIFIED (CHARTER.md:57-58,122-130)."
sha256:
  world_gd_before: 04750bda7c91377146d81724c7f2888700464812fc97a3dba8f4dd9ac6063f09
  world_gd_after: 3fe067384e0ec59bbc2dd2f8a867895963f398e931be10784d696d40cbc46572
  world3d_relief_gd_before_includes_coord_typed_fix: 357e21d043cdcbbbfe8f8270e6f5e43b04c41035ec26d73e04a64c48694910de
  world3d_relief_gd_after: 9368d7dfc0ff85b9dd2acb2240ff62927fd4fa159091a2ea1d1dac092ec6cee1
---

# FOLD-07 — last two flat-path consumers folded into the resolver

> [!IMPORTANT]
> **Boundary.** Exactly two owned files were edited. `asset_paths.gd` was read
> and called but **not modified**; no runner job was submitted and no Godot
> process was launched (`WAVE_G_CHARTER.md:31`: only G04 runs jobs). All runtime
> consequences of the resolver change are **UNVERIFIED** until G04 reimports and
> re-runs the gates. **No donor parity claim.**

## 0. COORD notice handled

COORD reported a parse error at `world3d_relief.gd:341` (`var path := OBJ_DIR +
sid + ".obj"`, cannot infer type) and applied the typed one-line fix
`var path: String = OBJ_DIR + sid + ".obj"`.

- That fix is **present in the backup** `world3d_relief.gd.bak-FOLD07` (verified:
  line 341 of the backup is the typed form, SHA
  `357e21d043…`), so it is part of the pre-FOLD-07 baseline and was **not**
  undone. My edit preserves the `var path: String` declaration verbatim and
  changes only its RHS to the resolver call (§2).
- COORD also reported 188 missing `.mesh`/`.ctex` errors from G04's y04 capture
  because bucket copies lack a Godot import sidecar pass. G04 owns the editor
  import pass next; this ticket did not touch `.import`/`.godot/**` and did not
  run Godot. The resolver's `existing()` returns the mapped bucket path on disk
  first, so the import pass is exactly the remaining G04 step (§5).
- Standing order confirmed: **NO runner, NO Godot** from this agent.

## 1. Backups taken before edits (OBSERVED)

| Backup | Source | Size |
|---|---|---|
| `inbox/backup/world.gd.bak-FOLD07` | pre-edit `variant3d/scripts/world.gd` | 173,637 B |
| `inbox/backup/world3d_relief.gd.bak-FOLD07` | pre-edit `variant3d/scripts/world3d_relief.gd` (with COORD's typed fix) | 13,434 B |

## 2. Exact diff (backup → working tree)

Both diffs below are the complete change set; no other hunk exists in either file.

### 2.1 `variant3d/scripts/world.gd`

```diff
--- world.gd.bak-FOLD07
+++ world.gd
@@ -11,4 +11,9 @@
 
 const Data = preload("res://scripts/data.gd")
+# FOLD-07 — central asset path resolver (read-only here). Sprite lookups now
+# prefer the manifest `assets.sprite` / `assets.sprite_hi` bucket paths, with
+# the flat original kept ONLY as a diagnostic fallback while the copy-only
+# FOLD-06 migration is in place. This file does not edit the resolver.
+const AssetPaths = preload("res://scripts/asset_paths.gd")
 
 # Nation-first anim layout: every nation code that owns a `<nat>/{units,buildings}`
@@ -160,4 +165,8 @@
 # procedural shapes below, so the game never draws blank.
 var sprites: Dictionary = {}
+# FOLD-07 diagnostic only: count sprite keys that resolved through a flat
+# original because the manifest bucket path was absent. No shipped key relies
+# on this path; it exists so a migration miss is loud instead of silent.
+var _sprite_flat_fallbacks := 0
 # Animated original-model sheets (tools/bake_sprites.py): key -> {cell, actions}.
 var anim_index := {}
@@ -380,6 +389,32 @@
 	return load(path) as Texture2D
 
+# FOLD-07 — mapped sprite path via the central resolver. `res_for(sid, ext,
+# suffix)` returns the manifest `assets.sprite` / `assets.sprite_hi` bucket path
+# (the same resolver FOLD-06 uses for obj/tex); the suffix form inserts the
+# `_000..315` frame index before `.png`. Its generic legacy fallback is an OBJ
+# path, so a returned path is accepted only when it sits under a sprite root.
+func _mapped_sprite_path(key: String, ext: String, suffix: String = "") -> String:
+	var p := AssetPaths.res_for(key, ext, suffix)
+	var root := "res://assets/models/sprites/" if ext == "sprite" else "res://assets/models/sprites_hi/"
+	return p if p.begins_with(root) else ""
+
+# Resolve a model sprite with the mapped bucket path FIRST. The flat original
+# is consulted only as a diagnostic + last-resort fallback while the copy-only
+# FOLD-06 migration is in place; it is never preferred over a mapped file.
+func _sprite_res_path(key: String, ext: String, suffix: String = "") -> String:
+	var mapped := _mapped_sprite_path(key, ext, suffix)
+	if mapped != "" and _res_exists(mapped):
+		return mapped
+	var folder := "sprites" if ext == "sprite" else "sprites_hi"
+	var legacy := "res://assets/models/%s/%s%s.png" % [folder, key, suffix]
+	if _res_exists(legacy):
+		push_warning("world: sprite map miss for '%s%s' — flat original used only as diagnostic fallback (%s)" % [key, suffix, legacy])
+		_sprite_flat_fallbacks += 1
+		return legacy
+	return ""
+
 func _load_sprites() -> void:
 	sprites.clear()
+	_sprite_flat_fallbacks = 0
 	var sids: Array = []
 	for sid in Data.UNITS:
 		sids.append(SPRITE_ALIAS.get(sid, sid))
@@ -392,11 +427,12 @@
 			sids.append(n)
 	# NOTE: probe with _res_exists (ResourceLoader.exists for exported .pck
-	# builds, FileAccess fallback for never-imported editor PNGs).
+	# builds, FileAccess fallback for never-imported editor PNGs). FOLD-07:
+	# mapped bucket path wins; the flat root is diagnostic only.
 	for key in sids:
 		var frames: Array = []
 		var has_dir := false
 		for d in 8:
-			var p := "res://assets/models/sprites/%s_%03d.png" % [key, d * 45]
-			if _res_exists(p):
+			var p := _sprite_res_path(key, "sprite", "_%03d" % (d * 45))
+			if p != "":
 				has_dir = true
 				frames.append(load(p) as Texture2D)
@@ -405,11 +441,15 @@
 		if has_dir:
 			sprites[key] = frames
-		elif _res_exists("res://assets/models/sprites_hi/%s.png" % key):
+		else:
 			# 512 px CPU-Cycles rebake of the donor mesh (ASSET-2 env set).
 			# Prefer hi-res for EVERY env sid, not just tree_*; the low-res
 			# sprites/ copy stays as the fallback (rock/stone/field live there).
-			sprites[key] = [_load_env_tex("res://assets/models/sprites_hi/%s.png" % key)]
-		elif _res_exists("res://assets/models/sprites/%s.png" % key):
-			sprites[key] = [_load_env_tex("res://assets/models/sprites/%s.png" % key)]
+			var hi_p := _sprite_res_path(key, "sprite_hi")
+			if hi_p != "":
+				sprites[key] = [_load_env_tex(hi_p)]
+			else:
+				var low_p := _sprite_res_path(key, "sprite")
+				if low_p != "":
+					sprites[key] = [_load_env_tex(low_p)]
 	# Loud, explicit report: a missing env sid must never be mistaken for a
 	# successfully loaded prop (and never silently borrowed from another pool).
@@ -421,5 +461,5 @@
 	if not missing.is_empty():
 		push_warning("world: env sprite sids did not resolve: %s" % str(missing))
-	print("sprites: %d sets loaded (sids=%d)" % [sprites.size(), sids.size()])
+	print("sprites: %d sets loaded (sids=%d, flat_fallbacks=%d)" % [sprites.size(), sids.size(), _sprite_flat_fallbacks])
 
 func _unit_height(e: Dictionary) -> float:
```

**Why the guard in `_mapped_sprite_path` is mandatory (OBSERVED).**
`asset_paths.gd:59-66` has no `sprite` case in `legacy_for()`, so an unmapped key
falls through to the **OBJ** path. Static probe: `res_for("rock", "sprite_hi")`
returns `res://assets/models/obj/rock.obj`, which exists on disk — accepting it
would load a 3D model as a texture. The `begins_with("res://assets/models/sprites_hi/")`
guard rejects it, so `rock`/`stone`/`field` (the three sprite-only keys) correctly
fall through to their mapped **low**-res sprite, matching the original code's
hi→low order.

### 2.2 `variant3d/scripts/world3d_relief.gd`

```diff
--- world3d_relief.gd.bak-FOLD07
+++ world3d_relief.gd
@@ -42,5 +42,8 @@
 const PROP_TABLE := "res://assets/terrain/mountain_props.json"
 const MODEL_MANIFEST := "res://assets/models/manifest.json"
-const OBJ_DIR := "res://assets/models/obj/"
+# FOLD-07 — resolve relief OBJ geometry through the central manifest resolver,
+# preferring the mapped `assets.obj` bucket path. The flat OBJ root stays in
+# asset_paths.gd as a legacy fallback only; this module composes no flat path.
+const AssetPaths = preload("res://scripts/asset_paths.gd")
 const DONOR_UNITS := 160.0            # pattern_gen.gd:9 (existing port scale)
 const TILE_M := 2.0                   # data.gd:23 / game.gd:16
@@ -339,5 +342,10 @@
 	_meshes = {}
 	for sid in RELIEF_SIDS:
-		var path: String = OBJ_DIR + sid + ".obj"
+		# FOLD-07 — mapped `assets.obj` bucket path first via the central
+		# resolver; flat original is only a diagnostic fallback (never relied
+		# on). COORD's typed `var path: String` form is preserved.
+		var path: String = AssetPaths.existing(sid, "obj")
+		if path.begins_with(AssetPaths.LEGACY_OBJ_DIR):
+			push_warning("world3d_relief: relief OBJ map miss for %s — flat diagnostic fallback %s" % [sid, path])
 		# Without a Godot import pass no .import exists; load() then returns null.
 		# Skip with a warning rather than crash any existing gate (Z05 R11).
```

`AssetPaths.existing()` (`asset_paths.gd:86-93`) checks the mapped bucket path
first, then the untouched flat original, then returns the mapped path. The
warning fires only when the **flat** branch was actually taken, so a healthy
mapped tree is silent. `ResourceLoader.exists()` / `load()` / `push_warning()`
fail-soft behaviour and `stats` shape are unchanged (Z08 §4 invariants intact).

## 3. Resolver proof (static, no Godot)

Helper scripts in `%TEMP%\opencode\` (`fold07_verify.py`, `fold07_proof.py`,
`fold07_syntax.py`) replicated `asset_paths.gd:59-93` against the shipped
`manifest.json`, then compared against the on-disk bucket tree.

| Check | Result | Label |
|---|---|---|
| Manifest `assets.sprite` entries | **123** (matches FOLD-06 §2.5) | OBSERVED |
| Manifest `assets.sprite_hi` entries | **90** (matches FOLD-06 §2.5) | OBSERVED |
| Keys world.gd actually probes | 166 unique | DERIVED |
| Low probes resolved via **mapped** path | **116** (all keys with art) | OBSERVED |
| Low probes resolved via flat diagnostic | **0** | OBSERVED |
| Hi probes resolved via **mapped** path | **90** | OBSERVED |
| Hi probes resolved via flat diagnostic | **0** | OBSERVED |
| OBJ legacy paths wrongly accepted by sprite guard | **0** | OBSERVED |
| `terrainmesh1..4` resolve to `obj/shared/terrain/*.obj` | **4/4**, file exists, none legacy | OBSERVED |

Representative mapped resolutions (all exist on disk):

```
res_for(serdiuk,sprite,_000) -> res://assets/models/sprites/ukr/land_units/serdiuk_000.png
res_for(serdiuk,sprite,_315) -> res://assets/models/sprites/ukr/land_units/serdiuk_315.png
res_for(peasant,sprite,_045) -> res://assets/models/sprites/shared/land_units/peasant_045.png
res_for(cen,sprite,'')       -> res://assets/models/sprites/shared/buildings/cen.png
res_for(tree_fir,sprite_hi)  -> res://assets/models/sprites_hi/shared/terrain/tree_fir.png
res_for(rock,sprite_hi)      -> res://assets/models/obj/rock.obj   [REJECTED by guard]
res_for(rock,sprite)         -> res://assets/models/sprites/shared/terrain/rock.png
res_for(terrainmeshN,obj)    -> res://assets/models/obj/shared/terrain/terrainmeshN.obj
```

**Flat-path audit (active code, comments stripped):** neither file composes a
flat `res://assets/models/sprites/%s...`, `sprites_hi/%s...` or
`OBJ_DIR + sid + ".obj"` path in its resolution path. The only flat composition
left is the explicitly labelled diagnostic branch in `_sprite_res_path`
(`world.gd:408-413`); `world3d_relief.gd` composes no flat path at all.

**Static syntax sanity (no Godot):** both files decode as UTF-8; all
`()[]{}` balanced; no mixed tab/space indentation; pre/post hashes recorded in
frontmatter. A full GDScript parse is G04's gate (§5), not this agent's.

## 4. Semantics preserved (DERIVED, to be re-verified by G04)

1. **Rendering.** 8-direction frame order (`d*45`, 0..315), `has_dir` grouping,
   hi-before-low env preference, `_load_env_tex` direct-PNG decode, and the
   procedural-shape fallback for missing entries are all unchanged — only the
   path source changed. The `sprites:` print gained one diagnostic counter
   field; no assertion/threshold reads it.
2. **Alias resolution.** `SPRITE_ALIAS` (`:212-214`) still feeds the key before
   lookup; the manifest's sprite values are alias-resolved (FOLD-05 §3.1), so
   `musk18→serdiuk` etc. land on the same bucket file.
3. **Season / quality.** No season atlas, `_anim_dir`, quality preset, fog,
   water or terrain code was touched. `t_season_overlay.gd` operates on
   `world3d_terrain.gd`/atlas paths only and has no `sprites` reference.
4. **Z07 atom / Z08 invariants.** `props()`, `set_props_visible()`, `stats`
   keys, MultiMesh batching, raw donor units, authored scaling and yaw, and
   fail-soft warnings in `world3d_relief.gd` are untouched; only the mesh path
   source changed. No sim-state write was added.
5. **Tests.** No test file was edited. `t_render_mode.gd` scans `main.gd` only;
   `t_entities3d.gd` / `t_fx3d.gd` source-scan `world3d_entities.gd` /
   `world3d_fx.gd` only — none scans the two files edited here.

## 5. G04 gate list — **G04 only**, not run here

Pre-flight: `python variant3d\tools\godot_runner.py status` (pending=0,
godot.lock free, `now_serving == next_ticket`).

1. **G1 import pass (blocking).** Editor import pass so the rewritten bucket
   `.import` sidecars produce `.ctex`/`.mesh`; expect the 188 missing-resource
   errors from y04 to clear. `uid` preserved; no hand edit of `.godot/**`.
2. **G2 parse.** `world.gd` and `world3d_relief.gd` load with 0 script errors —
   specifically re-check the former `:341` typed declaration now reads
   `var path: String = AssetPaths.existing(sid, "obj")`.
3. **G3 standing gates.** selftest **29/29**, uitest **17/17**,
   `t_render_mode` (**2D default preserved**), `assert_clean CLEAN`,
   `t_season_overlay`, `t_anim_metrics`, `t_naval`; no threshold lowered.
4. **G4 2D sprite observability.** 2D capture: `sprites: N sets loaded
   (sids=M, flat_fallbacks=0)`; no `world: sprite map miss` warnings; no blank
   sprites; compare sprite-set count with the pre-FOLD-07 2D capture.
5. **G5 relief QA.** Z08/Z07 atom (after its §6 reconciliation) reports
   `skipped_missing_mesh == 0` for all four `terrainmeshN` and no
   `world3d_relief: OBJ map miss` warning; props-ON/OFF A/B PNGs non-blank.
6. **G6 3D regression.** `t_entities3d`, `t_fx3d`, `t_ghost_final_stage` green;
   `stats.obj_available` does not drop; no new `donor_bbox_proxy`; skin count 66.
7. **G7 windowed capture.** 3D P0 + real map and a 2D capture: no new seams,
   proxy boxes or blank sprites.
8. **Refusal condition.** Any parse error, missing sprite set, non-zero
   `flat_fallbacks` for a shipped key, missing relief mesh, or count regression
   ⇒ stop; do **not** move the flat originals aside (FOLD-06 Step 7).

All runtime items above are **UNVERIFIED** by this agent — no Godot, no runner,
no capture.

## 6. Attestation

- Only the two exclusively-owned files were edited; backup creation and this
  report are the only other writes. `asset_paths.gd`, `manifest.json`,
  `skin/index.json`, all `.gd` tests, `.import` files, `app/**`, `data.gd`,
  `game.gd`, `main.gd`, `world3d.gd` and every other FOLD-06-owned file are
  byte-unchanged by this ticket.
- COORD's typed parse fix was preserved, not reverted (§0).
- No Godot process, no runner job, no screenshot, no donor file read/copied,
  no test weakened, no synthetic noise, no invented donor constant.
- **No donor parity claim.** All visual/donor statements remain UNVERIFIED.
- Staying available for COORD follow-up.
