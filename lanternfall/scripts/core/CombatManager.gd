class_name CombatManager
extends Node
## Turn-based combat rules. Pure game logic; UI listens to signals.

signal hand_changed
signal state_changed
signal floating_text(who: Combatant, text: String, color: Color)
signal attacked(who: Combatant)
signal was_hit(who: Combatant)
signal enemy_died(who: Combatant)
signal turn_started(turn: int)
signal enemy_turn_started
signal enemy_acting(who: Combatant, move_name: String)
signal combat_ended(victory: bool)
signal gadgets_changed
signal gadget_fired(index: int)
signal dice_changed
signal flow_broken

const MAX_GADGETS := 3
const MAX_DICE := 8

const BASE_ENERGY := 3
const BASE_DRAW := 5

var player: Combatant
var enemies: Array = []
var deck: DeckManager
var rng: RandomNumberGenerator
var energy: int = 0
var max_energy: int = BASE_ENERGY
var turn: int = 0
var phase: String = "setup" # setup | player | enemy | over
var cards_played_turn: int = 0
var cards_played_total: int = 0
var encounter_type: String = "monster"
var counters: Dictionary = {}
## Hero mechanic: "gadgets" | "dice" | "flow"
var mechanic: String = ""
var gadgets: Array = []   # [{kind, power, turns}]
var dice: Array = []      # [int]
var last_type: String = ""
## When true no timers are awaited (used by automated tests / fast combat).
var fast_mode: bool = false
## Multiplier for animation pacing (0.5 = fast combat setting).
var speed: float = 1.0


func setup(enemy_ids: Array, kind: String) -> void:
	rng = GameManager.rng
	encounter_type = kind
	var run: Dictionary = GameManager.run
	player = Combatant.new()
	player.is_player = true
	player.display_name = CharacterDatabase.get_character(run["character"])["name"]
	player.max_hp = int(run["max_hp"])
	player.hp = int(run["hp"])
	mechanic = CharacterDatabase.mechanic(run["character"])
	deck = DeckManager.new()
	deck.setup(run["deck"], rng)
	enemies.clear()
	for i in enemy_ids.size():
		enemies.append(Combatant.make_enemy(enemy_ids[i], rng, i))
	for e in enemies:
		_choose_intent(e)


func start() -> void:
	RelicManager.on_combat_start(self)
	start_player_turn()


# ------------------------------------------------------------------ queries

func alive_enemies() -> Array:
	return enemies.filter(func(e): return e.is_alive())


func calc_damage(base: int, src: Combatant, dst: Combatant) -> int:
	var d := float(base + src.get_status("strength"))
	if src.is_player:
		d += flow_bonus()
	if src.get_status("weak") > 0:
		d *= 0.75
	if dst != null and dst.get_status("vulnerable") > 0:
		d *= 1.5
	return maxi(0, int(floor(d)))


func preview_damage(base: int, target) -> int:
	return calc_damage(base, player, target)


func preview_block(base: int) -> int:
	return maxi(0, base + player.get_status("dexterity") + flow_bonus())


func flow_bonus() -> int:
	return player.get_status("flow") * (2 if player.get_status("spotlight") > 0 else 1)


func count_of(what: String) -> int:
	if what == "gadgets":
		return gadgets.size()
	return player.get_status(what)


func card_def(inst: Dictionary) -> Dictionary:
	return CardDatabase.resolve(inst["id"], inst.get("upgraded", false))


func can_play(inst: Dictionary) -> bool:
	if phase != "player":
		return false
	var c := card_def(inst)
	if c.is_empty() or c.get("unplayable", false):
		return false
	return int(c["cost"]) <= energy


func needs_target(inst: Dictionary) -> bool:
	return card_def(inst).get("target", "none") == "enemy"


## Summarises an enemy's upcoming move for the intent icon.
func intent_info(e: Combatant) -> Dictionary:
	var info := {"kinds": [], "damage": 0, "times": 0, "name": e.intent.get("name", "")}
	for eff in e.intent.get("effects", []):
		var self_target: bool = eff.get("target", "player") == "self"
		match eff["type"]:
			"damage":
				info["damage"] = calc_damage(int(eff["value"]), e, player)
				info["times"] = int(eff.get("times", 1))
				if not "attack" in info["kinds"]:
					info["kinds"].append("attack")
			"block":
				if not "defend" in info["kinds"]:
					info["kinds"].append("defend")
			"apply", "heal":
				var k := "buff" if self_target else "debuff"
				if not k in info["kinds"]:
					info["kinds"].append(k)
			"add_card":
				if not "debuff" in info["kinds"]:
					info["kinds"].append("debuff")
	return info


