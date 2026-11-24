---
owner: W2-7
swarm: coord_swarm_2026-11-24
ticket: G-ENV2 (R10 claim 14 / ranked gap 2)
date: 2026-11-24
scope: verify + wire donor ambient beds in app/scripts/audio.gd ONLY; read-only donor
donor: C:\Games\Cossacks 3 (private use, bytes read via Python latin-1, never run/copied)
backup: inbox/backup/audio.gd.bak-W27
---

# W27 — Donor ambient beds (G-ENV2)

## Verification of the current source (before edit)

`app/scripts/audio.gd` dispatched only **2 of 5** donor ambient beds:

- `app/scripts/audio.gd:63-69` — `amb_atmosphere` in `start_music()`, volume `Data.AMBIENT_VOLUME_DB`, replayed by `_replay_ambient()` at `:136-138`.
- `app/scripts/audio.gd:71-97` — `amb_windmill` dedicated looping player, volume `Data.AMBIENT_VOLUME_DB - 10.0`, distance scan + attenuation in `_process()` at `:84-124`, replay guard at `:126-130`.
- The only AMBIENT constants were `AMBIENT_MAX_DIST := 60.0` (`:21`) and `AMBIENT_TICK := 0.4` (`:22`).
- Port assets `amb_wind.ogg`, `amb_towneur.ogg`, `amb_sea.ogg` existed under `app/assets/sounds/` but were **never dispatched** — exactly as `R10_environment.md:31` claimed.

## Donor bed list with evidence

Read-only donor enumerations (Python `latin-1`):

1. `data\sounds\ambient\ambient.snd:103-135` declares exactly five ambient loops:
   - `:104-105` `amb_atmosphere` → `amb_atmosphere.ogg` (`DefVolume=1`, `DefMaxDistance=100`)
   - `:121-122` `amb_towneur` → `amb_towneur.ogg`
   - `:125-126` `amb_wind` → `amb_wind.ogg`
   - `:129-130` `amb_windmill` → `amb_windmill.ogg`
   - `:133-134` `amb_sea` → `amb_sea.ogg`
   The `data\sounds\ambient\` directory listing confirms all five `.ogg` files exist there.
2. `data\gui\menu.inc\doambientsound.inc:56-77` sets `amb_wind` `sndVol=0.2`, `sndRangeMin=-5`, `sndRangeMax=100`, ranges enabled; no object drives its volume → continuous bed.
3. `doambientsound.inc:80-103` sets `amb_towneur` up at `vol=1`, then **zeroes** it at `:103`; `doambientsound.inc:106-129` does the same for `amb_sea` at `:129` — both are driven later from `gui.script`.
4. `data\scripts\lib\gui.script:3234-3236` names the three driven beds: `cMill='amb_windmill'`, `cTown='amb_towneur'`, `cSea='amb_sea'`.
5. `gui.script:3266-3304` distance ramps: `cBaseVolumeMill=0.3`, `cBaseVolumeTown=1.0`, `mindst=20`, `maxdst=60`; town volume = `maxvoltown * cBaseVolumeTown`, set-playing only when `>0`. Scan covers built storehouses (`bbuilt`) with `usage=gc_obj_usage_mill` / `gc_obj_usage_center`.
6. `gui.script:3305-3335` sea bed: `cBaseVolumeSea=0.5`, `maxdstsea=60`, `mindstsea=20`, `cSeaBorder=40`, `cOptimizer=4`; water cells counted on a 4 m grid inside the frustum, `seafactor=Clamp(seafactor/200,0,1)`, delta clamped to `(-0.15,+0.075)`, half-step smoothing, playing only when `newvol>0.01`.
7. `data\env\env.cfg:15-26` and `data\env\time.cfg:5-9` were also read: they own the disabled date-time/colour/sky/PFX subsystem (`time.cfg` `hour=10`, `speedfactor=8`, `normalspeedfactor=10`), not the ambient beds — no ambient-bed identifiers there. Agrees with R10 claim 11 (day/night manager disabled).

## Bed status table

| Bed | Donor evidence | Port asset (`app/assets/sounds/`) | Audio.gd before | Status after W27 |
|---|---|---|---|---|
| `amb_atmosphere` | `ambient.snd:104-105` | `amb_atmosphere.ogg` (+ `.import`) | dispatched `:63-69` | **VERIFIED-ALREADY** — untouched |
| `amb_windmill` | `ambient.snd:129-130`; `gui.script:3234,3266-3302` | `amb_windmill.ogg` (+ `.import`) | dispatched `:71-97` + scan `:84-124` | **VERIFIED-ALREADY** — volume/behaviour untouched |
| `amb_wind` | `ambient.snd:125-126`; `doambientsound.inc:56-77` | `amb_wind.ogg` (+ `.import`) | not dispatched | **WIRED** — dedicated looping player, continuous `0.2` linear (`-13.98 dB` below atmosphere) |
| `amb_towneur` | `ambient.snd:121-122`; `gui.script:3235,3292-3304` | `amb_towneur.ogg` (+ `.import`) | not dispatched | **WIRED** — 20→60 m distance ramp to nearest finished `cen` building, base volume 1 |
| `amb_sea` | `ambient.snd:133-134`; `gui.script:3236,3305-3335` | `amb_sea.ogg` (+ `.import`) | not dispatched | **WIRED** — 4 m water grid, 20→60 m ramp, `seafactor/200`, donor delta smoothing, base volume 0.5 |

**MISSING-ASSET: none.** Every one of the five donor bed identifiers has a matching port `.ogg`; no fake bed and no new binary were added. (Donor `.ogg` files were enumerated by filename only; none were copied.)

## Exact diff applied

`git diff -- app/scripts/audio.gd` (git notes the file was LF in the working copy and will be CRLF when git next touches it; no line-ending edit was made by W27):

```diff
diff --git a/app/scripts/audio.gd b/app/scripts/audio.gd
index 747ee298..95b7389a 100644
--- a/app/scripts/audio.gd
+++ b/app/scripts/audio.gd
@@ -19,7 +19,16 @@ const MUSIC_FALLBACK := "ukr"
 # per resource (units/unit.inc/ontagstates.inc). Both are driven from the game
 # state exposed by main.gd, which owns the event dispatch and is read-only here.
 const AMBIENT_MAX_DIST := 60.0   # same audibility cutoff as play() below
