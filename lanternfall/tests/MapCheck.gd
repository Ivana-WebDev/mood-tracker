extends Node
## Generates many maps and reports how many rest sites the worst route passes.

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	var hist := {}
	var worst_mid := 99
	var maps := 400
	var total_rest := 0
	var total_nodes := 0
	for i in maps:
		rng.seed = 1000 + i
		var m: Dictionary = MapManager.generate(1 + i % 2, rng)
		var r := _min_rests(m["nodes"])
		total_rest += m["nodes"].filter(func(n): return n["type"] == "rest" and n["floor"] < 11).size()
		total_nodes += m["nodes"].size()
		hist[r] = hist.get(r, 0) + 1
	print("routes' minimum rest sites (incl. the pre-boss campfire) over %d maps: %s" % [maps, str(hist)])
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
