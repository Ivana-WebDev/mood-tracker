extends Node
## Run state + high level flow between screens.
##
## Screens: menu, char_select, map, combat, reward, rest, shop, event, treasure, game_over, victory.
## Every node visit stores a "pending" record so a quit / app kill resumes at the right place.

signal screen_requested(screen: String, params: Dictionary)
signal run_changed

const ACTS := 2

var run: Dictionary = {}
var rng := RandomNumberGenerator.new()


func has_run() -> bool:
	return not run.is_empty()


func new_uid() -> int:
	var uid: int = int(run.get("next_uid", 1))
	run["next_uid"] = uid + 1
	return uid


# ------------------------------------------------------------------ run lifecycle

func new_run(character_id: String, run_seed: int = 0) -> void:
	var ch: Dictionary = CharacterDatabase.get_character(character_id)
	if run_seed == 0:
		run_seed = int(Time.get_unix_time_from_system() * 1000.0) ^ randi()
	rng.seed = run_seed
	run = {
		"character": character_id,
		"hp": int(ch["hp"]), "max_hp": int(ch["hp"]), "gold": int(ch["gold"]),
		"deck": [], "relics": [], "relic_flags": {},
		"act": 1, "floor": 0, "map": {}, "current_node": -1,
		"next_uid": 1, "remove_cost": 75, "fights": 0, "last_encounter": "",
		"seen_events": [], "potions": [],
		"stats": {"floors": 0, "kills": 0, "elites": 0, "bosses": 0, "gold_earned": 0, "cards_played": 0},
		"pending": {},
	}
	for id in ch["deck"]:
		run["deck"].append({"uid": new_uid(), "id": id, "upgraded": false})
	RelicManager.add_relic(ch["relic"])
	run["map"] = MapManager.generate(1, rng)
	SaveManager.save_run()
	goto("map")


func continue_run() -> bool:
	if not SaveManager.load_run():
		return false
	resume_pending()
	return true


func abandon_run() -> void:
	if has_run():
		SaveManager.record_run_end(false)
	SaveManager.clear_run()
	run = {}
	goto("menu")


func goto(screen: String, params: Dictionary = {}) -> void:
	screen_requested.emit(screen, params)


func resume_pending() -> void:
	var p: Dictionary = run.get("pending", {})
	if p.is_empty():
		goto("map")
		return
	match p.get("type", ""):
		"combat": goto("combat", p)
		"reward": goto("reward", p)
		"rest": goto("rest", p)
		"shop": goto("shop", p)
		"event": goto("event", p)
		"treasure": goto("treasure", p)
		_: goto("map")


func set_pending(p: Dictionary) -> void:
	run["pending"] = p
	SaveManager.save_run()


func clear_pending() -> void:
	run["pending"] = {}
	SaveManager.save_run()


# ------------------------------------------------------------------ map navigation

func enter_node(node_id: int) -> void:
	if not MapManager.available_nodes(run).has(node_id):
		return
	AudioManager.play("select")
	var node: Dictionary = run["map"]["nodes"][node_id]
	node["visited"] = true
	run["current_node"] = node_id
	run["floor"] = int(node["floor"]) + 1
	run["stats"]["floors"] = int(run["stats"]["floors"]) + 1
	match node["type"]:
		"monster", "elite", "boss":
			var p := {"type": "combat", "kind": node["type"], "enemies": _pick_encounter(node["type"])}
			set_pending(p)
			goto("combat", p)
		"rest":
			var p2 := {"type": "rest"}
			set_pending(p2)
			goto("rest", p2)
		"shop":
			var p3 := {"type": "shop", "stock": _make_shop_stock()}
			set_pending(p3)
			goto("shop", p3)
		"event":
			var p4 := {"type": "event", "event": _pick_event()}
			set_pending(p4)
			goto("event", p4)
		"treasure":
			var p5 := {"type": "treasure", "gold": rng.randi_range(30, 55), "relic": RelicManager.roll_relic(_roll_relic_rarity()), "opened": false}
			set_pending(p5)
			goto("treasure", p5)
	run_changed.emit()


func node_done() -> void:
	clear_pending()
	goto("map")


func _pick_encounter(kind: String) -> Array:
	var act: int = int(run["act"])
	var table: Dictionary = EnemyDatabase.ENCOUNTERS[act]
	var key := kind
	if kind == "monster":
		key = "easy" if int(run["fights"]) < 2 else "hard"
		run["fights"] = int(run["fights"]) + 1
	var options: Array = table[key]
	var pick: Array = options[rng.randi_range(0, options.size() - 1)]
	if options.size() > 1:
		for i in 4:
			if ",".join(pick) != run["last_encounter"]:
				break
			pick = options[rng.randi_range(0, options.size() - 1)]
	run["last_encounter"] = ",".join(pick)
	return pick