-const AMBIENT_TICK := 0.4        # seconds between mill-ambient proximity checks
+const AMBIENT_TICK := 0.4        # seconds between ambient proximity checks
+# The five donor ambient beds (donor sounds/ambient/ambient.snd:103-135).
+const AMB_ATMOSPHERE := "amb_atmosphere"
+const AMB_WIND := "amb_wind"
+const AMB_WINDMILL := "amb_windmill"
+const AMB_TOWN := "amb_towneur"
+const AMB_SEA := "amb_sea"
+# Donor gui.script:3310,3328 - sea scan cell size and frustum-cell divisor.
+const AMBIENT_SEA_STEP := 4.0
+const AMBIENT_SEA_DIV := 200.0
 
 var files: Array = []          # the names of all the sound files
 var cache: Dictionary = {}     # name -> AudioStream (loaded when first needed)
@@ -29,6 +38,12 @@ var music_player: AudioStreamPlayer
 var ambient_player: AudioStreamPlayer
 var mill_ambient_player: AudioStreamPlayer
 var mill_ambient_active := false
+var wind_ambient_player: AudioStreamPlayer
+var town_ambient_player: AudioStreamPlayer
+var town_ambient_active := false
+var sea_ambient_player: AudioStreamPlayer
+var sea_ambient_active := false
+var sea_ambient_vol := 0.0     # donor's smoothed linear sea volume
 var ambient_tick := 0.0
 var last_play: Dictionary = {}
 var music_on := false
@@ -60,7 +75,7 @@ func start_music(nation := "ukr") -> void:
 		music_player.finished.connect(_replay_music)
 		music_player.play()
 	ambient_player = AudioStreamPlayer.new()
-	var a := _stream("amb_atmosphere")
+	var a := _stream(AMB_ATMOSPHERE)
 	if a != null:
 		ambient_player.stream = a
 		ambient_player.volume_db = Data.AMBIENT_VOLUME_DB
@@ -68,10 +83,10 @@ func start_music(nation := "ukr") -> void:
 		ambient_player.finished.connect(_replay_ambient)
 		ambient_player.play()
 
-	# Dedicated looping player for the donor windmill ambience. It is not taken
+	# Dedicated looping players for the other four donor beds. None is taken
 	# from the 16-player polyphony pool: an ambient bed must never steal a slot
