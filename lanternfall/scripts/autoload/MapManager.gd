extends Node
## Generates branching node maps. Floors run left -> right (landscape layout).

const FLOORS := 12 # regular floors (0..11); boss sits on floor 12
const LANES := 7
const PATHS := 6
const TREASURE_FLOOR := 6


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
	# Make sure there is at least one shop and one elite per act.
	_guarantee(nodes, "shop", 3, 9, rng)
	_guarantee(nodes, "elite", 5, 10, rng)


func _guarantee(nodes: Array, t: String, min_f: int, max_f: int, rng: RandomNumberGenerator) -> void:
	for n in nodes:
		if n["type"] == t:
			return
	var cands := nodes.filter(func(n): return n["floor"] >= min_f and n["floor"] <= max_f and n["type"] in ["monster", "event"])
	if not cands.is_empty():
		cands[rng.randi_range(0, cands.size() - 1)]["type"] = t


func _roll_type(f: int, rng: RandomNumberGenerator) -> String:
	var table := [["monster", 46], ["event", 22]]
	if f >= 4:
		table.append(["elite", 13])
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