func _pick_event() -> String:
	var ids: Array = EventDatabase.EVENTS.keys().filter(func(k): return not run["seen_events"].has(k))
	if ids.is_empty():
		run["seen_events"].clear()
		ids = EventDatabase.EVENTS.keys()
	var id: String = ids[rng.randi_range(0, ids.size() - 1)]
	run["seen_events"].append(id)
	return id


func _roll_relic_rarity() -> String:
	var r := rng.randf()
	if r < 0.55:
		return "common"
	if r < 0.88:
		return "uncommon"
	return "rare"


# ------------------------------------------------------------------ combat results

func on_combat_won(kind: String, hp_left: int) -> void:
	run["hp"] = clampi(hp_left, 1, int(run["max_hp"]))
	var gold := 0
	match kind:
		"monster": gold = rng.randi_range(12, 20)
		"elite": gold = rng.randi_range(28, 38)
		"boss": gold = rng.randi_range(90, 110)
	gold = int(round(gold * RelicManager.gold_multiplier()))
	var reward := {"type": "reward", "kind": kind, "gold": gold, "gold_taken": false,
		"cards": roll_card_rewards(kind), "card_taken": false, "relic": "", "relic_taken": false, "boss_relics": []}
	# Potions are an occasional bonus: 30% after normal fights, 45% after elites, none from bosses,
	# and the chance halves right after a fight that already dropped one.
	var potion_chance: float = {"monster": 0.30, "elite": 0.45, "boss": 0.0}.get(kind, 0.3)
	if run.get("last_fight_potion", false):
		potion_chance *= 0.5
	reward["potion"] = roll_potion() if rng.randf() < potion_chance else ""
	run["last_fight_potion"] = reward["potion"] != ""
	reward["potion_taken"] = false
	if kind == "elite":
		reward["relic"] = RelicManager.roll_relic(_roll_relic_rarity())
		run["stats"]["elites"] = int(run["stats"]["elites"]) + 1
	if kind == "boss":
		run["stats"]["bosses"] = int(run["stats"]["bosses"]) + 1
		if int(run["act"]) < ACTS:
			var picks: Array = []
			for i in 3:
				var r := RelicManager.roll_relic("boss", picks)
				if r != "" and RelicDatabase.get_relic(r)["rarity"] == "boss":
					picks.append(r)
			reward["boss_relics"] = picks
	set_pending(reward)
	goto("reward", reward)


func on_combat_lost() -> void:
	run["hp"] = 0
	SaveManager.record_run_end(false)
	var summary := run.duplicate(true)
	SaveManager.clear_run()
	goto("game_over", {"run": summary})


func finish_reward() -> void:
	var p: Dictionary = run.get("pending", {})
	if p.get("kind", "") == "boss":
		if int(run["act"]) >= ACTS:
			SaveManager.record_run_end(true)
			var summary := run.duplicate(true)
			SaveManager.clear_run()
			goto("victory", {"run": summary})
			return
		_advance_act()
		return
	node_done()


func _advance_act() -> void:
	run["act"] = int(run["act"]) + 1
	run["fights"] = 0
	run["current_node"] = -1
	# Reaching a new act restores most of your strength.
	var missing: int = int(run["max_hp"]) - int(run["hp"])
	run["hp"] = int(run["hp"]) + int(ceil(missing * 0.75))
	run["map"] = MapManager.generate(int(run["act"]), rng)
	run_changed.emit()
	node_done()


# ------------------------------------------------------------------ rewards / economy

func roll_card_rewards(kind: String, count: int = 3) -> Array:
	var weights := {"common": 60, "uncommon": 34, "rare": 6}
	if kind == "elite":
		weights = {"common": 40, "uncommon": 42, "rare": 18}
	elif kind == "boss" or kind == "rare":
		weights = {"common": 0, "uncommon": 0, "rare": 100}
	var picks: Array = []
	var guard := 0
	while picks.size() < count and guard < 100:
		guard += 1
		var rarity := _weighted(weights)
		var id := _roll_card_of(rarity)
		if id == "" or picks.any(func(c): return c["id"] == id):
			continue
		var upgraded := int(run["act"]) >= 2 and rng.randf() < 0.15
		picks.append({"id": id, "upgraded": upgraded})
	return picks


func _roll_card_of(rarity: String) -> String:
	var ch: String = run["character"]
	# Every card in a hero's reward pool belongs to that hero; nothing is shared.
	var pool: Array = CardDatabase.pool(ch, rarity)
	if pool.is_empty():
		pool = CardDatabase.pool(ch, "common")
	return pool[rng.randi_range(0, pool.size() - 1)]


func _weighted(w: Dictionary) -> String:
	var total := 0
	for k in w:
		total += int(w[k])
	var roll := rng.randi_range(1, maxi(1, total))
	for k in w:
		roll -= int(w[k])
		if roll <= 0:
			return k
	return w.keys()[0]


func card_price(rarity: String) -> int:
	var base := {"common": 50, "uncommon": 78, "rare": 150}.get(rarity, 60) as int
	return int(round(base * rng.randf_range(0.9, 1.1) * RelicManager.price_multiplier()))


