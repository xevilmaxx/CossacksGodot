# World rendering: terrain, resources, units, buildings, fog, effects.
# Terrain uses the original grass/dirt/rock PNGs (app/assets/terrain, copied
# from data/terrain/tiles/textures/*.dds) at full detail: each map tile shows
# a random crop of the real texture, so fields look like the original instead
# of flat blocks. Buildings are drawn as top-down RTS shapes with a dirt
# ground-decal (like data/terrain/decals/buildings/*.dds), walls, roofs and
# player trim - not UI icons. Trees/rocks/corn are clustered props in the
# original palette roles.
extends Node2D
class_name C3World

const Data = preload("res://scripts/data.gd")

var game: C3Game
var hud: CanvasLayer
var view_scale := 16.0  # screen px per meter
var terrain_sprite: Sprite2D
var fog_sprite: Sprite2D
var fog_img: Image
var fog_tex: ImageTexture
var fog_explored: PackedByteArray = PackedByteArray()
var fog_timer := 0.0
var unit_layer: Node2D
var bld_layer: Node2D
var res_layer: Node2D
var fx_layer: Node2D
var variants: Array = []  # per terrain type: Array of Image (16x16)
var fx_items: Array = []  # transient visual effects
var view_rect := Rect2(0, 0, 1, 1)
var sel_rect := Rect2(0, 0, 0, 0)
var sel_active := false
var anim_t := 0.0  # ambient animation clock (flags, water, idle bob)
# Original-model sprites (assets/models/sprites, rendered from the game's own
# .obj + .png by tools/render_models.py). Missing entries fall back to the
# procedural shapes below, so the game never draws blank.
var sprites: Dictionary = {}
# Animated original-model sheets (tools/bake_sprites.py): key -> {cell, actions}.
var anim_index := {}
var anim_tex := {}
const SPRITE_ALIAS := {"musk18": "serdiuk", "grenadier": "roundshier",
	"officer18": "officer", "drummer": "officer", "priest": "officer",
	"howitzer": "cannon", "mortar": "cannon"}
const SPRITE_TINT := {"priest": Color(0.25, 0.25, 0.3), "drummer": Color(1, 1, 1)}

func bind(g: C3Game, h: CanvasLayer = null) -> void:
	game = g
	hud = h
	view_scale = Data.PIXELS_PER_METER
	_build_terrain()
	res_layer = Node2D.new()
	res_layer.z_index = 1
	add_child(res_layer)
	bld_layer = Node2D.new()
	bld_layer.z_index = 2
	add_child(bld_layer)
	unit_layer = Node2D.new()
	unit_layer.z_index = 3
	add_child(unit_layer)
	fx_layer = Node2D.new()
	fx_layer.z_index = 4
	add_child(fx_layer)
	res_layer.draw.connect(_draw_resources)
	bld_layer.draw.connect(_draw_buildings)
	unit_layer.draw.connect(_draw_units)
	fx_layer.draw.connect(_draw_fx)
	_load_sprites()
	var j := FileAccess.get_file_as_string("res://assets/models/anim/index.json")
	if j != "":
		var parsed = JSON.parse_string(j)
		if parsed is Dictionary:
			anim_index = parsed
	fog_explored.resize(game.MAP_W * game.MAP_H)
	fog_img = Image.create(game.MAP_W, game.MAP_H, false, Image.FORMAT_RGBA8)
	fog_img.fill(Color(0, 0, 0, 0.78))
	fog_tex = ImageTexture.create_from_image(fog_img)
	fog_sprite = Sprite2D.new()
	fog_sprite.texture = fog_tex
	fog_sprite.centered = false
	fog_sprite.scale = Vector2(game.MAP_W * Data.TILE_M * view_scale / game.MAP_W, game.MAP_H * Data.TILE_M * view_scale / game.MAP_H)
	fog_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	fog_sprite.visible = Data.FOG_OF_WAR
	fog_sprite.z_index = 10
	add_child(fog_sprite)
	_update_fog()

func world_to_px(p: Vector2) -> Vector2:
	return p * view_scale

# Sprites rendered from the original models (see _load_sprites). Units face
# the camera of their movement direction; buildings/props use one view.
func _load_sprites() -> void:
	sprites.clear()
	var sids: Array = []
	for sid in Data.UNITS:
		sids.append(SPRITE_ALIAS.get(sid, sid))
	for sid in Data.BUILDINGS:
		if sid != "wal" and not sids.has(sid):
			sids.append(sid)
	for n in ["tree_fir", "tree_oak", "tree_pine", "rock", "stone", "field"]:
		if not sids.has(n):
			sids.append(n)
	# NOTE: ResourceLoader.exists misses never-imported PNGs on this setup,
	# so probe with FileAccess (the editor import cache does not know them).
	for key in sids:
		var frames: Array = []
		var has_dir := false
		for d in 8:
			var p := "res://assets/models/sprites/%s_%03d.png" % [key, d * 45]
			if FileAccess.file_exists(p):
				has_dir = true
				frames.append(load(p) as Texture2D)
			else:
				frames.append(null)
		if has_dir:
			sprites[key] = frames
		elif FileAccess.file_exists("res://assets/models/sprites/%s.png" % key):
			sprites[key] = [load("res://assets/models/sprites/%s.png" % key) as Texture2D]
	print("sprites: %d sets loaded (sids=%d)" % [sprites.size(), sids.size()])

func _unit_height(e: Dictionary) -> float:
	if e.def.get("artillery", false):
		return 1.5
	if e.def.get("cavalry", "") != "":
		return 2.3
	return 1.9

func _sprite_frames(sid: String) -> Array:
	# a baked animated sheet replaces the old static-sprite alias
	if anim_index.has(sid):
		return sprites.get(sid, [])
	return sprites.get(SPRITE_ALIAS.get(sid, sid), [])

func _sprite_for(sid: String, face: float) -> Texture2D:
	var frames: Array = _sprite_frames(sid)
	if frames.is_empty():
		return null
	if frames.size() == 1:
		return frames[0]
	# camera azimuths run 0..315 every 45 deg; pick the view facing the unit
	var idx := int(fposmod(roundf(face / (PI / 4.0)), 8.0)) % 8
	return frames[idx]

func _anim_key(sid: String, player: int) -> String:
	# nation-peasant visuals resolve first (ukr_peasant etc.), then the sid
	var nat := ""
	if player >= 0 and player < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[player])
	if nat != "":
		var nk := "%s_%s" % [nat, sid]
		if anim_index.has(nk):
			return nk
	return sid

func _anim_action(e: Dictionary) -> String:
	if float(e.get("death_t", -1.0)) >= 0.0:
		return "death"
	var o: Dictionary = e.order
	var gt: float = game.time_s
	if o.type == "attack" and float(e.get("fire_t", -1.0)) >= 0.0 and gt - float(e.fire_t) < 0.9:
		return "attack"
	if (o.type == "gather" or o.type == "build") and not bool(e.get("moving", false)):
		return "attack"
	if bool(e.get("moving", false)):
		return "walk"
	return "idle"

func _draw_anim(e: Dictionary, p: Vector2, tint: Color) -> bool:
	var key := _anim_key(e.sid, int(e.player))
	var info: Dictionary = anim_index.get(key, {})
	if info.is_empty():
		return false
	var act := _anim_action(e)
	var a: Dictionary = info.actions.get(act, info.actions.get("idle", {}))
	if a.is_empty():
		return false
	var tk := key + "_" + act
	if not anim_tex.has(tk):
		var path := "res://assets/models/anim/%s.png" % tk
		if not FileAccess.file_exists(path):
			return false
		anim_tex[tk] = load(path)
	var tex: Texture2D = anim_tex[tk]
	if tex == null:
		anim_tex.erase(tk)
		return false
	var cell: int = int(info.cell)
	var n: int = int(a.frames)
	var gt: float = game.time_s
	var t0: float = float(e.get("death_t", -1.0)) if act == "death" else (float(e.get("fire_t", -1.0)) if act == "attack" and e.order.type == "attack" else -1.0)
	var fi: int
	if t0 >= 0.0:
		fi = mini(n - 1, int((gt - t0) / maxf(0.05, float(a.duration)) * n))
	else:
		fi = int(anim_t / maxf(0.05, float(a.duration)) * n) % n
	var dir := int(fposmod(roundf(float(e.get("face", 0.0)) / (PI / 4.0)), 8.0)) % 8
	var src := Rect2(dir * cell, fi * cell, cell, cell)
	var world_h := _unit_height(e)
	var sc: float = world_h * view_scale / float(cell)
	var sz := Vector2(cell, cell) * sc
	var tl := p - Vector2(sz.x * 0.5, sz.y * 0.82)
	unit_layer.draw_texture_rect_region(tex, Rect2(tl, sz), src, tint)
	return true