# ------------------------------------------------------------------ player actions

func play_card(inst: Dictionary, target: Combatant = null) -> bool:
	if not can_play(inst):
		return false
	var c := card_def(inst)
	if c["target"] == "enemy":
		if target == null or not target.is_alive():
			var alive := alive_enemies()
			if alive.size() == 1:
				target = alive[0]
			else:
				return false
	energy -= int(c["cost"])
	deck.remove_from_hand(inst)
	cards_played_turn += 1
	cards_played_total += 1
	GameManager.run["stats"]["cards_played"] = int(GameManager.run["stats"].get("cards_played", 0)) + 1
	_resolve_card(c, target)
	if mechanic == "flow" and phase != "over":
		_update_flow(c["type"])
	if c["type"] == "power":
		pass # Powers leave play permanently.
	elif c.get("exhaust", false):
		deck.exhaust_pile.append(inst)
	else:
		deck.discard_pile.append(inst)
	if phase != "over":
		RelicManager.on_card_played(self, c)
	hand_changed.emit()
	state_changed.emit()
	return true


func end_player_turn() -> void:
	if phase != "player":
		return
	phase = "enemy"
	var b := player.get_status("bulwark")
	if b > 0:
		gain_block(player, b)
	RelicManager.on_turn_end(self)
	_end_of_turn_status(player)
	for c in deck.hand:
		if c["id"] == "x_doubt":
			player.add_status("weak", 1)
	deck.discard_hand()
	hand_changed.emit()
	state_changed.emit()
	if not gadgets.is_empty():
		await _wait(0.2)
		await _fire_gadgets_end_of_turn()
		if phase == "over":
			return
	await _enemy_turn()
	if phase == "over":
		return
	start_player_turn()


func start_player_turn() -> void:
	if phase == "over":
		return
	turn += 1
	cards_played_turn = 0
	if turn > 1 and player.get_status("steadfast") == 0:
		player.block = 0
	var bleed := player.get_status("bleed")
	if bleed > 0:
		lose_hp(player, bleed, Palette.HP)
		player.add_status("bleed", -1)
		if phase == "over":
			return
	max_energy = BASE_ENERGY + RelicManager.bonus_energy() + player.get_status("ley")
	energy = max_energy
	var rhythm := player.get_status("rhythm")
	if rhythm > 0:
		apply_status(player, "flow", rhythm)
	if mechanic == "dice":
		dice.clear()
		for i in 3 + player.get_status("extra_die"):
			dice.append(roll_die())
		dice_changed.emit()
	for i in player.get_status("factory"):
		deploy_gadget("turret", 2, 2)
	draw_cards(BASE_DRAW + RelicManager.bonus_draw())
	RelicManager.on_turn_start(self)
	phase = "player"
	turn_started.emit(turn)
	hand_changed.emit()
	state_changed.emit()


# ------------------------------------------------------------------ effect primitives

func make_card(id: String, upgraded: bool = false) -> Dictionary:
	return {"uid": GameManager.new_uid(), "id": id, "upgraded": upgraded}


func draw_cards(n: int) -> void:
	if n <= 0:
		return
	deck.draw(n)
	hand_changed.emit()


func gain_block(c: Combatant, amount: int) -> void:
	if amount <= 0:
		return
	c.block += amount
	floating_text.emit(c, "+%d" % amount, Palette.BLOCK)
	state_changed.emit()


func apply_status(c: Combatant, status: String, amount: int) -> void:
	if c == null or not c.is_alive() or amount == 0:
		return
	if status == "flow":
		amount = mini(amount, CardDatabase.FLOW_MAX - c.get_status("flow"))
		if amount <= 0:
			return
	c.add_status(status, amount)
	var info: Dictionary = CardDatabase.STATUS_INFO.get(status, {"buff": true})
	floating_text.emit(c, "%s %+d" % [CardDatabase.status_name(status), amount], Palette.BUFF if info["buff"] else Palette.DEBUFF)
	state_changed.emit()


