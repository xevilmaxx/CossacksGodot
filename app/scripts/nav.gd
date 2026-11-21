# Grid A* pathfinding for unit movement.
#
# The simulation stores passability as a flat PackedByteArray (`C3Game.blocked`,
# TILE metres per cell).  This class plans a route over that grid so a unit
# ordered to a point behind a building walks *around* the footprint instead of
# pushing into it until it gets stuck.  It is deliberately self-contained: it
# reads the blocked array passed to find_path() and keeps all scratch buffers
# between queries, so issuing a group order does not allocate per unit.
#
# Extra per-query blockers (closed / enemy gates) are handled through the
# `extra` argument; they are not written back into the shared grid.
extends RefCounted
class_name C3Nav

const MAX_EXPAND := 20000
const SEARCH_RADIUS := 24          # cells searched when a goal is inside a wall
const SQRT2 := 1.4142135623730951

# 8 neighbours: cardinals first, then diagonals.  Diagonals additionally
# require both shared orthogonal neighbours to be free (no corner cutting).
const DX := [1, -1, 0, 0, 1, 1, -1, -1]
const DY := [0, 0, 1, -1, 1, -1, 1, -1]

var w := 0
var h := 0
var tile := 2.0
var version := -1

var _g: PackedFloat32Array = PackedFloat32Array()
var _parent: PackedInt32Array = PackedInt32Array()
var _seen: PackedInt32Array = PackedInt32Array()
var _closed: PackedInt32Array = PackedInt32Array()
var _heap_id: PackedInt32Array = PackedInt32Array()
var _heap_pri: PackedFloat32Array = PackedFloat32Array()
var _heap_n := 0
var _stamp := 0
var _extra: Dictionary = {}


func configure(width: int, height: int, tile_size: float) -> void:
	if width == w and height == h and is_equal_approx(tile_size, tile):
		return
	w = maxi(1, width)
	h = maxi(1, height)
	tile = maxf(0.1, tile_size)
	var n: int = w * h
	_g.resize(n)
	_parent.resize(n)
	_seen.resize(n)
	_closed.resize(n)
	_heap_id.resize(maxi(64, n))
	_heap_pri.resize(maxi(64, n))
	_heap_n = 0
	_stamp = 0
	version = -1


func cell_of(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / tile), 0, w - 1),
		clampi(int(p.y / tile), 0, h - 1))


func cell_center(c: Vector2i) -> Vector2:
	return Vector2((float(c.x) + 0.5) * tile, (float(c.y) + 0.5) * tile)


func _blocked_cell(c: Vector2i, blocked: PackedByteArray) -> bool:
	return _blocked_xy(c.x, c.y, blocked)


# Integer form used in the A* hot loop - no Vector2i allocation per neighbour.
func _blocked_xy(x: int, y: int, blocked: PackedByteArray) -> bool:
	if x < 0 or y < 0 or x >= w or y >= h:
		return true
	if blocked[y * w + x] != 0:
		return true
	return _extra.has(y * w + x)


# Nearest walkable cell, searched as expanding square rings so the result is
# deterministic.  Used when the ordered point lands inside a building/wall.
func _nearest_open(c: Vector2i, blocked: PackedByteArray) -> Vector2i:
	if not _blocked_cell(c, blocked):
		return c
	for r in range(1, SEARCH_RADIUS + 1):
		var best := Vector2i(-1, -1)
		var best_d := 1e9
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var qx: int = c.x + dx
				var qy: int = c.y + dy
				if _blocked_xy(qx, qy, blocked):
					continue
				var dd: float = float(dx * dx + dy * dy)
				if dd < best_d:
					best_d = dd
					best = Vector2i(qx, qy)
		if best.x >= 0:
			return best
	return Vector2i(-1, -1)


func _heuristic(ax: int, ay: int, bx: int, by: int) -> float:
	var dx: float = float(absi(ax - bx))
	var dy: float = float(absi(ay - by))
	return maxf(dx, dy) + (SQRT2 - 1.0) * minf(dx, dy)


