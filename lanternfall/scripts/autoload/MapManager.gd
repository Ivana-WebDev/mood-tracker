extends Node
## Generates branching node maps. Floors run left -> right (landscape layout).

const FLOORS := 12 # regular floors (0..11); boss sits on floor 12
const LANES := 7
const PATHS := 6
const TREASURE_FLOOR := 6
## Minimum elites per act (Act 2 is meant to be the tougher, more rewarding road).
const MIN_ELITES := {1: 3, 2: 4}
## The longest run of plain monster fights a route may have before one becomes an event.
const MAX_MONSTER_STREAK := 3

var _act := 1


func generate(act: int, rng: RandomNumberGenerator) -> Dictionary:
	var grid := {} # "f:l" -> node id
	var nodes: Array = []
	var edges: Array = [] # [floor, from_lane, to_lane]
	for p in PATHS:
		var lane := rng.randi_range(0, LANES - 1)
		if p == 1:
			# Guarantee at least two distinct starting points.
			var first: int = nodes[0]["lane"]
			while lane == first:
				lane = rng.randi_range(0, LANES - 1)
		for f in FLOORS:
			var id := _ensure(grid, nodes, f, lane, rng)
			if f == FLOORS - 1:
				break
			var options := [lane - 1, lane, lane + 1].filter(func(x): return x >= 0 and x < LANES)
			_shuffle(options, rng)
			var nxt := lane
			for cand in options:
				if not _crosses(edges, f, lane, cand):
					nxt = cand
					break
			var to_id := _ensure(grid, nodes, f + 1, nxt, rng)
			if not nodes[id]["next"].has(to_id):
				nodes[id]["next"].append(to_id)
				edges.append([f, lane, nxt])
			lane = nxt
	# Boss
	var boss := {"id": nodes.size(), "floor": FLOORS, "lane": LANES >> 1, "type": "boss", "next": [],
		"visited": false, "jx": 0.0, "jy": 0.0}
	nodes.append(boss)
	for n in nodes:
		if n["floor"] == FLOORS - 1:
			n["next"].append(boss["id"])
	_act = act
	_assign_types(nodes, rng)
	return {"act": act, "nodes": nodes, "boss": boss["id"], "floors": FLOORS + 1}


func _ensure(grid: Dictionary, nodes: Array, f: int, lane: int, rng: RandomNumberGenerator) -> int:
	var key := "%d:%d" % [f, lane]
	if grid.has(key):
		return grid[key]
	var id := nodes.size()
	nodes.append({"id": id, "floor": f, "lane": lane, "type": "monster", "next": [], "visited": false,
		"jx": rng.randf_range(-0.25, 0.25), "jy": rng.randf_range(-0.22, 0.22)})
	grid[key] = id
	return id


func _crosses(edges: Array, f: int, a: int, b: int) -> bool:
	for e in edges:
		if e[0] != f:
			continue
		var c: int = e[1]
		var d: int = e[2]
		if (a < c and b > d) or (a > c and b < d):
			return true
	return false


func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t


func parents_of(nodes: Array, id: int) -> Array:
	var out: Array = []
	for n in nodes:
		if n["next"].has(id):
			out.append(n)
	return out


func _assign_types(nodes: Array, rng: RandomNumberGenerator) -> void:
	var sorted := nodes.duplicate()
	sorted.sort_custom(func(a, b): return a["floor"] < b["floor"])
	for n in sorted:
		var f: int = n["floor"]
		if n["type"] == "boss":
			continue
		if f == 0:
			n["type"] = "monster"
			continue
		if f == TREASURE_FLOOR:
			n["type"] = "treasure"
			continue
		if f == FLOORS - 1:
			n["type"] = "rest"
			continue
		var parents := parents_of(nodes, n["id"])
		var chosen := "monster"
		for attempt in 8:
			chosen = _roll_type(f, rng)
			var ok := true
			if chosen in ["elite", "rest", "shop"]:
				for p in parents:
					if p["type"] == chosen:
						ok = false
			if chosen == "rest" and f == FLOORS - 2:
				ok = false
			if ok:
				break
			chosen = "monster"
		n["type"] = chosen
	_guarantee_mid_rest(nodes, rng)
	# Two shops per act (one in each half) and a healthy number of elites, spread out.
	_guarantee_in(nodes, "shop", 2, 6, rng)
	_guarantee_in(nodes, "shop", 7, 10, rng)
	_guarantee_elites(nodes, int(MIN_ELITES.get(_act, 3)), rng)
	_break_monster_streaks(nodes)


## Every route must pass a rest site between floors 4 and 9, on top of the campfire before the boss.
## Rest sites are never placed next to another rest site, nor in a route's first 3 nodes.
func _guarantee_mid_rest(nodes: Array, rng: RandomNumberGenerator) -> void:
	for attempt in 60:
		var path := _route_without_mid_rest(nodes)
		if path.is_empty():
			return
		var spot := _spaced_spot(nodes, path, ["monster", "event"], rng)
		if spot.is_empty():
			spot = _spaced_spot(nodes, path, ["monster", "event", "shop", "elite"], rng)
		if spot.is_empty():
			# Every floor-4..9 spot on this route touches a rest site: move that neighbouring rest
			# onto this route instead (it stays a rest site for its other routes only if spaced).
			var cand: Array = path.filter(func(n): return n["floor"] >= 4 and n["floor"] <= 9 and n["type"] in ["monster", "event"])
			if cand.is_empty():
				return
			var pick: Dictionary = cand[rng.randi_range(0, cand.size() - 1)]
			for nb in _neighbours(nodes, pick):
				if nb["type"] == "rest" and nb["floor"] < MapManager.FLOORS - 1:
					nb["type"] = "monster"
			pick["type"] = "rest"
			continue
		spot["type"] = "rest"