func _bld_key(e: Dictionary) -> String:
	# nation sheet (assets/models/anim, lazy) wins, else the shared static one
	var nat := ""
	if int(e.player) >= 0 and int(e.player) < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[int(e.player)])
	if nat != "":
		var nk := "%s_%s" % [nat, e.sid]
		if FileAccess.file_exists("res://assets/models/anim/%s.png" % nk):
			return nk
	return e.sid

func _bld_anim(key: String) -> Texture2D:
	# lazy nation-sheet loading (like unit anims): only drawn buildings cost
	if anim_tex.has(key):
		var t: Texture2D = anim_tex[key]
		if t == null:
			anim_tex.erase(key)
			return null
		return t
	var path := "res://assets/models/anim/%s.png" % key
	if not FileAccess.file_exists(path):
		return null
	anim_tex[key] = load(path)
	var t2: Texture2D = anim_tex[key]
	if t2 == null:
		anim_tex.erase(key)
		return null
	return t2

func _bld_tex(e: Dictionary) -> Texture2D:
	var bk := _bld_key(e)
	if not e.finished:
		# construction stages baked by tools/bake_sprites.py --buildings
		var si := clampi(int(float(e.progress) / maxf(1.0, float(e.def.build_time)) * 4.0), 0, 3) + 1
		var st := _bld_anim("%s_s%d" % [bk, si])
		if st != null:
			return st
	var s0 := _sprite_for(bk, -1)
	if s0 != null:
		return s0
	return _bld_anim(bk)

func _draw_sprite(layer: Node2D, tex: Texture2D, p: Vector2, world_h: float, tint := Color(1, 1, 1), shadow := true) -> void:
	# world_h: how tall the figure should stand, in meters
	var px_h: float = world_h * view_scale
	var sc: float = px_h / maxf(1.0, float(tex.get_height()))
	var sz := Vector2(float(tex.get_width()), float(tex.get_height())) * sc
	var top_left := p - Vector2(sz.x * 0.5, sz.y * 0.82)
	if shadow:
		layer.draw_circle(p + Vector2(1.5, 2.5), sz.x * 0.32, Color(0, 0, 0, 0.28))
	layer.draw_texture(tex, top_left, tint)

func _src(path: String) -> Image:
	var tex: Texture2D = load(path)
	if tex == null:
		return null
	var im: Image = tex.get_image()
	if im == null:
		return null
	if im.get_format() != Image.FORMAT_RGB8:
		im.convert(Image.FORMAT_RGB8)
	return im

func _crop_variant(base: Image, rng_seed: int) -> Image:
	# random 64x64 crop of the real texture -> 16x16 tile, with gentle shade
	# variation (kept tight so neighbouring tiles do not checker like before)
	var r := RandomNumberGenerator.new()
	r.seed = rng_seed
	var bw := base.get_width()
	var bh := base.get_height()
	var cs := mini(96, mini(bw, bh) - 4)
	var ox := r.randi() % maxi(1, bw - cs)
	var oy := r.randi() % maxi(1, bh - cs)
	var im := base.get_region(Rect2i(ox, oy, cs, cs))
	im.resize(8, 8, Image.INTERPOLATE_BILINEAR)
	var shade := 0.99 + 0.02 * r.randf()
	im.adjust_bcs(shade, 1.0, 1.0)
	return im

func _tint(im: Image, mul: Color) -> Image:
	var c := im.duplicate() as Image
	for y in c.get_height():
		for x in c.get_width():
			var p := c.get_pixel(x, y)
			c.set_pixel(x, y, Color(p.r * mul.r, p.g * mul.g, p.b * mul.b))
	return c

func _build_terrain() -> void:
	var grass_imgs: Array = []
	for i in 5:
		var im := _src("res://assets/terrain/grass%d.png" % (i + 1))
		if im != null:
			grass_imgs.append(im)
	var dirt := _src("res://assets/terrain/dirt1.png")
	var rockg := _src("res://assets/terrain/rockgrass1.png")
	if grass_imgs.is_empty():
		var flat := Image.create(64, 64, false, Image.FORMAT_RGB8)
		flat.fill(Color(0.32, 0.45, 0.2))
		grass_imgs.append(flat)
	if dirt == null:
		dirt = grass_imgs[0]
	if rockg == null:
		rockg = grass_imgs[0]
	variants = [[], [], [], [], [], []]
	# few near-identical variants per type so neighbours do not checker;
	# the large soft patches already come from the terrain-type map itself
	var grass0 := _src("res://assets/terrain/grass1.png")
	if grass0 == null:
		grass0 = grass_imgs[0]
	for v in 4:
		variants[0].append(_crop_variant(grass0, 1000 + v * 77))
		var dirt_warm := _tint(_crop_variant(dirt, 2000 + v * 77), Color(1.06, 0.94, 0.80))
		variants[1].append(dirt_warm)
		var dark := _crop_variant(grass0, 3000 + v * 77)
		dark.adjust_bcs(0.96, 1.0, 1.01)
		variants[2].append(dark)
		# sand: dirt warmed up
		var sand := _crop_variant(dirt, 4000 + v * 77)
		variants[4].append(_tint(sand, Color(1.18, 1.08, 0.78)))
		# rock: rockgrass cooled/greyed
		var rk := _crop_variant(rockg, 5000 + v * 77)
		variants[5].append(_tint(rk, Color(1.02, 1.0, 0.96)))
	# pad to 8 slots (index % 8 is used below; water is filled next)
	for t in 6:
		if t == 3:
			continue
		while variants[t].size() < 8:
			variants[t].append(variants[t][variants[t].size() % 4])
	# water variants: painted blue with slight noise (no texture in original tiles)
	for v in 8:
		var w := Image.create(8, 8, false, Image.FORMAT_RGB8)
		var base := Color(0.16 + 0.02 * (v % 3), 0.34 + 0.02 * ((v + 1) % 3), 0.55)
		w.fill(base)
		# sparkle dots
		for k in 6:
			var px := (v * 5 + k * 3) % 8
			var py := (v * 3 + k * 7) % 8
			w.set_pixel(px, py, base.lightened(0.18))
		variants[3].append(w)
	# height shading: dark/normal/bright copies so hills read on the map
	# (wiki: elevation matters). 144 tiny images, picked per tile below.
	var hlv: Array = [[], [], []]
	for lvl in 3:
		for t in 6:
			var arr: Array = []
			for vi in 8:
				var c := (variants[t][vi] as Image).duplicate() as Image
				var f := 0.85 if lvl == 0 else (1.12 if lvl == 2 else 1.0)
				for py in c.get_height():
					for px in c.get_width():
						var col: Color = c.get_pixel(px, py)
						c.set_pixel(px, py, Color(minf(1.0, col.r * f), minf(1.0, col.g * f), minf(1.0, col.b * f)))
				arr.append(c)
			hlv[lvl].append(arr)
	var px_per_tile := 8
	var img := Image.create(game.MAP_W * px_per_tile, game.MAP_H * px_per_tile, false, Image.FORMAT_RGB8)
	for y in game.MAP_H:
		for x in game.MAP_W:
			var t: int = game.terrain[y * game.MAP_W + x]
			if t < 0 or t > 5:
				t = 0
			# variant picked by soft noise only (no per-tile hash), so
			# neighbours share variants and the field reads as one meadow
			var m: float = _wnoise(float(x) * 0.13, float(y) * 0.13)
			var vi: int = absi(int(m * 5.0) + (x / 4) + (y / 4)) % 8
			var hh: float = game.height_at(Vector2((float(x) + 0.5) * Data.TILE_M, (float(y) + 0.5) * Data.TILE_M))
			var lvl := 0 if hh < -0.6 else (2 if hh > 0.6 else 1)
			var sim: Image = (hlv[lvl] as Array)[t][vi]
			img.blit_rect(sim, Rect2i(0, 0, px_per_tile, px_per_tile), Vector2i(x * px_per_tile, y * px_per_tile))
	var tex := ImageTexture.create_from_image(img)
	terrain_sprite = Sprite2D.new()
	terrain_sprite.texture = tex
	terrain_sprite.centered = false
	terrain_sprite.scale = Vector2(game.MAP_W * Data.TILE_M * view_scale / img.get_width(), game.MAP_H * Data.TILE_M * view_scale / img.get_height())
	terrain_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	terrain_sprite.z_index = -10
	add_child(terrain_sprite)

func sync(dt: float) -> void:
	# visible WORLD rect (not screen pixels): cull in the same space the
	# entities are drawn in, otherwise big maps hide everything
	view_rect = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
	anim_t += dt
	fog_timer -= dt
	if fog_timer <= 0.0:
		fog_timer = 0.5
		_update_fog()
	bld_layer.queue_redraw()
	res_layer.queue_redraw()
	unit_layer.queue_redraw()
	fx_layer.queue_redraw()
	for f in fx_items:
		f.t += dt
	fx_items = fx_items.filter(func(f): return f.t < f.life)

