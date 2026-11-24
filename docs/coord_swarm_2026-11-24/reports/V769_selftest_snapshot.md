---
agent: V7-69
role: diagnose and restore the variant3d self-snapshot regression (P1, AUDIT3D-04 E10/E11)
date: 2026-11-24
status: DIAGNOSED + RESTORED (snapshot artefact byte-identical to 2D truth; full selftest 29/29 PASS; fast subset path OK; main.gd diff reported, NOT edited by me)
owns: "variant3d/selftest.json + variant3d/tests/** self-snapshot/harness + this report only"
runner_jobs: ["v769-selftest-snapshot", "v769-selfonly-fallback-probe", "v769-check-self-base-before", "v769-check-self-base-after", "v769-selfonly-fast-after"]
backup: "inbox/backup/selftest.json.bak-V769; inbox/backup/w52_self_base.json.bak-V769"
scope: "no git operations; app/** untouched (app/selftest.json sha256 be49b586... unchanged); no script outside ownership edited"
handoff_to: "V7-70 (main.gd owner) — exact diff below was applied by that owner concurrently, not by me"
---

# V7-69 — self-snapshot format regression: diagnosis, exact diff, before/after evidence

## 1. Root cause (diagnosis, with `path:line`)

The lossy `block_rect` string and the missing `_json_rect` do **not** come from
`selftest.json` or from any `variant3d/tests/**` harness script. They come from the
snapshot writer/loader in `variant3d/scripts/main.gd`, which had been reverted to
the pre-fix W5-2 form:

| Evidence | Before (regressed) | 2D truth / after |
|---|---|---|
| format marker | `variant3d/scripts/main.gd:760` `"format": "w52-self-base-1"` | `app/scripts/main.gd:721` / `variant3d/scripts/main.gd:761` (owner-applied) `"w52-self-base-2"` |
| serializer | `variant3d/scripts/main.gd:769` `JSON.stringify(dump)` + `:763-764` `Marshalls.raw_to_base64(game.tileblock/mine_mask)`, `:753-758` starts/zones downgraded to float arrays | `app/scripts/main.gd:730` / `variant3d:770` `var_to_str(dump)` with native `PackedByteArray`/`Vector2` (`:764-766`) |
| numeric parity | `variant3d/scripts/main.gd:807-808`, `:828-829` plain `float(a) == float(b)` | `app/scripts/main.gd:768-775`, `:816-820` / `variant3d:818+` float32-quantised via `PackedFloat32Array` |
| `_json_rect()` | absent (0 matches in regressed file) | `app/scripts/main.gd:778-797` / `variant3d:818-837` |
| loader parse | `variant3d/scripts/main.gd:842` `JSON.parse_string(txt)`, no normalisation | `app/scripts/main.gd:834` / `variant3d:874` `str_to_var(txt)`; `app:900-904` / `variant3d:940-944` normalise every `block_rect` through `_json_rect()` |
| path resolution | `variant3d/scripts/main.gd:838`, `:991` raw `path` / raw `FileAccess.file_exists(self_snapshot_path)` | `app/scripts/main.gd:829`, `:942` / `variant3d:869`, `:1022` `_pick_target(...)` |

Why this corrupts simulation state: `app/scripts/game.gd:5499-5512` `_vec_enc` does
not encode `Rect2`, so the canonical snapshot stores a native `Rect2` (`app/tests/results/w52_self_base.json:19`
`Rect2(591.98944, 30.532219, 13.1562, 12.470982)`). `JSON.stringify` instead emits
the string `"[P: (591.9894, 30.53222), S: (13.1562, 12.47098)]"` (regressed
`variant3d/tests/results/w52_self_base.json:1`, sha256 `9b237b80…`), while
`game.gd:129` requires `var r: Rect2 = b.get("block_rect", Rect2())`. The
`_load_self_base()` parity gate then rejects the fast path (silent full mapgen
fallback). Cross-ref `AUDIT3D_04_sim_parity.md:34-35,53-55` and
`W52_tiers_fast_subsets.md:206-220` (the original 2D corruption and fix).