func _heap_push(id: int, pri: float) -> void:
	if _heap_n >= _heap_id.size():
		var grow: int = maxi(64, _heap_id.size() * 2)
		_heap_id.resize(grow)
		_heap_pri.resize(grow)
	var i: int = _heap_n
	_heap_n += 1
	while i > 0:
		var p: int = (i - 1) / 2
		if _heap_pri[p] <= pri:
			break
		_heap_id[i] = _heap_id[p]
		_heap_pri[i] = _heap_pri[p]
		i = p
	_heap_id[i] = id
	_heap_pri[i] = pri


func _heap_pop() -> int:
	var top: int = _heap_id[0]
	_heap_n -= 1
	if _heap_n > 0:
		var lid: int = _heap_id[_heap_n]
		var lpri: float = _heap_pri[_heap_n]
		var i: int = 0
		while true:
			var l: int = i * 2 + 1
			if l >= _heap_n:
				break
			var r: int = l + 1
			var c: int = l
			if r < _heap_n and _heap_pri[r] < _heap_pri[l]:
				c = r
			if _heap_pri[c] >= lpri:
				break
			_heap_id[i] = _heap_id[c]
			_heap_pri[i] = _heap_pri[c]
			i = c
		_heap_id[i] = lid
		_heap_pri[i] = lpri
	return top


# Returns an Array of Vector2i cells from just after the start cell to the
# goal (or closest reachable cell).  Empty means no route exists.
func find_path(start_w: Vector2, goal_w: Vector2, blocked: PackedByteArray,
		extra: Array = []) -> Array:
	if w <= 0 or blocked.size() < w * h:
		return []
	_extra.clear()
	for c in extra:
		var cell: Vector2i = c as Vector2i
		_extra[cell.y * w + cell.x] = true
	var s := cell_of(start_w)
	var g := cell_of(goal_w)
	s = _nearest_open(s, blocked)
	g = _nearest_open(g, blocked)
	if s.x < 0 or g.x < 0:
		return []

	var n: int = w * h
	var start_i: int = s.y * w + s.x
	var goal_i: int = g.y * w + g.x
	_stamp += 1
	var stamp: int = _stamp
	_heap_n = 0
	_seen[start_i] = stamp
	_closed[start_i] = 0
	_g[start_i] = 0.0
	_parent[start_i] = -1
	_heap_push(start_i, _heuristic(s.x, s.y, g.x, g.y))

	var found := false
	var best_i: int = start_i
	var best_h: float = _heuristic(s.x, s.y, g.x, g.y)
	var expanded := 0
	while _heap_n > 0 and expanded < MAX_EXPAND:
		var ci: int = _heap_pop()
		if _closed[ci] == stamp:
			continue
		_closed[ci] = stamp
		var cx: int = ci % w
		var cy: int = ci / w
		var ch: float = _heuristic(cx, cy, g.x, g.y)
		if ch < best_h:
			best_h = ch
			best_i = ci
		if ci == goal_i:
			found = true
			break
		expanded += 1
		var base_g: float = _g[ci]
		var gx: int = g.x
		var gy: int = g.y
		for k in 8:
			var nx: int = cx + DX[k]
			var ny: int = cy + DY[k]
			if nx < 0 or ny < 0 or nx >= w or ny >= h:
				continue
			var ni: int = ny * w + nx
			if _blocked_xy(nx, ny, blocked):
				continue
			if k >= 4:
				# Diagonal step is only legal when the two cells it passes
				# between are walkable (no cutting building corners).
				if _blocked_xy(cx + DX[k], cy, blocked) \
					or _blocked_xy(cx, cy + DY[k], blocked):
					continue
			var dxh: float = float(absi(nx - gx))
			var dyh: float = float(absi(ny - gy))
			var hval: float = maxf(dxh, dyh) + (SQRT2 - 1.0) * minf(dxh, dyh)
			var step: float = 1.0 if k < 4 else SQRT2
			var ng: float = base_g + step
			if _seen[ni] == stamp and ng >= _g[ni]:
				continue
			_seen[ni] = stamp
			_g[ni] = ng
			_parent[ni] = ci
			_heap_push(ni, ng + hval)

	var end_i: int = goal_i if found else best_i
	var cells: Array = []
	var cur: int = end_i
	var guard := 0
	while cur >= 0 and guard < n:
		cells.append(Vector2i(cur % w, cur / w))
		cur = int(_parent[cur])
		guard += 1
	cells.reverse()
	if cells.size() <= 1:
		return []
	cells.remove_at(0)   # the unit is already in/near the start cell
	return cells