func _player_color(p: int) -> Color:
	return [Color(0.25, 0.5, 1.0), Color(1.0, 0.3, 0.25)][p]

func _update_fog() -> void:
	if game == null:
		return
	if not Data.FOG_OF_WAR:
		return
	for rq in game.reveal_requests:
		var c: Vector2 = rq.pos
		var rr: float = rq.r
		for ty in game.MAP_H:
			for tx in game.MAP_W:
				if Vector2(tx * 2 + 1, ty * 2 + 1).distance_to(c) <= rr:
					fog_explored[ty * game.MAP_W + tx] = 1
	game.reveal_requests.clear()
	var vis := {}
	for e in game.entities:
		if e.dead or e.player != 0:
			continue
		var r: float = e.def.get("search", 24.0) if e.kind == "unit" else e.def.get("radius", 2.0) * 6.0
		var t0 := game.tile_of(e.pos - Vector2(r, r))
		var t1 := game.tile_of(e.pos + Vector2(r, r))
		for y in range(maxi(0, t0.y), mini(game.MAP_H, t1.y + 1)):
			for x in range(maxi(0, t0.x), mini(game.MAP_W, t1.x + 1)):
				var c := Vector2((x + 0.5) * Data.TILE_M, (y + 0.5) * Data.TILE_M)
				if c.distance_to(e.pos) <= r:
					vis[y * game.MAP_W + x] = true
	for y in game.MAP_H:
		for x in game.MAP_W:
			var i := y * game.MAP_W + x
			if vis.has(i):
				fog_explored[i] = 1
				fog_img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif fog_explored[i] == 1:
				fog_img.set_pixel(x, y, Color(0, 0, 0, 0.30))
			else:
				fog_img.set_pixel(x, y, Color(0, 0, 0, 0.78))
	fog_tex.update(fog_img)

# deterministic hash for prop variation
func _hash(x: float, y: float) -> float:
	var s := int(x * 12.9898 + y * 78.233) & 0x7fffffff
	s = (s ^ (s >> 13)) * 1274126177
	s = s ^ (s >> 16)
	return float(s & 1023) / 1023.0

func _wnoise(x: float, y: float) -> float:
	var xi := int(floor(x))
	var yi := int(floor(y))
	var xf: float = x - floor(x)
	var yf: float = y - floor(y)
	var h := func(ix: int, iy: int) -> float:
		var s := ix * 374761393 + iy * 668265263
		s = (s ^ (s >> 13)) * 1274126177
		s = s ^ (s >> 16)
		return float(s & 65535) / 65535.0 * 2.0 - 1.0
	var a: float = h.call(xi, yi)
	var b: float = h.call(xi + 1, yi)
	var c: float = h.call(xi, yi + 1)
	var d: float = h.call(xi + 1, yi + 1)
	var u: float = xf * xf * (3.0 - 2.0 * xf)
	var v: float = yf * yf * (3.0 - 2.0 * yf)
	return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v

func _prop_tex(names: Array, seed_pos: Vector2) -> Texture2D:
	# stable variant per spot (pine/oak/fir), like the original forest mix
	var h := _hash(seed_pos.x, seed_pos.y)
	var pick: String = names[int(h * float(names.size())) % names.size()]
	var frames: Array = sprites.get(pick, [])
	if frames.is_empty():
		return null
	return frames[0]

func _draw_resources() -> void:
	for n in game.res_nodes:
		if n.hits <= 0:
			continue
		var p := world_to_px(n.pos)
		if not view_rect.grow(64).has_point(p):
			continue
		var h := _hash(n.pos.x, n.pos.y)
		match n.type:
			"wood":
				var tree := _prop_tex(["tree_fir", "tree_oak", "tree_pine"], n.pos)
				if tree != null:
					_draw_sprite(res_layer, tree, p, 3.6 + h * 1.6)
					continue
				# fallback below (no sprites): tall pines + broad oaks
				var pine := h > 0.42
				var tall := 30.0 + h * 12.0
				res_layer.draw_circle(p + Vector2(2, 3), 8.0, Color(0, 0, 0, 0.25))
				res_layer.draw_rect(Rect2(p.x - 1.6, p.y - 6, 3.2, 10), Color(0.3, 0.2, 0.11))
				res_layer.draw_rect(Rect2(p.x - 1.6, p.y - 6, 1.2, 10), Color(0.42, 0.3, 0.16))
				if pine:
					var c := Color(0.12 + h * 0.05, 0.32 + h * 0.05, 0.13)
					res_layer.draw_colored_polygon([p + Vector2(0, -tall), p + Vector2(-9, -tall * 0.45), p + Vector2(9, -tall * 0.45)], c.darkened(0.12))
					res_layer.draw_colored_polygon([p + Vector2(0, -tall * 0.78), p + Vector2(-7.5, -tall * 0.3), p + Vector2(7.5, -tall * 0.3)], c)
					res_layer.draw_colored_polygon([p + Vector2(0, -tall * 0.55), p + Vector2(-6, -8), p + Vector2(6, -8)], c.lightened(0.12))
					res_layer.draw_line(p + Vector2(-3, -tall * 0.6), p + Vector2(0, -tall + 2), c.lightened(0.3), 1.2)
				else:
					var c := Color(0.15 + h * 0.07, 0.38 + h * 0.05, 0.15)
					res_layer.draw_circle(p + Vector2(0, -tall * 0.45), 10.0, c.darkened(0.3))
					res_layer.draw_circle(p + Vector2(-4, -tall * 0.55), 7.5, c)
					res_layer.draw_circle(p + Vector2(3, -tall * 0.6), 5.5, c.lightened(0.16))
					res_layer.draw_circle(p + Vector2(-1, -tall * 0.62), 2.5, c.lightened(0.3))
			"stone":
				var rock := _prop_tex(["rock", "stone"], n.pos)
				if rock != null:
					_draw_sprite(res_layer, rock, p, 1.6 + h * 0.8)
					continue
				res_layer.draw_circle(p + Vector2(0, 2), 7.0, Color(0, 0, 0, 0.2))
				res_layer.draw_circle(p, 5.5, Color(0.5, 0.5, 0.49))
				res_layer.draw_circle(p + Vector2(-2.5, -2.5), 3.2, Color(0.68, 0.68, 0.66))
				res_layer.draw_circle(p + Vector2(3, 1), 2.4, Color(0.6, 0.6, 0.58))
				res_layer.draw_circle(p + Vector2(0.5, -1), 1.2, Color(0.8, 0.8, 0.78))
			"food":
				var field := _prop_tex(["field"], n.pos)
				if field != null:
					_draw_sprite(res_layer, field, p, 1.8, Color(1, 1, 1), false)
					continue
				# corn field tuft: golden stalks with green base
				res_layer.draw_circle(p + Vector2(0, 2), 5.0, Color(0, 0, 0, 0.15))
				for k in 5:
					var a := h * 6.28 + k * 1.256
					var tip := p + Vector2(cos(a), sin(a)) * (3.0 + h * 2.0) + Vector2(0, -6 - h * 3.0)
					res_layer.draw_line(p + Vector2(0, 2), tip, Color(0.35, 0.42, 0.18), 1.5)
					res_layer.draw_circle(tip, 2.2, Color(0.85 + h * 0.08, 0.72, 0.25))
			"gold", "iron", "coal":
				var col: Color = {"gold": Color(0.9, 0.75, 0.2), "iron": Color(0.7, 0.45, 0.3), "coal": Color(0.28, 0.28, 0.3)}[n.type]
				var outcrop := _prop_tex(["rock"], n.pos)
				if outcrop != null:
					_draw_sprite(res_layer, outcrop, p, 2.2)
					res_layer.draw_circle(p + Vector2(2, -4), 3.0, col)
					res_layer.draw_circle(p + Vector2(-1, 1), 2.0, col.lightened(0.2))
					continue
				# rock outcrop with ore veins (like original mine rocks)
				res_layer.draw_circle(p + Vector2(0, 2), 8.0, Color(0, 0, 0, 0.22))
				res_layer.draw_circle(p, 7.0, Color(0.45, 0.43, 0.4))
				res_layer.draw_circle(p + Vector2(-3, -3), 4.0, Color(0.58, 0.56, 0.52))
				res_layer.draw_circle(p + Vector2(2, -4), 3.0, col)
				res_layer.draw_circle(p + Vector2(-1, 1), 2.0, col.lightened(0.2))