**`app/selftest.json` is not the fix site.** It is the *report artifact* written by
`variant3d/scripts/main.gd:1882` (`JSON.stringify(report, "  ")`). Backup comparison
showed 0 differences in step name/detail/passed across all 29 steps and identical
`resources_gathered`/`shots_fired`; only `wall_ms` (26 entries) and `sim_seconds`
differ. I therefore did **not** copy it. Job 91 regenerated `variant3d/selftest.json`
with `sim_seconds 366.46875` (app canonical `366.71875`), `passed:true`, 29/29.

## 2. Exact diff needed (for main.gd owner; NOT applied by me)

`variant3d/scripts/main.gd:746-935` → `app/scripts/main.gd:710-926`, verbatim,
keeping all V7-50 3D additions outside that range:

```diff
--- variant3d/scripts/main.gd:746-935
+++ app/scripts/main.gd:710-926
@@ -5,22 +5,19 @@
 	add_child(game)
 	game.setup(start_mode)
-	var starts: Array = []
-	for s in game.map_starts:
-		starts.append([float(s.x), float(s.y)])
-	var zones: Array = []
-	for z in game.cluster_zones:
-		var zd: Dictionary = z
-		zones.append([float(zd.pos.x), float(zd.pos.y), float(zd.r)])
+	# var_to_str preserves Variant types exactly (JSON.parse_string turns every
+	# number into a float and Rect2 into a String, which corrupts entity ids and
+	# building block_rects on load). The inner "base" blob is game.serialize()'s
+	# own base64 form, which deserialize() expects verbatim.
 	var dump := {
-		"format": "w52-self-base-1", "seed": int(Data.RANDOM_SEED),
+		"format": "w52-self-base-2", "seed": int(Data.RANDOM_SEED),
 		"map_w": int(Data.MAP_W), "map_h": int(Data.MAP_H),
 		"base": game.serialize(),
-		"tileblock": Marshalls.raw_to_base64(game.tileblock),
-		"mine_mask": Marshalls.raw_to_base64(game.mine_mask),
-		"starts": starts, "zones": zones, "meta": game.map_meta,
+		"terrain": game.terrain, "blocked": game.blocked, "height": game.height,
+		"tileblock": game.tileblock, "mine_mask": game.mine_mask,
+		"starts": game.map_starts, "zones": game.cluster_zones, "meta": game.map_meta,
 		"rng_state": game.rng.get("state"), "gen_rng_state": game.gen_rng.get("state"),
 		"sow_t": game.sow_t, "ai_enabled": Data.AI_ENABLED,
 	}
-	var out := _write_text(self_base_dump_path, JSON.stringify(dump))
+	var out := _write_text(self_base_dump_path, var_to_str(dump))
 	if out == "":
 		printerr("dump-self-base: could not write ", self_base_dump_path)
@@ -61,6 +58,33 @@
 		return true
 	if (a is int or a is float) and (b is int or b is float):
-		return float(a) == float(b)
+		# Sim positions are float32 (Vector2); JSON keeps float64 text, so the
+		# same Vector2 can print as two distinct float64 values. Compare after
+		# quantising both through float32 - that is the sim's actual precision.
+		var q := PackedFloat32Array()
+		q.append(float(a))
+		q.append(float(b))
+		return q[0] == q[1]
 	return str(a) == str(b)
+
+func _json_rect(v: Variant) -> Rect2:
+	if v is Rect2:
+		return v
+	if v is String:
+		var s := str(v)
+		var p0 := s.find("(")
+		var p1 := s.find(")", p0 + 1)
+		var p2 := s.find("(", p1 + 1)
+		var p3 := s.find(")", p2 + 1)
+		if p0 >= 0 and p1 > p0 and p2 > p1 and p3 > p2:
+			var a := s.substr(p0 + 1, p1 - p0 - 1).split(",")
+			var b := s.substr(p2 + 1, p3 - p2 - 1).split(",")
+			for i in a.size():
+				a[i] = str(a[i]).strip_edges()
+			for i in b.size():
+				b[i] = str(b[i]).strip_edges()
+			if a.size() == 2 and b.size() == 2 and a[0].is_valid_float() and a[1].is_valid_float() \
+				and b[0].is_valid_float() and b[1].is_valid_float():
+				return Rect2(float(a[0]), float(a[1]), float(b[0]), float(b[1]))
+	return Rect2()
 
 func _json_diff(a: Variant, b: Variant, path: String) -> String:
@@ -82,23 +106,27 @@
 		return ""
 	if (a is int or a is float) and (b is int or b is float):
-		return "" if float(a) == float(b) else path + " " + str(b) + "->" + str(a)
+		var q := PackedFloat32Array()
+		q.append(float(a))
+		q.append(float(b))
+		return "" if q[0] == q[1] else path + " " + str(b) + "->" + str(a)
 	return "" if str(a) == str(b) else path + " " + str(b).substr(0, 100) + "->" + str(a).substr(0, 100)
 
 # W5-2: restore a pre-baked snapshot into a FRESH C3Game without running
 # mapgen. The canonical deserializer restores entities/players/stats; it is
-# called with a 0x0 map so its own _assign_tileblocks() pass touches no cells,
-# then the real terrain arrays are installed verbatim from the dump. Returns
+# called with a 1x1 stub map so its own _assign_tileblocks() pass touches one
+# cell, then the real arrays are installed verbatim from the Variant dump. Returns
 # false (caller falls back to full setup) on any validation or parity failure.
 func _load_self_base(g: C3Game, path: String) -> bool:
-	var txt := FileAccess.get_file_as_string(path)
+	var resolved := _pick_target(path)
+	var txt := FileAccess.get_file_as_string(resolved)
 	if txt == "":
-		printerr("self-snapshot: cannot read ", path)
-		return false
-	var parsed = JSON.parse_string(txt)
+		printerr("self-snapshot: cannot read ", resolved)
+		return false
+	var parsed = str_to_var(txt)
 	if not parsed is Dictionary:
-		printerr("self-snapshot: invalid JSON in ", path)
+		printerr("self-snapshot: not a Variant snapshot in ", path)
 		return false
 	var d: Dictionary = parsed
-	if str(d.get("format", "")) != "w52-self-base-1" or not d.has("base"):
+	if str(d.get("format", "")) != "w52-self-base-2" or not d.has("base"):
 		printerr("self-snapshot: bad format in ", path)
 		return false
@@ -140,18 +168,14 @@
 	for i in mini(g.height.size(), int(raw.size() / 4)):
 		g.height[i] = raw.decode_float(i * 4)
-	g.tileblock = Marshalls.base64_to_raw(str(d.get("tileblock", "")))
-	g.mine_mask = Marshalls.base64_to_raw(str(d.get("mine_mask", "")))
+	if d.get("tileblock") is PackedByteArray:
+		g.tileblock = d.tileblock
+	if d.get("mine_mask") is PackedByteArray:
+		g.mine_mask = d.mine_mask
 	var sarr = d.get("starts", [])
 	if sarr is Array:
-		g.map_starts = []
-		for s in sarr:
-			var sa: Array = s
-			g.map_starts.append(Vector2(float(sa[0]), float(sa[1])))
+		g.map_starts = (sarr as Array).duplicate(true)
 	var zarr = d.get("zones", [])
 	if zarr is Array:
-		g.cluster_zones = []
-		for z in zarr:
-			var za: Array = z
-			g.cluster_zones.append({"pos": Vector2(float(za[0]), float(za[1])), "r": float(za[2])})
+		g.cluster_zones = (zarr as Array).duplicate(true)
 	var meta = d.get("meta", {})
 	g.map_meta = meta.duplicate(true) if meta is Dictionary else {}
@@ -165,4 +189,9 @@
 	Data.AI_ENABLED = bool(d.get("ai_enabled", true))
 	g.sow_t = float(d.get("sow_t", 0.0))
+	# Defensive: the Variant snapshot preserves Rect2 natively; this only
+	# normalises any legacy string-form block_rect from an older dump.
+	for e in g.entities:
+		if e.has("block_rect"):
+			e["block_rect"] = _json_rect(e.block_rect)
 	g.events.clear()
 	g.projectiles.clear()
 	g.corpses.clear()
@@ -171,6 +200,4 @@
 	# Parity gate: refuse the fast path unless the loaded game reproduces every
 	# serialized field and the non-serialized map arrays byte-for-byte.
-	# JSON.parse_string returns floats for integer-looking numbers, so a plain
-	# str() compare would report a false MISMATCH on every numeric field.
 	var now := g.serialize()
 	var same := _same_json(now, b)
@@ -178,7 +205,7 @@
 		var dpath := _json_diff(now, b, "root")
 		printerr("self-snapshot: first difference at ", dpath)
-	if g.tileblock != Marshalls.base64_to_raw(str(d.get("tileblock", ""))):
-		same = false
-	if g.mine_mask != Marshalls.base64_to_raw(str(d.get("mine_mask", ""))):
+	if d.get("tileblock") is PackedByteArray and g.tileblock != d.tileblock:
+		same = false
+	if d.get("mine_mask") is PackedByteArray and g.mine_mask != d.mine_mask:
 		same = false
 	if g.map_starts.size() != (sarr as Array).size():
```