func heal(c: Combatant, amount: int) -> void:
	var healed := c.heal(amount)
	if healed > 0:
		floating_text.emit(c, "+%d" % healed, Palette.GOOD)
		state_changed.emit()


func lose_hp(c: Combatant, amount: int, color: Color = Palette.DEBUFF) -> void:
	if amount <= 0 or not c.is_alive():
		return
	c.hp -= amount
	floating_text.emit(c, "-%d" % amount, color)
	was_hit.emit(c)
	_check_death(c)
	state_changed.emit()


## An attack from src to dst using base damage (modifiers applied here).
func attack(src: Combatant, dst: Combatant, base: int) -> void:
	if dst == null or src == null or not dst.is_alive() or not src.is_alive() or phase == "over":
		return
	var dmg := calc_damage(base, src, dst)
	attacked.emit(src)
	_apply_damage(dst, dmg, true)
	var thorns := dst.get_status("thorns")
	if thorns > 0 and src.is_alive() and phase != "over":
		_apply_damage(src, thorns, false)


func _apply_damage(dst: Combatant, amount: int, is_attack: bool) -> void:
	var absorbed := mini(dst.block, amount)
	dst.block -= absorbed
	var rest := amount - absorbed
	if dst.is_player and is_attack and rest > 0:
		rest = RelicManager.modify_player_damage(rest)
	if rest > 0:
		dst.hp -= rest
		floating_text.emit(dst, "-%d" % rest, Palette.HP)
		was_hit.emit(dst)
	elif absorbed > 0:
		floating_text.emit(dst, "Blocked", Palette.BLOCK)
	_check_death(dst)
	state_changed.emit()


func _check_death(c: Combatant) -> void:
	if c.hp > 0:
		return
	if c.is_player:
		if RelicManager.try_prevent_death(self):
			state_changed.emit()
			return
		c.hp = 0
		_end(false)
		return
	c.hp = 0
	c.block = 0
	c.statuses.clear()
	GameManager.run["stats"]["kills"] = int(GameManager.run["stats"].get("kills", 0)) + 1
	enemy_died.emit(c)
	RelicManager.on_enemy_died(self, c)
	if alive_enemies().is_empty():
		_end(true)


func _end(victory: bool) -> void:
	if phase == "over":
		return
	phase = "over"
	if victory:
		RelicManager.on_combat_end(self)
	GameManager.run["hp"] = maxi(0, player.hp)
	combat_ended.emit(victory)


func _targets(kind: String, chosen: Combatant) -> Array:
	match kind:
		"all":
			return alive_enemies()
		"random":
			var alive := alive_enemies()
			if alive.is_empty():
				return []
			return [alive[rng.randi_range(0, alive.size() - 1)]]
		"self", "none":
			return [player]
	return [chosen] if chosen != null else []


