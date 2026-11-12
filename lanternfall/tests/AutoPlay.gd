extends Node
## Headless simulation: plays full runs with a simple bot to validate game logic.
## Run: godot --headless --path . res://tests/AutoPlay.tscn

const RUNS_PER_HERO := 12

var results := {}
var _potions_total := 0
var failures_logic := 0


func _ready() -> void:
	var failures := 0
	for ch in CharacterDatabase.ORDER:
		results[ch] = {"wins": 0, "floors": [], "acts": []}
		for i in RUNS_PER_HERO:
			var r: Dictionary = await _play_run(ch, 1000 + i * 7919)
			if r.get("error", "") != "":
				failures += 1
				print("ERROR ", ch, " seed ", i, ": ", r["error"])
			if r["won"]:
				results[ch]["wins"] += 1
			results[ch]["floors"].append(r["floor"])
			results[ch]["acts"].append(r["act"])
	for ch in results:
		var fl: Array = results[ch]["floors"]
		var avg := 0.0
		for f in fl:
			avg += f
		avg /= fl.size()
		print("%-9s wins %d/%d  avg floor %.1f  acts %s" % [ch, results[ch]["wins"], RUNS_PER_HERO, avg, str(results[ch]["acts"])])
	_test_save_roundtrip()
	_test_shop_potions()
	print("potions drunk across all runs: %d" % _potions_total)
	failures += failures_logic
	print("AUTOPLAY DONE failures=%d" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _test_save_roundtrip() -> void:
	GameManager.new_run("fatebinder", 42)
	GameManager.add_card("f_all_in", true)
	var before: Dictionary = GameManager.run.duplicate(true)
	var state_before := GameManager.rng.state
	SaveManager.save_run()
	GameManager.run = {}
	assert(SaveManager.load_run())
	var ok: bool = GameManager.run["deck"].size() == before["deck"].size() and GameManager.rng.state == state_before
	ok = ok and GameManager.run["map"]["nodes"].size() == before["map"]["nodes"].size()
	ok = ok and typeof(GameManager.run["deck"][0]["uid"]) == TYPE_INT
	print("SAVE ROUNDTRIP ", "OK" if ok else "FAILED")
	SaveManager.clear_run()


func _play_run(ch: String, run_seed: int) -> Dictionary:
	GameManager.new_run(ch, run_seed)
	var run := GameManager.run
	var guard := 0
	while guard < 200:
		guard += 1
		var avail: Array = MapManager.available_nodes(GameManager.run)
		if avail.is_empty():
			return {"won": false, "floor": run["floor"], "act": run["act"], "error": "no available nodes"}
		var pick: int = _choose_node(avail)
		GameManager.enter_node(pick)
		var p: Dictionary = GameManager.run["pending"]
		match p["type"]:
			"combat":
				var won: bool = await _fight(p)
				if not won:
					var floor_reached: int = GameManager.run["floor"]
					var act: int = GameManager.run["act"]
					if OS.get_cmdline_user_args().has("--verbose"):
						print("  died: %s act %d floor %d vs %s deck %d relics %s" % [ch, act, floor_reached, str(p["enemies"]), GameManager.run["deck"].size(), str(GameManager.run["relics"])])
					GameManager.on_combat_lost()
					return {"won": false, "floor": floor_reached, "act": act}
				var act_before: int = GameManager.run["act"]
				var kind: String = p["kind"]
				_claim_rewards()
				if kind == "boss" and act_before == GameManager.ACTS:
					GameManager.finish_reward()
					return {"won": true, "floor": run["floor"], "act": act_before}
				GameManager.finish_reward()
			"rest":
				if float(GameManager.run["hp"]) / GameManager.run["max_hp"] < 0.65 or GameManager.upgradable_cards().is_empty():
					GameManager.change_hp(int(ceil(GameManager.run["max_hp"] * 0.3)))
				else:
					GameManager.upgrade_card(int(GameManager.upgradable_cards()[0]["uid"]))
				GameManager.node_done()
			"shop":
				var stock: Dictionary = p["stock"]
				for item in stock["cards"]:
					if int(GameManager.run["gold"]) >= int(item["price"]) and CardDatabase.CARDS[item["id"]]["rarity"] != "common":
						GameManager.add_gold(-int(item["price"]))
						GameManager.add_card(item["id"])
						item["sold"] = true
				for r in stock["relics"]:
					if int(GameManager.run["gold"]) >= int(r["price"]):
						GameManager.add_gold(-int(r["price"]))
						RelicManager.add_relic(r["id"])
				# remove a starter attack
				for c in GameManager.run["deck"]:
					if CardDatabase.CARDS[c["id"]]["rarity"] == "starter" and int(GameManager.run["gold"]) >= 75:
						GameManager.add_gold(-75)
						GameManager.remove_card(int(c["uid"]))
						break
				GameManager.node_done()
			"event":
				var ev: Dictionary = EventDatabase.EVENTS[p["event"]]
				for e in ev["options"][0]["effects"]:
					match e["type"]:
						"gold": GameManager.add_gold(int(e["value"]))
						"hp": GameManager.change_hp(int(e["value"]))
						"max_hp": GameManager.change_max_hp(int(e["value"]))
						"relic": RelicManager.add_relic(RelicManager.roll_relic(e["value"]))
						"add_curse": GameManager.add_card(e["value"])
				GameManager.node_done()
			"treasure":
				GameManager.add_gold(int(p["gold"]))
				RelicManager.add_relic(p["relic"])
				GameManager.node_done()
	return {"won": false, "floor": run["floor"], "act": run["act"], "error": "guard exceeded"}


func _choose_node(avail: Array) -> int:
	var nodes: Array = GameManager.run["map"]["nodes"]
	var hp_frac := float(GameManager.run["hp"]) / float(GameManager.run["max_hp"])
	var best: int = avail[0]
	var best_score := -999.0
	for id in avail:
		var t: String = nodes[id]["type"]
		var s := GameManager.rng.randf()
		match t:
			"rest": s += 3.0 if hp_frac < 0.5 else 0.5
			"elite": s += 1.5 if hp_frac > 0.75 else -2.0
			"treasure": s += 2.0
			"shop": s += 1.0 if int(GameManager.run["gold"]) > 150 else 0.0
		if s > best_score:
			best_score = s
			best = id
	return best


func _claim_rewards() -> void:
	var p: Dictionary = GameManager.run["pending"]
	GameManager.add_gold(int(p["gold"]))
	if not p["cards"].is_empty():
		# Prefer the rarest offered card.
		var order := {"rare": 0, "uncommon": 1, "common": 2}
		var cards: Array = p["cards"].duplicate()
		cards.sort_custom(func(a, b): return order.get(CardDatabase.CARDS[a["id"]]["rarity"], 3) < order.get(CardDatabase.CARDS[b["id"]]["rarity"], 3))
		GameManager.add_card(cards[0]["id"], cards[0]["upgraded"])
	if p.get("potion", "") != "":
		GameManager.add_potion(p["potion"])
	if p["relic"] != "":
		RelicManager.add_relic(p["relic"])
	if not p["boss_relics"].is_empty():
		RelicManager.add_relic(p["boss_relics"][0])


func _fight(p: Dictionary) -> bool:
	var cm := CombatManager.new()
	cm.fast_mode = true
	add_child(cm)
	cm.setup(p["enemies"], p["kind"])
	cm.start()
	var turns := 0
	while cm.phase != "over" and turns < 60:
		turns += 1
		# Drink potions in hard fights or when low.
		if cm.phase == "player" and (p["kind"] != "monster" or cm.player.hp < cm.player.max_hp * 0.4):
			while not GameManager.potions().is_empty() and cm.phase == "player":
				var alive := cm.alive_enemies()
				if not cm.use_potion(0, alive[0] if not alive.is_empty() else null):
					GameManager.discard_potion(0)
		var safety := 0
		while cm.phase == "player" and safety < 40:
			safety += 1
			var played := false
			var hand: Array = cm.deck.hand.duplicate()
			hand.sort_custom(func(a, b): return _priority(cm, a) > _priority(cm, b))
			for c in hand:
				if cm.can_play(c):
					var target: Combatant = null
					if cm.needs_target(c):
						var alive := cm.alive_enemies()
						if alive.is_empty():
							failures_logic += 1
							print("ERROR: all enemies dead but combat still in player phase")
							break
						alive.sort_custom(func(x, y): return x.hp < y.hp)
						target = alive[0]
					if cm.play_card(c, target):
						played = true
						break
			if not played:
				break
		if cm.phase == "player":
			await cm.end_player_turn()
	_potions_total += int(GameManager.run["stats"].get("potions", 0))
	GameManager.run["stats"]["potions"] = 0
	var won := cm.phase == "over" and cm.player.hp > 0
	if won:
		GameManager.on_combat_won(p["kind"], cm.player.hp)
	cm.queue_free()
	return won


func _priority(cm: CombatManager, c: Dictionary) -> float:
	var d := cm.card_def(c)
	var incoming := 0
	for e in cm.alive_enemies():
		var info := cm.intent_info(e)
		incoming += int(info["damage"]) * maxi(1, int(info["times"]))
	var score := 0.0
	match d["type"]:
		"power": score = 10.0
		"attack": score = 5.0
		"skill": score = 6.0 if incoming > cm.player.block else 2.0
	if int(d["cost"]) == 0:
		score += 3.0
	if cm.mechanic == "flow" and d["type"] != cm.last_type:
		score += 4.0
	return score


func _test_shop_potions() -> void:
	var dupes := 0
	for ch in CharacterDatabase.ORDER:
		GameManager.new_run(ch, 500)
		for i in 200:
			var ids: Array = GameManager._make_shop_stock()["potions"].map(func(p): return p["id"])
			for id in ids:
				if ids.count(id) > 1:
					dupes += 1
	print("SHOP POTIONS ", "OK (no duplicates in 600 shops)" if dupes == 0 else "FAILED: %d duplicates" % dupes)
	SaveManager.clear_run()
