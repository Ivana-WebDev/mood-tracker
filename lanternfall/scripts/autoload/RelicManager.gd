extends Node
## Owns relic behaviour. Relic ids live in GameManager.run["relics"].

signal relic_triggered(id: String)
signal relics_changed


func relics() -> Array:
	return GameManager.run.get("relics", [])


func has(id: String) -> bool:
	return relics().has(id)


func add_relic(id: String) -> void:
	if id == "" or has(id):
		return
	GameManager.run["relics"].append(id)
	_on_pickup(id)
	relics_changed.emit()
	GameManager.run_changed.emit()


func owned_or_unavailable() -> Array:
	return relics().duplicate()


## Picks a random relic of the given rarity the player does not own (falls back to other rarities).
func roll_relic(rarity: String, exclude: Array = []) -> String:
	var order := [rarity, "common", "uncommon", "rare"]
	for r in order:
		var pool := RelicDatabase.pool(r).filter(func(x): return not has(x) and not exclude.has(x))
		if not pool.is_empty():
			return pool[GameManager.rng.randi_range(0, pool.size() - 1)]
	return ""


func _trigger(id: String) -> void:
	relic_triggered.emit(id)


func _on_pickup(id: String) -> void:
	var run: Dictionary = GameManager.run
	match id:
		"vital_stone":
			run["max_hp"] += 10
			run["hp"] += 10
		"titan_belt":
			run["max_hp"] += 25
			run["hp"] += 25


# ------------------------------------------------------------------ combat hooks

func on_combat_start(cm: CombatManager) -> void:
	cm.counters = {"cards": 0}
	for id in relics():
		match id:
			"mainspring":
				cm.deploy_gadget("turret", 3, 3); _trigger(id)
			"silver_bell":
				cm.apply_status(cm.player, "flow", 2); _trigger(id)
			"oak_buckler":
				cm.gain_block(cm.player, 7); _trigger(id)
			"whetstone":
				cm.apply_status(cm.player, "strength", 1); _trigger(id)
			"titan_belt":
				cm.apply_status(cm.player, "strength", 2); _trigger(id)
			"thorn_ring":
				cm.apply_status(cm.player, "thorns", 3); _trigger(id)
			"serpent_fang":
				for e in cm.alive_enemies():
					cm.apply_status(e, "weak", 1)
					cm.apply_status(e, "vulnerable", 1)
				_trigger(id)


func on_turn_start(cm: CombatManager) -> void:
	for id in relics():
		match id:
			"bronze_spurs":
				if cm.turn == 1:
					cm.energy += 1; _trigger(id)
			"war_banner":
				if cm.turn == 3:
					cm.apply_status(cm.player, "strength", 2)
					cm.energy += 1
					_trigger(id)


func on_turn_end(cm: CombatManager) -> void:
	if has("jade_turtle") and cm.player.block == 0:
		cm.gain_block(cm.player, 6)
		_trigger("jade_turtle")


func on_card_played(cm: CombatManager, _card: Dictionary) -> void:
	cm.counters["cards"] = int(cm.counters.get("cards", 0)) + 1
	if has("battle_drum") and cm.counters["cards"] % 4 == 0:
		cm.draw_cards(1)
		_trigger("battle_drum")


func on_enemy_died(cm: CombatManager, _enemy: Combatant) -> void:
	if has("blood_vial") and cm.player.is_alive():
		cm.heal(cm.player, 3)
		_trigger("blood_vial")


func on_combat_end(cm: CombatManager) -> void:
	if has("healing_herb"):
		cm.heal(cm.player, 5)
		_trigger("healing_herb")


func modify_player_damage(amount: int) -> int:
	if has("dragon_scale"):
		_trigger("dragon_scale")
		return maxi(0, amount - 1)
	return amount


func try_prevent_death(cm: CombatManager) -> bool:
	var flags: Dictionary = GameManager.run["relic_flags"]
	if has("phoenix_feather") and not flags.get("phoenix_used", false):
		flags["phoenix_used"] = true
		cm.player.hp = maxi(1, int(cm.player.max_hp * 0.4))
		cm.floating_text.emit(cm.player, "Reborn!", Palette.GOLD)
		_trigger("phoenix_feather")
		return true
	return false


# ------------------------------------------------------------------ passive modifiers

func bonus_energy() -> int:
	return 1 if has("lantern_heart") else 0


func bonus_draw() -> int:
	return 1 if has("twin_crown") else 0


func gold_multiplier() -> float:
	return 1.3 if has("coin_pouch") else 1.0


func price_multiplier() -> float:
	return 0.75 if has("merchant_scale") else 1.0