-	# from a shot or a work sound, and there is exactly one of it (no orphans).
-	var wm := _stream("amb_windmill")
+	# from a shot or a work sound, and each bed exists exactly once (no orphans).
+	var wm := _stream(AMB_WINDMILL)
 	if wm != null:
 		mill_ambient_player = AudioStreamPlayer.new()
 		if wm is AudioStreamOggVorbis:
@@ -81,13 +96,46 @@ func start_music(nation := "ukr") -> void:
 		add_child(mill_ambient_player)
 		mill_ambient_player.finished.connect(_replay_mill_ambient)
 
-# Quiet windmill bed while a finished mill is near the camera. main.gd owns the
-# game/camera objects; this node is its child, so read them through get_parent()
-# without editing (or owning) main.gd / game.gd. The proximity scan is throttled
-# and touches no game state ΓÇö it only reads buildings and camera position.
+	# amb_wind: continuous bed, donor doambientsound.inc:56-77 sets vol 0.2 and
+	# no object drives its volume. 0.2 linear == -13.98 dB vs amb_atmosphere's 1.
+	var wind := _ambient_player(AMB_WIND, Data.AMBIENT_VOLUME_DB + linear_to_db(0.2))
+	if wind != null:
+		wind_ambient_player = wind
+		wind.finished.connect(_replay_wind_ambient)
+		wind.play()
+
+	# amb_towneur / amb_sea start silent; _process() drives their volume by
+	# distance (donor gui.script:3303-3335), exactly like the mill bed above.
+	var town := _ambient_player(AMB_TOWN, Data.AMBIENT_VOLUME_DB)
+	if town != null:
+		town_ambient_player = town
+		town.finished.connect(_replay_town_ambient)
+	var sea := _ambient_player(AMB_SEA, Data.AMBIENT_VOLUME_DB)
+	if sea != null:
+		sea_ambient_player = sea
+		sea.finished.connect(_replay_sea_ambient)
+
+# One dedicated looping ambient player. Same loop-fallback pattern as the
+# windmill bed above, shared by the three newly wired beds.
+func _ambient_player(name: String, vol_db: float) -> AudioStreamPlayer:
+	var s := _stream(name)
+	if s == null:
+		return null
+	if s is AudioStreamOggVorbis:
+		s.loop = true
+	var p := AudioStreamPlayer.new()
+	p.stream = s
+	p.volume_db = vol_db
+	add_child(p)
+	return p
+
+# Quiet ambient beds while a finished mill / town hall is near the camera or
+# water is in view. main.gd owns the game/camera objects; this node is its child,
+# so read them through get_parent() without editing (or owning) main.gd/game.gd.
+# The proximity scan is throttled and touches no game state ΓÇö it only reads
+# buildings, terrain and camera position.
 func _process(dt: float) -> void:
-	if not music_on or not Data.AUDIO_ENABLED or mill_ambient_player == null \
-			or not is_instance_valid(mill_ambient_player):
+	if not music_on or not Data.AUDIO_ENABLED:
 		return
 	ambient_tick -= dt
 	if ambient_tick > 0.0:
@@ -97,31 +145,90 @@ func _process(dt: float) -> void:
 	if parent == null or not is_instance_valid(parent):
 		return
 	var game = parent.get("game")
-	if game == null:
+	if game == null or not is_instance_valid(game):
 		return
 	var center := Vector2.ZERO
 	var cam = parent.get("camera")
 	if cam != null and is_instance_valid(cam):
 		center = cam.global_position / 16.0   # main.gd's metres convention
-	var nearest := AMBIENT_MAX_DIST
+
+	# Donor gui.script:3274-3298 scans built storehouses for mill/town usage.
+	var nearest_mill := AMBIENT_MAX_DIST
+	var nearest_town := AMBIENT_MAX_DIST
 	for b in game.live_blds:
-		if b.dead or str(b.get("sid", "")) != "mil" or not bool(b.get("finished", false)):
+		if b.dead or not bool(b.get("finished", false)):
 			continue
+		var sid := str(b.get("sid", ""))
 		var d: float = b.pos.distance_to(center)