func _draw_buildings() -> void:
	for e in game.entities:
		if e.dead or e.kind != "building":
			continue
		var p := world_to_px(e.pos)
		if not view_rect.grow(96).has_point(p):
			continue
		var col := _player_color(e.player)
		var r: float = e.def.radius * view_scale
		var w := r * 2.0
		var hgt := r * 1.7
		if e.sid == "tow":
			hgt = r * 2.6
		elif e.sid == "aca" or e.sid == "cen":
			hgt = r * 2.0
		elif e.sid == "hou" or e.sid == "sto":
			hgt = r * 1.3
		if e.sid.begins_with("mine_"):
			_draw_mine(p, e, col)
		elif e.sid == "wal" or e.sid == "gat":
			_draw_wall(p, e)
		elif _bld_tex(e) != null:
			# original-model sprite (static or nation sheet); the selection
			# ring, damage smoke and capture flag below still draw on top
			var bspr := _bld_tex(e)
			var tint_b := Color(0.55, 0.55, 0.6) if not e.finished else Color(1, 1, 1)
			bld_layer.draw_circle(p + Vector2(0, 4), r * 1.5, Color(0, 0, 0, 0.22))
			_draw_sprite(bld_layer, bspr, p, _bld_height(e), tint_b)
			var bw := r * 2.0
			if not e.finished:
				var k: float = clampf(e.progress / maxf(1.0, e.def.build_time), 0.0, 1.0)
				bld_layer.draw_rect(Rect2(p.x - bw / 2, p.y + 6, bw * k, 5), Color(0.3, 0.8, 0.3))
				bld_layer.draw_rect(Rect2(p.x - bw / 2, p.y + 6, bw, 5), Color(0, 0, 0, 0.5), false, 1.0)
			elif e.hp < e.max_hp:
				var k2: float = clampf(float(e.hp) / e.max_hp, 0.0, 1.0)
				bld_layer.draw_rect(Rect2(p.x - bw / 2, p.y - 14, bw, 5), Color(0, 0, 0, 0.6))
				bld_layer.draw_rect(Rect2(p.x - bw / 2, p.y - 14, bw * k2, 5), Color(0.2, 0.9, 0.2))
		else:
			var hh := _hash(e.pos.x, e.pos.y)
			var dw := w * (0.72 + hh * 0.08)
			bld_layer.draw_circle(p + Vector2(0, hgt * 0.36), dw * 0.62, Color(0.30, 0.23, 0.14, 0.55))
			bld_layer.draw_circle(p + Vector2(0, hgt * 0.34), dw * 0.55, Color(0.42, 0.33, 0.20, 0.95))
			bld_layer.draw_circle(p + Vector2(-dw * 0.1, hgt * 0.30), dw * 0.38, Color(0.49, 0.40, 0.25, 0.95))
			bld_layer.draw_circle(p + Vector2(dw * 0.28, hgt * 0.22), dw * 0.5, Color(0, 0, 0, 0.16))
			var wall := Color(0.84, 0.78, 0.64)
			var trim := Color(0.55, 0.48, 0.38)
			if e.sid == "bar" or e.sid == "sta" or e.sid == "art":
				wall = Color(0.68, 0.57, 0.43)
				trim = Color(0.40, 0.33, 0.24)
			elif e.sid == "tow" or e.sid == "aca":
				wall = Color(0.62, 0.61, 0.59)
				trim = Color(0.38, 0.38, 0.40)
			elif e.sid == "mil" or e.sid == "hou" or e.sid == "sto":
				wall = Color(0.80, 0.70, 0.53)
			if not e.finished:
				wall = wall.darkened(0.28)
			var wall_top := p.y - hgt * 0.28
			var wall_bot := p.y + hgt * 0.5
			var wall_h := wall_bot - wall_top
			bld_layer.draw_rect(Rect2(p.x - w / 2 - 1, wall_top + 3, w + 2, wall_h - 2), Color(0.25, 0.20, 0.14))
			bld_layer.draw_rect(Rect2(p.x - w / 2, wall_top, w, wall_h), wall.darkened(0.18))
			bld_layer.draw_rect(Rect2(p.x - w / 2, wall_top, w * 0.72, wall_h), wall)
			bld_layer.draw_rect(Rect2(p.x - w / 2, wall_bot - 4, w, 3), Color(0.32, 0.26, 0.18))
			bld_layer.draw_line(Vector2(p.x - w / 2, wall_top), Vector2(p.x - w / 2, wall_bot), trim, 1.5)
			bld_layer.draw_line(Vector2(p.x + w / 2, wall_top), Vector2(p.x + w / 2, wall_bot), trim, 1.5)
			var rows := maxi(2, int(wall_h / 8.0))
			for ri in range(1, rows):
				var yy := wall_top + wall_h * float(ri) / float(rows)
				bld_layer.draw_line(Vector2(p.x - w / 2 + 1, yy), Vector2(p.x + w / 2 - 1, yy), trim.lightened(0.25), 1.0)
			if e.sid == "bar" or e.sid == "sta" or e.sid == "hou" or e.sid == "sto" or e.sid == "cen" or e.sid == "mil":
				bld_layer.draw_line(Vector2(p.x - w / 2, wall_top + 3), Vector2(p.x + w / 2, wall_top + 3), Color(0.32, 0.22, 0.13), 2.5)
				bld_layer.draw_line(Vector2(p.x - w / 2, wall_bot - 5), Vector2(p.x + w / 2, wall_bot - 5), Color(0.32, 0.22, 0.13), 2.0)
			var roof := Color(0.62, 0.26, 0.15)
			if e.sid == "bar" or e.sid == "aca" or e.sid == "art" or e.sid == "tow":
				roof = Color(0.42, 0.44, 0.48)
			elif e.sid == "hou" or e.sid == "sto" or e.sid == "mil" or e.sid == "mar":
				roof = Color(0.66, 0.42, 0.20)
			if not e.finished:
				roof = roof.darkened(0.3)
			var apex := Vector2(p.x, wall_top - hgt * 0.42 - 6.0)
			var eave_l := Vector2(p.x - w / 2 - 5, wall_top + 1)
			var eave_r := Vector2(p.x + w / 2 + 5, wall_top + 1)
			bld_layer.draw_colored_polygon([eave_l + Vector2(0, 2), apex + Vector2(0, 2), eave_r + Vector2(0, 2)], roof.darkened(0.45))
			bld_layer.draw_colored_polygon([eave_l, apex, eave_r], roof)
			bld_layer.draw_colored_polygon([Vector2(p.x, wall_top + 1), apex, eave_r], roof.lightened(0.12))
			bld_layer.draw_line(eave_l, apex, roof.darkened(0.4), 1.5)
			bld_layer.draw_line(apex, eave_r, roof.darkened(0.25), 1.5)
			bld_layer.draw_line(apex + Vector2(0, 1), Vector2(p.x, wall_top + 1), roof.lightened(0.30), 1.2)
			# sun highlight along the left wall edge (AAA top-light)
			bld_layer.draw_line(Vector2(p.x - w / 2 + 1, wall_top + 2), Vector2(p.x - w / 2 + 1, wall_bot - 6), Color(1, 1, 1, 0.22), 2.0)
			for ti in 2:
				var tt := 0.35 + 0.3 * float(ti)
				var ly := eave_l.lerp(apex, tt)
				var ry := eave_r.lerp(apex, tt)
				bld_layer.draw_line(ly, ry, roof.darkened(0.3), 1.0)
			# waving banner on hall, barracks and towers (player colour)
			if (e.sid == "cen" or e.sid == "bar" or e.sid == "tow") and e.finished:
				var wave := sin(anim_t * 4.0 + p.x * 0.2) * 2.5
				var pole_top := apex + Vector2(0, -2)
				bld_layer.draw_line(pole_top, pole_top + Vector2(0, -16), Color(0.25, 0.20, 0.14), 2.0)
				var flag := [pole_top + Vector2(0, -16), pole_top + Vector2(14 + wave, -13), pole_top + Vector2(0, -10)]
				bld_layer.draw_colored_polygon(flag, col)
				bld_layer.draw_colored_polygon([flag[0], flag[1], flag[1] + Vector2(0, 1.5)], col.lightened(0.25))
			if e.sid == "tow":
				for k in 4:
					var bx := p.x - w / 2 + k * (w / 3.0)
					bld_layer.draw_rect(Rect2(bx, wall_top - 12, w / 6.0, 8), wall.darkened(0.05))
					bld_layer.draw_rect(Rect2(bx, wall_top - 12, w / 6.0, 8), trim, false, 1.0)
				bld_layer.draw_circle(p + Vector2(0, wall_top + wall_h * 0.45), 3.5, Color(0.08, 0.08, 0.08))
				bld_layer.draw_circle(p + Vector2(0, wall_top + wall_h * 0.45), 3.5, Color(0.5, 0.5, 0.55), false, 1.0)
			elif e.sid == "cen":
				bld_layer.draw_circle(p + Vector2(0, wall_top + wall_h * 0.42), 6.0, Color(0.94, 0.92, 0.84))
				bld_layer.draw_circle(p + Vector2(0, wall_top + wall_h * 0.42), 6.0, Color(0.2, 0.2, 0.2), false, 1.2)
				bld_layer.draw_rect(Rect2(p.x - 5, wall_bot - 14, 10, 14), Color(0.22, 0.16, 0.11))
				bld_layer.draw_rect(Rect2(p.x - 5, wall_bot - 14, 10, 14), Color(0.45, 0.34, 0.2), false, 1.0)
			elif e.sid == "mil":
				var cx := p + Vector2(w / 2 + 6, wall_top - 4)
				bld_layer.draw_circle(cx, 2.5, Color(0.3, 0.22, 0.13))
				for b in 4:
					var a := PI / 4.0 + b * PI / 2.0 + hgt * 0.01
					bld_layer.draw_line(cx, cx + Vector2(cos(a), sin(a)) * 14.0, Color(0.75, 0.70, 0.60), 2.0)
				bld_layer.draw_rect(Rect2(p.x - 4, wall_bot - 12, 8, 12), Color(0.23, 0.16, 0.11))
			else:
				bld_layer.draw_rect(Rect2(p.x - 4, wall_bot - 12, 8, 12), Color(0.23, 0.16, 0.11))
				bld_layer.draw_rect(Rect2(p.x - 4, wall_bot - 12, 8, 12), Color(0.5, 0.4, 0.25), false, 1.0)
				bld_layer.draw_rect(Rect2(p.x - w / 4 - 4, wall_top + 7, 8, 8), Color(0.13, 0.18, 0.30))
				bld_layer.draw_rect(Rect2(p.x + w / 4 - 4, wall_top + 7, 8, 8), Color(0.13, 0.18, 0.30))
				bld_layer.draw_rect(Rect2(p.x - w / 4 - 4, wall_top + 7, 8, 8), Color(0.72, 0.70, 0.62), false, 1.0)
				bld_layer.draw_rect(Rect2(p.x + w / 4 - 4, wall_top + 7, 8, 8), Color(0.72, 0.70, 0.62), false, 1.0)
			bld_layer.draw_rect(Rect2(p.x - w / 2, wall_bot - 4, w, 3), col, true)
			if not e.finished:
				bld_layer.draw_rect(Rect2(p.x - w / 2 - 6, apex.y - 5, w + 12, wall_bot - apex.y + 13), Color(0.4, 0.28, 0.15, 0.85), false, 1.5)
				bld_layer.draw_line(Vector2(p.x - w / 2 - 6, apex.y + 9), Vector2(p.x + w / 2 + 6, apex.y + 9), Color(0.45, 0.32, 0.18, 0.9), 1.5)
				var k: float = clampf(e.progress / e.def.build_time, 0.0, 1.0)
				bld_layer.draw_rect(Rect2(p.x - w / 2, wall_bot + 7, w * k, 5), Color(0.3, 0.8, 0.3))
				bld_layer.draw_rect(Rect2(p.x - w / 2, wall_bot + 7, w, 5), Color(0, 0, 0, 0.5), false, 1.0)
			else:
				if e.hp < e.max_hp:
					var k2: float = clampf(float(e.hp) / e.max_hp, 0.0, 1.0)
					bld_layer.draw_rect(Rect2(p.x - w / 2, apex.y - 10, w, 5), Color(0, 0, 0, 0.6))
					bld_layer.draw_rect(Rect2(p.x - w / 2, apex.y - 10, w * k2, 5), Color(0.2, 0.9, 0.2))
		if e.get("selected", false):
			var rr: float = e.def.radius * view_scale + 9.0
			bld_layer.draw_arc(p, rr, 0, TAU, 32, Color(0.15, 0.12, 0.08, 0.7), 3.0)
			bld_layer.draw_arc(p, rr, 0, TAU, 32, Color(1, 1, 1, 0.95), 1.5)
			for k in 4:
				var a := k * PI / 2.0 + PI / 4.0
				var q := p + Vector2(cos(a), sin(a)) * rr
				bld_layer.draw_circle(q, 3.5, Color(0.2, 0.15, 0.08))
				bld_layer.draw_circle(q, 2.5, Color(1, 0.85, 0.3))
		# video pass: damaged buildings smoke and burn, contested ones fly white
		if e.finished and not e.sid.begins_with("mine_"):
			var frac: float = float(e.hp) / float(maxi(1, e.max_hp))
			if frac < 0.5:
				var fl := sin(anim_t * 9.0 + p.x * 0.3) * 2.0
				bld_layer.draw_circle(p + Vector2(-w * 0.2, -hgt * 0.5 + fl), 5.0, Color(1, 0.45, 0.12, 0.85))
				bld_layer.draw_circle(p + Vector2(w * 0.15, -hgt * 0.55 - fl), 3.5, Color(1, 0.8, 0.3, 0.85))
				bld_layer.draw_circle(p + Vector2(0, -hgt * 0.7), 6.0, Color(0.4, 0.4, 0.4, 0.35))
			elif frac < 0.8:
				bld_layer.draw_circle(p + Vector2(w * 0.2, -hgt * 0.6), 4.5, Color(0.5, 0.5, 0.5, 0.3))
			if float(e.get("capture_t", 0.0)) > 0.3:
				var pw := p + Vector2(0, -hgt * 0.6 - 18.0)
				bld_layer.draw_line(pw, pw + Vector2(0, -12), Color(0.3, 0.25, 0.2), 1.5)
				bld_layer.draw_colored_polygon([pw + Vector2(0, -12), pw + Vector2(10, -10), pw + Vector2(0, -8)], Color(1, 1, 1, 0.95))
	_draw_rubble()

