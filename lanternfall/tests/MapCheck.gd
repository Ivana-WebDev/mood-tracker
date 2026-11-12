extends Node
## Generates many maps and reports how many rest sites the worst route passes.

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	var hist := {}
	var worst_mid := 99
	var maps := 400
	var total_rest := 0
	var adjacent := 0
	var no_shop := 0
	var early := 0
	var total_nodes := 0
	for i in maps:
		rng.seed = 1000 + i
		var m: Dictionary = MapManager.generate(1 + i % 2, rng)
		var r := _min_rests(m["nodes"])
		if m["nodes"].filter(func(n): return n["type"] == "shop").is_empty():
			no_shop += 1
		for n in m["nodes"]:
			if n["type"] == "rest":
				if n["floor"] <= 2:
					early += 1
				for nx in n["next"]:
					if m["nodes"][nx]["type"] == "rest":
						adjacent += 1
		total_rest += m["nodes"].filter(func(n): return n["type"] == "rest" and n["floor"] < 11).size()
		total_nodes += m["nodes"].size()
		hist[r] = hist.get(r, 0) + 1
	print("routes' minimum rest sites (incl. the pre-boss campfire) over %d maps: %s" % [maps, str(hist)])
	print("rest next to rest: %d   rest in first 3 floors: %d   maps without a shop: %d" % [adjacent, early, no_shop])
	print("MAPCHECK ", "OK" if adjacent == 0 and early == 0 and no_shop == 0 and not hist.has(1) and not hist.has(0) else "FAILED")
	print("avg mid-act rest sites per map: %.1f of %.1f nodes" % [float(total_rest) / maps, float(total_nodes) / maps])
	get_tree().quit()


func _min_rests(nodes: Array) -> int:
	# DP over the DAG: fewest rests on any path from a floor-0 node to the boss.
	var best := {}
	var order := nodes.duplicate()
	order.sort_custom(func(a, b): return a["floor"] > b["floor"])
	for n in order:
		var here := 1 if n["type"] == "rest" else 0
		if n["next"].is_empty():
			best[n["id"]] = here
		else:
			var m := 999
			for nx in n["next"]:
				m = mini(m, best[nx])
			best[n["id"]] = here + m
	var res := 999
	for n in nodes:
		if n["floor"] == 0:
			res = mini(res, best[n["id"]])
	return res