-		if d < nearest:
-			nearest = d
-	if nearest >= AMBIENT_MAX_DIST:
-		if mill_ambient_active:
-			mill_ambient_player.stop()
-			mill_ambient_active = false
-		return
-	# Quiet bed, further attenuated with distance just like the donor's
-	# volume-by-distance windmill (gui.script:3234-3303).
-	mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0 \
-			- clampf((nearest - 8.0) * 0.25, 0.0, 8.0)
-	if not mill_ambient_active or not mill_ambient_player.playing:
-		mill_ambient_player.play()
-		mill_ambient_active = true
+		if sid == "mil" and d < nearest_mill:
+			nearest_mill = d
+		elif sid == "cen" and d < nearest_town:
+			nearest_town = d
+
+	if mill_ambient_player != null and is_instance_valid(mill_ambient_player):
+		if nearest_mill >= AMBIENT_MAX_DIST:
+			if mill_ambient_active:
+				mill_ambient_player.stop()
+				mill_ambient_active = false
+		else:
+			# Quiet bed, further attenuated with distance just like the donor's
+			# volume-by-distance windmill (gui.script:3285-3302).
+			mill_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB - 10.0 \
+					- clampf((nearest_mill - 8.0) * 0.25, 0.0, 8.0)
+			if not mill_ambient_active or not mill_ambient_player.playing:
+				mill_ambient_player.play()
+				mill_ambient_active = true
+
+	# amb_towneur: donor gui.script:3292-3304 ramps 20..60 m at base volume 1.
+	if town_ambient_player != null and is_instance_valid(town_ambient_player):
+		var town_vol := clampf(1.0 - (nearest_town - 20.0) / 40.0, 0.0, 1.0)
+		if town_vol <= 0.0:
+			if town_ambient_active:
+				town_ambient_player.stop()
+				town_ambient_active = false
+		else:
+			town_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB + linear_to_db(town_vol)
+			if not town_ambient_active or not town_ambient_player.playing:
+				town_ambient_player.play()
+				town_ambient_active = true
+
+	# amb_sea: donor gui.script:3313-3335 counts water cells on a 4 m grid in
+	# view, ramps volume by 20..60 m distance, then smooths it (base vol 0.5).
+	# The 2D port has no frustum query, so a camera-centred +/-60 m window is
+	# the read-only stand-in; no game state is written.
+	if sea_ambient_player != null and is_instance_valid(sea_ambient_player):
+		var terrain = game.get("terrain")
+		var sea_target := 0.0
+		if terrain is PackedByteArray and not (terrain as PackedByteArray).is_empty():
+			var water_cells := 0
+			var nearest_sea := AMBIENT_MAX_DIST
+			var gx := int(center.x / AMBIENT_SEA_STEP)
+			var gy := int(center.y / AMBIENT_SEA_STEP)
+			var steps: int = int(AMBIENT_MAX_DIST / AMBIENT_SEA_STEP)
+			for iy in range(gy - steps, gy + steps + 1):
+				for ix in range(gx - steps, gx + steps + 1):
+					var p := Vector2(ix * AMBIENT_SEA_STEP, iy * AMBIENT_SEA_STEP)
+					if not game._is_water(p):
+						continue
+					water_cells += 1
+					var d: float = p.distance_to(center)
+					if d < nearest_sea:
+						nearest_sea = d
+			var sea_factor := clampf(float(water_cells) / AMBIENT_SEA_DIV, 0.0, 1.0)
+			var sea_near := clampf(1.0 - (nearest_sea - 20.0) / 40.0, 0.0, 1.0)
+			sea_target = sea_near * 0.5 * sea_factor
+		# donor :3329-3334 delta clamp (-0.15..+0.075) and half-step smoothing.
+		var delta := clampf(sea_target - sea_ambient_vol, -0.15, 0.075)
+		sea_ambient_vol = clampf(sea_ambient_vol + delta * 0.5, 0.0, 1.0)
+		if sea_ambient_vol <= 0.01:
+			if sea_ambient_active:
+				sea_ambient_player.stop()
+				sea_ambient_active = false
+		else:
+			sea_ambient_player.volume_db = Data.AMBIENT_VOLUME_DB + linear_to_db(sea_ambient_vol)
+			if not sea_ambient_active or not sea_ambient_player.playing:
+				sea_ambient_player.play()
+				sea_ambient_active = true
 
 func _replay_mill_ambient() -> void:
 	# Covers importers that do not honour AudioStreamOggVorbis.loop. Never
@@ -129,6 +236,19 @@ func _replay_mill_ambient() -> void:
 	if music_on and mill_ambient_active and is_instance_valid(mill_ambient_player):
 		mill_ambient_player.play()
 