func _bld_height(e: Dictionary) -> float:
	# sprite stand height in meters, from the footprint the sim uses
	return clampf(e.def.radius * 2.0, 2.0, 7.0)

func _draw_wall(p: Vector2, e: Dictionary) -> void:
	var r: float = e.def.radius * view_scale
	if e.sid == "gat":
		bld_layer.draw_rect(Rect2(p.x - r, p.y - r * 0.6, r * 2, r * 1.2), Color(0.45, 0.36, 0.24))
		bld_layer.draw_rect(Rect2(p.x - r * 0.5, p.y - r * 0.4, r, r * 0.9), Color(0.2, 0.16, 0.1) if bool(e.get("closed", false)) else Color(0.1, 0.1, 0.1, 0.35))
		bld_layer.draw_rect(Rect2(p.x - r, p.y + r * 0.6 - 2, r * 2, 2), _player_color(e.player), true)
		return
	# stone wall segment (wallcustom.cfg BuilderPoints ±0.9 m): grey block
	# with crenellations and player-colour trim
	bld_layer.draw_rect(Rect2(p.x - r, p.y - r * 0.6, r * 2, r * 1.2), Color(0.55, 0.54, 0.52))
	bld_layer.draw_rect(Rect2(p.x - r, p.y - r * 0.6, r * 2, r * 0.35), Color(0.68, 0.67, 0.64))
	for k in 4:
		var bx := p.x - r + k * (r * 2.0 / 4.0)
		bld_layer.draw_rect(Rect2(bx, p.y - r * 0.6 - 4, r * 2.0 / 8.0, 5), Color(0.62, 0.61, 0.59))
	bld_layer.draw_rect(Rect2(p.x - r, p.y + r * 0.6 - 2, r * 2, 2), _player_color(e.player), true)
	if not e.finished:
		bld_layer.draw_rect(Rect2(p.x - r - 3, p.y - r - 3, r * 2 + 6, r * 2 + 6), Color(0.4, 0.28, 0.15, 0.7), false, 1.5)