func _neighbours(nodes: Array, n: Dictionary) -> Array:
	var out: Array = parents_of(nodes, n["id"])
	for nx in n["next"]:
		out.append(nodes[nx])
	return out


func _spaced_spot(nodes: Array, path: Array, types: Array, rng: RandomNumberGenerator) -> Dictionary:
	var c: Array = path.filter(func(n):
		if n["floor"] < 4 or n["floor"] > 9 or not types.has(n["type"]):
			return false
		for nb in _neighbours(nodes, n):
			if nb["type"] == "rest":
				return false
		return true)
	return {} if c.is_empty() else c[rng.randi_range(0, c.size() - 1)]


func _route_without_mid_rest(nodes: Array) -> Array:
	var dead := {}
	for n in nodes:
		if n["floor"] == 0:
			var p := _dfs_no_rest(nodes, n, dead)
			if not p.is_empty():
				return p
	return []


func _dfs_no_rest(nodes: Array, n: Dictionary, dead: Dictionary) -> Array:
	if dead.has(n["id"]):
		return []
	if n["type"] == "rest" and n["floor"] >= 4 and n["floor"] <= 9:
		dead[n["id"]] = true
		return []
	if n["type"] == "boss":
		return [n]
	for nx in n["next"]:
		var sub := _dfs_no_rest(nodes, nodes[nx], dead)
		if not sub.is_empty():
			return [n] + sub
	dead[n["id"]] = true
	return []


func _guarantee(nodes: Array, t: String, min_f: int, max_f: int, rng: RandomNumberGenerator) -> void:
	for n in nodes:
		if n["type"] == t:
			return
	var cands := nodes.filter(func(n): return n["floor"] >= min_f and n["floor"] <= max_f and n["type"] in ["monster", "event"])
	if not cands.is_empty():
		cands[rng.randi_range(0, cands.size() - 1)]["type"] = t


## Places a node of type t on floors min_f..max_f unless one is already there.
func _guarantee_in(nodes: Array, t: String, min_f: int, max_f: int, rng: RandomNumberGenerator) -> void:
	for n in nodes:
		if n["type"] == t and n["floor"] >= min_f and n["floor"] <= max_f:
			return
	var cands := nodes.filter(func(n): return n["floor"] >= min_f and n["floor"] <= max_f and n["type"] in ["monster", "event"] \
		and not _touches_type(nodes, n, t))
	if not cands.is_empty():
		cands[rng.randi_range(0, cands.size() - 1)]["type"] = t


## Adds elites until the act has at least `count`, never next to another elite, preferring new lanes.
func _guarantee_elites(nodes: Array, count: int, rng: RandomNumberGenerator) -> void:
	var min_f := 4 if _act == 1 else 3
	var guard := 0
	while nodes.filter(func(n): return n["type"] == "elite").size() < count and guard < 20:
		guard += 1
		var lanes_used := {}
		for n in nodes:
			if n["type"] == "elite":
				lanes_used[n["lane"]] = true
		var cands := nodes.filter(func(n): return n["floor"] >= min_f and n["floor"] <= 10 and n["type"] in ["monster", "event"] \
			and not _touches_type(nodes, n, "elite"))
		if cands.is_empty():
			return
		var fresh := cands.filter(func(n): return not lanes_used.has(n["lane"]))
		var pool: Array = fresh if not fresh.is_empty() else cands
		pool[rng.randi_range(0, pool.size() - 1)]["type"] = "elite"


func _touches_type(nodes: Array, n: Dictionary, t: String) -> bool:
	for nx in n["next"]:
		if nodes[nx]["type"] == t:
			return true
	for p in parents_of(nodes, n["id"]):
		if p["type"] == t:
			return true
	return false


## No route should drag through more than MAX_MONSTER_STREAK plain fights in a row.
func _break_monster_streaks(nodes: Array) -> void:
	var order := nodes.duplicate()
	order.sort_custom(func(a, b): return a["floor"] < b["floor"])
	var streak := {}
	for n in order:
		var best := 0
		for p in parents_of(nodes, n["id"]):
			best = maxi(best, int(streak.get(p["id"], 0)))
		if n["type"] == "monster":
			if best >= MAX_MONSTER_STREAK and n["floor"] >= 2:
				n["type"] = "event"
				streak[n["id"]] = 0
			else:
				streak[n["id"]] = best + 1
		else:
			streak[n["id"]] = 0


func _roll_type(f: int, rng: RandomNumberGenerator) -> String:
	var table := [["monster", 44], ["event", 22]]
	if f >= (4 if _act == 1 else 3):
		table.append(["elite", 15 if _act == 1 else 18])
	if f >= 4:
		table.append(["rest", 11])
	if f >= 2:
		table.append(["shop", 8])
	var total := 0
	for t in table:
		total += t[1]
	var roll := rng.randi_range(1, total)
	for t in table:
		roll -= t[1]
		if roll <= 0:
			return t[0]
	return "monster"


func available_nodes(run: Dictionary) -> Array:
	var nodes: Array = run["map"]["nodes"]
	var cur: int = int(run["current_node"])
	if cur < 0:
		return nodes.filter(func(n): return n["floor"] == 0).map(func(n): return n["id"])
	return nodes[cur]["next"].duplicate()