Plus the one-line fast-path check (`variant3d/scripts/main.gd:991` → `app:942`):

```diff
-	if selftest_only != "" and self_snapshot_path != "" and FileAccess.file_exists(self_snapshot_path):
+	if selftest_only != "" and self_snapshot_path != "" and FileAccess.file_exists(_pick_target(self_snapshot_path)):
```

**Status of this diff:** while my jobs were queued, the main.gd owner applied it
(main.gd mtime 11/24 13:15:40; parse job 102 `v770-main-parse` ok; `PROGRESS.md:250`
records the relay to V7-70). I did **not** edit main.gd. Current owner-applied lines
are `variant3d/scripts/main.gd:761,770,818,869,874,879,940-944,1022`.

## 3. Change I made (owned file only)

`variant3d/tests/results/w52_self_base.json` — the self-snapshot artefact itself.
Replaced the regressed `w52-self-base-1` JSON (sha256 `9b237b801857a932d599623a656765135faa1d810500b621a4d443d20a2be2ff`,
1,325,160 bytes, 1 line, lossy `"[P: … S: …]"`) with a **byte-identical copy of the
canonical 2D snapshot** `app/tests/results/w52_self_base.json` (sha256
`d807526fbc8b830a83c7ffa601ceb2526172aa597e27bf954d23af7a010f7b54`, 2,943,049 bytes,
`format w52-self-base-2`, native `Rect2(...)` at line 19). No new values invented;
seed 20261113, 320×320 and 18 entities match variant config/mapgen. Backup:
`inbox/backup/w52_self_base.json.bak-V769`.