func _draw_mine(p: Vector2, e: Dictionary, col: Color) -> void:
	var r: float = e.def.radius * view_scale
	var mspr := _sprite_for(e.sid, -1)
	if mspr != null:
		var tint_m := Color(0.55, 0.55, 0.6) if not e.finished else Color(1, 1, 1)
		bld_layer.draw_circle(p + Vector2(0, 4), r * 1.5, Color(0, 0, 0, 0.22))
		_draw_sprite(bld_layer, mspr, p, 3.0, tint_m)
		if not e.finished:
			bld_layer.draw_rect(Rect2(p.x - r - 3, p.y - r - 3, r * 2 + 6, r * 2 + 6), Color(0.4, 0.28, 0.15, 0.7), false, 1.5)
		elif e.hp < e.max_hp:
			var k: float = clampf(float(e.hp) / e.max_hp, 0.0, 1.0)
			bld_layer.draw_rect(Rect2(p.x - r, p.y - r - 8, r * 2, 4), Color(0, 0, 0, 0.6))
			bld_layer.draw_rect(Rect2(p.x - r, p.y - r - 8, r * 2 * k, 4), Color(0.2, 0.9, 0.2))
		return
	bld_layer.draw_circle(p + Vector2(0, 4), r * 1.6, Color(0, 0, 0, 0.22))
	bld_layer.draw_circle(p, r * 1.4, Color(0.42, 0.4, 0.37))
	bld_layer.draw_circle(p + Vector2(-r * 0.4, -r * 0.4), r * 0.8, Color(0.55, 0.53, 0.5))
	var ore: Color = {"mine_gold": Color(0.9, 0.75, 0.2), "mine_iron": Color(0.7, 0.45, 0.3), "mine_coal": Color(0.25, 0.25, 0.28)}.get(e.sid, Color(0.8, 0.7, 0.3))
	bld_layer.draw_circle(p + Vector2(r * 0.3, -r * 0.3), r * 0.45, ore)
	# timber entrance frame
	bld_layer.draw_rect(Rect2(p.x - 5, p.y - 2, 10, 12), Color(0.3, 0.2, 0.1))
	bld_layer.draw_rect(Rect2(p.x - 5, p.y - 2, 10, 12), Color(0.45, 0.32, 0.18), false, 1.5)
	bld_layer.draw_rect(Rect2(p.x - r, p.y + r * 0.6, r * 2, 3), col, false, 1.5)
	if not e.finished:
		bld_layer.draw_rect(Rect2(p.x - r - 3, p.y - r - 3, r * 2 + 6, r * 2 + 6), Color(0.4, 0.28, 0.15, 0.7), false, 1.5)
	elif e.hp < e.max_hp:
		var k: float = clampf(float(e.hp) / e.max_hp, 0.0, 1.0)
		bld_layer.draw_rect(Rect2(p.x - r, p.y - r - 8, r * 2, 4), Color(0, 0, 0, 0.6))
		bld_layer.draw_rect(Rect2(p.x - r, p.y - r - 8, r * 2 * k, 4), Color(0.2, 0.9, 0.2))

func _draw_units() -> void:
	_draw_corpses()
	for e in game.entities:
		if e.dead or e.kind != "unit":
			continue
		var p := world_to_px(e.pos)
		if not view_rect.grow(64).has_point(p):
			continue
		var col := _player_color(e.player)
		var coat := col.darkened(0.08)
		var coat_lt := col.lightened(0.22)
		var coat_dk := col.darkened(0.38)
		var r: float = e.def.radius * view_scale
		var vr: float = r * 1.7 + 2.0
		# soft contact shadow (two alpha layers) + idle/march bob
		var bob := sin(anim_t * 5.0 + float(e.id) * 1.7) * (1.4 if e.moving else 0.5)
		var pb := p + Vector2(0, bob * 0.4)
		unit_layer.draw_circle(pb + Vector2(1.5, 3.0), vr * 1.05, Color(0, 0, 0, 0.16))
		unit_layer.draw_circle(pb + Vector2(1, 2), vr * 0.95, Color(0, 0, 0, 0.26))
		# team ring under the unit so sides read at a glance
		unit_layer.draw_arc(pb, vr + 1.5, 0, TAU, 22, Color(col.r, col.g, col.b, 0.55), 2.0)
		# animated original-model sheets (tools/bake_sprites.py) first,
		# static sprite, procedural body below stays as the fallback
		var tint: Color = SPRITE_TINT.get(e.sid, Color(1, 1, 1))
		var anim_drawn := _draw_anim(e, pb, tint)
		var spr := _sprite_for(e.sid, float(e.get("face", 0.0)))
		match ("__anim__" if anim_drawn else ("__sprite__" if spr != null else e.sid)):
			"__anim__":
				pass
			"__sprite__":
				_draw_sprite(unit_layer, spr, pb, _unit_height(e), tint, false)
			"cossack", "dragoon":
				var dir := Vector2(cos(e.face), sin(e.face))
				var side := Vector2(-dir.y, dir.x)
				var body := Color(0.40, 0.29, 0.17)
				var body_dk := Color(0.25, 0.17, 0.10)
				unit_layer.draw_circle(pb - dir * 2.0, vr * 1.05, body_dk)
				unit_layer.draw_circle(pb - dir * 2.0, vr * 0.8, body)
				unit_layer.draw_circle(pb - dir * 2.0 + Vector2(-1.5, -1.5), vr * 0.45, body.lightened(0.18))
				unit_layer.draw_circle(pb + dir * 5.0, vr * 0.55, body.lightened(0.12))
				unit_layer.draw_circle(pb + dir * 5.0 + Vector2(-1, -1), vr * 0.28, Color(0.55, 0.42, 0.26))
				var rp := pb + side * 2.5 - dir * 1.0 + Vector2(0, bob * 0.3)
				unit_layer.draw_circle(rp, vr * 0.62, coat_dk)
				unit_layer.draw_circle(rp, vr * 0.5, coat)
				unit_layer.draw_circle(rp + Vector2(-1, -1.2), vr * 0.28, coat_lt)
				unit_layer.draw_circle(rp + Vector2(0, -vr * 0.25), vr * 0.3, Color(0.91, 0.80, 0.63))
				unit_layer.draw_rect(Rect2(rp - dir * 2.6 + Vector2(-3, -1.2), Vector2(6, 2.4)), Color(0.12, 0.12, 0.12))
				unit_layer.draw_line(rp, rp + dir * (vr + 4.0), coat_lt, 1.5)
			"cannon":
				var dir := Vector2(cos(e.face), sin(e.face))
				var side := Vector2(-dir.y, dir.x)
				unit_layer.draw_circle(pb - side * 6.0, 5.5, Color(0.19, 0.14, 0.10))
				unit_layer.draw_circle(pb + side * 6.0, 5.5, Color(0.19, 0.14, 0.10))
				unit_layer.draw_circle(pb - side * 6.0 + Vector2(-1, -1), 2.4, Color(0.50, 0.42, 0.30))
				unit_layer.draw_circle(pb + side * 6.0 + Vector2(-1, -1), 2.4, Color(0.50, 0.42, 0.30))
				unit_layer.draw_line(pb - dir * 6.0, pb + dir * 11.0, Color(0.10, 0.10, 0.11), 5.0)
				unit_layer.draw_line(pb - dir * 6.0, pb + dir * 11.0, Color(0.42, 0.42, 0.44), 1.6)
				unit_layer.draw_line(pb - dir * 6.0, pb + dir * 11.0 + Vector2(0, -1), Color(0.62, 0.62, 0.64, 0.6), 1.0)
				unit_layer.draw_rect(Rect2(pb - dir * 7.0 + Vector2(-3.5, -2), Vector2(7, 4)), Color(0.48, 0.36, 0.21))
				unit_layer.draw_rect(Rect2(pb - dir * 7.0 + Vector2(-3.5, -2), Vector2(7, 1.2)), Color(0.62, 0.50, 0.32))
			"peasant":
				unit_layer.draw_circle(pb, vr, coat_dk)
				unit_layer.draw_circle(pb, vr * 0.85, Color(0.55, 0.42, 0.27))
				unit_layer.draw_circle(pb + Vector2(-1.2, -1.2), vr * 0.55, Color(0.62, 0.49, 0.32))
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.45), vr * 0.5, Color(0.89, 0.76, 0.57))
				unit_layer.draw_circle(pb + Vector2(-1, -vr * 0.45 - 1), vr * 0.22, Color(0.95, 0.84, 0.66))
				unit_layer.draw_arc(pb + Vector2(0, -vr * 0.45), vr * 0.72, 0, TAU, 14, Color(0.74, 0.62, 0.33), 2.2)
				unit_layer.draw_arc(pb, vr * 0.85, PI * 1.15, PI * 1.85, 12, coat_lt, 1.5)
			"officer", "officer18":
				unit_layer.draw_circle(pb, vr, coat_dk)
				unit_layer.draw_circle(pb, vr * 0.85, coat)
				unit_layer.draw_circle(pb + Vector2(-1.2, -1.2), vr * 0.5, coat_lt)
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.48, Color(0.91, 0.80, 0.63))
				unit_layer.draw_circle(pb + Vector2(-1, -vr * 0.4 - 1), vr * 0.2, Color(0.97, 0.88, 0.72))
				unit_layer.draw_rect(Rect2(pb + Vector2(-vr * 0.55, -vr * 1.25), Vector2(vr * 1.1, vr * 0.4)), Color(0.12, 0.12, 0.14))
				unit_layer.draw_rect(Rect2(pb + Vector2(-vr * 0.55, -vr * 1.25), Vector2(vr * 1.1, vr * 0.4)), coat_lt, false, 1.0)
				unit_layer.draw_rect(Rect2(pb + Vector2(-1.2, -vr * 0.1), Vector2(2.4, vr)), Color(0.93, 0.85, 0.56))
				unit_layer.draw_rect(Rect2(pb + Vector2(-1.2, -vr * 0.1), Vector2(1.0, vr)), Color(1, 0.96, 0.75))
				# officer flag: the video shows the colours flying over the line
				var wave := sin(anim_t * 4.0 + float(e.id)) * 1.5
				unit_layer.draw_line(pb + Vector2(4, -vr), pb + Vector2(4, -vr - 12), Color(0.3, 0.22, 0.14), 1.6)
				unit_layer.draw_colored_polygon([pb + Vector2(4, -vr - 12), pb + Vector2(12 + wave, -vr - 10), pb + Vector2(4, -vr - 8)], col)
			"drummer":
				unit_layer.draw_circle(pb, vr, coat_dk)
				unit_layer.draw_circle(pb, vr * 0.85, coat)
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.45, Color(0.91, 0.80, 0.63))
				unit_layer.draw_circle(pb + Vector2(-4, 2), vr * 0.5, Color(0.75, 0.65, 0.5))
				unit_layer.draw_circle(pb + Vector2(4, 2), vr * 0.5, Color(0.75, 0.65, 0.5))
				unit_layer.draw_arc(pb + Vector2(0, 2), vr * 0.7, 0, TAU, 12, Color(0.9, 0.85, 0.7), 1.5)
			"priest":
				unit_layer.draw_circle(pb, vr, Color(0.08, 0.08, 0.09))
				unit_layer.draw_circle(pb, vr * 0.85, Color(0.12, 0.11, 0.12))
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.45, Color(0.89, 0.78, 0.62))
				unit_layer.draw_line(pb + Vector2(0, -vr * 0.5), pb + Vector2(0, vr * 0.5), Color(0.85, 0.75, 0.4), 1.5)
				unit_layer.draw_line(pb + Vector2(-2.5, -1), pb + Vector2(2.5, -1), Color(0.85, 0.75, 0.4), 1.5)
			"archer":
				unit_layer.draw_circle(pb, vr, Color(0.28, 0.22, 0.14))
				unit_layer.draw_circle(pb, vr * 0.85, Color(0.50, 0.42, 0.30))
				unit_layer.draw_circle(pb + Vector2(-1, -1), vr * 0.5, Color(0.60, 0.52, 0.37))
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.48, Color(0.89, 0.76, 0.58))
				unit_layer.draw_rect(Rect2(pb + Vector2(-vr * 0.5, -vr * 1.1), Vector2(vr, vr * 0.32)), Color(0.32, 0.26, 0.18))
				var dir := Vector2(cos(e.face), sin(e.face))
				unit_layer.draw_line(pb + dir * 1.0, pb + dir * (vr + 8.0), Color(0.42, 0.31, 0.18), 2.0)
				unit_layer.draw_line(pb + dir * 1.0, pb + dir * (vr + 8.0) + Vector2(0, -1), Color(0.60, 0.47, 0.28, 0.7), 1.0)
			_:
				var dir := Vector2(cos(e.face), sin(e.face))
				unit_layer.draw_circle(pb, vr, coat_dk)
				unit_layer.draw_circle(pb, vr * 0.85, coat)
				unit_layer.draw_circle(pb + Vector2(-1.2, -1.2), vr * 0.5, coat_lt)
				unit_layer.draw_line(pb + Vector2(-vr * 0.45, -vr * 0.55), pb + Vector2(vr * 0.45, vr * 0.55), Color(0.93, 0.91, 0.83), 2.0)
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.46, Color(0.91, 0.80, 0.63))
				unit_layer.draw_circle(pb + Vector2(-1, -vr * 0.4 - 1), vr * 0.2, Color(0.97, 0.87, 0.71))
				unit_layer.draw_circle(pb + Vector2(0, -vr * 0.4), vr * 0.46, Color(0.45, 0.32, 0.20), false, 1.0)
				unit_layer.draw_rect(Rect2(pb + Vector2(-vr * 0.6, -vr * 1.2), Vector2(vr * 1.2, vr * 0.45)), Color(0.10, 0.10, 0.12))
				unit_layer.draw_rect(Rect2(pb + Vector2(-vr * 0.6, -vr * 1.2), Vector2(vr * 1.2, vr * 0.45)), coat_lt, false, 1.0)
				var tip: Vector2 = pb + dir * (vr + 9.0)
				unit_layer.draw_line(pb + dir * vr * 0.4, tip, Color(0.30, 0.21, 0.11), 2.4)
				if e.sid == "pikeman":
					unit_layer.draw_circle(tip, 2.0, Color(0.80, 0.80, 0.84))
					unit_layer.draw_circle(tip, 2.0, Color(0.35, 0.35, 0.38), false, 1.0)
					unit_layer.draw_circle(tip + Vector2(-0.6, -0.6), 0.7, Color(1, 1, 1, 0.8))
				else:
					unit_layer.draw_circle(tip, 1.6, Color(0.55, 0.42, 0.22))
		if e.get("selected", false):
			var fd := Vector2(cos(e.face), sin(e.face))
			unit_layer.draw_line(p + fd * (vr + 2.0), p + fd * (vr + 7.0), Color(1, 1, 1, 0.9), 2.0)
			unit_layer.draw_arc(p, vr + 5.0, 0, TAU, 24, Color(0.1, 0.1, 0.1, 0.8), 3.0)
			unit_layer.draw_arc(p, vr + 5.0, 0, TAU, 24, Color(1, 1, 1, 0.95), 1.5)
		if e.hp < e.max_hp:
			var w: float = vr * 2.4
			unit_layer.draw_rect(Rect2(p.x - w / 2, p.y - vr - 11, w + 2, 6), Color(0, 0, 0, 0.7))
			unit_layer.draw_rect(Rect2(p.x - w / 2, p.y - vr - 10, w * clampf(float(e.hp) / e.max_hp, 0, 1), 4), Color(0.25, 0.9, 0.25))
			unit_layer.draw_rect(Rect2(p.x - w / 2, p.y - vr - 10, w * clampf(float(e.hp) / e.max_hp, 0, 1), 1.5), Color(0.6, 1, 0.6, 0.7))
			# morale pip: green holds, amber wavers, red routs (video: the line breaks)
			if not e.def.get("support", false) and e.sid != "peasant":
				var m: float = float(e.get("morale", 70.0))
				var mc := Color(0.3, 0.9, 0.3) if m > 50.0 else (Color(0.95, 0.8, 0.25) if m > 25.0 else Color(0.95, 0.25, 0.2))
				unit_layer.draw_circle(p + Vector2(-vr - 4, -vr - 6), 2.2, Color(0, 0, 0, 0.6))
				unit_layer.draw_circle(p + Vector2(-vr - 4, -vr - 6), 1.6, mc)
		if e.get("routing", false):
			unit_layer.draw_arc(p, vr + 9.0, 0, TAU, 16, Color(1, 0.3, 0.2, 0.8), 1.5)
			unit_layer.draw_line(p + Vector2(-5, -vr - 12), p + Vector2(5, -vr - 16), Color(1, 1, 1, 0.9), 1.5)
		if e.get("carry", 0) > 0:
			unit_layer.draw_circle(p + Vector2(vr * 0.8, -vr * 0.8), 3.4, Color(0.22, 0.16, 0.07))
			unit_layer.draw_circle(p + Vector2(vr * 0.8, -vr * 0.8), 2.4, Color(0.93, 0.81, 0.39))
			unit_layer.draw_circle(p + Vector2(vr * 0.8 - 0.8, -vr * 0.8 - 0.8), 1.0, Color(1, 0.95, 0.65))