func _resolve_card(c: Dictionary, target: Combatant) -> void:
	for e in c["effects"]:
		if phase == "over":
			return
		var tk: String = e.get("target", c["target"])
		match e["type"]:
			"damage":
				for i in int(e.get("times", 1)):
					for t in _targets(tk, target):
						attack(player, t, int(e["value"]))
			"block":
				gain_block(player, preview_block(int(e["value"])))
			"apply":
				var lst: Array = [player] if tk == "none" else _targets(tk, target)
				for t in lst:
					apply_status(t, e["status"], int(e["value"]))
			"draw":
				draw_cards(int(e["value"]))
			"energy":
				energy += int(e["value"])
			"heal":
				heal(player, int(e["value"]))
			"lose_hp":
				lose_hp(player, int(e["value"]), Palette.HP)
			"add_card":
				for i in int(e.get("count", 1)):
					deck.add_to_hand(make_card(e["card"]))
				hand_changed.emit()
			"double_block":
				gain_block(player, player.block)
			"burst":
				var raw: int = int(e["base"]) + int(e["per"]) * player.get_status(e["status"])
				player.set_status(e["status"], 0)
				for t in _targets(tk, target):
					attack(player, t, raw)
			"block_per":
				gain_block(player, int(e["value"]) * count_of(e["count"]))
			"damage_per":
				attack(player, target, int(e["base"]) + int(e["per"]) * count_of(e["count"]))
			# --- Gadgets
			"gadget":
				deploy_gadget(e["kind"], int(e["power"]), int(e["turns"]))
			"overclock":
				for i in int(e["value"]):
					fire_all_gadgets(false)
			"wind":
				for g in gadgets:
					g["turns"] = int(g["turns"]) + int(e["value"])
				gadgets_changed.emit()
			"tune":
				for g in gadgets:
					g["power"] = int(g["power"]) + int(e["value"])
				gadgets_changed.emit()
			# --- Dice
			"die_damage":
				var v := spend_die(e["pick"])
				attack(player, target, v * int(e["mult"]) + int(e.get("bonus", 0)))
			"die_block":
				var v2 := spend_die(e["pick"])
				gain_block(player, preview_block(v2 * int(e["mult"]) + int(e.get("bonus", 0))))
			"reroll":
				for i in dice.size():
					dice[i] = roll_die()
				dice_changed.emit()
			"add_die":
				for i in int(e.get("count", 1)):
					if dice.size() < MAX_DICE:
						dice.append(int(e["value"]) if int(e.get("value", 0)) > 0 else roll_die())
				dice_changed.emit()
			"bump":
				for i in dice.size():
					dice[i] = mini(6, int(dice[i]) + int(e["value"]))
				dice_changed.emit()
			"set_low":
				if not dice.is_empty():
					dice[_die_index("low")] = int(e["value"])
					dice_changed.emit()
			"set_all":
				for i in dice.size():
					dice[i] = int(e["value"])
				dice_changed.emit()
			"double_high":
				if not dice.is_empty():
					var hi := _die_index("high")
					dice[hi] = int(dice[hi]) * 2
					dice_changed.emit()
			"dice_sum":
				var total := 0
				while not dice.is_empty():
					total += spend_die("high")
				attack(player, target, total * int(e["mult"]) + int(e.get("base", 0)))


# ------------------------------------------------------------------ hero mechanics

func deploy_gadget(kind: String, power: int, turns: int) -> void:
	power += player.get_status("amplify")
	if gadgets.size() >= MAX_GADGETS:
		# The oldest gadget fires one last time as it is pushed out.
		gadget_fired.emit(0)
		_fire_gadget(gadgets[0])
		gadgets.remove_at(0)
	gadgets.append({"kind": kind, "power": power, "turns": turns})
	floating_text.emit(player, CardDatabase.GADGETS[kind]["name"], Color(CardDatabase.GADGETS[kind]["color"]))
	gadgets_changed.emit()


func fire_all_gadgets(wind_down: bool) -> void:
	for i in gadgets.size():
		if phase == "over":
			return
		gadget_fired.emit(i)
		_fire_gadget(gadgets[i])
	if wind_down:
		_wind_down()
	gadgets_changed.emit()


func _fire_gadgets_end_of_turn() -> void:
	for i in gadgets.size():
		if phase == "over":
			return
		gadget_fired.emit(i)
		_fire_gadget(gadgets[i])
		await _wait(0.28)
	_wind_down()
	gadgets_changed.emit()


func _wind_down() -> void:
	if player.get_status("perpetual") > 0:
		return
	for g in gadgets:
		g["turns"] = int(g["turns"]) - 1
	gadgets = gadgets.filter(func(g): return int(g["turns"]) > 0)


func _fire_gadget(g: Dictionary) -> void:
	var p := int(g["power"])
	match g["kind"]:
		"turret":
			var t := _targets("random", null)
			for e in t:
				_gadget_hit(e, p)
		"tesla":
			for e in alive_enemies():
				_gadget_hit(e, p)
		"cannon":
			var alive := alive_enemies()
			if not alive.is_empty():
				alive.sort_custom(func(a, b): return a.hp > b.hp)
				_gadget_hit(alive[0], p)
		"barrier":
			gain_block(player, p)
		"drone":
			heal(player, p)


func _gadget_hit(e: Combatant, p: int) -> void:
	if phase == "over" or not e.is_alive():
		return
	var d := float(p)
	if e.get_status("vulnerable") > 0:
		d *= 1.5
	_apply_damage(e, int(d), false)


func roll_die() -> int:
	var v := rng.randi_range(1, 6)
	if RelicManager.has("weighted_die"):
		v = maxi(v, 2)
	return mini(6, v + player.get_status("lucky"))


func _die_index(pick: String) -> int:
	var idx := 0
	for i in dice.size():
		if (pick == "high" and int(dice[i]) > int(dice[idx])) or (pick == "low" and int(dice[i]) < int(dice[idx])):
			idx = i
	return idx