`variant3d/selftest.json` was regenerated by the required verification job (report
artifact, not a hand edit); backup `inbox/backup/selftest.json.bak-V769`.
Diagnostic artifacts: `variant3d/tests/results/v769_selfonly_probe.json`,
`variant3d/tests/results/v769_selfonly_fast_after.json`.

## 4. Runner jobs and measured results (variant3d runner only)

| ticket | job id | job | wait (s) | run (s) | exit/status |
|---|---|---|---|---|---|
| 91 | `v769-selftest-snapshot` | **required** full `--self-test variant3d/selftest.json` | 175.43 | **85.19** | 0 / ok |
| 92 | `v769-selfonly-fallback-probe` | before: `--self-only formations_morale` + old snapshot | 260.59 | **53.07** | 0 / ok |
| 93 | `v769-check-self-base-before` | before: `--check-self-base` on old snapshot (post main.gd fix) | 313.70 | 4.95 | 1 / failed (expected MISMATCH) |
| 110 | `v769-selfonly-fast-after` | after: same subset + restored snapshot | 381.26 | **25.92** | 0 / ok |
| 111 | `v769-check-self-base-after` | after: `--check-self-base` on restored snapshot | 407.29 | 4.92 | 0 / ok |

Required gate (ticket 91): `variant3d/selftest.json` `passed:true`, **29/29 steps
passed**, all 29 step names/details/`passed` flags identical to `app/selftest.json`
(0 diffs); `resources_gathered` and `shots_fired 73` identical. Only timing differs:
`sim_seconds 366.46875` vs app `366.71875`, plus `wall_ms`. App canonical hash
`be49b5861754610415dffbc96e08e4f9c333bfb6ccb2406fd3fd4ab1f56ea874` unchanged.
No git operations were used.