func _draw_corpses() -> void:
	# the aftermath of a volley: fallen coats fading into the grass
	for c in game.corpses:
		var p := world_to_px(c.pos)
		if not view_rect.grow(64).has_point(p):
			continue
		var a := clampf(1.0 - c.t / c.life, 0.0, 1.0) * 0.55
		# death sheet (tools/bake_sprites.py): last falls linger, then fade
		var ckey := str(c.sid)
		var cinfo: Dictionary = anim_index.get(ckey, {})
		if not cinfo.is_empty() and (cinfo.actions as Dictionary).has("death"):
			var dact: Dictionary = cinfo.actions.death
			var dn: int = int(dact.frames)
			var dd: float = maxf(0.05, float(dact.duration))
			var dcell: int = int(cinfo.cell)
			var dtk := ckey + "_death"
			if not anim_tex.has(dtk) and FileAccess.file_exists("res://assets/models/anim/%s.png" % dtk):
				anim_tex[dtk] = load("res://assets/models/anim/%s.png" % dtk)
			if anim_tex.has(dtk):
				var dtex: Texture2D = anim_tex[dtk]
				if dtex == null:
					anim_tex.erase(dtk)
				else:
					var dfi: int = mini(dn - 1, int(float(c.t) / dd * dn))
					var ddir := int(fposmod(roundf(float(c.get("face", 0.0)) / (PI / 4.0)), 8.0)) % 8
					var dsrc := Rect2(ddir * dcell, dfi * dcell, dcell, dcell)
					var dsc: float = 1.9 * view_scale / float(dcell)
					var dsz := Vector2(dcell, dcell) * dsc
					var dtl := p - Vector2(dsz.x * 0.5, dsz.y * 0.82)
					unit_layer.draw_texture_rect_region(dtex, Rect2(dtl, dsz), dsrc, Color(0.55, 0.5, 0.5, a))
					continue
		var cspr := _sprite_for(str(c.sid), 0.0)
		if cspr != null:
			var fade := Color(0.45, 0.4, 0.4, a)
			_draw_sprite(unit_layer, cspr, p, 1.9, fade, false)
			continue
		var col := _player_color(int(c.player)).darkened(0.3)
		unit_layer.draw_circle(p + Vector2(0, 1), 4.5, Color(0, 0, 0, a * 0.5))
		unit_layer.draw_circle(p, 4.0, Color(col.r, col.g, col.b, a))