func peek_die(pick: String) -> int:
	return 0 if dice.is_empty() else int(dice[_die_index(pick)])


func dice_total() -> int:
	var t := 0
	for d in dice:
		t += int(d)
	return t


func spend_die(pick: String) -> int:
	if dice.is_empty():
		return 0
	var i := _die_index(pick)
	var v: int = int(dice[i])
	dice.remove_at(i)
	var fs := player.get_status("fate_six")
	if v >= 6 and fs > 0:
		energy += fs
		draw_cards(fs)
		floating_text.emit(player, "Critical!", Palette.GOLD)
	dice_changed.emit()
	return v


func _update_flow(card_type: String) -> void:
	if last_type == "" or card_type != last_type:
		apply_status(player, "flow", 1)
	elif player.get_status("flow") > 0:
		if player.get_status("grace") > 0:
			player.add_status("flow", -1)
		else:
			player.set_status("flow", 0)
			floating_text.emit(player, "Flow broken", Palette.BAD)
			flow_broken.emit()
	last_type = card_type
	state_changed.emit()


# ------------------------------------------------------------------ enemy AI

func _choose_intent(e: Combatant) -> void:
	var moves: Array = e.data["moves"]
	if e.data.get("pattern", "cycle") == "cycle":
		e.move_index = (e.move_index + 1) % moves.size()
	else:
		var total := 0
		for m in moves:
			total += int(m.get("weight", 1))
		var pick := -1
		for attempt in 6:
			var roll := rng.randi_range(1, total)
			var acc := 0
			for i in moves.size():
				acc += int(moves[i].get("weight", 1))
				if roll <= acc:
					pick = i
					break
			var h: Array = e.history
			var repeat3: bool = h.size() >= 2 and h[-1] == pick and h[-2] == pick
			if not repeat3:
				break
		e.move_index = pick
	e.history.append(e.move_index)
	if e.history.size() > 6:
		e.history.pop_front()
	e.intent = moves[e.move_index]


func _enemy_turn() -> void:
	enemy_turn_started.emit()
	await _wait(0.35)
	for e in enemies.duplicate():
		if phase == "over":
			return
		if not e.is_alive():
			continue
		e.block = 0
		var bleed: int = e.get_status("bleed")
		if bleed > 0:
			lose_hp(e, bleed)
			e.add_status("bleed", -1)
			state_changed.emit()
			await _wait(0.25)
			if phase == "over":
				return
			if not e.is_alive():
				continue
		enemy_acting.emit(e, e.intent.get("name", ""))
		await _execute_move(e)
		if phase == "over":
			return
		_end_of_turn_status(e)
		_choose_intent(e)
		state_changed.emit()
		await _wait(0.4)


func _execute_move(e: Combatant) -> void:
	for eff in e.intent.get("effects", []):
		if phase == "over" or not e.is_alive():
			return
		var self_target: bool = eff.get("target", "player") == "self"
		match eff["type"]:
			"damage":
				for i in int(eff.get("times", 1)):
					attack(e, player, int(eff["value"]))
					await _wait(0.2)
					if phase == "over" or not e.is_alive():
						return
			"block":
				gain_block(e, int(eff["value"]))
			"apply":
				apply_status(e if self_target else player, eff["status"], int(eff["value"]))
			"heal":
				heal(e, int(eff["value"]))
			"add_card":
				for i in int(eff.get("count", 1)):
					deck.discard_pile.append(make_card(eff["card"]))
				floating_text.emit(player, "+%d %s" % [int(eff.get("count", 1)), CardDatabase.CARDS[eff["card"]]["name"]], Palette.DEBUFF)
				hand_changed.emit()
		await _wait(0.12)


func _end_of_turn_status(c: Combatant) -> void:
	var regen := c.get_status("regen")
	if regen > 0:
		heal(c, regen)
		c.add_status("regen", -1)
	var ritual := c.get_status("ritual")
	if ritual > 0 and not c.is_player:
		c.add_status("strength", ritual)
	for s in CardDatabase.DECAYING:
		if c.get_status(s) > 0:
			c.add_status(s, -1)


func _wait(seconds: float) -> void:
	if fast_mode or seconds <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(seconds * speed).timeout