## 5. Fallback log evidence, before → after

**Before (regressed snapshot/script):**

- Ticket 91 full gate stdout has **no** `SELF-SNAPSHOT` line at all — expected, the
  fast path is subset-only (`main.gd:991`, `W52_tiers_fast_subsets.md:228`).
- Ticket 92 subset + old snapshot stdout (`…/00000092_v769-selfonly-fallback-probe/stdout.txt:1-4`)
  likewise has **no** `SELF-SNAPSHOT fast load parity` line: the old
  `FileAccess.file_exists(self_snapshot_path)` check did not resolve the relative
  path, so the snapshot was silently ignored and full mapgen ran (run 53.07 s).
  No `first difference at …` line was produced in any job — direct runtime proof of
  the `block_rect` string mismatch exists only as static evidence (§1) plus the
  format rejection below.
- Ticket 93, after the owner's main.gd fix but with the stale artefact:
  `stdout.txt:3` `SELF-SNAPSHOT check: MISMATCH`; `stderr.txt:1`
  `self-snapshot: bad format in variant3d/tests/results/w52_self_base.json`.
  This is the observable form of the fallback trigger: the w52-self-base-1 file
  is rejected by the w52-self-base-2 loader.

**After (restored snapshot + owner-fixed main.gd):**

- Ticket 111 `stdout.txt:3-4`: `SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)`
  and `SELF-SNAPSHOT check: OK`; `stderr.txt` empty (0 lines).
- Ticket 110 `stdout.txt:3`: `SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)`,
  then `SELFTEST baseline restore #1 parity: res_nodes=OK, stats=OK, blocked=OK,
  squads=OK, objectives=OK, ai=OK`; no `bad format`, no `MISMATCH`, no first-difference
  line. Same subset as ticket 92: **53.07 s → 25.92 s** (−27.15 s, −51.2 %),
  demonstrating that full-mapgen fallback is no longer taken.

Unrelated, out-of-scope stderr in tickets 91/92: `world3d_entities.gd:576/609/611`
parse errors from V7-65's concurrent edit; the sim-only selftest still passed.
Ticket 110 stderr contains only a documented pose-approximation warning.

## 6. Open questions

1. A direct `self-snapshot: first difference at root.entities[…].block_rect …`
   line was never captured: ticket 92 never invoked the loader (path-resolution
   bug), and ticket 93 failed earlier at the format gate. E11's string-MISMATCH
   consequence remains a strong static inference, not a captured log.
2. `sim_seconds` still varies run to run (app 366.71875, prior variant 366.5 /
   366.90625, this run 366.46875). Timing artefact, cause UNVERIFIED; no assertion
   depends on it.
3. main.gd was fixed by another agent mid-flight; if that owner reverts or further
   edits the snapshot functions, re-run `--check-self-base` (job 111 recipe).
4. `variant3d/selftest.json` is deliberately not byte-identical to app's because
   each live run rewrites timing fields. If a clean gate requires byte identity,
   that policy conflicts with the canonical report-writing behaviour — needs a
   coordinator decision.
5. The restored snapshot is a verbatim copy of the 2D artefact, not a fresh
   variant3d `--dump-self-base`. Parity OK proves it reproduces the canonical
   post-setup world, but a dump round-trip job was not spent (queue budget).