+func _replay_wind_ambient() -> void:
+	if music_on and wind_ambient_player != null and is_instance_valid(wind_ambient_player):
+		wind_ambient_player.play()
+
+func _replay_town_ambient() -> void:
+	# Never restart a bed deliberately stopped when the town hall went away.
+	if music_on and town_ambient_active and is_instance_valid(town_ambient_player):
+		town_ambient_player.play()
+
+func _replay_sea_ambient() -> void:
+	if music_on and sea_ambient_active and is_instance_valid(sea_ambient_player):
+		sea_ambient_player.play()
+
 func _replay_music() -> void:
 	if music_on and music_player != null and is_instance_valid(music_player):
 		music_player.play()
@@ -140,11 +260,15 @@ func _replay_ambient() -> void:
 func stop_all() -> void:
 	music_on = false
 	mill_ambient_active = false
+	town_ambient_active = false
+	sea_ambient_active = false
+	sea_ambient_vol = 0.0
 	for p in players:
 		if is_instance_valid(p):
 			p.stop()
 			p.stream = null
-	for p in [music_player, ambient_player, mill_ambient_player]:
+	for p in [music_player, ambient_player, mill_ambient_player,
+			wind_ambient_player, town_ambient_player, sea_ambient_player]:
 		if p != null and is_instance_valid(p):
 			p.stop()
 			p.stream = null
```

No called symbol was renamed; `_stream()`, `_process()`, `_replay_mill_ambient()`, `names_for()`, `play()` etc. keep their names. Only one source file was edited (plus this report).

## Backup

`Copy-Item app\scripts\audio.gd inbox\backup\audio.gd.bak-W27` — created before the first edit (10,125 bytes, verified present). It holds the exact pre-edit file.

## Runner job + result

Command (single targeted test, no full selftest):

```
python app\tools\godot_runner.py run --id w27-ambient --timeout 180 -- --headless --path app --script res://tests/t_audio_events.gd
```

Runner log: `[runner] ticket 1263 'w27-ambient' START (waited 262.22s)` → `[runner] ticket 1263 'w27-ambient' END ok (run 9.95s)`. Spool: `app/.godot_queue/results/00001263_w27-ambient/` (`stdout.txt` = Godot 4.7.2 banner only; `stderr.txt` = pre-existing test-harness cleanup warnings: 35 ObjectDB instances leaked at exit / 1 resource still in use — the test creates an audio node + 16 pool players and never frees them, and does not call `start_music()`, so W27's three new players are not constructed in this test). No parse/runtime errors attributable to W27.

Result file read: `app/tests/results/t_audio_events.json` → **`passed: true`, 5/5 checks PASS**:

| check | result | detail |
|---|---|---|
| `event_prefix_files_exist` | PASS | 20/20 prefixes backed by .ogg; missing none (of 325 files) |
| `audio_names_for_resolves_events` | PASS | names_for() unresolved: none |
| `walk_sound_prefixes_resolve` | PASS | unresolved walk sids: none |
| `chop_event_maps_to_sound` | PASS | main.gd chop → `["workwood"]`, resolves to workwood1..9 |
| `nation_theme_files_or_fallback` | PASS | 21 nations, 21 themed, fallback=true; missing [] |

No full selftest was run, per instructions.

## Open questions

1. Donor `amb_wind` uses `SetSndAmbientThreadRanges(-5, 100)` but has no object position, so its exact range semantics cannot be reproduced from text; wired as a continuous bed at donor `0.2` linear volume (R10 rank-2 action agrees).
2. The port has no frustum query, so the sea bed uses a camera-centred ±60 m water grid stand-in instead of the donor's frustum-bounded `RayCastWater` scan; numeric constants (4 m step, `/200`, 20–60 m ramp, 0.5 base, delta clamps) are donor-exact.
3. `game._is_water()` is a private helper on `game.gd`; W27 only reads it, never edits/writes it. If a future refactor removes it, the sea bed silently falls back to silence (safe failure).
4. Headless CI has no audible output; `t_audio_events.gd` checks file/prefix mapping, not bed audibility — verification here is static + "no regression", not a listening test.
5. Donor `time.cfg`/`env.cfg` carry no ambient-bed identifiers; they were checked to close the enumeration, not to add a day/night cycle (R10 says that manager is disabled).