func _draw_rubble() -> void:
	# lingering destroyed-building rubble, fading like corpses
	for c in game.rubble:
		var p := world_to_px(c.pos)
		if not view_rect.grow(64).has_point(p):
			continue
		var a := clampf(1.0 - c.t / c.life, 0.0, 1.0) * 0.6
		var nat := ""
		if int(c.player) >= 0 and int(c.player) < Data.PLAYER_NATIONS.size():
			nat = str(Data.PLAYER_NATIONS[int(c.player)])
		var tex: Texture2D = null
		for key in (["%s_%s_dead" % [nat, c.sid]] if nat != "" else []) + ["%s_dead" % c.sid]:
			tex = _bld_anim(key)
			if tex != null:
				break
		if tex != null:
			var cell := 320
			var sc: float = 3.0 * view_scale / float(cell)
			var sz := Vector2(cell, cell) * sc
			var tl := p - Vector2(sz.x * 0.5, sz.y * 0.82)
			bld_layer.draw_texture_rect(tex, Rect2(tl, sz), false, Color(0.5, 0.45, 0.4, a))
			continue
		bld_layer.draw_circle(p, 8.0, Color(0.3, 0.27, 0.24, a))

func _draw_ghost() -> void:
	# build placement preview (green = ok, red = blocked), like the original
	if game == null or hud == null:
		return
	var sid := str(hud.get("build_ghost_sid")) if hud.get("build_ghost_sid") != null else ""
	if sid == "" or not Data.BUILDINGS.has(sid):
		return
	var mp := get_viewport().get_mouse_position()
	var xform := get_viewport().get_canvas_transform().affine_inverse()
	var wp: Vector2 = (xform * mp) / maxf(1.0, view_scale)
	if not game.in_bounds(wp):
		return
	var def: Dictionary = Data.BUILDINGS[sid]
	var ok := not game.is_blocked(wp) and Data.can_pay(game.players[0].res, def.cost)
	var c := Color(0.2, 1.0, 0.3, 0.5) if ok else Color(1.0, 0.25, 0.2, 0.5)
	var p := world_to_px(wp)
	var r: float = def.radius * view_scale
	fx_layer.draw_arc(p, r + 4.0, 0, TAU, 28, c, 2.0)
	fx_layer.draw_rect(Rect2(p.x - r, p.y - r, r * 2, r * 2), c, false, 1.5)

func add_fx(kind: String, pos: Vector2) -> void:
	var life := 0.35
	match kind:
		"smoke":
			life = 1.6
		"explode", "crater":
			life = 0.8
		"fire":
			life = 0.9
		"heal":
			life = 0.9
		"capture", "rout":
			life = 1.2
	fx_items.append({"kind": kind, "pos": world_to_px(pos), "t": 0.0, "life": life})
	if fx_items.size() > 220:
		fx_items.pop_front()

func _draw_fx() -> void:
	# squad links: faint lines from the officer to his soldiers (selected only)
	if game != null:
		for sid in game.squads:
			var s: Dictionary = game.squads[sid]
			var off: Dictionary = game.by_id.get(int(s.officer), {})
			if off.is_empty() or off.dead:
				continue
			if not bool(off.get("selected", false)):
				continue
			var op := world_to_px(off.pos)
			for uid in s.members + [int(s.get("drummer", 0))]:
				if uid == 0:
					continue
				var u: Dictionary = game.by_id.get(uid, {})
				if u.is_empty() or u.dead:
					continue
				fx_layer.draw_line(op, world_to_px(u.pos), Color(1, 1, 1, 0.35), 1.5)
	# rally flags on barracks / stables / town halls
	if game != null:
		for e in game.entities:
			if e.dead or e.kind != "building" or not e.has("rally"):
				continue
			var rp: Vector2 = e.rally
			var bp := world_to_px(e.pos)
			var fp := world_to_px(rp)
			fx_layer.draw_line(bp, fp, Color(1, 1, 1, 0.4), 1.5)
			fx_layer.draw_line(fp, fp + Vector2(0, -12), Color(0.3, 0.25, 0.2), 1.5)
			fx_layer.draw_colored_polygon([fp + Vector2(0, -12), fp + Vector2(9, -10), fp + Vector2(0, -8)],
				_player_color(e.player))
	_draw_ghost()
	# in-flight shells and arrows (video: cannonballs arc across the field)
	for pr in game.projectiles:
		var pp := world_to_px(pr.target.lerp(pr.pos, 1.0 - pr.t / maxf(0.01, pr.total)))
		if not view_rect.grow(64).has_point(pp):
			continue
		if pr.kind == "cannonball":
			fx_layer.draw_circle(pp, 3.0, Color(0.05, 0.05, 0.05))
			fx_layer.draw_circle(pp + Vector2(-4, -2), 2.0, Color(0.6, 0.6, 0.6, 0.5))
		else:
			fx_layer.draw_line(pp + Vector2(-3, 1), pp + Vector2(3, -1), Color(0.7, 0.6, 0.4, 0.9), 1.5)
	# drag-selection rectangle (screen-space friendly: drawn in map px)
	if sel_active and sel_rect.size.length() > 4.0:
		var a := world_to_px(Vector2(sel_rect.position.x, sel_rect.position.y))
		var b := world_to_px(Vector2(sel_rect.end.x, sel_rect.end.y))
		var r := Rect2(a, b - a).abs()
		fx_layer.draw_rect(r, Color(1, 1, 1, 0.9), false, 1.5)
		fx_layer.draw_rect(r, Color(1, 1, 1, 0.18), true)
	# ghost placement marker
	for f in fx_items:
		var k: float = f.t / f.life
		match f.kind:
			"shot":
				fx_layer.draw_circle(f.pos, 2.0, Color(1, 0.9, 0.5, 1.0 - k))
			"smoke":
				# musket volley smoke: grey-white puffs drifting up and fading
				var rise := k * 14.0
				fx_layer.draw_circle(f.pos + Vector2(0, -4 - rise), 5.0 + k * 9.0, Color(0.85, 0.85, 0.82, (1.0 - k) * 0.55))
				fx_layer.draw_circle(f.pos + Vector2(3, -7 - rise), 3.5 + k * 6.0, Color(0.95, 0.95, 0.92, (1.0 - k) * 0.4))
			"explode":
				fx_layer.draw_arc(f.pos, 4.0 + k * 26.0, 0, TAU, 20, Color(1, 0.6, 0.2, 1.0 - k), 3.0)
				fx_layer.draw_circle(f.pos, 6.0 * (1.0 - k) + 2.0, Color(1, 0.85, 0.4, 1.0 - k))
			"crater":
				fx_layer.draw_circle(f.pos, 7.0, Color(0.15, 0.12, 0.09, (1.0 - k) * 0.8 + 0.2))
				fx_layer.draw_arc(f.pos, 7.0 + k * 10.0, 0, TAU, 16, Color(0.5, 0.4, 0.3, 1.0 - k), 2.0)
			"fire":
				fx_layer.draw_circle(f.pos + Vector2(0, -6), 4.0 + sin(k * 12.0) * 1.5, Color(1, 0.45, 0.1, 1.0 - k))
				fx_layer.draw_circle(f.pos + Vector2(0, -9), 2.5, Color(1, 0.8, 0.3, 1.0 - k))
			"heal":
				fx_layer.draw_arc(f.pos + Vector2(0, -4), 3.0 + k * 7.0, 0, TAU, 14, Color(0.4, 1, 0.5, 1.0 - k), 1.5)
			"capture":
				fx_layer.draw_line(f.pos + Vector2(0, -10), f.pos + Vector2(0, -26), Color(0.4, 0.3, 0.2), 1.5)
				fx_layer.draw_colored_polygon([f.pos + Vector2(0, -26), f.pos + Vector2(10, -24), f.pos + Vector2(0, -22)], Color(1, 1, 1, 1.0 - k * 0.5))
			"rout":
				fx_layer.draw_line(f.pos + Vector2(-5, -12), f.pos + Vector2(5, -16), Color(1, 0.3, 0.2, 1.0 - k), 2.0)
			"chop":
				fx_layer.draw_circle(f.pos + Vector2(0, -6), 2.0 + k * 3.0, Color(0.7, 0.6, 0.3, 1.0 - k))