func relic_price(rarity: String) -> int:
	var base := {"common": 145, "uncommon": 210, "rare": 290, "shop": 160}.get(rarity, 180) as int
	return int(round(base * rng.randf_range(0.92, 1.08) * RelicManager.price_multiplier()))


func _make_shop_stock() -> Dictionary:
	var cards: Array = []
	for rarity in ["common", "common", "common", "uncommon", "uncommon", "rare"]:
		for attempt in 10:
			var id := CardDatabase.pool(run["character"], rarity)
			var pick: String = id[rng.randi_range(0, id.size() - 1)]
			if not cards.any(func(c): return c["id"] == pick):
				cards.append({"id": pick, "upgraded": false, "price": card_price(rarity), "sold": false})
				break
	var relics: Array = []
	var taken: Array = []
	for rarity in ["common", "uncommon", "rare"]:
		var r := RelicManager.roll_relic(rarity, taken)
		if r != "":
			taken.append(r)
			relics.append({"id": r, "price": relic_price(RelicDatabase.get_relic(r)["rarity"]), "sold": false})
	var potions: Array = []
	var seen: Array = []
	for i in 3:
		var pid := roll_potion(seen)
		seen.append(pid)
		potions.append({"id": pid, "price": int(round(PotionDatabase.price(PotionDatabase.get_potion(pid)["rarity"]) * rng.randf_range(0.9, 1.1) * RelicManager.price_multiplier())), "sold": false})
	return {"cards": cards, "relics": relics, "potions": potions, "removed": false}


# ------------------------------------------------------------------ potions

func potions() -> Array:
	if not run.has("potions"):
		run["potions"] = []
	return run["potions"]


func potion_slots_free() -> bool:
	return potions().size() < PotionDatabase.MAX_SLOTS


func roll_potion(exclude: Array = []) -> String:
	var ch: String = run.get("character", "")
	var rarity := _weighted({"common": 64, "uncommon": 29, "rare": 7})
	var pool := PotionDatabase.pool(ch, rarity).filter(func(x): return not exclude.has(x))
	if pool.is_empty():
		# Fall back to any rarity that still has an unused potion.
		for r in ["common", "uncommon", "rare"]:
			pool = PotionDatabase.pool(ch, r).filter(func(x): return not exclude.has(x))
			if not pool.is_empty():
				break
	return pool[rng.randi_range(0, pool.size() - 1)]


func add_potion(id: String) -> bool:
	if id == "" or not potion_slots_free():
		return false
	potions().append(id)
	AudioManager.play("potion", -4.0)
	run_changed.emit()
	return true


func discard_potion(index: int) -> void:
	if index >= 0 and index < potions().size():
		potions().remove_at(index)
		SaveManager.save_run()
		run_changed.emit()


## Outside combat only potions flagged "anywhere" (healing) can be drunk.
func use_potion_outside_combat(index: int) -> bool:
	if index < 0 or index >= potions().size():
		return false
	var p := PotionDatabase.get_potion(potions()[index])
	if not p.get("anywhere", false):
		return false
	for e in p["effects"]:
		if e["type"] == "heal":
			change_hp(int(e["value"]))
	AudioManager.play("heal")
	potions().remove_at(index)
	SaveManager.save_run()
	run_changed.emit()
	return true


# ------------------------------------------------------------------ deck + stats mutations

func add_card(id: String, upgraded: bool = false) -> void:
	AudioManager.play("card", -3.0)
	run["deck"].append({"uid": new_uid(), "id": id, "upgraded": upgraded})
	run_changed.emit()


func remove_card(uid: int) -> void:
	var deck: Array = run["deck"]
	for i in deck.size():
		if int(deck[i]["uid"]) == uid:
			deck.remove_at(i)
			break
	run_changed.emit()


func upgrade_card(uid: int) -> void:
	AudioManager.play("buff")
	for c in run["deck"]:
		if int(c["uid"]) == uid and CardDatabase.can_upgrade(c["id"]):
			c["upgraded"] = true
	run_changed.emit()


func upgradable_cards() -> Array:
	return run["deck"].filter(func(c): return not c["upgraded"] and CardDatabase.can_upgrade(c["id"]))


func add_gold(amount: int) -> void:
	run["gold"] = maxi(0, int(run["gold"]) + amount)
	if amount > 0:
		run["stats"]["gold_earned"] = int(run["stats"]["gold_earned"]) + amount
		AudioManager.play("gold")
	run_changed.emit()


func change_hp(amount: int) -> void:
	# Out-of-combat HP loss never kills outright.
	run["hp"] = clampi(int(run["hp"]) + amount, 1, int(run["max_hp"]))
	run_changed.emit()


func change_max_hp(amount: int) -> void:
	run["max_hp"] = maxi(1, int(run["max_hp"]) + amount)
	if amount > 0:
		run["hp"] = int(run["hp"]) + amount
	run["hp"] = mini(int(run["hp"]), int(run["max_hp"]))
	run_changed.emit()
